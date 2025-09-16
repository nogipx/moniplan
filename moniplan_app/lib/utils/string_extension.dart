extension StringExt on String {
  String capitalize() {
    return '${this[0].toUpperCase()}${substring(1).toLowerCase()}';
  }

  int get fastHash => stringFastHash(this);
}

/// FNV-1a 64bit hash algorithm optimized for Dart Strings
int stringFastHash(String input) {
  // Use JS-representable literal to avoid precision issues when compiling to JS.
  var hash = 0xcbf29ce484222000;

  var i = 0;
  while (i < input.length) {
    final codeUnit = input.codeUnitAt(i++);
    hash ^= codeUnit >> 8;
    hash *= 0x100000001b3;
    hash ^= codeUnit & 0xFF;
    hash *= 0x100000001b3;
  }

  return hash;
}
