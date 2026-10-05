# Correcciones de la revisión

Se corrigieron los 14 hallazgos prioritarios y los problemas adicionales identificados en `REVISION_CODIGO.md`. El informe original se conserva como registro de la revisión previa.

## Comportamiento conservado y correcciones

- El paciente sigue creando, editando y eliminando sus registros y objetivos. Las referencias de propiedad y acceso no se pueden cambiar desde el cliente, y los comentarios del profesional quedan reservados a este.
- El profesional actual puede consultar los registros compartidos del paciente, incluso los anteriores a la vinculación. Las consultas ahora se basan en el paciente y las reglas comprueban la asignación y privacidad vigentes. El anterior pierde inmediatamente ese acceso.
- Apagar compartir bloquea las lecturas del profesional desde las reglas. La sincronización de referencias reconsulta el perfil dentro de cada transacción, respeta privacidad, pagina los registros y admite reintentos. El backfill administrativo usa esa misma lógica.
- Cada nueva asignación genera su propio chat; no se borran mensajes ni se cambian los participantes de las conversaciones anteriores. Una asignación sin cambio de profesional conserva su chat. Los accesos actuales que pasan el UID del paciente resuelven automáticamente el chat activo.
- Mensaje y resumen se guardan juntos en una transacción. La app conserva el borrador ante errores y reutiliza el identificador al reintentar, evitando duplicados.
- Las notas privadas nuevas se guardan en la carpeta del profesional. Se conserva la lectura de notas antiguas del profesional actual; al reasignar se fija su autor para impedir que el siguiente profesional las reciba. No se borran notas.
- Los comentarios sobre registros siguen compartiéndose y notificándose al paciente. La etiqueta de la interfaz ahora explica quién los recibe.
- La lectura profesional de objetivos usa la referencia completa, evitando `.id` en reglas.
- El reporte global de errores utiliza una única ruta con soporte Web y tolerancia a fallos de Crashlytics.
- El detalle del paciente acepta `patientId` en la URL y muestra un estado de error si falta o no es válido. Los accesos existentes con el objeto del paciente siguen funcionando.
- El recordatorio diario se entrega en el buzón de Notificaciones a las 9:00 a. m., hora de Perú. Se respeta la preferencia y se deduplica por día y paciente. Es un aviso dentro de la aplicación; no es una notificación push del sistema operativo.
- Las altas de psicólogos compensan un fallo del perfil eliminando únicamente la cuenta de Auth recién creada. Los errores de compensación quedan registrados para soporte.
- Las notificaciones de eventos usan identificadores estables para evitar duplicados. Marcar todas como leídas trabaja en grupos para no exceder el tamaño de una escritura.
- Storage conserva la carga de fotos y noticias, pero valida propietario, tipo de imagen y un máximo de 10 MB. Las noticias exigen rol de psicólogo; las eliminaciones propias siguen permitidas.
- Los fallos de conteo conservan el error original. Un fallo de deserialización se comunica a la vista en lugar de presentar una lista silenciosamente incompleta.
- La firma Android de publicación usa `signingConfigs.release`. `debug` sigue usando su configuración normal. Una compilación `release` sin `android/key.properties` falla con un mensaje explícito, y las claves quedan excluidas de Git.

## Verificación y límites

La suite de regresión verifica reglas de lectura y edición, consultas de paciente, privilegios de administración, revocación inmediata, privacidad durante backfill y eventos fuera de orden, aislamiento de notas y chats, reintento de mensajes, vinculaciones concurrentes, recordatorios y restricciones de Storage. Las pruebas usan exclusivamente el proyecto desechable `demo-equilibra-review`.

Resultados: 56 pruebas Flutter aprobadas; 3 pruebas de Firebase/Storage y recuperación de altas aprobadas; lint JavaScript sin errores ni advertencias; análisis Flutter con 0 errores, 532 advertencias y 845 observaciones generales; APK Android de depuración compilado correctamente con `flutter build apk --debug --no-pub`.

Para repetir las pruebas de Firebase, iniciar los emuladores con Java 21 y ejecutar desde `firebase`:

```powershell
firebase emulators:start --only firestore,storage --project demo-equilibra-review --config emulators.review.json
```

En otra terminal, desde `firebase/functions`:

```powershell
$env:FIRESTORE_EMULATOR_HOST = '127.0.0.1:8188'
$env:FIREBASE_STORAGE_EMULATOR_HOST = '127.0.0.1:9299'
npm run test:emulator
npm test
npm run lint
```

Las verificaciones Flutter se ejecutan con `flutter test --no-pub`, `flutter analyze --no-pub` y la compilación Android de depuración. El analizador aún contiene advertencias y sugerencias generales del proyecto; no se intentó una limpieza masiva ajena a estos fallos.

No se desplegaron reglas, funciones ni aplicaciones, ni se migraron datos de producción. Los cambios de Firebase requieren publicación coordinada con la aplicación actualizada, especialmente los nuevos chats y las notas privadas. El recordatorio comienza a ejecutarse cuando se despliega su función programada. No se verificó compilación iOS en Windows. La compilación de publicación necesita la clave real del proyecto.

Las notas o chats transferidos por reasignaciones anteriores a esta corrección no permiten inferir con certeza sus autores originales; esta corrección evita nuevas transferencias, pero no reconstruye retrospectivamente esa información.
