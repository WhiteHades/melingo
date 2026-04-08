import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:learner_app/src/features/review/review_screen.dart';
import 'package:learner_app/src/native/ai_bridge_platform.dart';
import 'package:learner_app/src/practice/audio_turn_controller.dart';
import 'package:learner_app/src/review/practice_review_repository.dart';
import 'package:learner_app/src/state/settings_state.dart';

class _ReviewAiBridge extends UnimplementedAiBridgePlatform {
  int ttsCalls = 0;

  @override
  Future<List<int>> runTts({required String responseText}) async {
    ttsCalls += 1;
    return responseText.codeUnits;
  }
}

void main() {
  testWidgets('review screen filters turns by mistake category and replays',
      (WidgetTester tester) async {
    final InMemorySettingsStore store = InMemorySettingsStore();
    final InMemorySecretMaterialStore secrets = InMemorySecretMaterialStore();
    final PracticeReviewRepository repository = PracticeReviewRepository(
      store: store,
      secretMaterialStore: secrets,
    );
    final _ReviewAiBridge aiBridge = _ReviewAiBridge();

    await repository.append(
      const PracticeReviewTurn(
        turnId: 'turn_1',
        occurredAtIso: '2026-04-08T00:00:00Z',
        transcript: 'ich gehe haus',
        correctedText: 'Ich gehe nach Hause.',
        explanation: 'Added the missing preposition.',
        nextPrompt: 'Say it in the past tense.',
        assistantResponseText: 'Say it in the past tense.',
        mistakeTags: <String>['grammar:agreement'],
      ),
    );
    await repository.append(
      const PracticeReviewTurn(
        turnId: 'turn_2',
        occurredAtIso: '2026-04-08T00:01:00Z',
        transcript: 'ana aqra',
        correctedText: 'ana aqra al-kitab',
        explanation: 'Add the object for clarity.',
        nextPrompt: 'Ask a question with the same verb.',
        assistantResponseText: 'Ask a question with the same verb.',
        mistakeTags: <String>['pronunciation:stress'],
      ),
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: <Override>[
          settingsStoreProvider.overrideWithValue(store),
          secretMaterialStoreProvider.overrideWithValue(secrets),
          practiceReviewRepositoryProvider.overrideWithValue(repository),
          aiBridgeProvider.overrideWithValue(aiBridge),
        ],
        child: const MaterialApp(home: ReviewScreen()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Session review'), findsOneWidget);
    expect(find.text('grammar'), findsOneWidget);
    expect(find.text('pronunciation'), findsOneWidget);

    await tester.tap(find.text('grammar'));
    await tester.pumpAndSettle();

    expect(find.text('ich gehe haus'), findsOneWidget);
    expect(find.text('ana aqra'), findsNothing);

    await tester.tap(find.text('replay tutor'));
    await tester.pumpAndSettle();

    expect(aiBridge.ttsCalls, 1);
  });
}
