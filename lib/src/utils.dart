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

class CidrGenerator {
  final String _base;
  late final _prefix = _base.split('/').first;
  late final _prefixBytes = _prefix.split('.').map(int.parse).toList();
  late final _prefixBitsValue = _base.split('/').last;
  late final _prefixBits = int.parse(_prefixBitsValue);

  int _beginCounter = 0;
  late final _beginBytes = () {
    final bytes = [..._prefixBytes];
    var zeroByteIndex = bytes.length - 1;
    var zeroBitIndex = 0;
    final zeroCounter = (bytes.length * 8) - _prefixBits;
    for (var i = 0; i < zeroCounter; i++) {
      final bitMask = 0xff - (1 << zeroBitIndex);
      bytes[zeroByteIndex] = bytes[zeroByteIndex] & bitMask;
      // next
      zeroBitIndex++;
      if (zeroBitIndex == 8) {
        zeroBitIndex = 0;
        zeroByteIndex--;
      }
    }
    return bytes;
  }();

  CidrGenerator(this._base);

  void _incBegin() {
    final bytes = _beginBytes;
    _beginCounter++;
    for (var i = bytes.length - 1; i >= 0; i--) {
      if (bytes[i] == 255) {
        bytes[i] = i == bytes.length ? 1 : 0;
        continue;
      }
      bytes[i] = bytes[i] + 1;
      break;
    }
  }

  String next() {
    _incBegin();
    return '${_beginBytes.join('.')}/$_prefixBits';
  }

  @override
  String toString() => 'CidrGenerator(counter = $_beginCounter)';
}
