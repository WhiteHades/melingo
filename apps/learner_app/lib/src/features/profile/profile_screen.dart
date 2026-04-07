import 'package:flutter/material.dart';

import '../shared/placeholder_scaffold.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const PlaceholderScaffold(
      title: 'Profile',
      description:
          'Profile summary, streaks, goals, and support prompts will be shown here.',
    );
  }
}
