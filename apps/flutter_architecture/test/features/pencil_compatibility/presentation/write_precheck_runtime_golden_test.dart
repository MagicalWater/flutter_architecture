import 'dart:io';

import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_architecture/features/pencil_compatibility/presentation/pages/write_precheck_view.dart';
import 'package:flutter_architecture/features/pencil_compatibility/presentation/write_precheck_copy.dart';
import 'package:flutter_architecture/l10n/generated/app_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../support/load_pencil_compatibility_test_fonts.dart';

void main() {
  setUpAll(loadPencilCompatibilityTestFonts);

  testWidgets(
    'Write pre-check runtime candidate is stable at 360x640',
    (tester) async {
      tester.view.physicalSize = const Size(360, 640);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final l10n = await AppLocalizations.delegate.load(
        const Locale('zh', 'TW'),
      );
      await tester.pumpWidget(
        MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: DefaultThemeDefinition().createDarkTheme(),
          home: WritePrecheckView(copy: WritePrecheckCopy.from(l10n)),
        ),
      );
      await tester.pump(const Duration(milliseconds: 100));

      await expectLater(
        find.byType(WritePrecheckView),
        matchesGoldenFile('../goldens/write_precheck_runtime_windows.png'),
      );
    },
    skip: !Platform.isWindows,
  );
}
