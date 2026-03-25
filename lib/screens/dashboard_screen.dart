import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:dev_vault/providers/vault_provider.dart';
import 'package:dev_vault/providers/note_provider.dart';
import 'package:dev_vault/providers/settings_provider.dart';
import 'package:dev_vault/theme/app_theme.dart';
import 'package:dev_vault/models/vault_item.dart';
import 'package:dev_vault/models/note.dart';
import 'package:dev_vault/providers/lock_provider.dart';
import 'package:dev_vault/providers/security_log_provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:pasteboard/pasteboard.dart';
import 'package:path_provider/path_provider.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  int _selectedIndex = 0;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final TextEditingController _globalSearchController = TextEditingController();
  final FocusNode _globalSearchFocusNode = FocusNode();
  String _globalSearchQuery = '';

  @override
  void initState() {
    super.initState();
    HardwareKeyboard.instance.addHandler(_handleGlobalKeyEvent);
  }

  @override
  void dispose() {
    HardwareKeyboard.instance.removeHandler(_handleGlobalKeyEvent);
    _globalSearchController.dispose();
    _globalSearchFocusNode.dispose();
    super.dispose();
  }

  bool _handleGlobalKeyEvent(KeyEvent event) {
    if (event is! KeyDownEvent) return false;
    if (!HardwareKeyboard.instance.isControlPressed) return false;

    final key = event.logicalKey;
    if (key == LogicalKeyboardKey.keyF) {
      _globalSearchFocusNode.requestFocus();
      _globalSearchController.selection = TextSelection(
        baseOffset: 0,
        extentOffset: _globalSearchController.text.length,
      );
      return true;
    }

    if (key == LogicalKeyboardKey.keyL) {
      ref.read(lockProvider.notifier).lock();
      return true;
    }

    if (key == LogicalKeyboardKey.keyN) {
      _handleCreateShortcut();
      return true;
    }

    return false;
  }

  @override
  Widget build(BuildContext context) {
    return Focus(
      autofocus: true,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isDark = Theme.of(context).brightness == Brightness.dark;
          final isCompact = constraints.maxWidth < 1080;

          return Scaffold(
            key: _scaffoldKey,
            backgroundColor: isDark ? AppTheme.darkBg : AppTheme.stBg,
            drawer:
                isCompact ? Drawer(child: _buildSidebarContent(isDrawer: true)) : null,
            endDrawer: _buildSecurityDrawer(),
            body: Column(
              children: [
                _buildTopAppBar(isCompact: isCompact),
                Expanded(
                  child: Row(
                    children: [
                      if (!isCompact)
                        Container(
                          width: 240,
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.surface,
                            border: Border(
                              right: BorderSide(
                                  color: Theme.of(context).dividerColor, width: 1),
                            ),
                          ),
                          child: _buildSidebarContent(),
                        ),
                      Expanded(
                        child: Container(
                          color: Theme.of(context).scaffoldBackgroundColor,
                          child: _buildContent(
                            isCompact: isCompact,
                            globalQuery: _globalSearchQuery,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _handleCreateShortcut() {
    if (_selectedIndex == 2) {
      NotesView.showAddNoteDialog(context, ref);
      return;
    }
    if (_selectedIndex == 1) {
      VaultView.showAddDialog(context, ref);
      return;
    }
    setState(() => _selectedIndex = 1);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      VaultView.showAddDialog(context, ref);
    });
  }

  Widget _buildTopAppBar({required bool isCompact}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    // Stitch: glassy top bar with ghost border, bg/80 + blur
    final bg = isDark ? const Color(0xFF141414) : const Color(0xFFF9F9F7);
    final crumb = _selectedIndex == 2 ? 'Notes' : 'Credentials';

    return Container(
      height: 56,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      decoration: BoxDecoration(
        color: bg.withValues(alpha: isDark ? 0.92 : 0.88),
        border: Border(
          bottom: BorderSide(
            color: const Color(0xFFADB3B0).withValues(alpha: 0.15),
          ),
        ),
      ),
      child: Row(
        children: [
          if (isCompact)
            IconButton(
              icon: Icon(LucideIcons.menu, size: 18,
                  color: isDark ? Colors.white54 : AppTheme.stOnSurfaceVariant),
              onPressed: () => _scaffoldKey.currentState?.openDrawer(),
            ),
          // Breadcrumb
          Text('Vault',
              style: TextStyle(
                  fontSize: 13,
                  color: isDark
                      ? Colors.white38
                      : AppTheme.stOnSurfaceVariant)),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Icon(LucideIcons.chevronRight,
                size: 13,
                color: isDark
                    ? Colors.white24
                    : AppTheme.stOutlineVariant),
          ),
          Text(crumb,
              style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.white : AppTheme.stOnSurface)),
          const Spacer(),
          // Filter tabs
          _TopTab(label: 'All Items', isSelected: true),
          const SizedBox(width: 4),
          _TopTab(label: 'Favorites', isSelected: false),
          const SizedBox(width: 4),
          _TopTab(label: 'Recent', isSelected: false),
          Container(
            width: 1,
            height: 16,
            margin: const EdgeInsets.symmetric(horizontal: 14),
            color: const Color(0xFFADB3B0).withValues(alpha: 0.20),
          ),
          // Search
          SizedBox(
            width: isCompact ? 150 : 220,
            height: 34,
            child: TextField(
              controller: _globalSearchController,
              focusNode: _globalSearchFocusNode,
              onChanged: (v) => setState(() => _globalSearchQuery = v),
              style: TextStyle(
                  fontSize: 13,
                  color: isDark ? Colors.white : AppTheme.stOnSurface),
              decoration: InputDecoration(
                hintText: 'Search Vault...',
                hintStyle: TextStyle(
                    fontSize: 13,
                    color: isDark
                        ? Colors.white38
                        : AppTheme.stOnSurfaceVariant),
                prefixIcon: Icon(LucideIcons.search,
                    size: 14,
                    color: isDark
                        ? Colors.white38
                        : AppTheme.stOnSurfaceVariant),
                filled: true,
                fillColor: isDark
                    ? const Color(0xFF242426)
                    : AppTheme.stSurfaceLow,
                contentPadding: const EdgeInsets.symmetric(vertical: 8),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(6),
                    borderSide: BorderSide.none),
                enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(6),
                    borderSide: BorderSide.none),
                focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(6),
                    borderSide: BorderSide(
                        color: AppTheme.stPrimary.withValues(alpha: 0.5))),
              ),
            ),
          ),
          const SizedBox(width: 6),
          IconButton(
            icon: Icon(LucideIcons.refreshCw,
                size: 15,
                color:
                    isDark ? Colors.white54 : AppTheme.stOnSurfaceVariant),
            tooltip: 'Sincronizar',
            onPressed: () {},
          ),
          const SizedBox(width: 4),
          // New Item — Stitch style: primary bg, small rounded
          ElevatedButton(
            onPressed: _handleCreateShortcut,
            style: ElevatedButton.styleFrom(
              backgroundColor:
                  isDark ? const Color(0xFFE5E2E1) : AppTheme.stPrimary,
              foregroundColor:
                  isDark ? AppTheme.stOnSurface : const Color(0xFFFAF7F6),
              elevation: 0,
              shadowColor: Colors.transparent,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6)),
              padding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              minimumSize: const Size(0, 34),
            ),
            child: const Text('New Item',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }

  Widget _buildSidebarContent({bool isDrawer = false}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    // Stitch: sidebar = surface-container-low (#f2f4f2)
    final bg = isDark ? const Color(0xFF1C1C1E) : AppTheme.stSurfaceLow;

    return Container(
      color: bg,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Branding header ─────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 16),
            child: Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: isDark
                        ? const Color(0xFF333333)
                        : AppTheme.stPrimary,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Text('V',
                      style: TextStyle(
                          color: Color(0xFFFAF7F6),
                          fontWeight: FontWeight.w800,
                          fontSize: 14)),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('The Digital Atelier',
                          style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: isDark
                                  ? Colors.white
                                  : const Color(0xFF191919))),
                      Text('SECURE WORKSPACE',
                          style: TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 1.2,
                              color: isDark
                                  ? Colors.white38
                                  : AppTheme.stOnSurfaceVariant
                                      .withValues(alpha: 0.6))),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // ── Nav items ────────────────────────────────────
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Column(
                children: [
                  _SidebarItem(
                    icon: LucideIcons.key,
                    label: 'Credentials',
                    isSelected: _selectedIndex == 1,
                    onTap: () {
                      setState(() => _selectedIndex = 1);
                      if (isDrawer) Navigator.pop(context);
                    },
                  ),
                  _SidebarItem(
                    icon: LucideIcons.fileText,
                    label: 'Notes',
                    isSelected: _selectedIndex == 2,
                    onTap: () {
                      setState(() => _selectedIndex = 2);
                      if (isDrawer) Navigator.pop(context);
                    },
                  ),
                ],
              ),
            ),
          ),

          // ── Bottom: Add New + Settings + Lock ────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _handleCreateShortcut,
                icon: const Icon(LucideIcons.plus, size: 14),
                label: const Text('Add New'),
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      isDark ? const Color(0xFF333333) : AppTheme.stPrimary,
                  foregroundColor: const Color(0xFFFAF7F6),
                  elevation: 0,
                  shadowColor: Colors.transparent,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6)),
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  textStyle: const TextStyle(
                      fontSize: 13, fontWeight: FontWeight.w500),
                ),
              ),
            ),
          ),
          Divider(
            height: 1,
            color: AppTheme.stOutlineVariant.withValues(alpha: 0.10),
          ),
          _SidebarItem(
            icon: LucideIcons.settings2,
            label: 'Settings',
            isSelected: _selectedIndex == 3,
            onTap: () {
              setState(() => _selectedIndex = 3);
              if (isDrawer) Navigator.pop(context);
            },
          ),
          _SidebarItem(
            icon: LucideIcons.lock,
            label: 'Lock',
            isSelected: false,
            onTap: () {
              ref.read(lockProvider.notifier).lock();
              if (isDrawer) Navigator.pop(context);
            },
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _buildSecurityDrawer() {
    final logs = ref.watch(securityLogProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Drawer(
      width: 400,
      backgroundColor: isDark ? AppTheme.darkBg : AppTheme.stSurface,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(32.0),
            child: Row(
              children: [
                const Icon(LucideIcons.bell, size: 24),
                const SizedBox(width: 16),
                const Text('Seguridad', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                const Spacer(),
                IconButton(icon: const Icon(LucideIcons.x), onPressed: () => Navigator.pop(context)),
              ],
            ),
          ),
          const Divider(),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              itemCount: logs.length,
              itemBuilder: (context, i) {
                final log = logs[i];
                return ListTile(
                  contentPadding: const EdgeInsets.symmetric(vertical: 8),
                  title: Text(log.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text(log.message),
                  trailing: Text(
                    DateFormat('HH:mm').format(log.timestamp),
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent({required bool isCompact, required String globalQuery}) {
    switch (_selectedIndex) {
      case 0:
        return const HomeOverview();
      case 1:
        return VaultView(globalQuery: globalQuery, isCompact: isCompact);
      case 2:
        return NotesView(globalQuery: globalQuery);
      case 3:
        return const SettingsView();
      default:
        return const HomeOverview();
    }
  }
}

class _SidebarItem extends ConsumerWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _SidebarItem({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    // Stitch: active = surface-container (#ecefec), inactive = transparent
    final selectedBg =
        isDark ? const Color(0xFF2C2C2E) : AppTheme.stSurfaceContainer;
    final selectedText =
        isDark ? Colors.white : const Color(0xFF191919);
    final unselectedText =
        isDark ? Colors.white54 : AppTheme.stOnSurfaceVariant;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 1),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(6),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
          decoration: BoxDecoration(
            color: isSelected ? selectedBg : Colors.transparent,
            borderRadius: BorderRadius.circular(6),
          ),
          child: Row(
            children: [
              Icon(icon,
                  size: 16,
                  color: isSelected ? selectedText : unselectedText),
              const SizedBox(width: 10),
              Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight:
                      isSelected ? FontWeight.w600 : FontWeight.w500,
                  color: isSelected ? selectedText : unselectedText,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TopTab extends StatelessWidget {
  final String label;
  final bool isSelected;
  const _TopTab({required this.label, required this.isSelected});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return InkWell(
      onTap: () {},
      borderRadius: BorderRadius.circular(6),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
            color: isSelected
                ? (isDark ? Colors.white : const Color(0xFF1A1A1A))
                : (isDark ? Colors.white38 : const Color(0xFFAAAAAA)),
          ),
        ),
      ),
    );
  }
}

class HomeOverview extends ConsumerWidget {
  const HomeOverview({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final vaultItems = ref.watch(vaultProvider);
    final notes = ref.watch(noteProvider);
    final accentColor = Theme.of(context).primaryColor;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      color: Colors.transparent,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(48.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Hola de nuevo,',
                      style: TextStyle(fontSize: 14, color: isDark ? Colors.white38 : Colors.grey, fontWeight: FontWeight.w600),
                    ),
                    const Text('Workspace Principal', style: TextStyle(fontSize: 32, fontWeight: FontWeight.w900, letterSpacing: -1)),
                  ],
                ),
                const Spacer(),
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () => Scaffold.of(context).openEndDrawer(),
                    borderRadius: BorderRadius.circular(6),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: isDark ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.04),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: isDark ? Colors.white10 : Colors.black.withOpacity(0.05)),
                      ),
                      child: const Icon(LucideIcons.bell, size: 16),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 48),
            // Bento Grid Layout
            GridView.count(
              crossAxisCount: 3,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 24,
              mainAxisSpacing: 24,
              childAspectRatio: 1.4,
              children: [
                _BentoCard(
                  span: 1,
                  color: accentColor,
                  title: 'Vault',
                  subtitle: '${vaultItems.length} Records',
                  icon: LucideIcons.lock,
                  onTap: () {},
                ),
                _BentoCard(
                    span: 1,
                    color: Colors.orangeAccent,
                    title: 'Notes',
                    subtitle: '${notes.length} Snippets',
                    icon: LucideIcons.pencil,
                    onTap: () {}),
                _BentoCard(
                    span: 1,
                    color: Colors.tealAccent,
                    title: 'Security',
                    subtitle: 'AES-256 Active',
                    icon: LucideIcons.shieldCheck,
                    onTap: () {}),
                _RecentListCard(
                  items: vaultItems.take(3).toList(),
                  title: 'Recent Activity',
                ),
                _TipsCard(),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _BentoCard extends StatelessWidget {
  final int span;
  final Color color;
  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;

  const _BentoCard({
    required this.span,
    required this.color,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Theme.of(context).dividerColor),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.15),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const Spacer(),
            Text(title, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16, letterSpacing: -0.5)),
            const SizedBox(height: 4),
            Text(subtitle, style: TextStyle(color: isDark ? Colors.white38 : Colors.black54, fontSize: 12, fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }
}

class _RecentListCard extends StatelessWidget {
  final List<VaultItem> items;
  final String title;
  const _RecentListCard({required this.items, required this.title});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
          const SizedBox(height: 16),
          if (items.isEmpty)
            const Text('Sin actividad reciente', style: TextStyle(color: Colors.grey, fontSize: 12))
          else
            ...items.map((i) => Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Row(
                    children: [
                      const Icon(LucideIcons.fileText, size: 12, color: Colors.grey),
                      const SizedBox(width: 8),
                      Text(i.title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
                    ],
                  ),
                )),
        ],
      ),
    );
  }
}

class _TipsCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(LucideIcons.lightbulb, color: Theme.of(context).primaryColor, size: 20),
          const SizedBox(height: 16),
          Text(
            'Tip de Seguridad', 
            style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontWeight: FontWeight.bold, fontSize: 14),
          ),
          const SizedBox(height: 4),
          Text(
            'Usa contraseñas complejas.', 
            style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7), fontSize: 12),
          ),
        ],
      ),
    );
  }
}

