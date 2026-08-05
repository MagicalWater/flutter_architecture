import 'package:flutter/foundation.dart';
import 'package:flutter_architecture/l10n/generated/app_localizations.dart';

@immutable
final class WritePrecheckRowCopy {
  const WritePrecheckRowCopy({required this.label, required this.value});

  final String label;
  final String value;
}

@immutable
final class WritePrecheckRecordCopy {
  const WritePrecheckRecordCopy({
    required this.title,
    required this.value,
    required this.badge,
  });

  final String title;
  final String value;
  final String badge;
}

@immutable
final class WritePrecheckCopy {
  WritePrecheckCopy._({
    required this.title,
    required this.flowStep,
    required List<String> steps,
    required this.heroTitle,
    required this.heroDescription,
    required this.heroStatus,
    required this.summaryTitle,
    required List<WritePrecheckRowCopy> summaryRows,
    required this.resultsTitle,
    required List<WritePrecheckRowCopy> resultRows,
    required this.technicalDetail,
    required this.recordsTitle,
    required List<WritePrecheckRecordCopy> records,
    required this.recordsNotice,
    required this.guidanceTitle,
    required List<String> guidanceLines,
    required this.commitmentNotice,
    required this.primaryAction,
    required List<String> secondaryActions,
    required this.endFlowAction,
  }) : steps = List<String>.unmodifiable(steps),
       summaryRows = List<WritePrecheckRowCopy>.unmodifiable(summaryRows),
       resultRows = List<WritePrecheckRowCopy>.unmodifiable(resultRows),
       records = List<WritePrecheckRecordCopy>.unmodifiable(records),
       guidanceLines = List<String>.unmodifiable(guidanceLines),
       secondaryActions = List<String>.unmodifiable(secondaryActions);

  factory WritePrecheckCopy.from(AppLocalizations l10n) => WritePrecheckCopy._(
    title: l10n.pencilPrecheckTitle,
    flowStep: l10n.pencilPrecheckFlowStep,
    steps: <String>[
      l10n.pencilPrecheckStepPrepared,
      l10n.pencilPrecheckStepDetected,
      l10n.pencilPrecheckStepActive,
      l10n.pencilPrecheckStepVerification,
    ],
    heroTitle: l10n.pencilPrecheckHeroTitle,
    heroDescription: l10n.pencilPrecheckHeroDescription,
    heroStatus: l10n.pencilPrecheckHeroStatus,
    summaryTitle: l10n.pencilPrecheckSummaryTitle,
    summaryRows: <WritePrecheckRowCopy>[
      WritePrecheckRowCopy(
        label: l10n.pencilPrecheckSummaryTargetLabel,
        value: l10n.pencilPrecheckSummaryTargetValue,
      ),
      WritePrecheckRowCopy(
        label: l10n.pencilPrecheckSummaryRecordsLabel,
        value: l10n.pencilPrecheckSummaryRecordsValue,
      ),
      WritePrecheckRowCopy(
        label: l10n.pencilPrecheckSummarySizeLabel,
        value: l10n.pencilPrecheckSummarySizeValue,
      ),
      WritePrecheckRowCopy(
        label: l10n.pencilPrecheckSummaryModeLabel,
        value: l10n.pencilPrecheckSummaryModeValue,
      ),
      WritePrecheckRowCopy(
        label: l10n.pencilPrecheckSummaryBackupLabel,
        value: l10n.pencilPrecheckSummaryBackupValue,
      ),
    ],
    resultsTitle: l10n.pencilPrecheckResultsTitle,
    resultRows: <WritePrecheckRowCopy>[
      WritePrecheckRowCopy(
        label: l10n.pencilPrecheckResultCompatibilityLabel,
        value: l10n.pencilPrecheckResultCompatibilityValue,
      ),
      WritePrecheckRowCopy(
        label: l10n.pencilPrecheckResultCapacityLabel,
        value: l10n.pencilPrecheckResultCapacityValue,
      ),
      WritePrecheckRowCopy(
        label: l10n.pencilPrecheckResultPermissionLabel,
        value: l10n.pencilPrecheckResultPermissionValue,
      ),
      WritePrecheckRowCopy(
        label: l10n.pencilPrecheckResultStabilityLabel,
        value: l10n.pencilPrecheckResultStabilityValue,
      ),
      WritePrecheckRowCopy(
        label: l10n.pencilPrecheckResultDecisionLabel,
        value: l10n.pencilPrecheckResultDecisionValue,
      ),
    ],
    technicalDetail: l10n.pencilPrecheckTechnicalDetail,
    recordsTitle: l10n.pencilPrecheckRecordsTitle,
    records: <WritePrecheckRecordCopy>[
      WritePrecheckRecordCopy(
        title: l10n.pencilPrecheckRecordTextTitle,
        value: l10n.pencilPrecheckRecordTextValue,
        badge: l10n.pencilPrecheckRecordTextBadge,
      ),
      WritePrecheckRecordCopy(
        title: l10n.pencilPrecheckRecordUrlTitle,
        value: l10n.pencilPrecheckRecordUrlValue,
        badge: l10n.pencilPrecheckRecordUrlBadge,
      ),
    ],
    recordsNotice: l10n.pencilPrecheckRecordsNotice,
    guidanceTitle: l10n.pencilPrecheckGuidanceTitle,
    guidanceLines: <String>[
      l10n.pencilPrecheckGuidanceKeepNear,
      l10n.pencilPrecheckGuidanceDoNotMove,
      l10n.pencilPrecheckGuidanceBackup,
    ],
    commitmentNotice: l10n.pencilPrecheckCommitmentNotice,
    primaryAction: l10n.pencilPrecheckPrimaryAction,
    secondaryActions: <String>[
      l10n.pencilPrecheckTechnicalAction,
      l10n.pencilPrecheckEditAction,
    ],
    endFlowAction: l10n.pencilPrecheckEndFlowAction,
  );

  final String title;
  final String flowStep;
  final List<String> steps;
  final String heroTitle;
  final String heroDescription;
  final String heroStatus;
  final String summaryTitle;
  final List<WritePrecheckRowCopy> summaryRows;
  final String resultsTitle;
  final List<WritePrecheckRowCopy> resultRows;
  final String technicalDetail;
  final String recordsTitle;
  final List<WritePrecheckRecordCopy> records;
  final String recordsNotice;
  final String guidanceTitle;
  final List<String> guidanceLines;
  final String commitmentNotice;
  final String primaryAction;
  final List<String> secondaryActions;
  final String endFlowAction;

  List<String> get visibleStrings => <String>[
    title,
    flowStep,
    ...steps,
    heroTitle,
    heroDescription,
    heroStatus,
    summaryTitle,
    for (final row in summaryRows) ...<String>[row.label, row.value],
    resultsTitle,
    for (final row in resultRows) ...<String>[row.label, row.value],
    technicalDetail,
    recordsTitle,
    for (final record in records) ...<String>[
      record.title,
      record.value,
      record.badge,
    ],
    recordsNotice,
    guidanceTitle,
    ...guidanceLines,
    commitmentNotice,
    primaryAction,
    ...secondaryActions,
    endFlowAction,
  ];
}
