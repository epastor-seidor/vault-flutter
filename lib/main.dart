import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:dev_vault/theme/app_theme.dart';
import 'package:dev_vault/screens/dashboard_screen.dart';
import 'package:dev_vault/services/security_service.dart';
import 'package:dev_vault/providers/settings_provider.dart';
import 'package:dev_vault/screens/lock_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Hive
  await Hive.initFlutter();
  
  // Open Boxes
  await Hive.openBox('settings');
  await Hive.openBox('notes'); // Notes can be plain for now
  
  // Vault box is encrypted for security
  await SecurityService.openEncryptedBox('vault');

  runApp(
    const ProviderScope(
      child: DevVaultApp(),
    ),
  );
}

class DevVaultApp extends ConsumerWidget {
  const DevVaultApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);

    return MaterialApp(
      title: 'DevVault',
      theme: AppTheme.lightTheme.copyWith(
        primaryColor: settings.accentColor, // Apply customization
      ),
      darkTheme: AppTheme.darkTheme.copyWith(
        primaryColor: settings.accentColor,
      ),
      themeMode: settings.themeMode, // User choice
      home: const LockScreen(child: DashboardScreen()),
      debugShowCheckedModeBanner: false,
    );
  }
}
