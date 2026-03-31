## Context

DevVault es una aplicación Flutter desktop para gestión segura de credenciales, notas y tareas. Actualmente cuenta con código funcional pero sin documentación en español. El README es boilerplate genérico de Flutter. No existen guías de arquitectura, desarrollo ni usuario.

**Restricciones:**
- Flutter desktop (Windows/Linux)
- Almacenamiento local con Hive (encriptado AES para credenciales)
- Riverpod para estado
- Diseño "Stitch Design System" (Notion-inspired)
- Sin backend ni servicios externos

## Goals / Non-Goals

**Goals:**
- Documentar completamente el proyecto en español
- Crear README con instalación, estructura y uso
- Crear guía de arquitectura explicando flujo de datos y encriptación
- Crear guía de desarrollo con convenciones y cómo extender
- Crear guía de usuario para cada funcionalidad

**Non-Goals:**
- No se modifica código de la aplicación
- No se agregan dependencias
- No se cambia comportamiento existente
- No se documenta en otros idiomas

## Decisions

### D1: Estructura de documentación en `docs/`
**Decisión:** Crear carpeta `docs/` en la raíz con tres archivos especializados.
**Racional:** Separar por audiencia (usuario vs desarrollador) mantiene cada documento enfocado y legible.
**Alternativas:** Un solo README monolítico → demasiado largo y difícil de navegar.

### D2: README como punto de entrada
**Decisión:** El README.md en la raíz será la puerta de entrada con enlaces a los documentos de `docs/`.
**Racional:** Es la convención estándar en GitHub y repositorios de código.

### D3: Documentación en Markdown
**Decisión:** Todos los documentos en Markdown plano.
**Racional:** Compatible con GitHub, legible en terminal, versionable con git, sin herramientas externas.

### D4: Incluir diagramas ASCII para arquitectura
**Decisión:** Usar diagramas en texto/ASCII para flujos de datos y estructura.
**Racional:** No requiere herramientas de diagramas externas, se renderiza en cualquier visor Markdown.

## Risks / Trade-offs

| Riesgo | Mitigación |
|--------|-----------|
| Documentación se desactualiza con cambios de código | Incluir nota en cada doc indicando última actualización y vincular a archivos fuente |
| Demasiado detalle técnico en guía de usuario | Separar claramente docs para usuarios vs desarrolladores |
| README muy largo | Usar el README como índice con enlaces a docs especializados |

## Migration Plan

No aplica. Se crean archivos nuevos sin modificar código existente.

## Open Questions

Ninguna.
