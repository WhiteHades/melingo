import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/semantics.dart';

import 'l10n/app_localizations.dart';
import 'src/app.dart';
import 'src/firebase/firebase_bootstrap.dart';
import 'src/l10n/language_packs.dart';
import 'src/onboarding/onboarding_controller.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await FirebaseBootstrap.initialize();
  if (kIsWeb) {
    SemanticsBinding.instance.ensureSemantics();
  }
  runApp(const ProviderScope(child: MelanguaApp()));
}

class MelanguaApp extends ConsumerWidget {
  const MelanguaApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final OnboardingState onboarding = ref.watch(onboardingControllerProvider);
    final LanguagePack languagePack =
        resolveLanguagePack(onboarding.profile?.languageCode);

    return MaterialApp.router(
      title: 'Melangua',
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      locale: languagePack.locale,
      theme: melanguaLightTheme(),
      darkTheme: melanguaDarkTheme(),
      themeMode: ThemeMode.system,
      routerConfig: appRouter,
      debugShowCheckedModeBanner: false,
    );
  }
}
