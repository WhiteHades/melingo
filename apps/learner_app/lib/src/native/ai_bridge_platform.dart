import 'dart:convert';

abstract class AiBridgePlatform {
  Future<void> initialize();
  Future<void> startRecording();
  Future<List<int>> stopRecording();
  Future<void> cancelRecording();
  Future<String> runAsr({required List<int> pcm16leBytes});
  Future<String> runTutor({required String transcript});
  Future<List<int>> runTts({required String responseText});
  Future<void> stopTts();
}

class UnimplementedAiBridgePlatform implements AiBridgePlatform {
  bool _isRecording = false;

  @override
  Future<void> initialize() async {}

  @override
  Future<void> startRecording() async {
    _isRecording = true;
  }

  @override
  Future<List<int>> stopRecording() async {
    if (!_isRecording) {
      return <int>[];
    }
    _isRecording = false;
    return 'pcm16le:simulated'.codeUnits;
  }

  @override
  Future<void> cancelRecording() async {
    _isRecording = false;
  }

  @override
  Future<String> runAsr({required List<int> pcm16leBytes}) async {
    if (pcm16leBytes.isEmpty) {
      return '';
    }
    return 'simulated transcript';
  }

  @override
  Future<String> runTutor({required String transcript}) async {
    return jsonEncode(<String, dynamic>{
      'correctedText': transcript,
      'explanation':
          'Nice attempt. Keep subject and verb agreement aligned in the sentence.',
      'encouragement': 'Good effort.',
      'nextPrompt': 'Can you say the same idea in past tense?',
      'mistakeTags': <String>['grammar:agreement'],
      'responseText': 'Good effort. Can you say the same idea in past tense?',
    });
  }

  @override
  Future<List<int>> runTts({required String responseText}) async {
    if (responseText.isEmpty) {
      return <int>[];
    }
    return responseText.codeUnits;
  }

  @override
  Future<void> stopTts() async {}
}
