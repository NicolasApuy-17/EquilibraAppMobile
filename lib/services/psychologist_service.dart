import 'package:cloud_functions/cloud_functions.dart';

/// A user-facing error from the psychologist-module flows. [message] is
/// always safe to show directly in the UI.
class PsychologistServiceException implements Exception {
  const PsychologistServiceException(this.message);

  final String message;

  @override
  String toString() => message;
}

/// Talks to the `createPsychologist`, `linkPsychologistByCode`,
/// `adminAssignPsychologist` and `sendConversationMessage` Cloud Functions:
/// the rest of the app never calls Cloud Functions directly, and never sees
/// a raw [FirebaseFunctionsException].
class PsychologistService {
  PsychologistService({FirebaseFunctions? functions})
      : _functionsOverride = functions;

  final FirebaseFunctions? _functionsOverride;

  FirebaseFunctions get _functions =>
      _functionsOverride ?? FirebaseFunctions.instance;

  /// Admin-only: creates a new psychologist account (Firebase Auth user +
  /// their `users/{uid}` Firestore document with role `'psicologo'`).
  /// Returns the generated link code (e.g. "FABRIZZIO-4821") patients use
  /// to connect to this psychologist.
  Future<String> createPsychologist({
    required String displayName,
    required String email,
    required String specialty,
    required String password,
  }) async {
    try {
      final result =
          await _functions.httpsCallable('createPsychologist').call(<String, dynamic>{
        'displayName': displayName,
        'email': email,
        'specialty': specialty,
        'password': password,
      });
      final data = result.data;
      final linkCode = data is Map ? data['linkCode'] : null;
      return linkCode is String ? linkCode : '';
    } on FirebaseFunctionsException catch (e) {
      throw PsychologistServiceException(_messageForCode(e.code, e.message));
    } catch (_) {
      throw const PsychologistServiceException(
        'No pudimos conectarnos en este momento. Revisa tu conexión e inténtalo nuevamente.',
      );
    }
  }

  /// Links the current patient to the psychologist owning [code] (e.g.
  /// "FABRIZZIO-4821") and creates their shared conversation. Returns the
  /// conversation id (the caller's own uid). Fails if the patient already
  /// has a psychologist assigned.
  Future<String> linkPsychologistByCode(String code) async {
    try {
      final result = await _functions
          .httpsCallable('linkPsychologistByCode')
          .call(<String, dynamic>{'code': code});
      final data = result.data;
      final conversationId = data is Map ? data['conversationId'] : null;
      if (conversationId is String && conversationId.isNotEmpty) {
        return conversationId;
      }
      throw const PsychologistServiceException(
        'No se pudo vincular al psicólogo. Intenta nuevamente.',
      );
    } on FirebaseFunctionsException catch (e) {
      throw PsychologistServiceException(_messageForCode(e.code, e.message));
    } on PsychologistServiceException {
      rethrow;
    } catch (_) {
      throw const PsychologistServiceException(
        'No pudimos conectarnos en este momento. Revisa tu conexión e inténtalo nuevamente.',
      );
    }
  }

  /// Admin-only: assigns or reassigns [patientId] to [psychologistId],
  /// overwriting any existing assignment, and creates/updates their shared
  /// conversation.
  Future<void> adminAssignPsychologist({
    required String patientId,
    required String psychologistId,
  }) async {
    try {
      await _functions.httpsCallable('adminAssignPsychologist').call(<String, dynamic>{
        'patientId': patientId,
        'psychologistId': psychologistId,
      });
    } on FirebaseFunctionsException catch (e) {
      throw PsychologistServiceException(_messageForCode(e.code, e.message));
    } catch (_) {
      throw const PsychologistServiceException(
        'No pudimos conectarnos en este momento. Revisa tu conexión e inténtalo nuevamente.',
      );
    }
  }

