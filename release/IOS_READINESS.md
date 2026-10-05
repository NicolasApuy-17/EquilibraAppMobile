# Equilibra: preparación de iOS y TestFlight

Revisión del código: 5 de octubre de 2026. Todavía no es una build certificada para App Store. El equipo disponible es Windows; el usuario todavía no cuenta con Mac, iPhone ni membresía Apple Developer. No se publicaron páginas, builds ni cuentas demo.

## Estado de los 18 puntos solicitados

| Punto | Estado y evidencia / pendiente |
| --- | --- |
| 1. Bundle ID | Debug, Profile y Release usan `pe.com.equilibra.app`. Registrar el mismo identificador en Apple Developer y App Store Connect. |
| 2. Firebase | Se conserva el backend `equilibra-w5rl2h`. El plist existente pertenece a `com.mycompany.equilibra`: falta registrar la nueva app iOS y descargar el archivo auténtico. App Check preparado en Dart: App Attest con fallback DeviceCheck para Release; proveedor debug para pruebas. Configurar los proveedores en Firebase antes de probar; no se modificó enforcement compartido. |
| 3. Eliminación | Acción real `Eliminar mi cuenta` en Perfil y también en el diálogo Privacidad y Datos. Reautentica y llama `deleteMyAccount`; no depende de las páginas pendientes. Probar en iPhone con cuenta desechable. |
| 4. Privacidad | Enlaces ya preparados, disponibles también antes de iniciar sesión. Publicación de ambas páginas pendiente por decisión del usuario. |
| 5. SDK | Inventario abajo. Consulta de versiones realizada: existen actualizaciones mayores; no se migraron ni se certificó compatibilidad del binario nativo. Resolver y validar en Mac antes de cerrar este punto. |
| 6. Manifest | `PrivacyInfo.xcprivacy` incluido en Resources, declara datos propios vinculados al usuario sin tracking. Los plugins deben aportar sus razones de APIs; falta validar el informe agregado del Archive. No basta este archivo para certificar los SDK. |
| 7. Permisos | Info.plist solo declara fotos; los dos selectores encontrados usan galería. No se agregó cámara, ubicación, contactos, micrófono, Bluetooth ni HealthKit. Entitlement App Attest preparado. |
| 8. Datos sensibles | Registros emocionales, conductuales y notas tratados como salud/contenido sensible. En iOS se deshabilita persistencia de Firestore antes de consultar; Documents y Library se excluyen de backup y se aplica protección de archivos antes de registrar plugins. Sin acceso offline a registros tras reiniciar. Comprobar herencia de atributos en archivos creados por cada SDK y restauración de backup en dispositivo; no se ha demostrado ausencia completa de datos locales. Keychain/Auth y caches nativas requieren revisión real. Mensajes crudos de excepciones ya no se envían a los reportes propios. |
| 9. Login | Pantallas actuales usan correo y contraseña. Hay helpers y SDK de Google/Apple heredados sin invocaciones de login desde pantallas. No habilitar login social sin revisar configuración, eliminación/revocación y reglas de Apple. |
| 10. Autenticación real | Pendiente matriz de pruebas en iPhone (abajo). Las pruebas Dart no sustituyen autenticación en iOS. |
| 11. Demos | Pendientes dos cuentas ficticias y vinculadas, sin pacientes reales. No crear credenciales hardcodeadas ni incluirlas en Git. |
| 12. Funciones | Pendiente ejecución de todos los flujos en dispositivo real. No hay implementación Flutter de Firebase Messaging/local notifications en las dependencias revisadas; el directorio ImageNotification por sí solo no acredita notificaciones operativas. |
| 13. Diseño iOS | Pendientes Safe Area, teclado, texto grande, scroll, tamaños, orientación, modo claro/oscuro y gráficos en simulador y dispositivo. |
| 14. Nombre/ícono | DisplayName Equilibra. Inspeccionados 15 PNG: dimensiones correctas, RGB sin canal alpha; logo revisado visualmente. Validación de Asset Catalog pendiente en Xcode. |
| 15. Versión | Proyecto actualmente `1.0.2+3`; no se redujo el número compartido con Android. El punto de versión del texto adjunto tiene formato ambiguo. Si la primera ficha iOS requiere `1.0.0 (1)`, usar overrides de build sin alterar Android. Cada nueva subida incrementa el build iOS. |
| 16. Release | Preparada fase final de carga de dSYM de Crashlytics. Eliminado pin de framework Firestore de terceros: CocoaPods resolverá el pod oficial de la versión FlutterFire. Falta `pod install`, Archive, firma y validación con Xcode/SDK aceptado por Apple. |
| 17. Logs/configuración | Prints de Dart existentes restringidos a Debug; reportes propios envían categoría/código en lugar de mensajes crudos. No se encontraron localhost/endpoints de emulador en lib. Plist antiguo es un bloqueo explícito. Contactos públicos aún requieren confirmación del propietario y prueba desde iPhone. |
| 18. TestFlight | Pendiente Mac o entorno macOS de compilación, cuenta Apple Developer, firma, ficha y upload. Primero pruebas internas; luego decidir revisión pública. |

