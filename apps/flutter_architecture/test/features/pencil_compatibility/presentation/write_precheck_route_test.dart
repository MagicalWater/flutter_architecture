import 'package:flutter/material.dart';
import 'package:flutter_architecture/features/pencil_compatibility/presentation/pages/write_precheck_page.dart';
import 'package:flutter_architecture/features/pencil_compatibility/presentation/pages/write_precheck_view.dart';
import 'package:flutter_architecture/l10n/generated/app_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('WritePrecheckPage 建立帶有 localized copy 的 WritePrecheckView', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        locale: Locale('zh', 'TW'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: WritePrecheckPage(),
      ),
    );

    final view = tester.widget<WritePrecheckView>(
      find.byType(WritePrecheckView),
    );
    expect(view.copy.title, '寫前檢查');
    expect(view.copy.steps, hasLength(4));
  });
}
