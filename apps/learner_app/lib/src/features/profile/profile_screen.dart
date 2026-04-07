import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../onboarding/onboarding_controller.dart';
import '../shared/placeholder_scaffold.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final OnboardingState onboarding = ref.watch(onboardingControllerProvider);

    if (onboarding.profile == null) {
      return const PlaceholderScaffold(
        title: 'Profile',
        description:
            'Profile summary, streaks, goals, and support prompts will be shown here.',
      );
    }

    final profile = onboarding.profile!;

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: <Widget>[
          Text('profile', style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text('name: ${profile.displayName}'),
                  Text('language: ${profile.languageCode}'),
                  Text('level: ${profile.level}'),
                  Text('weekly goal: ${profile.weeklyGoalMinutes} min'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