class VaultView extends ConsumerStatefulWidget {
  final String globalQuery;
  final bool isCompact;

  const VaultView({
    super.key,
    this.globalQuery = '',
    this.isCompact = false,
  });

  @override
  ConsumerState<VaultView> createState() => _VaultViewState();

  static void showAddDialog(BuildContext context, WidgetRef ref, {VaultItem? existingItem}) {
    final titleC = TextEditingController(text: existingItem?.title);
    final userC = TextEditingController(text: existingItem?.username);
    final passC = TextEditingController(text: existingItem?.password);
    final urlC = TextEditingController(text: existingItem?.url);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        title: Text(existingItem == null ? 'Nueva Credencial' : 'Editar Credencial'),
        content: SizedBox(
          width: 400,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: titleC, decoration: const InputDecoration(labelText: 'Sitio/Servicio')),
              TextField(controller: userC, decoration: const InputDecoration(labelText: 'Usuario')),
              TextField(controller: passC, obscureText: true, decoration: const InputDecoration(labelText: 'Contraseña')),
              TextField(controller: urlC, decoration: const InputDecoration(labelText: 'URL')),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
          ElevatedButton(onPressed: () {
            final item = VaultItem(
              id: existingItem?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
              title: titleC.text,
              username: userC.text,
              password: passC.text,
              url: urlC.text,
              updatedAt: DateTime.now(),
            );
            if (existingItem == null) {
              ref.read(vaultProvider.notifier).addItem(item);
            } else {
              ref.read(vaultProvider.notifier).updateItem(item);
            }
            Navigator.pop(context);
          }, child: const Text('Guardar')),
        ],
      ),
    );
  }
}

