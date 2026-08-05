import 'package:flutter/material.dart';
import 'package:flutter_architecture/features/pencil_compatibility/presentation/pages/write_precheck_view.dart';
import 'package:flutter_architecture/features/pencil_compatibility/presentation/write_precheck_copy.dart';
import 'package:flutter_architecture/l10n/generated/app_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  for (final size in <Size>[
    const Size(941, 1672),
    const Size(390, 844),
    const Size(226, 400),
  ]) {
    testWidgets('remains scrollable without fixed-canvas scaling at $size', (
      tester,
    ) async {
      tester.view.physicalSize = size;
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final l10n = await AppLocalizations.delegate.load(
        const Locale('zh', 'TW'),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: WritePrecheckView(copy: WritePrecheckCopy.from(l10n)),
        ),
      );
      await tester.pump();

      expect(
        find.byKey(const ValueKey<String>('writePrecheckScrollView')),
        findsOneWidget,
      );
      expect(find.byType(Scrollable), findsWidgets);
      expect(find.byType(FittedBox), findsNothing);
      expect(tester.takeException(), isNull);

      if (size == const Size(941, 1672)) {
        final endFlowRect = tester.getRect(
          find.byKey(const ValueKey<String>('precheckEndFlowAction')),
        );
        expect(
          endFlowRect.bottom,
          lessThanOrEqualTo(size.height),
          reason: 'The accepted canonical screen shows the complete flow.',
        );
      }

      if (size.width < 400) {
        await tester.scrollUntilVisible(
          find.byKey(const ValueKey<String>('precheckEndFlowAction')),
          300,
          scrollable: find.byType(Scrollable).first,
        );
        await tester.pump();

        expect(
          find.byKey(const ValueKey<String>('precheckEndFlowAction')),
          findsOneWidget,
        );
        expect(tester.takeException(), isNull);
      }
    });
  }
}
