import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:learner_app/src/l10n/language_packs.dart';

void main() {
  test('resolveLanguagePack returns arabic pack for ar', () {
    final LanguagePack pack = resolveLanguagePack('ar');

    expect(pack.languageCode, 'ar');
    expect(pack.direction, TextDirection.rtl);
    expect(pack.contentVersion, 'ar.v1');
    expect(pack.taxonomyVersion, 'ar.v1');
  });

  test('resolveLanguagePack falls back to german for unknown code', () {
    final LanguagePack pack = resolveLanguagePack('fr');

    expect(pack.languageCode, 'de');
    expect(pack.direction, TextDirection.ltr);
  });

  test('normalizeMistakeTags keeps only tags supported by selected language',
      () {
    final List<String> tags = normalizeMistakeTags(
      languagePack: arabicLanguagePack,
      rawTags: const <String>[
        'grammar:verb-pattern',
        'grammar:agreement',
        'script:hamza',
      ],
    );

    expect(tags, const <String>[
      'grammar:verb-pattern',
      'grammar:general',
      'script:hamza'
    ]);
  });

  test('normalizeMistakeTags defaults to grammar:general when empty', () {
    final List<String> tags = normalizeMistakeTags(
      languagePack: germanLanguagePack,
      rawTags: const <String>[],
    );

    expect(tags, const <String>['grammar:general']);
  });
}
