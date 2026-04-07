import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:learner_app/src/model_manager/model_health_repository.dart';
import 'package:learner_app/src/native/ai_bridge_platform.dart';
import 'package:learner_app/src/practice/audio_turn_controller.dart';
import 'package:learner_app/src/practice/practice_telemetry.dart';
import 'package:learner_app/src/state/settings_state.dart';

class _FakeAiBridge implements AiBridgePlatform {
  @override
  Future<void> initialize() async {}

  @override
  Future<String> runAsr({required List<int> pcm16leBytes}) async {
    return 'hello world';
  }

  @override
  Future<String> runTutor({required String transcript}) async {
    return 'ok';
  }

  @override
  Future<List<int>> runTts({required String responseText}) async {
    return <int>[];
  }
}

void main() {
  test('audio turn controller records transcript and telemetry', () async {
    final InMemorySettingsStore store = InMemorySettingsStore();
    final ModelHealthRepository healthRepository = ModelHealthRepository(store: store);
    await healthRepository.write(
      ModelHealth(
        ready: true,
        installedBundles: const <String>['lite'],
        lastCheckedIso: DateTime.now().toUtc().toIso8601String(),
      ),
    );

    final ProviderContainer container = ProviderContainer(
      overrides: <Override>[
        settingsStoreProvider.overrideWithValue(store),
        aiBridgeProvider.overrideWithValue(_FakeAiBridge()),
      ],
    );
    addTearDown(container.dispose);

    final AudioTurnController controller = container.read(audioTurnControllerProvider.notifier);

    await controller.startRecording();
    expect(container.read(audioTurnControllerProvider).phase, AudioTurnPhase.recording);

    await controller.stopRecording();
    final AudioTurnState state = container.read(audioTurnControllerProvider);
    expect(state.phase, AudioTurnPhase.completed);
    expect(state.transcript, 'hello world');
    expect(state.confidence, greaterThan(0));

    final PracticeTelemetryRepository telemetry =
        container.read(practiceTelemetryRepositoryProvider);
    final List<PracticeTelemetryEvent> events = await telemetry.readAll();
    expect(events.length, 1);
    expect(events.first.type, 'asr_result');
  });

  test('cancelRecording transitions to cancelled', () async {
    final InMemorySettingsStore store = InMemorySettingsStore();

    final ProviderContainer container = ProviderContainer(
      overrides: <Override>[
        settingsStoreProvider.overrideWithValue(store),
        aiBridgeProvider.overrideWithValue(_FakeAiBridge()),
      ],
    );
    addTearDown(container.dispose);

    final AudioTurnController controller = container.read(audioTurnControllerProvider.notifier);

    await controller.startRecording();
    await controller.cancelRecording();

    expect(container.read(audioTurnControllerProvider).phase, AudioTurnPhase.cancelled);
  });
}
