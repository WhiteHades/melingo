import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../state/settings_state.dart';
import 'onboarding_profile.dart';
import 'onboarding_repository.dart';
import 'sync_queue.dart';

class OnboardingState {
  const OnboardingState({
    this.profile,
    this.isSaving = false,
    this.saveError,
  });

  final OnboardingProfile? profile;
  final bool isSaving;
  final String? saveError;

  OnboardingState copyWith({
    OnboardingProfile? profile,
    bool? isSaving,
    String? saveError,
  }) {
    return OnboardingState(
      profile: profile ?? this.profile,
      isSaving: isSaving ?? this.isSaving,
      saveError: saveError,
    );
  }
}

class OnboardingController extends StateNotifier<OnboardingState> {
  OnboardingController(this._repository) : super(const OnboardingState()) {
    load();
  }

  final OnboardingRepository _repository;

  Future<void> load() async {
    final OnboardingProfile? profile = await _repository.readProfile();
    state = state.copyWith(profile: profile);
  }

  Future<void> save(OnboardingProfile profile) async {
    state = state.copyWith(isSaving: true, saveError: null);
    try {
      await _repository.saveProfileLocalFirst(profile);
      state =
          state.copyWith(profile: profile, isSaving: false, saveError: null);
    } catch (error) {
      state = state.copyWith(isSaving: false, saveError: error.toString());
    }
  }
}

final Provider<SyncQueueRepository> syncQueueRepositoryProvider =
    Provider<SyncQueueRepository>((Ref ref) {
  final SettingsValueStore store = ref.watch(settingsStoreProvider);
  return SyncQueueRepository(store: store);
});

final Provider<OnboardingRepository> onboardingRepositoryProvider =
    Provider<OnboardingRepository>((Ref ref) {
  final SettingsValueStore store = ref.watch(settingsStoreProvider);
  final SyncQueueRepository queue = ref.watch(syncQueueRepositoryProvider);
  return OnboardingRepository(store: store, syncQueue: queue);
});

final StateNotifierProvider<OnboardingController, OnboardingState>
    onboardingControllerProvider =
    StateNotifierProvider<OnboardingController, OnboardingState>((Ref ref) {
  final OnboardingRepository repository =
      ref.watch(onboardingRepositoryProvider);
  return OnboardingController(repository);
});
