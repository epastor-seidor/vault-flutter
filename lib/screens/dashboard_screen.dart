import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:dev_vault/providers/vault_provider.dart';
import 'package:dev_vault/providers/note_provider.dart';
import 'package:dev_vault/theme/app_theme.dart';
import 'package:dev_vault/models/vault_item.dart';
import 'package:dev_vault/models/note.dart';
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

    return Scaffold(
      body: Row(
        children: [
          // Notion-like Sidebar
          Container(
            width: 250,
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF202020) : AppTheme.notionSidebarBg,
              border: Border(
                right: BorderSide(
                  color: isDark ? Colors.white12 : AppTheme.notionBorder,
                  width: 1,
                ),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 24),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Row(
                    children: [
                      Container(
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          color: AppTheme.notionTextPrimary,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Center(
                          child: Text(
                            'D',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        'DevVault',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          letterSpacing: -0.2,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
                _SidebarItem(
                  icon: LucideIcons.layout,
                  label: 'General',
                  isSelected: _selectedIndex == 0,
                  onTap: () => setState(() => _selectedIndex = 0),
                ),
                _SidebarItem(
                  icon: LucideIcons.shieldCheck,
                  label: 'Bóveda Segura',
                  isSelected: _selectedIndex == 1,
                  onTap: () => setState(() => _selectedIndex = 1),
                ),
                _SidebarItem(
                  icon: LucideIcons.fileText,
                  label: 'Notas Técnicas',
                  isSelected: _selectedIndex == 2,
                  onTap: () => setState(() => _selectedIndex = 2),
                ),
                const Spacer(),
                const Divider(),
                _SidebarItem(
                  icon: LucideIcons.settings,
                  label: 'Configuración',
                  isSelected: false,
                  onTap: () {},
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
          // Main content area
          Expanded(
            child: _buildContent(),
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
      default:
        return const Center(child: Text('Coming Soon'));
    }
  }
}

class _SidebarItem extends StatelessWidget {
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
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 2),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(6),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? (isDark ? Colors.white12 : AppTheme.notionHover) : Colors.transparent,
            borderRadius: BorderRadius.circular(6),
          ),
          child: Row(
            children: [
              Icon(
                icon,
                size: 18,
                color: isSelected ? (isDark ? Colors.white : AppTheme.notionTextPrimary) : AppTheme.notionTextSecondary,
              ),
              const SizedBox(width: 12),
              Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: isSelected ? FontWeight.w500 : FontWeight.normal,
                  color: isSelected ? (isDark ? Colors.white : AppTheme.notionTextPrimary) : AppTheme.notionTextSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class VaultView extends ConsumerWidget {
  const VaultView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final vaultItems = ref.watch(vaultProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(48, 48, 48, 24),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Bóveda Segura',
                style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
              ),
              TextButton.icon(
                onPressed: () => _showAddDialog(context, ref),
                icon: const Icon(LucideIcons.plus, size: 18),
                label: const Text('Nueva Entrada'),
                style: TextButton.styleFrom(
                  foregroundColor: AppTheme.notionPrimary,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                ),
              ),
            ],
          ),
        ),
        const Divider(),
        Expanded(
          child: vaultItems.isEmpty
              ? const Center(child: Text('No hay registros en la bóveda.', style: TextStyle(color: Colors.grey)))
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 24),
                  itemCount: vaultItems.length,
                  itemBuilder: (context, index) {
                    final item = vaultItems[index];
                    return _VaultListTile(item: item);
                  },
                ),
        ),
      ],
    );
  }

  void _showAddDialog(BuildContext context, WidgetRef ref, {VaultItem? existingItem}) {
    final titleController = TextEditingController(text: existingItem?.title);
    final urlController = TextEditingController(text: existingItem?.url);
    final userController = TextEditingController(text: existingItem?.username);
    final passController = TextEditingController(text: existingItem?.password);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(existingItem == null ? 'Nueva Entrada' : 'Editar Bóveda'),
        content: SizedBox(
          width: 500,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
              TextField(controller: titleController, decoration: const InputDecoration(labelText: 'Título')),
              const SizedBox(height: 12),
              TextField(controller: urlController, decoration: const InputDecoration(labelText: 'URL')),
              const SizedBox(height: 12),
              TextField(controller: userController, decoration: const InputDecoration(labelText: 'Usuario')),
              const SizedBox(height: 12),
              TextField(
                controller: passController,
                decoration: const InputDecoration(labelText: 'Contraseña'),
                obscureText: true,
              ),
            ],
            ),
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
                final updatedItem = existingItem.copyWith(
                  title: titleController.text,
                  url: urlController.text,
                  username: userController.text,
                  password: passController.text,
                  updatedAt: DateTime.now(),
                );
                ref.read(vaultProvider.notifier).updateItem(updatedItem);
              }
              Navigator.pop(context);
            },
            child: Text(existingItem == null ? 'Añadir' : 'Guardar'),
          ),
        ],
      ),
    );
  }
}

