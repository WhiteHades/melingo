import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../l10n/fallback_strings.dart';
import '../../l10n/language_packs.dart';
import '../../onboarding/onboarding_controller.dart';
import '../../practice/practice_telemetry.dart';
import '../../state/settings_state.dart';
import 'stats_aggregator.dart';

enum StatsWindow {
  days7(7, '7d'),
  days30(30, '30d'),
  days90(90, '90d');

  const StatsWindow(this.days, this.label);

  final int days;
  final String label;
}

class StatsScreen extends ConsumerStatefulWidget {
  const StatsScreen({super.key});

  @override
  ConsumerState<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends ConsumerState<StatsScreen> {
  StatsWindow _window = StatsWindow.days30;

  @override
  Widget build(BuildContext context) {
    final SettingsValueStore store = ref.watch(settingsStoreProvider);
    final SecretMaterialStore secretMaterialStore =
        ref.watch(secretMaterialStoreProvider);
    final OnboardingState onboarding = ref.watch(onboardingControllerProvider);
    final LanguagePack languagePack =
        resolveLanguagePack(onboarding.profile?.languageCode);
    final PracticeTelemetryRepository repository = PracticeTelemetryRepository(
      store: store,
      secretMaterialStore: secretMaterialStore,
    );

    return FutureBuilder<List<PracticeTelemetryEvent>>(
      future: repository.readAll(),
      builder: (BuildContext context,
          AsyncSnapshot<List<PracticeTelemetryEvent>> snapshot) {
        if (snapshot.hasError) {
          return SafeArea(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: const <Widget>[
                Card(
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Text('Stats are temporarily unavailable.'),
                  ),
                ),
              ],
            ),
          );
        }

        final StatsSummary summary = snapshot.hasData
            ? const StatsAggregator().summarize(
                snapshot.data!,
                windowDays: _window.days,
              )
            : StatsSummary.empty;

        return SafeArea(
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: <Widget>[
              Text(
                FallbackStrings.statsTitle(context),
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 8),
              Text(
                '${FallbackStrings.activeLanguagePack(context)}: ${languagePack.displayName} (${languagePack.taxonomyVersion})',
              ),
              const SizedBox(height: 12),
              SegmentedButton<StatsWindow>(
                segments: StatsWindow.values
                    .map(
                      (StatsWindow window) => ButtonSegment<StatsWindow>(
                        value: window,
                        label: Text(window.label),
                      ),
                    )
                    .toList(growable: false),
                selected: <StatsWindow>{_window},
                onSelectionChanged: (Set<StatsWindow> next) {
                  setState(() {
                    _window = next.first;
                  });
                },
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: <Widget>[
                  _kpiCard(context, 'practice minutes',
                      summary.practiceMinutes.toString()),
                  _kpiCard(context, 'streak', '${summary.streakDays} days'),
                  _kpiCard(context, FallbackStrings.sessionsLabel(context),
                      summary.sessionCount.toString()),
                  _kpiCard(context, 'avg session length',
                      '${summary.avgSessionLengthMinutes} min'),
                  _kpiCard(context, FallbackStrings.avgAsrLatencyLabel(context),
                      '${summary.avgAsrLatencyMs} ms'),
                  _kpiCard(
                      context,
                      FallbackStrings.avgTutorLatencyLabel(context),
                      '${summary.avgTutorLatencyMs} ms'),
                  _kpiCard(context, FallbackStrings.avgTtsLatencyLabel(context),
                      '${summary.avgTtsLatencyMs} ms'),
                  _kpiCard(
                    context,
                    FallbackStrings.avgConfidenceLabel(context),
                    summary.avgAsrConfidence.toStringAsFixed(2),
                  ),
                  _kpiCard(context, FallbackStrings.replaysLabel(context),
                      summary.replayCount.toString()),
                  _kpiCard(context, FallbackStrings.interruptionsLabel(context),
                      summary.interruptionCount.toString()),
                ],
              ),
              if (summary.sessionCount == 0) ...<Widget>[
                const SizedBox(height: 16),
                const Card(
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Text(
                      'No practice activity has landed in this time window yet.',
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 16),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: <Widget>[
                      _kpiCard(context, 'grammar tags',
                          summary.grammarTagCount.toString()),
                      _kpiCard(context, 'pronunciation tags',
                          summary.pronunciationTagCount.toString()),
                      _kpiCard(context, 'vocabulary tags',
                          summary.vocabularyTagCount.toString()),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        FallbackStrings.topMistakeTags(context),
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      if (summary.topMistakeTags.isEmpty)
                        Text(FallbackStrings.noMistakeTagsYet(context))
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
