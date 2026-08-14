import 'package:cloud_functions/cloud_functions.dart';

/// Who authored a message in the chatbot conversation.
enum ChatMessageRole { user, assistant }

/// A single turn of the chatbot conversation, kept only in memory for the
/// lifetime of the chat screen (see [ChatbotService.sendMessage]).
class ChatMessage {
  const ChatMessage({required this.role, required this.content});

  final ChatMessageRole role;
  final String content;
}

/// A user-facing error from the chatbot flow. [message] is always safe to
/// show directly in the UI (never contains raw backend/stack details).
class ChatbotException implements Exception {
  const ChatbotException(this.message);

  final String message;

  @override
  String toString() => message;
}

/// Talks to the `chatWithGemini` Firebase Cloud Function so the rest of the
/// app never needs to know about Cloud Functions, Gemini, or the API key —
/// all of that lives exclusively on the backend.
///
/// This intentionally keeps no state of its own: the calling screen owns the
/// conversation history and passes whatever context is needed on each call,
/// which keeps the door open for a future Firestore-backed history without
/// having to change this service's shape.
class ChatbotService {
  ChatbotService({FirebaseFunctions? functions}) : _functionsOverride = functions;

  final FirebaseFunctions? _functionsOverride;

  // Resolved lazily (only once a message is actually sent) rather than at
  // construction time, so simply creating a ChatbotService — e.g. as a
  // State field — never requires Firebase to already be initialized. This
  // matters for widget tests that build screens without a real Firebase app.
  FirebaseFunctions get _functions =>
      _functionsOverride ?? FirebaseFunctions.instance;

  /// Only the most recent turns are sent for context; the backend enforces
  /// its own (lower) cap regardless, this just avoids sending a needlessly
  /// large payload as the conversation grows.
  static const int maxHistoryTurns = 8;

  Future<String> sendMessage({
    required String message,
    List<ChatMessage> history = const [],
  }) async {
    final trimmed = message.trim();
    if (trimmed.isEmpty) {
      throw const ChatbotException('El mensaje está vacío.');
    }

    final recentHistory = history.length > maxHistoryTurns
        ? history.sublist(history.length - maxHistoryTurns)
        : history;

    try {
      final callable = _functions.httpsCallable('chatWithGemini');
      final result = await callable.call(<String, dynamic>{
        'message': trimmed,
        'history': recentHistory
            .map((entry) => <String, String>{
                  'role': entry.role == ChatMessageRole.assistant
                      ? 'assistant'
                      : 'user',
                  'content': entry.content,
                })
            .toList(),
      });

      final data = result.data;
      final reply = data is Map ? data['reply'] : null;
      if (reply is String && reply.trim().isNotEmpty) {
        return reply.trim();
      }

      throw const ChatbotException(
        'El asistente no está disponible en este momento. Inténtalo nuevamente.',
      );
    } on FirebaseFunctionsException catch (e) {
      throw ChatbotException(_messageForCode(e.code));
    } on ChatbotException {
      rethrow;
    } catch (_) {
      // Anything else (no connectivity, DNS failure, timeout, ...).
      throw const ChatbotException(
        'No pudimos conectarnos en este momento. Revisa tu conexión e inténtalo nuevamente.',
      );
    }
  }

  String _messageForCode(String code) {
    switch (code) {
      case 'unauthenticated':
        return 'Debes iniciar sesión para usar el asistente.';
      case 'invalid-argument':
        return 'No pudimos enviar ese mensaje. Intenta con un texto más breve.';
      case 'already-exists':
        return 'Ya estamos procesando ese mensaje.';
      case 'resource-exhausted':
        return 'Has alcanzado temporalmente el límite de consultas. Inténtalo más tarde.';
      case 'unavailable':
      case 'internal':
      case 'not-found':
        return 'El asistente no está disponible en este momento. Inténtalo nuevamente.';
      default:
        return 'No pudimos conectarnos en este momento. Revisa tu conexión e inténtalo nuevamente.';
    }
  }
}
