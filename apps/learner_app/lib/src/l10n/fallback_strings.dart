import 'package:flutter/widgets.dart';

import '../../l10n/app_localizations.dart';

class FallbackStrings {
  const FallbackStrings._();

  static String appName(BuildContext context) =>
      AppLocalizations.of(context)?.appName ?? 'Melingo';

  static String homeTab(BuildContext context) =>
      AppLocalizations.of(context)?.homeTab ?? 'Home';

  static String practiceTab(BuildContext context) =>
      AppLocalizations.of(context)?.practiceTab ?? 'Practice';

  static String statsTab(BuildContext context) =>
      AppLocalizations.of(context)?.statsTab ?? 'Stats';

  static String libraryTab(BuildContext context) =>
      AppLocalizations.of(context)?.libraryTab ?? 'Library';

  static String profileTab(BuildContext context) =>
      AppLocalizations.of(context)?.profileTab ?? 'Profile';

  static String settingsTab(BuildContext context) =>
      AppLocalizations.of(context)?.settingsTab ?? 'Settings';

  static String startPractice(BuildContext context) =>
      AppLocalizations.of(context)?.startPractice ?? 'Start Practice';

  static String homeTitle(BuildContext context) =>
      AppLocalizations.of(context)?.homeTitle ?? 'Home';

  static String homeDescription(BuildContext context) =>
      AppLocalizations.of(context)?.homeDescription ??
      'Today\'s practice summary, streak, and quick start action will live here.';

  static String libraryTitle(BuildContext context) =>
      AppLocalizations.of(context)?.libraryTitle ?? 'Library';

  static String libraryDescription(BuildContext context) =>
      AppLocalizations.of(context)?.libraryDescription ??
      'Scenario prompts, drills, grammar notes, and vocabulary decks will appear here.';

  static String settingsTitle(BuildContext context) =>
      AppLocalizations.of(context)?.settingsTitle ?? 'Settings';

  static String settingsPrivacyDescription(BuildContext context) =>
      AppLocalizations.of(context)?.settingsPrivacyDescription ??
      'Privacy first defaults for melingo.';

  static String diagnosticsOptIn(BuildContext context) =>
      AppLocalizations.of(context)?.diagnosticsOptIn ?? 'Diagnostics opt-in';

  static String diagnosticsDescription(BuildContext context) =>
      AppLocalizations.of(context)?.diagnosticsDescription ??
      'Off by default. Enables anonymous crash and performance diagnostics.';

  static String storeRawAudio(BuildContext context) =>
      AppLocalizations.of(context)?.storeRawAudio ?? 'Store raw audio locally';

  static String storeRawAudioDescription(BuildContext context) =>
      AppLocalizations.of(context)?.storeRawAudioDescription ??
      'Keep disabled unless the learner explicitly enables session audio retention.';

  static String encryptionStatus(BuildContext context) =>
      AppLocalizations.of(context)?.encryptionStatus ?? 'Encryption status';

  static String encryptionEnabled(BuildContext context) =>
      AppLocalizations.of(context)?.encryptionEnabled ??
      'enabled for sensitive settings';

  static String encryptionDisabled(BuildContext context) =>
      AppLocalizations.of(context)?.encryptionDisabled ?? 'disabled';

  static String modelManagerTitle(BuildContext context) =>
      AppLocalizations.of(context)?.modelManagerTitle ?? 'Model manager';

  static String modelManagerDescription(BuildContext context) =>
      AppLocalizations.of(context)?.modelManagerDescription ??
      'Bundle setup and model health';

  static String onboardingDisplayNameLabel(BuildContext context) =>
      AppLocalizations.of(context)?.onboardingDisplayNameLabel ??
      'Display name';

  static String onboardingDisplayNameHint(BuildContext context) =>
      AppLocalizations.of(context)?.onboardingDisplayNameHint ??
      'Enter your name';

  static String onboardingNameRequired(BuildContext context) =>
      AppLocalizations.of(context)?.onboardingNameRequired ??
      'Name is required';

  static String onboardingNameTooShort(BuildContext context) =>
      AppLocalizations.of(context)?.onboardingNameTooShort ??
      'Name must be at least 2 characters';

  static String onboardingTargetLanguage(BuildContext context) =>
      AppLocalizations.of(context)?.onboardingTargetLanguage ??
      'Target language';

  static String onboardingLevel(BuildContext context) =>
      AppLocalizations.of(context)?.onboardingLevel ?? 'Level';

  static String onboardingWeeklyGoalMinutes(BuildContext context) =>
      AppLocalizations.of(context)?.onboardingWeeklyGoalMinutes ??
      'Weekly goal minutes';

  static String onboardingSave(BuildContext context) =>
      AppLocalizations.of(context)?.onboardingSave ?? 'Save onboarding';

  static String onboardingSaving(BuildContext context) =>
      AppLocalizations.of(context)?.onboardingSaving ?? 'Saving...';

  static String onboardingSaved(BuildContext context) =>
      AppLocalizations.of(context)?.onboardingSaved ??
      'Onboarding saved locally and queued for sync';

  static String onboardingNoProfileYet(BuildContext context) =>
      AppLocalizations.of(context)?.onboardingNoProfileYet ??
      'No saved onboarding profile yet';

  static String profileTitle(BuildContext context) =>
      AppLocalizations.of(context)?.profileTitle ?? 'Profile';

