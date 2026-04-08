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
    final InMemorySecretMaterialStore secrets = InMemorySecretMaterialStore();
    final SyncQueueRepository queue = SyncQueueRepository(
      store: store,
      secretMaterialStore: secrets,
    );
    final OnboardingRepository repository = OnboardingRepository(
      store: store,
      syncQueue: queue,
      secretMaterialStore: secrets,
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
          secretMaterialStoreProvider.overrideWithValue(secrets),
          syncQueueRepositoryProvider.overrideWithValue(queue),
          onboardingRepositoryProvider.overrideWithValue(repository),
        ],
        child: const MaterialApp(home: ProfileScreen()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Name: efaz'), findsOneWidget);
    expect(find.text('Language: Deutsch'), findsOneWidget);
    expect(find.text('Level: a2'), findsOneWidget);
    expect(find.text('Content version: de.v1'), findsOneWidget);
  });
}
