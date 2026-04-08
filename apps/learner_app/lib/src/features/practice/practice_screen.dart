import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../l10n/fallback_strings.dart';
import '../../l10n/language_packs.dart';
import '../../onboarding/onboarding_controller.dart';
import '../../practice/audio_turn_controller.dart';

class PracticeScreen extends ConsumerWidget {
  const PracticeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AudioTurnState state = ref.watch(audioTurnControllerProvider);
    final AudioTurnController controller =
        ref.read(audioTurnControllerProvider.notifier);
    final OnboardingState onboarding = ref.watch(onboardingControllerProvider);
    final LanguagePack languagePack =
        resolveLanguagePack(onboarding.profile?.languageCode);

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: <Widget>[
          Text(
            FallbackStrings.practiceTitle(context),
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(
              '${FallbackStrings.practicePhase(context)}: ${state.phase.name}'),
          Text(
            '${FallbackStrings.practiceOfflineReady(context)}: ${state.canRunOffline}',
          ),
          Text(
            '${FallbackStrings.activeLanguagePack(context)}: ${languagePack.displayName} (${languagePack.contentVersion})',
          ),
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
                label: Text(FallbackStrings.startAction(context)),
              ),
              FilledButton.tonalIcon(
                onPressed: state.phase == AudioTurnPhase.recording
                    ? () {
                        controller.stopRecording();
                      }
                    : null,
                icon: const Icon(Icons.stop),
                label: Text(FallbackStrings.stopAction(context)),
              ),
              OutlinedButton.icon(
                onPressed: state.phase == AudioTurnPhase.recording
                    ? () {
                        controller.cancelRecording();
                      }
                    : null,
                icon: const Icon(Icons.close),
                label: Text(FallbackStrings.cancelAction(context)),
              ),
              OutlinedButton.icon(
                onPressed: state.phase == AudioTurnPhase.speaking
                    ? () {
                        controller.stopSpeaking();
                      }
                    : null,
                icon: const Icon(Icons.volume_off),
                label: Text(FallbackStrings.stopSpeechAction(context)),
              ),
              OutlinedButton.icon(
                onPressed: state.tutor != null &&
                        state.phase != AudioTurnPhase.speaking
                    ? () {
                        controller.replayAssistantTurn();
                      }
                    : null,
                icon: const Icon(Icons.replay),
                label: Text(FallbackStrings.replayAction(context)),
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
                  Text(
                    FallbackStrings.transcriptTitle(context),
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    state.transcript.isEmpty
                        ? FallbackStrings.noTranscriptYet(context)
                        : state.transcript,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${FallbackStrings.confidenceLabel(context)}: ${state.confidence.toStringAsFixed(2)}',
                  ),
                  Text(
                    '${FallbackStrings.latencyLabel(context)}: ${state.latencyMs} ms',
                  ),
                  if (state.tutor != null) ...<Widget>[
                    const SizedBox(height: 12),
                    Text(
                      FallbackStrings.correctionTitle(context),
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                    const SizedBox(height: 4),
                    Text(state.tutor!.correctedText),
                    const SizedBox(height: 8),
                    Text(
                      FallbackStrings.explanationTitle(context),
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                    const SizedBox(height: 4),
                    Text(state.tutor!.explanation),
                    const SizedBox(height: 8),
                    Text(
                      FallbackStrings.assistantTitle(context),
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                    const SizedBox(height: 4),
                    Text(state.tutor!.assistantResponseText),
                    const SizedBox(height: 8),
                    Text(
                      FallbackStrings.nextPromptTitle(context),
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                    const SizedBox(height: 4),
                    Text(state.tutor!.nextPrompt),
                    const SizedBox(height: 8),
                    Text(
                      '${FallbackStrings.mistakeTagsLabel(context)}: ${state.tutor!.mistakeTags.join(', ')}',
                    ),
                    Text(
                      '${FallbackStrings.tutorLatencyLabel(context)}: ${state.tutorLatencyMs} ms',
                    ),
                    Text(
                      '${FallbackStrings.ttsLatencyLabel(context)}: ${state.ttsLatencyMs} ms',
                    ),
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
