import 'package:cloud_functions/cloud_functions.dart';

/// A user-facing error from the psychologist-module flows. [message] is
/// always safe to show directly in the UI.
class PsychologistServiceException implements Exception {
  const PsychologistServiceException(this.message);

  final String message;

  @override
  String toString() => message;
}

/// Talks to the `createPsychologist`, `assignPsychologist` and
/// `sendConversationMessage` Cloud Functions: the rest of the app never
/// calls Cloud Functions directly, and never sees a raw
/// [FirebaseFunctionsException].
class PsychologistService {
  PsychologistService({FirebaseFunctions? functions})
      : _functionsOverride = functions;

  final FirebaseFunctions? _functionsOverride;

  FirebaseFunctions get _functions =>
      _functionsOverride ?? FirebaseFunctions.instance;

  /// Admin-only: creates a new psychologist account (Firebase Auth user +
  /// their `users/{uid}` Firestore document with role `'psicologo'`).
  Future<void> createPsychologist({
    required String displayName,
    required String email,
    required String specialty,
    required String password,
  }) async {
    try {
      await _functions.httpsCallable('createPsychologist').call(<String, dynamic>{
        'displayName': displayName,
        'email': email,
        'specialty': specialty,
        'password': password,
      });
    } on FirebaseFunctionsException catch (e) {
      throw PsychologistServiceException(_messageForCode(e.code, e.message));
    } catch (_) {
      throw const PsychologistServiceException(
        'No pudimos conectarnos en este momento. Revisa tu conexión e inténtalo nuevamente.',
      );
    }
  }

  /// Assigns [psychologistId] as the current patient's psychologist and
  /// creates their shared conversation. Returns the conversation id (the
  /// caller's own uid).
  Future<String> assignPsychologist(String psychologistId) async {
    try {
      final result = await _functions
          .httpsCallable('assignPsychologist')
          .call(<String, dynamic>{'psychologistId': psychologistId});
      final data = result.data;
      final conversationId = data is Map ? data['conversationId'] : null;
      if (conversationId is String && conversationId.isNotEmpty) {
        return conversationId;
      }
      throw const PsychologistServiceException(
        'No se pudo asignar el psicólogo. Intenta nuevamente.',
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
      case 'unavailable':
      case 'internal':
        return 'El servicio no está disponible en este momento. Inténtalo nuevamente.';
      default:
        return 'No pudimos conectarnos en este momento. Revisa tu conexión e inténtalo nuevamente.';
    }
  }
}
