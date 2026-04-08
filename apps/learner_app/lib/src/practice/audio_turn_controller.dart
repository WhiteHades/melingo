import 'dart:math';
import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../l10n/language_packs.dart';
import '../model_manager/model_health_repository.dart';
import '../native/ai_bridge_platform.dart';
import '../firebase/firebase_sync.dart';
import '../onboarding/onboarding_controller.dart';
import '../onboarding/onboarding_profile.dart';
import '../onboarding/onboarding_repository.dart';
import '../onboarding/sync_queue.dart';
import '../review/practice_review_repository.dart';
import '../state/settings_state.dart';
import 'practice_telemetry.dart';
import 'tutor_turn_result.dart';

const Object _audioTurnStateUnset = Object();

enum AudioTurnPhase {
  idle,
  recording,
  transcribing,
  tutoring,
  speaking,
  completed,
  cancelled,
  failed,
}

class AudioTurnState {
  const AudioTurnState({
    required this.phase,
    required this.transcript,
    required this.confidence,
    required this.latencyMs,
    required this.canRunOffline,
    required this.tutor,
    required this.tutorLatencyMs,
    required this.ttsLatencyMs,
    this.error,
    this.turnId,
  });

  final AudioTurnPhase phase;
  final String transcript;
  final double confidence;
  final int latencyMs;
  final bool canRunOffline;
  final TutorTurnResult? tutor;
  final int tutorLatencyMs;
  final int ttsLatencyMs;
  final String? error;
  final String? turnId;

  AudioTurnState copyWith({
    AudioTurnPhase? phase,
    String? transcript,
    double? confidence,
    int? latencyMs,
    bool? canRunOffline,
    Object? tutor = _audioTurnStateUnset,
    int? tutorLatencyMs,
    int? ttsLatencyMs,
    Object? error = _audioTurnStateUnset,
    String? turnId,
  }) {
    return AudioTurnState(
      phase: phase ?? this.phase,
      transcript: transcript ?? this.transcript,
      confidence: confidence ?? this.confidence,
      latencyMs: latencyMs ?? this.latencyMs,
      canRunOffline: canRunOffline ?? this.canRunOffline,
      tutor: identical(tutor, _audioTurnStateUnset)
          ? this.tutor
          : tutor as TutorTurnResult?,
      tutorLatencyMs: tutorLatencyMs ?? this.tutorLatencyMs,
      ttsLatencyMs: ttsLatencyMs ?? this.ttsLatencyMs,
      error: identical(error, _audioTurnStateUnset)
          ? this.error
          : error as String?,
      turnId: turnId ?? this.turnId,
    );
  }

  static const AudioTurnState initial = AudioTurnState(
    phase: AudioTurnPhase.idle,
    transcript: '',
    confidence: 0,
    latencyMs: 0,
    canRunOffline: false,
    tutor: null,
    tutorLatencyMs: 0,
    ttsLatencyMs: 0,
  );
}

class AudioTurnController extends StateNotifier<AudioTurnState> {
  AudioTurnController({
    required AiBridgePlatform aiBridge,
    required PracticeTelemetryRepository telemetryRepository,
    required ModelHealthRepository modelHealthRepository,
    required OnboardingRepository onboardingRepository,
    required PracticeReviewRepository reviewRepository,
    required SyncQueueRepository syncQueueRepository,
    required FirebaseSyncService syncService,
  })  : _aiBridge = aiBridge,
        _telemetryRepository = telemetryRepository,
        _modelHealthRepository = modelHealthRepository,
        _onboardingRepository = onboardingRepository,
        _reviewRepository = reviewRepository,
        _syncQueueRepository = syncQueueRepository,
        _syncService = syncService,
        super(AudioTurnState.initial) {
    _refreshOfflineReadiness();
  }

  final AiBridgePlatform _aiBridge;
  final PracticeTelemetryRepository _telemetryRepository;
  final ModelHealthRepository _modelHealthRepository;
  final OnboardingRepository _onboardingRepository;
  final PracticeReviewRepository _reviewRepository;
  final SyncQueueRepository _syncQueueRepository;
  final FirebaseSyncService _syncService;

  List<int>? _currentPcm;
  List<int> _lastTtsBytes = <int>[];
  bool _ttsInterruptRequested = false;

  Future<void> _refreshOfflineReadiness() async {
    final bool ready = (await _modelHealthRepository.read()).ready;
    state = state.copyWith(canRunOffline: ready);
  }

  Future<void> startRecording() async {
    if (state.phase == AudioTurnPhase.speaking) {
      await stopSpeaking();
    }
    if (state.phase == AudioTurnPhase.recording ||
        state.phase == AudioTurnPhase.transcribing ||
        state.phase == AudioTurnPhase.tutoring) {
      return;
    }
    await _refreshOfflineReadiness();
    final String turnId = _newTurnId();
    state = state.copyWith(
      phase: AudioTurnPhase.recording,
      transcript: '',
      confidence: 0,
      latencyMs: 0,
      tutor: null,
      tutorLatencyMs: 0,
      ttsLatencyMs: 0,
      error: null,
      turnId: turnId,
    );
    await _aiBridge.startRecording();
    _currentPcm = _fakeMicCapture(turnId);
  }

