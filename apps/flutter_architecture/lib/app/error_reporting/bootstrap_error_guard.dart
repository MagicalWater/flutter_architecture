import 'package:flutter_architecture/app/error_reporting/error_report.dart';
import 'package:flutter_architecture/app/error_reporting/error_report_deduplicator.dart';
import 'package:flutter_architecture/app/error_reporting/error_reporter.dart';

Future<T> runBootstrapGuarded<T>(
  Future<T> Function() action,
  ErrorReporter reporter,
  ErrorReportDeduplicator deduplicator,
) async {
  try {
    return await action();
  } catch (error, stackTrace) {
    try {
      reporter.report(
        ErrorReport(
          error: error,
          stackTrace: stackTrace,
          severity: ErrorSeverity.fatal,
          context: const ErrorReportContext(
            operation: ErrorReportOperation.bootstrapInitialize,
          ),
        ),
      );
      deduplicator.markReported(error, stackTrace);
    } on Object {
      // Reporting不得取代原始bootstrap failure。
    }
    Error.throwWithStackTrace(error, stackTrace);
  }
}
