// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'Melingo';

  @override
  String get homeTab => 'Home';

  @override
  String get practiceTab => 'Practice';

  @override
  String get statsTab => 'Stats';

  @override
  String get libraryTab => 'Library';

  @override
  String get profileTab => 'Profile';

  @override
  String get settingsTab => 'Settings';

  @override
  String get startPractice => 'Start Practice';

  @override
  String get homeTitle => 'Home';

  @override
  String get homeDescription =>
      'Today\'s practice summary, streak, and quick start action will live here.';

  @override
  String get libraryTitle => 'Library';

  @override
  String get libraryDescription =>
      'Scenario prompts, drills, grammar notes, and vocabulary decks will appear here.';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get settingsPrivacyDescription =>
      'Privacy first defaults for melingo.';

  @override
  String get diagnosticsOptIn => 'Diagnostics opt-in';

  @override
  String get diagnosticsDescription =>
      'Off by default. Enables anonymous crash and performance diagnostics.';

  @override
  String get storeRawAudio => 'Store raw audio locally';

  @override
  String get storeRawAudioDescription =>
      'Keep disabled unless the learner explicitly enables session audio retention.';

  @override
  String get encryptionStatus => 'Encryption status';

  @override
  String get encryptionEnabled => 'enabled for sensitive settings';

  @override
  String get encryptionDisabled => 'disabled';

  @override
  String get modelManagerTitle => 'Model manager';

  @override
  String get modelManagerDescription => 'Bundle setup and model health';

  @override
  String get onboardingDisplayNameLabel => 'Display name';

  @override
  String get onboardingDisplayNameHint => 'Enter your name';

  @override
  String get onboardingNameRequired => 'Name is required';

  @override
  String get onboardingNameTooShort => 'Name must be at least 2 characters';

  @override
  String get onboardingTargetLanguage => 'Target language';

  @override
  String get onboardingLevel => 'Level';

  @override
  String get onboardingWeeklyGoalMinutes => 'Weekly goal minutes';

  @override
  String get onboardingSave => 'Save onboarding';

  @override
  String get onboardingSaving => 'Saving...';

  @override
  String get onboardingSaved => 'Onboarding saved locally and queued for sync';

  @override
  String get onboardingNoProfileYet => 'No saved onboarding profile yet';

  @override
  String get profileTitle => 'Profile';

  @override
  String get profileDescription =>
      'Profile summary, streaks, goals, and support prompts will be shown here.';

  @override
  String get nameLabel => 'Name';

  @override
  String get languageLabel => 'Language';

  @override
  String get levelLabel => 'Level';

  @override
  String get weeklyGoalLabel => 'Weekly goal';

  @override
  String get contentVersionLabel => 'Content version';

  @override
  String get taxonomyVersionLabel => 'Taxonomy version';

  @override
  String get practiceTitle => 'Practice';

  @override
  String get practicePhase => 'Phase';

  @override
  String get practiceOfflineReady => 'Offline ready';

  @override
  String get activeLanguagePack => 'Active language pack';

  @override
  String get startAction => 'Start';

  @override
  String get stopAction => 'Stop';

  @override
  String get cancelAction => 'Cancel';

  @override
  String get stopSpeechAction => 'Stop speech';

  @override
  String get replayAction => 'Replay';

  @override
  String get transcriptTitle => 'Transcript';

  @override
  String get noTranscriptYet => 'No transcript yet';

  @override
  String get confidenceLabel => 'Confidence';

  @override
  String get latencyLabel => 'Latency';

  @override
  String get correctionTitle => 'Correction';

  @override
  String get explanationTitle => 'Explanation';

  @override
  String get assistantTitle => 'Assistant';

  @override
  String get nextPromptTitle => 'Next prompt';

  @override
  String get mistakeTagsLabel => 'Mistake tags';

  @override
  String get tutorLatencyLabel => 'Tutor latency';

  @override
  String get ttsLatencyLabel => 'TTS latency';

  @override
  String get statsTitle => 'Stats';

  @override
  String get sessionsLabel => 'Sessions';

  @override
  String get avgAsrLatencyLabel => 'Avg ASR latency';

  @override
  String get avgTutorLatencyLabel => 'Avg tutor latency';

  @override
  String get avgTtsLatencyLabel => 'Avg TTS latency';

  @override
  String get avgConfidenceLabel => 'Avg confidence';

  @override
  String get replaysLabel => 'Replays';

  @override
  String get interruptionsLabel => 'Interruptions';

  @override
  String get topMistakeTags => 'Top mistake tags';

  @override
  String get noMistakeTagsYet => 'No mistake tags yet';

  @override
  String get trendSummary =>
      'Trend windows (7/30/90) and per-language topic breakdowns will be added in the next slice.';
}
