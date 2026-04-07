import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:learner_app/src/forms/onboarding_form.dart';

void main() {
  testWidgets('onboarding form shows validation message for empty name',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(body: OnboardingForm()),
      ),
    );

    await tester.tap(find.text('save onboarding'));
    await tester.pump();

    expect(find.text('name is required'), findsOneWidget);
  });
}
