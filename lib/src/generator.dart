import 'dart:io';

import 'package:nebula_mesh_toolkit/src/nebula_config.dart';
import 'package:nebula_mesh_toolkit/src/os_utils.dart';
import 'package:path/path.dart' as p;

import 'package:nebula_mesh_toolkit/src/nebula_assets.dart';
import 'package:nebula_mesh_toolkit/src/nebula_cli.dart';

import 'network_template.dart';

extension NetworkGeneratorExt on Network {
  /// Generates artifacts with reasonable defaults.
  Future<void> generateArtifacts({
    required String outputPath,
    NebulaAssets? assets,
  }) async {
    final temp = await Directory.systemTemp.createTemp();
    try {
      assets ??= GitHubNebulaAssets();
      await assets.extractReleaseTo(os: 'linux', targetPath: temp.path);
      final cli = await NebulaCli(path: temp.path);

      await Directory(outputPath).create(recursive: true);
      final caName = 'nebula-$id-ca';
      final caPrefix = p.join(outputPath, caName);
      await cli.ca(name: name ?? 'nebula-$id', outputPrefix: caPrefix);

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
        final dir = Directory(p.join(outputPath, entry.host.name));
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
        await File('$caPrefix.crt').copy(p.join(etc, '$caName.crt'));

        final prefix = 'nebula-$id-${entry.host.name}';
        final fullCertPrefix = p.join(etc, prefix);
        await cli.sign(
          caPrefix: caPrefix,
          ip: entry.host.address,
          name: entry.host.name,
          outputPrefix: fullCertPrefix,
          groups: entry.template.groups,
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
            ca: '$caName.crt',
            cert: '$prefix.crt',
            key: '$prefix.key',
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
        await File(p.join(etc, '$prefix.yml'))
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
