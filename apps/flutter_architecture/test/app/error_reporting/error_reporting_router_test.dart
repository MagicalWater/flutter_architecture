import 'package:flutter_architecture/app/error_reporting/error_report.dart';
import 'package:flutter_architecture/app/error_reporting/error_reporter.dart';
import 'package:flutter_architecture/app/error_reporting/error_reporting_router.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('fatal與unexpected直接轉送，degraded依source與operation限流', () {
    final delegate = _CollectingReporter();
    final router = ErrorReportingRouter(
      delegate: delegate,
      degradedBurstLimit: 2,
    );

    router.report(_report(ErrorSeverity.fatal));
    router.report(_report(ErrorSeverity.unexpected));
    router.report(_report(ErrorSeverity.degraded));
    router.report(_report(ErrorSeverity.degraded));
    router.report(_report(ErrorSeverity.degraded));

    expect(delegate.reports.map((report) => report.severity), <ErrorSeverity>[
      ErrorSeverity.fatal,
      ErrorSeverity.unexpected,
      ErrorSeverity.degraded,
      ErrorSeverity.degraded,
    ]);
  });

  test('degraded限流key不使用error message或payload', () {
    final delegate = _CollectingReporter();
    final router = ErrorReportingRouter(
      delegate: delegate,
      degradedBurstLimit: 1,
    );

    router.report(
      _report(ErrorSeverity.degraded, error: StateError('secret-a')),
    );
    router.report(
      _report(ErrorSeverity.degraded, error: StateError('secret-b')),
    );

    expect(delegate.reports, hasLength(1));
  });

  test('delegate再次透過router上報時不遞迴', () {
    late ErrorReportingRouter router;
    final delegate = _RecursiveReporter(() {
      router.report(_report(ErrorSeverity.unexpected));
    });
    router = ErrorReportingRouter(delegate: delegate);

    router.report(_report(ErrorSeverity.fatal));

    expect(delegate.calls, 1);
  });

  test('closed metadata只包含enum與severity名稱', () {
    final metadata = ErrorReportMetadata.fromReport(
      _report(ErrorSeverity.unexpected, error: StateError('token=secret')),
    );

    expect(metadata.values, <String, String>{
      'severity': 'unexpected',
      'source': 'catalogCache',
      'operation': 'catalogCacheRead',
      'error_type': 'StateError',
    });
    expect(metadata.toString(), isNot(contains('secret')));
  });
}

ErrorReport _report(ErrorSeverity severity, {Object? error}) {
  return ErrorReport(
    error: error ?? StateError('ignored'),
    stackTrace: StackTrace.current,
    severity: severity,
    context: const ErrorReportContext(
      source: ErrorReportSource.catalogCache,
      operation: ErrorReportOperation.catalogCacheRead,
    ),
  );
}

final class _CollectingReporter implements ErrorReporter {
  final List<ErrorReport> reports = <ErrorReport>[];

  @override
  void report(ErrorReport report) => reports.add(report);
}

final class _RecursiveReporter implements ErrorReporter {
  _RecursiveReporter(this.onReport);

  final void Function() onReport;
  int calls = 0;

  @override
  void report(ErrorReport report) {
    calls += 1;
    onReport();
  }
}
