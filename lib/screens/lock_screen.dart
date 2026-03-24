import 'dart:ui';
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
  bool _initialized = false; // Declaración de la variable que faltaba

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
      setState(() {
        _initialized = true;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final isLocked = ref.watch(lockProvider);
    
    // Si no está bloqueado, pero aún no inicializamos los checks iniciales, mostramos carga
    if (!isLocked) {
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
                    child: CircularProgressIndicator(color: Color(0xFF00DC82), strokeWidth: 3),
                  ),
                  const SizedBox(height: 32),
                  const Text('DEV VAULT', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w900, letterSpacing: 8)),
                ],
              ),
            ),
          ),
        );
      }
      return widget.child;
    }

    return Scaffold(
      backgroundColor: AppTheme.darkBg,
      body: Stack(
        children: [
          Positioned(
            top: -150,
            left: -150,
            child: Container(
              width: 500,
              height: 500,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppTheme.accentPrimary.withOpacity(0.05), // Cambiado withValues por withOpacity
              ),
            ),
          ),
          Center(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(32),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                child: Container(
                  width: 440,
                  padding: const EdgeInsets.all(48),
                  decoration: BoxDecoration(
                    color: AppTheme.darkSurface.withOpacity(0.4), // Cambiado withValues por withOpacity
                    borderRadius: BorderRadius.circular(32),
                    border: Border.all(color: Colors.white10),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [AppTheme.accentPrimary, AppTheme.accentSecondary],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(color: AppTheme.accentPrimary.withOpacity(0.35), blurRadius: 40, offset: const Offset(0, 10)),
                          ],
                        ),
                        child: const Icon(LucideIcons.shieldCheck, size: 48, color: Colors.white),
                      ),
                      const SizedBox(height: 32),
                      const Text('DEV VAULT', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 5, color: Colors.white54)),
                      const SizedBox(height: 8),
                      const Text('Bóveda Protegida', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white, letterSpacing: -0.5)),
                      const SizedBox(height: 48),
                      TextField(
                        controller: _passwordController,
                        obscureText: true,
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                        decoration: InputDecoration(
                          hintText: 'CONTRASEÑA MAESTRA',
                          hintStyle: const TextStyle(fontSize: 10, letterSpacing: 2, color: Colors.white24),
                          filled: true,
                          fillColor: Colors.black45,
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: BorderSide.none),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                        ),
                        onSubmitted: (_) => _unlock(),
                      ),
                      const SizedBox(height: 32),
                      SizedBox(
                        width: double.infinity,
                        height: 64,
                        child: ElevatedButton(
                          onPressed: _unlock,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.accentPrimary,
                            foregroundColor: Colors.black,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                            elevation: 0,
                          ),
                          child: const Text('ACCEDER AL WORKSPACE', style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1)),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
