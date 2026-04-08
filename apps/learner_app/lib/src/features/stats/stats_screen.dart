import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../l10n/fallback_strings.dart';
import '../../l10n/language_packs.dart';
import '../../onboarding/onboarding_controller.dart';
import '../../practice/practice_telemetry.dart';
import '../../state/settings_state.dart';
import 'stats_aggregator.dart';

class StatsScreen extends ConsumerWidget {
  const StatsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
        final StatsSummary summary = snapshot.hasData
            ? const StatsAggregator().summarize(snapshot.data!)
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
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: <Widget>[
                  _kpiCard(context, FallbackStrings.sessionsLabel(context),
                      summary.sessionCount.toString()),
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
              const SizedBox(height: 16),
              Text(
                FallbackStrings.trendSummary(context),
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
