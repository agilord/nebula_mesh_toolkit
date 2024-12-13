import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:archive/archive.dart';
import 'package:http/http.dart' as http;
import 'package:nebula_mesh_toolkit/src/os_utils.dart';
import 'package:path/path.dart' as p;

abstract class NebulaAssets {
  Future<String> getLatestVersion();

  Future<void> extractReleaseTo({
    String? version,
    required String os,
    required String targetPath,
  });
}

class GitHubNebulaAssets implements NebulaAssets {
  final String? _cacheDir;
  String? _latestVersion;
  final _binaries = <String, Uint8List>{};

  GitHubNebulaAssets({
    String? cacheDir,
  }) : _cacheDir = cacheDir;

  Future<void> _clearAllCachedFilesOlderThanMonth() async {
    if (_cacheDir == null) {
      return;
    }
    final dir = Directory(_cacheDir);
    if (!dir.existsSync()) {
      return;
    }
    final files = dir.listSync(recursive: true).whereType<File>();
    for (final file in files) {
      final age = DateTime.now().difference(file.lastModifiedSync());
      if (age.inDays <= 30) continue;
      await file.delete();
    }
  }

  String _cachedUriToName(Uri uri) {
    return uri
        .toString()
        .replaceAll(':', '_')
        .replaceAll('/', '_')
        .replaceAll(RegExp('[_]+'), '_');
  }

  Future<Uint8List?> _getCachedBytes(
    Uri uri, {
    Duration ttl = const Duration(hours: 24),
  }) async {
    if (_cacheDir == null) {
      return null;
    }
    await _clearAllCachedFilesOlderThanMonth();
    final file = File(p.join(_cacheDir, _cachedUriToName(uri)));
    if (file.existsSync()) {
      final age = DateTime.now().difference(file.lastModifiedSync());
      if (age < ttl) {
        return await file.readAsBytes();
      }
    }
    return null;
  }

  Future<void> _storeCachedBytes(Uri uri, Uint8List bytes) async {
    if (_cacheDir == null) {
      return;
    }
    final file = File(p.join(_cacheDir, _cachedUriToName(uri)));
    await file.parent.create(recursive: true);
    await file.writeAsBytes(bytes);
  }

  @override
  Future<String> getLatestVersion() async {
    if (_latestVersion != null) {
      return _latestVersion!;
    }
    final uri = Uri.parse('https://github.com/slackhq/nebula/releases');
    final cachedBytes = await _getCachedBytes(uri);
    if (cachedBytes != null) {
      return _latestVersion = utf8.decode(cachedBytes);
    }
    final rs = await http.get(uri);
    if (rs.statusCode != 200) {
      throw Exception('Unable to request $uri');
    }
    final releaseExp = RegExp(r'\>Release (v[0-9]+\.[0-9]+\.[0-9]+)<');
    final fm = releaseExp.firstMatch(rs.body);
    if (fm == null) {
      throw Exception('Unable to extract latest release version.');
    }
    _latestVersion = fm.group(1);
    await _storeCachedBytes(uri, utf8.encode(_latestVersion!));
    return _latestVersion!;
  }

  @override
  Future<void> extractReleaseTo({
    String? version,
    required String os,
    required String targetPath,
  }) async {
    version ??= await getLatestVersion();
    os = expandOS(os);
    final ext = os.startsWith('windows-') ? 'zip' : 'tar.gz';
    final uri = Uri.parse(
        'https://github.com/slackhq/nebula/releases/download/$version/nebula-$os.$ext');
    Uint8List? bytes = _binaries[uri.toString()];
    bytes ??= await _getCachedBytes(uri);
    if (bytes == null) {
      final rs = await http.get(uri);
      if (rs.statusCode != 200) {
        throw Exception('Unable to download $uri.');
      }
      bytes = rs.bodyBytes;
      _binaries[uri.toString()] = bytes;
      await _storeCachedBytes(uri, bytes);
    }

    late Archive archive;
    switch (ext) {
      case 'tar.gz':
        archive = TarDecoder().decodeBytes(gzip.decode(bytes));
        break;
      case 'zip':
        archive = ZipDecoder().decodeBytes(bytes);
        break;
      default:
        throw UnimplementedError('extracting $ext is not implemented');
    }

    for (final file in archive) {
      if (!file.isFile) continue;
      final outputFile = File(p.join(targetPath, file.name));
      await outputFile.parent.create(recursive: true);
      await outputFile.writeAsBytes(file.content);
      if (!Platform.isWindows && (file.mode & 0x49) != 0) {
        await Process.run('chmod', ['+x', outputFile.path]);
      }
    }
  }
}
