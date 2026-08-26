import 'package:firebase_auth/firebase_auth.dart';

/// Traduce los códigos de error más comunes de Firebase Auth a mensajes en
/// español que la persona usuaria pueda entender, en vez del mensaje técnico
/// en inglés que trae `FirebaseAuthException.message`.
String firebaseAuthErrorMessage(FirebaseAuthException e) {
  switch (e.code) {
    case 'email-already-in-use':
      return 'Ese correo electrónico ya está registrado. Intenta iniciar sesión.';
    case 'invalid-email':
      return 'El correo electrónico no es válido.';
    case 'weak-password':
      return 'La contraseña es demasiado débil. Usa al menos 8 caracteres.';
    case 'network-request-failed':
      return 'No hay conexión a internet. Verifica tu red e intenta nuevamente.';
    case 'user-not-found':
      return 'No existe una cuenta con ese correo electrónico.';
    case 'wrong-password':
    case 'INVALID_LOGIN_CREDENTIALS':
      return 'El correo o la contraseña son incorrectos.';
    case 'user-disabled':
      return 'Esta cuenta ha sido deshabilitada. Contacta a soporte.';
    case 'too-many-requests':
      return 'Demasiados intentos. Espera unos minutos e intenta nuevamente.';
    case 'requires-recent-login':
      return 'Por seguridad, vuelve a iniciar sesión para completar esta acción.';
    default:
      return e.message ?? 'Ocurrió un error inesperado. Intenta nuevamente.';
  }
}

/// Mensaje genérico en español para errores de Firestore/Storage u otros
/// fallos no relacionados con autenticación (parsing, red, permisos, etc.).
/// [action] describe brevemente qué se intentaba hacer, p. ej. "guardar tu
/// perfil", para que el mensaje sea específico sin repetir este helper por
/// cada pantalla.
String genericSaveErrorMessage(String action) =>
    'No se pudo $action. Intenta nuevamente.';
