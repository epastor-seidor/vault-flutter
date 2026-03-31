## Why

La sección de credenciales tiene funcionalidad sólida pero faltan mejoras UX finales: empty state visual, iconos por categoría, indicador de antigüedad, vista rápida, copiar desde lista, favoritos en vista lista, exportar, atajos de teclado, búsqueda con resaltado, y operaciones en lote.

## What Changes

- Empty state con icono grande y CTA
- Iconos por categoría (Login, API Key, Database, Email, Otros)
- Indicador de antigüedad de contraseña
- Vista rápida al hacer clic (panel resumen)
- Botón copiar contraseña en vista lista
- Estrella favoritos en vista lista
- Exportar credenciales (JSON)
- Atajos de teclado (Ctrl+C, Delete, Enter)
- Búsqueda con resaltado de coincidencias
- Selección múltiple y eliminación en lote

## Capabilities

### New Capabilities
- `credential-empty-state`: Empty state visual con CTA
- `credential-category-icons`: Iconos por categoría
- `credential-age-indicator`: Indicador de antigüedad
- `credential-quick-view`: Vista rápida resumen
- `credential-list-copy`: Copiar desde lista
- `credential-list-favorites`: Favoritos en lista
- `credential-export`: Exportar JSON
- `credential-keyboard-shortcuts`: Atajos de teclado
- `credential-search-highlight`: Resaltado de búsqueda
- `credential-batch-ops`: Operaciones en lote

## Impact

- `lib/screens/dashboard_screen.dart` — VaultView con todas las mejoras
- `lib/widgets/credential_editor_panel.dart` — Indicador de antigüedad
- `lib/widgets/credential_empty_state.dart` — **Nuevo**
- `lib/services/credential_export.dart` — **Nuevo**
- Sin nuevas dependencias