class _VaultListTile extends ConsumerWidget {
  final VaultItem item;
  const _VaultListTile({required this.item});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppTheme.notionBorder),
      ),
      child: Row(
        children: [
          const Icon(LucideIcons.lock, size: 16, color: Colors.blueGrey),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.title, style: const TextStyle(fontWeight: FontWeight.w600)),
                if (item.url != null && item.url!.isNotEmpty)
                  Text(item.url!, style: const TextStyle(color: Colors.grey, fontSize: 12)),
              ],
            ),
          ),
          Row(
            children: [
              if (item.url != null && item.url!.isNotEmpty)
                IconButton(
                  icon: const Icon(LucideIcons.externalLink, size: 16),
                  onPressed: () async {
                    String url = item.url!;
                    if (!url.startsWith('http://') && !url.startsWith('https://')) {
                      url = 'https://$url';
                    }
                    final uri = Uri.tryParse(url);
                    if (uri != null && await canLaunchUrl(uri)) {
                      await launchUrl(uri);
                    } else {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('No se pudo abrir la URL')),
                        );
                      }
                    }
                  },
                  tooltip: 'Abrir URL',
                ),
              IconButton(
                icon: const Icon(LucideIcons.user, size: 16),
                onPressed: () {
                  if (item.username != null) {
                    Clipboard.setData(ClipboardData(text: item.username!));
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Usuario copiado')));
                  }
                },
                tooltip: 'Copiar Usuario',
              ),
              IconButton(
                icon: const Icon(LucideIcons.copy, size: 16),
                onPressed: () {
                  if (item.password != null) {
                    Clipboard.setData(ClipboardData(text: item.password!));
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Contraseña copiada')));
                  }
                },
                tooltip: 'Copiar Password',
              ),
              IconButton(
                icon: const Icon(LucideIcons.edit3, size: 16),
                onPressed: () => _VaultViewHelper.showAddDialog(context, ref, existingItem: item),
                tooltip: 'Editar',
              ),
              IconButton(
                icon: const Icon(LucideIcons.trash2, size: 16, color: Colors.redAccent),
                onPressed: () => _showDeleteConfirm(context, ref),
                tooltip: 'Eliminar',
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirm(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar entrada'),
        content: const Text('¿Estás seguro de que quieres eliminar esta credencial?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('No')),
          TextButton(
            onPressed: () {
              ref.read(vaultProvider.notifier).deleteItem(item.id);
              Navigator.pop(context);
            },
            child: const Text('Sí, eliminar', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}

// Helper classes to avoid circular logic or bloated state
class _VaultViewHelper {
  static void showAddDialog(BuildContext context, WidgetRef ref, {VaultItem? existingItem}) {
    const VaultView()._showAddDialog(context, ref, existingItem: existingItem);
  }
}

class NotesView extends ConsumerWidget {
  const NotesView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notes = ref.watch(noteProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(48, 48, 48, 24),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Notas Técnicas',
                style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
              ),
              TextButton.icon(
                onPressed: () => _showAddNoteDialog(context, ref),
                icon: const Icon(LucideIcons.plus, size: 18),
                label: const Text('Nueva Nota'),
                style: TextButton.styleFrom(
                  foregroundColor: AppTheme.notionPrimary,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                ),
              ),
            ],
          ),
        ),
        const Divider(),
        Expanded(
          child: notes.isEmpty
              ? const Center(child: Text('Sin notas guardadas.', style: TextStyle(color: Colors.grey)))
              : GridView.builder(
                  padding: const EdgeInsets.all(48),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 1.4,
                  ),
                  itemCount: notes.length,
                  itemBuilder: (context, index) {
                    final note = notes[index];
                    return _NoteCard(note: note);
                  },
                ),
        ),
      ],
    );
  }

  void _showAddNoteDialog(BuildContext context, WidgetRef ref, {Note? existingNote}) {
    final titleController = TextEditingController(text: existingNote?.title);
    final contentController = TextEditingController(text: existingNote?.content);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(existingNote == null ? 'Nueva Nota' : 'Editar Nota'),
        content: SizedBox(
          width: 600,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
            TextField(controller: titleController, decoration: const InputDecoration(labelText: 'Título')),
            const SizedBox(height: 12),
            TextField(
              controller: contentController,
              decoration: const InputDecoration(labelText: 'Contenido'),
              maxLines: 8,
            ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
          ElevatedButton(
            onPressed: () {
              if (titleController.text.isEmpty) return;
              if (existingNote == null) {
                final newNote = Note(
                  id: generateNoteId(),
                  title: titleController.text,
                  content: contentController.text,
                  createdAt: DateTime.now(),
                  updatedAt: DateTime.now(),
                );
                ref.read(noteProvider.notifier).addNote(newNote);
              } else {
                final updatedNote = existingNote.copyWith(
                  title: titleController.text,
                  content: contentController.text,
                  updatedAt: DateTime.now(),
                );
                ref.read(noteProvider.notifier).updateNote(updatedNote);
              }
              Navigator.pop(context);
            },
            child: Text(existingNote == null ? 'Crear' : 'Guardar'),
          ),
        ],
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
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppTheme.notionBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  note.title,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              IconButton(
                icon: const Icon(LucideIcons.edit2, size: 14),
                onPressed: () => _NotesViewHelper.showAddNoteDialog(context, ref, existingNote: note),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
              const SizedBox(width: 8),
              IconButton(
                icon: const Icon(LucideIcons.trash, size: 14, color: Colors.redAccent),
                onPressed: () => _showDeleteConfirm(context, ref),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Expanded(
            child: Text(
              note.content,
              style: const TextStyle(color: Colors.black54, fontSize: 13, height: 1.5),
              overflow: TextOverflow.fade,
            ),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirm(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar nota'),
        content: const Text('¿Estás seguro de que deseas eliminar esta nota?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
          TextButton(
            onPressed: () {
              ref.read(noteProvider.notifier).deleteNote(note.id);
              Navigator.pop(context);
            },
            child: const Text('Eliminar', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}

class _NotesViewHelper {
  static void showAddNoteDialog(BuildContext context, WidgetRef ref, {Note? existingNote}) {
    const NotesView()._showAddNoteDialog(context, ref, existingNote: existingNote);
  }
}

class HomeOverview extends ConsumerWidget {
  const HomeOverview({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final vaultCount = ref.watch(vaultProvider).length;
    final notesCount = ref.watch(noteProvider).length;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(64.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Workspace',
            style: TextStyle(fontSize: 40, fontWeight: FontWeight.w800, letterSpacing: -1.2),
          ),
          const SizedBox(height: 8),
          const Text(
            'Bienvenido a tu espacio personal de desarrollo.',
            style: TextStyle(color: AppTheme.notionTextSecondary, fontSize: 18),
          ),
          const SizedBox(height: 64),
          Wrap(
            spacing: 24,
            runSpacing: 24,
            children: [
              _NotionSummaryTile(
                title: 'Credenciales',
                count: vaultCount,
                icon: LucideIcons.key,
                color: Colors.blue,
              ),
              _NotionSummaryTile(
                title: 'Apuntes',
                count: notesCount,
                icon: LucideIcons.fileText,
                color: Colors.orange,
              ),
            ],
          ),
          const SizedBox(height: 64),
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppTheme.notionSidebarBg,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppTheme.notionBorder),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(LucideIcons.lightbulb, size: 20, color: Colors.amber),
                    SizedBox(width: 12),
                    Text('Inspiración del día', style: TextStyle(fontWeight: FontWeight.w600)),
                  ],
                ),
                SizedBox(height: 12),
                Text(
                  'Organiza tu vida de desarrollador de la misma forma que organizas tu código. Limpio, escalable y siempre accesible.',
                  style: TextStyle(color: AppTheme.notionTextSecondary, height: 1.6),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _NotionSummaryTile extends StatelessWidget {
  final String title;
  final int count;
  final IconData icon;
  final Color color;

  const _NotionSummaryTile({
    required this.title,
    required this.count,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 280,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.notionBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const Spacer(),
              Text(
                count.toString(),
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
          ),
        ],
      ),
    );
  }
}
