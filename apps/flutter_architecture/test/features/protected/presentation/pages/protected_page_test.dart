import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_architecture/features/protected/presentation/pages/protected_page.dart';
import 'package:flutter_architecture/l10n/generated/app_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('ProtectedPage 顯示通過 Route Guard 的內容', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: OceanThemeDefinition().createDarkTheme(),
        locale: const Locale('zh', 'TW'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: const ProtectedPage(),
      ),
    );

    expect(find.text('受保護頁面'), findsOneWidget);
    expect(find.text('你已通過 Route Guard'), findsOneWidget);
    expect(find.byIcon(Icons.verified_user_outlined), findsOneWidget);
    expect(find.byType(DsMessageState), findsOneWidget);
  });
}
