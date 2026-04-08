import 'package:flutter_test/flutter_test.dart';
import 'package:learner_app/src/practice/practice_telemetry.dart';
import 'package:learner_app/src/state/settings_state.dart';

void main() {
  test('append writes immutable ordered telemetry events', () async {
    final InMemorySettingsStore store = InMemorySettingsStore();
    final PracticeTelemetryRepository repository =
        PracticeTelemetryRepository(store: store);

    await repository.append(
      const PracticeTelemetryEvent(
        type: 'asr_result',
        turnId: 'turn_1',
        occurredAtIso: '2026-04-07T00:00:00Z',
        metrics: <String, dynamic>{'latencyMs': 120, 'confidence': 0.87},
      ),
    );
    await repository.append(
      const PracticeTelemetryEvent(
        type: 'asr_result',
        turnId: 'turn_2',
        occurredAtIso: '2026-04-07T00:00:02Z',
        metrics: <String, dynamic>{'latencyMs': 100, 'confidence': 0.91},
      ),
    );

    final List<PracticeTelemetryEvent> events = await repository.readAll();
    expect(events.length, 2);
    expect(events.first.turnId, 'turn_1');
    expect(events.last.turnId, 'turn_2');
  });
}