class _VaultViewState extends ConsumerState<VaultView> {
  @override
  Widget build(BuildContext context) {
    // Use Stitch surface tokens
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? AppTheme.darkBg : AppTheme.stBg;
    final cardBg = isDark ? AppTheme.darkSurface : AppTheme.stSurface;
    final borderColor = isDark
        ? AppTheme.darkOutlineVariant.withValues(alpha: 0.3)
        : AppTheme.stOutlineVariant.withValues(alpha: 0.12);
    final textPrimary = isDark ? AppTheme.darkOnSurface : AppTheme.stOnSurface;
    final textSecondary =
        isDark ? AppTheme.darkOnSurfaceVariant : AppTheme.stOnSurfaceVariant;

    final rawItems = ref.watch(vaultProvider);
    final q = widget.globalQuery.trim().toLowerCase();

    final filtered = q.isEmpty
        ? rawItems
        : rawItems.where((i) {
            final titleMatch = i.title.toLowerCase().contains(q);
            final userMatch = (i.username?.toLowerCase().contains(q) ?? false);
            return titleMatch || userMatch;
          }).toList();

    final items = [...filtered]
      ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));

    return Container(
      color: bg,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Credentials', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w700, color: textPrimary, letterSpacing: -0.5)),
            const SizedBox(height: 6),
            Text(
              'Manage your secure access keys and digital identities with encrypted precision. All data is locally stored and end-to-end protected.',
              style: TextStyle(fontSize: 13, color: textSecondary, height: 1.5),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                _StatCard(label: 'TOTAL KEYS', value: '${items.length}', cardBg: cardBg, borderColor: borderColor, textPrimary: textPrimary, textSecondary: textSecondary),
                const SizedBox(width: 16),
                _StatCard(label: 'SECURITY SCORE', value: '98%', badge: 'EXCELLENT', badgeColor: const Color(0xFF22C55E), cardBg: cardBg, borderColor: borderColor, textPrimary: textPrimary, textSecondary: textSecondary),
                const SizedBox(width: 16),
                _StatCard(label: 'LAST SYNC', value: '2m ago', cardBg: cardBg, borderColor: borderColor, textPrimary: textPrimary, textSecondary: textSecondary),
              ],
            ),
            const SizedBox(height: 24),
            Container(
              decoration: BoxDecoration(color: cardBg, borderRadius: BorderRadius.circular(12), border: Border.all(color: borderColor)),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    decoration: BoxDecoration(border: Border(bottom: BorderSide(color: borderColor))),
                    child: Row(
                      children: [
                        SizedBox(width: 220, child: Text('SITIO / SERVICIO', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, letterSpacing: 1.0, color: textSecondary))),
                        SizedBox(width: 180, child: Text('USUARIO', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, letterSpacing: 1.0, color: textSecondary))),
                        SizedBox(width: 150, child: Text('CONTRASEÑA', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, letterSpacing: 1.0, color: textSecondary))),
                        Expanded(child: Text('URL', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, letterSpacing: 1.0, color: textSecondary))),
                        SizedBox(width: 80, child: Text('ACCIONES', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, letterSpacing: 1.0, color: textSecondary))),
                      ],
                    ),
                  ),
                  if (items.isEmpty)
                    Padding(
                      padding: const EdgeInsets.all(48),
                      child: Center(child: Text(q.isEmpty ? 'No hay credenciales guardadas' : 'No se encontraron resultados', style: TextStyle(color: textSecondary))),
                    )
                  else
                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: items.length,
                      separatorBuilder: (_, __) => Divider(height: 1, color: borderColor),
                      itemBuilder: (ctx, i) => _VaultCard(key: ValueKey(items[i].id), item: items[i], compact: widget.isCompact),
                    ),
                  if (items.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      decoration: BoxDecoration(border: Border(top: BorderSide(color: borderColor))),
                      child: Row(
                        children: [
                          Text('Showing ${items.length} of ${items.length} entries', style: TextStyle(fontSize: 12, color: textSecondary)),
                          const Spacer(),
                          OutlinedButton(
                            onPressed: null,
                            style: OutlinedButton.styleFrom(side: BorderSide(color: borderColor), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)), padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6), minimumSize: Size.zero, tapTargetSize: MaterialTapTargetSize.shrinkWrap),
                            child: Text('Previous', style: TextStyle(fontSize: 12, color: textSecondary)),
                          ),
                          const SizedBox(width: 8),
                          OutlinedButton(
                            onPressed: null,
                            style: OutlinedButton.styleFrom(side: BorderSide(color: borderColor), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)), padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6), minimumSize: Size.zero, tapTargetSize: MaterialTapTargetSize.shrinkWrap),
                            child: Text('Next', style: TextStyle(fontSize: 12, color: textSecondary)),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            // ── Pro Tip banner ── matches Stitch dashed border
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: (isDark
                      ? AppTheme.darkOutlineVariant
                      : AppTheme.stOutlineVariant)
                      .withValues(alpha: 0.20),
                  strokeAlign: BorderSide.strokeAlignInside,
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(LucideIcons.info,
                      size: 16, color: AppTheme.stPrimary),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Pro Tip: Keyboard Navigation',
                            style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: textPrimary)),
                        const SizedBox(height: 4),
                        Text(
                            'Press Ctrl+F to search, Ctrl+N for a new entry, Ctrl+L to lock.',
                            style: TextStyle(
                                fontSize: 12, color: textSecondary)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final String? badge;
  final Color? badgeColor;
  final Color cardBg;
  final Color borderColor;
  final Color textPrimary;
  final Color textSecondary;

  const _StatCard({
    required this.label,
    required this.value,
    this.badge,
    this.badgeColor,
    required this.cardBg,
    required this.borderColor,
    required this.textPrimary,
    required this.textSecondary,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: borderColor),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, letterSpacing: 1.0, color: textSecondary)),
            const SizedBox(height: 8),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(value, style: TextStyle(fontSize: 28, fontWeight: FontWeight.w700, color: textPrimary, letterSpacing: -1)),
                if (badge != null) ...[
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: (badgeColor ?? Colors.green).withOpacity(0.12),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(badge!, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: badgeColor ?? Colors.green)),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}


