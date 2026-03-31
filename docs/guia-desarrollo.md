# Guía de Desarrollo

> Última actualización: 31 de marzo, 2026

Esta guía está dirigida a desarrolladores que quieren contribuir o extender DevVault.

## Requisitos Previos

- **Flutter SDK** >= 3.11.1
- **Dart SDK** (incluido con Flutter)
- **Git** para control de versiones
- **Editor**: VS Code (con extensiones Flutter/Dart) o Android Studio
- **Plataforma**: Windows 10+ o Linux con soporte gráfico

## Configuración del Entorno

### 1. Instalar Flutter

```bash
# Windows (con Chocolatey)
choco install flutter

# Linux (snap)
sudo snap install flutter --classic

# O descarga manual: https://docs.flutter.dev/get-started/install
```

### 2. Verificar instalación

```bash
flutter doctor
```

Asegúrate de que la plataforma objetivo (Windows/Linux) muestra check verde.

### 3. Clonar y configurar

```bash
git clone <tu-repo>
cd dev_vault
flutter pub get
```

### 4. Ejecutar en modo debug

```bash
flutter run -d windows    # Windows
flutter run -d linux      # Linux
```

## Comandos Útiles

| Comando | Descripción |
|---------|-------------|
| `flutter run -d windows` | Ejecutar en Windows debug |
| `flutter run --release -d windows` | Ejecutar en modo release |
| `flutter analyze` | Análisis estático (lint + type check) |
| `flutter build windows` | Compilar ejecutable Windows |
| `flutter build linux` | Compilar ejecutable Linux |
| `flutter pub get` | Instalar dependencias |
| `flutter pub upgrade` | Actualizar dependencias |
| `flutter clean` | Limpiar build artifacts |
| `flutter test` | Ejecutar tests |

## Convenciones de Código

### Nomenclatura

- **Archivos**: `snake_case.dart` (ej: `vault_item.dart`)
- **Clases**: `PascalCase` (ej: `VaultItem`, `LockScreen`)
- **Variables/funciones**: `camelCase` (ej: `addItem`, `isLocked`)
- **Constantes**: `camelCase` con `_` prefix para privadas (ej: `_uuid`)
- **Providers**: `nombreProvider` (ej: `vaultProvider`, `lockProvider`)

### Estructura de archivos

```
lib/
├── models/       # Clases de datos puras (sin UI)
├── providers/    # Estado con Riverpod Notifiers
├── screens/      # Pantallas principales
├── services/     # Lógica de negocio/servicios
├── theme/        # Tokens de diseño y ThemeData
└── widgets/      # Widgets reutilizables
```

### Estilo

- Usar `GoogleFonts.inter` para toda la tipografía
- Usar `LucideIcons` para iconos
- Colores desde `AppTheme` (no hardcodear)
- Preferir `.withValues(alpha: x)` sobre `.withOpacity(x)`
- Widgets stateless siempre que sea posible
- Usar `ConsumerWidget` / `ConsumerStatefulWidget` de Riverpod

### Patrones de estado

Todos los providers siguen el patrón Riverpod Notifier:

```dart
class MiNotifier extends Notifier<List<MiModelo>> {
  @override
  List<MiModelo> build() {
    final box = Hive.box('mi_box');
    // Cargar estado inicial desde Hive
  }

  late final _box = Hive.box('mi_box');

  Future<void> agregar(MiModelo item) async {
    await _box.put(item.id, item.toMap());
    state = [...state, item];
  }

  Future<void> actualizar(MiModelo item) async {
    await _box.put(item.id, item.toMap());
    state = [
      for (final i in state)
        if (i.id == item.id) item else i
    ];
  }

  Future<void> eliminar(String id) async {
    await _box.delete(id);
    state = state.where((i) => i.id != id).toList();
  }
}

final miProvider = NotifierProvider<MiNotifier, List<MiModelo>>(() {
  return MiNotifier();
});
```

## Cómo Agregar un Nuevo Provider

### Paso 1: Crear el modelo (`lib/models/mi_modelo.dart`)

```dart
class MiModelo {
  final String id;
  final String nombre;
  final DateTime createdAt;

  MiModelo({
    required this.id,
    required this.nombre,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nombre': nombre,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory MiModelo.fromMap(Map<dynamic, dynamic> map) {
    return MiModelo(
      id: map['id'],
      nombre: map['nombre'],
      createdAt: DateTime.parse(map['createdAt']),
    );
  }

  MiModelo copyWith({String? nombre}) {
    return MiModelo(
      id: id,
      nombre: nombre ?? this.nombre,
      createdAt: createdAt,
    );
  }
}
```

