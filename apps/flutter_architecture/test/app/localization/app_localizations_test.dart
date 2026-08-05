import 'dart:convert';
import 'dart:io';

import 'package:flutter/widgets.dart';
import 'package:flutter_architecture/app/localization/app_locale_resolution.dart';
import 'package:flutter_architecture/l10n/generated/app_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AppLocalizations', () {
    test('loads English and zh_TW resources', () async {
      final english = await AppLocalizations.delegate.load(appEnglishLocale);
      final traditionalChinese = await AppLocalizations.delegate.load(
        appTraditionalChineseLocale,
      );

      expect(english.appTitle, 'Flutter Architecture');
      expect(traditionalChinese.appTitle, 'Flutter 架構模板');
      expect(AppLocalizations.supportedLocales, contains(appEnglishLocale));
      expect(
        AppLocalizations.supportedLocales,
        contains(appTraditionalChineseLocale),
      );
      expect(appSupportedLocales, <Locale>[
        appEnglishLocale,
        appTraditionalChineseLocale,
      ]);
    });

    test('every ARB contains the complete pencilPrecheck key set', () {
      final files = <File>[
        File('lib/l10n/app_en.arb'),
        File('lib/l10n/app_zh.arb'),
        File('lib/l10n/app_zh_TW.arb'),
      ];
      final keySets = <Set<String>>[
        for (final file in files)
          (jsonDecode(file.readAsStringSync()) as Map<String, Object?>).keys
              .where((key) => key.startsWith('pencilPrecheck'))
              .toSet(),
      ];

      expect(keySets.first, isNotEmpty);
      for (var index = 1; index < keySets.length; index++) {
        expect(
          keySets[index],
          unorderedEquals(keySets.first),
          reason: '${files[index].path} has incomplete pencilPrecheck keys',
        );
      }
    });
  });

  group('resolveAppLocale', () {
    test('maps Taiwan, Hant, Hong Kong and Macau to zh_TW', () {
      for (final locale in <Locale>[
        const Locale('zh', 'TW'),
        const Locale.fromSubtags(languageCode: 'zh', scriptCode: 'Hant'),
        const Locale('zh', 'HK'),
        const Locale('zh', 'MO'),
      ]) {
        expect(
          resolveAppLocale(<Locale>[locale], appSupportedLocales),
          appTraditionalChineseLocale,
        );
      }
    });

    test('does not map simplified Chinese to zh_TW', () {
      for (final locale in <Locale>[
        const Locale('zh', 'CN'),
        const Locale('zh', 'SG'),
        const Locale.fromSubtags(languageCode: 'zh', scriptCode: 'Hans'),
      ]) {
        expect(
          resolveAppLocale(<Locale>[locale], appSupportedLocales),
          appEnglishLocale,
        );
      }
    });

    test(
      'uses the first supported locale found in platform priority order',
      () {
        expect(
          resolveAppLocale(const <Locale>[
            Locale('ja'),
            Locale('zh', 'TW'),
          ], appSupportedLocales),
          appTraditionalChineseLocale,
        );
        expect(
          resolveAppLocale(const <Locale>[
            Locale('ja'),
            Locale('en', 'US'),
          ], appSupportedLocales),
          appEnglishLocale,
        );
      },
    );

    test('falls back to English for null or unsupported locales', () {
      expect(resolveAppLocale(null, appSupportedLocales), appEnglishLocale);
      expect(
        resolveAppLocale(const <Locale>[Locale('ja')], appSupportedLocales),
        appEnglishLocale,
      );
    });

    test('never returns a locale missing from supportedLocales', () {
      expect(
        resolveAppLocale(
          const <Locale>[Locale('zh', 'TW')],
          const <Locale>[appEnglishLocale],
        ),
        appEnglishLocale,
      );
      expect(
        resolveAppLocale(
          const <Locale>[Locale('en', 'US')],
          const <Locale>[appTraditionalChineseLocale],
        ),
        appTraditionalChineseLocale,
      );
    });

    test('rejects an empty supportedLocales contract', () {
      expect(
        () => resolveAppLocale(const <Locale>[Locale('en')], const <Locale>[]),
        throwsArgumentError,
      );
    });
  });
}
