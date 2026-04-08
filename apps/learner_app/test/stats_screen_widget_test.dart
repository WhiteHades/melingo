import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:learner_app/src/features/stats/stats_screen.dart';
import 'package:learner_app/src/practice/practice_telemetry.dart';
import 'package:learner_app/src/state/settings_state.dart';

void main() {
  testWidgets('stats screen renders KPI cards from telemetry',
      (WidgetTester tester) async {
    final InMemorySettingsStore store = InMemorySettingsStore();
    final PracticeTelemetryRepository telemetry =
        PracticeTelemetryRepository(store: store);

    await telemetry.append(
      const PracticeTelemetryEvent(
        type: 'asr_result',
        turnId: 'turn_1',
        occurredAtIso: '2026-04-08T00:00:00Z',
        metrics: <String, dynamic>{'latencyMs': 100, 'confidence': 0.9},
      ),
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: <Override>[
          settingsStoreProvider.overrideWithValue(store),
        ],
        child: const MaterialApp(
          home: Scaffold(body: StatsScreen()),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('stats'), findsOneWidget);
    expect(find.text('sessions'), findsOneWidget);
    expect(find.text('avg asr latency'), findsOneWidget);
    expect(find.text('top mistake tags'), findsOneWidget);
  });
}
