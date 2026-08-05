import 'package:flutter/material.dart';
import 'package:flutter_architecture/features/pencil_compatibility/presentation/pages/write_precheck_view.dart';
import 'package:flutter_architecture/features/pencil_compatibility/presentation/write_precheck_copy.dart';
import 'package:flutter_architecture/l10n/generated/app_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  for (final locale in <Locale>[const Locale('en'), const Locale('zh', 'TW')]) {
    testWidgets('exposes accepted section and action semantics for $locale', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final semantics = tester.ensureSemantics();

      final l10n = await AppLocalizations.delegate.load(locale);
      final copy = WritePrecheckCopy.from(l10n);
      await tester.pumpWidget(MaterialApp(home: WritePrecheckView(copy: copy)));
      await tester.pump();

      for (final label in <String>[
        copy.title,
        copy.flowStep,
        copy.heroTitle,
        copy.summaryTitle,
        copy.resultsTitle,
        copy.recordsTitle,
        copy.guidanceTitle,
      ]) {
        expect(find.bySemanticsLabel(label), findsWidgets);
      }
      for (var index = 0; index < copy.steps.length; index++) {
        expect(
          find.bySemanticsLabel('${index + 1}. ${copy.steps[index]}'),
          findsOneWidget,
        );
      }

      await tester.scrollUntilVisible(
        find.byKey(const ValueKey<String>('precheckPrimaryAction')),
        400,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.pump();
      expect(find.bySemanticsLabel(copy.primaryAction), findsOneWidget);

      await tester.scrollUntilVisible(
        find.byKey(const ValueKey<String>('precheckEndFlowAction')),
        300,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.pump();
      expect(find.bySemanticsLabel(copy.endFlowAction), findsOneWidget);
      expect(tester.takeException(), isNull);
      semantics.dispose();
    });
  }
}
