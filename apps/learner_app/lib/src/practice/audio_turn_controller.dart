import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../model_manager/model_health_repository.dart';
import '../native/ai_bridge_platform.dart';
import '../state/settings_state.dart';
import 'practice_telemetry.dart';

enum AudioTurnPhase {
  idle,
  recording,
  transcribing,
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
    this.error,
    this.turnId,
  });

  final AudioTurnPhase phase;
  final String transcript;
  final double confidence;
  final int latencyMs;
  final bool canRunOffline;
  final String? error;
  final String? turnId;

  AudioTurnState copyWith({
    AudioTurnPhase? phase,
    String? transcript,
    double? confidence,
    int? latencyMs,
    bool? canRunOffline,
    String? error,
    String? turnId,
  }) {
    return AudioTurnState(
      phase: phase ?? this.phase,
      transcript: transcript ?? this.transcript,
      confidence: confidence ?? this.confidence,
      latencyMs: latencyMs ?? this.latencyMs,
      canRunOffline: canRunOffline ?? this.canRunOffline,
      error: error,
      turnId: turnId ?? this.turnId,
    );
  }

  static const AudioTurnState initial = AudioTurnState(
    phase: AudioTurnPhase.idle,
    transcript: '',
    confidence: 0,
    latencyMs: 0,
    canRunOffline: false,
  );
}

class AudioTurnController extends StateNotifier<AudioTurnState> {
  AudioTurnController({
    required AiBridgePlatform aiBridge,
    required PracticeTelemetryRepository telemetryRepository,
    required ModelHealthRepository modelHealthRepository,
  })  : _aiBridge = aiBridge,
        _telemetryRepository = telemetryRepository,
        _modelHealthRepository = modelHealthRepository,
        super(AudioTurnState.initial) {
    _refreshOfflineReadiness();
  }

  final AiBridgePlatform _aiBridge;
  final PracticeTelemetryRepository _telemetryRepository;
  final ModelHealthRepository _modelHealthRepository;

  List<int>? _currentPcm;

  Future<void> _refreshOfflineReadiness() async {
    final bool ready = (await _modelHealthRepository.read()).ready;
    state = state.copyWith(canRunOffline: ready);
  }

  Future<void> startRecording() async {
    if (state.phase == AudioTurnPhase.recording || state.phase == AudioTurnPhase.transcribing) {
      return;
    }
    await _refreshOfflineReadiness();
    final String turnId = _newTurnId();
    state = state.copyWith(
      phase: AudioTurnPhase.recording,
      transcript: '',
      confidence: 0,
      latencyMs: 0,
      error: null,
      turnId: turnId,
    );
    _currentPcm = _fakeMicCapture(turnId);
  }

  Future<void> cancelRecording() async {
    if (state.phase != AudioTurnPhase.recording) {
      return;
    }
    _currentPcm = null;
    state = state.copyWith(
      phase: AudioTurnPhase.cancelled,
      transcript: '',
      confidence: 0,
      latencyMs: 0,
      error: null,
    );
  }

  Future<void> stopRecording() async {
    if (state.phase != AudioTurnPhase.recording) {
      return;
    }
    final String turnId = state.turnId ?? _newTurnId();
    final List<int> bytes = _currentPcm ?? _fakeMicCapture(turnId);
    _currentPcm = null;

    state = state.copyWith(phase: AudioTurnPhase.transcribing, error: null);

    try {
      final Stopwatch stopwatch = Stopwatch()..start();
      final String transcript = await _aiBridge.runAsr(pcm16leBytes: bytes);
      stopwatch.stop();

      final int latencyMs = stopwatch.elapsedMilliseconds;
      final double confidence = _estimateConfidence(transcript);

      await _telemetryRepository.append(
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
        phase: AudioTurnPhase.completed,
        transcript: transcript,
        confidence: confidence,
        latencyMs: latencyMs,
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
    return payload.codeUnits;
  }

  double _estimateConfidence(String transcript) {
    if (transcript.isEmpty || transcript == 'asr_not_configured') {
      return 0;
    }
    final int letters = transcript.runes.where((int r) => r >= 97 && r <= 122).length;
    final double raw = 0.5 + min(letters, 25) / 50;
    return raw.clamp(0, 0.99);
  }
}

final Provider<AiBridgePlatform> aiBridgeProvider = Provider<AiBridgePlatform>((Ref ref) {
  return UnimplementedAiBridgePlatform();
});

final Provider<PracticeTelemetryRepository> practiceTelemetryRepositoryProvider =
    Provider<PracticeTelemetryRepository>((Ref ref) {
  final SettingsValueStore store = ref.watch(settingsStoreProvider);
  return PracticeTelemetryRepository(store: store);
});

final StateNotifierProvider<AudioTurnController, AudioTurnState> audioTurnControllerProvider =
    StateNotifierProvider<AudioTurnController, AudioTurnState>((Ref ref) {
  final AiBridgePlatform aiBridge = ref.watch(aiBridgeProvider);
  final PracticeTelemetryRepository telemetry = ref.watch(practiceTelemetryRepositoryProvider);
  final SettingsValueStore store = ref.watch(settingsStoreProvider);
  final ModelHealthRepository health = ModelHealthRepository(store: store);
  return AudioTurnController(
    aiBridge: aiBridge,
    telemetryRepository: telemetry,
    modelHealthRepository: health,
  );
});
