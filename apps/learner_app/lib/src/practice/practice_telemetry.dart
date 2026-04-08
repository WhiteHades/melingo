import 'dart:convert';

import '../state/settings_state.dart';

class PracticeTelemetryEvent {
  const PracticeTelemetryEvent({
    required this.type,
    required this.turnId,
    required this.occurredAtIso,
    required this.metrics,
  });

  final String type;
  final String turnId;
  final String occurredAtIso;
  final Map<String, dynamic> metrics;

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'type': type,
      'turnId': turnId,
      'occurredAtIso': occurredAtIso,
      'metrics': metrics,
    };
  }

  static PracticeTelemetryEvent fromMap(Map<String, dynamic> map) {
    return PracticeTelemetryEvent(
      type: map['type'] as String,
      turnId: map['turnId'] as String,
      occurredAtIso: map['occurredAtIso'] as String,
      metrics:
          Map<String, dynamic>.from(map['metrics'] as Map<String, dynamic>),
    );
  }
}

class PracticeTelemetryRepository {
  PracticeTelemetryRepository({required SettingsValueStore store})
      : _store = store;

  static const String _eventsKey = 'melingo_practice_telemetry_events_v1';

  final SettingsValueStore _store;

  Future<List<PracticeTelemetryEvent>> readAll() async {
    final String? raw = await _store.readString(_eventsKey);
    if (raw == null || raw.isEmpty) {
      return <PracticeTelemetryEvent>[];
    }

    final List<dynamic> decoded = jsonDecode(raw) as List<dynamic>;
    return decoded
        .map((dynamic row) =>
            PracticeTelemetryEvent.fromMap(row as Map<String, dynamic>))
        .toList(growable: false);
  }

  Future<void> append(PracticeTelemetryEvent event) async {
    final List<PracticeTelemetryEvent> existing = await readAll();
    final List<PracticeTelemetryEvent> next = <PracticeTelemetryEvent>[
      ...existing,
      event
    ];
    final String encoded =
        jsonEncode(next.map((e) => e.toMap()).toList(growable: false));
    await _store.writeString(_eventsKey, encoded);
  }
}
