import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:learner_app/src/l10n/language_packs.dart';
import 'package:learner_app/src/models/model_health.dart';
import 'package:learner_app/src/model_manager/model_health_repository.dart';
import 'package:learner_app/src/native/ai_bridge_platform.dart';
import 'package:learner_app/src/onboarding/onboarding_controller.dart';
import 'package:learner_app/src/onboarding/onboarding_profile.dart';
import 'package:learner_app/src/onboarding/onboarding_repository.dart';
import 'package:learner_app/src/onboarding/sync_queue.dart';
import 'package:learner_app/src/practice/audio_turn_controller.dart';
import 'package:learner_app/src/practice/practice_telemetry.dart';
import 'package:learner_app/src/review/practice_review_repository.dart';
import 'package:learner_app/src/state/settings_state.dart';

class _FakeAiBridge implements AiBridgePlatform {
  bool started = false;
  bool ttsStopped = false;
  int ttsCalls = 0;
  int ttsRepeat = 1;

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
    if (ttsRepeat <= 1) {
      return responseText.codeUnits;
    }
    final List<int> base = responseText.codeUnits;
    return List<int>.generate(base.length * ttsRepeat, (int i) {
      return base[i % base.length];
    });
  }

  @override
  Future<void> stopTts() async {
    ttsStopped = true;
  }
}

