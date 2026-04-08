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
    final InMemorySecretMaterialStore secrets = InMemorySecretMaterialStore();
    final PracticeTelemetryRepository telemetry = PracticeTelemetryRepository(
      store: store,
      secretMaterialStore: secrets,
    );

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
          secretMaterialStoreProvider.overrideWithValue(secrets),
        ],
        child: const MaterialApp(
          home: Scaffold(body: StatsScreen()),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Stats'), findsOneWidget);
    expect(find.text('7d'), findsOneWidget);
    expect(find.text('30d'), findsOneWidget);
    expect(find.text('90d'), findsOneWidget);
    expect(find.text('practice minutes'), findsOneWidget);
    expect(find.text('streak'), findsOneWidget);
    expect(find.text('Sessions'), findsOneWidget);
    expect(find.text('Avg ASR latency'), findsOneWidget);
    expect(find.text('grammar tags'), findsOneWidget);
  });
}
