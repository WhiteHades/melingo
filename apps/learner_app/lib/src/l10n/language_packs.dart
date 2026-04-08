import 'package:flutter/widgets.dart';

class LanguagePack {
  const LanguagePack({
    required this.languageCode,
    required this.locale,
    required this.displayName,
    required this.direction,
    required this.contentVersion,
    required this.taxonomyVersion,
    required this.defaultNextPrompt,
    required this.allowedMistakeTags,
  });

  final String languageCode;
  final Locale locale;
  final String displayName;
  final TextDirection direction;
  final String contentVersion;
  final String taxonomyVersion;
  final String defaultNextPrompt;
  final Set<String> allowedMistakeTags;
}

const LanguagePack germanLanguagePack = LanguagePack(
  languageCode: 'de',
  locale: Locale('de'),
  displayName: 'Deutsch',
  direction: TextDirection.ltr,
  contentVersion: 'de.v1',
  taxonomyVersion: 'de.v1',
  defaultNextPrompt: 'Kannst du denselben Gedanken im Praeteritum sagen?',
  allowedMistakeTags: <String>{
    'grammar:agreement',
    'grammar:word-order',
    'grammar:verb-order',
    'vocabulary:false-friend',
    'pronunciation:umlaut',
    'grammar:general',
  },
);

const LanguagePack arabicLanguagePack = LanguagePack(
  languageCode: 'ar',
  locale: Locale('ar'),
  displayName: 'العربية',
  direction: TextDirection.rtl,
  contentVersion: 'ar.v1',
  taxonomyVersion: 'ar.v1',
  defaultNextPrompt: 'هل يمكنك قول نفس الفكرة بصيغة الماضي؟',
  allowedMistakeTags: <String>{
    'grammar:case-ending',
    'grammar:verb-pattern',
    'script:hamza',
    'pronunciation:emphatic',
    'grammar:general',
  },
);

const List<LanguagePack> supportedLanguagePacks = <LanguagePack>[
  germanLanguagePack,
  arabicLanguagePack,
];

LanguagePack resolveLanguagePack(String? languageCode) {
  if (languageCode == null) {
    return germanLanguagePack;
  }

  for (final LanguagePack pack in supportedLanguagePacks) {
    if (pack.languageCode == languageCode) {
      return pack;
    }
  }

  return germanLanguagePack;
}

List<String> normalizeMistakeTags({
  required LanguagePack languagePack,
  required List<String> rawTags,
}) {
  if (rawTags.isEmpty) {
    return const <String>['grammar:general'];
  }

  final List<String> normalized = <String>[];

  for (final String raw in rawTags) {
    final String candidate = raw.trim().toLowerCase();
    if (candidate.isEmpty) {
      continue;
    }

    if (languagePack.allowedMistakeTags.contains(candidate)) {
      if (!normalized.contains(candidate)) {
        normalized.add(candidate);
      }
      continue;
    }

    if (!normalized.contains('grammar:general')) {
      normalized.add('grammar:general');
    }
  }

  if (normalized.isEmpty) {
    return const <String>['grammar:general'];
  }

  return List<String>.unmodifiable(normalized);
}
