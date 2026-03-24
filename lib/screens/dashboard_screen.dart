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
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/services.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final accentColor = Theme.of(context).primaryColor;

    return Scaffold(
      body: Row(
        children: [
          // Premium Floating Sidebar
          Container(
            width: 260,
            margin: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark ? AppTheme.darkSurface : AppTheme.notionSidebarBg,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: isDark ? AppTheme.darkBorder : AppTheme.notionBorder),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 32),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Row(
                    children: [
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [accentColor, accentColor.withValues(alpha: 0.7)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(color: accentColor.withValues(alpha: 0.3), blurRadius: 10, offset: const Offset(0, 4))
                          ],
                        ),
                        child: const Icon(LucideIcons.shield, color: Colors.white, size: 20),
                      ),
                      const SizedBox(width: 16),
                      const Text(
                        'DevVault',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, letterSpacing: -0.5),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 48),
                _SidebarItem(
                  icon: LucideIcons.layoutGrid,
                  label: 'Workspace',
                  isSelected: _selectedIndex == 0,
                  onTap: () => setState(() => _selectedIndex = 0),
                ),
                _SidebarItem(
                  icon: LucideIcons.key,
                  label: 'Credenciales',
                  isSelected: _selectedIndex == 1,
                  onTap: () => setState(() => _selectedIndex = 1),
                ),
                _SidebarItem(
                  icon: LucideIcons.pencil,
                  label: 'Notas Rápidas',
                  isSelected: _selectedIndex == 2,
                  onTap: () => setState(() => _selectedIndex = 2),
                ),
                const Spacer(),
                const Divider(indent: 24, endIndent: 24),
                _SidebarItem(
                  icon: LucideIcons.settings2,
                  label: 'Ajustes',
                  isSelected: _selectedIndex == 3,
                  onTap: () => setState(() => _selectedIndex = 3),
                ),
                const SizedBox(height: 8),
                 _SidebarItem(
                  icon: LucideIcons.logOut,
                  label: 'Cerrar Sesión',
                  isSelected: false,
                  color: Colors.redAccent,
                  onTap: () {
                    // Lock the app
                    ref.read(lockProvider.notifier).lock();
                  },
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
          // Scrollable Content
          Expanded(
            child: Container(
              margin: const EdgeInsets.fromLTRB(0, 16, 16, 16),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: _buildContent(),
              ),
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
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? accentColor.withValues(alpha: 0.1) : Colors.transparent,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              Icon(
                icon,
                size: 20,
                color: isSelected ? accentColor : (isDark ? Colors.white60 : Colors.black45),
              ),
              const SizedBox(width: 16),
              Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  color: isSelected ? (isDark ? Colors.white : Colors.black87) : (isDark ? Colors.white60 : Colors.black45),
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
    final accentColor = Theme.of(context).primaryColor;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SingleChildScrollView(
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
                      style: TextStyle(fontSize: 16, color: Colors.grey[500]),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Tu Workspace',
                      style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, letterSpacing: -1),
                    ),
                  ],
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardTheme.color,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Theme.of(context).colorScheme.outline),
                  ),
                  child: const Icon(LucideIcons.bell, size: 20),
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
                  title: 'Bóveda',
                  subtitle: '${vaultItems.length} Registros',
                  icon: LucideIcons.lock,
                  onTap: () {},
                ),
                _BentoCard(
                    span: 1,
                    color: Colors.orangeAccent,
                    title: 'Notas',
                    subtitle: '${notes.length} Apuntes',
                    icon: LucideIcons.pencil,
                    onTap: () {}),
                _BentoCard(
                    span: 1,
                    color: Colors.tealAccent,
                    title: 'Seguridad',
                    subtitle: 'AES-256 Activo',
                    icon: LucideIcons.shieldCheck,
                    onTap: () {}),
                _RecentListCard(
                  items: vaultItems.take(3).toList(),
                  title: 'Recientes en Bóveda',
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
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Theme.of(context).colorScheme.outline),
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
            child: Icon(icon, color: color, size: 20),
          ),
          const Spacer(),
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          const SizedBox(height: 4),
          Text(subtitle, style: const TextStyle(color: Colors.grey, fontSize: 13)),
        ],
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
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Theme.of(context).colorScheme.outline),
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          if (items.isEmpty)
            const Text('Sin actividad reciente', style: TextStyle(color: Colors.grey, fontSize: 12))
          else
            ...items.map((i) => Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Row(
                    children: [
                      const Icon(LucideIcons.key, size: 12, color: Colors.grey),
                      const SizedBox(width: 8),
                      Text(i.title, style: const TextStyle(fontSize: 13)),
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
        gradient: LinearGradient(
          colors: [Theme.of(context).primaryColor, Colors.indigoAccent],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
      ),
      padding: const EdgeInsets.all(24),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(LucideIcons.sparkles, color: Colors.white, size: 24),
          SizedBox(height: 16),
          Text(
            'Tip Pro:',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 4),
          Text(
            'Activa la contraseña maestra para bloquear tu app al salir.',
            style: TextStyle(color: Colors.white70, fontSize: 12),
          ),
        ],
      ),
    );
  }
}

