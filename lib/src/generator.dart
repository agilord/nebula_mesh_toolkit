import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as p;

import 'nebula_assets.dart';
import 'nebula_cli.dart';
import 'nebula_config.dart';
import 'network_template.dart';
import 'os_utils.dart';
import 'utils.dart';

extension NetworkGeneratorExt on Network {
  /// Generates artifacts with reasonable defaults.
  Future<void> generateArtifacts({
    required String outputPath,
    NebulaAssets? assets,
  }) async {
    final temp = await Directory.systemTemp.createTemp();
    try {
      final tempBin = Directory(p.join(temp.path, 'bin'));
      await tempBin.create(recursive: true);
      assets ??= GitHubNebulaAssets();
      await assets.extractReleaseTo(os: 'linux', targetPath: tempBin.path);
      final cli = NebulaCli(path: tempBin.path);

      await Directory(outputPath).create(recursive: true);
      final existingCaCerts =
          await loadCertificatesFromDirectory(p.join(outputPath, 'ca', 'keys'));

      // next ca key
      final netName = 'nebula-$id';
      final tempCAPrefix = p.join(temp.path, 'ca', netName);
      await File('$tempCAPrefix.crt').parent.create(recursive: true);
      final caCert = await cli.ca(
        name: name ?? netName,
        outputPrefix: tempCAPrefix,
        duration: translateDuration(duration),
      );
      final caFingerprint = caCert.fingerprint;
      if (caFingerprint == null || caFingerprint.isEmpty) {
        throw AssertionError('No CA fingerprint detected.');
      }
      final caPrefix = p.join(outputPath, 'ca', 'keys', caCert.canonicalId);
      await File('$caPrefix.crt').parent.create(recursive: true);
      await File('$tempCAPrefix.crt').copy('$caPrefix.crt');
      await File('$tempCAPrefix.crt.json').copy('$caPrefix.crt.json');
      await File('$tempCAPrefix.key').copy('$caPrefix.key');

      final now = DateTime.now();
      final validCaCerts = [
        ...existingCaCerts,
        caCert,
      ].where((c) => !now.isAfter(c.details!.notAfter!)).toList()
        ..sort((a, b) => a.canonicalId.compareTo(b.canonicalId));
      final allCaCertContent = StringBuffer();
      for (final cert in validCaCerts) {
        final content = await File(
                p.join(outputPath, 'ca', 'keys', '${cert.canonicalId}.crt'))
            .readAsString();
        allCaCertContent.writeln(content);
      }
      if (allCaCertContent.isEmpty) {
        throw AssertionError('No valid CA cert available.');
      }
      final allCaCrtFile = File(p.join(outputPath, 'ca', '$netName.ca.crt'));
      await allCaCrtFile.writeAsString(allCaCertContent.toString());

      final entries = templates
          .expand((t) => t.hosts.map((h) => _HostTemplate(h, t)))
          .toList();
      final lighthouses = entries.where((e) => e.isLighthouse).toList();
      final lighthousesStaticHostMap = Map.fromEntries(lighthouses
          .where((e) =>
              e.host.publicAddresses != null &&
              e.host.publicAddresses!.isNotEmpty)
          .map((e) => MapEntry(e.host.address, e.host.publicAddresses ?? [])));
      for (final entry in entries) {
        final dir = Directory(p.join(outputPath, 'hosts', entry.host.name));
        await dir.create(recursive: true);
        final bin = p.join(dir.path, 'bin');
        await Directory(bin).create(recursive: true);

        final resolvedOS =
            expandOS(entry.host.os ?? entry.template.os ?? os ?? 'linux');
        if (resolvedOS != 'android') {
          await assets.extractReleaseTo(os: resolvedOS, targetPath: bin);
        }

        final etc = p.join(dir.path, 'etc');
        await Directory(etc).create(recursive: true);
        await allCaCrtFile.copy(p.join(etc, '$netName.ca.crt'));

        final prefixNamePart = '$netName-${entry.host.name}';
        final keyPrefix = p.join(etc, prefixNamePart);
        await cli.keygen(outputPrefix: keyPrefix);
        await cli.sign(
          caPrefix: caPrefix,
          ip: entry.host.address,
          name: entry.host.name,
          outputPrefix: keyPrefix,
          groups: entry.template.groups,
          duration:
              translateDuration(entry.host.duration ?? entry.template.duration),
        );

        final staticHostMap = {
          if (!entry.isLighthouse) ...lighthousesStaticHostMap,
          ...?entry.template.staticHostMap,
        };

        var relay = entry.template.relay;
        final relays = relay?.relays
            ?.expand((e) => e.startsWith('@')
                ? entries
                    .where((x) =>
                        x.template.groups?.contains(e.substring(1)) ?? false)
                    .map((x) => x.host.address.split('/').first)
                : [e])
            .toSet()
            .toList();
        relay = relay?.replace(relays: relays);

        final config = Nebula(
          pki: Pki(
            ca: '$netName.ca.crt',
            cert: '$prefixNamePart.crt',
            key: '$prefixNamePart.key',
          ),
          cipher: cipher,
          staticHostMap: staticHostMap.isEmpty ? null : staticHostMap,
          lighthouse: entry.isLighthouse
              ? Lighthouse(amLighthouse: true)
              : Lighthouse(
                  hosts: lighthouses.map((e) => e.host.address).toList(),
                ),
          listen: entry.host.listen ?? entry.template.listen,
          tun: Tun(
            dev: tunDeviceName(resolvedOS, id),
          ),
          punchy: entry.template.punchy,
          relay: relay,
          firewall: _mergeFirewall(
                  entry.template.firewall, entry.template.firewallPresets) ??
              Firewall(
                outbound: [
                  FirewallRule(host: 'any'),
                ],
                inbound: [
                  FirewallRule(proto: 'icmp', host: 'any'),
                ],
              ),
        );
        await File(p.join(etc, '$prefixNamePart.yml'))
            .writeAsString('${config.toYamlString()}\n');
      }
    } finally {
      await temp.delete(recursive: true);
    }
  }
}

class _HostTemplate {
  final Host host;
  final Template template;

  _HostTemplate(this.host, this.template);

  late final isLighthouse =
      (template.groups ?? const []).contains('lighthouse');
}

Firewall? _mergeFirewall(Firewall? defined, List<String>? presetNames) {
  final inbound = <FirewallRule>{...?defined?.inbound};
  final outbound = <FirewallRule>{...?defined?.outbound};

  for (final name in presetNames ?? []) {
    if (name == 'any') {
      inbound.add(FirewallRule(host: 'any'));
      outbound.add(FirewallRule(host: 'any'));
      continue;
    }

    throw UnimplementedError('Unknown preset name: $name');
  }

  if (inbound.isEmpty && outbound.isEmpty) {
    return null;
  }
  return Firewall(
    inbound: inbound.toList(),
    outbound: outbound.toList(),
  );
}

Future<List<Certificate>> loadCertificatesFromDirectory(String path) async {
  final dir = Directory(path);
  if (!await dir.exists()) {
    return [];
  }
  final files = dir
      .listSync()
      .whereType<File>()
      .where((f) => f.path.endsWith('.crt.json'))
      .toList();
  return files
      .map((f) => f.readAsStringSync())
      .map(json.decode)
      .map((j) => Certificate.fromJson(j as Map<String, dynamic>))
      .toList();
}
