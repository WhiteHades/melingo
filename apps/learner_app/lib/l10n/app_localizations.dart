import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_de.dart';
import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('de'),
    Locale('en')
  ];

  /// No description provided for @appName.
  ///
  /// In en, this message translates to:
  /// **'Melingo'**
  String get appName;

  /// No description provided for @homeTab.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get homeTab;

  /// No description provided for @practiceTab.
  ///
  /// In en, this message translates to:
  /// **'Practice'**
  String get practiceTab;

  /// No description provided for @statsTab.
  ///
  /// In en, this message translates to:
  /// **'Stats'**
  String get statsTab;

  /// No description provided for @libraryTab.
  ///
  /// In en, this message translates to:
  /// **'Library'**
  String get libraryTab;

  /// No description provided for @profileTab.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profileTab;

  /// No description provided for @settingsTab.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTab;

  /// No description provided for @startPractice.
  ///
  /// In en, this message translates to:
  /// **'Start Practice'**
  String get startPractice;

  /// No description provided for @homeTitle.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get homeTitle;

  /// No description provided for @homeDescription.
  ///
  /// In en, this message translates to:
  /// **'Today\'s practice summary, streak, and quick start action will live here.'**
  String get homeDescription;

  /// No description provided for @libraryTitle.
  ///
  /// In en, this message translates to:
  /// **'Library'**
  String get libraryTitle;

  /// No description provided for @libraryDescription.
  ///
  /// In en, this message translates to:
  /// **'Scenario prompts, drills, grammar notes, and vocabulary decks will appear here.'**
  String get libraryDescription;

  /// No description provided for @settingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// No description provided for @settingsPrivacyDescription.
  ///
  /// In en, this message translates to:
  /// **'Privacy first defaults for melingo.'**
  String get settingsPrivacyDescription;

  /// No description provided for @diagnosticsOptIn.
  ///
  /// In en, this message translates to:
  /// **'Diagnostics opt-in'**
  String get diagnosticsOptIn;

  /// No description provided for @diagnosticsDescription.
  ///
  /// In en, this message translates to:
  /// **'Off by default. Enables anonymous crash and performance diagnostics.'**
  String get diagnosticsDescription;

  /// No description provided for @storeRawAudio.
  ///
  /// In en, this message translates to:
  /// **'Store raw audio locally'**
  String get storeRawAudio;

  /// No description provided for @storeRawAudioDescription.
  ///
  /// In en, this message translates to:
  /// **'Keep disabled unless the learner explicitly enables session audio retention.'**
  String get storeRawAudioDescription;

  /// No description provided for @encryptionStatus.
  ///
  /// In en, this message translates to:
  /// **'Encryption status'**
  String get encryptionStatus;

  /// No description provided for @encryptionEnabled.
  ///
  /// In en, this message translates to:
  /// **'enabled for sensitive settings'**
  String get encryptionEnabled;

  /// No description provided for @encryptionDisabled.
  ///
  /// In en, this message translates to:
  /// **'disabled'**
  String get encryptionDisabled;

  /// No description provided for @modelManagerTitle.
  ///
  /// In en, this message translates to:
  /// **'Model manager'**
  String get modelManagerTitle;

  /// No description provided for @modelManagerDescription.
  ///
  /// In en, this message translates to:
  /// **'Bundle setup and model health'**
  String get modelManagerDescription;

  /// No description provided for @onboardingDisplayNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Display name'**
  String get onboardingDisplayNameLabel;

  /// No description provided for @onboardingDisplayNameHint.
  ///
  /// In en, this message translates to:
  /// **'Enter your name'**
  String get onboardingDisplayNameHint;

  /// No description provided for @onboardingNameRequired.
  ///
  /// In en, this message translates to:
  /// **'Name is required'**
  String get onboardingNameRequired;

  /// No description provided for @onboardingNameTooShort.
  ///
  /// In en, this message translates to:
  /// **'Name must be at least 2 characters'**
  String get onboardingNameTooShort;

  /// No description provided for @onboardingTargetLanguage.
  ///
  /// In en, this message translates to:
  /// **'Target language'**
  String get onboardingTargetLanguage;

  /// No description provided for @onboardingLevel.
  ///
  /// In en, this message translates to:
  /// **'Level'**
  String get onboardingLevel;

  /// No description provided for @onboardingWeeklyGoalMinutes.
  ///
  /// In en, this message translates to:
  /// **'Weekly goal minutes'**
  String get onboardingWeeklyGoalMinutes;

  /// No description provided for @onboardingSave.
  ///
  /// In en, this message translates to:
  /// **'Save onboarding'**
  String get onboardingSave;

  /// No description provided for @onboardingSaving.
  ///
  /// In en, this message translates to:
  /// **'Saving...'**
  String get onboardingSaving;

  /// No description provided for @onboardingSaved.
  ///
  /// In en, this message translates to:
  /// **'Onboarding saved locally and queued for sync'**
  String get onboardingSaved;

  /// No description provided for @onboardingNoProfileYet.
  ///
  /// In en, this message translates to:
  /// **'No saved onboarding profile yet'**
  String get onboardingNoProfileYet;

  /// No description provided for @profileTitle.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profileTitle;

  /// No description provided for @profileDescription.
  ///
  /// In en, this message translates to:
  /// **'Profile summary, streaks, goals, and support prompts will be shown here.'**
  String get profileDescription;

  /// No description provided for @nameLabel.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get nameLabel;

  /// No description provided for @languageLabel.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get languageLabel;

  /// No description provided for @levelLabel.
  ///
  /// In en, this message translates to:
  /// **'Level'**
  String get levelLabel;

  /// No description provided for @weeklyGoalLabel.
  ///
  /// In en, this message translates to:
  /// **'Weekly goal'**
  String get weeklyGoalLabel;

  /// No description provided for @contentVersionLabel.
  ///
  /// In en, this message translates to:
  /// **'Content version'**
  String get contentVersionLabel;

  /// No description provided for @taxonomyVersionLabel.
  ///
  /// In en, this message translates to:
  /// **'Taxonomy version'**
  String get taxonomyVersionLabel;

  /// No description provided for @practiceTitle.
  ///
  /// In en, this message translates to:
  /// **'Practice'**
  String get practiceTitle;

  /// No description provided for @practicePhase.
  ///
  /// In en, this message translates to:
  /// **'Phase'**
  String get practicePhase;

  /// No description provided for @practiceOfflineReady.
  ///
  /// In en, this message translates to:
  /// **'Offline ready'**
  String get practiceOfflineReady;

  /// No description provided for @activeLanguagePack.
  ///
  /// In en, this message translates to:
  /// **'Active language pack'**
  String get activeLanguagePack;

  /// No description provided for @startAction.
  ///
  /// In en, this message translates to:
  /// **'Start'**
  String get startAction;

  /// No description provided for @stopAction.
  ///
  /// In en, this message translates to:
  /// **'Stop'**
  String get stopAction;

  /// No description provided for @cancelAction.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancelAction;

  /// No description provided for @stopSpeechAction.
  ///
  /// In en, this message translates to:
  /// **'Stop speech'**
  String get stopSpeechAction;

  /// No description provided for @replayAction.
  ///
  /// In en, this message translates to:
  /// **'Replay'**
  String get replayAction;

  /// No description provided for @transcriptTitle.
  ///
  /// In en, this message translates to:
  /// **'Transcript'**
  String get transcriptTitle;

  /// No description provided for @noTranscriptYet.
  ///
  /// In en, this message translates to:
  /// **'No transcript yet'**
  String get noTranscriptYet;

  /// No description provided for @confidenceLabel.
  ///
  /// In en, this message translates to:
  /// **'Confidence'**
  String get confidenceLabel;

  /// No description provided for @latencyLabel.
  ///
  /// In en, this message translates to:
  /// **'Latency'**
  String get latencyLabel;

  /// No description provided for @correctionTitle.
  ///
  /// In en, this message translates to:
  /// **'Correction'**
  String get correctionTitle;

  /// No description provided for @explanationTitle.
  ///
  /// In en, this message translates to:
  /// **'Explanation'**
  String get explanationTitle;

  /// No description provided for @assistantTitle.
  ///
  /// In en, this message translates to:
  /// **'Assistant'**
  String get assistantTitle;

  /// No description provided for @nextPromptTitle.
  ///
  /// In en, this message translates to:
  /// **'Next prompt'**
  String get nextPromptTitle;

  /// No description provided for @mistakeTagsLabel.
  ///
  /// In en, this message translates to:
  /// **'Mistake tags'**
  String get mistakeTagsLabel;

  /// No description provided for @tutorLatencyLabel.
  ///
  /// In en, this message translates to:
  /// **'Tutor latency'**
  String get tutorLatencyLabel;

  /// No description provided for @ttsLatencyLabel.
  ///
  /// In en, this message translates to:
  /// **'TTS latency'**
  String get ttsLatencyLabel;

  /// No description provided for @statsTitle.
  ///
  /// In en, this message translates to:
  /// **'Stats'**
  String get statsTitle;

  /// No description provided for @sessionsLabel.
  ///
  /// In en, this message translates to:
  /// **'Sessions'**
  String get sessionsLabel;

  /// No description provided for @avgAsrLatencyLabel.
  ///
  /// In en, this message translates to:
  /// **'Avg ASR latency'**
  String get avgAsrLatencyLabel;

  /// No description provided for @avgTutorLatencyLabel.
  ///
  /// In en, this message translates to:
  /// **'Avg tutor latency'**
  String get avgTutorLatencyLabel;

  /// No description provided for @avgTtsLatencyLabel.
  ///
  /// In en, this message translates to:
  /// **'Avg TTS latency'**
  String get avgTtsLatencyLabel;

  /// No description provided for @avgConfidenceLabel.
  ///
  /// In en, this message translates to:
  /// **'Avg confidence'**
  String get avgConfidenceLabel;

  /// No description provided for @replaysLabel.
  ///
  /// In en, this message translates to:
  /// **'Replays'**
  String get replaysLabel;

  /// No description provided for @interruptionsLabel.
  ///
  /// In en, this message translates to:
  /// **'Interruptions'**
  String get interruptionsLabel;

  /// No description provided for @topMistakeTags.
  ///
  /// In en, this message translates to:
  /// **'Top mistake tags'**
  String get topMistakeTags;

  /// No description provided for @noMistakeTagsYet.
  ///
  /// In en, this message translates to:
  /// **'No mistake tags yet'**
  String get noMistakeTagsYet;

  /// No description provided for @trendSummary.
  ///
  /// In en, this message translates to:
  /// **'Trend windows (7/30/90) and per-language topic breakdowns will be added in the next slice.'**
  String get trendSummary;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['ar', 'de', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'de':
      return AppLocalizationsDe();
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
