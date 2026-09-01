import 'package:auth/auth_infrastructure.dart';
import 'package:flutter_architecture/app/error_reporting/error_report.dart';
import 'package:flutter_architecture/app/error_reporting/error_reporter.dart';

/// 將 Auth cleanup diagnostics 轉成 App-owned safe reports。
final class AuthCleanupErrorReporterAdapter
    implements AuthCleanupDiagnosticSink {
  const AuthCleanupErrorReporterAdapter(this._reporter);

  final ErrorReporter _reporter;

  @override
  void reportAll(Iterable<AuthCleanupDiagnostic> diagnostics) {
    for (final diagnostic in diagnostics) {
      try {
        _reporter.report(
          ErrorReport(
            error: diagnostic.error,
            stackTrace: diagnostic.stackTrace,
            severity: ErrorSeverity.degraded,
            context: ErrorReportContext(
              operation: _mapOperation(diagnostic.operation),
            ),
          ),
        );
      } on Object {
        // Reporting不得改變migration resolution或遺失後續diagnostics。
      }
    }
  }

  ErrorReportOperation _mapOperation(AuthCleanupOperation operation) {
    return switch (operation) {
      AuthCleanupOperation.migrationLegacyCleanup =>
        ErrorReportOperation.authMigrationLegacyCleanup,
      AuthCleanupOperation.secureCleanup =>
        ErrorReportOperation.authSecureCleanup,
      AuthCleanupOperation.legacyCleanup =>
        ErrorReportOperation.authLegacyCleanup,
      AuthCleanupOperation.userCleanup => ErrorReportOperation.authUserCleanup,
      AuthCleanupOperation.localUnlockPreferenceCleanup =>
        ErrorReportOperation.authLocalUnlockPreferenceCleanup,
    };
  }
}
