import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:learner_app/src/state/settings_state.dart';

void main() {
  group('settings repository', () {
    test('reads defaults when storage is empty', () async {
      final SettingsRepository repository = SettingsRepository(
        settingsStore: InMemorySettingsStore(),
        secretMaterialStore: InMemorySecretMaterialStore(),
      );

      final AppSettings settings = await repository.read();

      expect(settings.diagnosticsOptIn, false);
      expect(settings.storeRawAudioLocally, false);
      expect(settings.encryptionEnabled, true);
    });

    test('writes and reads settings through encoded payload', () async {
      final SettingsRepository repository = SettingsRepository(
        settingsStore: InMemorySettingsStore(),
        secretMaterialStore: InMemorySecretMaterialStore(),
      );
      const AppSettings expected = AppSettings(
        diagnosticsOptIn: true,
        storeRawAudioLocally: true,
        encryptionEnabled: true,
      );

      await repository.write(expected);
      final AppSettings actual = await repository.read();

      expect(actual.diagnosticsOptIn, true);
      expect(actual.storeRawAudioLocally, true);
      expect(actual.encryptionEnabled, true);
    });

    test('stored payload is not raw json map', () async {
      final InMemorySettingsStore store = InMemorySettingsStore();
      final SettingsRepository repository = SettingsRepository(
        settingsStore: store,
        secretMaterialStore: InMemorySecretMaterialStore(),
      );

      await repository.write(AppSettings.defaults);

      final String? raw = await store.readString('melingo_settings_v2');
      expect(raw, isNotNull);
      final Map<String, dynamic> parsed =
          jsonDecode(raw!) as Map<String, dynamic>;
      expect(parsed.containsKey('cipherText'), true);
      expect(parsed.containsKey('nonce'), true);
      expect(parsed.containsKey('mac'), true);
      expect((parsed['cipherText'] as String).contains('{'), false);
    });
  });
}
