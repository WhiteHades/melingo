import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../model_manager/model_manager_controller.dart';

class ModelManagerScreen extends ConsumerWidget {
  const ModelManagerScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ModelManagerState state = ref.watch(modelManagerControllerProvider);

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: <Widget>[
          Row(
            children: <Widget>[
              Text(
                'models',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const Spacer(),
              IconButton(
                onPressed: () {
                  ref.read(modelManagerControllerProvider.notifier).refreshManifest();
                },
                icon: const Icon(Icons.refresh),
                tooltip: 'refresh manifest',
              ),
            ],
          ),
          const SizedBox(height: 8),
          if (state.manifest != null)
            Text('manifest version: ${state.manifest!.version}')
          else
            const Text('no cached manifest available yet'),
          if (state.error != null) ...<Widget>[
            const SizedBox(height: 8),
            Text(
              state.error!,
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ],
          const SizedBox(height: 12),
          ..._bundleCards(context, ref, state),
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  const Text('model health'),
                  const SizedBox(height: 8),
                  Text('ready: ${state.health?.ready ?? false}'),
                  Text('installed: ${state.health?.installedBundles.join(', ') ?? 'none'}'),
                  Text('last check: ${state.health?.lastCheckedIso ?? 'n/a'}'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _bundleCards(
    BuildContext context,
    WidgetRef ref,
    ModelManagerState state,
  ) {
    final bundles = state.manifest?.bundles ?? const <dynamic>[];
    return bundles.map((bundle) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(bundle.id, style: Theme.of(context).textTheme.titleMedium),
              Text('size: ${bundle.sizeMb} mb'),
              Text('min ram: ${bundle.minRamMb} mb'),
              Text('languages: ${bundle.languages.join(', ')}'),
              Text('offline: ${bundle.offlineCapable}'),
              const SizedBox(height: 8),
              Row(
                children: <Widget>[
                  FilledButton.tonal(
                    onPressed: () {
                      ref
                          .read(modelManagerControllerProvider.notifier)
                          .markInstallStarted(bundle.id);
                    },
                    child: const Text('download'),
                  ),
                  const SizedBox(width: 8),
                  OutlinedButton(
                    onPressed: () {
                      ref
                          .read(modelManagerControllerProvider.notifier)
                          .markInstallReady(bundle.id);
                    },
                    child: const Text('mark ready'),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    }).toList(growable: false);
  }
}
