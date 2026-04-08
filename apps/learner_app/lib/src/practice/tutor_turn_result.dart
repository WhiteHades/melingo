import 'dart:convert';

class TutorTurnResult {
  const TutorTurnResult({
    required this.correctedText,
    required this.explanation,
    required this.encouragement,
    required this.nextPrompt,
    required this.mistakeTags,
    required this.assistantResponseText,
  });

  final String correctedText;
  final String explanation;
  final String encouragement;
  final String nextPrompt;
  final List<String> mistakeTags;
  final String assistantResponseText;

  static TutorTurnResult fromRaw({
    required String transcript,
    required String raw,
  }) {
    if (raw.isEmpty) {
      return fallback(transcript: transcript);
    }

    try {
      final dynamic decoded = jsonDecode(raw);
      if (decoded is! Map<String, dynamic>) {
        return fallback(
          transcript: transcript,
          assistantResponseText: raw,
        );
      }

      final String encouragement =
          _stringValue(decoded['encouragement']) ?? 'Good effort.';
      final String nextPrompt = _stringValue(decoded['nextPrompt']) ??
          'Try another sentence with the same idea.';

      return TutorTurnResult(
        correctedText: _stringValue(decoded['correctedText']) ?? transcript,
        explanation: _stringValue(decoded['explanation']) ??
            'I adjusted your sentence to be more natural and clear.',
        encouragement: encouragement,
        nextPrompt: nextPrompt,
        mistakeTags: _stringList(decoded['mistakeTags']),
        assistantResponseText: _stringValue(decoded['responseText']) ??
            '$encouragement $nextPrompt',
      );
    } catch (_) {
      return fallback(
        transcript: transcript,
        assistantResponseText: raw,
      );
    }
  }

  static TutorTurnResult fallback({
    required String transcript,
    String? assistantResponseText,
  }) {
    final String encouragement = 'Good effort.';
    final String nextPrompt = 'Try another sentence with the same idea.';
    return TutorTurnResult(
      correctedText: transcript,
      explanation: 'I adjusted your sentence to be more natural and clear.',
      encouragement: encouragement,
      nextPrompt: nextPrompt,
      mistakeTags: const <String>['grammar:general'],
      assistantResponseText:
          assistantResponseText ?? '$encouragement $nextPrompt',
    );
  }

  static String? _stringValue(dynamic value) {
    if (value is String && value.isNotEmpty) {
      return value;
    }
    return null;
  }

  static List<String> _stringList(dynamic value) {
    if (value is List<dynamic>) {
      return value
          .whereType<String>()
          .where((String entry) => entry.isNotEmpty)
          .toList(growable: false);
    }
    return const <String>['grammar:general'];
  }
}
