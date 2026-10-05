# Equilibra Android 1.0.0

Esta es la entrega anterior. La actualización 1.0.2 (código 3), con borrado desde el perfil de todos los roles y protección del último administrador, se documenta en `ELIMINACION_CUENTAS_1.0.2.md`. Las entregas previas se conservan; los archivos genéricos de verificación muestran la última compilación.

## Artefacto de publicación

`Equilibra-v1.0.0.aab`: applicationId y namespace `pe.com.equilibra.app`, versión 1.0.0, código 1, compile/target SDK 36, mínimo 23. El manifiesto extraído del bundle está en `AndroidManifest-verificado.xml`; los providers usan el nuevo identificador. Validación con bundletool y firma con jarsigner aprobadas.

Firma: `CN=Equilibra Upload, OU=Mobile, O=Equilibra, C=PE`, RSA 3072. Es una clave de carga nueva, distinta de Android Debug. SHA-256 del archivo: `20653A020B88EC69BF0B3D7D83ECEC045B3EBA864CB0042F1914ADFC2BCDDD73`.

La clave está en `android/keystores/equilibra-upload.jks`; Gradle lee `android/key.properties`. Ambos están excluidos de Git y protegidos mediante permisos de Windows. Hacer una copia de seguridad cifrada y guardar las contraseñas en un gestor seguro. No incluir estos archivos privados en entregas públicas. El certificado PEM es público. La clave de firma de Google Play será independiente de esta clave de carga.

## Firebase y privacidad

Nueva aplicación Android `1:229293546081:android:cbcaa00183f9b88d62a820` registrada en el mismo proyecto `equilibra-w5rl2h`. Configuración oficial actualizada, sin crear otra base de datos. Registrados SHA-1/SHA-256 de carga y depuración. Los flujos visibles usan email/contraseña; no se añadió otro proveedor de autenticación.

App Check usa Play Integrity en release y el proveedor debug en desarrollo. No se modificó la exigencia de App Check de otras aplicaciones. La comprobación de integridad de una instalación distribuida por Google Play queda pendiente: este Pixel virtual no contiene Play Store. Cuando Play Console genere el certificado de firma de la aplicación, registrar también sus SHA en Firebase y completar la prueba en un canal interno.

Perfil → Privacidad y Datos y Términos y Privacidad contienen enlaces visibles a la política y a la solicitud de eliminación. La desactivación se presenta por separado. El aviso de salud solicitado figura literalmente en la sección legal. WhatsApp de regulación: Fabrizzio (`https://wa.me/message/Q4SUBWYO4CLDF1`); Contacto de Apoyo urgente: MINSA (`https://wa.me/51955557000`), según la confirmación del usuario.

**Pendiente externo:** ambas páginas públicas devolvieron HTTP 404 al verificarlas. Publicar `https://www.equilibra.com.pe/eliminar-cuenta/` y `https://www.equilibra.com.pe/politica-de-privacidad-app/` antes de enviar la aplicación a revisión. El enlace de eliminación debe permitir enviar una solicitud y describir los datos eliminados y los plazos de retención.

## Procesamiento de solicitudes

Verificar la identidad y registrar la solicitud mediante el procedimiento administrativo. Si existe una obligación legal de retención, conservar únicamente esos datos en un archivo restringido separado **antes** de eliminar el usuario de Authentication. El borrado de Authentication dispara `onUserDeleted`, que elimina los datos operativos asociados en Firestore y los archivos personales en Storage, incluidos chats y notas relacionadas. Se ejecuta por lotes y permite reintentos; no confundir este proceso con desactivar la cuenta. Comprobar el resultado y los logs de Functions antes de cerrar la solicitud.

No se han eliminado usuarios reales durante las pruebas. Las reglas de Firestore y Storage y las 20 Functions se publicaron en `equilibra-w5rl2h` el 2 de octubre de 2026; la CLI confirmó `Deploy complete!`. Se conservaron las regiones originales, se activaron los reintentos de consentimiento/borrado y se creó el recordatorio diario. No se publicaron índices ni Hosting y no se ejecutó una migración ni un borrado de usuarios. El registro está en `firebase-release-deploy.txt`. Publicar esta aplicación de manera coordinada: las notas privadas y las conversaciones por vinculación utilizan el backend actualizado.

## Evidencia de pruebas

58 pruebas Flutter aprobadas; análisis completo sin errores de compilación, con advertencias y sugerencias generales del proyecto pendientes. Las 3 pruebas de reglas, Storage, privacidad, concurrencia y borrado pasaron en `demo-equilibra-review`; también pasó la prueba unitaria de compensación de altas y el lint JavaScript. La automatización Android está en `integration_test/pixel_release_flows_test.dart`, usa Firebase local y terminó con `All tests passed!`; los resultados están en `pixel-integration-test.txt`. El panel del psicólogo evita consultas a registros de pacientes que desactivaron el consentimiento; tareas y sesiones conservan sus permisos.

El APK generado directamente desde el AAB firmado se instaló y arrancó correctamente en el Pixel 6 virtual con Android API 37 y páginas de memoria de 16384 bytes. Se verificaron la pantalla inicial, versión/SDK, inicialización nativa de Firebase y ausencia de errores fatales en el log capturado. Evidencia: `pixel-release.png` y `pixel-release-native.txt`. Esta prueba de arranque utiliza la configuración de producción; los flujos con cuentas y datos de prueba se ejecutaron contra Firebase local. No equivale a validar todos los servicios en producción ni la atestación de Play Integrity.

Los flujos de alta, acceso y vinculación se ejercitan desde la interfaz. Registros emocionales y conductuales, objetivos/tareas y sesiones se insertan mediante los plugins Android de Firebase y se comprueba la navegación y el acceso del psicólogo; esto no cubre todos los formularios de entrada manual. La recuperación de contraseña se verifica con Authentication local, sin envío de correo real. Los enlaces externos tienen pruebas de apertura y tratamiento del error; la disponibilidad de sus páginas depende de la publicación web indicada arriba.

En el APK release se abrió la sección legal y se verificó que ambos botones lanzan Chrome con las rutas correctas de privacidad y eliminación. Los XML de accesibilidad `pixel-release-external.xml` y `pixel-release-deletion.xml` registran los destinos. Esto verifica la apertura Android; no corrige el 404 de las páginas públicas.

Para compilar la versión actual del proyecto: `flutter build appbundle --release`; después `./scripts/verify_bundle.ps1`. La versión se obtiene de `pubspec.yaml`. Dejar habilitado el paso de pub para regenerar los metadatos de plugins después de ejecutar integration_test; de lo contrario, el registrador Android puede conservar una referencia al plugin exclusivo de pruebas. El verificador falla si el paquete, versión, SDK o certificado no coinciden.
