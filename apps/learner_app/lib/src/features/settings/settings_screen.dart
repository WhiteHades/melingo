import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../l10n/fallback_strings.dart';
import '../../state/settings_state.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppSettings settings = ref.watch(settingsProvider);

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: <Widget>[
            Text(
              FallbackStrings.settingsTitle(context),
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              FallbackStrings.settingsPrivacyDescription(context),
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 20),
            SwitchListTile(
              value: settings.diagnosticsOptIn,
              title: Text(FallbackStrings.diagnosticsOptIn(context)),
              subtitle: Text(
                FallbackStrings.diagnosticsDescription(context),
              ),
              onChanged: (bool value) {
                ref.read(settingsProvider.notifier).setDiagnosticsOptIn(value);
              },
            ),
            SwitchListTile(
              value: settings.storeRawAudioLocally,
              title: Text(FallbackStrings.storeRawAudio(context)),
              subtitle: Text(
                FallbackStrings.storeRawAudioDescription(context),
              ),
              onChanged: (bool value) {
                ref
                    .read(settingsProvider.notifier)
                    .setStoreRawAudioLocally(value);
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.shield_outlined),
              title: Text(FallbackStrings.encryptionStatus(context)),
              subtitle: Text(
                settings.encryptionEnabled
                    ? FallbackStrings.encryptionEnabled(context)
                    : FallbackStrings.encryptionDisabled(context),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.memory_outlined),
              title: Text(FallbackStrings.modelManagerTitle(context)),
              subtitle: Text(FallbackStrings.modelManagerDescription(context)),
              onTap: () {
                context.push('/models');
              },
            ),
          ],
        ),
      ),
    );
  }
}
