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
    await _NetworkGenerator(
      network: this,
      outputPath: outputPath,
    ).generateArtifacts(assets: assets);
  }
}

class _NetworkGenerator {
  final Network network;
  final String outputPath;

  _NetworkGenerator({
    required this.network,
    required this.outputPath,
  });

  late final Directory _tempRoot;
  late final NebulaCli _cli;
  late final NebulaAssets _assets;

  late final _entries = network.templates
      .expand((t) => t.hosts.map((h) => _HostTemplate(h, t)))
      .toList();
  late final _lighthouses = _entries.where((e) => e.isLighthouse).toList();
  late final _lighthousesStaticHostMap = Map.fromEntries(_lighthouses
      .where((e) =>
          e.host.publicAddresses != null && e.host.publicAddresses!.isNotEmpty)
      .map((e) => MapEntry(e.host.address, e.host.publicAddresses ?? [])));

  late final _netName = 'nebula-${network.id}';
  late final File _allCaCrtFile;
  late final List<Certificate> _validCaCerts;

  Future<void> generateArtifacts({
    NebulaAssets? assets,
  }) async {
    _tempRoot = await Directory.systemTemp.createTemp();
    try {
      await _initAssetsAndCli(assets);
      await Directory(outputPath).create(recursive: true);
      await _generateNewCaKey();
      await _refreshCaCertsUpdateAllCaCrt();

      for (final entry in _entries) {
        await _HostGenerator(this, entry).generateArtifacts();
      }
    } finally {
      await _tempRoot.delete(recursive: true);
    }
  }

  Future<void> _initAssetsAndCli(NebulaAssets? assets) async {
    final tempBin = Directory(p.join(_tempRoot.path, 'bin'));
    await tempBin.create(recursive: true);
    _assets = assets ?? GitHubNebulaAssets();
    await _assets.extractReleaseTo(os: 'linux', targetPath: tempBin.path);
    _cli = NebulaCli(path: tempBin.path);
  }

  Future<void> _generateNewCaKey() async {
    final parsedRenew = parseDuration(network.renew);
    if (parsedRenew != null) {
      final currentCerts =
          await loadCertificatesFromDirectory(p.join(outputPath, 'ca', 'keys'));
      final threshold = DateTime.now().subtract(parsedRenew);
      if (currentCerts
          .any((c) => c.certificate.details!.notBefore!.isAfter(threshold))) {
        return;
      }
    }

    final tempCAPrefix = p.join(_tempRoot.path, 'ca', _netName);
    await File('$tempCAPrefix.crt').parent.create(recursive: true);
    final newCaCert = await _cli.ca(
      name: network.name ?? _netName,
      outputPrefix: tempCAPrefix,
      duration: translateDuration(network.duration),
    );
    final caFingerprint = newCaCert.fingerprint;
    if (caFingerprint == null || caFingerprint.isEmpty) {
      throw AssertionError('No CA fingerprint detected.');
    }
    final canonicalCaPrefix =
        p.join(outputPath, 'ca', 'keys', newCaCert.canonicalId);
    await File('$canonicalCaPrefix.crt').parent.create(recursive: true);
    await File('$tempCAPrefix.crt').copy('$canonicalCaPrefix.crt');
    await File('$tempCAPrefix.crt.json').copy('$canonicalCaPrefix.crt.json');
    await File('$tempCAPrefix.key').copy('$canonicalCaPrefix.key');
  }

  Future<void> _refreshCaCertsUpdateAllCaCrt() async {
    final currentCerts =
        await loadCertificatesFromDirectory(p.join(outputPath, 'ca', 'keys'));
    _validCaCerts = currentCerts
        .map((cf) => cf.certificate)
        .where((c) => c.isValid())
        .toList()
      ..sort((a, b) => a.canonicalId.compareTo(b.canonicalId));
    final allCaCertContent = StringBuffer();
    for (final cert in _validCaCerts) {
      final content = await File(
              p.join(outputPath, 'ca', 'keys', '${cert.canonicalId}.crt'))
          .readAsString();
      allCaCertContent.writeln(content.trim());
    }
    if (allCaCertContent.isEmpty) {
      throw AssertionError('No valid CA cert available.');
    }
    _allCaCrtFile = File(p.join(outputPath, 'ca', '$_netName.ca.crt'));
    await _allCaCrtFile.writeAsString(allCaCertContent.toString());
  }
}

class _HostGenerator {
  final _NetworkGenerator _parent;
  final _HostTemplate entry;

  _HostGenerator(this._parent, this.entry);

