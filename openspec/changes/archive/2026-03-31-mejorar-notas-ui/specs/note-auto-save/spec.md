## ADDED Requirements

### Requirement: Auto-guardado de notas
El sistema SHALL guardar automáticamente los cambios de una nota después de 1 segundo de inactividad del usuario (debounce) mientras está en modo edición.

#### Scenario: Usuario escribe y deja de escribir
- **WHEN** usuario escribe en el TextField y deja de escribir por 1 segundo
- **THEN** el sistema guarda los cambios en Hive sin intervención del usuario

#### Scenario: Usuario cambia de nota rápidamente
- **WHEN** usuario selecciona otra nota mientras hay cambios pendientes
- **THEN** el sistema guarda la nota anterior antes de cambiar

#### Scenario: Usuario cierra la app mientras edita
- **WHEN** la app se cierra mientras hay cambios sin guardar
- **THEN** los cambios en el buffer del TextField se pierden pero el último auto-save (máx 1s atrás) persiste
