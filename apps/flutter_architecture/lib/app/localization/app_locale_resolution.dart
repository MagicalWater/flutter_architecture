import 'package:flutter/widgets.dart';

const Locale appEnglishLocale = Locale('en');
const Locale appTraditionalChineseLocale = Locale('zh', 'TW');

const List<Locale> appSupportedLocales = <Locale>[
  appEnglishLocale,
  appTraditionalChineseLocale,
];

/// 將平台提供的 locale 優先順序解析為 App 支援的 locale。
///
/// 第一版只支援英文與繁體中文。`zh_Hant`、台灣、香港與澳門中文會
/// 映射至 `zh_TW`；簡體中文與其他未支援 locale 則回退至英文。
Locale resolveAppLocale(
  List<Locale>? platformLocales,
  Iterable<Locale> supportedLocales,
) {
  final supported = supportedLocales.toList(growable: false);
  if (supported.isEmpty) {
    throw ArgumentError.value(
      supportedLocales,
      'supportedLocales',
      'must not be empty',
    );
  }

  final supportsEnglish = supported.contains(appEnglishLocale);
  final supportsTraditionalChinese = supported.contains(
    appTraditionalChineseLocale,
  );

  for (final locale in platformLocales ?? const <Locale>[]) {
    if (supportsTraditionalChinese && _isTraditionalChinese(locale)) {
      return appTraditionalChineseLocale;
    }

    if (supportsEnglish && locale.languageCode.toLowerCase() == 'en') {
      return appEnglishLocale;
    }
  }

  return supportsEnglish ? appEnglishLocale : supported.first;
}

bool _isTraditionalChinese(Locale locale) {
  if (locale.languageCode.toLowerCase() != 'zh') {
    return false;
  }

  final scriptCode = locale.scriptCode?.toLowerCase();
  if (scriptCode == 'hant') {
    return true;
  }
  if (scriptCode == 'hans') {
    return false;
  }

  return switch (locale.countryCode?.toUpperCase()) {
    'TW' || 'HK' || 'MO' => true,
    _ => false,
  };
}
