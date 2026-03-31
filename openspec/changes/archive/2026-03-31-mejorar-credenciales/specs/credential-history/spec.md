## ADDED Requirements

### Requirement: Historial de cambios por credencial
El sistema SHALL registrar cada modificación de una credencial con fecha y tipo de cambio (creación, edición de campo, cambio de contraseña).

#### Scenario: Registrar cambio de contraseña
- **WHEN** usuario modifica la contraseña de una credencial
- **THEN** se registra un evento "Contraseña cambiada" con la fecha

#### Scenario: Ver historial
- **WHEN** usuario abre el panel de edición de una credencial
- **THEN** se muestra la fecha de creación y última modificación
