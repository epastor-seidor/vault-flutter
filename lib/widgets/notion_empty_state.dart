import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:dev_vault/theme/app_theme.dart';

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
      title: 'No hay credenciales',
      description: 'Guarda tu primera contraseña o login para comenzar.',
      actionLabel: 'Agregar credencial',
      onAction: onAction,
    );
  }

  factory NotionEmptyState.noNotes({VoidCallback? onAction}) {
    return NotionEmptyState(
      icon: LucideIcons.fileText,
      title: 'No hay notas',
      description: 'Crea tu primera nota para capturar ideas e información.',
      actionLabel: 'Crear nota',
      onAction: onAction,
    );
  }

  factory NotionEmptyState.noTasks({VoidCallback? onAction}) {
    return NotionEmptyState(
      icon: LucideIcons.checkCircle2,
      title: 'No hay tareas',
      description: 'Agrega tu primera tarea para mantenerte organizado.',
      actionLabel: 'Crear tarea',
      onAction: onAction,
    );
  }

  factory NotionEmptyState.noResults({required String query}) {
    return NotionEmptyState(
      icon: LucideIcons.search,
      title: 'Sin resultados',
      description:
          'Nada coincide con "$query". Intenta una búsqueda diferente.',
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPrimary = isDark ? AppTheme.darkOnSurface : AppTheme.stOnSurface;
    final textSecondary = isDark
        ? AppTheme.darkOnSurfaceVariant
        : AppTheme.stOnSurfaceVariant;
    final surfaceLow = isDark ? AppTheme.darkSurfaceLow : AppTheme.stSurfaceLow;
    final borderColor = isDark
        ? AppTheme.darkOutlineVariant
        : AppTheme.stOutlineVariant;

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 64, horizontal: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Icon container - Notion style (3px radius, thin border)
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: surfaceLow,
                borderRadius: BorderRadius.circular(3),
                border: Border.all(color: borderColor, width: 1),
              ),
              child: Icon(icon, size: 20, color: textSecondary),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: textPrimary,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              description,
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 14,
                color: textSecondary,
                height: 1.5,
              ),
            ),
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: onAction,
                style: ElevatedButton.styleFrom(
                  backgroundColor: isDark
                      ? AppTheme.darkPrimary
                      : AppTheme.stPrimaryDim,
                  foregroundColor: isDark
                      ? AppTheme.darkOnPrimary
                      : AppTheme.stOnPrimary,
                  elevation: 0,
                  shadowColor: Colors.transparent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(3),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 8,
                  ),
                ),
                child: Text(
                  actionLabel!,
                  style: GoogleFonts.inter(
                    fontSize: 14,
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
