# Revisión del código de Equilibra

Fecha: 30 de septiembre de 2026, America/Lima.

## Alcance y comprobaciones

Revisión estática de la aplicación Flutter, autenticación, navegación, acceso a datos, reglas de Firestore/Storage, Cloud Functions y configuración móvil. Se inspeccionaron los flujos de registros, seguimiento del paciente, tareas, chat, privacidad, perfil y notificaciones. El inventario contiene 173 archivos Dart/JavaScript de aplicación y pruebas. Esto no equivale a una validación funcional de todas las pantallas en dispositivos.

- `flutter analyze --no-pub`: 0 errores, 532 advertencias, 847 observaciones; 1379 incidencias en total. Salida completa en `review-analyzer.txt`. El comando terminó con código 1 por las incidencias.
- `flutter test --no-pub`: 54 pruebas aprobadas. La suite cubre validadores y una pantalla de entrada; no cubre permisos, reasignaciones, privacidad ni funciones del servidor.
- `node --check` para `index.js`, `psychologists.js` y `notifications.js`: sintaxis válida.
- No se desplegaron cambios, no se consultaron datos de producción y no se ejecutaron pruebas de reglas en el emulador de Firebase. Los hallazgos de permisos se deducen del código local; deben reproducirse con identidades de prueba antes de publicar una corrección.
- No se modificó código de la aplicación. Los cambios previos en `pubspec.lock` y la eliminación de `ios/Flutter/ephemeral/flutter_native_integration.env` ya existían al comenzar.

Prioridad P1: corregir antes de publicar por exposición de información o ruptura de autorización. P2: error funcional o problema de entrega que debe resolverse en la siguiente corrección.

## Hallazgos prioritarios

### 1. P1 — El propietario puede cambiar las referencias que controlan el acceso

Ubicación: `firebase/firestore.rules:126` y `:143`.

En `records` y `behavioral_records`, el propietario puede actualizar cualquier campo. La comprobación de `psychologistRef` solo ocurre al crear. Un cliente puede cambiar después `psychologistRef`, `userRef` o los comentarios atribuidos al psicólogo. Por ejemplo, puede sustituir `psychologistRef` por la referencia de un usuario cualquiera, al que la regla de lectura concede acceso sin comprobar su rol o su relación actual con el paciente. Cambiar `userRef` también permite transferir un documento al espacio de otro usuario.

Corrección: restringir los campos editables del paciente, conservar inmutables las referencias de propiedad y autorización y reservar los comentarios del profesional para su autor. Aplicar la misma disciplina a `goals`, cuya actualización tampoco conserva `userRef`.

### 2. P1 — Reasignar un paciente no revoca el acceso a sus registros anteriores

Ubicación: `firebase/functions/psychologists.js:168`, `:701`; `firebase/firestore.rules:122` y `:139`.

`linkPatientToPsychologist` actualiza el perfil y la conversación. No cambia las referencias del profesional en registros existentes. El único trigger de propagación retorna cuando la preferencia de compartir no cambia, por lo que una reasignación normal de A a B no lo ejecuta. Las reglas siguen autorizando a A mediante las referencias antiguas; B no encuentra esos registros en sus consultas. Esto también afecta las tareas personales que conservan la referencia inicial.

Corrección: definir explícitamente qué información histórica se transfiere, revocar acceso mediante la asignación vigente y sincronizar las referencias al vincular o reasignar. Verificar tanto registros anteriores al primer vínculo como registros creados antes de una reasignación.

### 3. P1 — El nuevo psicólogo recibe el historial del chat anterior

Ubicación: `firebase/functions/psychologists.js:163` y `:173`; `firebase/firestore.rules:386`.

La conversación usa únicamente el UID del paciente como ID. Al reasignarlo se reemplaza `psychologistRef` en el mismo documento con `merge: true`, sin separar la subcolección `messages`. La regla de lectura de todos los mensajes depende de los participantes actuales del padre. El nuevo profesional obtiene así acceso a los mensajes intercambiados con el anterior.

Corrección: crear una conversación distinta por vínculo o episodio de atención y conservar los participantes de cada historial. Cualquier transferencia de mensajes requiere una política explícita, no un efecto secundario de la reasignación.

### 4. P1 — La migración administrativa vuelve a compartir registros privados

Ubicación: `firebase/functions/psychologists.js:387` y `:409`.

`adminBackfillPsychologistRefs` busca registros sin `psychologistRef` y les asigna el profesional actual. No consulta `shareDataWithPsychologist`. Los registros privados, tanto nuevos como ocultados por el trigger, tienen precisamente esa referencia ausente o nula. Ejecutar la migración los vuelve a exponer, aunque el interruptor continúe apagado. El trigger no los oculta de nuevo porque la preferencia no cambió.

