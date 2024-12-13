import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as p;

import 'nebula_config.dart';

class NebulaCli {
  final String? path;

  late final _certBin = p.joinAll([
    if (path != null) path!,
    'nebula-cert',
  ]);

  NebulaCli({
    this.path,
  });

  Future<ProcessResult> _run(List<String> args) async {
    final pr = await Process.run(
      args.first,
      args.skip(1).toList(),
    );
    if (pr.exitCode != 0) {
      throw Exception('Unable to run $args\n${pr.stdout}\n${pr.stderr}\n');
    }
    return pr;
  }

  Future<Certificate> ca({
    required String name,
    required String outputPrefix,
    String? duration,
  }) async {
    await _run([
      _certBin,
      'ca',
      if (duration != null) ...['-duration', duration],
      '-name',
      name,
      '-out-crt',
      '$outputPrefix.crt',
      '-out-key',
      '$outputPrefix.key',
    ]);
    return await _printAndSaveCert('$outputPrefix.crt');
  }

  Future<void> keygen({required String outputPrefix}) async {
    await _run([
      _certBin,
      'keygen',
      '-out-key',
      '$outputPrefix.key',
      '-out-pub',
      '$outputPrefix.pub',
    ]);
  }

  Future<Certificate> sign({
    required String caPrefix,
    List<String>? groups,
    required String ip,
    required String name,
    required String outputPrefix,
    String? duration,
  }) async {
    groups ??= const <String>[];
    final pubKeyPath = '$outputPrefix.pub';
    final pubKeyExists = File(pubKeyPath).existsSync();
    await _run([
      _certBin,
      'sign',
      if (duration != null) ...['-duration', duration],
      '-ca-crt',
      '$caPrefix.crt',
      '-ca-key',
      '$caPrefix.key',
      if (pubKeyExists) ...[
        '-in-pub',
        pubKeyPath,
      ],
      if (groups.isNotEmpty) ...['-groups', groups.join(',')],
      '-ip',
      ip,
      '-name',
      name,
      '-out-crt',
      '$outputPrefix.crt',
      if (!pubKeyExists) ...[
        '-out-key',
        '$outputPrefix.key',
      ],
      '-out-qr',
      '$outputPrefix.png',
    ]);
    return await _printAndSaveCert('$outputPrefix.crt');
  }

  Future<Certificate> _printAndSaveCert(String certPath) async {
    final pr = await _run([
      _certBin,
      'print',
      '-json',
      '-path',
      certPath,
    ]);
    final map = json.decode(pr.stdout.toString()) as Map<String, dynamic>;
    await File('$certPath.json')
        .writeAsString(JsonEncoder.withIndent('  ').convert(map));
    return Certificate.fromJson(map);
  }
}
