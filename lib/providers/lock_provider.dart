import 'package:flutter_riverpod/flutter_riverpod.dart';

class LockNotifier extends Notifier<bool> {
  @override
  bool build() {
    return true; // Default to locked
  }

  void lock() => state = true;
  void unlock() => state = false;
}

final lockProvider = NotifierProvider<LockNotifier, bool>(() {
  return LockNotifier();
});
