import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:learner_app/main.dart';
import 'package:learner_app/src/onboarding/onboarding_controller.dart';
import 'package:learner_app/src/onboarding/onboarding_profile.dart';
import 'package:learner_app/src/onboarding/onboarding_repository.dart';
import 'package:learner_app/src/onboarding/sync_queue.dart';
import 'package:learner_app/src/state/settings_state.dart';

void main() {
  testWidgets('app switches to RTL when arabic pack is selected',
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
        languageCode: 'ar',
        level: 'a1',
        weeklyGoalMinutes: 60,
      ),
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: <Override>[
          settingsStoreProvider.overrideWithValue(store),
          syncQueueRepositoryProvider.overrideWithValue(queue),
          onboardingRepositoryProvider.overrideWithValue(repository),
        ],
        child: const MelingoApp(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('الرئيسية'), findsWidgets);

    final BuildContext context = tester.element(find.byType(Scaffold).first);
    expect(Directionality.of(context), TextDirection.rtl);
  });
}
