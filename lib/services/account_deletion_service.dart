import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_functions/cloud_functions.dart';

class AccountDeletionException implements Exception {
  const AccountDeletionException(this.message);
  final String message;
  @override
  String toString() => message;
}

class AccountDeletionService {
  Future<void> deleteAccount({
    required String password,
    required String confirmationEmail,
    String? targetUid,
  }) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null || user.email == null) {
      throw const AccountDeletionException(
          'Inicia sesión nuevamente para continuar.');
    }
    try {
      await user.reauthenticateWithCredential(EmailAuthProvider.credential(
        email: user.email!,
        password: password,
      ));
      await user.getIdToken(true);
      final result = await FirebaseFunctions.instance
          .httpsCallable(
        targetUid == null ? 'deleteMyAccount' : 'adminDeleteAccount',
        options: HttpsCallableOptions(timeout: const Duration(minutes: 9)),
      )
          .call(<String, dynamic>{
        'confirmationEmail': confirmationEmail.trim(),
        if (targetUid != null) 'uid': targetUid,
      });
      if (result.data is! Map || result.data['deleted'] != true) {
        throw const AccountDeletionException(
            'No se confirmó la eliminación. Inténtalo nuevamente.');
      }
    } on FirebaseAuthException catch (error) {
      throw AccountDeletionException(switch (error.code) {
        'wrong-password' ||
        'invalid-credential' ||
        'INVALID_LOGIN_CREDENTIALS' =>
          'La contraseña es incorrecta. Tu cuenta no se ha eliminado.',
        'too-many-requests' =>
          'Demasiados intentos. Espera unos minutos y vuelve a intentarlo.',
        'network-request-failed' =>
          'Revisa tu conexión e inténtalo nuevamente.',
        _ => 'No se pudo verificar tu identidad. Inicia sesión nuevamente.',
      });
    } on FirebaseFunctionsException catch (error) {
      throw AccountDeletionException(switch (error.code) {
        'permission-denied' ||
        'invalid-argument' ||
        'failed-precondition' =>
          error.message ?? 'No se pudo completar la eliminación.',
        'unauthenticated' => 'Inicia sesión nuevamente para continuar.',
        _ =>
          'No se confirmó la eliminación. Revisa tu conexión antes de reintentar.',
      });
    }
  }
}
