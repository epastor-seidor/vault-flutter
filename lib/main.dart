import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:dev_vault/screens/dashboard_screen.dart';
import 'package:dev_vault/screens/lock_screen.dart';
import 'package:dev_vault/theme/app_theme.dart';
import 'package:dev_vault/services/security_service.dart';
import 'package:dev_vault/providers/settings_provider.dart';
import 'package:window_manager/window_manager.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const ProviderScope(child: Bootstrapper()));
}

class Bootstrapper extends StatefulWidget {
  const Bootstrapper({super.key});

  @override
  State<Bootstrapper> createState() => _BootstrapperState();
}

class _BootstrapperState extends State<Bootstrapper> {
  bool _initialized = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    try {
      await windowManager.ensureInitialized();
      await windowManager.setTitle('DevVault');
      await windowManager.show();
      await windowManager.focus();

      // Use app documents directory explicitly
      final appDir = await getApplicationDocumentsDirectory();
      await Hive.initFlutter(appDir.path);

      // Clean stale lock files from crashed instances
      final lockFiles = Directory(
        appDir.path,
      ).listSync().whereType<File>().where((f) => f.path.endsWith('.lock'));
      for (final lockFile in lockFiles) {
        try {
          await lockFile.delete();
        } catch (_) {
          // Ignore if file is in use by another running instance
        }
      }

      // Open boxes
      await Hive.openBox('settings');
      await SecurityService.openEncryptedBox('vault');
      await Hive.openBox('notes');
      await Hive.openBox('tasks');

      if (mounted) setState(() => _initialized = true);
    } catch (e) {
      if (mounted) setState(() => _error = e.toString());
      debugPrint('Bootstrap error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_error != null) {
      return MaterialApp(
        home: Scaffold(body: Center(child: Text('Error Crítico: $_error'))),
      );
    }
    if (!_initialized) {
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        themeMode: ThemeMode.dark,
        theme: ThemeData.dark(),
        home: Scaffold(
          backgroundColor: const Color(0xFF020408),
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(
                  width: 48,
                  height: 48,
                  child: CircularProgressIndicator(
                    color: Color(0xFF00DC82),
                    strokeWidth: 3,
                  ),
                ),
                const SizedBox(height: 32),
                const Text(
                  'DEV VAULT',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 8,
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Sincronizando seguridad...',
                  style: TextStyle(color: Colors.white38, fontSize: 13),
                ),
              ],
            ),
          ),
        ),
      );
    }
    return const MyApp();
  }
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    return MaterialApp(
      title: 'DevVault',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: settings.themeMode, // Restored dynamic theme
      home: const LockScreen(child: DashboardScreen()),
    );
  }
}
