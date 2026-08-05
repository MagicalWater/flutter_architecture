import 'package:flutter/material.dart';
import 'package:flutter_architecture/features/pencil_compatibility/presentation/pages/write_precheck_view.dart';
import 'package:flutter_architecture/features/pencil_compatibility/presentation/widgets/precheck_actions.dart';
import 'package:flutter_architecture/features/pencil_compatibility/presentation/widgets/precheck_data_row.dart';
import 'package:flutter_architecture/features/pencil_compatibility/presentation/widgets/precheck_progress.dart';
import 'package:flutter_architecture/features/pencil_compatibility/presentation/widgets/precheck_record_tile.dart';
import 'package:flutter_architecture/features/pencil_compatibility/presentation/write_precheck_copy.dart';
import 'package:flutter_architecture/l10n/generated/app_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('renders the accepted hierarchy and reusable component counts', (
    tester,
  ) async {
    final l10n = await AppLocalizations.delegate.load(const Locale('zh', 'TW'));

    await tester.pumpWidget(
      MaterialApp(home: WritePrecheckView(copy: WritePrecheckCopy.from(l10n))),
    );
    await tester.pump();

    expect(find.byType(PrecheckStepItem), findsNWidgets(4));
    expect(find.byType(PrecheckDataRow), findsNWidgets(10));
    expect(find.byType(PrecheckRecordTile), findsNWidgets(2));
    expect(find.byType(PrecheckSecondaryAction), findsNWidgets(2));

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