class _VaultCard extends ConsumerStatefulWidget {
  final VaultItem item;
  final bool compact;
  const _VaultCard({super.key, required this.item, this.compact = false});
  @override
  ConsumerState<_VaultCard> createState() => _VaultCardState();
}

class _VaultCardState extends ConsumerState<_VaultCard> {
  bool _showPassword = false;

  @override
  Widget build(BuildContext context) {
    final item = widget.item;
    final username = item.username?.isNotEmpty == true ? item.username! : 'Sin usuario';
    final password = item.password?.isNotEmpty == true ? item.password! : '-';

    if (widget.compact) {
      return Padding(
        padding: const EdgeInsets.all(12),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Theme.of(context).dividerColor),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(item.title, style: const TextStyle(fontWeight: FontWeight.w700), overflow: TextOverflow.ellipsis),
                  ),
                  IconButton(
                    icon: const Icon(LucideIcons.edit2, size: 16),
                    onPressed: () => VaultView.showAddDialog(context, ref, existingItem: item),
                  ),
                  IconButton(
                    icon: const Icon(LucideIcons.trash2, size: 16, color: Colors.redAccent),
                    onPressed: () => ref.read(vaultProvider.notifier).deleteItem(item.id),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              SelectableText(username, style: Theme.of(context).textTheme.bodyMedium),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: Text(_showPassword ? password : '••••••••••', style: const TextStyle(fontFamily: 'Courier')),
                  ),
                  IconButton(
                    icon: Icon(_showPassword ? LucideIcons.eyeOff : LucideIcons.eye, size: 16),
                    onPressed: password == '-' ? null : () => setState(() => _showPassword = !_showPassword),
                  ),
                  IconButton(
                    icon: const Icon(LucideIcons.copy, size: 16),
                    onPressed: password == '-'
                        ? null
                        : () {
                            Clipboard.setData(ClipboardData(text: password));
                            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Contraseña copiada')));
                          },
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          SizedBox(
            width: 270,
            child: Row(
              children: [
                Container(
                  width: 30,
                  height: 30,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor.withOpacity(0.12),
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    item.title.isEmpty ? '?' : item.title[0].toUpperCase(),
                    style: TextStyle(
                      color: Theme.of(context).primaryColor,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    item.title,
                    style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            width: 230,
            child: SelectableText(
              username,
              maxLines: 1,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
          Expanded(
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    _showPassword ? password : '••••••••••',
                    style: const TextStyle(fontFamily: 'Courier', fontWeight: FontWeight.w600, fontSize: 13),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                IconButton(
                  icon: Icon(_showPassword ? LucideIcons.eyeOff : LucideIcons.eye, size: 16),
                  onPressed: password == '-' ? null : () => setState(() => _showPassword = !_showPassword),
                  tooltip: _showPassword ? 'Ocultar' : 'Mostrar',
                ),
                IconButton(
                  icon: const Icon(LucideIcons.copy, size: 16),
                  onPressed: password == '-'
                      ? null
                      : () {
                          Clipboard.setData(ClipboardData(text: password));
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Contraseña copiada')),
                          );
                        },
                ),
              ],
            ),
          ),
          SizedBox(
            width: 110,
            child: Text(
              DateFormat('dd/MM').format(item.updatedAt),
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
          SizedBox(
            width: 120,
            child: Row(
              children: [
                if (item.url != null && item.url!.isNotEmpty)
                  IconButton(
                    icon: const Icon(LucideIcons.externalLink, size: 16),
                    onPressed: () async {
                      final uri = Uri.tryParse(item.url!);
                      if (uri != null) {
                        await launchUrl(uri);
                      }
                    },
                    tooltip: 'Abrir',
                  ),
                IconButton(
                  icon: const Icon(LucideIcons.edit2, size: 16),
                  onPressed: () => VaultView.showAddDialog(context, ref, existingItem: item),
                  tooltip: 'Editar',
                ),
                IconButton(
                  icon: const Icon(LucideIcons.trash2, size: 16, color: Colors.redAccent),
                  onPressed: () => ref.read(vaultProvider.notifier).deleteItem(item.id),
                  tooltip: 'Eliminar',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class NotesView extends ConsumerStatefulWidget {
  final String globalQuery;
  const NotesView({super.key, this.globalQuery = ''});

  @override
  ConsumerState<NotesView> createState() => _NotesViewState();

  static void showAddNoteDialog(BuildContext context, WidgetRef ref, {Note? existingNote}) {
    final noteId =
        existingNote?.id ?? DateTime.now().millisecondsSinceEpoch.toString();
    final titleC = TextEditingController(text: existingNote?.title);
    final contentC = TextEditingController(text: existingNote?.content);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        title: Text(existingNote == null ? 'Nueva Nota' : 'Editar Nota'),
        content: SizedBox(
          width: 500,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: titleC, decoration: const InputDecoration(labelText: 'Título')),
              const SizedBox(height: 16),
              CallbackShortcuts(
                bindings: <ShortcutActivator, VoidCallback>{
                  const SingleActivator(LogicalKeyboardKey.keyV, control: true): () {
                    unawaited(_tryPasteImageIntoNote(
                      context: context,
                      contentController: contentC,
                      noteId: noteId,
                    ));
                  },
                },
                child: TextField(
                  controller: contentC,
                  maxLines: 6,
                  decoration: const InputDecoration(
                    labelText: 'Contenido',
                    hintText:
                        'Tip: también puedes pegar imágenes con Ctrl+V',
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Align(
                alignment: Alignment.centerRight,
                child: OutlinedButton.icon(
                  onPressed: () => unawaited(_tryPasteImageIntoNote(
                    context: context,
                    contentController: contentC,
                    noteId: noteId,
                  )),
                  icon: const Icon(LucideIcons.image, size: 14),
                  label: const Text('Pegar imagen'),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
          ElevatedButton(onPressed: () {
            if (existingNote == null) {
              ref.read(noteProvider.notifier).addNote(Note(
                id: noteId,
                title: titleC.text,
                content: contentC.text,
                createdAt: DateTime.now(),
                updatedAt: DateTime.now(),
              ));
            } else {
              ref.read(noteProvider.notifier).updateNote(existingNote.copyWith(
                title: titleC.text, content: contentC.text, updatedAt: DateTime.now(),
              ));
            }
            Navigator.pop(context);
          }, child: const Text('Guardar')),
        ],
      ),
    );
  }

  static void showNoteDetailsDialog(BuildContext context, WidgetRef ref, {required Note note}) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        insetPadding: const EdgeInsets.all(24),
        title: Row(
          children: [
            const Icon(LucideIcons.fileText, size: 18),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                note.title,
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
            ),
            IconButton(
              icon: const Icon(LucideIcons.x),
              onPressed: () => Navigator.pop(context),
              tooltip: 'Cerrar',
            ),
          ],
        ),
        content: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 900),
          child: SingleChildScrollView(
            child: MarkdownBody(
              data: note.content,
              sizedImageBuilder: _markdownSizedImageBuilder,
              styleSheet: MarkdownStyleSheet(
                p: TextStyle(
                  fontSize: 13,
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.85),
                  height: 1.6,
                ),
              ),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => NotesView.showAddNoteDialog(context, ref, existingNote: note),
            child: const Text('Editar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Listo'),
          ),
        ],
      ),
    );
  }
}

class _NotesViewState extends ConsumerState<NotesView> {
  Note? _selectedNote;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? AppTheme.darkBg : AppTheme.stBg;
    final listBg = isDark ? AppTheme.darkSurface : AppTheme.stSurfaceLow;
    final contentBg = isDark ? AppTheme.darkBg : AppTheme.stSurface;
    final textPrimary = isDark ? AppTheme.darkOnSurface : AppTheme.stOnSurface;
    final textSecondary =
        isDark ? AppTheme.darkOnSurfaceVariant : AppTheme.stOnSurfaceVariant;
    final divider = (isDark
        ? AppTheme.darkOutlineVariant
        : AppTheme.stOutlineVariant)
        .withValues(alpha: 0.10);

    final rawNotes = ref.watch(noteProvider);
    final q = widget.globalQuery.trim().toLowerCase();
    final filtered = q.isEmpty
        ? rawNotes
        : rawNotes.where((n) {
            return n.title.toLowerCase().contains(q) ||
                n.content.toLowerCase().contains(q);
          }).toList();
    final notes = [...filtered]
      ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));

    // Select first note if none selected
    if (_selectedNote == null && notes.isNotEmpty) {
      _selectedNote = notes.first;
    } else if (notes.isNotEmpty &&
        _selectedNote != null &&
        !notes.any((n) => n.id == _selectedNote!.id)) {
      _selectedNote = notes.first;
    }
    if (notes.isEmpty) _selectedNote = null;

    return Container(
      color: bg,
      child: Row(
        children: [
          // ── Notes List Panel (left) ───────────────────────────
          Container(
            width: 300,
            color: listBg,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Panel header
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                  child: Row(
                    children: [
                      Text(
                        'RECENT NOTES',
                        style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1.5,
                            color: textSecondary),
                      ),
                      const Spacer(),
                      GestureDetector(
                        onTap: () => NotesView.showAddNoteDialog(context, ref),
                        child: Icon(LucideIcons.plus,
                            size: 16, color: textSecondary),
                      ),
                    ],
                  ),
                ),
                Divider(height: 1, color: divider),
                // Note list
                Expanded(
                  child: notes.isEmpty
                      ? Center(
                          child: Text(
                            q.isEmpty ? 'No hay notas' : 'Sin resultados',
                            style: TextStyle(
                                fontSize: 13, color: textSecondary),
                          ),
                        )
                      : ListView.separated(
                          padding: const EdgeInsets.all(8),
                          itemCount: notes.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: 2),
                          itemBuilder: (ctx, i) {
                            final note = notes[i];
                            final isActive =
                                _selectedNote?.id == note.id;
                            return GestureDetector(
                              onTap: () =>
                                  setState(() => _selectedNote = note),
                              child: Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: isActive
                                      ? (isDark
                                          ? AppTheme.darkSurfaceLow
                                          : AppTheme.stSurface)
                                      : Colors.transparent,
                                  borderRadius: BorderRadius.circular(8),
                                  boxShadow: isActive
                                      ? [
                                          BoxShadow(
                                            color: const Color(0xFF2D3432)
                                                .withValues(alpha: 0.05),
                                            blurRadius: 8,
                                            offset: const Offset(0, 2),
                                          )
                                        ]
                                      : null,
                                ),
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Icon(
                                          LucideIcons.fileText,
                                          size: 13,
                                          color: isActive
                                              ? AppTheme.stPrimary
                                              : textSecondary,
                                        ),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: Text(
                                            note.title,
                                            style: TextStyle(
                                              fontSize: 13,
                                              fontWeight: isActive
                                                  ? FontWeight.w600
                                                  : FontWeight.w500,
                                              color: textPrimary,
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      _makeNotePreview(note.content),
                                      style: TextStyle(
                                          fontSize: 11,
                                          color: textSecondary,
                                          height: 1.4),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
          ),

          // ── Content Canvas (right) ───────────────────────────
          Expanded(
            child: Container(
              color: contentBg,
              child: _selectedNote == null
                  ? Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(LucideIcons.fileText,
                              size: 32,
                              color: textSecondary.withValues(alpha: 0.4)),
                          const SizedBox(height: 12),
                          Text('Selecciona una nota',
                              style: TextStyle(
                                  fontSize: 14, color: textSecondary)),
                        ],
                      ),
                    )
                  : _NoteContentPanel(
                      key: ValueKey(_selectedNote!.id),
                      note: _selectedNote!,
                      isDark: isDark,
                      textPrimary: textPrimary,
                      textSecondary: textSecondary,
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

// Two-panel note content viewer (right panel of NotesView)
class _NoteContentPanel extends ConsumerWidget {
  final Note note;
  final bool isDark;
  final Color textPrimary;
  final Color textSecondary;

  const _NoteContentPanel({
    super.key,
    required this.note,
    required this.isDark,
    required this.textPrimary,
    required this.textSecondary,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(48, 48, 48, 80),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Tags row
          Row(
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppTheme.stSurfaceContainer,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  'Nota',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.8,
                    color: AppTheme.stOnSurfaceVariant,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                DateFormat('d MMM yyyy').format(note.updatedAt),
                style: TextStyle(
                    fontSize: 11,
                    color: AppTheme.stOnSurfaceVariant),
              ),
            ],
          ),
          const SizedBox(height: 20),
          // Title
          Text(
            note.title,
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.w800,
              color: textPrimary,
              letterSpacing: -0.5,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 24),
          Divider(
            color: AppTheme.stOutlineVariant.withValues(alpha: 0.10),
            height: 1,
          ),
          const SizedBox(height: 24),
          // Content via Markdown
          MarkdownBody(
            data: note.content.isEmpty
                ? '*Sin contenido. Edita la nota para añadir contenido.*'
                : note.content,
            sizedImageBuilder: _markdownSizedImageBuilder,
            styleSheet: MarkdownStyleSheet(
              p: TextStyle(
                  fontSize: 15,
                  color: textPrimary.withValues(alpha: 0.88),
                  height: 1.7),
              h1: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: textPrimary,
                  letterSpacing: -0.3),
              h2: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: textPrimary),
              code: TextStyle(
                fontFamily: 'Courier',
                fontSize: 13,
                color: AppTheme.stPrimary,
                backgroundColor:
                    AppTheme.stSurfaceContainer,
              ),
              codeblockDecoration: BoxDecoration(
                color: isDark
                    ? AppTheme.darkSurfaceLow
                    : AppTheme.stSurfaceContainer,
                borderRadius: BorderRadius.circular(8),
              ),
              blockquoteDecoration: BoxDecoration(
                border: Border(
                  left: BorderSide(
                    color: AppTheme.stPrimary.withValues(alpha: 0.4),
                    width: 3,
                  ),
                ),
                color: AppTheme.stSurfaceLow,
              ),
            ),
          ),
          const SizedBox(height: 40),
          // Action row
          Row(
            children: [
              OutlinedButton.icon(
                onPressed: () =>
                    NotesView.showAddNoteDialog(context, ref,
                        existingNote: note),
                icon: const Icon(LucideIcons.edit2, size: 13),
                label: const Text('Editar'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppTheme.stOnSurface,
                  side: BorderSide(
                    color: AppTheme.stOutlineVariant.withValues(alpha: 0.3),
                  ),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6)),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 10),
                  textStyle: const TextStyle(fontSize: 12),
                ),
              ),
              const SizedBox(width: 8),
              OutlinedButton.icon(
                onPressed: () =>
                    ref.read(noteProvider.notifier).deleteNote(note.id),
                icon: const Icon(LucideIcons.trash2,
                    size: 13, color: Color(0xFF9f403d)),
                label: const Text('Eliminar'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFF9f403d),
                  side: BorderSide(
                    color:
                        const Color(0xFF9f403d).withValues(alpha: 0.2),
                  ),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6)),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 10),
                  textStyle: const TextStyle(fontSize: 12),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}


class SettingsView extends ConsumerWidget {
  const SettingsView({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    return SingleChildScrollView(
      padding: const EdgeInsets.all(48),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Ajustes', style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
          const SizedBox(height: 48),
          _SettingBox(
            title: 'Modo de Tema',
            icon: LucideIcons.moon,
            trailing: DropdownButton<ThemeMode>(
              value: settings.themeMode,
              items: const [
                DropdownMenuItem(value: ThemeMode.light, child: Text('Claro')),
                DropdownMenuItem(value: ThemeMode.dark, child: Text('Oscuro')),
              ],
              onChanged: (v) => ref.read(settingsProvider.notifier).setThemeMode(v!),
            ),
          ),
          const SizedBox(height: 24),
          _SettingBox(
            title: 'Contraseña Maestra',
            icon: LucideIcons.lock,
            trailing: Switch(
              value: settings.hasMasterPassword,
              onChanged: (v) {
                if (v) {
                  _showPasswordSetDialog(context, ref);
                } else {
                  ref.read(settingsProvider.notifier).disableMasterPassword();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Seguridad desactivada')),
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}

void _showPasswordSetDialog(BuildContext context, WidgetRef ref) {
  final c = TextEditingController();
  showDialog(
    context: context, 
    builder: (context) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
      title: const Text('Configurar Contraseña'),
      content: TextField(
        controller: c,
        obscureText: true,
        decoration: const InputDecoration(hintText: 'Nueva contraseña'),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
        ElevatedButton(onPressed: () {
          ref.read(settingsProvider.notifier).setMasterPassword(c.text);
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Contraseña configurada')));
        }, child: const Text('Guardar')),
      ],
    ),
  );
}

class _SettingBox extends StatelessWidget {
  final String title;
  final IconData icon;
  final Widget trailing;
  const _SettingBox({required this.title, required this.icon, required this.trailing});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: isDark ? Colors.white.withOpacity(0.06) : Colors.black.withOpacity(0.08)),
      ),
      child: Row(
        children: [
          Icon(icon, size: 20),
          const SizedBox(width: 16),
          Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
          const Spacer(),
          trailing,
        ],
      ),
    );
  }
}

String _makeNotePreview(String content) {
  final cleaned = content
      .replaceAll(RegExp(r'\s+'), ' ')
      .replaceAll(RegExp(r'[*_`#>-]'), '')
      .trim();
  if (cleaned.isEmpty) return 'Sin contenido';
  const maxChars = 220;
  if (cleaned.length <= maxChars) return cleaned;
  return '${cleaned.substring(0, maxChars)}...';
}

Future<void> _tryPasteImageIntoNote({
  required BuildContext context,
  required TextEditingController contentController,
  required String noteId,
}) async {
  try {
    final bytes = await Pasteboard.image;
    if (bytes == null || bytes.isEmpty) return;

    final docs = await getApplicationDocumentsDirectory();
    final imagesDir = Directory(
      '${docs.path}${Platform.pathSeparator}note_images'
      '${Platform.pathSeparator}$noteId',
    );
    await imagesDir.create(recursive: true);

    final file = File(
      '${imagesDir.path}${Platform.pathSeparator}'
      '${DateTime.now().millisecondsSinceEpoch}.png',
    );
    await file.writeAsBytes(bytes, flush: true);

    final markdown = '\n![](${Uri.file(file.path).toString()})\n';
    _insertTextAtSelection(contentController, markdown);
  } catch (_) {
    // If clipboard doesn't contain an image or platform blocks access, do nothing.
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No se pudo pegar la imagen')),
      );
    }
  }
}

void _insertTextAtSelection(TextEditingController controller, String text) {
  final value = controller.value;
  final selection = value.selection;
  final fullText = value.text;

  final start = selection.isValid ? selection.start : fullText.length;
  final end = selection.isValid ? selection.end : fullText.length;
  final safeStart = start.clamp(0, fullText.length);
  final safeEnd = end.clamp(0, fullText.length);

  final newText =
      fullText.replaceRange(safeStart, safeEnd, text);
  controller.value = value.copyWith(
    text: newText,
    selection: TextSelection.collapsed(offset: safeStart + text.length),
    composing: TextRange.empty,
  );
}

Widget _markdownSizedImageBuilder(MarkdownImageConfig config) {
  final uri = config.uri;
  final width = config.width;
  final height = config.height;

  if (kIsWeb) {
    return Image.network(uri.toString(), width: width, height: height);
  }

  if (uri.scheme == 'file') {
    return Image.file(
      File.fromUri(uri),
      width: width,
      height: height,
    );
  }

  return Image.network(uri.toString(), width: width, height: height);
}
