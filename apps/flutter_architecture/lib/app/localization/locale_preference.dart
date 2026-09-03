import 'package:flutter/widgets.dart';
import 'package:flutter_architecture/app/localization/app_locale_resolution.dart';

/// 使用者希望 App 採用哪一種語系設定。
///
/// [system] 代表跟著作業系統；另外兩個值則固定 App 語系。
enum AppLocalePreference {
  /// 跟隨系統語言。
  system,

  /// 固定使用英文。
  english,

  /// 固定使用繁體中文（台灣）。
  traditionalChinese,
}

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
