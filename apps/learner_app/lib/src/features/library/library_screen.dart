import 'package:flutter/material.dart';

import '../../l10n/fallback_strings.dart';
import '../shared/placeholder_scaffold.dart';

class LibraryScreen extends StatelessWidget {
  const LibraryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return PlaceholderScaffold(
      title: FallbackStrings.libraryTitle(context),
      description: FallbackStrings.libraryDescription(context),
    );
  }
}
