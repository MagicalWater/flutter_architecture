import 'package:flutter/material.dart';
import 'package:flutter_architecture/features/pencil_compatibility/presentation/pages/write_precheck_projected_canvas.dart';
import 'package:flutter_architecture/features/pencil_compatibility/presentation/pages/write_precheck_view.dart';
import 'package:flutter_architecture/features/pencil_compatibility/presentation/write_precheck_copy.dart';
import 'package:flutter_architecture/l10n/generated/app_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('renders the accepted hierarchy through one projected tree', (
    tester,
  ) async {
    final l10n = await AppLocalizations.delegate.load(const Locale('zh', 'TW'));

    await tester.pumpWidget(
      MaterialApp(home: WritePrecheckView(copy: WritePrecheckCopy.from(l10n))),
    );
    await tester.pump();

    expect(find.byType(WritePrecheckProjectedCanvas), findsOneWidget);

    for (final key in <String>[
      'precheckHeader',
      'precheckProgress',
      'precheckHero',
      'precheckSummary',
      'precheckResults',
      'precheckRecords',
      'precheckGuidance',
      'precheckPrimaryAction',
      'precheckEndFlowAction',
    ]) {
      expect(find.byKey(ValueKey<String>(key)), findsOneWidget);
    }

    expect(
      find.bySemanticsLabel(l10n.pencilPrecheckPrimaryAction),
      findsOneWidget,
    );
    expect(
      find.bySemanticsLabel(l10n.pencilPrecheckEndFlowAction),
      findsOneWidget,
    );
    expect(tester.takeException(), isNull);
  });
}
