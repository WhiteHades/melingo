import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../review/practice_review_repository.dart';
import '../../review/review_playback_controller.dart';

class ReviewScreen extends ConsumerStatefulWidget {
  const ReviewScreen({super.key});

  @override
  ConsumerState<ReviewScreen> createState() => _ReviewScreenState();
}

class _ReviewScreenState extends ConsumerState<ReviewScreen> {
  String? _selectedCategory;

  @override
  Widget build(BuildContext context) {
    final PracticeReviewRepository repository =
        ref.watch(practiceReviewRepositoryProvider);
    final ReviewPlaybackState playback =
        ref.watch(reviewPlaybackControllerProvider);
    final ReviewPlaybackController playbackController =
        ref.read(reviewPlaybackControllerProvider.notifier);

    return FutureBuilder<List<PracticeReviewTurn>>(
      future: repository.readAll(),
      builder: (BuildContext context,
          AsyncSnapshot<List<PracticeReviewTurn>> snapshot) {
        final List<PracticeReviewTurn> turns =
            snapshot.data ?? const <PracticeReviewTurn>[];
        final List<String> categories = turns
            .expand((PracticeReviewTurn turn) => turn.mistakeTags)
            .map((String tag) => tag.split(':').first)
            .toSet()
            .toList(growable: false)
          ..sort();

        final List<PracticeReviewTurn> filtered = _selectedCategory == null
            ? turns
            : turns.where((PracticeReviewTurn turn) {
                return turn.mistakeTags.any((String tag) {
                  return tag.startsWith('$_selectedCategory:');
                });
              }).toList(growable: false);

        return Scaffold(
          appBar: AppBar(title: const Text('Session review')),
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: <Widget>[
              const Text(
                'Review recent turns, inspect mistake categories, and replay tutor guidance from the timeline.',
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: <Widget>[
                  ChoiceChip(
                    label: const Text('all'),
                    selected: _selectedCategory == null,
                    onSelected: (_) {
                      setState(() {
                        _selectedCategory = null;
                      });
                    },
                  ),
                  ...categories.map(
                    (String category) => ChoiceChip(
                      label: Text(category),
                      selected: _selectedCategory == category,
                      onSelected: (_) {
                        setState(() {
                          _selectedCategory = category;
                        });
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              if (filtered.isEmpty)
                const Card(
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Text('No reviewed turns match this filter yet.'),
                  ),
                )
              else
                ...filtered.map(
                  (PracticeReviewTurn turn) => Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            turn.occurredAtIso,
                            style: Theme.of(context).textTheme.labelMedium,
                          ),
                          const SizedBox(height: 8),
                          Text('transcript',
                              style: Theme.of(context).textTheme.titleSmall),
                          const SizedBox(height: 4),
                          Text(turn.transcript),
                          const SizedBox(height: 8),
                          Text('correction',
                              style: Theme.of(context).textTheme.titleSmall),
                          const SizedBox(height: 4),
                          Text(turn.correctedText),
                          const SizedBox(height: 8),
                          Text('explanation',
                              style: Theme.of(context).textTheme.titleSmall),
                          const SizedBox(height: 4),
                          Text(turn.explanation),
                          const SizedBox(height: 8),
                          Text('next prompt',
                              style: Theme.of(context).textTheme.titleSmall),
                          const SizedBox(height: 4),
                          Text(turn.nextPrompt),
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: turn.mistakeTags
                                .map(
                                  (String tag) => Chip(label: Text(tag)),
                                )
                                .toList(growable: false),
                          ),
                          const SizedBox(height: 12),
                          OutlinedButton.icon(
                            onPressed: playback.playingTurnId == turn.turnId
                                ? null
                                : () {
                                    playbackController.replay(turn);
                                  },
                            icon: const Icon(Icons.replay),
                            label: Text(
                              playback.playingTurnId == turn.turnId
                                  ? 'playing...'
                                  : 'replay tutor',
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}
