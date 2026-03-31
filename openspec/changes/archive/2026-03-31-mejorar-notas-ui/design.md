## Context

Actualmente la sección de Notas usa un flujo de dos paneles: lista izquierda + contenido derecha. Para editar se abre un diálogo modal desconectado. La barra de herramientas flotante es decorativa. No hay auto-guardado ni indicadores de estado.

## Goals / Non-Goals

**Goals:**
- Edición inline sin diálogos modales
- Auto-guardado con debounce de 1 segundo
- Barra de herramientas funcional que inserta Markdown
- Lista de notas con timestamps relativos y badges
- Panel de propiedades editable en sidebar derecha
- Toggle para colapsar panel izquierdo

**Non-Goals:**
- No cambiar el modelo Note ni el provider
- No agregar dependencias externas
- No cambiar otras secciones (Credenciales, Tareas)

## Decisions

### D1: Modo edición inline con TextField
**Decisión:** Reemplazar MarkdownBody por TextField en modo edición, alternando con vista de lectura.
**Racional:** Mantiene el contexto visual, el usuario ve su nota mientras edita.
**Alternativas:** Editor de rich text → requiere dependencia externa (flutter_quill).

### D2: Auto-save con Timer debounce
**Decisión:** Usar Timer.run con debounce de 1s en el onChanged del TextField.
**Racional:** Simple, no bloquea la UI, evita writes excesivos a Hive.
**Alternativas:** Guardar en cada keystroke → demasiado I/O. Guardar solo al salir → riesgo de pérdida.

### D3: Toolbar inserta texto en posición del cursor
**Decisión:** Cada botón del toolbar usa TextSelection para insertar sintaxis Markdown en la posición actual del cursor.
**Racional:** Comportamiento esperado en editores de texto.
**Alternativas:** Toolbar como botones de formato visual → requeriría editor WYSIWYG.

### D4: Panel de propiedades como widget separado
**Decisión:** Crear `note_properties_panel.dart` como widget independiente.
**Racional:** Mantiene dashboard_screen.dart manejable, reutilizable.

### D5: Timestamps relativos con formato "Hace X"
**Decisión:** Calcular diferencia de tiempo manualmente (sin paquete intl adicional).
**Racional:** Evita dependencia extra, lógica simple.

## Risks / Trade-offs

| Riesgo | Mitigación |
|--------|-----------|
| Auto-save puede perder cambios si la app crashea | Debounce corto (1s), el texto en el TextField actúa como buffer |
| TextField no renderiza Markdown | Modo lectura usa MarkdownBody, modo edición usa TextField |
| Tres paneles puede verse apretado en pantallas pequeñas | Panel de propiedades solo 200px, toggle para colapsar lista |
