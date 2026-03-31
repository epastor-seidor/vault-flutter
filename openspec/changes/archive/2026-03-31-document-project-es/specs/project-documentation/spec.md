## ADDED Requirements

### Requirement: README en español con información completa del proyecto
El archivo README.md en la raíz del proyecto SHALL contener en español: descripción del proyecto, características principales, tech stack, instrucciones de instalación, instrucciones de ejecución, estructura de directorios, y enlaces a documentación adicional en `docs/`.

#### Scenario: Desarrollador lee el README por primera vez
- **WHEN** un desarrollador abre el README.md del proyecto
- **THEN** encuentra una descripción clara de qué es DevVault, para qué sirve, y cómo empezar

#### Scenario: Usuario busca instrucciones de instalación
- **WHEN** un usuario busca cómo instalar DevVault
- **THEN** el README contiene pasos claros de instalación para Windows y Linux

### Requirement: Documento de arquitectura en docs/arquitectura.md
El archivo docs/arquitectura.md SHALL describir en español: la arquitectura general de la aplicación, el flujo de datos entre componentes, el modelo de encriptación (Hive + flutter_secure_storage), la estructura de proveedores Riverpod, y el diseño de pantallas con diagramas.

#### Scenario: Desarrollador necesita entender la arquitectura
- **WHEN** un desarrollador lee docs/arquitectura.md
- **THEN** comprende cómo se organizan los datos, cómo funciona la encriptación y cómo interactúan los componentes

#### Scenario: Nuevo colaborador revisa el flujo de datos
- **WHEN** alguien consulta el flujo de datos
- **THEN** el documento muestra el camino desde Hive boxes hasta los widgets UI vía Riverpod providers

### Requirement: Guía de desarrollo en docs/guia-desarrollo.md
El archivo docs/guia-desarrollo.md SHALL contener en español: requisitos previos (Flutter SDK, Dart), configuración del entorno, comandos útiles (run, build, analyze), convenciones de código, estructura de archivos, cómo agregar nuevas pantallas/providers/modelos, y buenas prácticas de seguridad.

#### Scenario: Desarrollador configura el entorno por primera vez
- **WHEN** un desarrollador sigue la guía de desarrollo
- **THEN** puede configurar Flutter, instalar dependencias y ejecutar la app exitosamente

#### Scenario: Desarrollador quiere agregar una nueva funcionalidad
- **WHEN** alguien necesita crear un nuevo provider o pantalla
- **THEN** la guía explica el patrón a seguir con ejemplos de código

### Requirement: Guía de usuario en docs/guia-usuario.md
El archivo docs/guia-usuario.md SHALL explicar en español: cómo usar la pantalla de bloqueo con contraseña maestra, cómo gestionar credenciales (crear, editar, eliminar, copiar), cómo usar el editor de notas con Markdown, cómo gestionar tareas con filtros, y cómo configurar ajustes de tema y seguridad.

#### Scenario: Usuario quiere aprender a usar la app
- **WHEN** un usuario lee la guía de usuario
- **THEN** entiende cómo usar cada sección de DevVault: credenciales, notas, tareas y ajustes

#### Scenario: Usuario configura su contraseña maestra
- **WHEN** alguien quiere activar la protección con contraseña
- **THEN** la guía explica paso a paso cómo configurar la contraseña maestra desde Ajustes
