import 'dart:convert';
import 'dart:math';

import 'package:cryptography/cryptography.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppSettings {
  const AppSettings({
    required this.diagnosticsOptIn,
    required this.storeRawAudioLocally,
    required this.encryptionEnabled,
  });

  final bool diagnosticsOptIn;
  final bool storeRawAudioLocally;
  final bool encryptionEnabled;

  AppSettings copyWith({
    bool? diagnosticsOptIn,
    bool? storeRawAudioLocally,
    bool? encryptionEnabled,
  }) {
    return AppSettings(
      diagnosticsOptIn: diagnosticsOptIn ?? this.diagnosticsOptIn,
      storeRawAudioLocally: storeRawAudioLocally ?? this.storeRawAudioLocally,
      encryptionEnabled: encryptionEnabled ?? this.encryptionEnabled,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'diagnosticsOptIn': diagnosticsOptIn,
      'storeRawAudioLocally': storeRawAudioLocally,
      'encryptionEnabled': encryptionEnabled,
    };
  }

  static AppSettings fromMap(Map<String, dynamic> map) {
    return AppSettings(
      diagnosticsOptIn: map['diagnosticsOptIn'] as bool? ?? false,
      storeRawAudioLocally: map['storeRawAudioLocally'] as bool? ?? false,
      encryptionEnabled: map['encryptionEnabled'] as bool? ?? true,
    );
  }

  static const AppSettings defaults = AppSettings(
    diagnosticsOptIn: false,
    storeRawAudioLocally: false,
    encryptionEnabled: true,
  );
}

class SettingsRepository {
  SettingsRepository({
    SettingsValueStore? settingsStore,
    SecretMaterialStore? secretMaterialStore,
  })  : _settingsStore = settingsStore ?? SharedPreferencesSettingsStore(),
        _cipher = SettingsCipher(
          secretMaterialStore:
              secretMaterialStore ?? FlutterSecureSecretMaterialStore(),
        );

  static const String _storageKey = 'melangua_settings_v2';

  final SettingsValueStore _settingsStore;
  final SettingsCipher _cipher;

  Future<AppSettings> read() async {
    final String? raw = await _settingsStore.readString(_storageKey);
    if (raw == null || raw.isEmpty) {
      return AppSettings.defaults;
    }

    try {
      final EncryptedPayload payload = EncryptedPayload.fromJson(
        jsonDecode(raw) as Map<String, dynamic>,
      );
      final String decrypted = await _cipher.decrypt(payload);
      final Map<String, dynamic> map =
          jsonDecode(decrypted) as Map<String, dynamic>;
      return AppSettings.fromMap(map);
    } catch (_) {
      return AppSettings.defaults;
    }
  }

  Future<void> write(AppSettings settings) async {
    final String payload = jsonEncode(settings.toMap());
    final EncryptedPayload encryptedPayload = await _cipher.encrypt(payload);
    final String wrapped = jsonEncode(encryptedPayload.toJson());
    await _settingsStore.writeString(_storageKey, wrapped);
  }
}

abstract class SettingsValueStore {
  Future<String?> readString(String key);
  Future<void> writeString(String key, String value);
}

class SharedPreferencesSettingsStore implements SettingsValueStore {
  @override
  Future<String?> readString(String key) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(key);
  }

  @override
  Future<void> writeString(String key, String value) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(key, value);
  }
}

class InMemorySettingsStore implements SettingsValueStore {
  InMemorySettingsStore([Map<String, String>? initial])
      : _items = initial ?? <String, String>{};

  final Map<String, String> _items;

  @override
  Future<String?> readString(String key) async {
    return _items[key];
  }

  @override
  Future<void> writeString(String key, String value) async {
    _items[key] = value;
  }
}

abstract class SecretMaterialStore {
  Future<String?> readSecret(String key);
  Future<void> writeSecret(String key, String value);
}

class FlutterSecureSecretMaterialStore implements SecretMaterialStore {
  FlutterSecureSecretMaterialStore({FlutterSecureStorage? storage})
      : _storage = storage ?? const FlutterSecureStorage();

  final FlutterSecureStorage _storage;

  @override
  Future<String?> readSecret(String key) {
    return _storage.read(key: key);
  }

  @override
  Future<void> writeSecret(String key, String value) {
    return _storage.write(key: key, value: value);
  }
}

class InMemorySecretMaterialStore implements SecretMaterialStore {
  InMemorySecretMaterialStore([Map<String, String>? initial])
      : _items = initial ?? <String, String>{};

  final Map<String, String> _items;

  @override
  Future<String?> readSecret(String key) async {
    return _items[key];
  }

  @override
  Future<void> writeSecret(String key, String value) async {
    _items[key] = value;
  }
}

class EncryptedSettingsValueStore implements SettingsValueStore {
  EncryptedSettingsValueStore({
    required SettingsValueStore inner,
    required SecretMaterialStore secretMaterialStore,
  })  : _inner = inner,
        _cipher = SettingsCipher(secretMaterialStore: secretMaterialStore);

