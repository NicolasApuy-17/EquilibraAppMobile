import 'dart:convert';
import 'dart:ui';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:equilibra/main.dart' as app;
import 'package:equilibra/index.dart';
import 'package:equilibra/auth/firebase_auth/auth_util.dart';
import 'package:equilibra/flutter_flow/nav/nav.dart';
import 'package:equilibra/services/psychologist_service.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Pixel Android: account, records, sharing, sessions and privacy',
      (tester) async {
    await Firebase.initializeApp();
    // The Pixel's 10.0.2.2 points only at the host's LOCAL emulator suite.
    // These calls run before any application listeners or database operations.
    final auth = FirebaseAuth.instance;
    final db = FirebaseFirestore.instance;
    await auth.useAuthEmulator('10.0.2.2', 9098);
    db.useFirestoreEmulator('10.0.2.2', 8188);
    FirebaseStorage.instance.useStorageEmulator('10.0.2.2', 9299);
    FirebaseFunctions.instance.useFunctionsEmulator('10.0.2.2', 5008);
    await auth.signOut();
    final testErrorHandler = FlutterError.onError;
    final testAsyncErrorHandler = PlatformDispatcher.instance.onError;
    app.main();
    addTearDown(() {
      FlutterError.onError = testErrorHandler;
      PlatformDispatcher.instance.onError = testAsyncErrorHandler;
    });

    Future<void> waitFor(Finder finder) async {
      for (var i = 0; i < 120; i++) {
        await tester.pump(const Duration(milliseconds: 500));
        if (finder.evaluate().isNotEmpty) return;
      }
      fail('Timed out waiting for $finder; authenticated UID: ${auth.currentUser?.uid}');
    }

    Future<void> tapText(String label) async {
      await waitFor(find.text(label));
      // A screen title can repeat the button label. Target the actual button.
      final buttons = find.ancestor(
        of: find.text(label),
        matching: find.byWidgetPredicate((widget) => widget is ButtonStyleButton),
      );
      final finder = buttons.evaluate().isNotEmpty ? buttons.last : find.text(label).last;
      await tester.ensureVisible(finder);
      await tester.pump(const Duration(milliseconds: 300));
      await tester.tap(finder);
      await tester.pump(const Duration(seconds: 1));
    }

    Future<void> go(String route,
        {Map<String, String> query = const {}}) async {
      final context = tester.element(find.byType(Scaffold).last);
      GoRouter.of(context).goNamed(route, queryParameters: query);
      await tester.pump(const Duration(seconds: 2));
    }

    Future<void> enter(int index, String text) async {
      await waitFor(find.byType(EditableText));
      final field = find.byType(EditableText).at(index);
      await tester.ensureVisible(field);
      await tester.enterText(field, text);
      FocusManager.instance.primaryFocus?.unfocus();
      await tester.pump(const Duration(milliseconds: 300));
    }

    Future<void> logout() async {
      final router = GoRouter.of(tester.element(find.byType(Scaffold).last));
      router.prepareAuthEvent();
      await authManager.signOut();
      router.clearRedirectLocation();
      router.goNamed(LoginScreenWidget.routeName);
      await tester.pump(const Duration(seconds: 2));
      await waitFor(find.byType(LoginScreenWidget));
    }

    await waitFor(find.byType(Scaffold));
    // Preserve the test binding's exception collection after app startup.
    FlutterError.onError = testErrorHandler;
    PlatformDispatcher.instance.onError = testAsyncErrorHandler;
    await tester.pump(const Duration(seconds: 3));
    await tapText('Crear una cuenta');
    await waitFor(find.byType(CreateAccountScreenWidget));
    await enter(0, 'Paciente Prueba');
    await enter(1, 'pixel-patient@example.com');
    await enter(2, 'PixelTest2026!');
    await enter(3, 'PixelTest2026!');
    await tester.ensureVisible(find.byType(Checkbox));
    await tester.tap(find.byType(Checkbox));
    await tapText('Crear cuenta');
    await waitFor(find.byType(HomeScreenWidget));
    expect(auth.currentUser?.email, 'pixel-patient@example.com');
    final patient = db.doc('users/${auth.currentUser!.uid}');
    expect((await patient.get()).data()?['role'], 'paciente');
    debugPrint('PIXEL PASS: account creation through UI');

    await go(LinkPsychologistWidget.routeName);
    await enter(0, 'PIXEL-2026');
    await tapText('Vincular');
    await waitFor(find.byType(PsychologistChatWidget));
    final conversation =
        (await patient.get()).data()?['activeConversationId'] as String;
    await PsychologistService().sendConversationMessage(
        conversationId: conversation,
        text: 'Prueba de chat Pixel',
        messageId: 'pixel-retry',
        resolvePatientAlias: false);
    await PsychologistService().sendConversationMessage(
        conversationId: conversation,
        text: 'Prueba de chat Pixel',
        messageId: 'pixel-retry',
        resolvePatientAlias: false);
    expect(
        (await db.collection('conversations/$conversation/messages').get())
            .size,
        1);
    debugPrint('PIXEL PASS: linking and idempotent chat via Cloud Functions');

    final professional = db.doc('users/pixel-test-psychologist');
    await db.collection('records').add({
      'userRef': patient,
      'psychologistRef': professional,
      'emotion': 'Tranquilo',
      'description': 'Registro Pixel',
      'timestamp': Timestamp.now(),
      'intensity': 4
    });
    await db.collection('behavioral_records').add({
      'userRef': patient,
      'psychologistRef': professional,
      'behaviorType': 'Meditación',
      'date': Timestamp.now(),
      'createdAt': Timestamp.now(),
      'value': 'Sí'
    });
    await db.collection('goals').add({
      'userRef': patient,
      'title': 'Objetivo Pixel',
      'completed': false,
      'steps': []
    });
    await db.collection('tasks').add({
      'userRef': patient,
      'psychologistRef': professional,
      'createdByRef': patient,
      'title': 'Tarea Pixel',
      'status': 'pendiente'
    });
    final session = await db.collection('session_requests').add({
      'patientRef': patient,
      'psychologistRef': professional,
      'status': 'pendiente',
      'requestedDate':
          Timestamp.fromDate(DateTime.now().add(const Duration(days: 2))),
      'createdAt': Timestamp.now()
    });
    for (final route in [
      MyRecordsWidget.routeName,
      TasksWidget.routeName,
      ScheduleSessionWidget.routeName
    ]) {
      await go(route);
      await tester.pump(const Duration(seconds: 2));
      expect(tester.takeException(), isNull);
    }
    debugPrint(
        'PIXEL PASS: Android Firestore records, behavior, goals, tasks and sessions');

    // Real PNG through the Android Firebase Storage plugin, not a mocked upload.
    final photo = FirebaseStorage.instance.ref('users/${patient.id}/pixel.png');
    await photo.putData(
        base64Decode(
            'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mP8/x8AAwMCAO+ael0AAAAASUVORK5CYII='),
        SettableMetadata(contentType: 'image/png'));
    expect(await photo.getDownloadURL(), contains('pixel.png'));
    await photo.delete();
    debugPrint('PIXEL PASS: image upload and download URL');

    await go(UserProfileWidget.routeName);
    await tapText('Privacidad y Datos');
    await waitFor(find.text('Solicitar eliminación de cuenta'));
    expect(find.text('Política de Privacidad'), findsOneWidget);
    await tester.ensureVisible(find.byType(Switch));
    await tester.tap(find.byType(Switch));
    await tester.pump(const Duration(seconds: 2));
    expect((await patient.get()).data()?['shareDataWithPsychologist'], false);
    await tapText('Entendido');
    await go(SupportContactWidget.routeName);
    expect(find.text('Contacto de Apoyo'), findsOneWidget);
    await go(TermsPrivacyWidget.routeName);
    await tester.pump(const Duration(seconds: 1));
    expect(tester.takeException(), isNull);
    debugPrint(
        'PIXEL PASS: profile privacy, deletion route, support and legal page');

    await auth.sendPasswordResetEmail(email: 'pixel-patient@example.com');
    await logout();
    await enter(0, 'pixel-psychologist@example.com');
    await enter(1, 'PixelTest2026!');
    await tapText('Iniciar sesión');
    await waitFor(find.byType(PsychologistHomeWidget));
    expect(auth.currentUser?.uid, professional.id);
    await expectLater(
        db.collection('records').where('userRef', isEqualTo: patient).get(),
        throwsA(isA<FirebaseException>()));
    await session
        .update({'status': 'confirmada', 'respondedAt': Timestamp.now()});
    // Sessions remain authorized while the patient has sharing off.
    expect((await session.get()).data()?['status'], 'confirmada');
    debugPrint(
        'PIXEL PASS: psychologist login, privacy denial and session confirmation');

    await logout();
    await enter(0, 'pixel-patient@example.com');
    await enter(1, 'PixelTest2026!');
    await tapText('Iniciar sesión');
    await waitFor(find.byType(HomeScreenWidget));
    await patient.update({'shareDataWithPsychologist': true});
    await logout();
    await auth.signInWithEmailAndPassword(
        email: 'pixel-psychologist@example.com', password: 'PixelTest2026!');
    expect(
        (await db
                .collection('records')
                .where('userRef', isEqualTo: patient)
                .get())
            .size,
        1);
    await go(PsychologistPatientDetailWidget.routeName,
        query: {'patientId': patient.id});
    await waitFor(find.byType(PsychologistPatientDetailWidget));
    await tapText('Registros');
    await tester.pump(const Duration(seconds: 2));
    expect(tester.takeException(), isNull);
    await auth.signOut();
    debugPrint(
        'PIXEL PASS: patient re-login and psychologist record visibility restored');
  }, timeout: const Timeout(Duration(minutes: 12)));
}
