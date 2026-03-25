import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:dev_vault/providers/settings_provider.dart';
import 'package:dev_vault/providers/lock_provider.dart';

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

  // Stitch DS Tokens
  static const _bg = Color(0xFFF9F9F7);
  static const _surface = Color(0xFFFFFFFF);
  static const _surfaceLow = Color(0xFFF2F4F2);
  static const _primary = Color(0xFF5F5E5E);
  static const _onSurface = Color(0xFF2D3432);
  static const _onSurfaceVariant = Color(0xFF5A605E);
  static const _outlineVariant = Color(0xFFADB3B0);

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
          backgroundColor: const Color(0xFF9f403d),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
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

    if (!isLocked) {
      if (!_initialized) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          home: Scaffold(
            backgroundColor: _bg,
            body: const Center(
              child: CircularProgressIndicator(
                color: _primary,
                strokeWidth: 1.5,
              ),
            ),
          ),
        );
      }
      return widget.child;
    }

    return Scaffold(
      backgroundColor: _bg,
      body: Stack(
        children: [
          // Decorative blobs (Atelier feel)
          Positioned(
            top: 0,
            right: 0,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFFE5E9E6).withValues(alpha: 0.5),
              ),
            ),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            child: Container(
              width: 400,
              height: 400,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFFE5E2DD).withValues(alpha: 0.4),
              ),
            ),
          ),
          // Main content
          Center(
            child: SizedBox(
              width: 420,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // ── Branding ──────────────────────────────────
                  Column(
                    children: [
                      // Lock icon badge
                      Container(
                        width: 64,
                        height: 64,
                        decoration: BoxDecoration(
                          color: _surface,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF2D3432).withValues(alpha: 0.06),
                              blurRadius: 20,
                              offset: const Offset(0, 4),
                            ),
                          ],
                          border: Border.all(
                            color: _outlineVariant.withValues(alpha: 0.10),
                          ),
                        ),
                        child: const Icon(LucideIcons.lock, size: 28, color: _primary),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'Vault',
                        style: GoogleFonts.inter(
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                          color: _onSurface,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Ingresa tu contraseña maestra para\ndesbloquear tus credenciales y notas.',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          color: _onSurfaceVariant,
                          height: 1.6,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 40),

                  // ── Form Card ───────────────────────────────
                  Container(
                    padding: const EdgeInsets.all(32),
                    decoration: BoxDecoration(
                      color: _surface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: _outlineVariant.withValues(alpha: 0.08),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF2D3432).withValues(alpha: 0.06),
                          blurRadius: 32,
                          offset: const Offset(0, 12),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Label
                        Text(
                          'CONTRASEÑA MAESTRA',
                          style: GoogleFonts.inter(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1.4,
                            color: _onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: 10),

                        // Password Input — Stitch style: surface-container-low bg, bottom border
                        Container(
                          decoration: BoxDecoration(
                            color: _surfaceLow,
                            borderRadius: BorderRadius.circular(8),
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
                                    color: _onSurface,
                                    letterSpacing: _obscurePassword ? 3 : 0,
                                  ),
                                  decoration: InputDecoration(
                                    border: InputBorder.none,
                                    contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 16,
                                    ),
                                    hintText: '••••••••••••',
                                    hintStyle: GoogleFonts.inter(
                                      fontSize: 14,
                                      color: _outlineVariant,
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
                                  size: 17,
                                  color: _onSurfaceVariant,
                                ),
                                onPressed: () => setState(
                                    () => _obscurePassword = !_obscurePassword),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Unlock CTA — rounded-full, primary bg
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _unlock,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _primary,
                              foregroundColor: const Color(0xFFFAF7F6),
                              elevation: 0,
                              shadowColor: Colors.transparent,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(999),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 16),
                            ),
                            child: Text(
                              'Desbloquear',
                              style: GoogleFonts.inter(
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Forgot password + dots
                        Column(
                          children: [
                            Center(
                              child: TextButton(
                                onPressed: () {},
                                style: TextButton.styleFrom(
                                  foregroundColor: _onSurfaceVariant,
                                  padding: EdgeInsets.zero,
                                  minimumSize: Size.zero,
                                  tapTargetSize:
                                      MaterialTapTargetSize.shrinkWrap,
                                ),
                                child: Text(
                                  'Olvidé mi contraseña',
                                  style: GoogleFonts.inter(fontSize: 12),
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                            Center(
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  _Dot(active: true),
                                  const SizedBox(width: 6),
                                  const _Dot(),
                                  const SizedBox(width: 6),
                                  const _Dot(),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),

                  // ── Security badge ──────────────────────────
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        LucideIcons.shieldCheck,
                        size: 12,
                        color: _outlineVariant.withValues(alpha: 0.7),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'END-TO-END ENCRYPTED',
                        style: GoogleFonts.inter(
                          fontSize: 9,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.8,
                          color: _outlineVariant.withValues(alpha: 0.7),
                        ),
                      ),
                    ],
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

class _Dot extends StatelessWidget {
  final bool active;
  const _Dot({this.active = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 5,
      height: 5,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: active
            ? const Color(0xFFADB3B0).withValues(alpha: 0.6)
            : const Color(0xFFADB3B0).withValues(alpha: 0.25),
      ),
    );
  }
}
