## ADDED Requirements

### Requirement: Filtros por categoría
El sistema SHALL permitir filtrar credenciales por categoría: Todas, Login, API Key, Database, Email, Otros.

#### Scenario: Filtrar por Login
- **WHEN** usuario selecciona el filtro "Login"
- **THEN** solo se muestran credenciales con categoría Login

#### Scenario: Sin resultados en filtro
- **WHEN** no hay credenciales en la categoría seleccionada
- **THEN** se muestra un mensaje "No hay credenciales en esta categoría"

### Requirement: Ordenamiento de credenciales
El sistema SHALL permitir ordenar credenciales por nombre (A-Z, Z-A), fecha de modificación, y categoría.

#### Scenario: Ordenar por nombre A-Z
- **WHEN** usuario selecciona orden "Nombre A-Z"
- **THEN** las credenciales se muestran ordenadas alfabéticamente
