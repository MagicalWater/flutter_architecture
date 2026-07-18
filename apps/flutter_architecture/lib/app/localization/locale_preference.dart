import 'package:flutter/widgets.dart';
import 'package:flutter_architecture/app/localization/app_locale_resolution.dart';

enum AppLocalePreference { system, english, traditionalChinese }

extension AppLocalePreferenceX on AppLocalePreference {
  String get storageValue => switch (this) {
    AppLocalePreference.system => 'system',
    AppLocalePreference.english => 'en',
    AppLocalePreference.traditionalChinese => 'zh_TW',
  };

  Locale? get materialLocale => switch (this) {
    AppLocalePreference.system => null,
    AppLocalePreference.english => appEnglishLocale,
    AppLocalePreference.traditionalChinese => appTraditionalChineseLocale,
  };
}
