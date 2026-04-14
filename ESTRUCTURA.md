# Estructura del Proyecto - Noche Buenas Frontend

## Árbol de carpetas

```
lib/
├── main.dart                      # Entry point + AppShell (guard de autenticación)
├── screens/
│   ├── login_screen.dart          # Pantalla de inicio de sesión
│   ├── home_screen.dart           # Contenedor principal con menú inferior
│   ├── users_screen.dart          # Pestaña: lista de usuarios
│   └── account_screen.dart        # Pestaña: datos de mi cuenta
└── services/
    └── api_service.dart           # Cliente HTTP + manejo de errores
```

---

## Responsabilidades por archivo

### `main.dart`
- Punto de entrada de la app (`main()` y `MyApp`)
- `AppShell`: decide si mostrar login o la app principal según si hay sesión activa

### `screens/login_screen.dart`
- Formulario de inicio de sesión
- Llama a `POST /api/sesiones/login`
- Al éxito, guarda el token y notifica a `AppShell`

### `screens/home_screen.dart`
- Scaffold principal con `BottomNavigationBar`
- Controla qué pestaña se muestra (Usuarios o Mi Cuenta)
- No contiene lógica de negocio propia

### `screens/users_screen.dart`
- Lista todos los usuarios del sistema
- Llama a `GET /api/usuarios`
- Permite revocar la sesión de un usuario (`PATCH /api/sesiones/:id/revocar`)

### `screens/account_screen.dart`
- Muestra los datos del usuario autenticado
- Llama a `GET /api/usuarios/:id`
- Botón para cerrar su propia sesión (`POST /api/sesiones/logout`)

### `services/api_service.dart`
- Singleton: una única instancia en toda la app (`ApiService()`)
- Gestiona el token JWT en memoria
- Métodos base: `get`, `post`, `put`, `patch`, `delete`
- Clase `ApiException`: errores con código HTTP y mensaje del servidor

---

## Conexión con el backend

**Base URL** configurada en `api_service.dart`:
```dart
static const String baseUrl = 'http://192.168.0.103:3000';
```

### Endpoints actualmente conectados

| Método | Endpoint                          | Dónde se usa          |
|--------|-----------------------------------|-----------------------|
| POST   | `/api/sesiones/login`             | `login_screen.dart`   |
| POST   | `/api/sesiones/logout`            | `account_screen.dart` |
| PATCH  | `/api/sesiones/:id/revocar`       | `users_screen.dart`   |
| GET    | `/api/usuarios`                   | `users_screen.dart`   |
| GET    | `/api/usuarios/:id`               | `account_screen.dart` |

---

## Cómo agregar un nuevo endpoint

### 1. Solo llamar al endpoint (sin nueva pantalla)

Usa directamente los métodos base de `ApiService` en la pantalla donde lo necesites:

```dart
final _api = ApiService();

// GET
final response = await _api.get('/api/ruta');

// POST
final response = await _api.post('/api/ruta', {'campo': 'valor'});

// PATCH
final response = await _api.patch('/api/ruta/$id/accion', {});

// PUT
final response = await _api.put('/api/ruta/$id', {'campo': 'valor'});

// DELETE
final response = await _api.delete('/api/ruta/$id');
```

Los datos llegan en `response['data']`.

### 2. Agregar una nueva pantalla

1. Crear `lib/screens/nueva_pantalla.dart`
2. En el constructor recibir `ApiService api`
3. Llamar el endpoint en `initState()` o en un método propio
4. Si la pantalla va en el menú inferior, agregarla en `home_screen.dart`:

```dart
// En home_screen.dart - agregar al body:
body: switch (_selectedIndex) {
  0 => UsersScreen(api: _api),
  1 => NuevaPantalla(api: _api),     // <- aquí
  _ => AccountScreen(...)
},

// Y en bottomNavigationBar agregar un ítem:
BottomNavigationBarItem(
  icon: Icon(Icons.nuevo_icono),
  label: 'Nueva',
),
```

---

## Manejo de errores

Todos los errores del backend lanzan `ApiException`. Siempre capturarlos así:

```dart
try {
  final response = await _api.get('/api/algo');
  // usar response['data']
} on ApiException catch (e) {
  // e.statusCode → código HTTP (401, 403, 404...)
  // e.message    → mensaje del servidor
  setState(() => _error = e.message);
}
```
