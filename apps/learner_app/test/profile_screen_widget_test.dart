import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:learner_app/src/features/profile/profile_screen.dart';
import 'package:learner_app/src/onboarding/onboarding_controller.dart';
import 'package:learner_app/src/onboarding/onboarding_profile.dart';
import 'package:learner_app/src/onboarding/onboarding_repository.dart';
import 'package:learner_app/src/onboarding/sync_queue.dart';
import 'package:learner_app/src/state/settings_state.dart';

void main() {
  testWidgets('profile screen shows onboarding values when available',
      (WidgetTester tester) async {
    final InMemorySettingsStore store = InMemorySettingsStore();
    final SyncQueueRepository queue = SyncQueueRepository(store: store);
    final OnboardingRepository repository = OnboardingRepository(
      store: store,
      syncQueue: queue,
    );

    await repository.saveProfileLocalFirst(
      const OnboardingProfile(
        displayName: 'efaz',
        languageCode: 'de',
        level: 'a2',
        weeklyGoalMinutes: 120,
      ),
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: <Override>[
          settingsStoreProvider.overrideWithValue(store),
          syncQueueRepositoryProvider.overrideWithValue(queue),
          onboardingRepositoryProvider.overrideWithValue(repository),
        ],
        child: const MaterialApp(home: ProfileScreen()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('name: efaz'), findsOneWidget);
    expect(find.text('language: de'), findsOneWidget);
    expect(find.text('level: a2'), findsOneWidget);
  });
}