## SDK y plugins nativos

Versiones actuales de FlutterFire: Core 3.14.0; Auth 5.6.0; Firestore 5.6.9; Storage 12.4.7; Functions 5.5.2; Crashlytics 4.3.7; Performance 0.10.1+7; App Check 0.3.2+6. Core determina Firebase Apple SDK 11.13.0. Esto es un inventario, no una garantía de soporte actual.

Otros plugins iOS registrados: `audio_session`, `device_info_plus`, `google_sign_in_ios`, `image_picker_ios`, `just_audio`, `path_provider_foundation`, `shared_preferences_foundation`, `sign_in_with_apple`, `sqflite`, `url_launcher_ios`, `vibration`. `integration_test` corresponde a pruebas y debe comprobarse que no aparezca en la distribución Release.

Se encontraron manifests en las fuentes locales de device_info_plus, google_sign_in_ios, image_picker_ios, path_provider_foundation, shared_preferences_foundation, sqflite y url_launcher_ios. Los manifests de Firebase se obtienen con los pods nativos, todavía no instalados aquí; no concluir que faltan solo porque no existen en el paquete Dart. Revisar también Flutter.framework y todos los frameworks finales.

La consulta `flutter pub outdated --no-dev-dependencies --no-dependency-overrides` mostró versiones mayores disponibles para Firebase y otros plugins. Migrar como conjunto compatible y probar Android/iOS; no cambiar todas las versiones a ciegas. La actualización sigue pendiente.

## Datos y declaraciones

El manifiesto propio declara nombre, correo, teléfono (schema de usuario), identificador de usuario, salud, información sensible, fotos, contenido del usuario y diagnósticos. Finalidad: funcionamiento de la app, sin tracking. Contrastar el formulario App Privacy con los campos realmente capturados y el informe agregado: Crashlytics, Performance, App Check y sus proveedores pueden añadir identificadores/diagnósticos. No hay SDK Firebase Analytics declarado directamente, pero verificar el árbol nativo final.

No introducir valores emocionales, notas clínicas, correos, tokens ni fotos en logs, nombres de trazas o atributos Performance. Los stacks y reportes nativos todavía deben revisarse en Firebase con datos ficticios. La exclusión de backup es preventiva; no prueba por sí sola protección de todos los archivos ni elimina copies previas de una instalación anterior.

## Siguiente paso: Firebase iOS

