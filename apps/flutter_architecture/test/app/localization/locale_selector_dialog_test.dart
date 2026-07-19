import 'package:flutter/material.dart';
import 'package:flutter_architecture/app/error_reporting/error_reporter.dart';
import 'package:flutter_architecture/app/localization/locale_controller.dart';
import 'package:flutter_architecture/app/localization/locale_preference.dart';
import 'package:flutter_architecture/app/localization/locale_preference_store.dart';
import 'package:flutter_architecture/app/localization/presentation/locale_selector_dialog.dart';
import 'package:flutter_architecture/l10n/generated/app_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('selector updates locale and rebuilds localized labels', (
    tester,
  ) async {
    final controller = LocaleController(
      store: LocalePreferenceStore(
        _MemoryStorage(),
        const LocalePreferenceCodec(),
      ),
      initialPreference: AppLocalePreference.system,
      errorReporter: const NoopErrorReporter(),
    );

    await tester.pumpWidget(
      ListenableBuilder(
        listenable: controller,
        builder: (context, _) {
          return MaterialApp(
            locale: controller.locale,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: Builder(
              builder: (context) =>
                  LocaleSelectorDialog(controller: controller),
            ),
          );
        },
      ),
    );

    expect(find.text('Language'), findsOneWidget);
    await tester.tap(find.text('Traditional Chinese'));
    await tester.pumpAndSettle();

    expect(controller.preference, AppLocalePreference.traditionalChinese);
    expect(find.text('語言'), findsOneWidget);
    expect(find.text('繁體中文'), findsOneWidget);
  });
}

final class _MemoryStorage implements LocalePreferenceStorage {
  String? value;

  @override
  Future<String?> read() async => value;

  @override
  Future<void> write(String value) async {
    this.value = value;
  }
}
