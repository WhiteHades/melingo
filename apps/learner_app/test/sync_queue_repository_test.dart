import 'package:flutter_test/flutter_test.dart';
import 'package:learner_app/src/onboarding/sync_queue.dart';
import 'package:learner_app/src/state/settings_state.dart';

void main() {
  test('enqueue appends items and readAll returns ordered queue', () async {
    final InMemorySettingsStore store = InMemorySettingsStore();
    final InMemorySecretMaterialStore secrets = InMemorySecretMaterialStore();
    final SyncQueueRepository repository = SyncQueueRepository(
      store: store,
      secretMaterialStore: secrets,
    );

    await repository.enqueue(
      const SyncQueueItem(
        type: 'session_started',
        payload: <String, dynamic>{'sessionId': 's1'},
        createdAtIso: '2026-04-07T10:00:00Z',
      ),
    );
    await repository.enqueue(
      const SyncQueueItem(
        type: 'session_ended',
        payload: <String, dynamic>{'sessionId': 's1'},
        createdAtIso: '2026-04-07T10:10:00Z',
      ),
    );

    final List<SyncQueueItem> items = await repository.readAll();
    expect(items.length, 2);
    expect(items.first.type, 'session_started');
    expect(items.last.type, 'session_ended');
  });
}
