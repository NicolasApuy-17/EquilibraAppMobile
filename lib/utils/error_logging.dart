import 'dart:async';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:firebase_crashlytics/firebase_crashlytics.dart';

import '/auth/firebase_auth/auth_util.dart';
import '/backend/backend.dart';

/// Records an unhandled error two places: Crashlytics (full native stack
/// trace, viewable only in the Firebase Console) and the `app_errors`
/// Firestore collection (a short summary, viewable from the admin panel's
/// own "Incidencias" tab). Never throws itself -- a logging failure must
/// never crash the app or surface anything to the user.
Future<void> logAppError({
  required String context,
  required Object error,
  StackTrace? stackTrace,
  bool fatal = false,
}) async {
  // Exception messages can contain document payloads, emails or clinical text.
  // Retain the error category/code and stack without uploading the raw message.
  final safeMessage = error is FirebaseException
      ? '${error.plugin}/${error.code}'
      : error.runtimeType.toString();
  // Crashlytics has no web plugin implementation -- calling it there throws
  // an assertion failure ("pluginConstants['isCrashlyticsCollectionEnabled']
  // != null is not true") on every single logAppError call. `unawaited`
  // keeps that from blocking the Firestore write below, but it's still an
  // uncaught error printed to the console on every report; skip it outright
  // on web instead.
  if (!kIsWeb) {
    try {
      await FirebaseCrashlytics.instance.recordError(
        safeMessage,
        stackTrace,
        reason: context,
        fatal: fatal,
      );
    } catch (_) {
      // Keep the Firestore fallback available if the native reporter fails.
    }
  }

  try {
    await AppErrorsRecord.collection.add(createAppErrorsRecordData(
      context: context,
      message: safeMessage,
      stackTrace: stackTrace?.toString().split('\n').take(20).join('\n'),
      userRef: currentUserReference,
      role: currentUserDocument?.role,
      createdTime: DateTime.now(),
    ));
  } catch (_) {
    // Firestore write failed (e.g. offline, or not signed in yet) --
    // Crashlytics above already has the report either way.
  }
}
