## ADDED Requirements

### Requirement: Barra de herramientas con acciones Markdown
El sistema SHALL permitir insertar sintaxis Markdown en la posición actual del cursor a través de botones en la barra de herramientas flotante. Los botones incluirán: Bold, Italic, Heading, List, Link, Code, Image.

#### Scenario: Usuario inserta texto en negrita
- **WHEN** usuario selecciona texto y hace clic en el botón Bold
- **THEN** el texto seleccionado se envuelve con `**texto**`

#### Scenario: Usuario inserta un enlace
- **WHEN** usuario hace clic en el botón Link
- **THEN** se inserta `[texto](url)` en la posición del cursor

#### Scenario: Usuario inserta un bloque de código
- **WHEN** usuario hace clic en el botón Code
- **THEN** se inserta un bloque de código con backticks triples en la posición del cursor
