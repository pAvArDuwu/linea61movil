# Flujo del Sistema - Línea 61

## Arquitectura General

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                              USUARIOS                                      │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐  │
│  │ Conductor    │  │ Administrador│  │Fiscalizador  │  │ Propietario  │  │
│  │ (App Móvil)  │  │ (Panel Web)  │  │ (Panel Web)  │  │ (Panel Web)  │  │
│  └──────┬───────┘  └──────┬───────┘  └──────┬───────┘  └──────┬───────┘  │
└─────────┼──────────────────┼──────────────────┼──────────────────┼─────────┘
          │                  │                  │                  │
          ▼                  ▼                  ▼                  ▼
┌─────────────────┐  ┌──────────────────────────────────────────────────────┐
│  linea61_app    │  │              linea57_control (Laravel)               │
│  (App Flutter)  │  │  ┌────────────────────────────────────────────────┐  │
│                 │  │  │  Panel Web (Blade + Tailwind)                  │  │
│  - Provider     │  │  │  - Dashboard                                  │  │
│  - MVVM         │  │  │  - Gestión de recursos                        │  │
│  - Token Bearer │  │  │  - Monitoreo en tiempo real                   │  │
│                 │  │  │  - Control de recorridos                      │  │
│                 │  │  └────────────────────────────────────────────────┘  │
│                 │  │  ┌────────────────────────────────────────────────┐  │
│                 │  │  │  API REST (Laravel Sanctum)                    │  │
│                 │  │  │  - /api/login                                 │  │
│                 │  │  │  - /api/conductores                           │  │
│                 │  │  │  - /api/mis/asignaciones                     │  │
│                 │  │  │  - /api/mis/asignaciones/{id}/ubicaciones    │  │
│                 │  │  └────────────────────────────────────────────────┘  │
└────────┬────────┘  └──────────────────────┬───────────────────────────────┘
         │                                  │
         │         ┌────────────────┐       │
         └────────▶│    ApiDart     │◀──────┘
                   │ (Servidor Dart)│
                   │  - Shelf       │
                   │  - Token Base64│
                   └───────┬────────┘
                           │
                           ▼
                   ┌───────────────┐
                   │     MySQL     │
                   │   linea61     │
                   │               │
                   │ - users       │
                   │ - conductores │
                   │ - turnos      │
                   │ - asignacion_ │
                   │   turnos      │
                   │ - seguimiento_│
                   │   gps         │
                   │ - rutas       │
                   │ - paradas     │
                   │ - micros      │
                   └───────────────┘
```

---

## 1. Flujo de Autenticación (Login)

### Opción A: vía ApiDart (Actual)

```mermaid
sequenceDiagram
    participant U as Usuario
    participant App as App Flutter
    participant API as ApiDart
    participant DB as MySQL

    U->>App: Ingresa email y contraseña
    App->>API: POST /api/login<br/>{email, password, device_name}
    API->>DB: SELECT * FROM users WHERE email = ?
    DB-->>API: User record
    API->>API: Generar token (Base64)
    API-->>App: {token, user_data}
    App->>App: Guardar token en FlutterSecureStorage
    App-->>U: Redirigir a /dashboard
```

### Opción B: vía Laravel (linea57_control)

```mermaid
sequenceDiagram
    participant U as Usuario
    participant App as App Flutter
    participant Laravel as linea57_control
    participant DB as MySQL

    U->>App: Ingresa email y contraseña
    App->>Laravel: POST /api/login<br/>{email, password, device_name}
    Laravel->>DB: SELECT * FROM users WHERE email = ?
    DB-->>Laravel: User record
    Laravel->>Laravel: Crear token Sanctum
    Laravel-->>App: {access_token, token_type, user}
    App->>App: Guardar token en FlutterSecureStorage
    App-->>U: Redirigir a /dashboard
