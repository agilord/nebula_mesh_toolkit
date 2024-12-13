import 'dart:io';

import 'package:nebula_mesh_toolkit/src/nebula_assets.dart';
import 'package:nebula_mesh_toolkit/src/nebula_cli.dart';
import 'package:path/path.dart' as p;
import 'package:test/test.dart';

void main() {
  group('CLI test', () {
    final gh = GitHubNebulaAssets(cacheDir: '.dart_tool/cached-github');
    late Directory cliTemp;

    setUpAll(() async {
      cliTemp = await Directory.systemTemp.createTemp();
      await gh.extractReleaseTo(os: 'linux', targetPath: cliTemp.path);
    });

    tearDownAll(() async {
      await cliTemp.delete(recursive: true);
    });

    test('CA + signing in one step', () async {
      final temp = await Directory.systemTemp.createTemp();
      try {
        final cli = NebulaCli(path: cliTemp.path);
        final caPrefix = p.join(temp.path, 'test-ca');
        await cli.ca(name: 'Test CA', outputPrefix: caPrefix);
        await cli.sign(
          caPrefix: caPrefix,
          ip: '192.168.100.1/24',
          name: 'machine',
          groups: ['a', 'b'],
          outputPrefix: p.join(temp.path, 'machine'),
        );

        final files = temp.listSync().whereType<File>();
        final paths = files
            .map((e) => e.path)
            .map((e) => p.relative(e, from: temp.path))
            .toSet();
        expect(paths, {
          'test-ca.crt',
          'test-ca.crt.json',
          'test-ca.key',
          'machine.crt',
          'machine.crt.json',
          'machine.key',
          'machine.png',
        });
      } finally {
        await temp.delete(recursive: true);
      }
    });

    test('CA + keygen + sign', () async {
      final temp = await Directory.systemTemp.createTemp();
      try {
        final cli = NebulaCli(path: cliTemp.path);
        final caPrefix = p.join(temp.path, 'test-ca');
        await cli.ca(name: 'Test CA', outputPrefix: caPrefix);
        final machinePrefix = p.join(temp.path, 'machine');
        await cli.keygen(outputPrefix: machinePrefix);
        await cli.sign(
          caPrefix: caPrefix,
          ip: '192.168.100.1/24',
          name: 'machine',
          groups: ['a', 'b'],
          outputPrefix: p.join(temp.path, 'machine'),
        );

        final files = temp.listSync().whereType<File>();
        final paths = files
            .map((e) => e.path)
            .map((e) => p.relative(e, from: temp.path))
            .toSet();
        expect(paths, {
          'test-ca.crt',
          'test-ca.crt.json',
          'test-ca.key',
          'machine.crt',
          'machine.crt.json',
          'machine.key',
          'machine.pub',
          'machine.png',
        });
      } finally {
        await temp.delete(recursive: true);
      }
    });
  });
}
