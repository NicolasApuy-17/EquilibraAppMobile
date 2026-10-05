import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:equilibra/pages/psychologist_patient_detail/psychologist_patient_detail_widget.dart';

void main() {
  testWidgets(
      'a direct patient route without an ID shows an error instead of crashing',
      (tester) async {
    await tester.pumpWidget(const MaterialApp(home: PatientDetailRoute()));
    await tester.pumpAndSettle();
    expect(find.text('No se pudo abrir este consultante.'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('a malformed patient ID is rejected before querying Firebase',
      (tester) async {
    await tester.pumpWidget(const MaterialApp(
        home: PatientDetailRoute(patientId: 'users/patient')));
    await tester.pumpAndSettle();
    expect(find.text('No se pudo abrir este consultante.'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
