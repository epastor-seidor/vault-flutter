## Context

La sección de credenciales tiene filtros, favoritos, generador, auditoría y fortaleza real. Faltan mejoras UX finales.

## Goals / Non-Goals

**Goals:** Empty state visual, iconos categoría, antigüedad, vista rápida, copiar lista, favoritos lista, exportar, atajos, resaltado, batch ops.
**Non-Goals:** No cambiar modelo, no dependencias nuevas, no otras secciones.

## Decisions

### D1: Empty state inline
**Decisión:** Mostrar empty state dentro del área de contenido, no como pantalla separada.

### D2: Iconos mapeados por categoría
**Decisión:** Mapa estático categoría→icono en función helper.

### D3: Exportar JSON simple
**Decisión:** Usar `dart:convert` + `path_provider` para guardar archivo JSON.

### D4: Atajos con RawKeyboardListener
**Decisión:** Usar `KeyboardListener` en el widget raíz de VaultView.

## Risks / Trade-offs

| Riesgo | Mitigación |
|--------|-----------|
| Exportar con muchas credenciales | Progreso visual, archivo en Downloads |
| Batch delete accidental | Confirmación con diálogo |