  /// Admin-only: changes [uid]'s role to [newRole] ('paciente', 'psicologo'
  /// or 'admin'). Returns the new role, plus a `linkCode` if [uid] just
  /// became a psychologist. Fails if [uid] is a psychologist who still has
  /// patients assigned (reassign them first) and is leaving that role.
  Future<Map<String, dynamic>> setUserRole({
    required String uid,
    required String newRole,
  }) async {
    try {
      final result = await _functions.httpsCallable('setUserRole').call(<String, dynamic>{
        'uid': uid,
        'newRole': newRole,
      });
      final data = result.data;
      return data is Map ? Map<String, dynamic>.from(data) : {};
    } on FirebaseFunctionsException catch (e) {
      throw PsychologistServiceException(_messageForCode(e.code, e.message));
    } catch (_) {
      throw const PsychologistServiceException(
        'No pudimos conectarnos en este momento. Revisa tu conexión e inténtalo nuevamente.',
      );
    }
  }

  /// Admin-only: activates or deactivates [uid]'s account. Disables the
  /// underlying Firebase Auth user too (not just a Firestore flag), so a
  /// deactivated account can't sign in again or keep an existing session
  /// alive past its next token refresh.
  Future<void> setAccountActive({required String uid, required bool active}) async {
    try {
      await _functions.httpsCallable('setAccountActive').call(<String, dynamic>{
        'uid': uid,
        'active': active,
      });
    } on FirebaseFunctionsException catch (e) {
      throw PsychologistServiceException(_messageForCode(e.code, e.message));
    } catch (_) {
      throw const PsychologistServiceException(
        'No pudimos conectarnos en este momento. Revisa tu conexión e inténtalo nuevamente.',
      );
    }
  }

  /// Admin-only diagnostic: compares [patientId]'s stored `psychologistRef`
  /// against a freshly reconstructed reference to the same uid, and reports
  /// whether Firestore's `==` filter finds the patient using each. Returns
  /// the raw map from the Cloud Function (see `adminDiagnosePatientLink`).
  Future<Map<String, dynamic>> diagnosePatientLink(String patientId) async {
    try {
      final result = await _functions
          .httpsCallable('adminDiagnosePatientLink')
          .call(<String, dynamic>{'patientId': patientId});
      final data = result.data;
      return data is Map ? Map<String, dynamic>.from(data) : {};
    } on FirebaseFunctionsException catch (e) {
      throw PsychologistServiceException(_messageForCode(e.code, e.message));
    } catch (_) {
      throw const PsychologistServiceException(
        'No pudimos conectarnos en este momento. Revisa tu conexión e inténtalo nuevamente.',
      );
    }
  }

  /// Sends a chat message in [conversationId] (either participant may call
  /// this — the backend verifies the caller is actually a participant).
  Future<void> sendConversationMessage({
    required String conversationId,
    required String text,
  }) async {
    final trimmed = text.trim();
    if (trimmed.isEmpty) {
      throw const PsychologistServiceException('El mensaje está vacío.');
    }
    try {
      await _functions
          .httpsCallable('sendConversationMessage')
          .call(<String, dynamic>{
        'conversationId': conversationId,
        'text': trimmed,
      });
    } on FirebaseFunctionsException catch (e) {
      throw PsychologistServiceException(_messageForCode(e.code, e.message));
    } catch (_) {
      throw const PsychologistServiceException(
        'No pudimos conectarnos en este momento. Revisa tu conexión e inténtalo nuevamente.',
      );
    }
  }

  String _messageForCode(String code, String? serverMessage) {
    switch (code) {
      case 'unauthenticated':
        return 'Debes iniciar sesión para continuar.';
      case 'permission-denied':
        return serverMessage ?? 'No tienes permiso para realizar esta acción.';
      case 'invalid-argument':
        return serverMessage ?? 'Revisa los datos ingresados e intenta nuevamente.';
      case 'already-exists':
        return serverMessage ?? 'Ese correo electrónico ya está registrado.';
      case 'not-found':
        return serverMessage ?? 'No se encontró lo que buscabas.';
      case 'failed-precondition':
        return serverMessage ?? 'No se pudo completar la acción en este momento.';
      case 'unavailable':
      case 'internal':
        return 'El servicio no está disponible en este momento. Inténtalo nuevamente.';
      default:
        return 'No pudimos conectarnos en este momento. Revisa tu conexión e inténtalo nuevamente.';
    }
  }
}
