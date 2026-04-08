// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get appName => 'Melingo';

  @override
  String get settingsTitle => 'الاعدادات';

  @override
  String get diagnosticsOptIn => 'تفعيل التشخيص';

  @override
  String get storeRawAudio => 'حفظ الصوت الخام محليا';

  @override
  String get encryptionStatus => 'حالة التشفير';

  @override
  String get encryptionEnabled => 'مفعل للبيانات الحساسة';

  @override
  String get encryptionDisabled => 'غير مفعل';
}
