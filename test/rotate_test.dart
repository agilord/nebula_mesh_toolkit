import 'dart:io';

import 'package:nebula_mesh_toolkit/src/generator.dart';
import 'package:nebula_mesh_toolkit/src/nebula_assets.dart';
import 'package:nebula_mesh_toolkit/src/nebula_cli.dart';
import 'package:nebula_mesh_toolkit/src/network_template.dart';
import 'package:path/path.dart' as p;
import 'package:test/test.dart';

void main() {
  group('Key rotation', () {
    final gh = GitHubNebulaAssets(cacheDir: '.dart_tool/cached-github');
    late Directory cliTemp;

    setUpAll(() async {
      cliTemp = await Directory.systemTemp.createTemp();
      await gh.extractReleaseTo(os: 'linux', targetPath: cliTemp.path);
    });

    tearDownAll(() async {
      await cliTemp.delete(recursive: true);
    });

    test('two keys on a single machine', () async {
      final temp = await Directory.systemTemp.createTemp();

      List<String> listFiles() => temp
          .listSync(recursive: true)
          .whereType<File>()
          .map((f) => p.relative(f.path, from: temp.path))
          .toList();

      try {
        final cli = NebulaCli(path: cliTemp.path);

        final network = Network(domain: 'neb.internal', templates: [
          Template(
            hosts: [Host(name: 'lh', address: '192.168.11.1/24')],
          ),
        ]);
        // generate artifacts programmatically
        final gh = GitHubNebulaAssets(cacheDir: '.dart_tool/cached-github');
        await network.generateArtifacts(outputPath: temp.path, assets: gh);
        await cli.testConfig(
          configPath: p.join(temp.path, 'hosts/lh/etc/lh.neb.internal.yml'),
          workingDirectory: p.join(temp.path, 'hosts/lh/etc'),
        );
        expect(listFiles(), hasLength(16));

        // second run
        await network.generateArtifacts(outputPath: temp.path, assets: gh);
        expect(listFiles(), hasLength(22));

        final caCertContent =
            await File(p.join(temp.path, 'ca', 'neb.internal.ca.crt'))
                .readAsString();
        expect(caCertContent.split('NEBULA CERTIFICATE').length, 5);

        final hostCertContent = await File(
                p.join(temp.path, 'hosts', 'lh', 'etc', 'lh.neb.internal.crt'))
            .readAsString();
        expect(hostCertContent.split('NEBULA CERTIFICATE').length, 3);

        await cli.testConfig(
          configPath: p.join(temp.path, 'hosts/lh/etc/lh.neb.internal.yml'),
          workingDirectory: p.join(temp.path, 'hosts/lh/etc'),
        );

        // keep current ca for longer
        final n2 = Network.fromJson(network.toJson()..['keep'] = '1h');
        await n2.generateArtifacts(outputPath: temp.path, assets: gh);
        expect(listFiles(), hasLength(22));
      } finally {
        await temp.delete(recursive: true);
      }
    });
  });
}
