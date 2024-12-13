String? translateDuration(String? input) {
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

  return [
    if (hours > 0) '${hours}h',
    input,
  ].join();
}
