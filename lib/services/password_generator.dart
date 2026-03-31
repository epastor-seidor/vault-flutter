import 'dart:math';

class PasswordGenerator {
  static const _uppercase = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
  static const _lowercase = 'abcdefghijklmnopqrstuvwxyz';
  static const _digits = '0123456789';
  static const _symbols = '!@#\$%^&*()_+-=[]{}|;:,.<>?';

  static String generate({
    int length = 16,
    bool includeUppercase = true,
    bool includeLowercase = true,
    bool includeDigits = true,
    bool includeSymbols = true,
  }) {
    length = length.clamp(8, 64);

    String charset = '';
    if (includeUppercase) charset += _uppercase;
    if (includeLowercase) charset += _lowercase;
    if (includeDigits) charset += _digits;
    if (includeSymbols) charset += _symbols;

    if (charset.isEmpty) {
      charset = _lowercase + _digits;
    }

    final random = Random.secure();
    final result = List.generate(
      length,
      (_) => charset[random.nextInt(charset.length)],
    );

    // Ensure at least one character from each selected type
    int pos = 0;
    if (includeUppercase && _uppercase.isNotEmpty) {
      result[pos++] = _uppercase[random.nextInt(_uppercase.length)];
    }
    if (includeLowercase && _lowercase.isNotEmpty) {
      result[pos++] = _lowercase[random.nextInt(_lowercase.length)];
    }
    if (includeDigits && _digits.isNotEmpty) {
      result[pos++] = _digits[random.nextInt(_digits.length)];
    }
    if (includeSymbols && _symbols.isNotEmpty) {
      result[pos++] = _symbols[random.nextInt(_symbols.length)];
    }

    // Shuffle to randomize positions of guaranteed characters
    for (var i = result.length - 1; i > 0; i--) {
      final j = random.nextInt(i + 1);
      final temp = result[i];
      result[i] = result[j];
      result[j] = temp;
    }

    return result.join();
  }
}
