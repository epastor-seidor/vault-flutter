import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
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
  bool _initialized = false;
  bool _obscurePassword = true;

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
        SnackBar(
          content: Text(
            'Contraseña incorrecta',
            style: GoogleFonts.inter(fontSize: 13),
          ),
          backgroundColor: AppTheme.errorLight,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(3)),
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
      setState(() => _initialized = true);
    });
  }

  @override
  void dispose() {
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isLocked = ref.watch(lockProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (!isLocked) {
      if (!_initialized) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          home: Scaffold(
            backgroundColor: isDark ? AppTheme.darkBg : AppTheme.stBg,
            body: const Center(
              child: CircularProgressIndicator(
                color: AppTheme.stPrimary,
                strokeWidth: 1.5,
              ),
            ),
          ),
        );
      }
      return widget.child;
    }

    final bgColor = isDark ? AppTheme.darkBg : AppTheme.stBg;
    final surfaceColor = isDark ? AppTheme.darkSurface : AppTheme.stSurface;
    final surfaceLowColor = isDark
        ? AppTheme.darkSurfaceLow
        : AppTheme.stSurfaceLow;
    final onSurfaceColor = isDark
        ? AppTheme.darkOnSurface
        : AppTheme.stOnSurface;
    final onSurfaceVariantColor = isDark
        ? AppTheme.darkOnSurfaceVariant
        : AppTheme.stOnSurfaceVariant;
    final outlineVariantColor = isDark
        ? AppTheme.darkOutlineVariant
        : AppTheme.stOutlineVariant;

    return Scaffold(
      backgroundColor: bgColor,
      body: Center(
        child: SizedBox(
          width: 380,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Icon - Notion style (simple, no shadows, no glow)
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: surfaceLowColor,
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: outlineVariantColor, width: 1),
                ),
                child: Icon(
                  LucideIcons.shield,
                  size: 24,
                  color: onSurfaceVariantColor,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'DevVault',
                style: GoogleFonts.inter(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: onSurfaceColor,
                  letterSpacing: -0.01,
                ),
              ),
              const SizedBox(height: 6),
              SizedBox(
                width: 260,
                child: Text(
                  'Ingresa tu contraseña maestra para desbloquear.',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: onSurfaceVariantColor,
                    height: 1.5,
                  ),
                ),
              ),
              const SizedBox(height: 40),

              // Form Card - Notion style (flat, thin border, NO shadow)
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: surfaceColor,
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: outlineVariantColor, width: 1),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'CONTRASEÑA MAESTRA',
                      style: GoogleFonts.inter(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 1.0,
                        color: onSurfaceVariantColor,
                      ),
                    ),
                    const SizedBox(height: 8),

                    // Input
                    Container(
                      decoration: BoxDecoration(
                        color: surfaceLowColor,
                        borderRadius: BorderRadius.circular(3),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _passwordController,
                              obscureText: _obscurePassword,
                              onSubmitted: (_) => _unlock(),
                              style: GoogleFonts.inter(
                                fontSize: 14,
                                color: onSurfaceColor,
                                letterSpacing: _obscurePassword ? 2 : 0,
                              ),
                              decoration: InputDecoration(
                                border: InputBorder.none,
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 12,
                                ),
                                hintText: '••••••••••••',
                                hintStyle: GoogleFonts.inter(
                                  fontSize: 14,
                                  color: onSurfaceVariantColor,
                                  letterSpacing: 2,
                                ),
                                isDense: true,
                              ),
                            ),
                          ),
                          IconButton(
                            icon: Icon(
                              _obscurePassword
                                  ? LucideIcons.eye
                                  : LucideIcons.eyeOff,
                              size: 18,
                              color: onSurfaceVariantColor,
                            ),
                            onPressed: () => setState(
                              () => _obscurePassword = !_obscurePassword,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Button - Notion style (3px radius, dark fill, NOT pill)
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _unlock,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isDark
                              ? AppTheme.darkPrimary
                              : AppTheme.stPrimaryDim,
                          foregroundColor: isDark
                              ? AppTheme.darkOnPrimary
                              : AppTheme.stOnPrimary,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(3),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 10),
                        ),
                        child: Text(
                          'Desbloquear',
                          style: GoogleFonts.inter(
                            fontWeight: FontWeight.w500,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),

                    Center(
                      child: TextButton(
                        onPressed: () {},
                        style: TextButton.styleFrom(
                          foregroundColor: onSurfaceVariantColor,
                          padding: EdgeInsets.zero,
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        child: Text(
                          'Olvidé mi contraseña',
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Security badge - subtle
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    LucideIcons.shieldCheck,
                    size: 12,
                    color: onSurfaceVariantColor,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'END-TO-END ENCRYPTED',
                    style: GoogleFonts.inter(
                      fontSize: 9,
                      fontWeight: FontWeight.w500,
                      letterSpacing: 1.5,
                      color: onSurfaceVariantColor,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
