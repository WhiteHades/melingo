import 'package:flutter_test/flutter_test.dart';
import 'package:learner_app/src/review/practice_review_repository.dart';
import 'package:learner_app/src/state/settings_state.dart';

void main() {
  test('append stores review turns in timestamp order', () async {
    final InMemorySettingsStore store = InMemorySettingsStore();
    final InMemorySecretMaterialStore secrets = InMemorySecretMaterialStore();
    final PracticeReviewRepository repository = PracticeReviewRepository(
      store: store,
      secretMaterialStore: secrets,
    );

    await repository.append(
      const PracticeReviewTurn(
        turnId: 'turn_2',
        occurredAtIso: '2026-04-08T00:01:00Z',
        transcript: 'second',
        correctedText: 'second corrected',
        explanation: 'second explanation',
        nextPrompt: 'second next',
        assistantResponseText: 'second response',
        mistakeTags: <String>['grammar:agreement'],
      ),
    );
    await repository.append(
      const PracticeReviewTurn(
        turnId: 'turn_1',
        occurredAtIso: '2026-04-08T00:00:00Z',
        transcript: 'first',
        correctedText: 'first corrected',
        explanation: 'first explanation',
        nextPrompt: 'first next',
        assistantResponseText: 'first response',
        mistakeTags: <String>['pronunciation:stress'],
      ),
    );

    final List<PracticeReviewTurn> turns = await repository.readAll();
    expect(turns.length, 2);
    expect(turns.first.turnId, 'turn_1');
    expect(turns.last.turnId, 'turn_2');
  });
}
