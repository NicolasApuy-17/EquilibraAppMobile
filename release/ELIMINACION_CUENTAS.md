# Eliminación de cuentas — Equilibra 1.0.1 (código 2)

El perfil personal termina con un botón rojo «Eliminar mi cuenta». La confirmación describe el carácter irreversible del borrado, pide escribir el correo de la cuenta y verificar la contraseña actual. Tras confirmar el borrado, la aplicación cierra la sesión y vuelve a la pantalla inicial.

Ajuste visual del 5 de octubre de 2026: «Eliminar mi cuenta» utiliza el componente `ButtonWidget` existente, con la variante `destructive` y el tamaño `medium`, igual que «Cerrar Sesión». Comparte tipografía Outfit, bordes redondeados y espaciado; el color rojo procede del tema de Equilibra. Conserva su posición al final del perfil y la misma acción de confirmación. Las 61 pruebas Flutter volvieron a pasar (`button-style-flutter-tests.txt`).

Administración → Usuarios incluye «Eliminar cuenta» en rojo para cada cuenta ajena. Se confirma el correo del usuario seleccionado y la contraseña del administrador, nunca la contraseña de la persona eliminada. El administrador conserva su sesión. Para eliminar su propia cuenta utiliza el perfil personal.

La contraseña se verifica con Firebase Authentication en el dispositivo y no se envía a la función de borrado. El cliente renueva el token; `deleteMyAccount` y `adminDeleteAccount` exigen autenticación de los últimos cinco minutos. El servidor comprueba que el administrador conserva ese rol en Firestore y que su cuenta está activa. El borrado propio toma exclusivamente el UID del token autenticado, aunque un cliente alterado envíe otro UID. La confirmación del correo se vuelve a validar en el servidor.

Las funciones eliminan la cuenta de Authentication. El trigger `onUserDeleted`, con reintentos, procesa el borrado asociado de Firestore y Storage. La interfaz indica que el borrado de datos comienza tras eliminar la cuenta; no afirma que todo se haya eliminado antes de terminar el proceso asíncrono. El administrador también puede reintentar la limpieza de un perfil huérfano cuya cuenta de Authentication ya fue eliminada. La rutina de limpieza existente conserva los historiales de otras personas al desvincular a un profesional eliminado.

Cancelar o fallar la verificación no solicita el borrado. Durante una solicitud se bloquean el botón, las entradas y la salida del diálogo para impedir solicitudes duplicadas. Un error de conexión mantiene el diálogo abierto y permite reintentar; si el resultado no se confirma, no se asegura falsamente que la cuenta permanezca intacta.

Los datos operativos eliminados no se recuperan desde la aplicación. Los archivos de conservación legal, si corresponde, deben gestionarse fuera de los datos operativos mediante el procedimiento establecido antes de procesar el borrado. Los enlaces públicos de solicitud y privacidad siguen siendo necesarios para el recurso web externo.

La versión Android utiliza el mismo package `pe.com.equilibra.app`, SDK objetivo 36 y certificado de carga de la entrega anterior. El verificador de bundles comprueba ahora la versión contra `pubspec.yaml` y entrega un AAB con el nombre correspondiente; la generación del APK de prueba también verifica el hash del AAB antes de usarlo.

## Verificación

61 pruebas Flutter aprobadas, incluidas cancelación, correo incorrecto, contraseña rechazada, reintento y bloqueo de solicitudes duplicadas. Cinco pruebas unitarias del backend aprobadas: identidades anónimas/caducadas/inválidas, confirmación del correo, UID ajeno en borrado propio, privilegios administrativos y recuperación de perfiles huérfanos. Lint JavaScript sin errores ni advertencias. El análisis de los archivos modificados no presenta errores de compilación; conserva observaciones generales anteriores.

La prueba Android `integration_test/pixel_account_deletion_test.dart` usa exclusivamente emuladores locales de Authentication, Firestore, Storage y Functions. Sus cuentas ficticias y la comprobación posterior están en `firebase/functions/test/pixel_deletion_fixture.cjs`. Ninguna prueba debe ejecutarse sobre usuarios reales.

Resultado Android: `All tests passed!`. Se rechazó una contraseña incorrecta antes del borrado administrativo y se completó la eliminación propia con cierre de sesión. La comprobación posterior confirmó dos cuentas eliminadas de Authentication, dos perfiles, dos registros y dos archivos personales eliminados, y la conservación de Authentication, perfil, registro y archivo de la tercera cuenta no seleccionada. Evidencia: `account-deletion-pixel-tests.txt` y `account-deletion-pixel-verify.json`. La escritura de los campos de verificación espera a que Android reabra el teclado después de un rechazo; el Pixel se inició sin snapshot y con renderizado por software para evitar avisos de System UI.

Las dos funciones nuevas se publicaron el 4 de octubre de 2026 en el proyecto actual `equilibra-w5rl2h`, región `us-central1`. La CLI confirmó ambas operaciones y `Deploy complete!`; evidencia en `account-deletion-deploy.txt`. No se ejecutaron borrados sobre cuentas de producción durante esta verificación.

## Entrega Android

`release/Equilibra-v1.0.1.aab`, versión 1.0.1, código 2, package `pe.com.equilibra.app`, target SDK 36 y mínimo 23. Bundletool aprobó el bundle y jarsigner verificó la firma con el certificado `CN=Equilibra Upload, OU=Mobile, O=Equilibra, C=PE`, distinto de Android Debug. Se reutilizó la clave de carga existente; no se creó otra.

SHA-256 del AAB actualizado el 5 de octubre con el ajuste visual: `99012CABEB474292C5105A994D3F512213337A290A1619E06A2E34858F0467DF`. Los metadatos están en `bundle-v1.0.1-verificado.json`; el AAB 1.0.0 anterior se conserva. Para compilar otra vez: `flutter build appbundle --release`, seguido de `./scripts/verify_bundle.ps1`.

Antes del ajuste visual del 5 de octubre, el APK extraído del AAB verificado se instaló y arrancó correctamente en el Pixel 6 con páginas de memoria de 16384 bytes. Android confirmó versión 1.0.1, código 2 y target SDK 36. Firebase se inicializó y no aparecieron errores fatales en el log de arranque capturado. Evidencia: `pixel-v1.0.1.png` y `pixel-v1.0.1-native.txt`. La prueba de borrado con datos se realizó en Firebase local; este arranque release utilizó la configuración de producción sin crear o eliminar usuarios reales. El AAB actualizado del 5 de octubre superó la compilación y la verificación de bundle y firma; no se repitió su instalación en el Pixel.