  late final _netName = _parent._netName;
  late final _hostDir =
      Directory(p.join(_parent.outputPath, 'hosts', entry.host.name));
  late final _resolvedOS = expandOS(
      entry.host.os ?? entry.template.os ?? _parent.network.os ?? 'linux');
  late final _etcDir = Directory(p.join(_hostDir.path, 'etc'));
  late final _qualifiedName = '$_netName-${entry.host.name}';

  Future<void> generateArtifacts() async {
    await _hostDir.create(recursive: true);
    await _extractBinFiles();

    await _etcDir.create(recursive: true);
    await _parent._allCaCrtFile.copy(p.join(_etcDir.path, '$_netName.ca.crt'));

    await _updateCertificates();
    await _updateConfig();
  }

  Future<void> _extractBinFiles() async {
    if (_resolvedOS != 'android') {
      final bin = p.join(_hostDir.path, 'bin');
      await Directory(bin).create(recursive: true);
      await _parent._assets.extractReleaseTo(os: _resolvedOS, targetPath: bin);
    }
  }

  Future<void> _updateCertificates() async {
    final hostCertsDir = Directory(p.join(_hostDir.path, 'certs'));
    final keyPrefix = p.join(_etcDir.path, _qualifiedName);
    final resetKeys = !File('$keyPrefix.pub').existsSync();
    if (resetKeys) {
      await _parent._cli.keygen(outputPrefix: keyPrefix);
      if (await hostCertsDir.exists()) {
        await hostCertsDir.delete(recursive: true);
      }
    }

    await hostCertsDir.create(recursive: true);
    for (final caCert in _parent._validCaCerts) {
      final hostCertPrefix = p.join(hostCertsDir.path, caCert.canonicalId);
      final hostCertFile = File('$hostCertPrefix.crt');
      if (await hostCertFile.exists()) continue;
      await hostCertFile.parent.create(recursive: true);

      final caPrefix =
          p.join(_parent.outputPath, 'ca', 'keys', caCert.canonicalId);
      await _parent._cli.sign(
        caPrefix: caPrefix,
        ip: entry.host.address,
        name: entry.host.name,
        pubKeyPath: '$keyPrefix.pub',
        outputPrefix: hostCertPrefix,
        groups: entry.template.groups,
        duration:
            translateDuration(entry.host.duration ?? entry.template.duration),
      );
    }

    final hostCertFiles =
        await loadCertificatesFromDirectory(hostCertsDir.path);
    final cf = hostCertFiles.reduce((a, b) => a.certificate.details!.notAfter!
            .isAfter(b.certificate.details!.notAfter!)
        ? a
        : b);
    final certContent =
        await File(cf.path.substring(0, cf.path.length - 5)).readAsString();
    await File(p.join(_etcDir.path, '$keyPrefix.crt'))
        .writeAsString(certContent);
  }

  Future<void> _updateConfig() async {
    final staticHostMap = {
      if (!entry.isLighthouse) ..._parent._lighthousesStaticHostMap,
      ...?entry.template.staticHostMap,
    };

    var relay = entry.template.relay;
    final relays = relay?.relays
        ?.expand((e) => e.startsWith('@')
            ? _parent._entries
                .where(
                    (x) => x.template.groups?.contains(e.substring(1)) ?? false)
                .map((x) => x.host.address.split('/').first)
            : [e])
        .toSet()
        .toList();
    relay = relay?.replace(relays: relays);

    final config = Nebula(
      pki: Pki(
        ca: '$_netName.ca.crt',
        cert: '$_qualifiedName.crt',
        key: '$_qualifiedName.key',
      ),
      cipher: _parent.network.cipher,
      staticHostMap: staticHostMap.isEmpty ? null : staticHostMap,
      lighthouse: entry.isLighthouse
          ? Lighthouse(amLighthouse: true)
          : Lighthouse(
              hosts: _parent._lighthouses.map((e) => e.host.address).toList(),
            ),
      listen: entry.host.listen ?? entry.template.listen,
      tun: Tun(
        dev: tunDeviceName(_resolvedOS, _parent.network.id),
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
    await File(p.join(_etcDir.path, '$_qualifiedName.yml'))
        .writeAsString('${config.toYamlString()}\n');
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

Future<List<CertificateJsonFile>> loadCertificatesFromDirectory(
    String path) async {
  final dir = Directory(path);
  if (!await dir.exists()) {
    return [];
  }
  final files = dir
      .listSync()
      .whereType<File>()
      .where((f) => f.path.endsWith('.crt.json'))
      .toList();
  return files.map((f) {
    final content = f.readAsStringSync();
    final map = json.decode(content) as Map<String, dynamic>;
    final cert = Certificate.fromJson(map);
    return CertificateJsonFile(f.path, cert);
  }).toList();
}

class CertificateJsonFile {
  final String path;
  final Certificate certificate;

  CertificateJsonFile(this.path, this.certificate);
}
