# Guía de Usuario

> Última actualización: 31 de March, 2026

Bienvenido a DevVault. Esta guía te explica cómo usar cada funcionalidad de la aplicación.

## Introducción

DevVault es tu bóveda personal de escritorio para guardar de forma segura:

- **Credenciales**: Contraseñas, logins y claves de API
- **Notas**: Ideas, documentación, información en formato Markdown
- **Tareas**: Pendientes con fechas, prioridades y sub-pasos

Todo se almacena localmente en tu computadora. No se envía nada a internet.

## Pantalla de Bloqueo

Al abrir DevVault, verás la pantalla de bloqueo.

### Si no tienes contraseña maestra

La app se desbloquea automáticamente y accedes directamente al dashboard.

### Si configuraste contraseña maestra

1. Verás un campo que dice **CONTRASEÑA MAESTRA**
2. Escribe tu contraseña
3. Presiona **Desbloquear** o la tecla `Enter`
4. Si la contraseña es incorrecta, verás un mensaje de error

### Olvidé mi contraseña

Si olvidaste tu contraseña maestra, no hay forma de recuperarla (por diseño de seguridad). Los datos permanecen en tu máquina pero no podrás acceder a las credenciales encriptadas.

## Credenciales

La sección de credenciales te permite gestionar todos tus logins y contraseñas.

### Ver credenciales

1. Haz clic en **Credenciales** en la barra lateral
2. Verás una tabla con: Sitio/Servicio, Usuario, Contraseña, URL y Acciones
3. Puedes alternar entre vista **lista** y vista **cuadrícula** usando los botones en la esquina superior derecha

### Crear una credencial

1. Haz clic en el botón **+ Nuevo** en la barra superior
2. Selecciona **Credencial**
3. Completa los campos:
   - **Nombre del servicio** (ej: "Google", "GitHub")
   - **Usuario/Email**
   - **Contraseña**
   - **URL** (opcional)
   - **Categoría** (opcional)
4. Haz clic en **Guardar**

### Editar una credencial

1. Haz clic en el icono de **editar** (lápiz) en la fila de la credencial
2. Se abrirá un **panel lateral deslizante** con todos los campos
3. Modifica lo que necesites
4. Haz clic en **Guardar Cambios**

El panel lateral incluye:
- Logo/identidad del servicio
- Campos de usuario, contraseña y URL
- Botón para **copiar contraseña** al portapapeles
- Botón para **generar contraseña segura**
- Barra de fortaleza de contraseña
- Notas adicionales
- Metadata (fecha de creación y última modificación)

### Copiar contraseña

Haz clic en el icono de **ojo** para mostrar la contraseña, luego en el icono de **copiar** para copiarla al portapapeles.

### Eliminar una credencial

1. Haz clic en el icono de **papelera** en la fila
2. La credencial se elimina inmediatamente

## Notas

Las notas te permiten guardar información en formato Markdown.

### Crear una nota

1. Haz clic en **Notas** en la barra lateral
2. Haz clic en el botón **+** en la esquina superior izquierda del panel de notas
3. Escribe el **título** y el **contenido** en Markdown
4. Haz clic en **Guardar**

### Ver y leer notas

1. La vista de notas tiene **dos paneles**:
   - **Izquierda**: Lista de notas recientes
   - **Derecha**: Contenido de la nota seleccionada
2. Haz clic en una nota de la lista para ver su contenido

### Formato Markdown soportado

- **Negrita**: `**texto**`
- *Cursiva*: `*texto*`
- `Código`: `` `código` ``
- Bloques de código: ``` ```código``` ```
- [Enlaces](https://ejemplo.com): `[texto](url)`
- Listas: `- elemento`
- Citas: `> texto citado`
- Imágenes: `![alt](ruta)`

### Pegar imágenes

Puedes pegar imágenes directamente desde el portapapeles:
1. Copia una imagen (Ctrl+C en cualquier imagen)
2. En el editor de notas, haz clic en **Pegar imagen**
3. La imagen se inserta como Markdown en el contenido

### Editar una nota

1. Abre la nota
2. Haz clic en **Editar** en la parte inferior del contenido
3. Modifica título o contenido
4. Haz clic en **Guardar**

### Eliminar una nota

Haz clic en **Eliminar** en la parte inferior del contenido de la nota.

## Tareas

El gestor de tareas te permite organizar tu trabajo con filtros y sub-pasos.

### Crear una tarea

1. Haz clic en **Tareas** en la barra lateral
2. Haz clic en el botón **+** en la esquina superior izquierda
3. Completa:
   - **Título de la tarea**
   - **Descripción** (opcional)
   - **Marcar como importante** (estrella)
   - **Fecha límite** (opcional)
4. Haz clic en **Guardar**

### Filtros de tareas

En la parte superior de la lista de tareas puedes filtrar por:

| Filtro | Muestra |
|--------|---------|
| **All** | Todas las tareas |
| **Today** | Tareas que vencen hoy |
| **Planned** | Tareas con fecha límite |
| **Important** | Tareas marcadas como importantes |
| **Completed** | Tareas completadas |

### Completar una tarea

Haz clic en el **círculo** junto al título de la tarea para marcarla como completada. El título se tacha y el círculo se vuelve verde.

### Sub-pasos

Cada tarea puede tener sub-pasos:
1. Abre la tarea seleccionándola
2. En la sección **Pasos**, escribe un nuevo paso y presiona `Enter` o clic en la flecha
3. Marca pasos individuales como completados
4. Elimina pasos con el icono de papelera

### Editar una tarea

1. Selecciona la tarea
2. Haz clic en el icono de **editar** (lápiz)
3. Modifica los campos
4. Haz clic en **Guardar**

## Ajustes

Accede a **Ajustes** desde la barra lateral.

### Modo de Tema

Puedes elegir entre:
- **Claro**: Tema con fondo blanco y texto oscuro
- **Oscuro**: Tema con fondo oscuro y texto claro

### Contraseña Maestra

Para activar la protección con contraseña:
1. Ve a **Ajustes**
2. En **Contraseña Maestra**, activa el interruptor
3. Escribe tu contraseña deseada
4. Haz clic en **Guardar**

Para desactivarla:
1. Ve a **Ajustes**
2. Desactiva el interruptor de **Contraseña Maestra**

> **Importante**: Si activas la contraseña maestra y la olvidas, no podrás recuperar tus credenciales encriptadas.

## Atajos de Teclado

| Atajo | Acción |
|-------|--------|
| `Ctrl+F` | Enfocar la barra de búsqueda |
| `Ctrl+N` | Crear nueva entrada (depende de la sección actual) |
| `Ctrl+L` | Bloquear la bóveda inmediatamente |

## Preguntas Frecuentes

### ¿Mis datos están seguros?

Sí. Las credenciales se almacenan con encriptación AES-256. La clave de encriptación se guarda en el almacén seguro de tu sistema operativo. Sin embargo, si activas la contraseña maestra y la olvidas, no hay forma de recuperar los datos.

### ¿Puedo usar DevVault en múltiples computadoras?

Actualmente los datos son locales. Para sincronizar entre dispositivos necesitarías copiar manualmente los archivos de Hive.

### ¿Qué pasa si desinstalo la app?

Los datos de Hive permanecen en tu sistema. Si reinstalas, podrás acceder a ellos.

### ¿Puedo exportar mis datos?

Actualmente no hay función de exportación. Los datos se almacenan en archivos Hive en tu sistema.
