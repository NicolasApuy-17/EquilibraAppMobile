import 'package:equilibra/components/privacy_links.dart';
import 'package:equilibra/config/legal_links.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const channel = MethodChannel('plugins.flutter.io/url_launcher');

  testWidgets('privacy and deletion open the public pages outside the app',
      (tester) async {
    final opened = <String>[];
    tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(channel,
        (call) async {
      opened.add(call.arguments['url'] as String);
      expect(call.arguments['useWebView'], false);
      return true;
    });
    addTearDown(() => tester.binding.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null));
    await tester.pumpWidget(const MaterialApp(
        home: Scaffold(body: SingleChildScrollView(child: PrivacyLinks()))));
    await tester.tap(find.text('Política de Privacidad'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Solicitar eliminación de cuenta'));
    await tester.pumpAndSettle();
    expect(opened, [publicPrivacyPolicyUrl, accountDeletionUrl]);
    expect(tester.takeException(), isNull);
  });

  testWidgets('a browser launch failure displays a retry message',
      (tester) async {
    tester.binding.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (_) async => false);
    addTearDown(() => tester.binding.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null));
    await tester
        .pumpWidget(const MaterialApp(home: Scaffold(body: PrivacyLinks())));
    await tester.tap(find.text('Solicitar eliminación de cuenta'));
    await tester.pumpAndSettle();
    expect(find.text('No se pudo abrir la página. Inténtalo nuevamente.'),
        findsOneWidget);
  });
}
