import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:dev_vault/models/note.dart';
import 'package:dev_vault/providers/note_provider.dart';
import 'package:dev_vault/theme/app_theme.dart';

class NotePropertiesPanel extends ConsumerStatefulWidget {
  final Note note;
  final bool isDark;
  final Color textPrimary;
  final Color textSecondary;

  const NotePropertiesPanel({
    super.key,
    required this.note,
    required this.isDark,
    required this.textPrimary,
    required this.textSecondary,
  });

  @override
  ConsumerState<NotePropertiesPanel> createState() =>
      _NotePropertiesPanelState();
}

class _NotePropertiesPanelState extends ConsumerState<NotePropertiesPanel> {
  late TextEditingController _titleC;
  late TextEditingController _tagC;
  late List<String> _tags;

  @override
  void initState() {
    super.initState();
    _titleC = TextEditingController(text: widget.note.title);
    _tags = List.from(widget.note.tags);
    _tagC = TextEditingController();
    _titleC.addListener(_onTitleChange);
  }

  @override
  void didUpdateWidget(NotePropertiesPanel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.note.id != widget.note.id) {
      _titleC.text = widget.note.title;
      _tags = List.from(widget.note.tags);
    }
  }

  @override
  void dispose() {
    _titleC.removeListener(_onTitleChange);
    _titleC.dispose();
    _tagC.dispose();
    super.dispose();
  }

  void _onTitleChange() {
    final title = _titleC.text.trim();
    if (title.isNotEmpty && title != widget.note.title) {
      ref
          .read(noteProvider.notifier)
          .updateNote(
            widget.note.copyWith(title: title, updatedAt: DateTime.now()),
          );
    }
  }

  void _addTag() {
    final tag = _tagC.text.trim();
    if (tag.isEmpty || _tags.contains(tag)) return;
    _tags = [..._tags, tag];
    _tagC.clear();
    ref
        .read(noteProvider.notifier)
        .updateNote(
          widget.note.copyWith(tags: _tags, updatedAt: DateTime.now()),
        );
    setState(() {});
  }

  void _removeTag(String tag) {
    _tags = _tags.where((t) => t != tag).toList();
    ref
        .read(noteProvider.notifier)
        .updateNote(
          widget.note.copyWith(tags: _tags, updatedAt: DateTime.now()),
        );
    setState(() {});
  }

  String _relativeTime(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 1) return 'Ahora';
    if (diff.inMinutes < 60) return 'Hace ${diff.inMinutes} min';
    if (diff.inHours < 24) return 'Hace ${diff.inHours}h';
    if (diff.inDays < 7) return 'Hace ${diff.inDays}d';
    return '${dt.day} ${_monthName(dt.month)} ${dt.year}';
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

  int get _wordCount {
    final content = widget.note.content.trim();
    if (content.isEmpty) return 0;
    return content.split(RegExp(r'\s+')).length;
  }

  int get _charCount => widget.note.content.length;

  @override
  Widget build(BuildContext context) {
    final surface = widget.isDark
        ? AppTheme.darkSurface
        : const Color(0xFFFFFFFF);
    final surfaceLow = widget.isDark
        ? const Color(0xFF1C1C1E)
        : AppTheme.stSurfaceLow;
    final borderColor =
        (widget.isDark
                ? AppTheme.darkOutlineVariant
                : AppTheme.stOutlineVariant)
            .withValues(alpha: 0.10);

    return Container(
      width: 220,
      decoration: BoxDecoration(
        color: surface,
        border: Border(left: BorderSide(color: borderColor)),
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Section header
            Text(
              'PROPIEDADES',
              style: GoogleFonts.inter(
                fontSize: 9,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.5,
                color: widget.textSecondary,
              ),
            ),
            const SizedBox(height: 16),

            // Title
            Text(
              'TÍTULO',
              style: GoogleFonts.inter(
                fontSize: 9,
                fontWeight: FontWeight.w600,
                letterSpacing: 1.0,
                color: widget.textSecondary,
              ),
            ),
            const SizedBox(height: 6),
            TextField(
              controller: _titleC,
              style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: widget.textPrimary,
              ),
              decoration: InputDecoration(
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 6,
                ),
                filled: true,
                fillColor: surfaceLow,
              ),
            ),
            const SizedBox(height: 16),

            // Tags
            Text(
              'TAGS',
              style: GoogleFonts.inter(
                fontSize: 9,
                fontWeight: FontWeight.w600,
                letterSpacing: 1.0,
                color: widget.textSecondary,
              ),
            ),
            const SizedBox(height: 6),
            Wrap(
              spacing: 4,
              runSpacing: 4,
              children: [
                for (final tag in _tags)
                  Chip(
                    label: Text(tag, style: GoogleFonts.inter(fontSize: 10)),
                    deleteIcon: const Icon(LucideIcons.x, size: 12),
                    onDeleted: () => _removeTag(tag),
                    padding: EdgeInsets.zero,
                    visualDensity: VisualDensity.compact,
                    backgroundColor: AppTheme.stSurfaceContainer,
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _tagC,
                    onSubmitted: (_) => _addTag(),
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      color: widget.textPrimary,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Agregar tag...',
                      hintStyle: GoogleFonts.inter(
                        fontSize: 11,
                        color: widget.textSecondary,
                      ),
                      border: InputBorder.none,
                      isDense: true,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 6,
                      ),
                      filled: true,
                      fillColor: surfaceLow,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(LucideIcons.plus, size: 14),
                  onPressed: _addTag,
                  padding: const EdgeInsets.all(4),
                  constraints: const BoxConstraints(),
                  color: widget.textSecondary,
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Divider
            Container(height: 1, color: borderColor),
            const SizedBox(height: 16),

            // Metadata
            _MetaRow(
              label: 'CREADA',
              value: _relativeTime(widget.note.createdAt),
              textSecondary: widget.textSecondary,
              textPrimary: widget.textPrimary,
            ),
            const SizedBox(height: 8),
            _MetaRow(
              label: 'MODIFICADA',
              value: _relativeTime(widget.note.updatedAt),
              textSecondary: widget.textSecondary,
              textPrimary: widget.textPrimary,
            ),
            const SizedBox(height: 8),
            _MetaRow(
              label: 'PALABRAS',
              value: '$_wordCount',
              textSecondary: widget.textSecondary,
              textPrimary: widget.textPrimary,
            ),
            const SizedBox(height: 8),
            _MetaRow(
              label: 'CARACTERES',
              value: '$_charCount',
              textSecondary: widget.textSecondary,
              textPrimary: widget.textPrimary,
            ),
          ],
        ),
      ),
    );
  }
}

class _MetaRow extends StatelessWidget {
  final String label;
  final String value;
  final Color textSecondary;
  final Color textPrimary;

  const _MetaRow({
    required this.label,
    required this.value,
    required this.textSecondary,
    required this.textPrimary,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 9,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.8,
            color: textSecondary,
          ),
        ),
        Text(value, style: GoogleFonts.inter(fontSize: 10, color: textPrimary)),
      ],
    );
  }
}
