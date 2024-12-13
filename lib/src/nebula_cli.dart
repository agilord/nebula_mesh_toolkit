import 'dart:io';

import 'package:path/path.dart' as p;

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

  Future<void> ca({
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
  }

  Future<void> sign({
    required String caPrefix,
    List<String>? groups,
    required String ip,
    required String name,
    required String outputPrefix,
    String? duration,
  }) async {
    groups ??= const <String>[];
    await _run([
      _certBin,
      'sign',
      if (duration != null) ...['-duration', duration],
      '-ca-crt',
      '$caPrefix.crt',
      '-ca-key',
      '$caPrefix.key',
      if (groups.isNotEmpty) ...['-groups', groups.join(',')],
      '-ip',
      ip,
      '-name',
      name,
      '-out-crt',
      '$outputPrefix.crt',
      '-out-key',
      '$outputPrefix.key',
      '-out-qr',
      '$outputPrefix.png',
    ]);
  }
}
