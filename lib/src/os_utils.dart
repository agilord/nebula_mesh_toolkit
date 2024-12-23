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
