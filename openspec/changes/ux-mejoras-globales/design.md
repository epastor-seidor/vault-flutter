## Context

DevVault tiene funcionalidad sólida pero le falta pulir la UX global: accesos rápidos, atajos, notificaciones y onboarding.

## Goals / Non-Goals

**Goals:** Accesos rápidos top bar, atajos teclado, toast notifications, tour bienvenida.
**Non-Goals:** No cambiar lógica de negocio, no dependencias nuevas, no otras secciones.

## Decisions

### D1: Toast como Overlay global
**Decisión:** Toast se renderiza como Stack overlay en DashboardScreen, controlado por ToastNotifier.
**Racional:** Simple, sin dependencias, consistente en toda la app.

### D2: Tour con FocusOverlay
**Decisión:** Overlay semitransparente con spotlight en cada elemento, flechas y botones Siguiente/Saltar.
**Racional:** Patrón estándar de onboarding, sin librerías externas.

### D3: Atajos con KeyboardListener
**Decisión:** KeyboardListener en el Scaffold raíz de DashboardScreen.
**Racional:** Captura atajos globales sin interferir con TextFields.

### D4: Accesos rápidos como botones en top bar
**Decisión:** 3 botones con icono + label en la barra superior derecha.
**Racional:** Siempre visibles, no requieren descubrir atajos.

## Risks / Trade-offs

| Riesgo | Mitigación |
|--------|-----------|
| Toast interfiere con edición | Auto-dismiss 2s, no bloquea interacción |
| Tour molesto si se repite | Solo primer uso, flag en settings |
| Atajos conflictivos con TextFields | KeyboardListener con skip: true en focus |
