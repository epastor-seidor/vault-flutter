import 'package:flutter_riverpod/flutter_riverpod.dart';

class SecurityLog {
  final String title;
  final String message;
  final DateTime timestamp;

  SecurityLog({required this.title, required this.message, required this.timestamp});
}

class SecurityLogNotifier extends Notifier<List<SecurityLog>> {
  @override
  List<SecurityLog> build() {
    return [
      SecurityLog(
        title: 'Inicio de aplicación',
        message: 'Sesión iniciada correctamente.',
        timestamp: DateTime.now(),
      ),
    ];
  }

  void addLog(String title, String message) {
    state = [
      SecurityLog(title: title, message: message, timestamp: DateTime.now()),
      ...state,
    ];
  }
}

final securityLogProvider = NotifierProvider<SecurityLogNotifier, List<SecurityLog>>(() {
  return SecurityLogNotifier();
});
