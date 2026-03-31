# Arquitectura de DevVault

> Última actualización: 31 de marzo, 2026

## Descripción General

DevVault es una aplicación Flutter desktop (Windows/Linux) de tipo **local-first** para gestión segura de credenciales, notas y tareas. No utiliza backend ni servicios externos; todo se almacena y procesa localmente en la máquina del usuario.

### Principios de Diseño

1. **Local-first**: Todos los datos viven en la máquina del usuario
2. **Encriptación por defecto**: Las credenciales se cifran con AES-256
3. **Estado reactivo**: Riverpod Notifiers como patrón de gestión de estado
4. **UI minimalista**: Stitch Design System inspirado en Notion

## Flujo de Datos

```
┌─────────────────────────────────────────────────────────────┐
│                        UI Layer (Screens)                    │
│  ┌──────────────┐  ┌──────────────┐  ┌────────────────────┐ │
│  │ LockScreen   │  │ Dashboard    │  │ CredentialEditor   │ │
│  │              │  │  ├─ Home     │  │ Panel              │ │
│  │              │  │  ├─ Vault    │  │                    │ │
│  │              │  │  ├─ Notes    │  │ NotionEmptyState   │ │
│  │              │  │  ├─ Tasks    │  │                    │ │
│  │              │  │  └─ Settings │  │                    │ │
│  └──────┬───────┘  └──────┬───────┘  └────────┬───────────┘ │
└─────────┼─────────────────┼───────────────────┼─────────────┘
          │                 │                   │
          ▼                 ▼                   ▼
┌─────────────────────────────────────────────────────────────┐
│                   State Layer (Riverpod)                     │
│  ┌──────────────┐  ┌──────────────┐  ┌────────────────────┐ │
│  │ lockProvider │  │ vaultProvider│  │ noteProvider       │ │
│  │ (bool)       │  │ List<Vault>  │  │ List<Note>         │ │
│  └──────────────┘  └──────────────┘  └────────────────────┘ │
│  ┌──────────────┐  ┌──────────────┐  ┌────────────────────┐ │
│  │ taskProvider │  │settingsProvider│ │securityLogProvider │ │
│  │ List<Task>   │  │ SettingsState│  │ List<SecurityLog>  │ │
│  └──────────────┘  └──────────────┘  └────────────────────┘ │
└────────────────────────┬────────────────────────────────────┘
                         │
                         ▼
┌─────────────────────────────────────────────────────────────┐
│                   Persistence Layer (Hive)                   │
│  ┌──────────────┐  ┌──────────────┐  ┌────────────────────┐ │
│  │ settings box │  │ vault box    │  │ notes box          │ │
│  │ (plaintext)  │  │ (AES-256)    │  │ (plaintext)        │ │
│  └──────────────┘  └──────────────┘  └────────────────────┘ │
│  ┌──────────────┐  ┌────────────────────────────────────┐   │
│  │ tasks box    │  │ SecurityService                    │   │
│  │ (plaintext)  │  │ ┌────────────────────────────────┐ │   │
│  └──────────────┘  │ │ flutter_secure_storage (OS)    │ │   │
│                    │ │   → Hive encryption key (AES)  │ │   │
│                    │ └────────────────────────────────┘ │   │
│                    └────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────┘
```

### Flujo paso a paso

1. **main.dart** inicializa Hive boxes y SecurityService
2. **LockScreen** verifica la contraseña maestra contra settingsProvider
3. Al desbloquear, se muestra **DashboardScreen** con sidebar + top bar + contenido
4. Cada vista (Vault, Notes, Tasks) consume su provider Riverpod
5. Los providers leen/escriben directamente en Hive boxes
6. Las credenciales usan un box encriptado con clave almacenada en flutter_secure_storage

## Modelo de Encriptación

```
┌──────────────────────────────────────────────────────────┐
│                   Encriptación de Credenciales            │
│                                                          │
│  1. Al iniciar la app:                                   │
│     SecurityService._getOrCreateKey()                    │
│       ├── ¿Existe clave en flutter_secure_storage?       │
│       │   ├── Sí → leer y decodificar (base64)           │
│       │   └── No → Hive.generateSecureKey() → guardar    │
│       └── Retornar Uint8List (256-bit AES key)           │
│                                                          │
│  2. Al abrir el box 'vault':                             │
│     Hive.openBox('vault',                                │
│       encryptionCipher: HiveAesCipher(key))              │
│                                                          │
│  3. Todas las operaciones CRUD en vaultProvider:         │
│     Se cifran/descifran transparentemente por Hive       │
│                                                          │
│  4. Otros boxes (settings, notes, tasks):                │
│     Sin encriptación (datos no sensibles)                │
└──────────────────────────────────────────────────────────┘
```

### Componentes de seguridad

| Componente | Función |
|------------|---------|
| `flutter_secure_storage` | Almacena la clave AES en el almacén seguro del SO (Windows Credential Manager / Linux Keyring) |
| `HiveAesCipher` | Cifra/descifra datos del box 'vault' con AES-256 |
| `crypto` | Utilidades criptográficas (generación de claves) |
| Contraseña maestra | Opcional; protege el acceso a la UI, no cifra datos |

