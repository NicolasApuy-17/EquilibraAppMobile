import 'dart:async';
import 'package:equilibra/components/account_deletion_dialog.dart';
import 'package:equilibra/services/account_deletion_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Future<void> open(
      WidgetTester tester, Future<void> Function(String, String) confirm,
      {bool admin = false}) async {
    await tester.pumpWidget(MaterialApp(
        home: Scaffold(
            body: Builder(
      builder: (context) => TextButton(
        onPressed: () => showAccountDeletionDialog(
            context: context,
            targetEmail: 'patient@example.com',
            adminMode: admin,
            onConfirm: confirm),
        child: const Text('Abrir'),
      ),
    ))));
    await tester.tap(find.text('Abrir'));
    await tester.pumpAndSettle();
  }

  testWidgets('cancel and an unconfirmed email never request deletion',
      (tester) async {
    var calls = 0;
    await open(tester, (_, __) async {
      calls++;
    });
    await tester.enterText(find.byType(TextField).at(0), 'other@example.com');
    await tester.enterText(find.byType(TextField).at(1), 'password');
    await tester.tap(find.text('Eliminar definitivamente'));
    await tester.pumpAndSettle();
    expect(calls, 0);
    expect(
        find.text('Escribe el correo indicado y tu contraseña para confirmar.'),
        findsOneWidget);
    await tester.tap(find.text('Cancelar'));
    await tester.pumpAndSettle();
    expect(find.byType(AccountDeletionDialog), findsNothing);
  });

  testWidgets(
      'a verification failure keeps the dialog open and permits a retry',
      (tester) async {
    var calls = 0;
    await open(tester, (password, email) async {
      calls++;
      if (password != 'correct')
        throw const AccountDeletionException('Contraseña incorrecta');
      expect(email, 'patient@example.com');
    });
    await tester.enterText(find.byType(TextField).at(0), 'patient@example.com');
    await tester.enterText(find.byType(TextField).at(1), 'wrong');
    await tester.tap(find.text('Eliminar definitivamente'));
    await tester.pumpAndSettle();
    expect(find.text('Contraseña incorrecta'), findsOneWidget);
    expect(
        tester.widget<TextField>(find.byType(TextField).at(1)).controller!.text,
        isEmpty);
    await tester.enterText(find.byType(TextField).at(1), 'correct');
    await tester.tap(find.text('Eliminar definitivamente'));
    await tester.pumpAndSettle();
    expect(calls, 2);
    expect(find.byType(AccountDeletionDialog), findsNothing);
  });

  testWidgets(
      'admin confirmation uses the admin password and prevents duplicate requests',
      (tester) async {
    var calls = 0;
    final pending = Completer<void>();
    await open(tester, (_, __) {
      calls++;
      return pending.future;
    }, admin: true);
    expect(find.text('Tu contraseña de administrador'), findsOneWidget);
    await tester.enterText(find.byType(TextField).at(0), 'patient@example.com');
    await tester.enterText(find.byType(TextField).at(1), 'password');
    await tester.tap(find.text('Eliminar definitivamente'));
    await tester.pump();
    final cancel =
        tester.widget<TextButton>(find.widgetWithText(TextButton, 'Cancelar'));
    expect(cancel.onPressed, isNull);
    expect(calls, 1);
    pending.complete();
    await tester.pumpAndSettle();
    expect(find.byType(AccountDeletionDialog), findsNothing);
  });
}