Corrección: distinguir registros anteriores a la migración de registros deliberadamente privados y respetar el consentimiento vigente durante cualquier mantenimiento.

### 5. P1 — La revocación de privacidad depende de un trigger susceptible a desorden y fallos

Ubicación: `firebase/functions/psychologists.js:698`, `:705`, `:716`; `firebase/firestore.rules:122`.

Al apagar compartir, la regla de lectura aún acepta la referencia antigua hasta que el trigger termine de reescribir todos los documentos. Si falla, el código registra el error y retorna normalmente, pudiendo dejar registros visibles. Además, cada ejecución usa el estado capturado en su evento: apagar/encender/apagar rápidamente puede dejar como resultado la referencia de un evento anterior que terminó después del último.

Firebase documenta que el orden de los eventos no está garantizado y que un evento puede entregarse más de una vez: [documentación oficial de triggers](https://firebase.google.com/docs/functions/firestore-events).

Corrección: hacer que la autorización dependa del consentimiento vigente y diseñar la sincronización con control de versión, estado actual e idempotencia. No prometer revocación efectiva solo porque se guardó el interruptor.

### 6. P1 — «Observación privada» es accesible al paciente

Ubicación: `lib/pages/psychologist_patient_detail/registros_tab.dart:110` y `:226`; `firebase/firestore.rules:122`; `firebase/functions/notifications.js:116`.

La interfaz invita al profesional a escribir una «Observación privada», pero guarda el texto en el documento del registro, que el paciente puede leer completo. Además, el trigger de comentarios envía al paciente una notificación con una vista previa del texto. Que la pantalla de registros del paciente no muestre ese campo no lo hace privado.

Corrección: si el comentario es compartido, cambiar su etiqueta y explicar su destinatario; si es privado, guardarlo en una colección con permisos exclusivos del profesional y no incluirlo en notificaciones al paciente.

### 7. P1 — Las notas privadas pasan al siguiente profesional

Ubicación: `firebase/firestore.rules:243`; `lib/pages/psychologist_patient_detail/resumen_tab.dart:75`.

`patient_notes/{patientUid}` tiene un solo documento por paciente y autoriza al psicólogo actualmente asignado, sin guardar ni comprobar al autor. Al reasignar al paciente, B puede leer y sobrescribir la nota escrita por A. A pierde el acceso. Esto contradice la intención documentada de que sea una nota privada del profesional.

Corrección: identificar las notas por paciente y autor o por vínculo; conservar el autor y autorizar contra él. Si deben transferirse, establecer ese comportamiento explícitamente en el producto.

### 8. P2 — La lectura profesional de objetivos utiliza una propiedad inválida de referencia

Ubicación: `firebase/firestore.rules:329`.

Se llama a `isAssignedPsychologistAndSharing(resource.data.userRef.id)`. Una referencia almacenada en reglas es un `Path`, no un `DocumentReference` de Dart con propiedad `id`. El mismo archivo ya advierte de este problema en la validación de creación de otros documentos. El acceso del propietario puede pasar por la primera rama, mientras el del profesional falla al evaluar la segunda.

La [referencia oficial de Path](https://firebase.google.com/docs/reference/rules/rules.Path) documenta sus operadores y bindings; no ofrece una propiedad `id` como el SDK cliente.

Corrección: pasar la referencia completa a un helper que use `get(patientRef)` y compruebe asignación y consentimiento. Confirmar lecturas individuales y consultas con el emulador.

### 9. P2 — El manejador global de errores falla en Web

Ubicación: `lib/main.dart:33`; `lib/utils/error_logging.dart:27`.

`logAppError` evita Crashlytics en Web porque no tiene implementación allí, pero `FlutterError.onError` llama antes a `FirebaseCrashlytics.instance.recordFlutterFatalError` sin esa protección. Un error de Flutter en Web puede provocar otro error dentro del propio manejador e impedir que se alcance el registro de Firestore. En móvil también se informa el mismo error dos veces, porque `logAppError` vuelve a invocar Crashlytics.

Corrección: centralizar el reporte en `logAppError`, proteger plataformas no soportadas y mantener una salida de diagnóstico cuando falle el reporte.

### 10. P2 — Abrir directamente el detalle de paciente produce un cast inválido

Ubicación: `lib/flutter_flow/nav/nav.dart:267`.

El builder exige `params.state.extra as UsersRecord`. Un enlace directo a `/psychologistPatientDetail` no contiene ese objeto; la ruta está además habilitada para deep links. El cast de null provoca una excepción. El chat ya utiliza una comprobación de tipo para evitar una variante del mismo problema.

Corrección: llevar el identificador del paciente en la URL, cargar el documento autorizado y mostrar un estado de error si el ID falta o no hay acceso. No depender de un objeto de memoria para una ruta que se puede abrir desde fuera.

### 11. P2 — El recordatorio diario no está implementado

Ubicación: `lib/pages/user_profile/user_profile_widget.dart:88`; `lib/backend/schema/user_prefs_record.dart:30`.

El interruptor promete recibir un recordatorio diario y escribe `dailyReminderEnabled`. La búsqueda de usos solo encuentra lectura, almacenamiento y serialización de esa preferencia. No hay un consumidor que programe o envíe el aviso en Flutter ni en las funciones exportadas.

Corrección: implementar el envío/programación, permisos y cancelación del recordatorio, o retirar temporalmente la promesa del producto.

### 12. P2 — La creación de psicólogos puede dejar una cuenta incompleta

Ubicación: `firebase/functions/psychologists.js:117` y `:140`.

Primero se crea el usuario de Firebase Auth. La generación del código y la escritura del perfil ocurren después, sin recuperación ni compensación. Si fallan, queda un correo registrado sin el perfil/rol de psicólogo; repetir la operación devuelve «ya registrado» y no completa el alta.

Corrección: implementar recuperación idempotente de altas parciales o compensar eliminando la cuenta recién creada cuando no se pudo persistir el perfil.

### 13. P2 — El envío de mensajes puede informar fracaso después de guardarlos

Ubicación: `firebase/functions/psychologists.js:617` y `:622`; `lib/pages/psychologist_chat/psychologist_chat_widget.dart:105`.

La creación del mensaje y la actualización de la conversación son dos escrituras independientes. Si la segunda falla, la función informa error aunque el mensaje ya exista. Reintentar puede duplicarlo. El cliente además borra el borrador antes de obtener una respuesta y no lo restaura cuando el envío falla.

Corrección: escribir mensaje y resumen en un batch/transaction, usar un identificador idempotente de envío y conservar el texto hasta confirmar o permitir recuperación del borrador.

### 14. P2 — La compilación Android de producción usa firma de depuración

Ubicación: `android/app/build.gradle:82`.

Aunque hay un bloque `signingConfigs.release`, el build `release` selecciona `signingConfigs.debug`. El artefacto resultante no usa la identidad de publicación configurada y puede fallar al distribuirse o actualizar una instalación firmada correctamente.

Corrección: utilizar la configuración de firma de publicación y comprobar que la ausencia de credenciales produce un error claro al generar el artefacto de producción.

## Otros problemas concretos

- `lib/backend/backend.dart:537`: `catchError` de la consulta de conteo no devuelve un `AggregateQuerySnapshot` ni relanza. El analizador lo advierte; cuando la consulta falla puede sustituirse el error original por un error de tipo. Propagar el fallo o devolver un resultado de dominio explícito.
- `firebase/functions/notifications.js:24`: las notificaciones se crean con `.add()` y los triggers no deduplican por evento. Como la entrega admite repeticiones, pueden aparecer notificaciones duplicadas. Usar IDs deterministas por evento/destinatario.
- `firebase/storage.rules:9` y `:13`: las escrituras validan solo el UID de la carpeta; no limitan tamaño ni tipo de archivo, y `news_images` no exige rol de psicólogo. Un usuario autenticado puede subir contenido arbitrario a su carpeta. Validar MIME, tamaño y rol según el uso esperado.
- `lib/backend/backend.dart:558` y `:582`: los documentos que fallan al deserializar se omiten mediante `safeGet` y solo se imprime el fallo. Las pantallas pueden mostrar estadísticas incompletas sin indicar que se excluyeron registros. Reportar el fallo de lectura y el estado parcial, especialmente en vistas de seguimiento.
- `firebase/functions/psychologists.js:194`: la comprobación «ya tiene psicólogo» ocurre fuera de la transacción que asigna. Dos solicitudes concurrentes con códigos diferentes pueden pasar y ambas informar éxito. Leer y comprobar el vínculo dentro de la misma transacción.

## Trabajo recomendado

1. Corregir permisos e inmutabilidad de referencias. Añadir pruebas de reglas con paciente, profesional actual, anterior y tercero.
2. Definir aislamiento y transferencia de registros, notas y conversaciones al reasignar.
3. Resolver consentimiento, migración y sincronización; probar cambios rápidos y fallos parciales.
4. Corregir los errores funcionales de Web, navegación, altas y chat.
5. Verificar firma de producción y después limpiar advertencias del analizador.

Las pruebas críticas deben incluir un intento de modificar `userRef`/`psychologistRef`, lectura tras reasignación, backfill con consentimiento apagado, eventos de privacidad ejecutados fuera de orden, aislamiento de notas e historial de chat y un alta que falle después de crear el usuario de Auth.
