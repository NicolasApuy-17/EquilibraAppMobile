// Widget test for the Equilibra chatbot screen.
//
// This replaces the default Flutter counter-app template test, which never
// matched this project (it pumped MyApp() directly, which requires
// Firebase.initializeApp() to already have run — something main.dart does,
// but a bare widget test never does) and always failed.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:equilibra/pages/chatbot/chatbot_widget.dart';

void main() {
  setUpAll(() {
    // Avoid Google Fonts trying to fetch over the network during tests.
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  testWidgets(
    'ChatbotWidget shows the title, the initial greeting and a message input',
    (WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(home: ChatbotWidget()));

      expect(find.text('Preguntas frecuentes'), findsOneWidget);
      expect(
        find.textContaining('Soy el asistente de Equilibra'),
        findsOneWidget,
      );
      expect(find.byType(TextField), findsOneWidget);
    },
  );
}
