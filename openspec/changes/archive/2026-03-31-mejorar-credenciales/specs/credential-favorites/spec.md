## ADDED Requirements

### Requirement: Favoritos en credenciales
El sistema SHALL permitir marcar credenciales como favoritas para acceso rápido. Las favoritas se muestran primero en la lista.

#### Scenario: Marcar como favorito
- **WHEN** usuario hace clic en la estrella de una credencial
- **THEN** la credencial se marca como favorita y aparece primero en la lista

#### Scenario: Filtrar solo favoritos
- **WHEN** usuario activa el filtro de favoritos
- **THEN** solo se muestran las credenciales marcadas como favoritas
