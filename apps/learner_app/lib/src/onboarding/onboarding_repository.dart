import 'dart:convert';

import '../state/settings_state.dart';
import 'onboarding_profile.dart';
import 'sync_queue.dart';

class OnboardingRepository {
  OnboardingRepository({
    required SettingsValueStore store,
    required SyncQueueRepository syncQueue,
    required SecretMaterialStore secretMaterialStore,
  })  : _encryptedStore = EncryptedSettingsValueStore(
          inner: store,
          secretMaterialStore: secretMaterialStore,
        ),
        _syncQueue = syncQueue;

  static const String _profileKey = 'melangua_onboarding_profile_v1';

  final SettingsValueStore _encryptedStore;
  final SyncQueueRepository _syncQueue;

  Future<OnboardingProfile?> readProfile() async {
    final String? raw = await _encryptedStore.readString(_profileKey);
    if (raw == null || raw.isEmpty) {
      return null;
    }

    final Map<String, dynamic> map = jsonDecode(raw) as Map<String, dynamic>;
    return OnboardingProfile.fromMap(map);
  }

  Future<void> saveProfileLocalFirst(OnboardingProfile profile) async {
    await _encryptedStore.writeString(_profileKey, jsonEncode(profile.toMap()));
    await _syncQueue.enqueue(
      SyncQueueItem(
        type: 'onboarding_profile_upsert',
        payload: profile.toMap(),
        createdAtIso: DateTime.now().toUtc().toIso8601String(),
      ),
    );
  }
}
