import 'package:flutter/material.dart';

class AccessibilityBanner extends StatelessWidget {
  const AccessibilityBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: 'accessibility notice',
      child: Container(
        width: double.infinity,
        constraints: const BoxConstraints(minHeight: 48),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        color: Theme.of(context).colorScheme.secondaryContainer,
        child: Text(
          'Melangua supports large text, screen readers, and RTL language packs.',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      ),
    );
  }
}