void main() {
  test('audio turn controller records transcript and telemetry', () async {
    final InMemorySettingsStore store = InMemorySettingsStore();
    final InMemorySecretMaterialStore secrets = InMemorySecretMaterialStore();
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
        secretMaterialStoreProvider.overrideWithValue(secrets),
        aiBridgeProvider.overrideWithValue(_FakeAiBridge()),
        syncQueueRepositoryProvider.overrideWithValue(
          SyncQueueRepository(
            store: store,
            secretMaterialStore: secrets,
          ),
        ),
        onboardingRepositoryProvider.overrideWithValue(
          OnboardingRepository(
            store: store,
            syncQueue: SyncQueueRepository(
              store: store,
              secretMaterialStore: secrets,
            ),
            secretMaterialStore: secrets,
          ),
        ),
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

    final PracticeReviewRepository reviewRepository =
        container.read(practiceReviewRepositoryProvider);
    final List<PracticeReviewTurn> reviewTurns =
        await reviewRepository.readAll();
    expect(reviewTurns.length, 1);
    expect(reviewTurns.first.transcript, 'hello world');
  });

  test('replayAssistantTurn emits replay telemetry', () async {
    final InMemorySettingsStore store = InMemorySettingsStore();
    final InMemorySecretMaterialStore secrets = InMemorySecretMaterialStore();
    final _FakeAiBridge fakeBridge = _FakeAiBridge();
    final SyncQueueRepository queue = SyncQueueRepository(
      store: store,
      secretMaterialStore: secrets,
    );
    final OnboardingRepository onboardingRepository = OnboardingRepository(
      store: store,
      syncQueue: queue,
      secretMaterialStore: secrets,
    );
    final ProviderContainer container = ProviderContainer(
      overrides: <Override>[
        settingsStoreProvider.overrideWithValue(store),
        secretMaterialStoreProvider.overrideWithValue(secrets),
        aiBridgeProvider.overrideWithValue(fakeBridge),
        syncQueueRepositoryProvider.overrideWithValue(queue),
        onboardingRepositoryProvider.overrideWithValue(onboardingRepository),
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
    final InMemorySecretMaterialStore secrets = InMemorySecretMaterialStore();
    final _FakeAiBridge fakeBridge = _FakeAiBridge();
    final SyncQueueRepository queue = SyncQueueRepository(
      store: store,
      secretMaterialStore: secrets,
    );
    final OnboardingRepository onboardingRepository = OnboardingRepository(
      store: store,
      syncQueue: queue,
      secretMaterialStore: secrets,
    );

    final ProviderContainer container = ProviderContainer(
      overrides: <Override>[
        settingsStoreProvider.overrideWithValue(store),
        secretMaterialStoreProvider.overrideWithValue(secrets),
        aiBridgeProvider.overrideWithValue(fakeBridge),
        syncQueueRepositoryProvider.overrideWithValue(queue),
        onboardingRepositoryProvider.overrideWithValue(onboardingRepository),
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

  test('startRecording while speaking interrupts and starts new turn',
      () async {
    final InMemorySettingsStore store = InMemorySettingsStore();
    final InMemorySecretMaterialStore secrets = InMemorySecretMaterialStore();
    final _FakeAiBridge fakeBridge = _FakeAiBridge()..ttsRepeat = 400;
    final SyncQueueRepository queue = SyncQueueRepository(
      store: store,
      secretMaterialStore: secrets,
    );
    final OnboardingRepository onboardingRepository = OnboardingRepository(
      store: store,
      syncQueue: queue,
      secretMaterialStore: secrets,
    );

    final ProviderContainer container = ProviderContainer(
      overrides: <Override>[
        settingsStoreProvider.overrideWithValue(store),
        secretMaterialStoreProvider.overrideWithValue(secrets),
        aiBridgeProvider.overrideWithValue(fakeBridge),
        syncQueueRepositoryProvider.overrideWithValue(queue),
        onboardingRepositoryProvider.overrideWithValue(onboardingRepository),
      ],
    );
    addTearDown(container.dispose);

    final AudioTurnController controller =
        container.read(audioTurnControllerProvider.notifier);

    await controller.startRecording();
    final Future<void> firstTurn = controller.stopRecording();
    await Future<void>.delayed(const Duration(milliseconds: 20));

    await controller.startRecording();

    expect(
      container.read(audioTurnControllerProvider).phase,
      AudioTurnPhase.recording,
    );
    expect(fakeBridge.ttsStopped, isTrue);

    await controller.cancelRecording();
    await firstTurn;
  });

  test('cancelRecording transitions to cancelled', () async {
    final InMemorySettingsStore store = InMemorySettingsStore();
    final InMemorySecretMaterialStore secrets = InMemorySecretMaterialStore();

    final ProviderContainer container = ProviderContainer(
      overrides: <Override>[
        settingsStoreProvider.overrideWithValue(store),
        secretMaterialStoreProvider.overrideWithValue(secrets),
        aiBridgeProvider.overrideWithValue(_FakeAiBridge()),
        syncQueueRepositoryProvider.overrideWithValue(
          SyncQueueRepository(
            store: store,
            secretMaterialStore: secrets,
          ),
        ),
        onboardingRepositoryProvider.overrideWithValue(
          OnboardingRepository(
            store: store,
            syncQueue: SyncQueueRepository(
              store: store,
              secretMaterialStore: secrets,
            ),
            secretMaterialStore: secrets,
          ),
        ),
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

  test('tutor telemetry carries taxonomy metadata for selected language',
      () async {
    final InMemorySettingsStore store = InMemorySettingsStore();
    final InMemorySecretMaterialStore secrets = InMemorySecretMaterialStore();
    final _FakeAiBridge fakeBridge = _FakeAiBridge();
    final SyncQueueRepository queue = SyncQueueRepository(
      store: store,
      secretMaterialStore: secrets,
    );
    final OnboardingRepository onboardingRepository = OnboardingRepository(
      store: store,
      syncQueue: queue,
      secretMaterialStore: secrets,
    );

    await onboardingRepository.saveProfileLocalFirst(
      const OnboardingProfile(
        displayName: 'efaz',
        languageCode: 'ar',
        level: 'a2',
        weeklyGoalMinutes: 90,
      ),
    );

    final ProviderContainer container = ProviderContainer(
      overrides: <Override>[
        settingsStoreProvider.overrideWithValue(store),
        secretMaterialStoreProvider.overrideWithValue(secrets),
        aiBridgeProvider.overrideWithValue(fakeBridge),
        syncQueueRepositoryProvider.overrideWithValue(queue),
        onboardingRepositoryProvider.overrideWithValue(onboardingRepository),
      ],
    );
    addTearDown(container.dispose);

    final AudioTurnController controller =
        container.read(audioTurnControllerProvider.notifier);

    await controller.startRecording();
    await controller.stopRecording();

    final PracticeTelemetryRepository telemetry =
        container.read(practiceTelemetryRepositoryProvider);
    final List<PracticeTelemetryEvent> events = await telemetry.readAll();
    final PracticeTelemetryEvent tutorEvent =
        events.firstWhere((PracticeTelemetryEvent event) {
      return event.type == 'tutor_result';
    });

    expect(tutorEvent.metrics['languageCode'], arabicLanguagePack.languageCode);
    expect(
      tutorEvent.metrics['taxonomyVersion'],
      arabicLanguagePack.taxonomyVersion,
    );
  });
}
