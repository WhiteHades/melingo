import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../practice/audio_turn_controller.dart';

class PracticeScreen extends ConsumerWidget {
  const PracticeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AudioTurnState state = ref.watch(audioTurnControllerProvider);
    final AudioTurnController controller =
        ref.read(audioTurnControllerProvider.notifier);

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: <Widget>[
          Text('practice', style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 8),
          Text('phase: ${state.phase.name}'),
          Text('offline ready: ${state.canRunOffline}'),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: <Widget>[
              FilledButton.icon(
                onPressed: state.phase == AudioTurnPhase.recording ||
                        state.phase == AudioTurnPhase.transcribing ||
                        state.phase == AudioTurnPhase.tutoring
                    ? null
                    : () {
                        controller.startRecording();
                      },
                icon: const Icon(Icons.mic),
                label: const Text('start'),
              ),
              FilledButton.tonalIcon(
                onPressed: state.phase == AudioTurnPhase.recording
                    ? () {
                        controller.stopRecording();
                      }
                    : null,
                icon: const Icon(Icons.stop),
                label: const Text('stop'),
              ),
              OutlinedButton.icon(
                onPressed: state.phase == AudioTurnPhase.recording
                    ? () {
                        controller.cancelRecording();
                      }
                    : null,
                icon: const Icon(Icons.close),
                label: const Text('cancel'),
              ),
              OutlinedButton.icon(
                onPressed: state.phase == AudioTurnPhase.speaking
                    ? () {
                        controller.stopSpeaking();
                      }
                    : null,
                icon: const Icon(Icons.volume_off),
                label: const Text('stop speech'),
              ),
              OutlinedButton.icon(
                onPressed: state.tutor != null &&
                        state.phase != AudioTurnPhase.speaking
                    ? () {
                        controller.replayAssistantTurn();
                      }
                    : null,
                icon: const Icon(Icons.replay),
                label: const Text('replay'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text('transcript',
                      style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 8),
                  Text(state.transcript.isEmpty
                      ? 'no transcript yet'
                      : state.transcript),
                  const SizedBox(height: 8),
                  Text('confidence: ${state.confidence.toStringAsFixed(2)}'),
                  Text('latency: ${state.latencyMs} ms'),
                  if (state.tutor != null) ...<Widget>[
                    const SizedBox(height: 12),
                    Text('correction',
                        style: Theme.of(context).textTheme.titleSmall),
                    const SizedBox(height: 4),
                    Text(state.tutor!.correctedText),
                    const SizedBox(height: 8),
                    Text('explanation',
                        style: Theme.of(context).textTheme.titleSmall),
                    const SizedBox(height: 4),
                    Text(state.tutor!.explanation),
                    const SizedBox(height: 8),
                    Text('assistant',
                        style: Theme.of(context).textTheme.titleSmall),
                    const SizedBox(height: 4),
                    Text(state.tutor!.assistantResponseText),
                    const SizedBox(height: 8),
                    Text('next prompt',
                        style: Theme.of(context).textTheme.titleSmall),
                    const SizedBox(height: 4),
                    Text(state.tutor!.nextPrompt),
                    const SizedBox(height: 8),
                    Text(
                        'mistake tags: ${state.tutor!.mistakeTags.join(', ')}'),
                    Text('tutor latency: ${state.tutorLatencyMs} ms'),
                    Text('tts latency: ${state.ttsLatencyMs} ms'),
                  ],
                  if (state.error != null) ...<Widget>[
                    const SizedBox(height: 8),
                    Text(
                      state.error!,
                      style:
                          TextStyle(color: Theme.of(context).colorScheme.error),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
