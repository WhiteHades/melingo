// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for German (`de`).
class AppLocalizationsDe extends AppLocalizations {
  AppLocalizationsDe([String locale = 'de']) : super(locale);

  @override
  String get appName => 'Melingo';

  @override
  String get settingsTitle => 'Einstellungen';

  @override
  String get diagnosticsOptIn => 'Diagnose aktivieren';

  @override
  String get storeRawAudio => 'Rohaudio lokal speichern';

  @override
  String get encryptionStatus => 'Verschluesselungsstatus';

  @override
  String get encryptionEnabled => 'fuer sensible Einstellungen aktiviert';

  @override
  String get encryptionDisabled => 'deaktiviert';
}
