## ADDED Requirements

### Requirement: Edición inline de notas
El sistema SHALL permitir editar el contenido de una nota directamente en el panel de contenido sin abrir diálogos modales. Un botón de toggle cambiará entre modo lectura (MarkdownBody) y modo edición (TextField).

#### Scenario: Usuario activa modo edición
- **WHEN** usuario hace clic en el botón "Editar" del panel de contenido
- **THEN** el contenido de la nota se convierte en un TextField editable con el texto actual

#### Scenario: Usuario vuelve a modo lectura
- **WHEN** usuario hace clic en el botón "Listo" en modo edición
- **THEN** el contenido se guarda y se muestra como Markdown renderizado

### Requirement: Panel de propiedades de nota
El sistema SHALL mostrar un panel lateral derecho de 200px con metadata de la nota: fecha de creación, última modificación, conteo de palabras, conteo de caracteres, y tags editables.

#### Scenario: Usuario selecciona una nota
- **WHEN** usuario selecciona una nota de la lista
- **THEN** el panel derecho muestra la metadata correspondiente

#### Scenario: Usuario edita tags
- **WHEN** usuario agrega o elimina tags en el panel de propiedades
- **THEN** los cambios se reflejan en la nota y se guardan automáticamente
