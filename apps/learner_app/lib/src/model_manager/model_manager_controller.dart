import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/model_health.dart';
import '../models/model_install_state.dart';
import '../models/model_manifest.dart';
import '../network/model_manifest_client.dart';
import '../state/settings_state.dart';
import 'model_health_repository.dart';
import 'model_install_repository.dart';
import 'model_manifest_repository.dart';

class ModelManagerState {
  const ModelManagerState({
    this.manifest,
    this.installs = const <ModelInstallState>[],
    this.health,
    this.isLoading = false,
    this.error,
  });

  final ModelManifest? manifest;
  final List<ModelInstallState> installs;
  final ModelHealth? health;
  final bool isLoading;
  final String? error;

  ModelManagerState copyWith({
    ModelManifest? manifest,
    List<ModelInstallState>? installs,
    ModelHealth? health,
    bool? isLoading,
    String? error,
  }) {
    return ModelManagerState(
      manifest: manifest ?? this.manifest,
      installs: installs ?? this.installs,
      health: health ?? this.health,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class ModelManagerController extends StateNotifier<ModelManagerState> {
  ModelManagerController({
    required ModelManifestRepository manifestRepository,
    required ModelInstallRepository installRepository,
    required ModelHealthRepository healthRepository,
  })  : _manifestRepository = manifestRepository,
        _installRepository = installRepository,
        _healthRepository = healthRepository,
        super(const ModelManagerState()) {
    load();
  }

  final ModelManifestRepository _manifestRepository;
  final ModelInstallRepository _installRepository;
  final ModelHealthRepository _healthRepository;

  Future<void> load() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final ModelManifest? cached = await _manifestRepository.readCached();
      final List<ModelInstallState> installs = await _installRepository.readAll();
      final ModelHealth health = await _healthRepository.read();
      state = state.copyWith(
        manifest: cached,
        installs: installs,
        health: health,
        isLoading: false,
        error: null,
      );
    } catch (error) {
      state = state.copyWith(isLoading: false, error: error.toString());
    }
  }

  Future<void> refreshManifest() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final ModelManifest manifest = await _manifestRepository.fetchAndCache();
      state = state.copyWith(manifest: manifest, isLoading: false, error: null);
    } catch (error) {
      state = state.copyWith(isLoading: false, error: error.toString());
    }
  }

  Future<void> markInstallStarted(String bundleId) async {
    const double progress = 0.1;
    final ModelInstallState install = ModelInstallState(
      bundleId: bundleId,
      status: 'downloading',
      progress: progress,
    );
    await _installRepository.upsert(install);
    final List<ModelInstallState> next = await _installRepository.readAll();
    state = state.copyWith(installs: next);
  }

  Future<void> markInstallReady(String bundleId) async {
    final ModelInstallState install = ModelInstallState(
      bundleId: bundleId,
      status: 'ready',
      progress: 1,
    );
    await _installRepository.upsert(install);
    final List<ModelInstallState> next = await _installRepository.readAll();

    final List<String> installed =
        next.where((e) => e.status == 'ready').map((e) => e.bundleId).toList(growable: false);
    final ModelHealth health = ModelHealth(
      ready: installed.isNotEmpty,
      installedBundles: installed,
      lastCheckedIso: DateTime.now().toUtc().toIso8601String(),
    );
    await _healthRepository.write(health);
    state = state.copyWith(installs: next, health: health);
  }
}

final Provider<ModelManifestClient> modelManifestClientProvider =
    Provider<ModelManifestClient>((Ref ref) {
  return ModelManifestClient();
});

final Provider<ModelManifestRepository> modelManifestRepositoryProvider =
    Provider<ModelManifestRepository>((Ref ref) {
  final SettingsValueStore store = ref.watch(settingsStoreProvider);
  final ModelManifestClient client = ref.watch(modelManifestClientProvider);
  return ModelManifestRepository(client: client, store: store);
});

final Provider<ModelInstallRepository> modelInstallRepositoryProvider =
    Provider<ModelInstallRepository>((Ref ref) {
  final SettingsValueStore store = ref.watch(settingsStoreProvider);
  return ModelInstallRepository(store: store);
});

final Provider<ModelHealthRepository> modelHealthRepositoryProvider =
    Provider<ModelHealthRepository>((Ref ref) {
  final SettingsValueStore store = ref.watch(settingsStoreProvider);
  return ModelHealthRepository(store: store);
});

final StateNotifierProvider<ModelManagerController, ModelManagerState>
    modelManagerControllerProvider =
    StateNotifierProvider<ModelManagerController, ModelManagerState>((Ref ref) {
  return ModelManagerController(
    manifestRepository: ref.watch(modelManifestRepositoryProvider),
    installRepository: ref.watch(modelInstallRepositoryProvider),
    healthRepository: ref.watch(modelHealthRepositoryProvider),
  );
});
