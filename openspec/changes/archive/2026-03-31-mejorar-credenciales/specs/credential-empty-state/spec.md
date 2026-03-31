## ADDED Requirements

### Requirement: Empty state con CTA
El sistema SHALL mostrar un empty state ilustrado cuando no hay credenciales, con un botón para crear la primera credencial.

#### Scenario: Sin credenciales
- **WHEN** el usuario entra a Credenciales y no hay ninguna guardada
- **THEN** se muestra una ilustración con texto "No hay credenciales guardadas" y un botón "+ Crear primera credencial"
