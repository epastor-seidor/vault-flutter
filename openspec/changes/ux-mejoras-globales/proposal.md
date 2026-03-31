## Why

La aplicación carece de accesos rápidos en la barra superior, atajos de teclado funcionales, notificaciones elegantes (usa SnackBars básicos), y no tiene un tour de bienvenida para nuevos usuarios. Esto reduce la eficiencia y la experiencia de primer uso.

## What Changes

- **Accesos rápidos en top bar**: Botones para crear credencial, nota, tarea directamente desde cualquier sección
- **Atajos de teclado funcionales**: Ctrl+N, Ctrl+F, Ctrl+L, Ctrl+E, Delete, Enter, Escape, Ctrl+1-4 para navegación
- **Toast notifications elegantes**: Reemplazar SnackBars por toasts animados tipo Notion con iconos, colores por tipo y auto-dismiss
- **Tour de bienvenida**: Overlay interactivo de 4 pasos que guía al usuario por las secciones principales en el primer uso

## Capabilities

### New Capabilities
- `quick-actions-bar`: Accesos rápidos en la barra superior
- `keyboard-shortcuts`: Atajos de teclado globales funcionales
- `toast-notifications`: Sistema de notificaciones toast elegantes
- `onboarding-tour`: Tour de bienvenida interactivo para primer uso

## Impact

- `lib/screens/dashboard_screen.dart` — Top bar con accesos rápidos, atajos de teclado
- `lib/widgets/toast_notification.dart` — **Nuevo** widget de toast
- `lib/widgets/onboarding_tour.dart` — **Nuevo** widget de tour
- `lib/providers/toast_provider.dart` — **Nuevo** provider para toasts
- `lib/providers/settings_provider.dart` — Agregar campo `hasSeenOnboarding`
- Sin nuevas dependencias
