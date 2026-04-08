import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:learner_app/src/forms/onboarding_form.dart';
import 'package:learner_app/src/onboarding/onboarding_controller.dart';
import 'package:learner_app/src/onboarding/onboarding_repository.dart';
import 'package:learner_app/src/onboarding/sync_queue.dart';
import 'package:learner_app/src/state/settings_state.dart';

void main() {
  testWidgets('onboarding form shows validation message for empty name',
      (WidgetTester tester) async {
    final InMemorySettingsStore store = InMemorySettingsStore();
    final SyncQueueRepository queue = SyncQueueRepository(store: store);
    final OnboardingRepository repository = OnboardingRepository(
      store: store,
      syncQueue: queue,
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: <Override>[
          settingsStoreProvider.overrideWithValue(store),
          syncQueueRepositoryProvider.overrideWithValue(queue),
          onboardingRepositoryProvider.overrideWithValue(repository),
        ],
        child: const MaterialApp(
          home: Scaffold(body: OnboardingForm()),
        ),
      ),
    );

    await tester.tap(find.text('Save onboarding'));
    await tester.pump();

    expect(find.text('Name is required'), findsOneWidget);
  });

  testWidgets('onboarding form saves local profile and queues sync marker',
      (WidgetTester tester) async {
    final InMemorySettingsStore store = InMemorySettingsStore();
    final SyncQueueRepository queue = SyncQueueRepository(store: store);
    final OnboardingRepository repository = OnboardingRepository(
      store: store,
      syncQueue: queue,
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: <Override>[
          settingsStoreProvider.overrideWithValue(store),
          syncQueueRepositoryProvider.overrideWithValue(queue),
          onboardingRepositoryProvider.overrideWithValue(repository),
        ],
        child: const MaterialApp(
          home: Scaffold(body: OnboardingForm()),
        ),
      ),
    );

    await tester.enterText(find.byType(TextFormField).first, 'efaz');
    await tester.tap(find.text('Save onboarding'));
    await tester.pumpAndSettle();

    final List<SyncQueueItem> queued = await queue.readAll();
    expect(queued.length, 1);
    expect(queued.first.type, 'onboarding_profile_upsert');
  });
}
