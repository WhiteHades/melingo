import 'dart:convert';

import '../models/model_install_state.dart';
import '../state/settings_state.dart';

class ModelInstallRepository {
  ModelInstallRepository({required SettingsValueStore store}) : _store = store;

  static const String _installKey = 'melingo_model_install_state_v1';

  final SettingsValueStore _store;

  Future<List<ModelInstallState>> readAll() async {
    final String? raw = await _store.readString(_installKey);
    if (raw == null || raw.isEmpty) {
      return <ModelInstallState>[];
    }
    final List<dynamic> list = jsonDecode(raw) as List<dynamic>;
    return list
        .map(
          (dynamic e) => ModelInstallState.fromMap(e as Map<String, dynamic>),
        )
        .toList(growable: false);
  }

  Future<void> upsert(ModelInstallState state) async {
    final List<ModelInstallState> states = await readAll();
    final int index = states.indexWhere((e) => e.bundleId == state.bundleId);
    final List<ModelInstallState> next = <ModelInstallState>[...states];
    if (index == -1) {
      next.add(state);
    } else {
      next[index] = state;
    }
    final String encoded = jsonEncode(
      next.map((e) => e.toMap()).toList(growable: false),
    );
    await _store.writeString(_installKey, encoded);
  }
}
