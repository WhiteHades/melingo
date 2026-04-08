import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:learner_app/src/models/model_health.dart';
import 'package:learner_app/src/model_manager/model_health_repository.dart';
import 'package:learner_app/src/native/ai_bridge_platform.dart';
import 'package:learner_app/src/practice/audio_turn_controller.dart';
import 'package:learner_app/src/practice/practice_telemetry.dart';
import 'package:learner_app/src/state/settings_state.dart';

class _FakeAiBridge implements AiBridgePlatform {
  bool started = false;
  bool ttsStopped = false;
  int ttsCalls = 0;

  @override
  Future<void> initialize() async {}

  @override
  Future<void> startRecording() async {
    started = true;
  }

  @override
  Future<List<int>> stopRecording() async {
    if (!started) {
      return <int>[];
    }
    started = false;
    return 'pcm16le:bridge'.codeUnits;
  }

  @override
  Future<void> cancelRecording() async {
    started = false;
  }

  @override
  Future<String> runAsr({required List<int> pcm16leBytes}) async {
    if (String.fromCharCodes(pcm16leBytes) != 'pcm16le:bridge') {
      throw StateError('expected bridge bytes');
    }
    return 'hello world';
  }

  @override
  Future<String> runTutor({required String transcript}) async {
    return '{"correctedText":"$transcript","explanation":"Looks good with minor grammar fixes.","encouragement":"Great job.","nextPrompt":"Try a longer sentence.","mistakeTags":["grammar:agreement"],"responseText":"Great job. Try a longer sentence."}';
  }

  @override
  Future<List<int>> runTts({required String responseText}) async {
    ttsCalls += 1;
    return responseText.codeUnits;
  }

  @override
  Future<void> stopTts() async {
    ttsStopped = true;
  }
}

void main() {
  test('audio turn controller records transcript and telemetry', () async {
    final InMemorySettingsStore store = InMemorySettingsStore();
    final ModelHealthRepository healthRepository =
        ModelHealthRepository(store: store);
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

    final AudioTurnController controller =
        container.read(audioTurnControllerProvider.notifier);

    await controller.startRecording();
    expect(container.read(audioTurnControllerProvider).phase,
        AudioTurnPhase.recording);

    await controller.stopRecording();
    final AudioTurnState state = container.read(audioTurnControllerProvider);
    expect(state.phase, AudioTurnPhase.completed);
    expect(state.transcript, 'hello world');
    expect(state.confidence, greaterThan(0));
    expect(state.tutor, isNotNull);
    expect(state.tutor!.correctedText, 'hello world');
    expect(state.tutor!.mistakeTags, contains('grammar:agreement'));
    expect(state.tutor!.assistantResponseText, isNotEmpty);
    expect(state.tutorLatencyMs, greaterThanOrEqualTo(0));
    expect(state.ttsLatencyMs, greaterThanOrEqualTo(0));

    final PracticeTelemetryRepository telemetry =
        container.read(practiceTelemetryRepositoryProvider);
    final List<PracticeTelemetryEvent> events = await telemetry.readAll();
    expect(events.length, 3);
    expect(events.first.type, 'asr_result');
    expect(events[1].type, 'tutor_result');
    expect(events[2].type, 'tts_result');
  });

  test('replayAssistantTurn emits replay telemetry', () async {
    final InMemorySettingsStore store = InMemorySettingsStore();
    final _FakeAiBridge fakeBridge = _FakeAiBridge();
    final ProviderContainer container = ProviderContainer(
      overrides: <Override>[
        settingsStoreProvider.overrideWithValue(store),
        aiBridgeProvider.overrideWithValue(fakeBridge),
      ],
    );
    addTearDown(container.dispose);

    final AudioTurnController controller =
        container.read(audioTurnControllerProvider.notifier);

    await controller.startRecording();
    await controller.stopRecording();
    await controller.replayAssistantTurn();

    final PracticeTelemetryRepository telemetry =
        container.read(practiceTelemetryRepositoryProvider);
    final List<PracticeTelemetryEvent> events = await telemetry.readAll();
    expect(events.any((PracticeTelemetryEvent e) => e.type == 'tts_replay'),
        isTrue);
    expect(fakeBridge.ttsCalls, greaterThanOrEqualTo(1));
  });

  test('stopSpeaking interrupts playback and emits interruption telemetry',
      () async {
    final InMemorySettingsStore store = InMemorySettingsStore();
    final _FakeAiBridge fakeBridge = _FakeAiBridge();

    final ProviderContainer container = ProviderContainer(
      overrides: <Override>[
        settingsStoreProvider.overrideWithValue(store),
        aiBridgeProvider.overrideWithValue(fakeBridge),
      ],
    );
    addTearDown(container.dispose);

    final AudioTurnController controller =
        container.read(audioTurnControllerProvider.notifier);

    await controller.startRecording();
    final Future<void> turnFuture = controller.stopRecording();
    await Future<void>.delayed(const Duration(milliseconds: 20));
    await controller.stopSpeaking();
    await turnFuture;

    expect(fakeBridge.ttsStopped, isTrue);

    final PracticeTelemetryRepository telemetry =
        container.read(practiceTelemetryRepositoryProvider);
    final List<PracticeTelemetryEvent> events = await telemetry.readAll();
    expect(
      events.any((PracticeTelemetryEvent e) => e.type == 'tts_interrupted'),
      isTrue,
    );
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

    final AudioTurnController controller =
        container.read(audioTurnControllerProvider.notifier);

    await controller.startRecording();
    await controller.cancelRecording();

    expect(container.read(audioTurnControllerProvider).phase,
        AudioTurnPhase.cancelled);
  });
}
