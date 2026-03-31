## ADDED Requirements

### Requirement: Generador de contraseñas
El sistema SHALL generar contraseñas aleatorias criptográficamente seguras con opciones configurables de longitud (8-64), inclusión de mayúsculas, minúsculas, números y símbolos especiales.

#### Scenario: Generar contraseña por defecto
- **WHEN** usuario hace clic en "GENERAR SEGURA" sin cambiar opciones
- **THEN** se genera una contraseña de 16 caracteres con mayúsculas, minúsculas, números y símbolos

#### Scenario: Generar con longitud personalizada
- **WHEN** usuario ajusta la longitud a 24 y genera
- **THEN** la contraseña generada tiene exactamente 24 caracteres

#### Scenario: Generar solo números
- **WHEN** usuario desactiva letras y símbolos, dejando solo números
- **THEN** la contraseña generada contiene solo dígitos
