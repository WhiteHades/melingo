import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../practice/practice_telemetry.dart';
import '../../state/settings_state.dart';
import 'stats_aggregator.dart';

class StatsScreen extends ConsumerWidget {
  const StatsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final SettingsValueStore store = ref.watch(settingsStoreProvider);
    final PracticeTelemetryRepository repository =
        PracticeTelemetryRepository(store: store);

    return FutureBuilder<List<PracticeTelemetryEvent>>(
      future: repository.readAll(),
      builder: (BuildContext context,
          AsyncSnapshot<List<PracticeTelemetryEvent>> snapshot) {
        final StatsSummary summary = snapshot.hasData
            ? const StatsAggregator().summarize(snapshot.data!)
            : StatsSummary.empty;

        return SafeArea(
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: <Widget>[
              Text('stats', style: Theme.of(context).textTheme.headlineSmall),
              const SizedBox(height: 12),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: <Widget>[
                  _kpiCard(
                      context, 'sessions', summary.sessionCount.toString()),
                  _kpiCard(context, 'avg asr latency',
                      '${summary.avgAsrLatencyMs} ms'),
                  _kpiCard(context, 'avg tutor latency',
                      '${summary.avgTutorLatencyMs} ms'),
                  _kpiCard(context, 'avg tts latency',
                      '${summary.avgTtsLatencyMs} ms'),
                  _kpiCard(
                    context,
                    'avg confidence',
                    summary.avgAsrConfidence.toStringAsFixed(2),
                  ),
                  _kpiCard(context, 'replays', summary.replayCount.toString()),
                  _kpiCard(context, 'interruptions',
                      summary.interruptionCount.toString()),
                ],
              ),
              const SizedBox(height: 16),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text('top mistake tags',
                          style: Theme.of(context).textTheme.titleMedium),
                      const SizedBox(height: 8),
                      if (summary.topMistakeTags.isEmpty)
                        const Text('no mistake tags yet')
                      else
                        ...summary.topMistakeTags.map(
                          (String tag) => Padding(
                            padding: const EdgeInsets.only(bottom: 4),
                            child: Text(tag),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'trend windows (7/30/90) and per-language topic breakdowns will be added in next slice.',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _kpiCard(BuildContext context, String label, String value) {
    return SizedBox(
      width: 170,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(label, style: Theme.of(context).textTheme.labelMedium),
              const SizedBox(height: 6),
              Text(value, style: Theme.of(context).textTheme.titleLarge),
            ],
          ),
        ),
      ),
    );
  }
}