```

---

## 2. Flujo de Asignación de Turnos

```mermaid
sequenceDiagram
    participant Admin as Administrador
    participant Web as Panel Laravel
    participant API as ApiDart/Laravel
    participant DB as MySQL
    participant C as Conductor
    participant App as App Flutter

    Note over Admin,DB: Fase 1: Crear Recursos (desde Panel Web)
    Admin->>Web: Crear Turno (horario)
    Web->>API: POST /api/turnos/
    API->>DB: INSERT INTO turnos
    DB-->>API: OK

    Admin->>Web: Crear Asignación
    Web->>API: POST /api/asignaciones/<br/>{turno_id, ruta_id, micro_id, conductor_id, fecha}
    API->>DB: INSERT INTO asignacion_turnos
    DB-->>API: OK

    Note over C,DB: Fase 2: Conductor Inicia Turno (desde App Flutter)
    C->>App: Ver "Mis Asignaciones"
    App->>API: GET /api/mis/asignaciones?conductor_id=X
    API->>DB: SELECT * FROM asignacion_turnos<br/>WHERE conductor_id = ?
    DB-->>API: Lista de asignaciones
    API-->>App: [{id, turno, ruta, micro, fecha, estado}]

    C->>App: Presiona "Iniciar Turno"
    App->>API: POST /api/mis/asignaciones/{id}/iniciar
    API->>DB: UPDATE asignacion_turnos<br/>SET estado = 'en_curso',<br/>hora_salida = NOW()
    DB-->>API: OK

    Note over C,DB: Fase 3: Seguimiento GPS
    loop Cada 10 segundos
        C->>App: App envía ubicación GPS
        App->>API: POST /api/mis/asignaciones/{id}/ubicaciones<br/>{lat, lng, timestamp}
        API->>DB: INSERT INTO seguimiento_gps
        DB-->>API: OK
    end

    Note over C,DB: Fase 4: Finalizar Turno
    C->>App: Presiona "Finalizar Turno"
    App->>API: POST /api/mis/asignaciones/{id}/finalizar
    API->>DB: UPDATE asignacion_turnos<br/>SET estado = 'completado',<br/>hora_llegada = NOW()
    DB-->>API: OK
```

---

## 3. Flujo de Registro de Usuarios (FALTA IMPLEMENTAR)

> **ESTADO:** No existe ni en la app Flutter ni en el backend ApiDart.
> Los usuarios se crean directamente en la base de datos.

```mermaid
sequenceDiagram
    participant U as Nuevo Usuario
    participant App as App Flutter
    participant API as ApiDart/Laravel
    participant DB as MySQL

    Note over U,DB: Flujo propuesto para implementar

    U->>App: Completa formulario de registro<br/>(nombre, email, password, rol)
    App->>API: POST /api/register<br/>{nombre, email, password, rol}
    API->>API: Validar datos únicos
    API->>DB: INSERT INTO users<br/>(nombre, email, password_hash, rol)
    DB-->>API: OK
    API-->>App: {token, user_data}
    App-->>U: Registro exitoso
```

---

## 4. Flujo de Sincronización Offline (GPS)

```mermaid
sequenceDiagram
    participant C as Conductor
    participant App as App Flutter
    participant API as ApiDart/Laravel
    participant DB as MySQL

    Note over C,DB: Cuando no hay conexión a internet

    C->>App: App detecta sin conexión
    App->>App: Almacenar ubicaciones en<br/>almacenamiento local (SQLite/Archivo)

    Note over C,DB: Cuando se recupera la conexión

    C->>App: App detecta conexión restaurada
    App->>API: POST /api/mis/ubicaciones/sincronizar<br/>[{lat, lng, timestamp}, ...]
    API->>DB: INSERT INTO seguimiento_gps<br/>(batch insert)
    DB-->>API: OK
    API-->>App: {sincronizadas: N}
    App->>App: Limpiar ubicaciones locales sincronizadas
```

---

## 5. Flujo Completo del Sistema (Vista General)

```mermaid
flowchart TD
    subgraph Usuarios["Usuarios"]
        U1[Conductor<br/>App Móvil]
        U2[Administrador<br/>Panel Web]
        U3[Fiscalizador<br/>Panel Web]
        U4[Propietario<br/>Panel Web]
    end

    subgraph App_Flutter["App Flutter (linea61_app)"]
        A[Login] --> B[Dashboard]
        B --> C[Conductores]
        B --> D[Turnos]
        B --> E[Asignación de Turnos]
        B --> F[Rutas]
        B --> G[Micros]
        B --> H[Paradas]
        
        E --> E1[Ver Mis Asignaciones]
        E1 --> E2[Iniciar Turno]
        E2 --> E3[Enviar GPS cada 10s]
        E3 --> E4[Finalizar Turno]
    end

    subgraph Panel_Web["Panel Web (linea57_control - Laravel)"]
        W1[Dashboard]
        W2[Gestión de Recursos]
        W3[Monitoreo en Tiempo Real]
        W4[Control de Recorridos]
        W5[Asignación de Turnos]
    end

    subgraph Backends["Backends"]
        ApiDart[ApiDart<br/>Servidor Dart<br/>Token Base64]
        Laravel[Laravel API<br/>Sanctum Token]
    end

    subgraph DB["Base de Datos MySQL (linea61)"]
        O[(users)]
        P[(turnos)]
        Q[(asignacion_turnos)]
        R[(seguimiento_gps)]
        S[(conductores)]
        T[(micros)]
        U[(rutas)]
        V[(paradas)]
    end

    U1 -->|Usa| App_Flutter
    U2 -->|Usa| Panel_Web
    U3 -->|Usa| Panel_Web
    U4 -->|Usa| Panel_Web

    App_Flutter -->|HTTP/JSON| ApiDart
    Panel_Web -->|HTTP/JSON| Laravel

    ApiDart -->|MySQL| DB
    Laravel -->|MySQL| DB