  final SettingsValueStore _inner;
  final SettingsCipher _cipher;

  @override
  Future<String?> readString(String key) async {
    final String? raw = await _inner.readString(key);
    if (raw == null || raw.isEmpty) {
      return raw;
    }

    try {
      final EncryptedPayload payload = EncryptedPayload.fromJson(
        jsonDecode(raw) as Map<String, dynamic>,
      );
      return await _cipher.decrypt(payload);
    } catch (_) {
      // Preserve access to any plaintext values written before encryption was enforced.
      return raw;
    }
  }

  @override
  Future<void> writeString(String key, String value) async {
    final EncryptedPayload payload = await _cipher.encrypt(value);
    await _inner.writeString(key, jsonEncode(payload.toJson()));
  }
}

class EncryptedPayload {
  const EncryptedPayload({
    required this.nonce,
    required this.cipherText,
    required this.mac,
  });

  final String nonce;
  final String cipherText;
  final String mac;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'nonce': nonce,
      'cipherText': cipherText,
      'mac': mac,
    };
  }

  static EncryptedPayload fromJson(Map<String, dynamic> map) {
    return EncryptedPayload(
      nonce: map['nonce'] as String,
      cipherText: map['cipherText'] as String,
      mac: map['mac'] as String,
    );
  }
}

class SettingsCipher {
  SettingsCipher({
    required SecretMaterialStore secretMaterialStore,
    AesGcm? algorithm,
  })  : _secretMaterialStore = secretMaterialStore,
        _algorithm = algorithm ?? AesGcm.with256bits();

  static const String _keyAlias = 'melangua_settings_aes_key_v1';

  final SecretMaterialStore _secretMaterialStore;
  final AesGcm _algorithm;

  Future<EncryptedPayload> encrypt(String plainText) async {
    final SecretKey key = await _readOrCreateSecretKey();
    final List<int> nonce = _randomBytes(12);
    final SecretBox box = await _algorithm.encrypt(
      utf8.encode(plainText),
      secretKey: key,
      nonce: nonce,
    );

    return EncryptedPayload(
      nonce: base64Encode(box.nonce),
      cipherText: base64Encode(box.cipherText),
      mac: base64Encode(box.mac.bytes),
    );
  }

  Future<String> decrypt(EncryptedPayload payload) async {
    final SecretKey key = await _readOrCreateSecretKey();
    final SecretBox box = SecretBox(
      base64Decode(payload.cipherText),
      nonce: base64Decode(payload.nonce),
      mac: Mac(base64Decode(payload.mac)),
    );
    final List<int> clearBytes = await _algorithm.decrypt(box, secretKey: key);
    return utf8.decode(clearBytes);
  }

  Future<SecretKey> _readOrCreateSecretKey() async {
    final String? stored = await _secretMaterialStore.readSecret(_keyAlias);
    if (stored != null && stored.isNotEmpty) {
      return SecretKey(base64Decode(stored));
    }

    final List<int> keyBytes = _randomBytes(32);
    await _secretMaterialStore.writeSecret(_keyAlias, base64Encode(keyBytes));
    return SecretKey(keyBytes);
  }

  List<int> _randomBytes(int length) {
    final Random random = Random.secure();
    return List<int>.generate(length, (_) => random.nextInt(256));
  }
}

class SettingsNotifier extends StateNotifier<AppSettings> {
  SettingsNotifier(this._repository) : super(AppSettings.defaults) {
    _load();
  }

  final SettingsRepository _repository;

  Future<void> _load() async {
    state = await _repository.read();
  }

  Future<void> setDiagnosticsOptIn(bool value) async {
    state = state.copyWith(diagnosticsOptIn: value);
    await _repository.write(state);
  }

  Future<void> setStoreRawAudioLocally(bool value) async {
    state = state.copyWith(storeRawAudioLocally: value);
    await _repository.write(state);
  }
}

final Provider<SettingsRepository> settingsRepositoryProvider =
    Provider<SettingsRepository>((Ref ref) {
  final SettingsValueStore store = ref.watch(settingsStoreProvider);
  final SecretMaterialStore secretMaterialStore =
      ref.watch(secretMaterialStoreProvider);
  return SettingsRepository(
    settingsStore: store,
    secretMaterialStore: secretMaterialStore,
  );
});

final Provider<SettingsValueStore> settingsStoreProvider =
    Provider<SettingsValueStore>((Ref ref) {
  return SharedPreferencesSettingsStore();
});

final Provider<SecretMaterialStore> secretMaterialStoreProvider =
    Provider<SecretMaterialStore>((Ref ref) {
  return FlutterSecureSecretMaterialStore();
});

final StateNotifierProvider<SettingsNotifier, AppSettings> settingsProvider =
    StateNotifierProvider<SettingsNotifier, AppSettings>(
  (Ref ref) {
    final SettingsRepository repository = ref.watch(settingsRepositoryProvider);
    return SettingsNotifier(repository);
  },
);
