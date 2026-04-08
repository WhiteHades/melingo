import 'package:flutter_test/flutter_test.dart';
import 'package:learner_app/src/l10n/language_packs.dart';
import 'package:learner_app/src/practice/tutor_turn_result.dart';

void main() {
  test('parses structured tutor json payload', () {
    const String raw =
        '{"correctedText":"Ich gehe nach Hause.","explanation":"Verb position is corrected.","encouragement":"Great job.","nextPrompt":"Now say it in present perfect.","mistakeTags":["grammar:verb-order"],"responseText":"Great job. Now say it in present perfect."}';

    final TutorTurnResult result =
        TutorTurnResult.fromRaw(transcript: 'Ich gehe nach hause', raw: raw);

    expect(result.correctedText, 'Ich gehe nach Hause.');
    expect(result.explanation, 'Verb position is corrected.');
    expect(result.encouragement, 'Great job.');
    expect(result.nextPrompt, 'Now say it in present perfect.');
    expect(result.mistakeTags, <String>['grammar:verb-order']);
    expect(
      result.assistantResponseText,
      'Great job. Now say it in present perfect.',
    );
  });

  test('falls back when tutor payload is plain text', () {
    final TutorTurnResult result = TutorTurnResult.fromRaw(
      transcript: 'ana uhib al qiraa',
      raw: 'Try again with clearer pronunciation.',
    );

    expect(result.correctedText, 'ana uhib al qiraa');
    expect(result.mistakeTags, <String>['grammar:general']);
    expect(
        result.assistantResponseText, 'Try again with clearer pronunciation.');
  });

  test('normalizes tags against selected language taxonomy', () {
    const String raw =
        '{"correctedText":"ana adhhab","explanation":"Adjusted case ending.","encouragement":"Good effort.","nextPrompt":"Try again.","mistakeTags":["grammar:agreement","script:hamza"],"responseText":"Try again."}';

    final TutorTurnResult result = TutorTurnResult.fromRaw(
      transcript: 'ana adhhab',
      raw: raw,
      languagePack: arabicLanguagePack,
    );

    expect(
        result.mistakeTags, const <String>['grammar:general', 'script:hamza']);
  });
}
