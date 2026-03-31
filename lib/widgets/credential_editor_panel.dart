import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:dev_vault/models/vault_item.dart';
import 'package:dev_vault/providers/vault_provider.dart';
import 'package:dev_vault/theme/app_theme.dart';
import 'package:url_launcher/url_launcher.dart';

class CredentialEditorPanel extends ConsumerStatefulWidget {
  final VaultItem item;
  final VoidCallback onClose;

  const CredentialEditorPanel({
    super.key,
    required this.item,
    required this.onClose,
  });

  @override
  ConsumerState<CredentialEditorPanel> createState() =>
      _CredentialEditorPanelState();
}

class _CredentialEditorPanelState extends ConsumerState<CredentialEditorPanel> {
  late TextEditingController _titleC;
  late TextEditingController _userC;
  late TextEditingController _passC;
  late TextEditingController _urlC;
  late TextEditingController _notesC;
  bool _showPassword = false;
  bool _hasChanges = false;

  @override
  void initState() {
    super.initState();
    _titleC = TextEditingController(text: widget.item.title);
    _userC = TextEditingController(text: widget.item.username ?? '');
    _passC = TextEditingController(text: widget.item.password ?? '');
    _urlC = TextEditingController(text: widget.item.url ?? '');
    _notesC = TextEditingController(text: widget.item.notes ?? '');
    _titleC.addListener(() => setState(() => _hasChanges = true));
    _userC.addListener(() => setState(() => _hasChanges = true));
    _passC.addListener(() => setState(() => _hasChanges = true));
    _urlC.addListener(() => setState(() => _hasChanges = true));
    _notesC.addListener(() => setState(() => _hasChanges = true));
  }

  @override
  void dispose() {
    _titleC.dispose();
    _userC.dispose();
    _passC.dispose();
    _urlC.dispose();
    _notesC.dispose();
    super.dispose();
  }

  void _save() {
    final updated = widget.item.copyWith(
      title: _titleC.text,
      username: _userC.text,
      password: _passC.text,
      url: _urlC.text,
      notes: _notesC.text,
      updatedAt: DateTime.now(),
    );
    ref.read(vaultProvider.notifier).updateItem(updated);
    widget.onClose();
  }

