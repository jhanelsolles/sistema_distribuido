My Token: c1V-BIUHOTJ_EVGsv8aSyi:APA91bEMhG9wADgI7J8vX6E7eWJx0ezu9hecU_iajjfltdihdyFlNy5FvoFbEU-eY7Pk5Jf9sxTKaDVrOw2o713pG6dD1_TFAFxU7GBSPjoZwiI2V8SenQA

# Proyecto de Notificaciones Flutter Web

Este proyecto es una aplicación Flutter configurada para recibir notificaciones Push en la Web usando Firebase Cloud Messaging (FCM).

## Requisitos Previos

*   **Flutter SDK** instalado y configurado.
*   **Navegador Web** (Google Chrome, Microsoft Edge u Opera).
*   **Cuenta de Firebase** con acceso al proyecto `notificaciones-prueba`.

## Configuración Inicial

### 1. Dependencias
Ejecuta el siguiente comando en la raíz del proyecto para descargar las librerías necesarias:

```bash
flutter pub get
```
cdc
### 2. Claves de Firebase (IMPORTANTE)

Para que el envío y recepción de notificaciones funcione, debes configurar dos claves en el código.

#### A. Clave del Servidor (Server Key)
Esta clave permite a la aplicación enviar notificaciones directamente (solo para pruebas).

1.  Ve a la [Consola de Firebase](https://console.firebase.google.com/).
2.  Entra en **Configuración del proyecto** -> **Cloud Messaging**.
3.  Copia la **Clave del servidor** (Server Key). *Si no aparece, habilita la "API de Cloud Messaging (heredada)" desde los 3 puntitos*.
4.  Abre el archivo `lib/data/datasources/notification_datasource.dart`.
5.  Busca la línea 29 y reemplaza el texto:
    ```dart
    const String serverKey = "PEGAR_TU_CLAVE_DEL_SERVIDOR_AQUI";
    ```

#### B. Certificado Push Web (VAPID Key)
Esta clave es necesaria para obtener el token del dispositivo en la web.

*   Actualmente ya está configurada en `lib/presentation/screens/notification_sender_screen.dart` (Línea 68).
*   Si necesitas cambiarla, ve a **Configuración del proyecto** -> **Cloud Messaging** -> **Certificados push web**.

## Ejecución del Proyecto

Para ejecutar la aplicación en modo web, usa el siguiente comando en la terminal:

```bash
flutter run -d web-server --web-hostname 0.0.0.0 --web-port 8080
```

Luego, abre tu navegador y entra a: [http://localhost:8080](http://localhost:8080)

## Cómo Probar las Notificaciones

1.  Al abrir la app, selecciona el usuario **"My Device (Self)"**.
2.  Si es la primera vez, el navegador te pedirá permiso para mostrar notificaciones. Haz clic en **"Permitir"**.
3.  Deberías ver un mensaje en rojo que dice **"Status: Token found!"** y un cuadro gris con tu Token.
4.  Escribe un **Título** y un **Cuerpo** para el mensaje.
5.  Haz clic en **"Send Notification"**.
6.  ¡Deberías recibir la notificación en tu pantalla!

## Solución de Problemas

### "Permission declined" (Permiso denegado)
Si ves este error, significa que el navegador bloqueó las notificaciones.
1.  Haz clic en el icono del **candado** o **información** a la izquierda de la URL (`localhost:8080`).
2.  Ve a **Configuración del sitio** o **Permisos**.
3.  Busca **Notificaciones** y cámbialo a **Permitir**.
4.  Recarga la página.

### "AbortError: Registration failed"
Esto suele pasar si:
*   Estás en **Modo Incógnito** (las notificaciones no funcionan ahí).
*   Falta la **VAPID Key** correcta en el código.
*   El navegador (como Opera) tiene restricciones estrictas. Prueba con Chrome.

### No recibo la notificación
*   Asegúrate de que la pestaña de la app no esté en primer plano (a veces el sistema operativo las oculta si estás viendo la app).
*   Revisa la consola del navegador (F12) para ver si hay errores rojos.
