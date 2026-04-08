import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../firebase/firebase_sync.dart';
import '../../l10n/fallback_strings.dart';
import '../../l10n/language_packs.dart';
import '../../onboarding/onboarding_controller.dart';
import '../../onboarding/sync_queue.dart';
import '../shared/placeholder_scaffold.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final OnboardingState onboarding = ref.watch(onboardingControllerProvider);
    final FirebaseSyncService syncService =
        ref.watch(firebaseSyncServiceProvider);
    final SyncQueueRepository queue = ref.watch(syncQueueRepositoryProvider);

    if (onboarding.profile == null) {
      return PlaceholderScaffold(
        title: FallbackStrings.profileTitle(context),
        description: FallbackStrings.profileDescription(context),
      );
    }

    final profile = onboarding.profile!;
    final LanguagePack languagePack = resolveLanguagePack(profile.languageCode);

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: <Widget>[
          Text(
            FallbackStrings.profileTitle(context),
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    '${FallbackStrings.nameLabel(context)}: ${profile.displayName}',
                  ),
                  Text(
                    '${FallbackStrings.languageLabel(context)}: ${languagePack.displayName}',
                  ),
                  Text(
                    '${FallbackStrings.levelLabel(context)}: ${profile.level}',
                  ),
                  Text(
                    '${FallbackStrings.weeklyGoalLabel(context)}: ${profile.weeklyGoalMinutes} min',
                  ),
                  const SizedBox(height: 12),
                  Text(
                    '${FallbackStrings.contentVersionLabel(context)}: ${languagePack.contentVersion}',
                  ),
                  Text(
                    '${FallbackStrings.taxonomyVersionLabel(context)}: ${languagePack.taxonomyVersion}',
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          FutureBuilder<List<SyncQueueItem>>(
            future: queue.readAll(),
            builder: (BuildContext context,
                AsyncSnapshot<List<SyncQueueItem>> snapshot) {
              final int pending = snapshot.data?.length ?? 0;

              return Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        'cloud sync',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      Text('pending items: $pending'),
                      const SizedBox(height: 12),
                      OutlinedButton.icon(
                        onPressed: () async {
                          final int processed = await syncService.syncAll();
                          if (!context.mounted) {
                            return;
                          }
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('synced $processed item(s)'),
                            ),
                          );
                        },
                        icon: const Icon(Icons.sync),
                        label: const Text('sync now'),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    FallbackStrings.donationTitle(context),
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(FallbackStrings.donationBody(context)),
                  const SizedBox(height: 12),
                  SelectableText(FallbackStrings.donationLink(context)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
