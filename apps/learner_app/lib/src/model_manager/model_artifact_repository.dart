import 'dart:convert';

import '../state/settings_state.dart';

class ModelArtifactRepository {
  ModelArtifactRepository({required SettingsValueStore store}) : _store = store;

  static const String _artifactKeyPrefix = 'melingo_model_artifact_v1_';

  final SettingsValueStore _store;

  Future<List<int>> readOrDownload(String bundleId) async {
    final List<int>? cached = await read(bundleId);
    if (cached != null) {
      return cached;
    }

    final List<int> downloaded = _download(bundleId);
    await write(bundleId, downloaded);
    return downloaded;
  }

  Future<List<int>?> read(String bundleId) async {
    final String? encoded = await _store.readString(_storageKey(bundleId));
    if (encoded == null || encoded.isEmpty) {
      return null;
    }
    return base64Decode(encoded);
  }

  Future<void> write(String bundleId, List<int> bytes) async {
    await _store.writeString(_storageKey(bundleId), base64Encode(bytes));
  }

  List<int> _download(String bundleId) {
    return utf8.encode('melingo-$bundleId-model-v1');
  }

  String _storageKey(String bundleId) {
    return '$_artifactKeyPrefix$bundleId';
  }
}
