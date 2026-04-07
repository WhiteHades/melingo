import 'dart:convert';

import '../state/settings_state.dart';

class SyncQueueItem {
  const SyncQueueItem({
    required this.type,
    required this.payload,
    required this.createdAtIso,
  });

  final String type;
  final Map<String, dynamic> payload;
  final String createdAtIso;

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'type': type,
      'payload': payload,
      'createdAtIso': createdAtIso,
    };
  }

  static SyncQueueItem fromMap(Map<String, dynamic> map) {
    return SyncQueueItem(
      type: map['type'] as String,
      payload: map['payload'] as Map<String, dynamic>,
      createdAtIso: map['createdAtIso'] as String,
    );
  }
}

class SyncQueueRepository {
  SyncQueueRepository({required SettingsValueStore store}) : _store = store;

  static const String _queueKey = 'melingo_sync_queue_v1';

  final SettingsValueStore _store;

  Future<List<SyncQueueItem>> readAll() async {
    final String? raw = await _store.readString(_queueKey);
    if (raw == null || raw.isEmpty) {
      return <SyncQueueItem>[];
    }

    final List<dynamic> list = jsonDecode(raw) as List<dynamic>;
    return list
        .map((dynamic item) =>
            SyncQueueItem.fromMap(item as Map<String, dynamic>))
        .toList(growable: false);
  }

  Future<void> enqueue(SyncQueueItem item) async {
    final List<SyncQueueItem> existing = await readAll();
    final List<SyncQueueItem> next = <SyncQueueItem>[...existing, item];
    final String raw = jsonEncode(
      next.map((SyncQueueItem e) => e.toMap()).toList(growable: false),
    );
    await _store.writeString(_queueKey, raw);
  }
}
