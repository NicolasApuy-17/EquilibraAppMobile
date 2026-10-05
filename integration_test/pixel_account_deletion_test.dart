import 'dart:ui';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:equilibra/main.dart' as app;
import 'package:equilibra/index.dart';
import 'package:equilibra/components/profile_avatar_button.dart';
import 'package:equilibra/components/delete_my_account_button.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  testWidgets(
      'Pixel: admin and psychologist profiles, last admin protection and verified deletion',
      (tester) async {
    await Firebase.initializeApp();
    final auth = FirebaseAuth.instance;
    final db = FirebaseFirestore.instance;
    await auth.useAuthEmulator('10.0.2.2', 9098);
    db.useFirestoreEmulator('10.0.2.2', 8188);
    FirebaseStorage.instance.useStorageEmulator('10.0.2.2', 9299);
    FirebaseFunctions.instance.useFunctionsEmulator('10.0.2.2', 5008);
    await auth.signOut();
    final errorHandler = FlutterError.onError;
    final asyncHandler = PlatformDispatcher.instance.onError;
    app.main();
    addTearDown(() {
      FlutterError.onError = errorHandler;
      PlatformDispatcher.instance.onError = asyncHandler;
    });
    Future<void> waitFor(Finder finder) async {
      for (var n = 0; n < 120; n++) {
        await tester.pump(const Duration(milliseconds: 500));
        if (finder.evaluate().isNotEmpty) return;
      }
      fail('Timed out: $finder');
    }

    Future<void> tap(String label) async {
      await waitFor(find.text(label));
      final buttons = find.ancestor(
          of: find.text(label),
          matching: find.byWidgetPredicate((w) => w is ButtonStyleButton));
      final target =
          buttons.evaluate().isNotEmpty ? buttons.last : find.text(label).last;
      await tester.ensureVisible(target);
      await tester.pump(const Duration(milliseconds: 300));
      await tester.tap(target);
      await tester.pump(const Duration(seconds: 1));
    }

    Future<void> enter(int index, String value) async {
      final field = find.byType(EditableText).at(index);
      await tester.ensureVisible(field);
      await tester.enterText(field, value);
      FocusManager.instance.primaryFocus?.unfocus();
      await tester.pump(const Duration(milliseconds: 300));
    }

    await waitFor(find.byType(Scaffold));
    FlutterError.onError = errorHandler;
    PlatformDispatcher.instance.onError = asyncHandler;
    await tester.pump(const Duration(seconds: 3));
    await tap('Iniciar sesión');
    await waitFor(find.byType(LoginScreenWidget));
    await enter(0, 'pixel-delete-admin@example.com');
    await enter(1, 'PixelTest2026!');
    await tap('Iniciar sesión');
    await waitFor(find.byType(AdminPsychologistsWidget));
    await tap('Usuarios');
    await enter(0, 'pixel-delete-patient@example.com');
    await tester.pump(const Duration(seconds: 1));
    await tap('Eliminar cuenta');
    final dialogFields = find.descendant(
        of: find.byType(AlertDialog), matching: find.byType(EditableText));
    Future<void> enterDialog(int index, String value) async {
      final field = dialogFields.at(index);
      await tester.ensureVisible(field);
      await tester.tap(field);
      // Let Android reopen its input connection after a disabled verification field.
      await tester.pump(const Duration(milliseconds: 700));
      await tester.enterText(field, value);
      FocusManager.instance.primaryFocus?.unfocus();
      await tester.pump(const Duration(milliseconds: 300));
      expect(tester.widget<EditableText>(field).controller.text, value);
    }

    await enterDialog(0, 'pixel-delete-patient@example.com');
    await enterDialog(1, 'incorrecta');
    await tap('Eliminar definitivamente');
    await waitFor(find
        .text('La contraseña es incorrecta. Tu cuenta no se ha eliminado.'));
    expect((await db.doc('users/pixel-deletion-patient').get()).exists, true);
    await tester.pump(const Duration(seconds: 2));
    await enterDialog(1, 'PixelTest2026!');
    await tap('Eliminar definitivamente');
    await waitFor(find
        .text('Cuenta eliminada. Sus datos personales se están eliminando.'));
    expect(auth.currentUser?.uid, 'pixel-deletion-admin');
    debugPrint(
        'PIXEL PASS: wrong password rejected; administrator deletes only selected account');

    await tester.tap(find.byType(ProfileAvatarButton));
    await waitFor(find.byType(AccountPanelWidget));
    expect(find.byType(DeleteMyAccountButton), findsOneWidget);
    await tap('Eliminar mi cuenta');
    await enterDialog(0, 'pixel-delete-admin@example.com');
    await enterDialog(1, 'PixelTest2026!');
    await tap('Eliminar definitivamente');
    await waitFor(find.text(
        'No puedes eliminar la única cuenta de administrador disponible. Debe quedar otro administrador activo con acceso.'));
    expect(auth.currentUser?.uid, 'pixel-deletion-admin');
    expect((await db.doc('users/pixel-deletion-admin').get()).exists, true);
    debugPrint(
        'PIXEL PASS: last administrator kept; clear explanation shown in profile confirmation');
    await FirebaseFunctions.instance.httpsCallable('setUserRole').call({
      'uid': 'pixel-deletion-backup',
      'newRole': 'admin',
    });
    await tester.pump(const Duration(seconds: 2));
    await enterDialog(1, 'PixelTest2026!');
    await tap('Eliminar definitivamente');
    await waitFor(find.byType(TestScreenWidget));
    expect(auth.currentUser, isNull);
    await expectLater(
        auth.signInWithEmailAndPassword(
            email: 'pixel-delete-admin@example.com',
            password: 'PixelTest2026!'),
        throwsA(isA<FirebaseAuthException>()));
    expect(tester.takeException(), isNull);
    debugPrint(
        'PIXEL PASS: administrator profile deletes own account with a backup and logs out');

    await tap('Iniciar sesión');
    await waitFor(find.byType(LoginScreenWidget));
    await enter(0, 'pixel-delete-psychologist@example.com');
    await enter(1, 'PixelTest2026!');
    await tap('Iniciar sesión');
    await waitFor(find.byType(PsychologistHomeWidget));
    await tester.tap(find.byType(ProfileAvatarButton));
    await waitFor(find.byType(AccountPanelWidget));
    expect(find.byType(DeleteMyAccountButton), findsOneWidget);
    await tap('Eliminar mi cuenta');
    await enterDialog(0, 'pixel-delete-psychologist@example.com');
    await enterDialog(1, 'PixelTest2026!');
    await tap('Eliminar definitivamente');
    await waitFor(find.byType(TestScreenWidget));
    expect(auth.currentUser, isNull);
    await expectLater(
        auth.signInWithEmailAndPassword(
            email: 'pixel-delete-psychologist@example.com',
            password: 'PixelTest2026!'),
        throwsA(isA<FirebaseAuthException>()));
    expect(tester.takeException(), isNull);
    debugPrint(
        'PIXEL PASS: psychologist profile deletes own account with verification and logs out');
  }, timeout: const Timeout(Duration(minutes: 10)));
}
