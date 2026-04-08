import 'dart:convert';

import '../models/model_health.dart';
import '../state/settings_state.dart';

class ModelHealthRepository {
  ModelHealthRepository({required SettingsValueStore store}) : _store = store;

  static const String _healthKey = 'melangua_model_health_v1';

  final SettingsValueStore _store;

  Future<ModelHealth> read() async {
    final String? raw = await _store.readString(_healthKey);
    if (raw == null || raw.isEmpty) {
      return ModelHealth(
        ready: false,
        installedBundles: const <String>[],
        lastCheckedIso: DateTime.now().toUtc().toIso8601String(),
      );
    }
    return ModelHealth.fromMap(jsonDecode(raw) as Map<String, dynamic>);
  }

  Future<void> write(ModelHealth health) async {
    await _store.writeString(_healthKey, jsonEncode(health.toMap()));
  }
}
