## 1. Edición Inline de Notas

- [x] 1.1 Agregar estado `_isEditing` al _NotesViewState
- [x] 1.2 Reemplazar diálogo modal por modo edición inline con TextField en _NoteContentPanel
- [x] 1.3 Agregar botón toggle lectura/edición en el header del contenido
- [x] 1.4 Crear widget NoteEditor con TextField multi-línea estilizado

## 2. Auto-guardado

- [x] 2.1 Implementar Timer debounce de 1s en onChanged del editor
- [x] 2.2 Agregar indicador visual "Guardando..." / "Guardado"
- [x] 2.3 Guardar nota anterior al cambiar de nota
- [x] 2.4 Cancelar timer al desmontar el widget

## 3. Barra de Herramientas Funcional

- [x] 3.1 Implementar inserción de **bold** en posición del cursor
- [x] 3.2 Implementar inserción de *italic* en posición del cursor
- [x] 3.3 Implementar inserción de headings (#, ##, ###)
- [x] 3.4 Implementar inserción de listas (- item)
- [x] 3.5 Implementar inserción de [link](url)
- [x] 3.6 Implementar inserción de bloques de código
- [x] 3.7 Implementar inserción de imágenes ![alt](url)

## 4. Mejoras en Lista de Notas

- [x] 4.1 Implementar función de timestamp relativo ("Hace X min", "Ayer", "15 Mar")
- [x] 4.2 Agregar timestamps relativos en cada item de la lista
- [x] 4.3 Implementar detección de contenido (imágenes, código) para badges
- [x] 4.4 Agregar badges de contenido en items de la lista
- [x] 4.5 Implementar acciones en hover (editar/eliminar) con MouseRegion
- [x] 4.6 Agregar toggle para colapsar/mostrar panel izquierdo

## 5. Panel de Propiedades

- [x] 5.1 Crear widget NotePropertiesPanel (200px, sidebar derecha)
- [x] 5.2 Mostrar metadata: fechas, word count, char count
- [x] 5.3 Implementar edición de título desde el panel
- [x] 5.4 Implementar sistema de tags con input y chips
- [x] 5.5 Integrar panel en _NotesViewState con layout de 3 paneles
- [x] 5.6 Agregar toggle para mostrar/ocultar panel de propiedades