## Proveedores Riverpod

### 1. `lockProvider` — `Notifier<bool>`
- **Estado**: `true` = bloqueado, `false` = desbloqueado
- **Métodos**: `lock()`, `unlock()`
- **Uso**: LockScreen, DashboardScreen (botón de bloqueo)

### 2. `vaultProvider` — `Notifier<List<VaultItem>>`
- **Estado**: Lista de credenciales
- **Métodos**: `addItem()`, `updateItem()`, `deleteItem()`
- **Storage**: Hive box `vault` (encriptado AES)

### 3. `noteProvider` — `Notifier<List<Note>>`
- **Estado**: Lista de notas
- **Métodos**: `addNote()`, `updateNote()`, `deleteNote()`
- **Storage**: Hive box `notes`

### 4. `taskProvider` — `Notifier<List<TaskItem>>`
- **Estado**: Lista de tareas
- **Métodos**: `addTask()`, `updateTask()`, `deleteTask()`
- **Storage**: Hive box `tasks`

### 5. `settingsProvider` — `Notifier<SettingsState>`
- **Estado**: `SettingsState` (themeMode, accentColor, hasMasterPassword, masterPassword)
- **Métodos**: `setThemeMode()`, `setAccentColor()`, `setMasterPassword()`, `disableMasterPassword()`
- **Storage**: Hive box `settings`

### 6. `securityLogProvider` — `Notifier<List<SecurityLog>>`
- **Estado**: Lista de eventos de seguridad
- **Métodos**: `addLog(title, message)`
- **Storage**: Solo en memoria (no persistente)

## Pantallas y Navegación

```
┌────────────────────────────────────────────────────────────┐
│  MyApp (ConsumerWidget)                                     │
│  └── MaterialApp (theme: light/dark)                        │
│      └── LockScreen (wrapper)                               │
│          ├── Estado bloqueado: Lock UI                      │
│          └── Estado desbloqueado: DashboardScreen           │
│              ┌────────────────────────────────────────────┐ │
│              │ Sidebar (200px)                            │ │
│              │  ┌────────────────────────────────────┐   │ │
│              │  │ [Logo] DevVault                    │   │ │
│              │  ├────────────────────────────────────┤   │ │
│              │  │ 🏠 Overview                        │   │ │
│              │  │ 🔑 Credenciales                    │   │ │
│              │  │ 📝 Notas                           │   │ │
│              │  │ ✅ Tareas                          │   │ │
│              │  │ ⚙️  Ajustes                        │   │ │
│              │  ├────────────────────────────────────┤   │ │
│              │  │ 🔒 Bloquear                        │   │ │
│              │  └────────────────────────────────────┘   │ │
│              ├────────────────────────────────────────────┤ │
│              │ TopAppBar (64px)                           │ │
│              │  [Search ──────────────]  [+ Nuevo]       │ │
│              ├────────────────────────────────────────────┤ │
│              │ Content Area (dinámico)                    │ │
│              │                                            │ │
│              │  Index 0: HomeOverview (resumen)           │ │
│              │  Index 1: VaultView (credenciales)         │ │
│              │  Index 2: NotesView (notas)                │ │
│              │  Index 3: TasksView (tareas)               │ │
│              │  Index 4: SettingsView (ajustes)           │ │
│              │                                            │ │
│              └────────────────────────────────────────────┘ │
└────────────────────────────────────────────────────────────┘
```

### Flujo de navegación

1. La app inicia con `LockScreen` envolviendo `DashboardScreen`
2. Si no hay contraseña maestra configurada → desbloqueo automático
3. Si hay contraseña → se muestra el formulario de desbloqueo
4. `DashboardScreen` usa `_selectedIndex` (0-4) para cambiar entre vistas
5. No hay navegación con rutas; todo es cambio de widgets en el content area

## Modelo de Datos

### VaultItem
```dart
{
  id: String,           // UUID v4
  title: String,        // Nombre del servicio
  url: String?,         // URL del sitio
  username: String?,    // Usuario/email
  password: String?,    // Contraseña (encriptada en Hive)
  category: String?,    // Categoría (Login, API Key, etc.)
  updatedAt: DateTime,  // Última modificación
  notes: String?        // Notas adicionales
}
```

### Note
```dart
{
  id: String,           // Timestamp ms
  title: String,        // Título de la nota
  content: String,      // Contenido Markdown
  createdAt: DateTime,  // Fecha de creación
  updatedAt: DateTime,  // Última modificación
  tags: List<String>    // Etiquetas
}
```

### TaskItem
```dart
{
  id: String,           // UUID v4
  title: String,        // Título de la tarea
  isCompleted: bool,    // Estado de completado
  isImportant: bool,    // Marcada como importante
  createdAt: DateTime,  // Fecha de creación
  updatedAt: DateTime,  // Última modificación
  dueAt: DateTime?,     // Fecha límite
  notes: String,        // Descripción
  steps: List<TaskStep> // Sub-pasos
}

TaskStep {
  id: String,           // UUID v4
  title: String,        // Título del paso
  isCompleted: bool     // Estado del paso
}
```
