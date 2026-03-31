## Context

La sección de credenciales tiene CRUD básico con panel lateral de edición. El generador de contraseñas es decorativo, la barra de fortaleza es estática, no hay filtros ni ordenamiento, ni favoritos, ni auditoría.

## Goals / Non-Goals

**Goals:**
- Generador de contraseñas funcional con opciones configurables
- Evaluación real de fortaleza
- Filtros por categoría y ordenamiento
- Sistema de favoritos
- Auditoría de contraseñas (débiles, duplicadas)
- Empty state con CTA
- Hover preview en lista

**Non-Goals:**
- No cambiar el modelo de almacenamiento (Hive)
- No agregar dependencias externas
- No cambiar otras secciones (Notas, Tareas)

## Decisions

### D1: Generador con Crypto.getRandomValues
**Decisión:** Usar `dart:math` con `Random.secure()` para generación criptográfica.
**Racional:** Sin dependencias externas, seguro, incluido en Dart SDK.

### D2: Fortaleza con scoring simple
**Decisión:** Puntuación 0-100 basada en: longitud (25pts), mayúsculas (15pts), minúsculas (15pts), números (15pts), símbolos (15pts), sin patrones (15pts).
**Racional:** Simple, transparente, sin dependencias.

### D3: Favoritos con campo en VaultItem
**Decisión:** Agregar `isFavorite` al modelo VaultItem.
**Racional:** Persistencia automática en Hive, sin servicio adicional.

### D4: Auditoría en tiempo real
**Decisión:** Calcular auditoría al renderizar VaultView, no almacenar resultados.
**Racional:** Datos siempre actualizados, sin storage extra.

### D5: Filtros como chips en top bar
**Decisión:** Chips de categoría debajo del título, estilo TasksView.
**Racional:** Patrón consistente con la app.

## Risks / Trade-offs

| Riesgo | Mitigación |
|--------|-----------|
| Generador lento con contraseñas muy largas | Limitar a 64 caracteres máximo |
| Auditoría con muchas credenciales | Calcular solo al entrar a la vista |
| Modelo VaultItem cambia (migración) | Hive maneja campos nuevos con valores default |
