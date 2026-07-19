import 'package:flutter_architecture/app/error_reporting/debug_error_reporter.dart';
import 'package:flutter_architecture/app/error_reporting/error_report.dart';
import 'package:flutter_architecture/app/error_reporting/error_reporter.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('ErrorReport 保留原始error與stack trace identity', () {
    final error = StateError('sensitive error payload');
    final stackTrace = StackTrace.current;
    final report = ErrorReport(
      error: error,
      stackTrace: stackTrace,
      severity: ErrorSeverity.unexpected,
      context: const ErrorReportContext(
        source: ErrorReportSource.bootstrap,
        operation: ErrorReportOperation.bootstrapInitialize,
      ),
    );

    expect(report.error, same(error));
    expect(report.stackTrace, same(stackTrace));
  });

  test('ErrorReport toString只輸出安全metadata', () {
    final report = ErrorReport(
      error: StateError('sensitive error payload'),
      stackTrace: StackTrace.fromString('sensitive stack payload'),
      severity: ErrorSeverity.degraded,
      context: const ErrorReportContext(
        source: ErrorReportSource.preference,
        operation: ErrorReportOperation.preferenceRestore,
      ),
    );

    final text = report.toString();

    expect(text, contains('StateError'));
    expect(text, contains('ErrorSeverity.degraded'));
    expect(text, contains('ErrorReportSource.preference'));
    expect(text, contains('ErrorReportOperation.preferenceRestore'));
    expect(text, isNot(contains('sensitive error payload')));
    expect(text, isNot(contains('sensitive stack payload')));
  });

  test('DebugErrorReporter不展開error內容', () {
    final messages = <String>[];
    final reporter = DebugErrorReporter(sink: messages.add);

    reporter.report(
      ErrorReport(
        error: StateError('secret'),
        stackTrace: StackTrace.current,
        severity: ErrorSeverity.fatal,
        context: const ErrorReportContext(
          source: ErrorReportSource.flutterFramework,
          operation: ErrorReportOperation.flutterFrameworkError,
        ),
      ),
    );

    expect(messages, hasLength(1));
    expect(messages.single, contains('StateError'));
    expect(messages.single, contains('flutterFrameworkError'));
    expect(messages.single, isNot(contains('secret')));
  });

  test('DebugErrorReporter會吸收sink自身錯誤', () {
    final reporter = DebugErrorReporter(
      sink: (_) => throw StateError('logger failed'),
    );

    expect(
      () => reporter.report(
        ErrorReport(
          error: StateError('original'),
          stackTrace: StackTrace.current,
          severity: ErrorSeverity.unexpected,
          context: const ErrorReportContext(
            source: ErrorReportSource.platform,
            operation: ErrorReportOperation.platformUncaughtAsync,
          ),
        ),
      ),
      returnsNormally,
    );
  });

  test('Recording reporter可保存完整typed report供測試驗證', () {
    final reporter = _RecordingErrorReporter();
    final report = ErrorReport(
      error: StateError('failure'),
      stackTrace: StackTrace.current,
      severity: ErrorSeverity.degraded,
      context: const ErrorReportContext(
        source: ErrorReportSource.catalogCache,
        operation: ErrorReportOperation.catalogCacheRead,
      ),
    );

    reporter.report(report);

    expect(reporter.reports, hasLength(1));
    expect(reporter.reports.single, same(report));
  });

  test('Context只接受封閉enum operation', () {
    const context = ErrorReportContext(
      source: ErrorReportSource.preference,
      operation: ErrorReportOperation.preferenceWrite,
    );

    expect(context.source, ErrorReportSource.preference);
    expect(context.operation, ErrorReportOperation.preferenceWrite);
  });

  test('DebugErrorReporter固定格式化安全欄位', () {
    final messages = <String>[];
    final reporter = DebugErrorReporter(sink: messages.add);

    reporter.report(
      ErrorReport(
        error: StateError('secret'),
        stackTrace: StackTrace.fromString('secret stack'),
        severity: ErrorSeverity.unexpected,
        context: const ErrorReportContext(
          source: ErrorReportSource.bloc,
          operation: ErrorReportOperation.blocUnhandledError,
        ),
      ),
    );

    expect(messages.single, contains('source: bloc'));
    expect(messages.single, contains('operation: blocUnhandledError'));
    expect(messages.single, isNot(contains('ErrorReportContext')));
    expect(messages.single, isNot(contains('secret')));
  });
}

final class _RecordingErrorReporter implements ErrorReporter {
  final List<ErrorReport> reports = <ErrorReport>[];

  @override
  void report(ErrorReport report) {
    reports.add(report);
  }
}
