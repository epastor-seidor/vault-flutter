## ADDED Requirements

### Requirement: Timestamps relativos en lista de notas
El sistema SHALL mostrar timestamps relativos (ej: "Hace 5 min", "Hace 2h", "Ayer", "15 Mar") en cada item de la lista de notas.

#### Scenario: Nota editada hace pocos minutos
- **WHEN** una nota fue actualizada hace menos de 60 minutos
- **THEN** se muestra "Hace X min"

#### Scenario: Nota editada hace días
- **WHEN** una nota fue actualizada hace más de 24 horas
- **THEN** se muestra la fecha abreviada "15 Mar"

### Requirement: Acciones rápidas en hover
El sistema SHALL mostrar botones de editar y eliminar cuando el usuario pasa el mouse sobre un item de la lista de notas.

#### Scenario: Usuario pasa el mouse sobre una nota
- **WHEN** el cursor del mouse está sobre un item de la lista
- **THEN** aparecen los iconos de editar y eliminar en la esquina derecha del item

### Requirement: Badges de contenido
El sistema SHALL mostrar indicadores visuales en la lista de notas cuando el contenido incluye imágenes o bloques de código.

#### Scenario: Nota contiene imágenes
- **WHEN** el contenido de una nota incluye sintaxis de imagen Markdown
- **THEN** se muestra un badge con icono de imagen en el item de la lista
