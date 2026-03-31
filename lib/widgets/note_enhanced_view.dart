import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:dev_vault/models/note.dart';
import 'package:dev_vault/providers/note_provider.dart';
import 'package:dev_vault/theme/app_theme.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

/// Enhanced note list item with relative timestamps, content badges, and hover actions
class EnhancedNoteListItem extends StatefulWidget {
  final Note note;
  final bool isActive;
  final bool isDark;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final String relativeTime;
  final bool hasImages;
  final bool hasCode;

  const EnhancedNoteListItem({
    super.key,
    required this.note,
    required this.isActive,
    required this.isDark,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
    required this.relativeTime,
    this.hasImages = false,
    this.hasCode = false,
  });

  @override
  State<EnhancedNoteListItem> createState() => _EnhancedNoteListItemState();
}

class _EnhancedNoteListItemState extends State<EnhancedNoteListItem> {
  bool _isHovered = false;

  String _preview(String content) {
    final stripped = content
        .replaceAll(RegExp(r'!\[.*?\]\(.*?\)'), '[imagen]')
        .replaceAll(RegExp(r'```.*?```', dotAll: true), '[código]')
        .replaceAll(RegExp(r'`.*?`'), '[code]')
        .replaceAll(RegExp(r'\[.*?\]\(.*?\)'), '[link]')
        .replaceAll(RegExp(r'[*_#>~-]'), '')
        .trim();
    return stripped.length > 60 ? '${stripped.substring(0, 60)}...' : stripped;
  }

