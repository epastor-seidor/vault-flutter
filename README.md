# DevVault

> Bóveda segura de escritorio para credenciales, notas y tareas.

**DevVault** es una aplicación Flutter desktop que te permite gestionar de forma segura tus credenciales (contraseñas), notas en Markdown y tareas. Todos los datos se almacenan localmente con encriptación AES de extremo a extremo. No requiere backend ni conexión a internet.

## Características

- **Gestión de Credenciales** — Almacena logins, contraseñas y URLs con encriptación AES. Copia al portapapeles, genera contraseñas seguras y edita desde un panel lateral deslizante.
- **Notas en Markdown** — Crea y organiza notas con soporte completo de Markdown, imágenes pegadas desde el portapapeles, enlaces clickeables y bloques de código.
- **Gestión de Tareas** — Organiza tareas con estados, prioridades, fechas límite, sub-pasos y filtros (Hoy, Planificadas, Importantes, Completadas).
- **Contraseña Maestra** — Protege el acceso a tu bóveda con una contraseña maestra.
- **Almacenamiento Local** — Todo se guarda en tu máquina con Hive + encriptación AES. Sin nube, sin terceros.
- **Diseño Minimalista** — Interfaz inspirada en Notion con el sistema de diseño "Stitch Design System": tipografía Inter, paleta near-monochrome, micro-animaciones suaves.

## Tech Stack

| Categoría | Tecnología |
|-----------|-----------|
| Framework | Flutter (Material 3) |
| Lenguaje | Dart ^3.11.1 |
| Estado | flutter_riverpod ^3.3.1 |
| Base de datos local | Hive ^2.2.3 + hive_flutter ^1.1.0 |
| Encriptación | flutter_secure_storage ^10.0.0 + crypto ^3.0.7 |
| Tipografía | google_fonts ^8.0.2 (Inter) |
| Iconos | lucide_icons ^0.257.0 |
| Markdown | flutter_markdown ^0.7.7+1 |
| Utilidades | uuid, url_launcher, intl, path_provider, pasteboard |
| Ventana | window_manager ^0.5.1, system_tray ^2.0.3 |

## Instalación

### Requisitos previos

- **Flutter SDK** >= 3.11.1 — [Instalar Flutter](https://docs.flutter.dev/get-started/install)
- **Dart SDK** (incluido con Flutter)
- **Windows 10+** o **Linux** con soporte gráfico

### Pasos

```bash
# 1. Clonar el repositorio
git clone <tu-repo>
cd dev_vault

# 2. Instalar dependencias
flutter pub get

# 3. Verificar configuración
flutter doctor
```

## Ejecución

```bash
# Windows
flutter run -d windows

# Linux
flutter run -d linux

# Modo release (producción)
flutter run --release -d windows
```

### Comandos útiles

```bash
flutter analyze          # Análisis estático de código
flutter build windows    # Compilar para Windows (build/windows/x64/runner/)
flutter build linux      # Compilar para Linux
flutter pub get          # Instalar/actualizar dependencias
flutter clean            # Limpiar build artifacts
```

## Estructura del Proyecto

```
dev_vault/
├── lib/
│   ├── main.dart                      # Punto de entrada
│   ├── screens/
│   │   ├── lock_screen.dart           # Pantalla de bloqueo (contraseña maestra)
│   │   └── dashboard_screen.dart      # Dashboard principal (~3700 líneas)
│   ├── models/
│   │   ├── vault_item.dart            # Modelo de credencial
│   │   ├── note.dart                  # Modelo de nota
│   │   └── task_item.dart             # Modelo de tarea + sub-pasos
│   ├── providers/
│   │   ├── lock_provider.dart         # Estado de bloqueo
│   │   ├── vault_provider.dart        # CRUD credenciales (Hive encriptado)
│   │   ├── note_provider.dart         # CRUD notas
│   │   ├── task_provider.dart         # CRUD tareas
│   │   ├── settings_provider.dart     # Configuración (tema, contraseña)
│   │   └── security_log_provider.dart # Log de seguridad
│   ├── services/
│   │   └── security_service.dart      # Gestión de encriptación
│   ├── theme/
│   │   └── app_theme.dart             # Stitch Design System
│   └── widgets/
│       ├── credential_editor_panel.dart  # Panel lateral de edición
│       └── notion_empty_state.dart       # Estados vacíos reutilizables
├── docs/
│   ├── arquitectura.md                # Documentación de arquitectura
│   ├── guia-desarrollo.md             # Guía para desarrolladores
│   └── guia-usuario.md                # Manual de usuario
├── openspec/                          # Especificaciones de cambios
├── assets/icon/                       # Icono de la aplicación
├── windows/                           # Scaffold plataforma Windows
├── linux/                             # Scaffold plataforma Linux
└── pubspec.yaml                       # Dependencias y configuración
```

## Documentación

| Documento | Descripción |
|-----------|-------------|
| [Arquitectura](docs/arquitectura.md) | Flujo de datos, encriptación, proveedores, pantallas |
| [Guía de Desarrollo](docs/guia-desarrollo.md) | Configuración, convenciones, cómo extender |
| [Guía de Usuario](docs/guia-usuario.md) | Manual completo de uso de la aplicación |

## Atajos de Teclado

| Atajo | Acción |
|-------|--------|
| `Ctrl+F` | Buscar en la sección actual |
| `Ctrl+N` | Crear nueva entrada |
| `Ctrl+L` | Bloquear la bóveda |

## Contribuir

1. Haz fork del repositorio
2. Crea una rama (`git checkout -b feature/nueva-funcionalidad`)
3. Sigue las convenciones en [Guía de Desarrollo](docs/guia-desarrollo.md)
4. Ejecuta `flutter analyze` antes de commit
5. Abre un Pull Request

## Licencia

Privado. Todos los derechos reservados.