```

---

## 6. Comparación de Backends

| Característica | ApiDart (Dart/Shelf) | linea57_control (Laravel) |
|----------------|----------------------|---------------------------|
| **Lenguaje** | Dart | PHP 8.3+ |
| **Framework** | Shelf | Laravel 13 |
| **Token** | Base64 simple | Sanctum (Bearer) |
| **Base de datos** | MySQL `linea61` | MySQL `linea61` |
| **Panel Web** | ❌ No tiene | ✅ Blade + Tailwind |
| **API REST** | ✅ Básica | ✅ Completa |
| **Roles/Permisos** | ⚠️ Básico | ✅ Spatie Permission |
| **Documentación API** | ❌ No tiene | ✅ Swagger/OpenAPI |
| **Tests** | ⚠️ Básicos | ✅ PHPUnit + Feature |
| **Migraciones** | ✅ SQL files | ✅ Laravel Migrations |
| **Validación** | ⚠️ Manual | ✅ Form Requests |

---

## 7. Estado Actual vs. Funcionalidades Faltantes

| Funcionalidad | App Flutter | ApiDart | Laravel | Estado |
|---------------|-------------|---------|---------|--------|
| Login | ✅ | ✅ | ✅ | Completo |
| Logout | ✅ | ✅ | ✅ | Completo |
| Registro de usuarios | ❌ | ❌ | ❌ | **FALTA** |
| Listar conductores | ✅ | ✅ | ✅ | Completo |
| Crear conductores | ✅ | ✅ | ✅ | Completo |
| Listar turnos | ✅ | ✅ | ✅ | Completo |
| Crear turnos | ✅ | ✅ | ✅ | Completo |
| Asignación de turnos | ✅ | ✅ | ✅ | Completo |
| Iniciar turno | ✅ | ✅ | ✅ | Completo |
| Finalizar turno | ✅ | ✅ | ✅ | Completo |
| Seguimiento GPS | ✅ | ✅ | ✅ | Completo |
| Sincronización offline | ✅ | ✅ | ✅ | Completo |
| Monitoreo en tiempo real | ❌ | ❌ | ✅ | Solo Laravel |
| Control de paradas | ❌ | ❌ | ✅ | Solo Laravel |
| Recuperar contraseña | ❌ | ❌ | ❌ | **FALTA** |
| Roles y permisos | ⚠️ | ⚠️ | ✅ | Parcial |
| Documentación API | ❌ | ❌ | ✅ | Solo Laravel |

---

## 8. Recomendaciones

### Prioridad Alta
1. **Unificar backends** - Decidir si se usa ApiDart o Laravel como backend principal
2. **Implementar registro de usuarios** - Tanto en la app como en el backend
3. **Mejorar seguridad del token** - Actualizar de Base64 a JWT/Sanctum
4. **Hash de contraseñas** - Implementar bcrypt en el backend

### Prioridad Media
5. **Recuperación de contraseña** - Flujo de reset por email
6. **Roles y permisos** - Sistema más robusto de autorización
7. **Validación de datos** - Tanto en frontend como backend
8. **Migrar app Flutter a Laravel** - Si se decide usar Laravel como backend único

### Prioridad Baja
9. **Notificaciones push** - Alertas de asignaciones nuevas
10. **Reportes y estadísticas** - Dashboard administrativo
11. **API unificada** - Documentación Swagger completa

---

## 9. Decisión de Arquitectura

### Opción A: Mantener ambos backends
- **ApiDart** para la app Flutter (ligero, rápido)
- **Laravel** para el panel web y administración
- **Ventaja:** No hay que migrar código existente
- **Desventaja:** Dos backends que mantener

### Opción B: Migrar todo a Laravel (Recomendado)
- **Laravel** como único backend
- **ApiDart** se descontinua o usa solo para pruebas
- **Ventaja:** Un solo backend, más robusto, con documentación
- **Desventaja:** Hay que actualizar la app Flutter para usar los endpoints de Laravel

### Opción C: Migrar todo a ApiDart
- **ApiDart** como único backend
- **Laravel** se descontinua
- **Ventaja:** Un solo backend, más ligero
- **Desventaja:** Perder todas las funcionalidades de Laravel (panel web, roles, etc.)
