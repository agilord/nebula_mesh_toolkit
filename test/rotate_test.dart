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

        final network = Network(id: 12, templates: [
          Template(
            hosts: [Host(name: 'lh', address: '192.168.11.1/24')],
          ),
        ]);
        // generate artifacts programmatically
        final gh = GitHubNebulaAssets(cacheDir: '.dart_tool/cached-github');
        await network.generateArtifacts(outputPath: temp.path, assets: gh);
        await cli.testConfig(
          configPath: p.join(temp.path, 'hosts/lh/etc/nebula-12-lh.yml'),
          workingDirectory: p.join(temp.path, 'hosts/lh/etc'),
        );
        expect(listFiles(), hasLength(14));

        // second run
        await network.generateArtifacts(outputPath: temp.path, assets: gh);
        expect(listFiles(), hasLength(20));

        final caCertContent =
            await File(p.join(temp.path, 'ca', 'nebula-12.ca.crt'))
                .readAsString();
        expect(caCertContent.split('NEBULA CERTIFICATE').length, 5);

        final hostCertContent = await File(
                p.join(temp.path, 'hosts', 'lh', 'etc', 'nebula-12-lh.crt'))
            .readAsString();
        expect(hostCertContent.split('NEBULA CERTIFICATE').length, 3);

        await cli.testConfig(
          configPath: p.join(temp.path, 'hosts/lh/etc/nebula-12-lh.yml'),
          workingDirectory: p.join(temp.path, 'hosts/lh/etc'),
        );

        // renew keeps current ca
        final n2 = Network.fromJson(network.toJson()..['renew'] = '1h');
        await n2.generateArtifacts(outputPath: temp.path, assets: gh);
        expect(listFiles(), hasLength(20));
      } finally {
        await temp.delete(recursive: true);
      }
    });
  });
}