// VaultView and NotesView would follow similar Premium design... 
// (I will condense those for brevity or update them in the next step to not hit token limits)

class VaultView extends ConsumerStatefulWidget {
  const VaultView({super.key});
  @override
  ConsumerState<VaultView> createState() => _VaultViewState();
  static void showAddDialog(BuildContext context, WidgetRef ref, {VaultItem? existingItem}) {
    // ... logic remains same but with better UI ...
    _showVaultDialog(context, ref, existingItem);
  }
}

void _showVaultDialog(BuildContext context, WidgetRef ref, VaultItem? existingItem) {
  final titleController = TextEditingController(text: existingItem?.title);
  final urlController = TextEditingController(text: existingItem?.url);
  final userController = TextEditingController(text: existingItem?.username);
  final passController = TextEditingController(text: existingItem?.password);

  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      title: Text(existingItem == null ? 'Nueva Entrada' : 'Editar Bóveda'),
      content: SizedBox(
        width: 450,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: titleController, decoration: const InputDecoration(labelText: 'Nombre de Servicio')),
            const SizedBox(height: 16),
            TextField(controller: urlController, decoration: const InputDecoration(labelText: 'URL')),
            const SizedBox(height: 16),
            TextField(controller: userController, decoration: const InputDecoration(labelText: 'Usuario')),
            const SizedBox(height: 16),
            TextField(controller: passController, decoration: const InputDecoration(labelText: 'Contraseña'), obscureText: true),
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
        ElevatedButton(
          onPressed: () {
            if (titleController.text.isEmpty) return;
            if (existingItem == null) {
              final newItem = VaultItem(
                id: generateVaultId(),
                title: titleController.text,
                url: urlController.text,
                username: userController.text,
                password: passController.text,
                updatedAt: DateTime.now(),
              );
              ref.read(vaultProvider.notifier).addItem(newItem);
            } else {
              ref.read(vaultProvider.notifier).updateItem(existingItem.copyWith(
                title: titleController.text,
                url: urlController.text,
                username: userController.text,
                password: passController.text,
                updatedAt: DateTime.now(),
              ));
            }
            Navigator.pop(context);
          },
          child: const Text('Guardar'),
        ),
      ],
    ),
  );
}

class _VaultViewState extends ConsumerState<VaultView> {
  final _searchC = TextEditingController();
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final items = ref.watch(vaultProvider).where((i) => i.title.toLowerCase().contains(_query.toLowerCase())).toList();

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: const Text('Mi Bóveda', style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 24.0),
            child: ElevatedButton.icon(
              onPressed: () => VaultView.showAddDialog(context, ref),
              icon: const Icon(LucideIcons.plus, size: 18),
              label: const Text('Añadir'),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: TextField(
              controller: _searchC,
              onChanged: (v) => setState(() => _query = v),
              decoration: InputDecoration(
                hintText: 'Buscar credenciales...',
                prefixIcon: const Icon(LucideIcons.search, size: 18),
                fillColor: Theme.of(context).cardTheme.color,
                filled: true,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(24),
              itemCount: items.length,
              itemBuilder: (context, i) => _VaultTile(item: items[i]),
            ),
          ),
        ],
      ),
    );
  }
}

class _VaultTile extends ConsumerWidget {
  final VaultItem item;
  const _VaultTile({required this.item});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Theme.of(context).colorScheme.outline),
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(color: Theme.of(context).primaryColor.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
          child: Icon(LucideIcons.key, color: Theme.of(context).primaryColor, size: 18),
        ),
        title: Text(item.title, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text(item.url ?? 'Sin URL', style: const TextStyle(fontSize: 12)),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(LucideIcons.edit2, size: 16),
              onPressed: () => VaultView.showAddDialog(context, ref, existingItem: item),
              tooltip: 'Editar',
            ),
            IconButton(icon: const Icon(LucideIcons.copy, size: 16), onPressed: () {
              Clipboard.setData(ClipboardData(text: item.password ?? ''));
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Contraseña copiada')));
            }),
            IconButton(icon: const Icon(LucideIcons.trash2, size: 16, color: Colors.redAccent), onPressed: () {
              ref.read(vaultProvider.notifier).deleteItem(item.id);
            }),
          ],
        ),
        onTap: () async {
          if (item.url != null && item.url!.isNotEmpty) {
            String url = item.url!;
            if (!url.startsWith('http://') && !url.startsWith('https://')) {
              url = 'https://$url';
            }
            final uri = Uri.tryParse(url);
            if (uri != null && await canLaunchUrl(uri)) {
              await launchUrl(uri);
            }
          }
        },
      ),
    );
  }
}

