import 'package:auth/auth.dart';
import 'package:flutter_architecture/app/error_reporting/error_report.dart';
import 'package:flutter_architecture/app/error_reporting/error_reporter.dart';

/// 將Auth migration diagnostics轉成App-owned safe reports。
final class AuthMigrationErrorReporterAdapter
    implements AuthLifecycleDiagnosticSink {
  const AuthMigrationErrorReporterAdapter(this._reporter);

  final ErrorReporter _reporter;

  @override
  void reportAll(Iterable<AuthLifecycleDiagnostic> diagnostics) {
    for (final diagnostic in diagnostics) {
      try {
        _reporter.report(
          ErrorReport(
            error: diagnostic.error,
            stackTrace: diagnostic.stackTrace,
            severity: ErrorSeverity.degraded,
            context: ErrorReportContext(
              source: ErrorReportSource.authLifecycle,
              operation: _mapOperation(diagnostic.operation),
            ),
          ),
        );
      } on Object {
        // Reporting不得改變migration resolution或遺失後續diagnostics。
      }
    }
  }

  ErrorReportOperation _mapOperation(
    AuthLifecycleDiagnosticOperation operation,
  ) {
    return switch (operation) {
      AuthLifecycleDiagnosticOperation.migrationLegacyCleanup =>
        ErrorReportOperation.authMigrationLegacyCleanup,
      AuthLifecycleDiagnosticOperation.secureCleanup =>
        ErrorReportOperation.authSecureCleanup,
      AuthLifecycleDiagnosticOperation.legacyCleanup =>
        ErrorReportOperation.authLegacyCleanup,
      AuthLifecycleDiagnosticOperation.userCleanup =>
        ErrorReportOperation.authUserCleanup,
    };
  }
}
