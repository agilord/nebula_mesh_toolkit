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

void _setLastBits(List<int> bytes, int prefixBits, bool set) {
  var byteIndex = bytes.length - 1;
  var bitIndex = 0;
  final counter = (bytes.length * 8) - prefixBits;
  for (var i = 0; i < counter; i++) {
    if (set) {
      final bitMask = 1 << bitIndex;
      bytes[byteIndex] = bytes[byteIndex] | bitMask;
    } else {
      final bitMask = 0xff - (1 << bitIndex);
      bytes[byteIndex] = bytes[byteIndex] & bitMask;
    }
    // next
    bitIndex++;
    if (bitIndex == 8) {
      bitIndex = 0;
      byteIndex--;
    }
  }
}

class CidrGenerator {
  final String _base;
  late final _prefix = _base.split('/').first;
  late final _prefixBytes = _prefix.split('.').map(int.parse).toList();
  late final prefixBitsValue = _base.split('/').last;
  late final _prefixBits = int.parse(prefixBitsValue);

  late int _availableValues = 1 << ((_prefixBytes.length * 8) - _prefixBits);

  late final _beginBytes = () {
    final bytes = [..._prefixBytes];
    _setLastBits(bytes, _prefixBits, false);
    return bytes;
  }();

  late final _endBytes = () {
    final bytes = [..._prefixBytes];
    _setLastBits(bytes, _prefixBits, true);
    return bytes;
  }();

  CidrGenerator(this._base);

  void _incBegin() {
    final bytes = _beginBytes;
    _availableValues--;
    if (_availableValues <= 0) {
      throw AssertionError('No more available space.');
    }
    for (var i = bytes.length - 1; i >= 0; i--) {
      if (bytes[i] == 255) {
        bytes[i] = 0;
        continue;
      }
      bytes[i] = bytes[i] + 1;
      break;
    }
  }

  void _decEnd() {
    final bytes = _endBytes;
    _availableValues--;
    if (_availableValues <= 0) {
      throw AssertionError('No more available space.');
    }
    for (var i = bytes.length - 1; i >= 0; i--) {
      if (bytes[i] == 0) {
        bytes[i] = 255;
        continue;
      }
      bytes[i] = bytes[i] - 1;
      break;
    }
  }

  String nextFromBeginning() {
    _incBegin();
    return '${_beginBytes.join('.')}/$_prefixBits';
  }

  String nextFromEnd() {
    _decEnd();
    return '${_endBytes.join('.')}/$_prefixBits';
  }

  @override
  String toString() => 'CidrGenerator(available = $_availableValues)';
}
