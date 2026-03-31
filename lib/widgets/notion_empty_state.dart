import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';

class NotionEmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final String? actionLabel;
  final VoidCallback? onAction;

  const NotionEmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.description,
    this.actionLabel,
    this.onAction,
  });

  factory NotionEmptyState.noCredentials({VoidCallback? onAction}) {
    return NotionEmptyState(
      icon: LucideIcons.key,
      title: 'No credentials yet',
      description: 'Save your first password or login to get started.',
      actionLabel: 'Add credential',
      onAction: onAction,
    );
  }

  factory NotionEmptyState.noNotes({VoidCallback? onAction}) {
    return NotionEmptyState(
      icon: LucideIcons.fileText,
      title: 'No notes yet',
      description: 'Create your first note to capture ideas and information.',
      actionLabel: 'Create note',
      onAction: onAction,
    );
  }

  factory NotionEmptyState.noTasks({VoidCallback? onAction}) {
    return NotionEmptyState(
      icon: LucideIcons.checkCircle2,
      title: 'No tasks yet',
      description: 'Add your first task to stay organized.',
      actionLabel: 'Create task',
      onAction: onAction,
    );
  }

  factory NotionEmptyState.noResults({required String query}) {
    return NotionEmptyState(
      icon: LucideIcons.search,
      title: 'No results found',
      description: 'Nothing matches "$query". Try a different search.',
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPrimary = isDark
        ? const Color(0xFFF9F9F7)
        : const Color(0xFF2D3432);
    final textSecondary = isDark
        ? const Color(0xFFAAAAAA)
        : const Color(0xFF5A605E);
    final surfaceLow = isDark
        ? const Color(0xFF242426)
        : const Color(0xFFF2F4F2);

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 64, horizontal: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: surfaceLow,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, size: 22, color: textSecondary),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: textPrimary,
                letterSpacing: -0.02,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              description,
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 13,
                color: textSecondary,
                height: 1.5,
              ),
            ),
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: onAction,
                style: ElevatedButton.styleFrom(
                  backgroundColor: isDark
                      ? const Color(0xFFE5E2E1)
                      : const Color(0xFF5F5E5E),
                  foregroundColor: isDark
                      ? const Color(0xFF2D3432)
                      : const Color(0xFFFAF7F6),
                  elevation: 0,
                  shadowColor: Colors.transparent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                ),
                child: Text(
                  actionLabel!,
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
