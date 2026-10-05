# Equilibra 1.0.2 — Perfiles y protección del administrador

Los perfiles de psicólogo y administrador, accesibles desde su foto en la cabecera → «Mi cuenta», terminan con «Eliminar mi cuenta». El perfil del paciente conserva la misma opción. Los tres utilizan `DeleteMyAccountButton`, con el componente `ButtonWidget`, tipografía Outfit, tamaño medium y el rojo del tema de Equilibra. La confirmación exige escribir el correo de la cuenta y verificar la contraseña actual; al completar el borrado propio se cierra la sesión.

El servidor impide eliminar al último administrador disponible, tanto desde `deleteMyAccount` como desde `adminDeleteAccount`. Para contar como respaldo, otra cuenta debe tener rol admin, estar activa, existir en Authentication, tener acceso habilitado y no estar ya en proceso de eliminación. El bloqueo muestra «No puedes eliminar la única cuenta de administrador disponible. Debe quedar otro administrador activo con acceso», conserva la cuenta y permite reintentar.

La comprobación y la reserva se realizan en una transacción de Firestore antes de llamar a Authentication. Las eliminaciones simultáneas no pueden contar mutuamente las cuentas que están eliminando como respaldo. Las reservas no pueden modificarse desde el cliente. Si Authentication confirma que la cuenta sigue existiendo después de un fallo, se libera la reserva. Si una invocación se interrumpe con resultado desconocido, esa cuenta sigue excluida como respaldo y su eliminación puede reintentarse después de veinte minutos. Nunca se elimina Authentication dentro de una transacción que pueda repetirse.

El borrado de Firestore y Storage sigue a cargo del trigger existente `onUserDeleted`, con reintentos. Se conservan los datos de las cuentas ajenas.

## Comprobaciones del 5 de octubre de 2026

Los registros crudos de compilación, emuladores y dispositivos se conservan localmente y están excluidos de Git. El repositorio incluye el código de las pruebas, este informe y los metadatos de los bundles; los AAB firmados y las claves privadas se conservan fuera del control de versiones.

- 61 pruebas Flutter aprobadas: `role-deletion-flutter-tests.txt`.
- 11 pruebas unitarias del servidor aprobadas y lint sin errores.
- Tres pruebas con las funciones y transacciones reales de los emuladores Firebase aprobadas: `role-deletion-backend-integration.txt`. Cubren respaldos no disponibles, dos borrados propios simultáneos y borrado administrativo con el solicitante reservado.
- Pixel 6: `role-deletion-pixel-tests.txt`, resultado `All tests passed!`. Navegó desde la foto al perfil de cada rol, rechazó una contraseña incorrecta, bloqueó el único administrador, permitió su borrado tras crear otro administrador y completó el borrado propio del psicólogo con cierre de sesión.
- Verificación posterior local: `account-deletion-pixel-verify.json`. Tres cuentas, perfiles, registros y archivos personales eliminados; administrador restante y cuenta ajena conservados. No se crearon ni eliminaron usuarios de producción para estas pruebas.
- Análisis Flutter de los archivos de la interfaz sin errores de compilación; observaciones generales anteriores en `role-deletion-analyzer.txt`.

Las funciones `deleteMyAccount` y `adminDeleteAccount` se actualizaron en el proyecto existente `equilibra-w5rl2h`, región `us-central1`. La CLI confirmó ambas operaciones y `Deploy complete!`: `role-deletion-deploy.txt`.

La prueba del servidor requiere emuladores locales de Auth, Firestore, Storage y Functions con `firebase/emulators.pixel.json`. Antes de sembrar las cuentas Pixel, configurar `FIREBASE_AUTH_EMULATOR_HOST=127.0.0.1:9098`, `FIRESTORE_EMULATOR_HOST=127.0.0.1:8188` y `FIREBASE_STORAGE_EMULATOR_HOST=127.0.0.1:9299`, y ejecutar `npm run test:account-actions:emulator` desde `firebase/functions`. Los archivos de prueba rechazan destinos externos.

## Entrega

`release/Equilibra-v1.0.2.aab`, versión 1.0.2, código 3, package `pe.com.equilibra.app`, target SDK 36 y mínimo 23. Compilación release, validación bundletool y firma jarsigner aprobadas, reutilizando la clave de carga de Equilibra. SHA-256: `CAF4CA01956EA144AF22CE558963605F3804AC3E0AAC80DCB6735024E45A096C`. Metadatos en `bundle-v1.0.2-verificado.json`; los AAB anteriores se conservan.

Para regenerar: `flutter build appbundle --release`, seguido de `scripts/verify_bundle.ps1`. El APK de comprobación se extrae del AAB firmado mediante `scripts/build_release_test_apk.ps1`.

El APK extraído de este AAB se instaló y abrió en el Pixel 6. Android confirmó versión 1.0.2, código 3, mínimo SDK 23, target SDK 36 y páginas de memoria de 16384 bytes. El proceso permaneció activo sin errores fatales en el log de arranque capturado (`pixel-v1.0.2-native.txt`). La prueba de borrado con datos se realizó antes en Firebase local; este arranque release no creó ni eliminó cuentas de producción.