### Paso 2: Crear el provider (`lib/providers/mi_provider.dart`)

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:dev_vault/models/mi_modelo.dart';
import 'package:uuid/uuid.dart';

class MiNotifier extends Notifier<List<MiModelo>> {
  @override
  List<MiModelo> build() {
    final box = Hive.box('mi_box');
    return box.values
        .map((item) => MiModelo.fromMap(Map<String, dynamic>.from(item)))
        .toList();
  }

  late final _box = Hive.box('mi_box');

  Future<void> add(MiModelo item) async {
    await _box.put(item.id, item.toMap());
    state = [...state, item];
  }

  Future<void> update(MiModelo item) async {
    await _box.put(item.id, item.toMap());
    state = [
      for (final i in state)
        if (i.id == item.id) item else i
    ];
  }

  Future<void> delete(String id) async {
    await _box.delete(id);
    state = state.where((i) => i.id != id).toList();
  }
}

final miProvider = NotifierProvider<MiNotifier, List<MiModelo>>(() {
  return MiNotifier();
});
```

### Paso 3: Registrar el Hive box en `main.dart`

```dart
// En main(), antes de runApp:
await Hive.openBox('mi_box');
// Si necesita encriptación:
// await SecurityService.openEncryptedBox('mi_box');
```

### Paso 4: Usar en una pantalla

```dart
class MiVista extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final items = ref.watch(miProvider);
    return ListView.builder(
      itemCount: items.length,
      itemBuilder: (ctx, i) => Text(items[i].nombre),
    );
  }
}
```

## Cómo Agregar una Nueva Pantalla

### Paso 1: Crear el archivo (`lib/screens/mi_pantalla.dart`)

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:dev_vault/theme/app_theme.dart';

class MiPantalla extends ConsumerWidget {
  const MiPantalla({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPrimary = isDark ? AppTheme.darkOnSurface : AppTheme.stOnSurface;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Mi Pantalla',
            style: GoogleFonts.inter(
              fontSize: 28,
              fontWeight: FontWeight.w600,
              color: textPrimary,
            ),
          ),
          // ... contenido
        ],
      ),
    );
  }
}
```

### Paso 2: Agregar al Dashboard

En `dashboard_screen.dart`, agrega la pantalla al `_selectedIndex` switch:

```dart
Widget _buildContent(int index) {
  return switch (index) {
    0 => const HomeOverview(),
    1 => VaultView(globalQuery: _searchQuery),
    2 => NotesView(globalQuery: _searchQuery),
    3 => TasksView(globalQuery: _searchQuery),
    4 => const SettingsView(),
    5 => const MiPantalla(),  // <-- Nueva pantalla
    _ => const HomeOverview(),
  };
}
```

Y agrega el item en el sidebar.

## Cómo Agregar un Nuevo Modelo

Sigue el patrón de los modelos existentes:

1. Clase inmutable con campos `final`
2. Constructor con parámetros `required`
3. Método `toMap()` para serialización Hive
4. Factory `fromMap()` para deserialización
5. Método `copyWith()` para actualizaciones inmutables

## Buenas Prácticas de Seguridad

1. **Nunca hardcodear secretos**: No incluyas API keys, contraseñas ni tokens en el código
2. **Datos sensibles solo en Hive encriptado**: Usa `SecurityService.openEncryptedBox()` para datos sensibles
3. **flutter_secure_storage para claves**: La clave de encriptación de Hive se almacena en el almacén seguro del SO
4. **No loguear datos sensibles**: Evita `print()` o `debugPrint()` con contraseñas o datos personales
5. **Validar entrada del usuario**: Sanitiza inputs antes de almacenar
6. **Contraseña maestra opcional pero recomendada**: Anima a los usuarios a configurarla
7. **No enviar datos por red**: La app es local-first; no hay llamadas HTTP externas

## Testing

```bash
# Ejecutar todos los tests
flutter test

# Ejecutar un archivo específico
flutter test test/mi_test.dart

# Con coverage
flutter test --coverage
```

## Empaquetado

### Windows (MSIX)

```bash
flutter pub run msix:create
# Output: build/windows/x64/runner/Release/dev_vault.msix
```

Configuración en `pubspec.yaml` bajo `msix_config:`.

### Windows (ejecutable)

```bash
flutter build windows --release
# Output: build/windows/x64/runner/Release/dev_vault.exe
```
