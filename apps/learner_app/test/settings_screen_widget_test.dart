import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:learner_app/l10n/app_localizations.dart';
import 'package:learner_app/src/features/settings/settings_screen.dart';
import 'package:learner_app/src/state/settings_state.dart';

void main() {
  testWidgets('settings screen renders encryption status',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: SettingsScreen(),
        ),
      ),
    );

    expect(find.text('Encryption status'), findsOneWidget);
  });

  testWidgets('settings screen toggles diagnostics switch',
      (WidgetTester tester) async {
    final SettingsRepository fakeRepository = SettingsRepository(
      settingsStore: InMemorySettingsStore(),
      secretMaterialStore: InMemorySecretMaterialStore(),
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          settingsRepositoryProvider.overrideWithValue(fakeRepository),
        ],
        child: const MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: SettingsScreen(),
        ),
      ),
    );

    final Finder diagnosticsSwitch =
        find.widgetWithText(SwitchListTile, 'Diagnostics opt-in');
    expect(diagnosticsSwitch, findsOneWidget);

    await tester.tap(diagnosticsSwitch);
    await tester.pump();

    final AppSettings stored = await fakeRepository.read();
    expect(stored.diagnosticsOptIn, true);
  });
}
