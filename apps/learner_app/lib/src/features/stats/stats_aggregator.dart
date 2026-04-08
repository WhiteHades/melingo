import '../../practice/practice_telemetry.dart';

class StatsSummary {
  const StatsSummary({
    required this.practiceMinutes,
    required this.streakDays,
    required this.sessionCount,
    required this.avgSessionLengthMinutes,
    required this.avgAsrLatencyMs,
    required this.avgTutorLatencyMs,
    required this.avgTtsLatencyMs,
    required this.avgAsrConfidence,
    required this.topMistakeTags,
    required this.replayCount,
    required this.interruptionCount,
    required this.grammarTagCount,
    required this.pronunciationTagCount,
    required this.vocabularyTagCount,
  });

  final int practiceMinutes;
  final int streakDays;
  final int sessionCount;
  final int avgSessionLengthMinutes;
  final int avgAsrLatencyMs;
  final int avgTutorLatencyMs;
  final int avgTtsLatencyMs;
  final double avgAsrConfidence;
  final List<String> topMistakeTags;
  final int replayCount;
  final int interruptionCount;
  final int grammarTagCount;
  final int pronunciationTagCount;
  final int vocabularyTagCount;

  static const StatsSummary empty = StatsSummary(
    practiceMinutes: 0,
    streakDays: 0,
    sessionCount: 0,
    avgSessionLengthMinutes: 0,
    avgAsrLatencyMs: 0,
    avgTutorLatencyMs: 0,
    avgTtsLatencyMs: 0,
    avgAsrConfidence: 0,
    topMistakeTags: <String>[],
    replayCount: 0,
    interruptionCount: 0,
    grammarTagCount: 0,
    pronunciationTagCount: 0,
    vocabularyTagCount: 0,
  );
}

class StatsAggregator {
  const StatsAggregator();

  StatsSummary summarize(
    List<PracticeTelemetryEvent> events, {
    DateTime? now,
    int windowDays = 30,
  }) {
    final DateTime effectiveNow = (now ?? DateTime.now()).toUtc();
    final DateTime cutoff = DateTime.utc(
      effectiveNow.year,
      effectiveNow.month,
      effectiveNow.day,
    ).subtract(Duration(days: windowDays - 1));

    final List<PracticeTelemetryEvent> filtered = events.where((event) {
      final DateTime? occurredAt = _parseIso(event.occurredAtIso);
      return occurredAt != null && !occurredAt.isBefore(cutoff);
    }).toList(growable: false);

    if (filtered.isEmpty) {
      return StatsSummary.empty;
    }

    final Set<String> turnIds = <String>{};
    final Map<String, _TurnWindow> turnWindows = <String, _TurnWindow>{};
    final Set<String> activeDays = <String>{};
    int asrLatencyTotal = 0;
    int asrLatencyCount = 0;
    double asrConfidenceTotal = 0;
    int asrConfidenceCount = 0;
    int tutorLatencyTotal = 0;
    int tutorLatencyCount = 0;
    int ttsLatencyTotal = 0;
    int ttsLatencyCount = 0;
    int replayCount = 0;
    int interruptionCount = 0;
    int grammarTagCount = 0;
    int pronunciationTagCount = 0;
    int vocabularyTagCount = 0;
    final Map<String, int> tagCounts = <String, int>{};

    for (final PracticeTelemetryEvent event in filtered) {
      final DateTime occurredAt = _parseIso(event.occurredAtIso)!;
      if (event.turnId.isNotEmpty) {
        turnIds.add(event.turnId);
        turnWindows.update(
          event.turnId,
          (_TurnWindow current) => current.expand(occurredAt),
          ifAbsent: () => _TurnWindow(start: occurredAt, end: occurredAt),
        );
      }
      activeDays.add(_dayKey(occurredAt));

      switch (event.type) {
        case 'asr_result':
          final int? latencyMs = _toInt(event.metrics['latencyMs']);
          final double? confidence = _toDouble(event.metrics['confidence']);
          if (latencyMs != null) {
            asrLatencyTotal += latencyMs;
            asrLatencyCount += 1;
          }
          if (confidence != null) {
            asrConfidenceTotal += confidence;
            asrConfidenceCount += 1;
          }
          break;
        case 'tutor_result':
          final int? latencyMs = _toInt(event.metrics['latencyMs']);
          if (latencyMs != null) {
            tutorLatencyTotal += latencyMs;
            tutorLatencyCount += 1;
          }
          final List<String> tags = _toStringList(event.metrics['mistakeTags']);
          for (final String tag in tags) {
            tagCounts.update(tag, (int current) => current + 1,
                ifAbsent: () => 1);
            if (tag.startsWith('grammar:')) {
              grammarTagCount += 1;
            }
            if (tag.startsWith('pronunciation:')) {
              pronunciationTagCount += 1;
            }
            if (tag.startsWith('vocabulary:') || tag.startsWith('vocab:')) {
              vocabularyTagCount += 1;
            }
          }
          break;
        case 'tts_result':
          final int? latencyMs = _toInt(event.metrics['latencyMs']);
          if (latencyMs != null) {
            ttsLatencyTotal += latencyMs;
            ttsLatencyCount += 1;
          }
          break;
        case 'tts_replay':
          replayCount += 1;
          break;
        case 'tts_interrupted':
          interruptionCount += 1;
          break;
        default:
          break;
      }
    }

    final List<MapEntry<String, int>> sortedTags = tagCounts.entries
        .toList(growable: false)
      ..sort((MapEntry<String, int> a, MapEntry<String, int> b) =>
          b.value.compareTo(a.value));

    final List<int> sessionMinutes = turnWindows.values
        .map((window) => window.durationMinutes)
        .toList(growable: false);
    final int practiceMinutes =
        sessionMinutes.fold(0, (int total, int minutes) => total + minutes);

    return StatsSummary(
      practiceMinutes: practiceMinutes,
      streakDays: _streakDays(activeDays, effectiveNow),
      sessionCount: turnIds.length,
      avgSessionLengthMinutes: _averageInt(practiceMinutes, turnWindows.length),
      avgAsrLatencyMs: _averageInt(asrLatencyTotal, asrLatencyCount),
      avgTutorLatencyMs: _averageInt(tutorLatencyTotal, tutorLatencyCount),
      avgTtsLatencyMs: _averageInt(ttsLatencyTotal, ttsLatencyCount),
      avgAsrConfidence: _averageDouble(asrConfidenceTotal, asrConfidenceCount),
      topMistakeTags:
          sortedTags.take(3).map((MapEntry<String, int> e) => e.key).toList(),
      replayCount: replayCount,
      interruptionCount: interruptionCount,
      grammarTagCount: grammarTagCount,
      pronunciationTagCount: pronunciationTagCount,
      vocabularyTagCount: vocabularyTagCount,
    );
  }

