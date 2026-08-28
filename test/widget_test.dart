// Widget test for the Equilibra pre-auth splash screen.
//
// This replaces the default Flutter counter-app template test, which never
// matched this project (it pumped MyApp() directly, which requires
// Firebase.initializeApp() to already have run — something main.dart does,
// but a bare widget test never does) and always failed. TestScreenWidget was
// picked (like ChatbotWidget before it) because it doesn't touch
// Firebase/Auth/Firestore in its build method, so it can be pumped directly
// without any test setup.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:equilibra/test_screen/test_screen_widget.dart';

void main() {
  setUpAll(() {
    // Avoid Google Fonts trying to fetch over the network during tests.
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  testWidgets(
    'TestScreenWidget shows the app name and the two entry actions',
    (WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(home: TestScreenWidget()));

      expect(find.text('equilibra'), findsOneWidget);
      expect(find.text('Crear una cuenta'), findsOneWidget);
      expect(find.text('Iniciar sesión'), findsOneWidget);
    },
  );
}
