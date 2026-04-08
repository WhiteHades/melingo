import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/semantics.dart';

import 'l10n/app_localizations.dart';
import 'src/app.dart';
import 'src/l10n/language_packs.dart';
import 'src/onboarding/onboarding_controller.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  if (kIsWeb) {
    SemanticsBinding.instance.ensureSemantics();
  }
  runApp(const ProviderScope(child: MelingoApp()));
}

class MelingoApp extends ConsumerWidget {
  const MelingoApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final OnboardingState onboarding = ref.watch(onboardingControllerProvider);
    final LanguagePack languagePack =
        resolveLanguagePack(onboarding.profile?.languageCode);

    return MaterialApp.router(
      title: 'Melingo',
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      locale: languagePack.locale,
      theme: melingoLightTheme(),
      darkTheme: melingoDarkTheme(),
      themeMode: ThemeMode.system,
      routerConfig: appRouter,
      debugShowCheckedModeBanner: false,
    );
  }
}
