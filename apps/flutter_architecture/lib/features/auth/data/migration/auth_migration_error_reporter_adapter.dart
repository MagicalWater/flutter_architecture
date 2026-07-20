import 'package:auth/auth.dart';
import 'package:flutter_architecture/app/error_reporting/error_report.dart';
import 'package:flutter_architecture/app/error_reporting/error_reporter.dart';

/// 將Auth migration diagnostics轉成App-owned safe reports。
final class AuthMigrationErrorReporterAdapter {
  const AuthMigrationErrorReporterAdapter(this._reporter);

  final ErrorReporter _reporter;

  void reportAll(Iterable<AuthCredentialMigrationDiagnostic> diagnostics) {
    for (final diagnostic in diagnostics) {
      try {
        _reporter.report(
          ErrorReport(
            error: diagnostic.error,
            stackTrace: diagnostic.stackTrace,
            severity: ErrorSeverity.degraded,
            context: const ErrorReportContext(
              source: ErrorReportSource.authMigration,
              operation: ErrorReportOperation.authMigrationLegacyCleanup,
            ),
          ),
        );
      } on Object {
        // Reporting不得改變migration resolution或遺失後續diagnostics。
      }
    }
  }
}