  @override
  Widget build(BuildContext context) {
    final textPrimary = widget.isDark
        ? AppTheme.darkOnSurface
        : AppTheme.stOnSurface;
    final textSecondary = widget.isDark
        ? AppTheme.darkOnSurfaceVariant
        : AppTheme.stOnSurfaceVariant;
    final activeBg = widget.isDark
        ? AppTheme.darkSurfaceLow
        : AppTheme.stSurface;
    final borderColor =
        (widget.isDark
                ? AppTheme.darkOutlineVariant
                : AppTheme.stOutlineVariant)
            .withValues(alpha: 0.10);

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: widget.isActive ? activeBg : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
            border: widget.isActive ? Border.all(color: borderColor) : null,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    LucideIcons.fileText,
                    size: 13,
                    color: widget.isActive ? AppTheme.stPrimary : textSecondary,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      widget.note.title,
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        fontWeight: widget.isActive
                            ? FontWeight.w600
                            : FontWeight.w500,
                        color: textPrimary,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (_isHovered) ...[
                    IconButton(
                      icon: const Icon(LucideIcons.edit2, size: 13),
                      onPressed: widget.onEdit,
                      padding: const EdgeInsets.all(4),
                      constraints: const BoxConstraints(),
                      color: textSecondary,
                    ),
                    const SizedBox(width: 4),
                    IconButton(
                      icon: const Icon(
                        LucideIcons.trash2,
                        size: 13,
                        color: Color(0xFF9f403d),
                      ),
                      onPressed: widget.onDelete,
                      padding: const EdgeInsets.all(4),
                      constraints: const BoxConstraints(),
                    ),
                  ] else
                    Text(
                      widget.relativeTime,
                      style: GoogleFonts.inter(
                        fontSize: 10,
                        color: textSecondary,
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                _preview(widget.note.content),
                style: GoogleFonts.inter(
                  fontSize: 11,
                  color: textSecondary,
                  height: 1.4,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              if (widget.hasImages || widget.hasCode) ...[
                const SizedBox(height: 6),
                Row(
                  children: [
                    if (widget.hasImages)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 5,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: AppTheme.stSurfaceContainer,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              LucideIcons.image,
                              size: 9,
                              color: textSecondary,
                            ),
                            const SizedBox(width: 3),
                            Text(
                              'img',
                              style: GoogleFonts.inter(
                                fontSize: 8,
                                color: textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    if (widget.hasCode) ...[
                      const SizedBox(width: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 5,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: AppTheme.stSurfaceContainer,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              LucideIcons.code2,
                              size: 9,
                              color: textSecondary,
                            ),
                            const SizedBox(width: 3),
                            Text(
                              'code',
                              style: GoogleFonts.inter(
                                fontSize: 8,
                                color: textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// Enhanced note content panel with inline editing, toolbar, and save indicator
class EnhancedNoteContent extends ConsumerStatefulWidget {
  final Note note;
  final bool isEditing;
  final TextEditingController editController;
  final bool isDark;
  final Color textPrimary;
  final Color textSecondary;
  final VoidCallback onToggleEdit;
  final VoidCallback onAutoSave;
  final Function(String, [String]) onInsertMarkdown;

  const EnhancedNoteContent({
    super.key,
    required this.note,
    required this.isEditing,
    required this.editController,
    required this.isDark,
    required this.textPrimary,
    required this.textSecondary,
    required this.onToggleEdit,
    required this.onAutoSave,
    required this.onInsertMarkdown,
  });

  @override
  ConsumerState<EnhancedNoteContent> createState() =>
      _EnhancedNoteContentState();
}

class _EnhancedNoteContentState extends ConsumerState<EnhancedNoteContent> {
  final _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _wrapSelection(String before, [String after = '']) {
    final c = widget.editController;
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
    widget.onAutoSave();
  }

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

    return Row(
      children: [
        // ── Main content canvas ──
        Expanded(
          child: Stack(
            children: [
              SingleChildScrollView(
                controller: _scrollController,
                padding: const EdgeInsets.fromLTRB(48, 60, 48, 80),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Tags row
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
                        ...widget.note.tags.map(
                          (tag) => Padding(
                            padding: const EdgeInsets.only(left: 8),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: AppTheme.stTertiaryContainer,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                tag.toUpperCase(),
                                style: GoogleFonts.inter(
                                  fontSize: 9,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 1.0,
                                  color: AppTheme.stOnTertiaryContainer,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    // Title
                    Text(
                      widget.note.title,
                      style: GoogleFonts.inter(
                        fontSize: 36,
                        fontWeight: FontWeight.w800,
                        color: widget.textPrimary,
                        letterSpacing: -0.5,
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Metadata
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
                                color: widget.textSecondary,
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
                            color: widget.textSecondary,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          child: Container(
                            width: 3,
                            height: 3,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: widget.textSecondary.withValues(
                                alpha: 0.40,
                              ),
                            ),
                          ),
                        ),
                        Icon(
                          LucideIcons.calendar,
                          size: 14,
                          color: widget.textSecondary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          _relativeTime(widget.note.updatedAt),
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            color: widget.textSecondary,
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
                    // Content: edit mode or read mode
                    if (widget.isEditing)
                      TextField(
                        controller: widget.editController,
                        maxLines: null,
                        minLines: 15,
                        style: GoogleFonts.inter(
                          fontSize: 15,
                          color: widget.textPrimary,
                          height: 1.7,
                        ),
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          isDense: true,
                          contentPadding: EdgeInsets.zero,
                          hintText: 'Escribe tu nota aquí...',
                          hintStyle: GoogleFonts.inter(
                            fontSize: 15,
                            color: widget.textSecondary.withValues(alpha: 0.5),
                            height: 1.7,
                          ),
                        ),
                        onChanged: (_) => widget.onAutoSave(),
                      )
                    else
                      MarkdownBody(
                        data: widget.note.content.isEmpty
                            ? '*Sin contenido. Haz clic en Editar para añadir contenido.*'
                            : widget.note.content,
                        onTapLink: (text, href, title) async {
                          if (href != null) {
                            final uri = Uri.tryParse(href);
                            if (uri != null) {
                              // launch handled by parent
                            }
                          }
                        },
                        styleSheet: MarkdownStyleSheet(
                          p: TextStyle(
                            fontSize: 15,
                            color: widget.textPrimary.withValues(alpha: 0.88),
                            height: 1.7,
                          ),
                          h1: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w600,
                            color: widget.textPrimary,
                            letterSpacing: -0.3,
                          ),
                          h2: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                            color: widget.textPrimary,
                          ),
                          code: TextStyle(
                            fontFamily: 'Courier',
                            fontSize: 13,
                            color: AppTheme.stPrimary,
                            backgroundColor: AppTheme.stSurfaceContainer,
                          ),
                          codeblockDecoration: BoxDecoration(
                            color: widget.isDark
                                ? AppTheme.darkSurfaceLow
                                : AppTheme.stSurfaceContainer,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          blockquoteDecoration: BoxDecoration(
                            border: Border(
                              left: BorderSide(
                                color: AppTheme.stPrimary.withValues(
                                  alpha: 0.4,
                                ),
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
                  ],
                ),
              ),
              // ── Floating toolbar ──
              Positioned(
                top: 12,
                left: 0,
                right: 0,
                child: Center(
                  child: Container(
                    decoration: BoxDecoration(
                      color: surface,
                      borderRadius: BorderRadius.circular(9999),
                      border: Border.all(color: borderColor),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.08),
                          blurRadius: 16,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _ToolbarBtn(
                          icon: LucideIcons.edit2,
                          tooltip: widget.isEditing ? 'Listo' : 'Editar',
                          onTap: widget.onToggleEdit,
                          active: widget.isEditing,
                        ),
                        if (widget.isEditing) ...[
                          Container(width: 1, height: 16, color: borderColor),
                          _ToolbarBtn(
                            icon: LucideIcons.bold,
                            tooltip: 'Negrita',
                            onTap: () => _wrapSelection('**', '**'),
                          ),
                          _ToolbarBtn(
                            icon: LucideIcons.italic,
                            tooltip: 'Cursiva',
                            onTap: () => _wrapSelection('*', '*'),
                          ),
                          _ToolbarBtn(
                            icon: LucideIcons.heading,
                            tooltip: 'Título',
                            onTap: () => _wrapSelection('# ', ''),
                          ),
                          Container(width: 1, height: 16, color: borderColor),
                          _ToolbarBtn(
                            icon: LucideIcons.list,
                            tooltip: 'Lista',
                            onTap: () => _wrapSelection('- ', ''),
                          ),
                          _ToolbarBtn(
                            icon: LucideIcons.link2,
                            tooltip: 'Link',
                            onTap: () => _wrapSelection('[', '](url)'),
                          ),
                          _ToolbarBtn(
                            icon: LucideIcons.code2,
                            tooltip: 'Código',
                            onTap: () => _wrapSelection('`', '`'),
                          ),
                          _ToolbarBtn(
                            icon: LucideIcons.image,
                            tooltip: 'Imagen',
                            onTap: () => _wrapSelection('![alt](', ')'),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _relativeTime(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 1) return 'Ahora';
    if (diff.inMinutes < 60) return 'Hace ${diff.inMinutes} min';
    if (diff.inHours < 24) return 'Hace ${diff.inHours}h';
    if (diff.inDays < 7) return 'Hace ${diff.inDays}d';
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
    return '${dt.day} ${months[dt.month - 1]} ${dt.year}';
  }
}

class _ToolbarBtn extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;
  final bool active;

  const _ToolbarBtn({
    required this.icon,
    required this.tooltip,
    required this.onTap,
    this.active = false,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(6),
          color: active ? AppTheme.stSurfaceContainer : Colors.transparent,
        ),
        child: IconButton(
          icon: Icon(icon, size: 16),
          onPressed: onTap,
          padding: const EdgeInsets.all(6),
          constraints: const BoxConstraints(),
          color: active ? AppTheme.stPrimary : AppTheme.stOnSurfaceVariant,
          splashRadius: 18,
        ),
      ),
    );
  }
}
