## Why

La sección de credenciales tiene funcionalidad básica CRUD pero le faltan características esenciales de un gestor de contraseñas moderno: generador de contraseñas funcional, filtros por categoría, auditoría de seguridad, favoritos, y mejoras de UX como empty states y ordenamiento.

## What Changes

- **Generador de contraseñas funcional** — Genera contraseñas seguras con opciones de longitud y caracteres
- **Indicador de fortaleza real** — Evalúa la contraseña actual con criterios reales (longitud, variedad, patrones)
- **Copiar usuario y contraseña** — Botones de copiado para ambos campos
- **Filtros por categoría** — Chips de filtro: Todas, Login, API Key, Database, Email, Otros
- **Ordenamiento** — Por nombre (A-Z, Z-A), fecha, categoría
- **Favoritos** — Marcar credenciales de uso frecuente con estrella
- **Auditoría de contraseñas** — Detectar débiles, duplicadas y mostrar puntaje de seguridad
- **Historial de cambios** — Registro de modificaciones por credencial
- **Empty state mejorado** — Ilustración con CTA cuando no hay credenciales
- **Vista previa en hover** — Detalles al pasar el mouse sobre items de la lista

## Capabilities

### New Capabilities
- `password-generator`: Generador de contraseñas con opciones configurables
- `password-strength`: Evaluación real de fortaleza de contraseñas
- `credential-filters`: Filtros por categoría y ordenamiento
- `credential-favorites`: Sistema de favoritos para acceso rápido
- `password-audit`: Auditoría de contraseñas (débiles, duplicadas, puntaje)
- `credential-history`: Historial de cambios por credencial
- `credential-empty-state`: Empty state con ilustración y CTA
- `credential-hover-preview`: Vista previa de detalles en hover

### Modified Capabilities
<!-- No existing specs modified -->

## Impact

- `lib/screens/dashboard_screen.dart` — Sección VaultView con filtros, ordenamiento, favoritos
- `lib/widgets/credential_editor_panel.dart` — Generador, fortaleza real, copiar usuario
- `lib/models/vault_item.dart` — Agregar campo `isFavorite` y `history`
- `lib/providers/vault_provider.dart` — Métodos para favoritos y auditoría
- `lib/widgets/credential_empty_state.dart` — **Nuevo** widget
- `lib/services/password_generator.dart` — **Nuevo** servicio
- `lib/services/password_auditor.dart` — **Nuevo** servicio
- Sin nuevas dependencias externas
