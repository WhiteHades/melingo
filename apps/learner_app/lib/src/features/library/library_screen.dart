import 'package:flutter/material.dart';

import '../shared/placeholder_scaffold.dart';

class LibraryScreen extends StatelessWidget {
  const LibraryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const PlaceholderScaffold(
      title: 'Library',
      description:
          'Scenario prompts, drills, grammar notes, and vocabulary decks will appear here.',
    );
  }
}
