import 'package:auth/auth.dart';
import 'package:flutter_architecture/app/error_reporting/error_report.dart';
import 'package:flutter_architecture/app/error_reporting/error_reporter.dart';
import 'package:flutter_architecture/features/auth/data/migration/auth_migration_error_reporter_adapter.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('逐項上報所有migration diagnostics並使用固定safe context', () {
    final reporter = _RecordingReporter();
    final adapter = AuthMigrationErrorReporterAdapter(reporter);
    final firstError = StateError('plugin-secret-1');
    final secondError = StateError('plugin-secret-2');
    final thirdError = StateError('plugin-secret-3');
    final fourthError = StateError('plugin-secret-4');
    final firstStack = StackTrace.current;
    final secondStack = StackTrace.current;

    adapter.reportAll(<AuthLifecycleDiagnostic>[
      AuthLifecycleDiagnostic(
        operation: AuthLifecycleDiagnosticOperation.migrationLegacyCleanup,
        error: firstError,
        stackTrace: firstStack,
      ),
      AuthLifecycleDiagnostic(
        operation: AuthLifecycleDiagnosticOperation.secureCleanup,
        error: secondError,
        stackTrace: secondStack,
      ),
      AuthLifecycleDiagnostic(
        operation: AuthLifecycleDiagnosticOperation.legacyCleanup,
        error: thirdError,
        stackTrace: StackTrace.current,
      ),
      AuthLifecycleDiagnostic(
        operation: AuthLifecycleDiagnosticOperation.userCleanup,
        error: fourthError,
        stackTrace: StackTrace.current,
      ),
    ]);

    expect(reporter.reports, hasLength(4));
    expect(reporter.reports[0].error, same(firstError));
    expect(reporter.reports[0].stackTrace, same(firstStack));
    expect(reporter.reports[1].error, same(secondError));
    expect(reporter.reports[1].stackTrace, same(secondStack));
    for (final report in reporter.reports) {
      expect(report.severity, ErrorSeverity.degraded);
      expect(report.context.source, ErrorReportSource.authLifecycle);
      expect(report.toString(), isNot(contains('plugin-secret')));
    }
    expect(
      reporter.reports[0].context.operation,
      ErrorReportOperation.authMigrationLegacyCleanup,
    );
    expect(
      reporter.reports[1].context.operation,
      ErrorReportOperation.authSecureCleanup,
    );
    expect(
      reporter.reports[2].context.operation,
      ErrorReportOperation.authLegacyCleanup,
    );
    expect(
      reporter.reports[3].context.operation,
      ErrorReportOperation.authUserCleanup,
    );
  });

  test('reporter failure不阻止後續diagnostic上報', () {
    final reporter = _RecordingReporter(throwOnCall: 1);
    final adapter = AuthMigrationErrorReporterAdapter(reporter);

    adapter.reportAll(<AuthLifecycleDiagnostic>[
      AuthLifecycleDiagnostic(
        operation: AuthLifecycleDiagnosticOperation.legacyCleanup,
        error: StateError('first'),
        stackTrace: StackTrace.current,
      ),
      AuthLifecycleDiagnostic(
        operation: AuthLifecycleDiagnosticOperation.userCleanup,
        error: StateError('second'),
        stackTrace: StackTrace.current,
      ),
    ]);

    expect(reporter.calls, 2);
    expect(reporter.reports, hasLength(1));
  });
}

final class _RecordingReporter implements ErrorReporter {
  _RecordingReporter({this.throwOnCall});

  final int? throwOnCall;
  final List<ErrorReport> reports = <ErrorReport>[];
  int calls = 0;

  @override
  void report(ErrorReport report) {
    calls += 1;
    if (calls == throwOnCall) throw StateError('reporter failed');
    reports.add(report);
  }
}
