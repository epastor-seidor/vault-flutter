import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:dev_vault/providers/vault_provider.dart';
import 'package:dev_vault/providers/note_provider.dart';
import 'package:dev_vault/providers/task_provider.dart';
import 'package:dev_vault/providers/settings_provider.dart';
import 'package:dev_vault/theme/app_theme.dart';
import 'package:dev_vault/models/vault_item.dart';
import 'package:dev_vault/models/note.dart';
import 'package:dev_vault/models/task_item.dart';
import 'package:dev_vault/providers/lock_provider.dart';
import 'package:dev_vault/providers/security_log_provider.dart';
import 'package:dev_vault/widgets/credential_editor_panel.dart';
import 'package:dev_vault/widgets/note_properties_panel.dart';
import 'package:dev_vault/widgets/note_enhanced_view.dart';
import 'package:dev_vault/widgets/toast_notification.dart';
import 'package:dev_vault/widgets/onboarding_tour.dart';
import 'package:dev_vault/services/password_auditor.dart';
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
    final isCtrl = HardwareKeyboard.instance.isControlPressed;
    final isShift = HardwareKeyboard.instance.isShiftPressed;
    final key = event.logicalKey;

    // Ctrl+F - Focus search
    if (isCtrl && key == LogicalKeyboardKey.keyF) {
      _globalSearchFocusNode.requestFocus();
      _globalSearchController.selection = TextSelection(
        baseOffset: 0,
        extentOffset: _globalSearchController.text.length,
      );
      return true;
    }

    // Ctrl+L - Lock vault
    if (isCtrl && key == LogicalKeyboardKey.keyL) {
      ref.read(lockProvider.notifier).lock();
      ref
          .read(toastProvider.notifier)
          .show('Bóveda bloqueada', type: ToastType.info);
      return true;
    }

    // Ctrl+N - New entry for current section
    if (isCtrl && !isShift && key == LogicalKeyboardKey.keyN) {
      _handleCreateShortcut();
      return true;
    }

    // Ctrl+Shift+C - New credential
    if (isCtrl && isShift && key == LogicalKeyboardKey.keyC) {
      VaultView.showAddDialog(context, ref);
      return true;
    }

    // Ctrl+Shift+N - New note
    if (isCtrl && isShift && key == LogicalKeyboardKey.keyN) {
      NotesView.showAddNoteDialog(context, ref);
      return true;
    }

    // Ctrl+Shift+T - New task
    if (isCtrl && isShift && key == LogicalKeyboardKey.keyT) {
      TasksView.showAddTaskDialog(context, ref);
      return true;
    }

    // Ctrl+Shift+F - Toggle favorites filter (on vault screen)
    if (isCtrl && isShift && key == LogicalKeyboardKey.keyF) {
      if (_selectedIndex == 1) {
        ref.read(vaultFilterProvider.notifier).toggleFavorites();
        ref
            .read(toastProvider.notifier)
            .show(
              ref.read(vaultFilterProvider).showFavoritesOnly
                  ? 'Filtro: Solo favoritos'
                  : 'Filtro: Todos',
              type: ToastType.info,
            );
      }
      return true;
    }

    // Ctrl+Shift+S - Cycle sort modes (on vault screen)
    if (isCtrl && isShift && key == LogicalKeyboardKey.keyS) {
      if (_selectedIndex == 1) {
        final sortModes = ['Fecha', 'Nombre A-Z', 'Nombre Z-A', 'Categoría'];
        final current = ref.read(vaultFilterProvider).sortMode;
        final idx = sortModes.indexOf(current);
        final next = sortModes[(idx + 1) % sortModes.length];
        ref.read(vaultFilterProvider.notifier).setSortMode(next);
        ref
            .read(toastProvider.notifier)
            .show('Ordenar: $next', type: ToastType.info);
      }
      return true;
    }

    // Ctrl+E - Export credentials
    if (isCtrl && key == LogicalKeyboardKey.keyE) {
      ref
          .read(toastProvider.notifier)
          .show('Exportación iniciada', type: ToastType.info);
      return true;
    }

    // Ctrl+1/2/3/4 - Navigate sections
    if (isCtrl && key == LogicalKeyboardKey.digit1) {
      setState(() => _selectedIndex = 1);
      return true;
    }
    if (isCtrl && key == LogicalKeyboardKey.digit2) {
      setState(() => _selectedIndex = 2);
      return true;
    }
    if (isCtrl && key == LogicalKeyboardKey.digit3) {
      setState(() => _selectedIndex = 3);
      return true;
    }
    if (isCtrl && key == LogicalKeyboardKey.digit4) {
      setState(() => _selectedIndex = 4);
      return true;
    }

    // Escape - Close search / back to home
    if (key == LogicalKeyboardKey.escape) {
      if (_globalSearchFocusNode.hasFocus) {
        _globalSearchFocusNode.unfocus();
        _globalSearchController.clear();
        setState(() => _globalSearchQuery = '');
      } else if (_selectedIndex != 0) {
        setState(() => _selectedIndex = 0);
      }
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
          final hasSeenOnboarding = ref
              .watch(settingsProvider)
              .hasSeenOnboarding;

          return ToastOverlay(
            child: Scaffold(
              key: _scaffoldKey,
              backgroundColor: isDark ? AppTheme.darkBg : AppTheme.stBg,
              drawer: isCompact
                  ? Drawer(child: _buildSidebarContent(isDrawer: true))
                  : null,
              endDrawer: _buildSecurityDrawer(),
              body: Stack(
                children: [
                  Column(
                    children: [
                      _buildTopAppBar(isCompact: isCompact),
                      Expanded(
                        child: Row(
                          children: [
                            if (!isCompact)
                              Container(
                                width: 220,
                                decoration: BoxDecoration(
                                  border: Border(
                                    right: BorderSide(
                                      color: Theme.of(context).dividerColor,
                                      width: 1,
                                    ),
                                  ),
                                ),
                                child: _buildSidebarContent(),
                              ),
                            Expanded(
                              child: Container(
                                color: Theme.of(
                                  context,
                                ).scaffoldBackgroundColor,
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
                  // Onboarding tour overlay
                  if (!hasSeenOnboarding) _buildOnboardingTour(context),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildOnboardingTour(BuildContext context) {
    final renderBox = context.findRenderObject() as RenderBox?;
    if (renderBox == null || !renderBox.hasSize) return const SizedBox.shrink();

    final size = renderBox.size;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF1E1E2E) : const Color(0xFFFFFFFF);

    return OnboardingTour(
      steps: [
        TourStep(
          title: 'Bienvenido a DevVault',
          description:
              'Tu bóveda segura para credenciales, notas y tareas. Todo almacenado localmente con encriptación.',
          targetRect: Rect.fromCenter(
            center: Offset(size.width / 2, 40),
            width: 200,
            height: 50,
          ),
          tooltipAlignment: Alignment.bottomCenter,
        ),
        TourStep(
          title: 'Navegación rápida',
          description:
              'Usa la barra lateral para moverte entre Credenciales, Notas, Tareas y Ajustes. O presiona Ctrl+1, Ctrl+2, Ctrl+3, Ctrl+4.',
          targetRect: Rect.fromLTWH(0, 60, 220, size.height - 120),
          tooltipAlignment: Alignment.centerRight,
        ),
        TourStep(
          title: 'Accesos rápidos',
          description:
              'Crea credenciales, notas o tareas directamente desde la barra superior. También puedes usar Ctrl+Shift+C, Ctrl+Shift+N, Ctrl+Shift+T.',
          targetRect: Rect.fromCenter(
            center: Offset(size.width - 200, 40),
            width: 300,
            height: 50,
          ),
          tooltipAlignment: Alignment.bottomCenter,
        ),
        TourStep(
          title: '¡Empieza a explorar!',
          description:
              'Selecciona una sección para comenzar. Usa Ctrl+F para buscar y Ctrl+L para bloquear la bóveda.',
          targetRect: Rect.fromCenter(
            center: Offset(size.width / 2, size.height / 2),
            width: 300,
            height: 200,
          ),
          tooltipAlignment: Alignment.topCenter,
        ),
      ],
      onComplete: () {
        ref.read(settingsProvider.notifier).markOnboardingSeen();
        ref
            .read(toastProvider.notifier)
            .show('¡Bienvenido a DevVault!', type: ToastType.success);
      },
      onSkip: () {
        ref.read(settingsProvider.notifier).markOnboardingSeen();
      },
    );
  }

  void _handleCreateShortcut() {
    if (_selectedIndex == 2) {
      NotesView.showAddNoteDialog(context, ref);
      return;
    }
    if (_selectedIndex == 3) {
      TasksView.showAddTaskDialog(context, ref);
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
    final crumb = switch (_selectedIndex) {
      1 => 'Credenciales',
      2 => 'Notas',
      3 => 'Tareas',
      4 => 'Ajustes',
      _ => 'Inicio',
    };

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
              icon: Icon(
                LucideIcons.menu,
                size: 18,
                color: isDark ? Colors.white54 : AppTheme.stOnSurfaceVariant,
              ),
              onPressed: () => _scaffoldKey.currentState?.openDrawer(),
            ),
          const Spacer(),
          Text(
            crumb,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.white : AppTheme.stOnSurface,
            ),
          ),
          const Spacer(),
          // Search
          SizedBox(
            width: isCompact ? 140 : 200,
            height: 32,
            child: TextField(
              controller: _globalSearchController,
              focusNode: _globalSearchFocusNode,
              onChanged: (v) => setState(() => _globalSearchQuery = v),
              style: TextStyle(
                fontSize: 13,
                color: isDark ? Colors.white : AppTheme.stOnSurface,
              ),
              decoration: InputDecoration(
                hintText: 'Search...',
                hintStyle: TextStyle(
                  fontSize: 13,
                  color: isDark ? Colors.white38 : AppTheme.stOnSurfaceVariant,
                ),
                prefixIcon: Icon(
                  LucideIcons.search,
                  size: 14,
                  color: isDark ? Colors.white38 : AppTheme.stOnSurfaceVariant,
                ),
                filled: true,
                fillColor: isDark
                    ? const Color(0xFF242426)
                    : AppTheme.stSurfaceLow,
                contentPadding: const EdgeInsets.symmetric(vertical: 6),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(6),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(6),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(6),
                  borderSide: BorderSide(
                    color: AppTheme.stPrimary.withValues(alpha: 0.5),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 6),
          // Quick action buttons
          _QuickActionBtn(
            icon: LucideIcons.key,
            label: 'Credencial',
            tooltip: 'Ctrl+Shift+C',
            onPressed: () => VaultView.showAddDialog(context, ref),
          ),
          const SizedBox(width: 4),
          _QuickActionBtn(
            icon: LucideIcons.fileText,
            label: 'Nota',
            tooltip: 'Ctrl+Shift+N',
            onPressed: () => NotesView.showAddNoteDialog(context, ref),
          ),
          const SizedBox(width: 4),
          _QuickActionBtn(
            icon: LucideIcons.checkSquare,
            label: 'Tarea',
            tooltip: 'Ctrl+Shift+T',
            onPressed: () => TasksView.showAddTaskDialog(context, ref),
          ),
          const SizedBox(width: 8),
          IconButton(
            icon: Icon(
              LucideIcons.refreshCw,
              size: 15,
              color: isDark ? Colors.white54 : AppTheme.stOnSurfaceVariant,
            ),
            tooltip: 'Sincronizar',
            onPressed: () {},
          ),
          const SizedBox(width: 4),
          // New Item — Stitch style: primary bg, small rounded
          ElevatedButton(
            onPressed: _handleCreateShortcut,
            style: ElevatedButton.styleFrom(
              backgroundColor: isDark
                  ? const Color(0xFFE5E2E1)
                  : AppTheme.stPrimary,
              foregroundColor: isDark
                  ? AppTheme.stOnSurface
                  : const Color(0xFFFAF7F6),
              elevation: 0,
              shadowColor: Colors.transparent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(6),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              minimumSize: const Size(0, 34),
            ),
            child: const Text(
              'Nuevo',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSidebarContent({bool isDrawer = false}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Branding header ─────────────────────────────
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 20, 16, 16),
          child: Row(
            children: [
              Container(
                width: 28,
                height: 28,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF333333) : AppTheme.stPrimary,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Text(
                  'V',
                  style: TextStyle(
                    color: Color(0xFFFAF7F6),
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'DevVault',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.white : const Color(0xFF191919),
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
                  label: 'Credenciales',
                  isSelected: _selectedIndex == 1,
                  onTap: () {
                    setState(() => _selectedIndex = 1);
                    if (isDrawer) Navigator.pop(context);
                  },
                ),
                _SidebarItem(
                  icon: LucideIcons.fileText,
                  label: 'Notas',
                  isSelected: _selectedIndex == 2,
                  onTap: () {
                    setState(() => _selectedIndex = 2);
                    if (isDrawer) Navigator.pop(context);
                  },
                ),
                _SidebarItem(
                  icon: LucideIcons.checkCircle2,
                  label: 'Tareas',
                  isSelected: _selectedIndex == 3,
                  onTap: () {
                    setState(() => _selectedIndex = 3);
                    if (isDrawer) Navigator.pop(context);
                  },
                ),
              ],
            ),
          ),
        ),

        // ── Bottom: Settings + Lock ────────────
        Divider(
          height: 1,
          color: AppTheme.stOutlineVariant.withValues(alpha: 0.10),
        ),
        _SidebarItem(
          icon: LucideIcons.settings2,
          label: 'Ajustes',
          isSelected: _selectedIndex == 4,
          onTap: () {
            setState(() => _selectedIndex = 4);
            if (isDrawer) Navigator.pop(context);
          },
        ),
        _SidebarItem(
          icon: LucideIcons.lock,
          label: 'Bloquear',
          isSelected: false,
          onTap: () {
            ref.read(lockProvider.notifier).lock();
            if (isDrawer) Navigator.pop(context);
          },
        ),
        const SizedBox(height: 8),
      ],
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
                const Text(
                  'Seguridad',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(LucideIcons.x),
                  onPressed: () => Navigator.pop(context),
                ),
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
                  title: Text(
                    log.title,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
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
        return TasksView(globalQuery: globalQuery);
      case 4:
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
    final selectedBg = isDark
        ? const Color(0xFF2C2C2E)
        : AppTheme.stSurfaceContainer;
    final selectedText = isDark ? Colors.white : const Color(0xFF191919);
    final unselectedText = isDark
        ? Colors.white54
        : AppTheme.stOnSurfaceVariant;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 1),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(6),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          curve: Curves.easeOut,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
          decoration: BoxDecoration(
            color: isSelected ? selectedBg : Colors.transparent,
            borderRadius: BorderRadius.circular(6),
          ),
          child: Row(
            children: [
              Icon(
                icon,
                size: 16,
                color: isSelected ? selectedText : unselectedText,
              ),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
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

class HomeOverview extends ConsumerWidget {
  const HomeOverview({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final vaultItems = ref.watch(vaultProvider);
    final notes = ref.watch(noteProvider);
    final tasks = ref.watch(taskProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPrimary = isDark ? AppTheme.darkOnSurface : AppTheme.stOnSurface;
    final textSecondary = isDark
        ? AppTheme.darkOnSurfaceVariant
        : AppTheme.stOnSurfaceVariant;
    final hoverBg = isDark ? AppTheme.darkSurfaceLow : AppTheme.stSurfaceLow;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Workspace',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w600,
              color: textPrimary,
              letterSpacing: -0.02,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Accede a tus credenciales, notas y tareas desde un solo lugar.',
            style: TextStyle(fontSize: 14, color: textSecondary, height: 1.5),
          ),
          const SizedBox(height: 32),

          // Quick access section
          _DashboardSection(
            title: 'Credenciales recientes',
            icon: LucideIcons.key,
            items: vaultItems.take(5).toList(),
            emptyMessage: 'No hay credenciales guardadas',
            emptyAction: 'Agregar credencial',
            onAction: () => VaultView.showAddDialog(context, ref),
            hoverBg: hoverBg,
            textPrimary: textPrimary,
            textSecondary: textSecondary,
          ),
          const SizedBox(height: 24),

          _DashboardSection(
            title: 'Notas recientes',
            icon: LucideIcons.fileText,
            items: notes.take(5).toList(),
            emptyMessage: 'No hay notas creadas',
            emptyAction: 'Crear nota',
            onAction: () => NotesView.showAddNoteDialog(context, ref),
            hoverBg: hoverBg,
            textPrimary: textPrimary,
            textSecondary: textSecondary,
          ),
          const SizedBox(height: 24),

          _DashboardSection(
            title: 'Tareas pendientes',
            icon: LucideIcons.checkCircle2,
            items: tasks.where((t) => !t.isCompleted).take(5).toList(),
            emptyMessage: 'No hay tareas pendientes',
            emptyAction: 'Crear tarea',
            onAction: () => TasksView.showAddTaskDialog(context, ref),
            hoverBg: hoverBg,
            textPrimary: textPrimary,
            textSecondary: textSecondary,
          ),
        ],
      ),
    );
  }
}

class _DashboardSection extends StatelessWidget {
  final String title;
  final IconData icon;
  final List<dynamic> items;
  final String emptyMessage;
  final String emptyAction;
  final VoidCallback onAction;
  final Color hoverBg;
  final Color textPrimary;
  final Color textSecondary;

  const _DashboardSection({
    required this.title,
    required this.icon,
    required this.items,
    required this.emptyMessage,
    required this.emptyAction,
    required this.onAction,
    required this.hoverBg,
    required this.textPrimary,
    required this.textSecondary,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 16, color: textSecondary),
            const SizedBox(width: 8),
            Text(
              title,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: textPrimary,
                letterSpacing: -0.02,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              '(${items.length})',
              style: TextStyle(fontSize: 12, color: textSecondary),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (items.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 24),
            decoration: BoxDecoration(
              color: hoverBg,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              children: [
                Text(
                  emptyMessage,
                  style: TextStyle(fontSize: 13, color: textSecondary),
                ),
                const SizedBox(height: 12),
                TextButton(
                  onPressed: onAction,
                  child: Text(
                    emptyAction,
                    style: const TextStyle(fontSize: 13),
                  ),
                ),
              ],
            ),
          )
        else
          ...items.map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 2),
              child: InkWell(
                borderRadius: BorderRadius.circular(6),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Row(
                    children: [
                      Icon(icon, size: 14, color: textSecondary),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          item.title ?? '',
                          style: TextStyle(fontSize: 13, color: textPrimary),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class VaultView extends ConsumerStatefulWidget {
  final String globalQuery;
  final bool isCompact;

  const VaultView({super.key, this.globalQuery = '', this.isCompact = false});

  @override
  ConsumerState<VaultView> createState() => _VaultViewState();

  static void showAddDialog(
    BuildContext context,
    WidgetRef ref, {
    VaultItem? existingItem,
  }) {
    final titleC = TextEditingController(text: existingItem?.title);
    final userC = TextEditingController(text: existingItem?.username);
    final passC = TextEditingController(text: existingItem?.password);
    final urlC = TextEditingController(text: existingItem?.url);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                LucideIcons.key,
                size: 20,
                color: Theme.of(context).primaryColor,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                existingItem == null ? 'Nueva Credencial' : 'Editar Credencial',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        content: SizedBox(
          width: 450,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleC,
                decoration: InputDecoration(
                  labelText: 'Sitio o Servicio',
                  hintText: 'Ej: Gmail, Netflix, etc.',
                  prefixIcon: const Icon(LucideIcons.globe, size: 18),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: userC,
                decoration: InputDecoration(
                  labelText: 'Usuario o Email',
                  hintText: 'Tu nombre de usuario',
                  prefixIcon: const Icon(LucideIcons.user, size: 18),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: passC,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'Contraseña',
                  hintText: 'Tu contraseña segura',
                  prefixIcon: const Icon(LucideIcons.lock, size: 18),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  suffixIcon: IconButton(
                    icon: const Icon(LucideIcons.eyeOff, size: 18),
                    onPressed: () {},
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: urlC,
                decoration: InputDecoration(
                  labelText: 'URL (opcional)',
                  hintText: 'https://ejemplo.com',
                  prefixIcon: const Icon(LucideIcons.link, size: 18),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              if (titleC.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Por favor ingresa el nombre del sitio'),
                  ),
                );
                return;
              }
              final item = VaultItem(
                id:
                    existingItem?.id ??
                    DateTime.now().millisecondsSinceEpoch.toString(),
                title: titleC.text,
                username: userC.text,
                password: passC.text,
                url: urlC.text,
                updatedAt: DateTime.now(),
                createdAt: existingItem?.createdAt ?? DateTime.now(),
              );
              if (existingItem == null) {
                ref.read(vaultProvider.notifier).addItem(item);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Credencial guardada exitosamente'),
                  ),
                );
              } else {
                ref.read(vaultProvider.notifier).updateItem(item);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Credencial actualizada exitosamente'),
                  ),
                );
              }
              Navigator.pop(context);
            },
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
  }
}

class _VaultViewState extends ConsumerState<VaultView> {
  VaultItem? _editingItem;
  bool _showGridView = false;
  bool _batchMode = false;
  final Set<String> _selectedItems = {};

  String _relativeTime(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 1) return 'Ahora';
    if (diff.inMinutes < 60) return 'Hace ${diff.inMinutes} min';
    if (diff.inHours < 24) return 'Hace ${diff.inHours}h';
    if (diff.inDays < 7) return 'Hace ${diff.inDays}d';
    return '${dt.day}/${dt.month}/${dt.year}';
  }

  IconData _getCategoryIcon(String? category) {
    switch (category?.toLowerCase()) {
      case 'login':
        return LucideIcons.logIn;
      case 'api key':
        return LucideIcons.key;
      case 'database':
        return LucideIcons.database;
      case 'email':
        return LucideIcons.mail;
      default:
        return LucideIcons.shield;
    }
  }

  int _passwordAgeDays(String? password, DateTime updatedAt) {
    if (password == null || password.isEmpty) return 0;
    return DateTime.now().difference(updatedAt).inDays;
  }

  String _getPasswordStrength(String? password) {
    if (password == null || password.isEmpty) return 'Sin contraseña';
    final len = password.length;
    final hasUpper = password.contains(RegExp(r'[A-Z]'));
    final hasLower = password.contains(RegExp(r'[a-z]'));
    final hasDigit = password.contains(RegExp(r'[0-9]'));
    final hasSpecial = password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'));
    final score = [
      hasUpper,
      hasLower,
      hasDigit,
      hasSpecial,
    ].where((b) => b).length;
    if (len < 8 || score <= 1) return 'Débil';
    if (len < 12 || score <= 2) return 'Media';
    return 'Fuerte';
  }

  List<String> _getDynamicCategories(List<VaultItem> items) {
    final categories = <String>{};
    for (final item in items) {
      if (item.category != null && item.category!.isNotEmpty) {
        categories.add(item.category!);
      }
    }
    final sorted = categories.toList()..sort();
    return sorted;
  }

  bool _matchesSearchQuery(VaultItem item, String query) {
    if (query.isEmpty) return true;

    if (query.contains(':')) {
      final parts = query.split(':');
      final field = parts[0].toLowerCase();
      final value = parts.sublist(1).join(':').toLowerCase();

      switch (field) {
        case 'user':
        case 'usuario':
          return (item.username?.toLowerCase().contains(value) ?? false);
        case 'url':
          return (item.url?.toLowerCase().contains(value) ?? false);
        case 'title':
        case 'titulo':
          return item.title.toLowerCase().contains(value);
        case 'note':
        case 'nota':
          return (item.notes?.toLowerCase().contains(value) ?? false);
        case 'cat':
        case 'category':
        case 'categoria':
          return (item.category?.toLowerCase().contains(value) ?? false);
        default:
          return _matchesAnyField(item, query);
      }
    }

    return _matchesAnyField(item, query);
  }

  bool _matchesAnyField(VaultItem item, String query) {
    final q = query.toLowerCase();
    return item.title.toLowerCase().contains(q) ||
        (item.username?.toLowerCase().contains(q) ?? false) ||
        (item.url?.toLowerCase().contains(q) ?? false) ||
        (item.notes?.toLowerCase().contains(q) ?? false) ||
        (item.category?.toLowerCase().contains(q) ?? false);
  }

  int _getActiveFilterCount() {
    return ref.read(vaultFilterProvider).activeFilterCount;
  }

  void _clearAllFilters() {
    ref.read(vaultFilterProvider.notifier).clearAll();
  }

  void _exportCredentials(List<VaultItem> items) async {
    try {
      final dir = await getApplicationDocumentsDirectory();
      final file = File(
        '${dir.path}/devvault_export_${DateTime.now().millisecondsSinceEpoch}.json',
      );
      final data = items
          .map(
            (i) => {
              'title': i.title,
              'url': i.url,
              'username': i.username,
              'password': i.password,
              'category': i.category,
              'notes': i.notes,
              'createdAt': i.createdAt.toIso8601String(),
              'updatedAt': i.updatedAt.toIso8601String(),
            },
          )
          .toList();
      await file.writeAsString(jsonEncode(data));
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Exportado: ${file.path}',
              style: GoogleFonts.inter(fontSize: 12),
            ),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al exportar: $e'),
            backgroundColor: const Color(0xFF9f403d),
          ),
        );
      }
    }
  }

  void _deleteSelected() {
    if (_selectedItems.isEmpty) return;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Eliminar ${_selectedItems.length} credenciales'),
        content: Text('¿Estás seguro? Esta acción no se puede deshacer.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              for (final id in _selectedItems) {
                ref.read(vaultProvider.notifier).deleteItem(id);
              }
              setState(() {
                _selectedItems.clear();
                _batchMode = false;
              });
              Navigator.pop(ctx);
            },
            child: const Text(
              'Eliminar',
              style: TextStyle(color: Color(0xFF9f403d)),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? AppTheme.darkBg : AppTheme.stBg;
    final cardBg = isDark ? AppTheme.darkSurface : AppTheme.stSurface;
    final borderColor = isDark
        ? AppTheme.darkOutlineVariant.withValues(alpha: 0.3)
        : AppTheme.stOutlineVariant.withValues(alpha: 0.12);
    final textPrimary = isDark ? AppTheme.darkOnSurface : AppTheme.stOnSurface;
    final textSecondary = isDark
        ? AppTheme.darkOnSurfaceVariant
        : AppTheme.stOnSurfaceVariant;

    final rawItems = ref.watch(vaultProvider);
    final filters = ref.watch(vaultFilterProvider);
    final q = widget.globalQuery.trim().toLowerCase();

    var items = rawItems.where((i) => _matchesSearchQuery(i, q)).toList();

    // Filter by category
    if (filters.selectedCategory != 'Todas') {
      items = items
          .where((i) => i.category == filters.selectedCategory)
          .toList();
    }

    // Filter favorites
    if (filters.showFavoritesOnly) {
      items = items.where((i) => i.isFavorite).toList();
    }

    // Filter by password strength
    if (filters.passwordStrengthFilter != 'Todas') {
      items = items.where((i) {
        final strength = _getPasswordStrength(i.password);
        return strength == filters.passwordStrengthFilter;
      }).toList();
    }

    // Filter by password age
    if (filters.passwordAgeFilter != 'Todas') {
      items = items.where((i) {
        final age = _passwordAgeDays(i.password, i.updatedAt);
        switch (filters.passwordAgeFilter) {
          case '<30 días':
            return age < 30;
          case '30-90 días':
            return age >= 30 && age <= 90;
          case '>90 días':
            return age > 90;
          default:
            return true;
        }
      }).toList();
    }

    // Filter duplicates only
    if (filters.showDuplicatesOnly) {
      final duplicateHashes = <String>{};
      final duplicateItems = <VaultItem>[];
      for (final item in items) {
        if (item.password != null && item.password!.isNotEmpty) {
          final hash = item.password!;
          if (duplicateHashes.contains(hash)) {
            if (!duplicateItems.any((i) => i.password == hash)) {
              duplicateItems.add(items.firstWhere((i) => i.password == hash));
            }
            duplicateItems.add(item);
          }
          duplicateHashes.add(hash);
        }
      }
      items = duplicateItems;
    }

    // Sort
    items = [...items];
    switch (filters.sortMode) {
      case 'Nombre A-Z':
        items.sort((a, b) => a.title.compareTo(b.title));
        break;
      case 'Nombre Z-A':
        items.sort((a, b) => b.title.compareTo(a.title));
        break;
      case 'Categoría':
        items.sort((a, b) => (a.category ?? '').compareTo(b.category ?? ''));
        break;
      case 'Fecha':
      default:
        items.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    }

    // Favorites first
    items.sort((a, b) {
      if (a.isFavorite && !b.isFavorite) return -1;
      if (!a.isFavorite && b.isFavorite) return 1;
      return 0;
    });

    // Audit
    final securityScore = PasswordAuditor.calculateOverallSecurityScore(items);
    final weakPasswords = PasswordAuditor.findWeakPasswords(items);
    final duplicateGroups = PasswordAuditor.findDuplicatePasswords(items);
    final dynamicCategories = _getDynamicCategories(rawItems);
    final activeFilters = filters.activeFilterCount;

    return Stack(
      children: [
        Container(
          color: bg,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Credenciales',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.w600,
                            color: textPrimary,
                            letterSpacing: -0.5,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Gestiona tus claves de acceso e identidades digitales con precisión encriptada.',
                          style: TextStyle(
                            fontSize: 13,
                            color: textSecondary,
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                    // View toggle + actions
                    Row(
                      children: [
                        // Batch mode toggle
                        if (items.isNotEmpty)
                          IconButton(
                            icon: Icon(
                              _batchMode
                                  ? LucideIcons.checkSquare
                                  : LucideIcons.square,
                              size: 16,
                              color: _batchMode ? textPrimary : textSecondary,
                            ),
                            onPressed: () => setState(() {
                              _batchMode = !_batchMode;
                              if (!_batchMode) _selectedItems.clear();
                            }),
                            tooltip: 'Selección múltiple',
                          ),
                        // Export
                        if (items.isNotEmpty)
                          IconButton(
                            icon: const Icon(LucideIcons.download, size: 16),
                            onPressed: () => _exportCredentials(items),
                            tooltip: 'Exportar JSON',
                            color: textSecondary,
                          ),
                        const SizedBox(width: 8),
                        Container(
                          decoration: BoxDecoration(
                            color: isDark
                                ? AppTheme.darkSurfaceLow
                                : AppTheme.stSurfaceLow,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              IconButton(
                                icon: Icon(
                                  LucideIcons.list,
                                  size: 16,
                                  color: !_showGridView
                                      ? textPrimary
                                      : textSecondary,
                                ),
                                onPressed: () =>
                                    setState(() => _showGridView = false),
                                tooltip: 'Lista',
                              ),
                              IconButton(
                                icon: Icon(
                                  LucideIcons.layoutGrid,
                                  size: 16,
                                  color: _showGridView
                                      ? textPrimary
                                      : textSecondary,
                                ),
                                onPressed: () =>
                                    setState(() => _showGridView = true),
                                tooltip: 'Cuadrícula',
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    _StatCard(
                      label: 'CLAVES TOTALES',
                      value: '${items.length}',
                      cardBg: cardBg,
                      borderColor: borderColor,
                      textPrimary: textPrimary,
                      textSecondary: textSecondary,
                    ),
                    const SizedBox(width: 16),
                    _StatCard(
                      label: 'PUNTAJE DE SEGURIDAD',
                      value: '$securityScore%',
                      badge: PasswordAuditor.strengthLabel(
                        securityScore,
                      ).toUpperCase(),
                      badgeColor: securityScore >= 80
                          ? const Color(0xFF22C55E)
                          : securityScore >= 60
                          ? const Color(0xFFEAB308)
                          : const Color(0xFFEF4444),
                      cardBg: cardBg,
                      borderColor: borderColor,
                      textPrimary: textPrimary,
                      textSecondary: textSecondary,
                    ),
                    const SizedBox(width: 16),
                    _StatCard(
                      label: 'ÚLTIMA SYNC',
                      value: 'Hace 2 min',
                      cardBg: cardBg,
                      borderColor: borderColor,
                      textPrimary: textPrimary,
                      textSecondary: textSecondary,
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                // ── Filters & Sorting ──
                Row(
                  children: [
                    // Category chips - dynamic
                    Expanded(
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            _FilterChip(
                              label: 'Todas',
                              selected: filters.selectedCategory == 'Todas',
                              onTap: () => ref
                                  .read(vaultFilterProvider.notifier)
                                  .setCategory('Todas'),
                            ),
                            const SizedBox(width: 6),
                            ...dynamicCategories
                                .map(
                                  (cat) => [
                                    _FilterChip(
                                      label: cat,
                                      selected: filters.selectedCategory == cat,
                                      onTap: () => ref
                                          .read(vaultFilterProvider.notifier)
                                          .setCategory(cat),
                                    ),
                                    const SizedBox(width: 6),
                                  ],
                                )
                                .expand((e) => e),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Sort dropdown
                    Container(
                      decoration: BoxDecoration(
                        color: isDark
                            ? AppTheme.darkSurfaceLow
                            : AppTheme.stSurfaceLow,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: DropdownButton<String>(
                        value: filters.sortMode,
                        underline: const SizedBox(),
                        icon: Icon(
                          LucideIcons.arrowUpDown,
                          size: 14,
                          color: textSecondary,
                        ),
                        items:
                            ['Fecha', 'Nombre A-Z', 'Nombre Z-A', 'Categoría']
                                .map(
                                  (m) => DropdownMenuItem(
                                    value: m,
                                    child: Text(
                                      m,
                                      style: GoogleFonts.inter(
                                        fontSize: 12,
                                        color: textPrimary,
                                      ),
                                    ),
                                  ),
                                )
                                .toList(),
                        onChanged: (v) => ref
                            .read(vaultFilterProvider.notifier)
                            .setSortMode(v!),
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Favorites toggle
                    Tooltip(
                      message: 'Mostrar solo favoritos (Ctrl+Shift+F)',
                      child: GestureDetector(
                        onTap: () => setState(
                          () => ref
                              .read(vaultFilterProvider.notifier)
                              .toggleFavorites(),
                        ),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: filters.showFavoritesOnly
                                ? const Color(
                                    0xFFF59E0B,
                                  ).withValues(alpha: 0.15)
                                : (isDark
                                      ? AppTheme.darkSurfaceLow
                                      : AppTheme.stSurfaceLow),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                filters.showFavoritesOnly
                                    ? LucideIcons.star
                                    : LucideIcons.starOff,
                                size: 14,
                                color: filters.showFavoritesOnly
                                    ? const Color(0xFFF59E0B)
                                    : textSecondary,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'Fav',
                                style: GoogleFonts.inter(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: filters.showFavoritesOnly
                                      ? const Color(0xFFF59E0B)
                                      : textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                // ── Advanced Filters Row ──
                Row(
                  children: [
                    // Password strength filter
                    Container(
                      decoration: BoxDecoration(
                        color: isDark
                            ? AppTheme.darkSurfaceLow
                            : AppTheme.stSurfaceLow,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: DropdownButton<String>(
                        value: filters.passwordStrengthFilter,
                        underline: const SizedBox(),
                        icon: Icon(
                          LucideIcons.shield,
                          size: 14,
                          color: textSecondary,
                        ),
                        items:
                            [
                                  'Todas',
                                  'Débil',
                                  'Media',
                                  'Fuerte',
                                  'Sin contraseña',
                                ]
                                .map(
                                  (m) => DropdownMenuItem(
                                    value: m,
                                    child: Text(
                                      m,
                                      style: GoogleFonts.inter(
                                        fontSize: 12,
                                        color: textPrimary,
                                      ),
                                    ),
                                  ),
                                )
                                .toList(),
                        onChanged: (v) => ref
                            .read(vaultFilterProvider.notifier)
                            .setPasswordStrength(v!),
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Password age filter
                    Container(
                      decoration: BoxDecoration(
                        color: isDark
                            ? AppTheme.darkSurfaceLow
                            : AppTheme.stSurfaceLow,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: DropdownButton<String>(
                        value: filters.passwordAgeFilter,
                        underline: const SizedBox(),
                        icon: Icon(
                          LucideIcons.clock,
                          size: 14,
                          color: textSecondary,
                        ),
                        items: ['Todas', '<30 días', '30-90 días', '>90 días']
                            .map(
                              (m) => DropdownMenuItem(
                                value: m,
                                child: Text(
                                  m,
                                  style: GoogleFonts.inter(
                                    fontSize: 12,
                                    color: textPrimary,
                                  ),
                                ),
                              ),
                            )
                            .toList(),
                        onChanged: (v) => ref
                            .read(vaultFilterProvider.notifier)
                            .setPasswordAge(v!),
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Duplicates toggle
                    Tooltip(
                      message: 'Mostrar solo contraseñas duplicadas',
                      child: GestureDetector(
                        onTap: () => ref
                            .read(vaultFilterProvider.notifier)
                            .toggleDuplicates(),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: filters.showDuplicatesOnly
                                ? const Color(
                                    0xFFEF4444,
                                  ).withValues(alpha: 0.15)
                                : (isDark
                                      ? AppTheme.darkSurfaceLow
                                      : AppTheme.stSurfaceLow),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                LucideIcons.copy,
                                size: 14,
                                color: filters.showDuplicatesOnly
                                    ? const Color(0xFFEF4444)
                                    : textSecondary,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'Duplicadas',
                                style: GoogleFonts.inter(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: filters.showDuplicatesOnly
                                      ? const Color(0xFFEF4444)
                                      : textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const Spacer(),
                    // Active filter count + clear button
                    if (activeFilters > 0) ...[
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppTheme.stPrimary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              LucideIcons.filter,
                              size: 12,
                              color: AppTheme.stPrimary,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '$activeFilters activo${activeFilters > 1 ? 's' : ''}',
                              style: GoogleFonts.inter(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: AppTheme.stPrimary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      TextButton.icon(
                        onPressed: _clearAllFilters,
                        icon: const Icon(LucideIcons.x, size: 14),
                        label: Text(
                          'Limpiar filtros',
                          style: GoogleFonts.inter(fontSize: 11),
                        ),
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 16),
                // Audit warnings
                if (weakPasswords.isNotEmpty || duplicateGroups.isNotEmpty) ...[
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEF4444).withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: const Color(0xFFEF4444).withValues(alpha: 0.20),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              LucideIcons.alertTriangle,
                              size: 14,
                              color: const Color(0xFFEF4444),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'ALERTA DE SEGURIDAD',
                              style: GoogleFonts.inter(
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 1.0,
                                color: const Color(0xFFEF4444),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        if (weakPasswords.isNotEmpty)
                          Text(
                            '• ${weakPasswords.length} contraseña${weakPasswords.length > 1 ? 's' : ''} débil${weakPasswords.length > 1 ? 'es' : ''}: ${weakPasswords.join(", ")}',
                            style: GoogleFonts.inter(
                              fontSize: 11,
                              color: textSecondary,
                            ),
                          ),
                        if (duplicateGroups.isNotEmpty)
                          Text(
                            '• ${duplicateGroups.length} grupo${duplicateGroups.length > 1 ? 's' : ''} de contraseñas duplicada${duplicateGroups.length > 1 ? 's' : ''}',
                            style: GoogleFonts.inter(
                              fontSize: 11,
                              color: textSecondary,
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
                // Batch action bar
                if (_batchMode && _selectedItems.isNotEmpty) ...[
                  Container(
                    padding: const EdgeInsets.all(12),
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF59E0B).withValues(alpha: 0.10),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: const Color(0xFFF59E0B).withValues(alpha: 0.30),
                      ),
                    ),
                    child: Row(
                      children: [
                        Text(
                          '${_selectedItems.length} seleccionada${_selectedItems.length > 1 ? 's' : ''}',
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: textPrimary,
                          ),
                        ),
                        const Spacer(),
                        TextButton.icon(
                          onPressed: _deleteSelected,
                          icon: const Icon(
                            LucideIcons.trash2,
                            size: 16,
                            color: Color(0xFF9f403d),
                          ),
                          label: Text(
                            'Eliminar',
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              color: const Color(0xFF9f403d),
                            ),
                          ),
                        ),
                        TextButton(
                          onPressed: () => setState(() {
                            _selectedItems.clear();
                            _batchMode = false;
                          }),
                          child: Text(
                            'Cancelar',
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              color: textSecondary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                if (_showGridView)
                  _buildGridView(
                    items,
                    textPrimary,
                    textSecondary,
                    cardBg,
                    borderColor,
                  )
                else
                  _buildListView(
                    items,
                    textPrimary,
                    textSecondary,
                    cardBg,
                    borderColor,
                  ),
                const SizedBox(height: 24),
                // ── Pro Tip banner ── matches Stitch dashed border
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color:
                          (isDark
                                  ? AppTheme.darkOutlineVariant
                                  : AppTheme.stOutlineVariant)
                              .withValues(alpha: 0.20),
                      strokeAlign: BorderSide.strokeAlignInside,
                    ),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        LucideIcons.info,
                        size: 16,
                        color: AppTheme.stPrimary,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Consejo: Navegación con Teclado',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: textPrimary,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Presiona Ctrl+F para buscar, Ctrl+N para nueva entrada, Ctrl+L para bloquear.',
                              style: TextStyle(
                                fontSize: 12,
                                color: textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        // ── Sliding Editor Panel ──
        if (_editingItem != null)
          Stack(
            children: [
              ModalBarrier(
                color: Colors.black.withValues(alpha: 0.10),
                dismissible: true,
                onDismiss: () => setState(() => _editingItem = null),
              ),
              Positioned.fill(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    CredentialEditorPanel(
                      item: _editingItem!,
                      onClose: () => setState(() => _editingItem = null),
                    ),
                  ],
                ),
              ),
            ],
          ),
      ],
    );
  }

  Widget _buildGridView(
    List<VaultItem> items,
    Color textPrimary,
    Color textSecondary,
    Color cardBg,
    Color borderColor,
  ) {
    if (items.isEmpty) {
      return _buildEmptyState(textPrimary, textSecondary);
    }
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 1.4,
      ),
      itemCount: items.length,
      itemBuilder: (ctx, i) => _VaultGridCard(
        key: ValueKey(items[i].id),
        item: items[i],
        onTap: () => setState(() => _editingItem = items[i]),
        textPrimary: textPrimary,
        textSecondary: textSecondary,
        cardBg: cardBg,
        borderColor: borderColor,
        getCategoryIcon: _getCategoryIcon,
        isBatchMode: _batchMode,
        isSelected: _selectedItems.contains(items[i].id),
        onToggleSelect: () {
          setState(() {
            if (_selectedItems.contains(items[i].id)) {
              _selectedItems.remove(items[i].id);
            } else {
              _selectedItems.add(items[i].id);
            }
          });
        },
        onCopyPassword: () {
          if (items[i].password?.isNotEmpty == true) {
            Clipboard.setData(ClipboardData(text: items[i].password!));
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
    );
  }

  Widget _buildEmptyState(Color textPrimary, Color textSecondary) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 80),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: AppTheme.stSurfaceContainer,
              shape: BoxShape.circle,
            ),
            child: Icon(
              LucideIcons.shieldOff,
              size: 36,
              color: textSecondary.withValues(alpha: 0.4),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'No hay credenciales',
            style: GoogleFonts.inter(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Crea tu primera credencial para comenzar',
            style: GoogleFonts.inter(fontSize: 13, color: textSecondary),
          ),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: () => VaultView.showAddDialog(context, ref),
            icon: const Icon(LucideIcons.plus, size: 16),
            label: Text(
              'Crear primera credencial',
              style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.stPrimary,
              foregroundColor: AppTheme.stOnPrimary,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildListView(
    List<VaultItem> items,
    Color textPrimary,
    Color textSecondary,
    Color cardBg,
    Color borderColor,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        children: [
          // Header row - widths must match data row exactly
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: borderColor)),
            ),
            child: Row(
              children: [
                if (_batchMode) const SizedBox(width: 26),
                SizedBox(
                  width: 220,
                  child: Text(
                    'SITIO / SERVICIO',
                    style: GoogleFonts.inter(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.0,
                      color: textSecondary,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                SizedBox(
                  width: 180,
                  child: Text(
                    'USUARIO',
                    style: GoogleFonts.inter(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.0,
                      color: textSecondary,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    'CONTRASEÑA',
                    style: GoogleFonts.inter(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.0,
                      color: textSecondary,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                SizedBox(
                  width: 90,
                  child: Text(
                    'MODIFICADA',
                    style: GoogleFonts.inter(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.0,
                      color: textSecondary,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                SizedBox(
                  width: 80,
                  child: Text(
                    'ACCIONES',
                    style: GoogleFonts.inter(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.0,
                      color: textSecondary,
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (items.isEmpty)
            _buildEmptyState(textPrimary, textSecondary)
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: items.length,
              separatorBuilder: (_, __) =>
                  Divider(height: 1, color: borderColor),
              itemBuilder: (ctx, i) => _VaultCard(
                key: ValueKey(items[i].id),
                item: items[i],
                compact: widget.isCompact,
                onEdit: () => setState(() => _editingItem = items[i]),
                getCategoryIcon: _getCategoryIcon,
                isBatchMode: _batchMode,
                isSelected: _selectedItems.contains(items[i].id),
                onToggleSelect: () {
                  setState(() {
                    if (_selectedItems.contains(items[i].id)) {
                      _selectedItems.remove(items[i].id);
                    } else {
                      _selectedItems.add(items[i].id);
                    }
                  });
                },
              ),
            ),
          if (items.isNotEmpty)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                border: Border(top: BorderSide(color: borderColor)),
              ),
              child: Text(
                '${items.length} credencial${items.length != 1 ? 'es' : ''}',
                style: GoogleFonts.inter(fontSize: 11, color: textSecondary),
              ),
            ),
        ],
      ),
    );
  }
}

class _QuickActionBtn extends StatelessWidget {
  final IconData icon;
  final String label;
  final String tooltip;
  final VoidCallback onPressed;

  const _QuickActionBtn({
    required this.icon,
    required this.label,
    required this.tooltip,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Tooltip(
      message: tooltip,
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, size: 14),
        label: Text(
          label,
          style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w600),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: isDark
              ? const Color(0xFF242426)
              : AppTheme.stSurfaceLow,
          foregroundColor: isDark
              ? const Color(0xFFE5E2E1)
              : AppTheme.stPrimary,
          elevation: 0,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          minimumSize: const Size(0, 30),
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
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                letterSpacing: 1.0,
                color: textSecondary,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w600,
                    color: textPrimary,
                    letterSpacing: -1,
                  ),
                ),
                if (badge != null) ...[
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: (badgeColor ?? Colors.green).withOpacity(0.12),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      badge!,
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: badgeColor ?? Colors.green,
                      ),
                    ),
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

class _VaultGridCard extends ConsumerWidget {
  final VaultItem item;
  final VoidCallback onTap;
  final Color textPrimary;
  final Color textSecondary;
  final Color cardBg;
  final Color borderColor;
  final IconData Function(String?) getCategoryIcon;
  final bool isBatchMode;
  final bool isSelected;
  final VoidCallback onToggleSelect;
  final VoidCallback onCopyPassword;

  const _VaultGridCard({
    super.key,
    required this.item,
    required this.onTap,
    required this.textPrimary,
    required this.textSecondary,
    required this.cardBg,
    required this.borderColor,
    required this.getCategoryIcon,
    this.isBatchMode = false,
    this.isSelected = false,
    required this.onToggleSelect,
    required this.onCopyPassword,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: isBatchMode ? onToggleSelect : onTap,
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: isSelected
                ? AppTheme.stPrimary.withValues(alpha: 0.08)
                : cardBg,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected
                  ? AppTheme.stPrimary.withValues(alpha: 0.4)
                  : borderColor.withValues(alpha: 0.10),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isSelected ? 0.08 : 0.04),
                blurRadius: isSelected ? 12 : 8,
                offset: Offset(0, isSelected ? 4 : 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: AppTheme.stSurfaceContainer,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          getCategoryIcon(item.category),
                          size: 18,
                          color: AppTheme.stPrimary,
                        ),
                      ),
                      const SizedBox(width: 8),
                      if (isBatchMode)
                        Icon(
                          isSelected
                              ? LucideIcons.checkSquare
                              : LucideIcons.square,
                          size: 18,
                          color: isSelected
                              ? AppTheme.stPrimary
                              : textSecondary,
                        ),
                    ],
                  ),
                  GestureDetector(
                    onTap: () {
                      ref
                          .read(vaultProvider.notifier)
                          .updateItem(
                            item.copyWith(isFavorite: !item.isFavorite),
                          );
                    },
                    child: Icon(
                      item.isFavorite ? LucideIcons.star : LucideIcons.starOff,
                      size: 16,
                      color: item.isFavorite
                          ? const Color(0xFFF59E0B)
                          : borderColor,
                    ),
                  ),
                ],
              ),
              const Spacer(),
              Text(
                item.title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: textPrimary,
                  letterSpacing: -0.02,
                ),
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Text(
                item.username ?? 'Sin usuario',
                style: TextStyle(fontSize: 12, color: textSecondary),
                overflow: TextOverflow.ellipsis,
              ),
              if (item.category != null) ...[
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.stSurfaceContainer,
                    borderRadius: BorderRadius.circular(9999),
                  ),
                  child: Text(
                    item.category!.toUpperCase(),
                    style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.0,
                      color: textSecondary,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: selected
              ? AppTheme.stPrimary
              : (Theme.of(context).brightness == Brightness.dark
                    ? AppTheme.darkSurfaceLow
                    : AppTheme.stSurfaceLow),
          borderRadius: BorderRadius.circular(9999),
        ),
        child: Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: selected
                ? const Color(0xFFFAF7F6)
                : (Theme.of(context).brightness == Brightness.dark
                      ? AppTheme.darkOnSurfaceVariant
                      : AppTheme.stOnSurfaceVariant),
          ),
        ),
      ),
    );
  }
}

class _VaultCard extends ConsumerStatefulWidget {
  final VaultItem item;
  final bool compact;
  final VoidCallback? onEdit;
  final IconData Function(String?) getCategoryIcon;
  final bool isBatchMode;
  final bool isSelected;
  final VoidCallback onToggleSelect;

  const _VaultCard({
    super.key,
    required this.item,
    this.compact = false,
    this.onEdit,
    required this.getCategoryIcon,
    this.isBatchMode = false,
    this.isSelected = false,
    required this.onToggleSelect,
  });
  @override
  ConsumerState<_VaultCard> createState() => _VaultCardState();
}

class _VaultCardState extends ConsumerState<_VaultCard> {
  bool _showPassword = false;

  void _confirmDelete(VaultItem item) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Eliminar "${item.title}"'),
        content: Text('¿Estás seguro? Esta acción no se puede deshacer.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              ref.read(vaultProvider.notifier).deleteItem(item.id);
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('"${item.title}" eliminada'),
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  duration: const Duration(seconds: 2),
                ),
              );
            },
            child: const Text(
              'Eliminar',
              style: TextStyle(color: Color(0xFF9f403d)),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final item = widget.item;
    final username = item.username?.isNotEmpty == true
        ? item.username!
        : 'Sin usuario';
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
                    child: Text(
                      item.title,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(LucideIcons.edit2, size: 14),
                    onPressed: () => VaultView.showAddDialog(
                      context,
                      ref,
                      existingItem: item,
                    ),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(
                      minWidth: 28,
                      minHeight: 28,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(
                      LucideIcons.trash2,
                      size: 14,
                      color: Color(0xFFE55D5D),
                    ),
                    onPressed: () => _confirmDelete(item),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(
                      minWidth: 28,
                      minHeight: 28,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              SelectableText(
                username,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      _showPassword ? password : '••••••••••',
                      style: const TextStyle(fontFamily: 'Courier'),
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      _showPassword ? LucideIcons.eyeOff : LucideIcons.eye,
                      size: 16,
                    ),
                    onPressed: password == '-'
                        ? null
                        : () => setState(() => _showPassword = !_showPassword),
                  ),
                  IconButton(
                    icon: const Icon(LucideIcons.copy, size: 16),
                    onPressed: password == '-'
                        ? null
                        : () {
                            Clipboard.setData(ClipboardData(text: password));
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Contraseña copiada'),
                              ),
                            );
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
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          // Batch checkbox
          if (widget.isBatchMode) ...[
            GestureDetector(
              onTap: widget.onToggleSelect,
              child: Icon(
                widget.isSelected
                    ? LucideIcons.checkSquare
                    : LucideIcons.square,
                size: 16,
                color: widget.isSelected
                    ? AppTheme.stPrimary
                    : const Color(0xFFADB3B0),
              ),
            ),
            const SizedBox(width: 8),
          ],
          // Sitio - 220px
          SizedBox(
            width: 220,
            child: Row(
              children: [
                Container(
                  width: 28,
                  height: 28,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: AppTheme.stSurfaceContainer,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    widget.getCategoryIcon(item.category),
                    size: 13,
                    color: AppTheme.stPrimary,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    item.title,
                    style: GoogleFonts.inter(
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          // Usuario - 180px
          SizedBox(
            width: 180,
            child: Text(
              username,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.inter(fontSize: 12),
            ),
          ),
          const SizedBox(width: 16),
          // Contraseña - Expanded
          Expanded(
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    _showPassword ? password : '••••••••••',
                    style: const TextStyle(
                      fontFamily: 'Courier',
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                IconButton(
                  icon: Icon(
                    _showPassword ? LucideIcons.eyeOff : LucideIcons.eye,
                    size: 14,
                  ),
                  onPressed: password == '-'
                      ? null
                      : () => setState(() => _showPassword = !_showPassword),
                  tooltip: _showPassword ? 'Ocultar' : 'Mostrar',
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(
                    minWidth: 24,
                    minHeight: 24,
                  ),
                ),
                IconButton(
                  icon: const Icon(LucideIcons.copy, size: 14),
                  onPressed: password == '-'
                      ? null
                      : () {
                          Clipboard.setData(ClipboardData(text: password));
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
                        },
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(
                    minWidth: 24,
                    minHeight: 24,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          // Modificada - 90px
          SizedBox(
            width: 90,
            child: Text(
              DateFormat('dd/MM/yyyy').format(item.updatedAt),
              style: const TextStyle(fontSize: 11, color: Color(0xFF5A605E)),
            ),
          ),
          const SizedBox(width: 16),
          // Acciones - 80px
          SizedBox(
            width: 80,
            child: Row(
              children: [
                // Favorite star
                GestureDetector(
                  onTap: () {
                    ref
                        .read(vaultProvider.notifier)
                        .updateItem(
                          item.copyWith(isFavorite: !item.isFavorite),
                        );
                  },
                  child: Icon(
                    item.isFavorite ? LucideIcons.star : LucideIcons.starOff,
                    size: 14,
                    color: item.isFavorite
                        ? const Color(0xFFF59E0B)
                        : const Color(0xFFADB3B0),
                  ),
                ),
                const SizedBox(width: 4),
                // Actions popup menu
                Expanded(
                  child: PopupMenuButton<String>(
                    icon: const Icon(LucideIcons.moreVertical, size: 14),
                    padding: EdgeInsets.zero,
                    tooltip: 'Acciones',
                    onSelected: (value) async {
                      switch (value) {
                        case 'open':
                          if (item.url != null && item.url!.isNotEmpty) {
                            final uri = Uri.tryParse(item.url!);
                            if (uri != null) await launchUrl(uri);
                          }
                          break;
                        case 'edit':
                          if (widget.onEdit != null) {
                            widget.onEdit!();
                          } else {
                            VaultView.showAddDialog(
                              context,
                              ref,
                              existingItem: item,
                            );
                          }
                          break;
                        case 'delete':
                          _confirmDelete(item);
                          break;
                      }
                    },
                    itemBuilder: (ctx) => [
                      if (item.url != null && item.url!.isNotEmpty)
                        const PopupMenuItem(
                          value: 'open',
                          child: Row(
                            children: [
                              Icon(LucideIcons.externalLink, size: 14),
                              SizedBox(width: 8),
                              Text('Abrir URL'),
                            ],
                          ),
                        ),
                      const PopupMenuItem(
                        value: 'edit',
                        child: Row(
                          children: [
                            Icon(LucideIcons.edit2, size: 14),
                            SizedBox(width: 8),
                            Text('Editar'),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(
                              LucideIcons.trash2,
                              size: 14,
                              color: Color(0xFFE55D5D),
                            ),
                            SizedBox(width: 8),
                            Text(
                              'Eliminar',
                              style: TextStyle(color: Color(0xFFE55D5D)),
                            ),
                          ],
                        ),
                      ),
                    ],
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

class NotesView extends ConsumerStatefulWidget {
  final String globalQuery;
  const NotesView({super.key, this.globalQuery = ''});

  @override
  ConsumerState<NotesView> createState() => _NotesViewState();

  static void showAddNoteDialog(
    BuildContext context,
    WidgetRef ref, {
    Note? existingNote,
  }) {
    final noteId =
        existingNote?.id ?? DateTime.now().millisecondsSinceEpoch.toString();
    final titleC = TextEditingController(text: existingNote?.title);
    final contentC = TextEditingController(text: existingNote?.content);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                LucideIcons.fileText,
                size: 20,
                color: Theme.of(context).primaryColor,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                existingNote == null ? 'Nueva Nota' : 'Editar Nota',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        content: SizedBox(
          width: 500,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleC,
                decoration: InputDecoration(
                  labelText: 'Título',
                  hintText: 'Ej: Ideas de proyecto',
                  prefixIcon: const Icon(LucideIcons.type, size: 18),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: contentC,
                maxLines: 6,
                decoration: InputDecoration(
                  labelText: 'Contenido',
                  hintText:
                      'Escribe tus ideas aquí...\nTip: Las URLs serán clickeables automáticamente',
                  prefixIcon: const Icon(LucideIcons.fileText, size: 18),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                enableInteractiveSelection: true,
                toolbarOptions: const ToolbarOptions(
                  copy: true,
                  cut: true,
                  paste: true,
                  selectAll: true,
                ),
              ),
              const SizedBox(height: 10),
              Align(
                alignment: Alignment.centerRight,
                child: OutlinedButton.icon(
                  onPressed: () => unawaited(
                    _tryPasteImageIntoNote(
                      context: context,
                      contentController: contentC,
                      noteId: noteId,
                    ),
                  ),
                  icon: const Icon(LucideIcons.image, size: 14),
                  label: const Text('Pegar imagen'),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              if (titleC.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Por favor ingresa un título')),
                );
                return;
              }
              if (existingNote == null) {
                ref
                    .read(noteProvider.notifier)
                    .addNote(
                      Note(
                        id: noteId,
                        title: titleC.text,
                        content: contentC.text,
                        createdAt: DateTime.now(),
                        updatedAt: DateTime.now(),
                      ),
                    );
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Nota creada exitosamente')),
                );
              } else {
                ref
                    .read(noteProvider.notifier)
                    .updateNote(
                      existingNote.copyWith(
                        title: titleC.text,
                        content: contentC.text,
                        updatedAt: DateTime.now(),
                      ),
                    );
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Nota actualizada exitosamente'),
                  ),
                );
              }
              Navigator.pop(context);
            },
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
  }

  static void showNoteDetailsDialog(
    BuildContext context,
    WidgetRef ref, {
    required Note note,
  }) {
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
                style: const TextStyle(fontWeight: FontWeight.w600),
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
              onTapLink: (text, href, title) async {
                if (href != null) {
                  final uri = Uri.tryParse(href);
                  if (uri != null && await canLaunchUrl(uri)) {
                    await launchUrl(uri, mode: LaunchMode.externalApplication);
                  }
                }
              },
              styleSheet: MarkdownStyleSheet(
                p: TextStyle(
                  fontSize: 13,
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withOpacity(0.85),
                  height: 1.6,
                ),
                // Make links clickable and visible
                a: TextStyle(
                  color: Theme.of(context).primaryColor,
                  decoration: TextDecoration.underline,
                  decorationColor: Theme.of(context).primaryColor,
                ),
              ),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () =>
                NotesView.showAddNoteDialog(context, ref, existingNote: note),
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
  bool _isEditing = false;
  bool _showList = true;
  bool _showProperties = false;
  Timer? _autoSaveTimer;
  final _editContentC = TextEditingController();

  @override
  void dispose() {
    _autoSaveTimer?.cancel();
    _editContentC.dispose();
    super.dispose();
  }

  void _startAutoSave(Note note) {
    _autoSaveTimer?.cancel();
    _autoSaveTimer = Timer(const Duration(seconds: 1), () {
      ref
          .read(noteProvider.notifier)
          .updateNote(
            note.copyWith(
              content: _editContentC.text,
              updatedAt: DateTime.now(),
            ),
          );
    });
  }

  void _saveAndSwitch(Note note) {
    _autoSaveTimer?.cancel();
    if (_editContentC.text != note.content) {
      ref
          .read(noteProvider.notifier)
          .updateNote(
            note.copyWith(
              content: _editContentC.text,
              updatedAt: DateTime.now(),
            ),
          );
    }
  }

  String _relativeTime(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 1) return 'Ahora';
    if (diff.inMinutes < 60) return 'Hace ${diff.inMinutes} min';
    if (diff.inHours < 24) return 'Hace ${diff.inHours}h';
    if (diff.inDays < 7) return 'Hace ${diff.inDays}d';
    return '${dt.day} ${_monthName(dt.month)}';
  }

  String _monthName(int m) {
    const months = [
      'Ene',
      'Feb',
      'Mar',
      'Abr',
      'May',
      'Jun',
      'Jul',
      'Ago',
      'Sep',
      'Oct',
      'Nov',
      'Dic',
    ];
    return months[m - 1];
  }

  bool _hasImages(String content) => content.contains('![');
  bool _hasCode(String content) =>
      content.contains('```') || content.contains('`');

  void _insertMarkdown(String before, [String after = '']) {
    final c = _editContentC;
    final sel = c.selection;
    final text = c.text;
    if (sel.isValid && sel.start != sel.end) {
      final selected = text.substring(sel.start, sel.end);
      final newText = text.replaceRange(
        sel.start,
        sel.end,
        '$before$selected$after',
      );
      c.text = newText;
      c.selection = TextSelection.collapsed(
        offset: sel.start + before.length + selected.length + after.length,
      );
    } else {
      final pos = sel.isValid ? sel.start : text.length;
      final newText =
          text.substring(0, pos) + '$before$after' + text.substring(pos);
      c.text = newText;
      c.selection = TextSelection.collapsed(offset: pos + before.length);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? AppTheme.darkBg : AppTheme.stBg;
    final listBg = isDark ? AppTheme.darkSurface : AppTheme.stSurfaceLow;
    final contentBg = isDark ? AppTheme.darkBg : AppTheme.stSurface;
    final textPrimary = isDark ? AppTheme.darkOnSurface : AppTheme.stOnSurface;
    final textSecondary = isDark
        ? AppTheme.darkOnSurfaceVariant
        : AppTheme.stOnSurfaceVariant;
    final divider =
        (isDark ? AppTheme.darkOutlineVariant : AppTheme.stOutlineVariant)
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
                        'NOTAS',
                        style: GoogleFonts.inter(
                          fontSize: 9,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.5,
                          color: textSecondary,
                        ),
                      ),
                      const Spacer(),
                      // Toggle properties panel
                      if (!_showProperties)
                        IconButton(
                          icon: const Icon(LucideIcons.panelRight, size: 16),
                          onPressed: () =>
                              setState(() => _showProperties = true),
                          tooltip: 'Mostrar propiedades',
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                          color: textSecondary,
                        ),
                      if (_showProperties)
                        IconButton(
                          icon: const Icon(
                            LucideIcons.panelRightClose,
                            size: 16,
                          ),
                          onPressed: () =>
                              setState(() => _showProperties = false),
                          tooltip: 'Ocultar propiedades',
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                          color: textSecondary,
                        ),
                      const SizedBox(width: 8),
                      GestureDetector(
                        onTap: () => NotesView.showAddNoteDialog(context, ref),
                        child: Icon(
                          LucideIcons.plus,
                          size: 16,
                          color: textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                Divider(height: 1, color: divider),
                // Note list with enhanced items
                Expanded(
                  child: notes.isEmpty
                      ? Center(
                          child: Text(
                            q.isEmpty ? 'No hay notas' : 'Sin resultados',
                            style: TextStyle(
                              fontSize: 13,
                              color: textSecondary,
                            ),
                          ),
                        )
                      : ListView.separated(
                          padding: const EdgeInsets.all(8),
                          itemCount: notes.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: 2),
                          itemBuilder: (ctx, i) {
                            final note = notes[i];
                            final isActive = _selectedNote?.id == note.id;
                            return EnhancedNoteListItem(
                              key: ValueKey(note.id),
                              note: note,
                              isActive: isActive,
                              isDark: isDark,
                              onTap: () {
                                _saveAndSwitch(_selectedNote!);
                                setState(() {
                                  _selectedNote = note;
                                  _isEditing = false;
                                  _editContentC.text = note.content;
                                });
                              },
                              onEdit: () => NotesView.showAddNoteDialog(
                                context,
                                ref,
                                existingNote: note,
                              ),
                              onDelete: () => ref
                                  .read(noteProvider.notifier)
                                  .deleteNote(note.id),
                              relativeTime: _relativeTime(note.updatedAt),
                              hasImages: _hasImages(note.content),
                              hasCode: _hasCode(note.content),
                            );
                          },
                        ),
                ),
              ],
            ),
          ),

          // ── Content Canvas (center) ───────────────────────────
          Expanded(
            child: Container(
              color: contentBg,
              child: _selectedNote == null
                  ? Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            LucideIcons.fileText,
                            size: 32,
                            color: textSecondary.withValues(alpha: 0.4),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Selecciona una nota',
                            style: TextStyle(
                              fontSize: 14,
                              color: textSecondary,
                            ),
                          ),
                        ],
                      ),
                    )
                  : EnhancedNoteContent(
                      key: ValueKey(_selectedNote!.id),
                      note: _selectedNote!,
                      isEditing: _isEditing,
                      editController: _editContentC,
                      isDark: isDark,
                      textPrimary: textPrimary,
                      textSecondary: textSecondary,
                      onToggleEdit: () {
                        setState(() {
                          if (_isEditing) {
                            _saveAndSwitch(_selectedNote!);
                            _isEditing = false;
                          } else {
                            _editContentC.text = _selectedNote!.content;
                            _isEditing = true;
                          }
                        });
                      },
                      onAutoSave: () => _startAutoSave(_selectedNote!),
                      onInsertMarkdown: _insertMarkdown,
                    ),
            ),
          ),

          // ── Properties Panel (right) ─────────────────────────
          if (_showProperties)
            NotePropertiesPanel(
              key: ValueKey('props-${_selectedNote!.id}'),
              note: _selectedNote!,
              isDark: isDark,
              textPrimary: textPrimary,
              textSecondary: textSecondary,
            ),
        ],
      ),
    );
  }
}

// Legacy: kept for backward compatibility with dialog-based note creation
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
    return Row(
      children: [
        // ── Main content canvas ──
        Expanded(
          child: Stack(
            children: [
              SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(48, 48, 48, 80),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Tags row (Stitch style)
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: AppTheme.stSecondaryContainer,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            'NOTA',
                            style: GoogleFonts.inter(
                              fontSize: 9,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 1.0,
                              color: AppTheme.stOnSecondaryContainer,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: AppTheme.stTertiaryContainer,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            'DEVOPS',
                            style: GoogleFonts.inter(
                              fontSize: 9,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 1.0,
                              color: AppTheme.stOnTertiaryContainer,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    // Title (Stitch: large, bold)
                    Text(
                      note.title,
                      style: GoogleFonts.inter(
                        fontSize: 36,
                        fontWeight: FontWeight.w800,
                        color: textPrimary,
                        letterSpacing: -0.5,
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Author + date metadata
                    Row(
                      children: [
                        Container(
                          width: 24,
                          height: 24,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppTheme.stSurfaceContainer,
                          ),
                          child: Center(
                            child: Text(
                              'V',
                              style: GoogleFonts.inter(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: textSecondary,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Vault',
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: textSecondary,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          child: Container(
                            width: 3,
                            height: 3,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: textSecondary.withValues(alpha: 0.40),
                            ),
                          ),
                        ),
                        Icon(
                          LucideIcons.calendar,
                          size: 14,
                          color: textSecondary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          DateFormat('d MMM yyyy').format(note.updatedAt),
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            color: textSecondary,
                          ),
                        ),
                      ],
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
                      onTapLink: (text, href, title) async {
                        if (href != null) {
                          final uri = Uri.tryParse(href);
                          if (uri != null && await canLaunchUrl(uri)) {
                            await launchUrl(
                              uri,
                              mode: LaunchMode.externalApplication,
                            );
                          }
                        }
                      },
                      styleSheet: MarkdownStyleSheet(
                        p: TextStyle(
                          fontSize: 15,
                          color: textPrimary.withValues(alpha: 0.88),
                          height: 1.7,
                        ),
                        h1: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w600,
                          color: textPrimary,
                          letterSpacing: -0.3,
                        ),
                        h2: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: textPrimary,
                        ),
                        code: TextStyle(
                          fontFamily: 'Courier',
                          fontSize: 13,
                          color: AppTheme.stPrimary,
                          backgroundColor: AppTheme.stSurfaceContainer,
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
                        a: TextStyle(
                          color: AppTheme.stPrimary,
                          decoration: TextDecoration.underline,
                          decorationColor: AppTheme.stPrimary,
                        ),
                      ),
                    ),
                    const SizedBox(height: 40),
                    // Action row
                    Row(
                      children: [
                        OutlinedButton.icon(
                          onPressed: () => NotesView.showAddNoteDialog(
                            context,
                            ref,
                            existingNote: note,
                          ),
                          icon: const Icon(LucideIcons.edit2, size: 13),
                          label: const Text('Editar'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppTheme.stOnSurface,
                            side: BorderSide(
                              color: AppTheme.stOutlineVariant.withValues(
                                alpha: 0.3,
                              ),
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(6),
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 10,
                            ),
                            textStyle: const TextStyle(fontSize: 12),
                          ),
                        ),
                        const SizedBox(width: 8),
                        OutlinedButton.icon(
                          onPressed: () => ref
                              .read(noteProvider.notifier)
                              .deleteNote(note.id),
                          icon: const Icon(
                            LucideIcons.trash2,
                            size: 13,
                            color: Color(0xFF9f403d),
                          ),
                          label: const Text('Eliminar'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: const Color(0xFF9f403d),
                            side: BorderSide(
                              color: const Color(
                                0xFF9f403d,
                              ).withValues(alpha: 0.2),
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(6),
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 10,
                            ),
                            textStyle: const TextStyle(fontSize: 12),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              // ── Floating Notion-style toolbar ──
              Positioned(
                top: 12,
                left: 0,
                right: 0,
                child: Center(
                  child: Container(
                    decoration: BoxDecoration(
                      color: isDark
                          ? AppTheme.darkSurfaceLow
                          : AppTheme.stSurface,
                      borderRadius: BorderRadius.circular(9999),
                      border: Border.all(
                        color: AppTheme.stOutlineVariant.withValues(
                          alpha: 0.15,
                        ),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.08),
                          blurRadius: 16,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _ToolbarBtn(icon: LucideIcons.bold, tooltip: 'Bold'),
                        _ToolbarBtn(
                          icon: LucideIcons.italic,
                          tooltip: 'Italic',
                        ),
                        _ToolbarBtn(icon: LucideIcons.list, tooltip: 'List'),
                        Container(
                          width: 1,
                          height: 16,
                          color: AppTheme.stOutlineVariant.withValues(
                            alpha: 0.30,
                          ),
                        ),
                        _ToolbarBtn(icon: LucideIcons.link2, tooltip: 'Link'),
                        _ToolbarBtn(icon: LucideIcons.image, tooltip: 'Image'),
                        _ToolbarBtn(icon: LucideIcons.code2, tooltip: 'Code'),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        // ── Right contextual sidebar (Stitch style) ──
        Container(
          width: 56,
          decoration: BoxDecoration(
            color: isDark ? AppTheme.darkSurface : AppTheme.stSurfaceLow,
            border: Border(
              left: BorderSide(
                color: AppTheme.stOutlineVariant.withValues(alpha: 0.10),
              ),
            ),
          ),
          child: Column(
            children: [
              const SizedBox(height: 24),
              _SidebarActionBtn(
                icon: LucideIcons.messageSquare,
                tooltip: 'Comments',
              ),
              const SizedBox(height: 24),
              _SidebarActionBtn(icon: LucideIcons.clock, tooltip: 'History'),
              const SizedBox(height: 24),
              _SidebarActionBtn(icon: LucideIcons.share2, tooltip: 'Share'),
              const SizedBox(height: 24),
              Container(
                width: 32,
                height: 1,
                color: AppTheme.stOutlineVariant.withValues(alpha: 0.20),
              ),
              const SizedBox(height: 24),
              _SidebarActionBtn(
                icon: LucideIcons.star,
                tooltip: 'Favorite',
                filled: false,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ToolbarBtn extends StatelessWidget {
  final IconData icon;
  final String tooltip;

  const _ToolbarBtn({required this.icon, required this.tooltip});

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: Container(
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(6)),
        child: IconButton(
          icon: Icon(icon, size: 16),
          onPressed: () {},
          padding: const EdgeInsets.all(6),
          constraints: const BoxConstraints(),
          color: AppTheme.stOnSurfaceVariant,
          splashRadius: 18,
        ),
      ),
    );
  }
}

class _SidebarActionBtn extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final bool filled;

  const _SidebarActionBtn({
    required this.icon,
    required this.tooltip,
    this.filled = false,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: Container(
        decoration: BoxDecoration(shape: BoxShape.circle),
        child: IconButton(
          icon: Icon(icon, size: 18),
          onPressed: () {},
          color: AppTheme.stOnSurfaceVariant,
          splashRadius: 18,
        ),
      ),
    );
  }
}

class SettingsView extends ConsumerWidget {
  const SettingsView({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final settings = ref.watch(settingsProvider);
    final surfaceColor = isDark ? AppTheme.darkSurface : AppTheme.stSurface;
    final textPrimary = isDark ? AppTheme.darkOnSurface : AppTheme.stOnSurface;
    final textSecondary = isDark
        ? AppTheme.darkOnSurfaceVariant
        : AppTheme.stOnSurfaceVariant;

    return Scaffold(
      backgroundColor: isDark ? AppTheme.darkBg : AppTheme.stBg,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(48),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Ajustes',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: textPrimary,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Configura el tema y la seguridad de tu bóveda.',
              style: TextStyle(fontSize: 14, color: textSecondary),
            ),
            const SizedBox(height: 48),
            _ModernSettingCard(
              isDark: isDark,
              icon: LucideIcons.palette,
              title: 'Apariencia',
              subtitle: 'Personaliza el tema de la aplicación',
              child: DropdownButton<ThemeMode>(
                value: settings.themeMode,
                items: const [
                  DropdownMenuItem(
                    value: ThemeMode.light,
                    child: Text('Claro'),
                  ),
                  DropdownMenuItem(
                    value: ThemeMode.dark,
                    child: Text('Oscuro'),
                  ),
                  DropdownMenuItem(
                    value: ThemeMode.system,
                    child: Text('Sistema'),
                  ),
                ],
                onChanged: (v) =>
                    ref.read(settingsProvider.notifier).setThemeMode(v!),
              ),
            ),
            const SizedBox(height: 16),
            _ModernSettingCard(
              isDark: isDark,
              icon: LucideIcons.shieldCheck,
              title: 'Contraseña Maestra',
              subtitle: settings.hasMasterPassword
                  ? 'Activada - Tu bóveda está protegida'
                  : 'Desactivada - Activa para mayor seguridad',
              trailing: Switch(
                value: settings.hasMasterPassword,
                onChanged: (v) {
                  if (v) {
                    _showPasswordSetDialogGlobal(context, ref);
                  } else {
                    ref.read(settingsProvider.notifier).disableMasterPassword();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Contraseña maestra desactivada'),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  }
                },
              ),
            ),
            const SizedBox(height: 16),
            _ModernSettingCard(
              isDark: isDark,
              icon: LucideIcons.keyRound,
              title: 'Cambiar Contraseña',
              subtitle: 'Actualiza tu contraseña maestra actual',
              enabled: settings.hasMasterPassword,
              onTap: settings.hasMasterPassword
                  ? () => _showPasswordChangeDialog(context, ref)
                  : null,
            ),
            const SizedBox(height: 16),
            _ModernSettingCard(
              isDark: isDark,
              icon: LucideIcons.download,
              title: 'Exportar Datos',
              subtitle: 'Descarga una copia de seguridad de tus credenciales',
              onTap: () {
                final items = ref.read(vaultProvider);
                if (items.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('No hay credenciales para exportar'),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                  return;
                }
                _exportCredentialsFromSettings(context, ref, items);
              },
            ),
            const SizedBox(height: 16),
            _ModernSettingCard(
              isDark: isDark,
              icon: LucideIcons.info,
              title: 'Acerca de',
              subtitle: 'DevVault v1.0.0 - Almacenamiento local seguro',
              onTap: () => _showAboutDialog(context),
            ),
          ],
        ),
      ),
    );
  }

  void _exportCredentialsFromSettings(
    BuildContext context,
    WidgetRef ref,
    List<VaultItem> items,
  ) async {
    try {
      final dir = await getApplicationDocumentsDirectory();
      final file = File(
        '${dir.path}/devvault_export_${DateTime.now().millisecondsSinceEpoch}.json',
      );
      final data = items
          .map(
            (i) => {
              'title': i.title,
              'url': i.url,
              'username': i.username,
              'password': i.password,
              'category': i.category,
              'notes': i.notes,
              'createdAt': i.createdAt.toIso8601String(),
              'updatedAt': i.updatedAt.toIso8601String(),
            },
          )
          .toList();
      await file.writeAsString(jsonEncode(data));
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Exportado exitosamente: ${file.path}'),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al exportar: $e'),
            backgroundColor: const Color(0xFF9f403d),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  void _showAboutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppTheme.stPrimary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(LucideIcons.shield, size: 20),
            ),
            const SizedBox(width: 12),
            const Text('DevVault'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('v1.0.0'),
            const SizedBox(height: 8),
            const Text(
              'Bóveda segura para credenciales, notas y tareas. Todo almacenado localmente con encriptación.',
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }

  void _showPasswordChangeDialog(BuildContext context, WidgetRef ref) {
    final currentC = TextEditingController();
    final newC = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setLocal) {
          final isDark = Theme.of(context).brightness == Brightness.dark;
          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppTheme.stPrimary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(LucideIcons.keyRound, size: 20),
                ),
                const SizedBox(width: 12),
                const Text('Cambiar Contraseña'),
              ],
            ),
            content: SizedBox(
              width: 400,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: currentC,
                    obscureText: true,
                    decoration: InputDecoration(
                      labelText: 'Contraseña actual',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: newC,
                    obscureText: true,
                    decoration: InputDecoration(
                      labelText: 'Nueva contraseña',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancelar'),
              ),
              ElevatedButton(
                onPressed: () {
                  if (currentC.text.isEmpty || newC.text.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Completa todos los campos'),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                    return;
                  }
                  final settings = ref.read(settingsProvider);
                  if (settings.masterPassword != currentC.text) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('La contraseña actual es incorrecta'),
                        backgroundColor: Color(0xFF9f403d),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                    return;
                  }
                  ref
                      .read(settingsProvider.notifier)
                      .setMasterPassword(newC.text);
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Contraseña actualizada exitosamente'),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                },
                child: const Text('Guardar'),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showPasswordSetDialogGlobal(BuildContext context, WidgetRef ref) {
    final c = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppTheme.stPrimary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(LucideIcons.lock, size: 20),
            ),
            const SizedBox(width: 12),
            const Text('Configurar Contraseña'),
          ],
        ),
        content: SizedBox(
          width: 400,
          child: TextField(
            controller: c,
            obscureText: true,
            decoration: InputDecoration(
              labelText: 'Nueva contraseña',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              if (c.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Ingresa una contraseña'),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
                return;
              }
              ref.read(settingsProvider.notifier).setMasterPassword(c.text);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Contraseña configurada exitosamente'),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
  }
}

class _ModernSettingCard extends StatelessWidget {
  final bool isDark;
  final IconData icon;
  final String title;
  final String subtitle;
  final Widget? child;
  final Widget? trailing;
  final VoidCallback? onTap;
  final bool enabled;

  const _ModernSettingCard({
    required this.isDark,
    required this.icon,
    required this.title,
    required this.subtitle,
    this.child,
    this.trailing,
    this.onTap,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    final cardBg = isDark ? AppTheme.darkSurface : AppTheme.stSurface;
    final borderColor = isDark
        ? AppTheme.darkOutlineVariant.withValues(alpha: 0.15)
        : AppTheme.stOutlineVariant.withValues(alpha: 0.15);
    final textPrimary = isDark ? AppTheme.darkOnSurface : AppTheme.stOnSurface;
    final textSecondary = isDark
        ? AppTheme.darkOnSurfaceVariant
        : AppTheme.stOnSurfaceVariant;

    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: enabled ? cardBg : cardBg.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: borderColor),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppTheme.stPrimary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                size: 20,
                color: enabled
                    ? AppTheme.stPrimary
                    : textSecondary.withValues(alpha: 0.5),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: enabled
                          ? textPrimary
                          : textSecondary.withValues(alpha: 0.5),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(fontSize: 12, color: textSecondary),
                  ),
                ],
              ),
            ),
            if (trailing != null) trailing!,
            if (child != null) child!,
            if (onTap != null && child == null && trailing == null)
              Icon(LucideIcons.chevronRight, size: 16, color: textSecondary),
            if (!enabled)
              Text(
                'Requiere contraseña',
                style: TextStyle(
                  fontSize: 11,
                  color: textSecondary.withValues(alpha: 0.6),
                ),
              ),
          ],
        ),
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

class TasksView extends ConsumerStatefulWidget {
  final String globalQuery;
  const TasksView({super.key, this.globalQuery = ''});

  @override
  ConsumerState<TasksView> createState() => _TasksViewState();

  static void showAddTaskDialog(
    BuildContext context,
    WidgetRef ref, {
    TaskItem? existing,
  }) {
    final id = existing?.id ?? generateTaskId();
    final titleC = TextEditingController(text: existing?.title ?? '');
    final notesC = TextEditingController(text: existing?.notes ?? '');
    var isImportant = existing?.isImportant ?? false;
    DateTime? dueAt = existing?.dueAt;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setLocal) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  LucideIcons.checkCircle2,
                  size: 20,
                  color: Theme.of(context).primaryColor,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  existing == null ? 'Nueva Tarea' : 'Editar Tarea',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          content: SizedBox(
            width: 520,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: titleC,
                  decoration: InputDecoration(
                    labelText: 'Título de la tarea',
                    hintText: 'Ej: Terminar el reporte',
                    prefixIcon: const Icon(LucideIcons.checkSquare, size: 18),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: notesC,
                  maxLines: 4,
                  decoration: InputDecoration(
                    labelText: 'Descripción',
                    hintText: 'Añade detalles sobre esta tarea...',
                    prefixIcon: const Icon(LucideIcons.fileText, size: 18),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Theme.of(context).dividerColor),
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          IconButton(
                            tooltip: 'Marcar como importante',
                            onPressed: () =>
                                setLocal(() => isImportant = !isImportant),
                            icon: Icon(
                              isImportant
                                  ? LucideIcons.star
                                  : LucideIcons.starOff,
                              size: 20,
                              color: isImportant
                                  ? const Color(0xFFF59E0B)
                                  : Theme.of(context).colorScheme.onSurface
                                        .withValues(alpha: 0.6),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            isImportant ? 'Importante' : 'No importante',
                            style: TextStyle(
                              fontWeight: FontWeight.w500,
                              color: isImportant
                                  ? const Color(0xFFF59E0B)
                                  : Theme.of(context).colorScheme.onSurface
                                        .withValues(alpha: 0.6),
                            ),
                          ),
                          const Spacer(),
                          OutlinedButton.icon(
                            onPressed: () async {
                              final picked = await showDatePicker(
                                context: context,
                                firstDate: DateTime(2000),
                                lastDate: DateTime(2100),
                                initialDate: dueAt ?? DateTime.now(),
                              );
                              if (picked != null) {
                                setLocal(
                                  () => dueAt = DateTime(
                                    picked.year,
                                    picked.month,
                                    picked.day,
                                  ),
                                );
                              }
                            },
                            icon: const Icon(LucideIcons.calendar, size: 14),
                            label: Text(
                              dueAt == null
                                  ? 'Agregar fecha'
                                  : 'Vence: ${DateFormat('dd/MM/yyyy').format(dueAt!)}',
                            ),
                          ),
                          if (dueAt != null) ...[
                            const SizedBox(width: 8),
                            IconButton(
                              tooltip: 'Quitar fecha',
                              onPressed: () => setLocal(() => dueAt = null),
                              icon: const Icon(LucideIcons.x, size: 16),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () {
                if (titleC.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Por favor ingresa un título para la tarea',
                      ),
                    ),
                  );
                  return;
                }
                final now = DateTime.now();
                if (existing == null) {
                  ref
                      .read(taskProvider.notifier)
                      .addTask(
                        TaskItem(
                          id: id,
                          title: titleC.text,
                          isCompleted: false,
                          isImportant: isImportant,
                          createdAt: now,
                          updatedAt: now,
                          dueAt: dueAt,
                          notes: notesC.text,
                          steps: const [],
                        ),
                      );
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Tarea creada exitosamente')),
                  );
                } else {
                  ref
                      .read(taskProvider.notifier)
                      .updateTask(
                        existing.copyWith(
                          title: titleC.text,
                          notes: notesC.text,
                          dueAt: dueAt,
                          isImportant: isImportant,
                          updatedAt: now,
                        ),
                      );
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Tarea actualizada exitosamente'),
                    ),
                  );
                }
                Navigator.pop(context);
              },
              child: const Text('Guardar'),
            ),
          ],
        ),
      ),
    );
  }
}

enum _TaskFilter { all, today, planned, important, completed }

class _TasksViewState extends ConsumerState<TasksView> {
  TaskItem? _selected;
  _TaskFilter _filter = _TaskFilter.all;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? AppTheme.darkBg : AppTheme.stBg;
    final listBg = isDark ? AppTheme.darkSurface : AppTheme.stSurfaceLow;
    final contentBg = isDark ? AppTheme.darkBg : AppTheme.stSurface;
    final textPrimary = isDark ? AppTheme.darkOnSurface : AppTheme.stOnSurface;
    final textSecondary = isDark
        ? AppTheme.darkOnSurfaceVariant
        : AppTheme.stOnSurfaceVariant;
    final divider =
        (isDark ? AppTheme.darkOutlineVariant : AppTheme.stOutlineVariant)
            .withValues(alpha: 0.10);

    final raw = ref.watch(taskProvider);
    final q = widget.globalQuery.trim().toLowerCase();

    final filteredByQuery = q.isEmpty
        ? raw
        : raw.where((t) {
            return t.title.toLowerCase().contains(q) ||
                t.notes.toLowerCase().contains(q);
          }).toList();

    final today = DateTime.now();
    bool isSameDay(DateTime a, DateTime b) =>
        a.year == b.year && a.month == b.month && a.day == b.day;

    final filtered = switch (_filter) {
      _TaskFilter.all => filteredByQuery,
      _TaskFilter.today =>
        filteredByQuery
            .where((t) => t.dueAt != null && isSameDay(t.dueAt!, today))
            .toList(),
      _TaskFilter.planned =>
        filteredByQuery.where((t) => t.dueAt != null).toList(),
      _TaskFilter.important =>
        filteredByQuery.where((t) => t.isImportant).toList(),
      _TaskFilter.completed =>
        filteredByQuery.where((t) => t.isCompleted).toList(),
    };

    final tasks = [...filtered]
      ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));

    if (_selected == null && tasks.isNotEmpty) {
      _selected = tasks.first;
    } else if (_selected != null &&
        tasks.isNotEmpty &&
        !tasks.any((t) => t.id == _selected!.id)) {
      _selected = tasks.first;
    }
    if (tasks.isEmpty) _selected = null;

    return Container(
      color: bg,
      child: Row(
        children: [
          Container(
            width: 340,
            color: listBg,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                  child: Row(
                    children: [
                      Text(
                        'TASKS',
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 1.5,
                          color: textSecondary,
                        ),
                      ),
                      const Spacer(),
                      GestureDetector(
                        onTap: () => TasksView.showAddTaskDialog(context, ref),
                        child: Icon(
                          LucideIcons.plus,
                          size: 16,
                          color: textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(12, 0, 12, 10),
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _TaskFilterChip(
                        label: 'Todas',
                        isSelected: _filter == _TaskFilter.all,
                        onTap: () => setState(() => _filter = _TaskFilter.all),
                      ),
                      _TaskFilterChip(
                        label: 'Hoy',
                        isSelected: _filter == _TaskFilter.today,
                        onTap: () =>
                            setState(() => _filter = _TaskFilter.today),
                      ),
                      _TaskFilterChip(
                        label: 'Planificadas',
                        isSelected: _filter == _TaskFilter.planned,
                        onTap: () =>
                            setState(() => _filter = _TaskFilter.planned),
                      ),
                      _TaskFilterChip(
                        label: 'Importantes',
                        isSelected: _filter == _TaskFilter.important,
                        onTap: () =>
                            setState(() => _filter = _TaskFilter.important),
                      ),
                      _TaskFilterChip(
                        label: 'Completadas',
                        isSelected: _filter == _TaskFilter.completed,
                        onTap: () =>
                            setState(() => _filter = _TaskFilter.completed),
                      ),
                    ],
                  ),
                ),
                Divider(height: 1, color: divider),
                Expanded(
                  child: tasks.isEmpty
                      ? Center(
                          child: Text(
                            q.isEmpty ? 'No hay tareas' : 'Sin resultados',
                            style: TextStyle(
                              fontSize: 13,
                              color: textSecondary,
                            ),
                          ),
                        )
                      : ListView.separated(
                          padding: const EdgeInsets.all(8),
                          itemCount: tasks.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: 2),
                          itemBuilder: (ctx, i) {
                            final task = tasks[i];
                            final isActive = _selected?.id == task.id;
                            return GestureDetector(
                              onTap: () => setState(() => _selected = task),
                              child: Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: isActive
                                      ? (isDark
                                            ? AppTheme.darkSurfaceLow
                                            : AppTheme.stSurface)
                                      : Colors.transparent,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  children: [
                                    GestureDetector(
                                      onTap: () {
                                        ref
                                            .read(taskProvider.notifier)
                                            .updateTask(
                                              task.copyWith(
                                                isCompleted: !task.isCompleted,
                                                updatedAt: DateTime.now(),
                                              ),
                                            );
                                      },
                                      child: Icon(
                                        task.isCompleted
                                            ? LucideIcons.checkCircle2
                                            : LucideIcons.circle,
                                        size: 16,
                                        color: task.isCompleted
                                            ? const Color(0xFF22C55E)
                                            : textSecondary,
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              Expanded(
                                                child: Text(
                                                  task.title,
                                                  style: TextStyle(
                                                    fontSize: 13,
                                                    fontWeight: FontWeight.w600,
                                                    color: textPrimary
                                                        .withValues(
                                                          alpha:
                                                              task.isCompleted
                                                              ? 0.5
                                                              : 1,
                                                        ),
                                                    decoration: task.isCompleted
                                                        ? TextDecoration
                                                              .lineThrough
                                                        : TextDecoration.none,
                                                  ),
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                              ),
                                              if (task.isImportant)
                                                const Padding(
                                                  padding: EdgeInsets.only(
                                                    left: 8.0,
                                                  ),
                                                  child: Icon(
                                                    LucideIcons.star,
                                                    size: 14,
                                                    color: Color(0xFFF59E0B),
                                                  ),
                                                ),
                                            ],
                                          ),
                                          if (task.dueAt != null)
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                top: 4,
                                              ),
                                              child: Text(
                                                'Vence: ${DateFormat('dd/MM').format(task.dueAt!)}',
                                                style: TextStyle(
                                                  fontSize: 11,
                                                  color: textSecondary,
                                                ),
                                              ),
                                            ),
                                        ],
                                      ),
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
          Expanded(
            child: Container(
              color: contentBg,
              child: _selected == null
                  ? Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            LucideIcons.checkCircle2,
                            size: 32,
                            color: textSecondary.withValues(alpha: 0.4),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Selecciona una tarea',
                            style: TextStyle(
                              fontSize: 14,
                              color: textSecondary,
                            ),
                          ),
                        ],
                      ),
                    )
                  : _TaskContentPanel(
                      key: ValueKey(_selected!.id),
                      task: _selected!,
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

class _TaskFilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  const _TaskFilterChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isSelected
        ? (isDark ? const Color(0xFF2C2C2E) : AppTheme.stSurface)
        : Colors.transparent;
    final border = (isDark ? Colors.white10 : Colors.black.withOpacity(0.06));
    final fg = isSelected
        ? (isDark ? Colors.white : AppTheme.stOnSurface)
        : (isDark ? Colors.white54 : AppTheme.stOnSurfaceVariant);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: border),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: fg,
          ),
        ),
      ),
    );
  }
}

class _TaskContentPanel extends ConsumerWidget {
  final TaskItem task;
  final Color textPrimary;
  final Color textSecondary;
  const _TaskContentPanel({
    super.key,
    required this.task,
    required this.textPrimary,
    required this.textSecondary,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final borderColor = (isDark
        ? Colors.white10
        : Colors.black.withOpacity(0.07));

    final completedSteps = task.steps.where((s) => s.isCompleted).length;
    final totalSteps = task.steps.length;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(48, 48, 48, 80),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              GestureDetector(
                onTap: () => ref
                    .read(taskProvider.notifier)
                    .updateTask(
                      task.copyWith(
                        isCompleted: !task.isCompleted,
                        updatedAt: DateTime.now(),
                      ),
                    ),
                child: Icon(
                  task.isCompleted
                      ? LucideIcons.checkCircle2
                      : LucideIcons.circle,
                  size: 18,
                  color: task.isCompleted
                      ? const Color(0xFF22C55E)
                      : textSecondary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  task.title,
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.w600,
                    letterSpacing: -0.5,
                    color: textPrimary.withValues(
                      alpha: task.isCompleted ? 0.55 : 1,
                    ),
                    decoration: task.isCompleted
                        ? TextDecoration.lineThrough
                        : TextDecoration.none,
                  ),
                ),
              ),
              IconButton(
                tooltip: 'Importante',
                onPressed: () => ref
                    .read(taskProvider.notifier)
                    .updateTask(
                      task.copyWith(
                        isImportant: !task.isImportant,
                        updatedAt: DateTime.now(),
                      ),
                    ),
                icon: Icon(
                  task.isImportant ? LucideIcons.star : LucideIcons.starOff,
                  size: 18,
                  color: task.isImportant
                      ? const Color(0xFFF59E0B)
                      : textSecondary,
                ),
              ),
              IconButton(
                tooltip: 'Editar',
                onPressed: () =>
                    TasksView.showAddTaskDialog(context, ref, existing: task),
                icon: const Icon(LucideIcons.edit2, size: 16),
              ),
              IconButton(
                tooltip: 'Eliminar',
                onPressed: () =>
                    ref.read(taskProvider.notifier).deleteTask(task.id),
                icon: const Icon(
                  LucideIcons.trash2,
                  size: 16,
                  color: Colors.redAccent,
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              _TaskMetaPill(
                icon: LucideIcons.clock,
                label:
                    'Actualizada: ${DateFormat('d MMM yyyy').format(task.updatedAt)}',
                borderColor: borderColor,
                fg: textSecondary,
              ),
              _TaskMetaPill(
                icon: LucideIcons.calendar,
                label: task.dueAt == null
                    ? 'Sin fecha límite'
                    : 'Vence: ${DateFormat('d MMM yyyy').format(task.dueAt!)}',
                borderColor: borderColor,
                fg: textSecondary,
              ),
              _TaskMetaPill(
                icon: LucideIcons.listChecks,
                label: 'Pasos: $completedSteps/$totalSteps',
                borderColor: borderColor,
                fg: textSecondary,
              ),
            ],
          ),
          const SizedBox(height: 22),
          Divider(color: borderColor, height: 1),
          const SizedBox(height: 18),
          if (task.notes.trim().isNotEmpty) ...[
            Text(
              'Notas',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: textSecondary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              task.notes,
              style: TextStyle(
                fontSize: 14,
                height: 1.6,
                color: textPrimary.withValues(alpha: 0.9),
              ),
            ),
            const SizedBox(height: 18),
          ],
          Text(
            'Pasos',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: textSecondary,
            ),
          ),
          const SizedBox(height: 10),
          Container(
            decoration: BoxDecoration(
              border: Border.all(color: borderColor),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                for (final step in task.steps)
                  _TaskStepRow(task: task, step: step),
                _AddStepRow(task: task),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TaskMetaPill extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color borderColor;
  final Color fg;
  const _TaskMetaPill({
    required this.icon,
    required this.label,
    required this.borderColor,
    required this.fg,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: borderColor),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: fg),
          const SizedBox(width: 8),
          Text(label, style: TextStyle(fontSize: 12, color: fg)),
        ],
      ),
    );
  }
}

class _TaskStepRow extends ConsumerWidget {
  final TaskItem task;
  final TaskStep step;
  const _TaskStepRow({required this.task, required this.step});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textPrimary = Theme.of(context).colorScheme.onSurface;
    final borderColor = (Theme.of(context).brightness == Brightness.dark
        ? Colors.white10
        : Colors.black.withOpacity(0.07));

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: borderColor)),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () {
              final steps = [
                for (final s in task.steps)
                  if (s.id == step.id)
                    s.copyWith(isCompleted: !s.isCompleted)
                  else
                    s,
              ];
              ref
                  .read(taskProvider.notifier)
                  .updateTask(
                    task.copyWith(steps: steps, updatedAt: DateTime.now()),
                  );
            },
            child: Icon(
              step.isCompleted ? LucideIcons.checkSquare : LucideIcons.square,
              size: 16,
              color: step.isCompleted
                  ? const Color(0xFF22C55E)
                  : textPrimary.withValues(alpha: 0.55),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              step.title,
              style: TextStyle(
                fontSize: 13,
                color: textPrimary.withValues(
                  alpha: step.isCompleted ? 0.55 : 0.9,
                ),
                decoration: step.isCompleted
                    ? TextDecoration.lineThrough
                    : TextDecoration.none,
              ),
            ),
          ),
          IconButton(
            tooltip: 'Eliminar paso',
            onPressed: () {
              final steps = task.steps.where((s) => s.id != step.id).toList();
              ref
                  .read(taskProvider.notifier)
                  .updateTask(
                    task.copyWith(steps: steps, updatedAt: DateTime.now()),
                  );
            },
            icon: const Icon(LucideIcons.trash2, size: 16),
          ),
        ],
      ),
    );
  }
}

class _AddStepRow extends ConsumerStatefulWidget {
  final TaskItem task;
  const _AddStepRow({required this.task});

  @override
  ConsumerState<_AddStepRow> createState() => _AddStepRowState();
}

class _AddStepRowState extends ConsumerState<_AddStepRow> {
  final _c = TextEditingController();

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  void _add() {
    final title = _c.text.trim();
    if (title.isEmpty) return;
    final steps = [
      ...widget.task.steps,
      TaskStep(id: generateTaskId(), title: title, isCompleted: false),
    ];
    ref
        .read(taskProvider.notifier)
        .updateTask(
          widget.task.copyWith(steps: steps, updatedAt: DateTime.now()),
        );
    _c.clear();
  }

  @override
  Widget build(BuildContext context) {
    final borderColor = (Theme.of(context).brightness == Brightness.dark
        ? Colors.white10
        : Colors.black.withOpacity(0.07));

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: borderColor)),
      ),
      child: Row(
        children: [
          const Icon(LucideIcons.plus, size: 16),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              controller: _c,
              onSubmitted: (_) => _add(),
              decoration: const InputDecoration(
                isDense: true,
                border: InputBorder.none,
                hintText: 'Agregar un paso...',
              ),
            ),
          ),
          IconButton(
            tooltip: 'Agregar',
            onPressed: _add,
            icon: const Icon(LucideIcons.arrowRight, size: 16),
          ),
        ],
      ),
    );
  }
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

  final newText = fullText.replaceRange(safeStart, safeEnd, text);
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
    return Image.file(File.fromUri(uri), width: width, height: height);
  }

  return Image.network(uri.toString(), width: width, height: height);
}
