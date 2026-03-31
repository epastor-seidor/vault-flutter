## ADDED Requirements

### Requirement: Auditoría de contraseñas
El sistema SHALL analizar todas las credenciales y detectar: contraseñas débiles (menos de 8 caracteres), contraseñas duplicadas (mismo valor), y calcular un puntaje de seguridad general.

#### Scenario: Detectar contraseñas débiles
- **WHEN** existen credenciales con contraseñas de menos de 8 caracteres
- **THEN** el sistema las lista en la sección de auditoría como "débiles"

#### Scenario: Detectar contraseñas duplicadas
- **WHEN** dos o más credenciales comparten la misma contraseña
- **THEN** el sistema las agrupa y muestra como "duplicadas"

#### Scenario: Mostrar puntaje de seguridad
- **WHEN** usuario abre la sección de credenciales
- **THEN** se muestra un puntaje general de seguridad (0-100%) basado en la calidad de todas las contraseñas
