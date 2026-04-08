import 'package:flutter/material.dart';

import '../../forms/onboarding_form.dart';
import '../../l10n/fallback_strings.dart';
import '../../widgets/accessibility_banner.dart';
import '../shared/placeholder_scaffold.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            const AccessibilityBanner(),
            PlaceholderScaffold(
              title: FallbackStrings.homeTitle(context),
              description: FallbackStrings.homeDescription(context),
            ),
            const Padding(
              padding: EdgeInsets.all(16),
              child: Card(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: OnboardingForm(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
