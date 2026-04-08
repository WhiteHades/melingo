import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:learner_app/src/features/practice/practice_screen.dart';
import 'package:learner_app/src/state/settings_state.dart';

void main() {
  testWidgets('practice screen renders start button and transcript placeholder',
      (WidgetTester tester) async {
    final InMemorySettingsStore store = InMemorySettingsStore();

    await tester.pumpWidget(
      ProviderScope(
        overrides: <Override>[
          settingsStoreProvider.overrideWithValue(store),
        ],
        child: const MaterialApp(
          home: Scaffold(body: PracticeScreen()),
        ),
      ),
    );

    expect(find.text('start'), findsOneWidget);
    expect(find.text('no transcript yet'), findsOneWidget);
    expect(find.text('replay'), findsOneWidget);
    expect(find.text('stop speech'), findsOneWidget);
  });
}
