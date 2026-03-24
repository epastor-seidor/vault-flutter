import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:dev_vault/providers/settings_provider.dart';
import 'package:dev_vault/providers/lock_provider.dart';
import 'package:dev_vault/theme/app_theme.dart';

class LockScreen extends ConsumerStatefulWidget {
  final Widget child;
  const LockScreen({super.key, required this.child});

  @override
  ConsumerState<LockScreen> createState() => _LockScreenState();
}

class _LockScreenState extends ConsumerState<LockScreen> {
  final _passwordController = TextEditingController();

  void _unlock() {
    final settings = ref.read(settingsProvider);
    if (!settings.hasMasterPassword) {
      ref.read(lockProvider.notifier).unlock();
      return;
    }

    if (_passwordController.text == settings.masterPassword) {
       ref.read(lockProvider.notifier).unlock();
       _passwordController.clear();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Contraseña incorrecta'),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final settings = ref.read(settingsProvider);
      if (!settings.hasMasterPassword) {
        ref.read(lockProvider.notifier).unlock();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isLocked = ref.watch(lockProvider);
    if (!isLocked) return widget.child;

    return Scaffold(
      backgroundColor: AppTheme.darkBg,
      body: Stack(
        children: [
          // Same Premium UI
          Positioned(
            top: -100,
            right: -100,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Theme.of(context).primaryColor.withValues(alpha: 0.2),
              ),
            ),
          ),
          Center(
            child: Container(
              width: 420,
              padding: const EdgeInsets.all(48),
              decoration: BoxDecoration(
                color: AppTheme.darkSurface.withValues(alpha: 0.8),
                borderRadius: BorderRadius.circular(32),
                border: Border.all(color: Colors.white10),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.5),
                    blurRadius: 100,
                    offset: const Offset(0, 20),
                  )
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(colors: [Theme.of(context).primaryColor, Colors.indigoAccent]),
                      shape: BoxShape.circle,
                      boxShadow: [BoxShadow(color: Theme.of(context).primaryColor.withValues(alpha: 0.4), blurRadius: 20)],
                    ),
                    child: const Icon(LucideIcons.shieldAlert, size: 40, color: Colors.white),
                  ),
                  const SizedBox(height: 32),
                  const Text('Bóveda Protegida', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white)),
                  const SizedBox(height: 48),
                  TextField(
                    controller: _passwordController,
                    obscureText: true,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: 'Contraseña Maestra',
                      prefixIcon: const Icon(LucideIcons.lock, size: 18, color: Colors.white24),
                      filled: true,
                      fillColor: Colors.black26,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                    ),
                    onSubmitted: (_) => _unlock(),
                  ),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: ElevatedButton(
                      onPressed: _unlock,
                      child: const Text('Desbloquear Workspace', style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
