import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

class SettingsState {
  final ThemeMode themeMode;
  final Color accentColor;
  final bool isEncrypted;
  final bool hasMasterPassword;
  final String? masterPassword;

  SettingsState({
    required this.themeMode,
    required this.accentColor,
    this.isEncrypted = false,
    this.hasMasterPassword = false,
    this.masterPassword,
  });

  SettingsState copyWith({
    ThemeMode? themeMode,
    Color? accentColor,
    bool? isEncrypted,
    bool? hasMasterPassword,
    String? masterPassword,
  }) {
    return SettingsState(
      themeMode: themeMode ?? this.themeMode,
      accentColor: accentColor ?? this.accentColor,
      isEncrypted: isEncrypted ?? this.isEncrypted,
      hasMasterPassword: hasMasterPassword ?? this.hasMasterPassword,
      masterPassword: masterPassword ?? this.masterPassword,
    );
  }
}

class SettingsNotifier extends Notifier<SettingsState> {
  late final _box = Hive.box('settings');

  @override
  SettingsState build() {
    final themeIndex = _box.get('themeMode', defaultValue: 0) as int;
    final colorValue = _box.get('accentColor', defaultValue: Colors.blue.value) as int;
    final isEncrypted = _box.get('isEncrypted', defaultValue: false) as bool;
    final hasPassword = _box.get('hasMasterPassword', defaultValue: false) as bool;
    final masterPass = _box.get('masterPassword') as String?;

    return SettingsState(
      themeMode: ThemeMode.values[themeIndex],
      accentColor: Color(colorValue),
      isEncrypted: isEncrypted,
      hasMasterPassword: hasPassword,
      masterPassword: masterPass,
    );
  }

  void setThemeMode(ThemeMode mode) {
    _box.put('themeMode', mode.index);
    state = state.copyWith(themeMode: mode);
  }

  void setAccentColor(Color color) {
    _box.put('accentColor', color.value);
    state = state.copyWith(accentColor: color);
  }

  void setMasterPassword(String pass) {
    _box.put('masterPassword', pass);
    _box.put('hasMasterPassword', true);
    state = state.copyWith(masterPassword: pass, hasMasterPassword: true);
  }

  void disableMasterPassword() {
    _box.put('hasMasterPassword', false);
    state = state.copyWith(hasMasterPassword: false);
  }
}

final settingsProvider = NotifierProvider<SettingsNotifier, SettingsState>(() {
  return SettingsNotifier();
});