  Future<void> cancelRecording() async {
    if (state.phase != AudioTurnPhase.recording) {
      return;
    }
    await _aiBridge.cancelRecording();
    _currentPcm = null;
    state = state.copyWith(
      phase: AudioTurnPhase.cancelled,
      transcript: '',
      confidence: 0,
      latencyMs: 0,
      tutor: null,
      tutorLatencyMs: 0,
      ttsLatencyMs: 0,
      error: null,
    );
  }

  Future<void> stopSpeaking() async {
    if (state.phase != AudioTurnPhase.speaking) {
      return;
    }
    _ttsInterruptRequested = true;
    await _aiBridge.stopTts();
    final String turnId = state.turnId ?? _newTurnId();
    await _recordPracticeEvent(
      PracticeTelemetryEvent(
        type: 'tts_interrupted',
        turnId: turnId,
        occurredAtIso: DateTime.now().toUtc().toIso8601String(),
        metrics: <String, dynamic>{
          'audioBytes': _lastTtsBytes.length,
        },
      ),
    );
    state = state.copyWith(phase: AudioTurnPhase.completed);
  }

  Future<void> replayAssistantTurn() async {
    if (_lastTtsBytes.isEmpty || state.tutor == null) {
      return;
    }
    if (state.phase == AudioTurnPhase.recording ||
        state.phase == AudioTurnPhase.transcribing ||
        state.phase == AudioTurnPhase.tutoring) {
      return;
    }

    final String turnId = state.turnId ?? _newTurnId();
    await _recordPracticeEvent(
      PracticeTelemetryEvent(
        type: 'tts_replay',
        turnId: turnId,
        occurredAtIso: DateTime.now().toUtc().toIso8601String(),
        metrics: <String, dynamic>{
          'audioBytes': _lastTtsBytes.length,
        },
      ),
    );

    state = state.copyWith(phase: AudioTurnPhase.speaking);
    final bool interrupted = await _simulatePlayback(_lastTtsBytes);
    if (interrupted) {
      return;
    }
    state = state.copyWith(phase: AudioTurnPhase.completed);
  }

  Future<void> stopRecording() async {
    if (state.phase != AudioTurnPhase.recording) {
      return;
    }
    final String turnId = state.turnId ?? _newTurnId();
    final List<int> bridgeBytes = await _aiBridge.stopRecording();
    final List<int> bytes;
    if (bridgeBytes.isNotEmpty) {
      bytes = bridgeBytes;
    } else {
      bytes = _currentPcm ?? _fakeMicCapture(turnId);
    }
    _currentPcm = null;

    state = state.copyWith(phase: AudioTurnPhase.transcribing, error: null);

    try {
      final Stopwatch stopwatch = Stopwatch()..start();
      final String transcript = await _aiBridge.runAsr(pcm16leBytes: bytes);
      stopwatch.stop();

      final int latencyMs = stopwatch.elapsedMilliseconds;
      final double confidence = _estimateConfidence(transcript);

      await _recordPracticeEvent(
        PracticeTelemetryEvent(
          type: 'asr_result',
          turnId: turnId,
          occurredAtIso: DateTime.now().toUtc().toIso8601String(),
          metrics: <String, dynamic>{
            'latencyMs': latencyMs,
            'confidence': confidence,
            'offlineReady': state.canRunOffline,
          },
        ),
      );

      state = state.copyWith(
        phase: AudioTurnPhase.tutoring,
        transcript: transcript,
        confidence: confidence,
        latencyMs: latencyMs,
        error: null,
      );

      final Stopwatch tutorStopwatch = Stopwatch()..start();
      final String tutorRaw = await _aiBridge.runTutor(transcript: transcript);
      tutorStopwatch.stop();
      final int tutorLatencyMs = tutorStopwatch.elapsedMilliseconds;
      final OnboardingProfile? profile =
          await _onboardingRepository.readProfile();
      final LanguagePack languagePack =
          resolveLanguagePack(profile?.languageCode);
      final TutorTurnResult tutor = TutorTurnResult.fromRaw(
        transcript: transcript,
        raw: tutorRaw,
        languagePack: languagePack,
      );

      await _recordPracticeEvent(
        PracticeTelemetryEvent(
          type: 'tutor_result',
          turnId: turnId,
          occurredAtIso: DateTime.now().toUtc().toIso8601String(),
          metrics: <String, dynamic>{
            'latencyMs': tutorLatencyMs,
            'mistakeTags': tutor.mistakeTags,
            'languageCode': languagePack.languageCode,
            'taxonomyVersion': languagePack.taxonomyVersion,
          },
        ),
      );

      state = state.copyWith(
        phase: AudioTurnPhase.speaking,
        tutor: tutor,
        tutorLatencyMs: tutorLatencyMs,
      );

      final Stopwatch ttsStopwatch = Stopwatch()..start();
      final List<int> ttsBytes = await _aiBridge.runTts(
        responseText: tutor.assistantResponseText,
      );
      ttsStopwatch.stop();
      final int ttsLatencyMs = ttsStopwatch.elapsedMilliseconds;
      _lastTtsBytes = ttsBytes;

      await _reviewRepository.append(
        PracticeReviewTurn(
          turnId: turnId,
          occurredAtIso: DateTime.now().toUtc().toIso8601String(),
          transcript: transcript,
          correctedText: tutor.correctedText,
          explanation: tutor.explanation,
          nextPrompt: tutor.nextPrompt,
          assistantResponseText: tutor.assistantResponseText,
          mistakeTags: tutor.mistakeTags,
        ),
      );

      await _recordPracticeEvent(
        PracticeTelemetryEvent(
          type: 'tts_result',
          turnId: turnId,
          occurredAtIso: DateTime.now().toUtc().toIso8601String(),
          metrics: <String, dynamic>{
            'latencyMs': ttsLatencyMs,
            'audioBytes': ttsBytes.length,
          },
        ),
      );

      final bool interrupted = await _simulatePlayback(ttsBytes);
      if (interrupted) {
        return;
      }

      state = state.copyWith(
        phase: AudioTurnPhase.completed,
        transcript: transcript,
        confidence: confidence,
        latencyMs: latencyMs,
        tutor: tutor,
        tutorLatencyMs: tutorLatencyMs,
        ttsLatencyMs: ttsLatencyMs,
        error: null,
      );
    } catch (error) {
      state = state.copyWith(
        phase: AudioTurnPhase.failed,
        error: error.toString(),
      );
    }
  }

