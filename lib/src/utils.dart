Duration? parseDuration(String? input) {
  if (input == null) {
    return null;
  }
  int hours = 0;
  final y = input.split('y');
  if (y.length == 2) {
    hours += int.parse(y[0]) * 365 * 24;
    input = y[1];
  }

  final d = input.split('d');
  if (d.length == 2) {
    hours += int.parse(d[0]) * 24;
    input = d[1];
  }

  final h = input.split('h');
  if (h.length == 2) {
    hours += int.parse(h[0]);
    input = h[1];
  }

  var seconds = 0;
  final m = input.split('m');
  if (m.length == 2) {
    seconds += int.parse(m[0]) * 60;
    input = m[1];
  }
  final s = input.split('s');
  if (s.first.isNotEmpty) {
    seconds += int.parse(s.first);
  }

  return Duration(hours: hours, seconds: seconds);
}

String? translateDuration(String? input) {
  final d = parseDuration(input);
  if (d == null) {
    return null;
  }
  final seconds = d.inSeconds;
  return [
    if (seconds > 0) '${seconds}s',
  ].join();
}