  void _delete() {
    ref.read(vaultProvider.notifier).deleteItem(widget.item.id);
    widget.onClose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surface = isDark ? AppTheme.darkSurface : const Color(0xFFFFFFFF);
    final surfaceContainer = isDark
        ? AppTheme.darkSurfaceLow
        : AppTheme.stSurfaceContainer;
    final surfaceContainerLow = isDark
        ? const Color(0xFF1C1C1E)
        : AppTheme.stSurfaceLow;
    final primary = isDark ? AppTheme.darkPrimary : AppTheme.stPrimary;
    final onPrimary = isDark ? AppTheme.darkOnPrimary : AppTheme.stOnPrimary;
    final onSurface = isDark ? AppTheme.darkOnSurface : AppTheme.stOnSurface;
    final onSurfaceVariant = isDark
        ? AppTheme.darkOnSurfaceVariant
        : AppTheme.stOnSurfaceVariant;
    final outlineVariant = isDark
        ? AppTheme.darkOutlineVariant
        : AppTheme.stOutlineVariant;
    final error = const Color(0xFF9f403d);

    return Container(
      width: 480,
      decoration: BoxDecoration(
        color: surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.15),
            blurRadius: 40,
            offset: const Offset(-8, 0),
          ),
        ],
      ),
      child: Column(
        children: [
          // ── Panel Header ──
          Container(
            padding: const EdgeInsets.fromLTRB(32, 32, 32, 24),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'VAULT / EDITOR',
                        style: GoogleFonts.inter(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 2.0,
                          color: outlineVariant,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Editar Credencial',
                        style: GoogleFonts.inter(
                          fontSize: 28,
                          fontWeight: FontWeight.w800,
                          color: onSurface,
                          letterSpacing: -0.02,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                    color: surfaceContainer,
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    icon: Icon(LucideIcons.x, size: 18, color: onSurface),
                    onPressed: widget.onClose,
                  ),
                ),
              ],
            ),
          ),

          // ── Editor Form ──
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Brand Identity section
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: surfaceContainer,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: outlineVariant.withValues(alpha: 0.10),
                          ),
                        ),
                        child: Center(
                          child: Text(
                            widget.item.title.isEmpty
                                ? '?'
                                : widget.item.title[0].toUpperCase(),
                            style: GoogleFonts.inter(
                              fontSize: 32,
                              fontWeight: FontWeight.w700,
                              color: primary,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'SITIO / SERVICIO',
                              style: GoogleFonts.inter(
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 1.5,
                                color: onSurfaceVariant,
                              ),
                            ),
                            const SizedBox(height: 4),
                            TextField(
                              controller: _titleC,
                              style: GoogleFonts.inter(
                                fontSize: 22,
                                fontWeight: FontWeight.w700,
                                color: onSurface,
                                letterSpacing: -0.02,
                              ),
                              decoration: InputDecoration(
                                hintText: 'Nombre del servicio',
                                hintStyle: GoogleFonts.inter(
                                  fontSize: 22,
                                  fontWeight: FontWeight.w700,
                                  color: outlineVariant,
                                ),
                                border: InputBorder.none,
                                enabledBorder: InputBorder.none,
                                focusedBorder: InputBorder.none,
                                isDense: true,
                                contentPadding: EdgeInsets.zero,
                              ),
                            ),
                            Container(
                              height: 1,
                              color: outlineVariant.withValues(alpha: 0.20),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 40),

                  // Core Data section
                  _EditorField(
                    label: 'USUARIO',
                    icon: LucideIcons.user,
                    controller: _userC,
                    onSurfaceVariant: onSurfaceVariant,
                    outlineVariant: outlineVariant,
                    primary: primary,
                    onSurface: onSurface,
                    isMono: false,
                  ),

                  const SizedBox(height: 28),

                  // Password field
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'CONTRASEÑA',
                            style: GoogleFonts.inter(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 1.5,
                              color: onSurfaceVariant,
                            ),
                          ),
                          TextButton(
                            onPressed: () {},
                            style: TextButton.styleFrom(
                              foregroundColor: primary,
                              padding: EdgeInsets.zero,
                              minimumSize: Size.zero,
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(LucideIcons.refreshCw, size: 12),
                                const SizedBox(width: 4),
                                Text(
                                  'GENERAR SEGURA',
                                  style: GoogleFonts.inter(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Container(
                        decoration: BoxDecoration(
                          color: surfaceContainerLow,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(left: 12),
                              child: Icon(
                                LucideIcons.lock,
                                size: 18,
                                color: outlineVariant,
                              ),
                            ),
                            Expanded(
                              child: TextField(
                                controller: _passC,
                                obscureText: !_showPassword,
                                style: GoogleFonts.inter(
                                  fontSize: 14,
                                  color: onSurface,
                                  letterSpacing: !_showPassword ? 2 : 0,
                                  fontWeight: FontWeight.w500,
                                ),
                                decoration: InputDecoration(
                                  border: InputBorder.none,
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 14,
                                  ),
                                  isDense: true,
                                ),
                              ),
                            ),
                            IconButton(
                              icon: Icon(
                                _showPassword
                                    ? LucideIcons.eyeOff
                                    : LucideIcons.eye,
                                size: 18,
                                color: outlineVariant,
                              ),
                              onPressed: () => setState(
                                () => _showPassword = !_showPassword,
                              ),
                            ),
                            IconButton(
                              icon: Icon(
                                LucideIcons.copy,
                                size: 18,
                                color: outlineVariant,
                              ),
                              onPressed: () {
                                if (_passC.text.isNotEmpty) {
                                  Clipboard.setData(
                                    ClipboardData(text: _passC.text),
                                  );
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        'Contraseña copiada',
                                        style: GoogleFonts.inter(fontSize: 12),
                                      ),
                                      behavior: SnackBarBehavior.floating,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      duration: const Duration(seconds: 1),
                                    ),
                                  );
                                }
                              },
                            ),
                          ],
                        ),
                      ),
                      // Strength bar
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: Row(
                              children: [
                                _StrengthBar(filled: true, color: primary),
                                const SizedBox(width: 4),
                                _StrengthBar(filled: true, color: primary),
                                const SizedBox(width: 4),
                                _StrengthBar(filled: true, color: primary),
                                const SizedBox(width: 4),
                                _StrengthBar(
                                  filled: false,
                                  color: outlineVariant,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Seguridad fuerte',
                            style: GoogleFonts.inter(
                              fontSize: 10,
                              fontStyle: FontStyle.italic,
                              color: onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),

                  const SizedBox(height: 28),

                  // URL field
                  _EditorField(
                    label: 'URL DEL SITIO',
                    icon: LucideIcons.link,
                    controller: _urlC,
                    onSurfaceVariant: onSurfaceVariant,
                    outlineVariant: outlineVariant,
                    primary: primary,
                    onSurface: onSurface,
                    isMono: false,
                    suffixIcon: IconButton(
                      icon: Icon(
                        LucideIcons.externalLink,
                        size: 18,
                        color: outlineVariant,
                      ),
                      onPressed: () async {
                        if (_urlC.text.isNotEmpty) {
                          final uri = Uri.tryParse(_urlC.text);
                          if (uri != null && await canLaunchUrl(uri)) {
                            await launchUrl(uri);
                          }
                        }
                      },
                    ),
                  ),

                  const SizedBox(height: 28),

                  // Additional Notes
                  Text(
                    'NOTAS ADICIONALES',
                    style: GoogleFonts.inter(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.5,
                      color: onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    decoration: BoxDecoration(
                      color: surfaceContainerLow,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: outlineVariant.withValues(alpha: 0.10),
                      ),
                    ),
                    padding: const EdgeInsets.all(16),
                    child: TextField(
                      controller: _notesC,
                      maxLines: 4,
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        color: onSurface,
                        height: 1.6,
                      ),
                      decoration: InputDecoration(
                        hintText:
                            'Escribe detalles importantes como tokens de acceso...',
                        hintStyle: GoogleFonts.inter(
                          fontSize: 13,
                          color: outlineVariant,
                          height: 1.6,
                        ),
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        isDense: true,
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                  ),

                  // Metadata
                  const SizedBox(height: 24),
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      border: Border(
                        top: BorderSide(
                          color: outlineVariant.withValues(alpha: 0.10),
                        ),
                      ),
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'ÚLTIMA MODIFICACIÓN',
                              style: GoogleFonts.inter(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 1.0,
                                color: onSurfaceVariant,
                              ),
                            ),
                            Text(
                              'Hace 12 horas',
                              style: GoogleFonts.inter(
                                fontSize: 11,
                                color: onSurface,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'CREADO EL',
                              style: GoogleFonts.inter(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 1.0,
                                color: onSurfaceVariant,
                              ),
                            ),
                            Text(
                              '15 Oct, 2023',
                              style: GoogleFonts.inter(
                                fontSize: 11,
                                color: onSurface,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),

          // ── Sticky Footer ──
          Container(
            padding: const EdgeInsets.fromLTRB(32, 16, 32, 24),
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(color: outlineVariant.withValues(alpha: 0.10)),
              ),
            ),
            child: Row(
              children: [
                TextButton.icon(
                  onPressed: _delete,
                  icon: Icon(LucideIcons.trash2, size: 16, color: error),
                  label: Text(
                    'Eliminar',
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: error,
                    ),
                  ),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                  ),
                ),
                const Spacer(),
                TextButton(
                  onPressed: widget.onClose,
                  child: Text(
                    'Cancelar',
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: onSurfaceVariant,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _hasChanges ? _save : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primary,
                    foregroundColor: onPrimary,
                    elevation: 0,
                    shadowColor: primary.withValues(alpha: 0.20),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                  ),
                  child: Text(
                    'Guardar Cambios',
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _EditorField extends StatelessWidget {
  final String label;
  final IconData icon;
  final TextEditingController controller;
  final Color onSurfaceVariant;
  final Color outlineVariant;
  final Color primary;
  final Color onSurface;
  final bool isMono;
  final Widget? suffixIcon;

  const _EditorField({
    required this.label,
    required this.icon,
    required this.controller,
    required this.onSurfaceVariant,
    required this.outlineVariant,
    required this.primary,
    required this.onSurface,
    this.isMono = false,
    this.suffixIcon,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 10,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.5,
            color: onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(8)),
          child: Row(
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 12),
                child: Icon(icon, size: 18, color: outlineVariant),
              ),
              Expanded(
                child: TextField(
                  controller: controller,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: onSurface,
                    fontWeight: FontWeight.w500,
                  ),
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 14,
                    ),
                    isDense: true,
                  ),
                ),
              ),
              if (suffixIcon != null) suffixIcon!,
            ],
          ),
        ),
        Container(height: 1, color: outlineVariant.withValues(alpha: 0.20)),
      ],
    );
  }
}

class _StrengthBar extends StatelessWidget {
  final bool filled;
  final Color color;

  const _StrengthBar({required this.filled, required this.color});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        height: 4,
        decoration: BoxDecoration(
          color: filled ? color : color.withValues(alpha: 0.30),
          borderRadius: BorderRadius.circular(2),
        ),
      ),
    );
  }
}
