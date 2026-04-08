import 'package:flutter_test/flutter_test.dart';
import 'package:learner_app/src/onboarding/onboarding_profile.dart';
import 'package:learner_app/src/onboarding/onboarding_repository.dart';
import 'package:learner_app/src/onboarding/sync_queue.dart';
import 'package:learner_app/src/state/settings_state.dart';

void main() {
  test('saveProfileLocalFirst stores profile and enqueues sync marker',
      () async {
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

    const OnboardingProfile profile = OnboardingProfile(
      displayName: 'efaz',
      languageCode: 'de',
      level: 'a2',
      weeklyGoalMinutes: 120,
    );

    await repository.saveProfileLocalFirst(profile);
    final OnboardingProfile? saved = await repository.readProfile();
    final List<SyncQueueItem> queued = await queue.readAll();

    expect(saved, isNotNull);
    expect(saved!.displayName, 'efaz');
    expect(queued.length, 1);
    expect(queued.first.type, 'onboarding_profile_upsert');
    expect(queued.first.payload['displayName'], 'efaz');
  });
}
