import 'package:flutter_test/flutter_test.dart';
import 'package:learner_app/src/features/stats/stats_aggregator.dart';
import 'package:learner_app/src/practice/practice_telemetry.dart';

void main() {
  test('summarizes telemetry into stats KPIs', () {
    final List<PracticeTelemetryEvent> events = <PracticeTelemetryEvent>[
      const PracticeTelemetryEvent(
        type: 'asr_result',
        turnId: 'turn_1',
        occurredAtIso: '2026-04-08T00:00:00Z',
        metrics: <String, dynamic>{'latencyMs': 120, 'confidence': 0.8},
      ),
      const PracticeTelemetryEvent(
        type: 'tutor_result',
        turnId: 'turn_1',
        occurredAtIso: '2026-04-08T00:00:01Z',
        metrics: <String, dynamic>{
          'latencyMs': 90,
          'mistakeTags': <String>['grammar:agreement', 'vocab:word-choice'],
        },
      ),
      const PracticeTelemetryEvent(
        type: 'tts_result',
        turnId: 'turn_1',
        occurredAtIso: '2026-04-08T00:00:02Z',
        metrics: <String, dynamic>{'latencyMs': 110, 'audioBytes': 2048},
      ),
      const PracticeTelemetryEvent(
        type: 'asr_result',
        turnId: 'turn_2',
        occurredAtIso: '2026-04-08T00:01:00Z',
        metrics: <String, dynamic>{'latencyMs': 80, 'confidence': 0.9},
      ),
      const PracticeTelemetryEvent(
        type: 'tutor_result',
        turnId: 'turn_2',
        occurredAtIso: '2026-04-08T00:01:01Z',
        metrics: <String, dynamic>{
          'latencyMs': 100,
          'mistakeTags': <String>['grammar:agreement'],
        },
      ),
      const PracticeTelemetryEvent(
        type: 'tts_result',
        turnId: 'turn_2',
        occurredAtIso: '2026-04-08T00:01:02Z',
        metrics: <String, dynamic>{'latencyMs': 95, 'audioBytes': 1024},
      ),
      const PracticeTelemetryEvent(
        type: 'tts_replay',
        turnId: 'turn_2',
        occurredAtIso: '2026-04-08T00:01:03Z',
        metrics: <String, dynamic>{'audioBytes': 1024},
      ),
      const PracticeTelemetryEvent(
        type: 'tts_interrupted',
        turnId: 'turn_2',
        occurredAtIso: '2026-04-08T00:01:04Z',
        metrics: <String, dynamic>{'audioBytes': 100},
      ),
      const PracticeTelemetryEvent(
        type: 'asr_result',
        turnId: 'turn_old',
        occurredAtIso: '2026-01-01T00:00:00Z',
        metrics: <String, dynamic>{'latencyMs': 50, 'confidence': 0.5},
      ),
    ];

    final StatsSummary summary = const StatsAggregator().summarize(
      events,
      now: DateTime.utc(2026, 4, 8, 12),
      windowDays: 30,
    );

    expect(summary.practiceMinutes, 2);
    expect(summary.streakDays, 1);
    expect(summary.sessionCount, 2);
    expect(summary.avgSessionLengthMinutes, 1);
    expect(summary.avgAsrLatencyMs, 100);
    expect(summary.avgTutorLatencyMs, 95);
    expect(summary.avgTtsLatencyMs, 103);
    expect(summary.avgAsrConfidence, closeTo(0.85, 0.00001));
    expect(summary.topMistakeTags.first, 'grammar:agreement');
    expect(summary.replayCount, 1);
    expect(summary.interruptionCount, 1);
    expect(summary.grammarTagCount, 2);
    expect(summary.vocabularyTagCount, 1);
  });

  test('supports wider trend windows', () {
    final List<PracticeTelemetryEvent> events = <PracticeTelemetryEvent>[
      const PracticeTelemetryEvent(
        type: 'asr_result',
        turnId: 'turn_old',
        occurredAtIso: '2026-02-20T00:00:00Z',
        metrics: <String, dynamic>{'latencyMs': 70, 'confidence': 0.8},
      ),
    ];

    final StatsSummary summary = const StatsAggregator().summarize(
      events,
      now: DateTime.utc(2026, 4, 8, 12),
      windowDays: 90,
    );

    expect(summary.sessionCount, 1);
  });
}
