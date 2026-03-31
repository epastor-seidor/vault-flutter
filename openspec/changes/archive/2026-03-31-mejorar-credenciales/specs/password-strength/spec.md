## ADDED Requirements

### Requirement: Evaluación de fortaleza de contraseña
El sistema SHALL evaluar la fortaleza de la contraseña actual en tiempo real usando un scoring de 0-100 basado en longitud, variedad de caracteres y ausencia de patrones comunes.

#### Scenario: Contraseña débil
- **WHEN** la contraseña tiene menos de 8 caracteres
- **THEN** el indicador muestra fortaleza baja (0-33) en color rojo

#### Scenario: Contraseña fuerte
- **WHEN** la contraseña tiene 16+ caracteres con mayúsculas, minúsculas, números y símbolos
- **THEN** el indicador muestra fortaleza alta (80-100) en color verde

#### Scenario: Contraseña con patrón común
- **WHEN** la contraseña contiene "123456", "password" o "qwerty"
- **THEN** la puntuación se reduce al menos 20 puntos
