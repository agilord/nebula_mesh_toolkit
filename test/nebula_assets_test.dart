import 'dart:io';

import 'package:nebula_mesh_toolkit/src/nebula_assets.dart';
import 'package:path/path.dart';
import 'package:test/test.dart';

void main() {
  group('GitHub', () {
    final gh = GitHubNebulaAssets(cacheDir: '.dart_tool/cached-github');

    test('detect latest version', () async {
      final v = await gh.getLatestVersion();
      expect(v, startsWith('v'));
      final parts = v.substring(1).split('.');
      expect(parts.length, 3);
      expect(int.parse(parts[0]) >= 1, true);
      expect(int.parse(parts[0]) >= 2 || int.parse(parts[1]) >= 9, true);
    });

    test('download defaults', () async {
      final dir = await Directory.systemTemp.createTemp();
      try {
        await gh.extractReleaseTo(os: 'linux', targetPath: dir.path);
        final files = dir.listSync(recursive: true).whereType<File>();
        expect(files.map((f) => relative(f.path, from: dir.path)).toSet(), {
          'nebula',
          'nebula-cert',
        });
      } finally {
        await dir.delete(recursive: true);
      }
    });
  });
}