1. Abrir Firebase Console → proyecto `equilibra-w5rl2h` → Configuración del proyecto → Agregar aplicación iOS.
2. Registrar exactamente `pe.com.equilibra.app`. No crear otro proyecto ni otra base de datos.
3. Descargar `GoogleService-Info.plist` y reemplazar `ios/Runner/GoogleService-Info.plist`. No modificar a mano el app ID o la API key del archivo antiguo.
4. Registrar App Attest con el Team ID real; para fallback DeviceCheck configurar la clave correspondiente. Registrar tokens debug solo para dispositivos/simuladores de desarrollo.
5. Verificar restricciones de la API key, email/password Auth, reglas Firestore/Storage y Functions existentes para la nueva app. No cambiar enforcement global sin revisar las otras plataformas.
6. En Windows ejecutar `powershell -File scripts/ios_preflight.ps1`. Actualmente falla intencionalmente por el plist antiguo.

## Build en macOS

Obtener membresía Apple Developer, registrar el Bundle ID, seleccionar Team y Automatic Signing en `ios/Runner.xcworkspace`, habilitar App Attest y regenerar provisioning profile. Resolver SDK/dependencias, instalar pods y revisar sus manifests antes de archivar.

```sh
flutter pub get
cd ios
pod install --repo-update
cd ..
plutil -lint ios/Runner/Info.plist ios/Runner/GoogleService-Info.plist ios/Runner/PrivacyInfo.xcprivacy ios/Runner/Runner.entitlements
flutter test
flutter build ipa --release --build-name=1.0.0 --build-number=1
```

El último comando es un ejemplo para primera build iOS 1.0.0 (1); confirmar los valores y aumentarlos para futuras subidas. Abrir Archive en Xcode Organizer, generar Privacy Report, validar firma, SDK, íconos y símbolos, y subir a App Store Connect/TestFlight. No se ejecutaron estos pasos ni se produjo IPA.

## Matriz de pruebas antes de TestFlight público

- Cuenta paciente desechable: registro, sesión, logout, login, recuperación de contraseña, persistencia tras reinicio, modo avión/errores, eliminación y rechazo posterior del login.
- Paciente demo y psicólogo demo: vinculación por código, acceso permitido/rechazado, desactivar compartir registros, sesiones y tareas. Datos ficticios y credenciales en almacenamiento privado.
- Crear/editar registros emocionales y conductuales, regulación/audio, objetivos/tareas, comentarios, gráficos, selección/subida de imagen, ayuda urgente y Contacto de Apoyo.
- Enlaces de privacidad y eliminación una vez publicadas las páginas. Probar las URLs desde Safari y desde la app.
- iPhone pequeño y grande: Safe Area, notch, teclado, scroll, texto ampliado, rotación y claro/oscuro. Revisar los diálogos de privacidad/eliminación con teclado abierto.
- Instalar Release/TestFlight, revisar tokens App Check válidos, Functions y Storage operativos, Crashlytics con símbolos y Performance sin datos clínicos.
- Revisar archivos locales y backup/restauración con datos ficticios; comprobar atributos de protección/exclusión de archivos creados por plugins, no solo sus carpetas padre.
- Preparar metadatos, edad, capturas, App Privacy, credenciales demo y notas para revisión. Publicar páginas antes de enviar a revisión final de ambas tiendas.

## Verificación hecha desde Windows

Suite completa existente: 61 pruebas aprobadas, incluidas privacidad y eliminación. Comprobación estática de iOS: identifica correctamente el plist incompatible. XML de Info.plist, entitlements y manifest: parseado correctamente. Dimensiones y ausencia de alpha de los 15 íconos: verificadas. Análisis Dart de los siete archivos revisados: sin errores, con 70 avisos de estilo/código (incluido un import redundante retirado después). No se validó compilación Swift, CocoaPods, Archive ni dispositivo.

Referencias: [privacidad y manifests](https://developer.apple.com/support/third-party-SDK-requirements/), [eliminación dentro de la app](https://developer.apple.com/support/offering-account-deletion-in-your-app/), [envío y TestFlight](https://developer.apple.com/app-store/submitting/), [App Check Flutter](https://firebase.google.com/docs/app-check/flutter/default-providers), [persistencia Firestore](https://firebase.google.com/docs/firestore/manage-data/enable-offline), [símbolos Crashlytics](https://firebase.google.com/docs/crashlytics/ios/get-deobfuscated-reports).