  int _streakDays(Set<String> activeDays, DateTime now) {
    int streak = 0;
    DateTime cursor = DateTime.utc(now.year, now.month, now.day);

    while (activeDays.contains(_dayKey(cursor))) {
      streak += 1;
      cursor = cursor.subtract(const Duration(days: 1));
    }

    return streak;
  }

  int _averageInt(int total, int count) {
    if (count == 0) {
      return 0;
    }
    return (total / count).round();
  }

  double _averageDouble(double total, int count) {
    if (count == 0) {
      return 0;
    }
    return total / count;
  }

  int? _toInt(dynamic value) {
    if (value is int) {
      return value;
    }
    if (value is num) {
      return value.round();
    }
    return null;
  }

  double? _toDouble(dynamic value) {
    if (value is double) {
      return value;
    }
    if (value is num) {
      return value.toDouble();
    }
    return null;
  }

  List<String> _toStringList(dynamic value) {
    if (value is List<dynamic>) {
      return value
          .whereType<String>()
          .where((String tag) => tag.isNotEmpty)
          .toList(growable: false);
    }
    return const <String>[];
  }

  DateTime? _parseIso(String value) {
    return DateTime.tryParse(value)?.toUtc();
  }

  String _dayKey(DateTime value) {
    final DateTime utc = value.toUtc();
    return '${utc.year.toString().padLeft(4, '0')}-${utc.month.toString().padLeft(2, '0')}-${utc.day.toString().padLeft(2, '0')}';
  }
}

class _TurnWindow {
  const _TurnWindow({required this.start, required this.end});

  final DateTime start;
  final DateTime end;

  _TurnWindow expand(DateTime value) {
    return _TurnWindow(
      start: value.isBefore(start) ? value : start,
      end: value.isAfter(end) ? value : end,
    );
  }

  int get durationMinutes {
    final int elapsedSeconds = end.difference(start).inSeconds;
    final int normalizedSeconds = elapsedSeconds < 60 ? 60 : elapsedSeconds;
    return (normalizedSeconds / 60).ceil();
  }
}
