import 'dart:convert';

import '../models/model_manifest.dart';
import '../state/settings_state.dart';
import '../network/model_manifest_client.dart';

class ModelManifestRepository {
  ModelManifestRepository({
    required ModelManifestClient client,
    required SettingsValueStore store,
  })  : _client = client,
        _store = store;

  static const String _cacheKey = 'melangua_model_manifest_cache_v1';

  final ModelManifestClient _client;
  final SettingsValueStore _store;

  Future<ModelManifest?> readCached() async {
    final String? raw = await _store.readString(_cacheKey);
    if (raw == null || raw.isEmpty) {
      return null;
    }
    return ModelManifest.fromMap(jsonDecode(raw) as Map<String, dynamic>);
  }

  Future<ModelManifest> fetchAndCache() async {
    final ModelManifest manifest = await _client.fetchManifest();
    final Map<String, dynamic> mapped = <String, dynamic>{
      'version': manifest.version,
      'bundles': manifest.bundles.map((e) => e.toMap()).toList(growable: false),
    };
    await _store.writeString(_cacheKey, jsonEncode(mapped));
    return manifest;
  }
}
