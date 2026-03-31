## ADDED Requirements

### Requirement: Panel de propiedades editable
El sistema SHALL mostrar un panel lateral derecho con propiedades de la nota: título editable, tags, fecha de creación, última modificación, conteo de palabras y caracteres.

#### Scenario: Usuario ve propiedades de la nota
- **WHEN** usuario selecciona una nota
- **THEN** el panel derecho muestra título, tags, fechas y contadores

#### Scenario: Usuario renombra la nota desde el panel
- **WHEN** usuario edita el título en el panel de propiedades
- **THEN** el cambio se guarda automáticamente y se refleja en la lista

#### Scenario: Usuario agrega un tag
- **WHEN** usuario escribe un tag y presiona Enter en el campo de tags
- **THEN** el tag se agrega a la nota y se guarda automáticamente