  String _newTurnId() {
    final int millis = DateTime.now().toUtc().millisecondsSinceEpoch;
    return 'turn_$millis';
  }

  List<int> _fakeMicCapture(String turnId) {
    final String payload = 'pcm16le:$turnId';
    return Uint8List.fromList(payload.codeUnits);
  }

  Future<bool> _simulatePlayback(List<int> audioBytes) async {
    _ttsInterruptRequested = false;
    if (audioBytes.isEmpty) {
      await Future<void>.delayed(const Duration(milliseconds: 80));
      return _ttsInterruptRequested;
    }

    final int chunks = max(1, (audioBytes.length / 2400).ceil());
    for (int i = 0; i < chunks; i++) {
      if (_ttsInterruptRequested) {
        return true;
      }
      await Future<void>.delayed(const Duration(milliseconds: 60));
    }
    return _ttsInterruptRequested;
  }

  double _estimateConfidence(String transcript) {
    if (transcript.isEmpty || transcript == 'asr_not_configured') {
      return 0;
    }
    final int letters =
        transcript.runes.where((int r) => r >= 97 && r <= 122).length;
    final double raw = 0.5 + min(letters, 25) / 50;
    return raw.clamp(0, 0.99);
  }

  Future<void> _recordPracticeEvent(PracticeTelemetryEvent event) async {
    await _telemetryRepository.append(event);
    await _syncQueueRepository.enqueue(
      SyncQueueItem(
        type: 'practice_event_append',
        payload: event.toMap(),
        createdAtIso: event.occurredAtIso,
      ),
    );
    await _syncService.syncAll();
  }
}

final Provider<AiBridgePlatform> aiBridgeProvider =
    Provider<AiBridgePlatform>((Ref ref) {
  return UnimplementedAiBridgePlatform();
});

final Provider<PracticeTelemetryRepository>
    practiceTelemetryRepositoryProvider =
    Provider<PracticeTelemetryRepository>((Ref ref) {
  final SettingsValueStore store = ref.watch(settingsStoreProvider);
  final SecretMaterialStore secretMaterialStore =
      ref.watch(secretMaterialStoreProvider);
  return PracticeTelemetryRepository(
    store: store,
    secretMaterialStore: secretMaterialStore,
  );
});

final StateNotifierProvider<AudioTurnController, AudioTurnState>
    audioTurnControllerProvider =
    StateNotifierProvider<AudioTurnController, AudioTurnState>((Ref ref) {
  final AiBridgePlatform aiBridge = ref.watch(aiBridgeProvider);
  final PracticeTelemetryRepository telemetry =
      ref.watch(practiceTelemetryRepositoryProvider);
  final OnboardingRepository onboardingRepository =
      ref.watch(onboardingRepositoryProvider);
  final PracticeReviewRepository reviewRepository =
      ref.watch(practiceReviewRepositoryProvider);
  final SyncQueueRepository syncQueueRepository =
      ref.watch(syncQueueRepositoryProvider);
  final FirebaseSyncService syncService =
      ref.watch(firebaseSyncServiceProvider);
  final SettingsValueStore store = ref.watch(settingsStoreProvider);
  final ModelHealthRepository health = ModelHealthRepository(store: store);
  return AudioTurnController(
    aiBridge: aiBridge,
    telemetryRepository: telemetry,
    modelHealthRepository: health,
    onboardingRepository: onboardingRepository,
    reviewRepository: reviewRepository,
    syncQueueRepository: syncQueueRepository,
    syncService: syncService,
  );
});
