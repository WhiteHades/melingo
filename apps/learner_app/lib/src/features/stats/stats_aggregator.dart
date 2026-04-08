import '../../practice/practice_telemetry.dart';

class StatsSummary {
  const StatsSummary({
    required this.sessionCount,
    required this.avgAsrLatencyMs,
    required this.avgTutorLatencyMs,
    required this.avgTtsLatencyMs,
    required this.avgAsrConfidence,
    required this.topMistakeTags,
    required this.replayCount,
    required this.interruptionCount,
  });

  final int sessionCount;
  final int avgAsrLatencyMs;
  final int avgTutorLatencyMs;
  final int avgTtsLatencyMs;
  final double avgAsrConfidence;
  final List<String> topMistakeTags;
  final int replayCount;
  final int interruptionCount;

  static const StatsSummary empty = StatsSummary(
    sessionCount: 0,
    avgAsrLatencyMs: 0,
    avgTutorLatencyMs: 0,
    avgTtsLatencyMs: 0,
    avgAsrConfidence: 0,
    topMistakeTags: <String>[],
    replayCount: 0,
    interruptionCount: 0,
  );
}

class StatsAggregator {
  const StatsAggregator();

  StatsSummary summarize(List<PracticeTelemetryEvent> events) {
    if (events.isEmpty) {
      return StatsSummary.empty;
    }

    final Set<String> turnIds = <String>{};
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
    final Map<String, int> tagCounts = <String, int>{};

    for (final PracticeTelemetryEvent event in events) {
      if (event.turnId.isNotEmpty) {
        turnIds.add(event.turnId);
      }

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

    return StatsSummary(
      sessionCount: turnIds.length,
      avgAsrLatencyMs: _averageInt(asrLatencyTotal, asrLatencyCount),
      avgTutorLatencyMs: _averageInt(tutorLatencyTotal, tutorLatencyCount),
      avgTtsLatencyMs: _averageInt(ttsLatencyTotal, ttsLatencyCount),
      avgAsrConfidence: _averageDouble(asrConfidenceTotal, asrConfidenceCount),
      topMistakeTags:
          sortedTags.take(3).map((MapEntry<String, int> e) => e.key).toList(),
      replayCount: replayCount,
      interruptionCount: interruptionCount,
    );
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
}
