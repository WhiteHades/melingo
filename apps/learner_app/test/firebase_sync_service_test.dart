import 'package:flutter_test/flutter_test.dart';
import 'package:learner_app/src/firebase/firebase_sync.dart';
import 'package:learner_app/src/onboarding/onboarding_profile.dart';
import 'package:learner_app/src/onboarding/onboarding_repository.dart';
import 'package:learner_app/src/onboarding/sync_queue.dart';
import 'package:learner_app/src/state/settings_state.dart';

class _FakeIdentityGateway implements CloudIdentityGateway {
  @override
  Future<String> ensureSignedIn() async => 'user_123';
}

class _FakeSyncGateway implements CloudSyncGateway {
  Map<String, dynamic>? remoteProfile;
  final List<SyncQueueItem> practiceEvents = <SyncQueueItem>[];

  @override
  Future<Map<String, dynamic>?> readProfile(String uid) async => remoteProfile;

  @override
  Future<void> writePracticeEvent(String uid, SyncQueueItem item) async {
    practiceEvents.add(item);
  }

  @override
  Future<void> writeProfile(String uid, Map<String, dynamic> profile) async {
    remoteProfile = profile;
  }
}

void main() {
  test('syncAll writes newer local profile and drains queue', () async {
    final InMemorySettingsStore store = InMemorySettingsStore();
    final InMemorySecretMaterialStore secrets = InMemorySecretMaterialStore();
    final SyncQueueRepository queue = SyncQueueRepository(
      store: store,
      secretMaterialStore: secrets,
    );
    final OnboardingRepository onboarding = OnboardingRepository(
      store: store,
      syncQueue: queue,
      secretMaterialStore: secrets,
    );
    final _FakeSyncGateway gateway = _FakeSyncGateway();
    final FirebaseSyncService service = FirebaseSyncService(
      identityGateway: _FakeIdentityGateway(),
      syncGateway: gateway,
      queueRepository: queue,
      onboardingRepository: onboarding,
    );

    await onboarding.saveProfileLocalFirst(
      const OnboardingProfile(
        displayName: 'mel',
        languageCode: 'de',
        level: 'a2',
        weeklyGoalMinutes: 90,
        updatedAtIso: '2026-04-08T10:00:00Z',
      ),
    );

    final int processed = await service.syncAll();

    expect(processed, 1);
    expect(gateway.remoteProfile?['displayName'], 'mel');
    expect((await queue.readAll()), isEmpty);
  });

  test('syncAll prefers newer remote profile deterministically', () async {
    final InMemorySettingsStore store = InMemorySettingsStore();
    final InMemorySecretMaterialStore secrets = InMemorySecretMaterialStore();
    final SyncQueueRepository queue = SyncQueueRepository(
      store: store,
      secretMaterialStore: secrets,
    );
    final OnboardingRepository onboarding = OnboardingRepository(
      store: store,
      syncQueue: queue,
      secretMaterialStore: secrets,
    );
    final _FakeSyncGateway gateway = _FakeSyncGateway()
      ..remoteProfile = <String, dynamic>{
        'displayName': 'remote',
        'languageCode': 'ar',
        'level': 'b1',
        'weeklyGoalMinutes': 120,
        'updatedAtIso': '2026-04-09T10:00:00Z',
      };
    final FirebaseSyncService service = FirebaseSyncService(
      identityGateway: _FakeIdentityGateway(),
      syncGateway: gateway,
      queueRepository: queue,
      onboardingRepository: onboarding,
    );

    await onboarding.saveProfileLocalFirst(
      const OnboardingProfile(
        displayName: 'local',
        languageCode: 'de',
        level: 'a2',
        weeklyGoalMinutes: 90,
        updatedAtIso: '2026-04-08T10:00:00Z',
      ),
    );

    await service.syncAll();
    final OnboardingProfile? profile = await onboarding.readProfile();

    expect(profile?.displayName, 'remote');
    expect(profile?.languageCode, 'ar');
  });
}