// Similarly for NotesView...

class NotesView extends ConsumerStatefulWidget {
  const NotesView({super.key});
  @override
  ConsumerState<NotesView> createState() => _NotesViewState();
  static void showAddNoteDialog(BuildContext context, WidgetRef ref, {Note? existingNote}) {
    _showNoteDialog(context, ref, existingNote);
  }
}

void _showNoteDialog(BuildContext context, WidgetRef ref, Note? existingNote) {
  final titleC = TextEditingController(text: existingNote?.title);
  final contentC = TextEditingController(text: existingNote?.content);

  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
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
              id: generateNoteId(),
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

class _NotesViewState extends ConsumerState<NotesView> {
  @override
  Widget build(BuildContext context) {
    final notes = ref.watch(noteProvider);
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: const Text('Mis Notas', style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 24.0),
            child: ElevatedButton.icon(onPressed: () => NotesView.showAddNoteDialog(context, ref), icon: const Icon(LucideIcons.plus, size: 18), label: const Text('Añadir')),
          )
        ],
      ),
      body: GridView.builder(
        padding: const EdgeInsets.all(24),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, crossAxisSpacing: 16, mainAxisSpacing: 16, childAspectRatio: 1.8),
        itemCount: notes.length,
        itemBuilder: (context, i) => _NoteCard(note: notes[i]),
      ),
    );
  }
}

class _NoteCard extends ConsumerWidget {
  final Note note;
  const _NoteCard({required this.note});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      decoration: BoxDecoration(color: Theme.of(context).cardTheme.color, borderRadius: BorderRadius.circular(24), border: Border.all(color: Theme.of(context).colorScheme.outline)),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(note.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const Spacer(),
              IconButton(
                icon: const Icon(LucideIcons.edit2, size: 14), 
                onPressed: () => NotesView.showAddNoteDialog(context, ref, existingNote: note),
              ),
              IconButton(
                icon: const Icon(LucideIcons.trash2, size: 14, color: Colors.redAccent), 
                onPressed: () {
                  ref.read(noteProvider.notifier).deleteNote(note.id);
                },
              ),
            ],
          ),
          const SizedBox(height: 8),
          Expanded(child: Text(note.content, style: const TextStyle(fontSize: 13, color: Colors.grey), overflow: TextOverflow.fade)),
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
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(48),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Ajustes', style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
            const SizedBox(height: 48),
            _SettingBox(title: 'Modo de Tema', icon: LucideIcons.moon, trailing: DropdownButton<ThemeMode>(
              value: settings.themeMode, 
              items: const [DropdownMenuItem(value: ThemeMode.light, child: Text('Claro')), DropdownMenuItem(value: ThemeMode.dark, child: Text('Oscuro'))],
              onChanged: (v) => ref.read(settingsProvider.notifier).setThemeMode(v!),
            )),
            const SizedBox(height: 24),
             _SettingBox(title: 'Contraseña Maestra', icon: LucideIcons.lock, trailing: Switch(
               value: settings.hasMasterPassword,
               onChanged: (v) {
                if (v) {
                   _showPasswordSetDialog(context, ref);
                } else {
                   ref.read(settingsProvider.notifier).disableMasterPassword();
                   ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Seguridad desactivada')));
                }
               },
             )),
          ],
        ),
      ),
    );
  }
}

void _showPasswordSetDialog(BuildContext context, WidgetRef ref) {
  final c = TextEditingController();
  showDialog(
    context: context, 
    builder: (context) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: const Text('Configurar Contraseña'),
      content: TextField(
        controller: c, 
        decoration: const InputDecoration(labelText: 'Nueva Contraseña'), 
        obscureText: true,
        autofocus: true,
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
        ElevatedButton(
          onPressed: () {
            if (c.text.isNotEmpty) {
              ref.read(settingsProvider.notifier).setMasterPassword(c.text);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Contraseña maestra activada')));
            }
          }, 
          child: const Text('Establecer'),
        ),
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
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Theme.of(context).cardTheme.color, borderRadius: BorderRadius.circular(16), border: Border.all(color: Theme.of(context).colorScheme.outline)),
      child: Row(children: [Icon(icon, size: 20), const SizedBox(width: 16), Text(title), const Spacer(), trailing]),
    );
  }
}
