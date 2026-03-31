## Why

La sección de Notas actual tiene un diseño funcional pero le falta la experiencia fluida de edición en línea tipo Notion. El editor usa un diálogo modal desconectado de la vista principal, la barra de herramientas es decorativa, y no hay indicadores visuales de estado (auto-guardado, contenido, etc.).

## What Changes

- **Edición inline**: Reemplazar el diálogo modal por un modo de edición integrado en el panel de contenido, con toggle lectura/edición
- **Auto-guardado**: Guardar automáticamente mientras se escribe (debounce 1s), eliminar botón "Guardar" manual
- **Barra de herramientas funcional**: Los botones del toolbar flotante insertan formato Markdown en el editor
- **Indicadores visuales en la lista**: Timestamp relativo ("Hace 5 min"), badge de contenido (imágenes, código), preview más rico
- **Panel de propiedades**: Sidebar derecha con metadata editable (tags, fecha, word count)
- **Toggle de sidebar**: Botón para colapsar/mostrar el panel izquierdo de notas
- **Acciones rápidas en hover**: Botones de editar/eliminar aparecen al pasar el mouse sobre notas en la lista

## Capabilities

### New Capabilities
- `inline-note-editing`: Edición de notas integrada en el panel de contenido sin diálogos modales
- `note-auto-save`: Guardado automático con debounce mientras el usuario escribe
- `note-toolbar-actions`: Barra de herramientas funcional que inserta formato Markdown
- `note-list-enhancements`: Lista de notas con timestamps relativos, badges de contenido, acciones en hover
- `note-properties-panel`: Panel lateral derecho con metadata y propiedades de la nota

### Modified Capabilities
- `notion-layout`: El layout de notas cambia de dos paneles a tres paneles con propiedades editables

## Impact

- Archivo principal modificado: `lib/screens/dashboard_screen.dart` (sección _NotesViewState y _NoteContentPanel)
- Nuevo widget: `lib/widgets/note_properties_panel.dart`
- Sin cambios en providers ni modelos (auto-save usa noteProvider existente)
- Sin nuevas dependencias
