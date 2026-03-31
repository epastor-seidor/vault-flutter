class PasswordAuditor {
  static const _commonPatterns = [
    '123456',
    'password',
    'qwerty',
    'abc123',
    '111111',
    '12345678',
    'admin',
    'letmein',
    'welcome',
    'monkey',
    'dragon',
    'master',
    'login',
    'princess',
    'football',
    'shadow',
    'sunshine',
    'trustno1',
    'iloveyou',
    'batman',
  ];

  static int scorePassword(String password) {
    if (password.isEmpty) return 0;

    int score = 0;

    // Length (max 25pts)
    if (password.length >= 16)
      score += 25;
    else if (password.length >= 12)
      score += 20;
    else if (password.length >= 10)
      score += 15;
    else if (password.length >= 8)
      score += 10;
    else
      score += 5;

    // Uppercase (15pts)
    if (password.contains(RegExp(r'[A-Z]'))) score += 15;

    // Lowercase (15pts)
    if (password.contains(RegExp(r'[a-z]'))) score += 15;

    // Digits (15pts)
    if (password.contains(RegExp(r'[0-9]'))) score += 15;

    // Symbols (15pts)
    if (password.contains(RegExp(r'[^a-zA-Z0-9]'))) score += 15;

    // Penalty for common patterns (up to -20pts)
    final lower = password.toLowerCase();
    for (final pattern in _commonPatterns) {
      if (lower.contains(pattern)) {
        score -= 20;
        break;
      }
    }

    // Penalty for repeated characters
    if (RegExp(r'(.)\1{2,}').hasMatch(password)) {
      score -= 10;
    }

    return score.clamp(0, 100);
  }

  static String strengthLabel(int score) {
    if (score >= 80) return 'Excelente';
    if (score >= 60) return 'Fuerte';
    if (score >= 40) return 'Regular';
    return 'Débil';
  }

  static List<String> findWeakPasswords(List<dynamic> items) {
    return items
        .where((item) {
          final pw = item.password ?? '';
          return pw.isNotEmpty && pw.length < 8;
        })
        .map((item) => item.title as String)
        .toList();
  }

  static List<List<String>> findDuplicatePasswords(List<dynamic> items) {
    final passwordMap = <String, List<String>>{};
    for (final item in items) {
      final pw = item.password ?? '';
      if (pw.isNotEmpty) {
        passwordMap.putIfAbsent(pw, () => []).add(item.title as String);
      }
    }
    return passwordMap.values.where((titles) => titles.length > 1).toList();
  }

  static int calculateOverallSecurityScore(List<dynamic> items) {
    if (items.isEmpty) return 100;
    final scores = items
        .where((item) => (item.password ?? '').isNotEmpty)
        .map((item) => scorePassword(item.password ?? ''))
        .toList();
    if (scores.isEmpty) return 100;
    return (scores.reduce((a, b) => a + b) / scores.length).round();
  }
}
