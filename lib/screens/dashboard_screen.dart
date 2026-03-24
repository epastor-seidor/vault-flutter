import 'dart:async';
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

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  int _selectedIndex = 0;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: isDark ? AppTheme.darkBg : AppTheme.lightBg,
      endDrawer: _buildSecurityDrawer(),
      body: Container(
        color: Theme.of(context).scaffoldBackgroundColor,
        child: Row(
          children: [
            // Sidebar edge-to-edge
            Container(
              width: 240,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                border: Border(
                  right: BorderSide(color: Theme.of(context).dividerColor, width: 1),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 36),
                  // Brand (Notion-like clean text)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: isDark ? Colors.white10 : Colors.black.withOpacity(0.05),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Icon(LucideIcons.shieldCheck, color: Theme.of(context).primaryColor, size: 16),
                        ),
                        const SizedBox(width: 12),
                        const Text(
                          'Dev Vault',
                          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, letterSpacing: -0.5),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                  // Items
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          _SidebarItem(
                            icon: LucideIcons.layoutGrid,
                            label: 'Workspace',
                            isSelected: _selectedIndex == 0,
                            onTap: () => setState(() => _selectedIndex = 0),
                          ),
                          _SidebarItem(
                            icon: LucideIcons.key,
                            label: 'Vault',
                            isSelected: _selectedIndex == 1,
                            onTap: () => setState(() => _selectedIndex = 1),
                          ),
                          _SidebarItem(
                            icon: LucideIcons.pencil,
                            label: 'Notes',
                            isSelected: _selectedIndex == 2,
                            onTap: () => setState(() => _selectedIndex = 2),
                          ),
                          const SizedBox(height: 64),
                          Divider(indent: 24, endIndent: 24, color: Theme.of(context).dividerColor),
                          const SizedBox(height: 16),
                          _SidebarItem(
                            icon: LucideIcons.settings2,
                            label: 'Settings',
                            isSelected: _selectedIndex == 3,
                            onTap: () => setState(() => _selectedIndex = 3),
                          ),
                          _SidebarItem(
                            icon: LucideIcons.logOut,
                            label: 'Lock Vault',
                            isSelected: false,
                            color: AppTheme.accentSecondary,
                            onTap: () {
                              ref.read(lockProvider.notifier).lock();
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Content
            Expanded(
              child: Container(
                color: Theme.of(context).scaffoldBackgroundColor,
                child: _buildContent(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSecurityDrawer() {
    final logs = ref.watch(securityLogProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Drawer(
      width: 400,
      backgroundColor: isDark ? AppTheme.darkBg : AppTheme.lightSurface,
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

  Widget _buildContent() {
    switch (_selectedIndex) {
      case 0:
        return const HomeOverview();
      case 1:
        return const VaultView();
      case 2:
        return const NotesView();
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
  final Color? color;

  const _SidebarItem({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
    this.color,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final accentColor = color ?? Theme.of(context).primaryColor;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 2),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(50),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? (isDark ? accentColor.withOpacity(0.15) : accentColor.withOpacity(0.1)) : Colors.transparent,
            borderRadius: BorderRadius.circular(50),
          ),
          child: Row(
            children: [
              Icon(
                icon,
                size: 16,
                color: isSelected ? (isDark ? Colors.white : Colors.black87) : (isDark ? Colors.white60 : Colors.black54),
              ),
              const SizedBox(width: 12),
              Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  color: isSelected ? (isDark ? Colors.white : Colors.black87) : (isDark ? Colors.white60 : Colors.black54),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SearchSectionHeader extends StatelessWidget {
  final String title;
  final String searchHint;
  final ValueChanged<String> onSearchChanged;
  final Widget action;

  const _SearchSectionHeader({
    required this.title,
    required this.searchHint,
    required this.onSearchChanged,
    required this.action,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(32, 24, 32, 16),
      child: Row(
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700) ??
                const TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
          ),
          const Spacer(),
          SizedBox(
            width: 320,
            child: TextField(
              onChanged: onSearchChanged,
              decoration: InputDecoration(
                hintText: searchHint,
                prefixIcon: const Icon(LucideIcons.search, size: 16),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
              ),
            ),
          ),
          const SizedBox(width: 16),
          action,
        ],
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
  const VaultView({super.key});

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
  String _searchQuery = '';
  Timer? _searchDebounce;

  @override
  void dispose() {
    _searchDebounce?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final rawItems = ref.watch(vaultProvider);
    final q = _searchQuery.trim().toLowerCase();

    final filtered = q.isEmpty
        ? rawItems
        : rawItems.where((i) {
            final titleMatch = i.title.toLowerCase().contains(q);
            final userMatch = (i.username?.toLowerCase().contains(q) ?? false);
            return titleMatch || userMatch;
          }).toList();

    final items = [...filtered]
      // Keep consistent order: most recently updated first.
      ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));

    return Column(
      children: [
        _SearchSectionHeader(
          title: 'Vault',
          searchHint: 'Buscar credencial...',
          onSearchChanged: (val) {
            _searchDebounce?.cancel();
            _searchDebounce = Timer(const Duration(milliseconds: 200), () {
              if (!mounted) return;
              setState(() => _searchQuery = val);
            });
          },
          action: ElevatedButton.icon(
            onPressed: () => VaultView.showAddDialog(context, ref),
            icon: const Icon(LucideIcons.plus, size: 16),
            label: const Text('Nueva'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).primaryColor,
              foregroundColor: isDark ? Colors.black : Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
            ),
          ),
        ),
        Expanded(
          child: items.isEmpty
              ? Center(
                  child: Text(
                    _searchQuery.isEmpty ? 'No hay credenciales guardadas' : 'No se encontraron resultados',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                )
              : GridView.builder(
                  padding: const EdgeInsets.all(32),
                  gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                    maxCrossAxisExtent: 400,
                    mainAxisExtent: 180,
                    crossAxisSpacing: 24,
                    mainAxisSpacing: 24,
                  ),
                  itemCount: items.length,
                  itemBuilder: (context, i) => _VaultCard(
                    key: ValueKey(items[i].id),
                    item: items[i],
                  ),
                ),
        ),
      ],
    );
  }
}

class _VaultCard extends ConsumerStatefulWidget {
  final VaultItem item;
  const _VaultCard({super.key, required this.item});
  @override
  ConsumerState<_VaultCard> createState() => _VaultCardState();
}

class _VaultCardState extends ConsumerState<_VaultCard> {
  bool _showPassword = false;

  @override
  Widget build(BuildContext context) {
    final item = widget.item;

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppTheme.accentPrimary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(LucideIcons.key, color: AppTheme.accentPrimary, size: 16),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(item.title, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
              ),
              if (item.url != null && item.url!.isNotEmpty)
                IconButton(
                  icon: const Icon(LucideIcons.externalLink, size: 14, color: Colors.grey),
                  onPressed: () async {
                    final uri = Uri.tryParse(item.url!);
                    if (uri != null) launchUrl(uri);
                  },
                  tooltip: 'Abrir URL',
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              const SizedBox(width: 12),
              IconButton(
                icon: const Icon(LucideIcons.edit2, size: 14, color: Colors.grey),
                onPressed: () => VaultView.showAddDialog(context, ref, existingItem: item),
                tooltip: 'Editar',
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
              const SizedBox(width: 12),
              IconButton(
                icon: const Icon(LucideIcons.trash2, size: 14, color: Colors.redAccent),
                onPressed: () => ref.read(vaultProvider.notifier).deleteItem(item.id),
                tooltip: 'Eliminar',
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
          const Spacer(),
          _CopyRow(
            label: 'User',
            value: item.username?.isNotEmpty == true ? item.username! : '-',
            isObscured: false,
          ),
          const SizedBox(height: 10),
          _CopyRow(
            label: 'Pass',
            value: item.password?.isNotEmpty == true ? item.password! : '-',
            isObscured: !_showPassword,
            onToggleVisibility: () => setState(() => _showPassword = !_showPassword),
          ),
        ],
      ),
    );
  }
}

class _CopyRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isObscured;
  final VoidCallback? onToggleVisibility;

  const _CopyRow({required this.label, required this.value, required this.isObscured, this.onToggleVisibility});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Row(
      children: [
        SizedBox(
          width: 45, 
          child: Text(label, style: const TextStyle(color: Colors.grey, fontSize: 11, fontWeight: FontWeight.w600)),
        ),
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: isDark ? Colors.white.withOpacity(0.03) : Colors.black.withOpacity(0.03),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: isDark ? Colors.transparent : Colors.black.withOpacity(0.03)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    isObscured ? '••••••••••••' : value,
                    style: TextStyle(
                      fontFamily: 'Courier',
                      fontWeight: isObscured ? FontWeight.w900 : FontWeight.w600,
                      fontSize: 13,
                      letterSpacing: isObscured ? 2.0 : 0.0,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (onToggleVisibility != null && value != '-')
                  InkWell(
                    onTap: onToggleVisibility,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4.0),
                      child: Icon(isObscured ? LucideIcons.eye : LucideIcons.eyeOff, size: 14, color: Colors.grey),
                    ),
                  ),
                const SizedBox(width: 8),
                if (value != '-')
                  InkWell(
                    onTap: () {
                      Clipboard.setData(ClipboardData(text: value));
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$label copiado', style: const TextStyle(fontWeight: FontWeight.bold))));
                    },
                    child: const Icon(LucideIcons.copy, size: 14, color: AppTheme.accentPrimary),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}


class NotesView extends ConsumerStatefulWidget {
  const NotesView({super.key});

  @override
  ConsumerState<NotesView> createState() => _NotesViewState();

  static void showAddNoteDialog(BuildContext context, WidgetRef ref, {Note? existingNote}) {
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
              TextField(controller: contentC, maxLines: 6, decoration: const InputDecoration(labelText: 'Contenido')),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
          ElevatedButton(onPressed: () {
            if (existingNote == null) {
              ref.read(noteProvider.notifier).addNote(Note(
                id: DateTime.now().millisecondsSinceEpoch.toString(),
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
  String _searchQuery = '';
  Timer? _searchDebounce;

  @override
  void dispose() {
    _searchDebounce?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final rawNotes = ref.watch(noteProvider);
    final q = _searchQuery.trim().toLowerCase();

    final filtered = q.isEmpty
        ? rawNotes
        : rawNotes.where((n) {
            final titleMatch = n.title.toLowerCase().contains(q);
            final contentMatch = n.content.toLowerCase().contains(q);
            return titleMatch || contentMatch;
          }).toList();

    final notes = [...filtered]..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));

    return Column(
      children: [
        _SearchSectionHeader(
          title: 'Notes',
          searchHint: 'Buscar notas...',
          onSearchChanged: (val) {
            _searchDebounce?.cancel();
            _searchDebounce = Timer(const Duration(milliseconds: 200), () {
              if (!mounted) return;
              setState(() => _searchQuery = val);
            });
          },
          action: ElevatedButton.icon(
            onPressed: () => NotesView.showAddNoteDialog(context, ref),
            icon: const Icon(LucideIcons.plus, size: 14),
            label: const Text('Añadir'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).primaryColor,
              foregroundColor: isDark ? Colors.black : Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
            ),
          ),
        ),
        Expanded(
          child: notes.isEmpty
              ? Center(
                  child: Text(
                    _searchQuery.isEmpty ? 'No hay notas' : 'No se encontraron resultados',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                )
              : GridView.builder(
                  padding: const EdgeInsets.all(24),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 1.8,
                  ),
                  itemCount: notes.length,
                  itemBuilder: (context, i) => _NoteCard(
                    key: ValueKey(notes[i].id),
                    note: notes[i],
                  ),
                ),
        ),
      ],
    );
  }
}

class _NoteCard extends ConsumerWidget {
  final Note note;
  const _NoteCard({super.key, required this.note});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final preview = _makeNotePreview(note.content);
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      padding: const EdgeInsets.all(24),
      child: InkWell(
        onTap: () => NotesView.showNoteDetailsDialog(context, ref, note: note),
        borderRadius: BorderRadius.circular(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppTheme.accentSecondary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Icon(LucideIcons.pencil, size: 14, color: AppTheme.accentSecondary),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    note.title,
                    style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                IconButton(
                  icon: const Icon(LucideIcons.edit2, size: 14),
                  onPressed: () => NotesView.showAddNoteDialog(context, ref, existingNote: note),
                ),
                IconButton(
                  icon: const Icon(LucideIcons.trash2, size: 14, color: Colors.redAccent),
                  onPressed: () => ref.read(noteProvider.notifier).deleteNote(note.id),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              preview,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontSize: 13,
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                    height: 1.6,
                  ) ??
                  TextStyle(
                    fontSize: 13,
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                    height: 1.6,
                  ),
              maxLines: 6,
              overflow: TextOverflow.ellipsis,
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
