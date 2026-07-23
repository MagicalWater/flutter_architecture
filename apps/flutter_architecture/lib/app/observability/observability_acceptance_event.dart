import 'package:flutter_architecture/app/error_reporting/error_report.dart';
import 'package:flutter_architecture/app/error_reporting/error_reporter.dart';
import 'package:flutter_architecture/app/observability/observability_runtime_config.dart';

final class ObservabilityAcceptanceEvent {
  const ObservabilityAcceptanceEvent._();

  static void emit({
    required ErrorReporter reporter,
    required ObservabilityRuntimeConfig config,
  }) {
    if (!config.emitAcceptanceEvent) return;

    reporter.report(
      ErrorReport(
        error: StateError('controlled-observability-acceptance-event'),
        stackTrace: StackTrace.current,
        severity: ErrorSeverity.unexpected,
        context: const ErrorReportContext(
          source: ErrorReportSource.bootstrap,
          operation: ErrorReportOperation.observabilityAcceptance,
        ),
      ),
    );
  }
}
