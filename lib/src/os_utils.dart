String expandOS(String os) {
  switch (os) {
    case 'linux':
      return 'linux-amd64';
    case 'windows':
      return 'windows-amd64';
    case 'macos':
      return 'darwin';
  }
  return os;
}

String tunDeviceName(String os, String domain) {
  final id = (domain.hashCode.abs() % 16) + 16;
  if (os == 'darwin') {
    return 'utun$id';
  }
  return 'tun$id';
}