  static String profileDescription(BuildContext context) =>
      AppLocalizations.of(context)?.profileDescription ??
      'Profile summary, streaks, goals, and support prompts will be shown here.';

  static String nameLabel(BuildContext context) =>
      AppLocalizations.of(context)?.nameLabel ?? 'Name';

  static String languageLabel(BuildContext context) =>
      AppLocalizations.of(context)?.languageLabel ?? 'Language';

  static String levelLabel(BuildContext context) =>
      AppLocalizations.of(context)?.levelLabel ?? 'Level';

  static String weeklyGoalLabel(BuildContext context) =>
      AppLocalizations.of(context)?.weeklyGoalLabel ?? 'Weekly goal';

  static String contentVersionLabel(BuildContext context) =>
      AppLocalizations.of(context)?.contentVersionLabel ?? 'Content version';

  static String taxonomyVersionLabel(BuildContext context) =>
      AppLocalizations.of(context)?.taxonomyVersionLabel ?? 'Taxonomy version';

  static String practiceTitle(BuildContext context) =>
      AppLocalizations.of(context)?.practiceTitle ?? 'Practice';

  static String practicePhase(BuildContext context) =>
      AppLocalizations.of(context)?.practicePhase ?? 'Phase';

  static String practiceOfflineReady(BuildContext context) =>
      AppLocalizations.of(context)?.practiceOfflineReady ?? 'Offline ready';

  static String activeLanguagePack(BuildContext context) =>
      AppLocalizations.of(context)?.activeLanguagePack ??
      'Active language pack';

  static String startAction(BuildContext context) =>
      AppLocalizations.of(context)?.startAction ?? 'Start';

  static String stopAction(BuildContext context) =>
      AppLocalizations.of(context)?.stopAction ?? 'Stop';

  static String cancelAction(BuildContext context) =>
      AppLocalizations.of(context)?.cancelAction ?? 'Cancel';

  static String stopSpeechAction(BuildContext context) =>
      AppLocalizations.of(context)?.stopSpeechAction ?? 'Stop speech';

  static String replayAction(BuildContext context) =>
      AppLocalizations.of(context)?.replayAction ?? 'Replay';

  static String transcriptTitle(BuildContext context) =>
      AppLocalizations.of(context)?.transcriptTitle ?? 'Transcript';

  static String noTranscriptYet(BuildContext context) =>
      AppLocalizations.of(context)?.noTranscriptYet ?? 'No transcript yet';

  static String confidenceLabel(BuildContext context) =>
      AppLocalizations.of(context)?.confidenceLabel ?? 'Confidence';

  static String latencyLabel(BuildContext context) =>
      AppLocalizations.of(context)?.latencyLabel ?? 'Latency';

  static String correctionTitle(BuildContext context) =>
      AppLocalizations.of(context)?.correctionTitle ?? 'Correction';

  static String explanationTitle(BuildContext context) =>
      AppLocalizations.of(context)?.explanationTitle ?? 'Explanation';

  static String assistantTitle(BuildContext context) =>
      AppLocalizations.of(context)?.assistantTitle ?? 'Assistant';

  static String nextPromptTitle(BuildContext context) =>
      AppLocalizations.of(context)?.nextPromptTitle ?? 'Next prompt';

  static String mistakeTagsLabel(BuildContext context) =>
      AppLocalizations.of(context)?.mistakeTagsLabel ?? 'Mistake tags';

  static String tutorLatencyLabel(BuildContext context) =>
      AppLocalizations.of(context)?.tutorLatencyLabel ?? 'Tutor latency';

  static String ttsLatencyLabel(BuildContext context) =>
      AppLocalizations.of(context)?.ttsLatencyLabel ?? 'TTS latency';

  static String statsTitle(BuildContext context) =>
      AppLocalizations.of(context)?.statsTitle ?? 'Stats';

  static String sessionsLabel(BuildContext context) =>
      AppLocalizations.of(context)?.sessionsLabel ?? 'Sessions';

  static String avgAsrLatencyLabel(BuildContext context) =>
      AppLocalizations.of(context)?.avgAsrLatencyLabel ?? 'Avg ASR latency';

  static String avgTutorLatencyLabel(BuildContext context) =>
      AppLocalizations.of(context)?.avgTutorLatencyLabel ?? 'Avg tutor latency';

  static String avgTtsLatencyLabel(BuildContext context) =>
      AppLocalizations.of(context)?.avgTtsLatencyLabel ?? 'Avg TTS latency';

  static String avgConfidenceLabel(BuildContext context) =>
      AppLocalizations.of(context)?.avgConfidenceLabel ?? 'Avg confidence';

  static String replaysLabel(BuildContext context) =>
      AppLocalizations.of(context)?.replaysLabel ?? 'Replays';

  static String interruptionsLabel(BuildContext context) =>
      AppLocalizations.of(context)?.interruptionsLabel ?? 'Interruptions';

  static String topMistakeTags(BuildContext context) =>
      AppLocalizations.of(context)?.topMistakeTags ?? 'Top mistake tags';

  static String noMistakeTagsYet(BuildContext context) =>
      AppLocalizations.of(context)?.noMistakeTagsYet ?? 'No mistake tags yet';

  static String trendSummary(BuildContext context) =>
      AppLocalizations.of(context)?.trendSummary ??
      'Trend windows (7/30/90) and per-language topic breakdowns will be added in the next slice.';
}
