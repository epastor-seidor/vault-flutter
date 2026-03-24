import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:dev_vault/theme/app_theme.dart';
import 'package:dev_vault/screens/dashboard_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Hive
  await Hive.initFlutter();
  
  await Hive.openBox('notes');
  await Hive.openBox('vault');

  runApp(
    ProviderScope(
      child: const DevVaultApp(),
    ),
  );
}

class DevVaultApp extends StatelessWidget {
  const DevVaultApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'DevVault',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.light, // Notion look is iconic in light mode
      home: const DashboardScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
