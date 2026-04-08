import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../native/ai_bridge_platform.dart';
import '../practice/audio_turn_controller.dart';
import 'practice_review_repository.dart';

class ReviewPlaybackState {
  const ReviewPlaybackState({this.playingTurnId});

  final String? playingTurnId;
}

class ReviewPlaybackController extends StateNotifier<ReviewPlaybackState> {
  ReviewPlaybackController({required AiBridgePlatform aiBridge})
      : _aiBridge = aiBridge,
        super(const ReviewPlaybackState());

  final AiBridgePlatform _aiBridge;

  Future<void> replay(PracticeReviewTurn turn) async {
    state = ReviewPlaybackState(playingTurnId: turn.turnId);
    final List<int> ttsBytes = await _aiBridge.runTts(
      responseText: turn.assistantResponseText,
    );
    final int chunks = max(1, (ttsBytes.length / 2400).ceil());
    for (int i = 0; i < chunks; i++) {
      await Future<void>.delayed(const Duration(milliseconds: 60));
    }
    state = const ReviewPlaybackState();
  }
}

final StateNotifierProvider<ReviewPlaybackController, ReviewPlaybackState>
    reviewPlaybackControllerProvider =
    StateNotifierProvider<ReviewPlaybackController, ReviewPlaybackState>(
  (Ref ref) {
    final AiBridgePlatform aiBridge = ref.watch(aiBridgeProvider);
    return ReviewPlaybackController(aiBridge: aiBridge);
  },
);
