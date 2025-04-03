# ON POINT - Sistema de Reservas de Salas

Aplicación móvil desarrollada en Flutter con Supabase como backend, que permite a los empleados de una empresa realizar reservas de salas de coworking de manera eficiente y segura.

## 🧩 Funcionalidades

- Registro e inicio de sesión con verificación de correo electrónico institucional.
- Visualización de salas disponibles por día.
- Realización de reservas.
- Consulta de reservas propias.
- Panel de administración para gestión de salas:
  - Crear nuevas salas.
  - Activar/desactivar salas.
  - Eliminar salas existentes.

## 💻 Tecnologías utilizadas

- **Flutter**: Framework UI multiplataforma.
- **Supabase**: Backend como servicio (auth + base de datos).
- **Dart**: Lenguaje de programación principal.
- **Material Design**: Diseño de interfaz amigable y moderno.

## 📦 Estructura del Proyecto

```plaintext
lib/
│
├── auth_service/
│   ├── AuthService.dart
│   └── AuthGate.dart
│
├── pages/
│   ├── LoginScreen.dart
│   ├── RegisterScreen.dart
│   ├── HomeScreen.dart
│   ├── MakeReserveScreen.dart
│   ├── MyReserveScreen.dart
│   └── AdminScreen.dart
│
├── widgets/
│   ├── CustomButton.dart
│   └── ErrorDialog.dart
│
├── color_scheme/
│   └── ColorScheme.dart
│
└── main.dart
```

## 🧪 Requisitos

- Cuenta de Supabase activa.
- App Flutter configurada con:
  ```dart
  await Supabase.initialize(
    anonKey: 'TU_ANON_KEY',
    url: 'TU_URL_SUPABASE',
  );
  ```

## 🛠️ Instalación y ejecución

1. Clona este repositorio:
   ```bash
   git clone https://github.com/JuandiGuti/on-point.git
   ```

2. Navega al directorio:
   ```bash
   cd on-point
   ```

3. Instala dependencias:
   ```bash
   flutter pub get
   ```

4. Ejecuta la app:
   ```bash
   flutter run
   ```

## 📌 Notas

- Solo se permiten registros con correos que terminen en `@hpc.com.gt`.
- El botón "MIS RESERVAS" y la lista de salas se actualizan automáticamente con *pull-to-refresh*.
- El panel de administrador requiere tener el rol adecuado en Supabase.

## 📄 Licencia

Este proyecto es de uso académico y personal. Libre de ser modificado para fines similares.
