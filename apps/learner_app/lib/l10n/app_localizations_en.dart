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
  String get settingsTitle => 'Settings';

  @override
  String get diagnosticsOptIn => 'Diagnostics opt-in';

  @override
  String get storeRawAudio => 'Store raw audio locally';

  @override
  String get encryptionStatus => 'Encryption status';

  @override
  String get encryptionEnabled => 'enabled for sensitive settings';

  @override
  String get encryptionDisabled => 'disabled';
}
