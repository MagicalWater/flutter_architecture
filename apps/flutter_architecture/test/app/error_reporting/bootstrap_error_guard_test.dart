import 'package:flutter/foundation.dart';
import 'package:flutter_architecture/app/error_reporting/bootstrap_error_guard.dart';
import 'package:flutter_architecture/app/error_reporting/app_uncaught_error_handler.dart';
import 'package:flutter_architecture/app/error_reporting/error_report.dart';
import 'package:flutter_architecture/app/error_reporting/error_report_deduplicator.dart';
import 'package:flutter_architecture/app/error_reporting/error_reporter.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('bootstrap failure以fatal上報並保留error與stack identity', () async {
    final reporter = _RecordingReporter();
    final error = StateError('bootstrap failed');
    late StackTrace caughtStackTrace;

    await expectLater(
      runBootstrapGuarded<void>(
        () async {
          try {
            Error.throwWithStackTrace(error, StackTrace.current);
          } catch (_, stackTrace) {
            caughtStackTrace = stackTrace;
            rethrow;
          }
        },
        reporter,
        ErrorReportDeduplicator(),
      ),
      throwsA(same(error)),
    );

    expect(reporter.reports, hasLength(1));
    final report = reporter.reports.single;
    expect(report.error, same(error));
    expect(report.stackTrace.toString(), caughtStackTrace.toString());
    expect(report.severity, ErrorSeverity.fatal);
    expect(report.context.source, ErrorReportSource.bootstrap);
    expect(report.context.operation, ErrorReportOperation.bootstrapInitialize);
  });

  test('Reporter failure不取代原始bootstrap failure', () async {
    final error = StateError('bootstrap failed');

    await expectLater(
      runBootstrapGuarded<void>(
        () async => throw error,
        _ThrowingReporter(),
        ErrorReportDeduplicator(),
      ),
      throwsA(same(error)),
    );
  });

  test('bootstrap已上報的同identity error不會再由Platform重複上報', () async {
    final reporter = _RecordingReporter();
    final deduplicator = ErrorReportDeduplicator(scheduleCleanup: (_) {});
    final platformHandler = AppUncaughtErrorHandler(reporter, deduplicator);
    final error = StateError('bootstrap failed');
    late StackTrace propagatedStackTrace;

    try {
      await runBootstrapGuarded<void>(
        () async => throw error,
        reporter,
        deduplicator,
      );
    } catch (_, stackTrace) {
      propagatedStackTrace = stackTrace;
    }
    final handled = platformHandler.handlePlatformError(
      error,
      propagatedStackTrace,
    );

    expect(handled, isTrue);
    expect(reporter.reports, hasLength(1));
    expect(
      reporter.reports.single.context.operation,
      ErrorReportOperation.bootstrapInitialize,
    );
  });

  testWidgets('hook install failure會進bootstrap fatal guard', (tester) async {
    final originalFlutterHandler = FlutterError.onError;
    final originalPlatformHandler = PlatformDispatcher.instance.onError;
    final reporter = _RecordingReporter();
    final deduplicator = ErrorReportDeduplicator(scheduleCleanup: (_) {});
    final installedHooks = AppUncaughtErrorHooks.install(
      AppUncaughtErrorHandler(reporter, deduplicator),
    );
    addTearDown(() {
      installedHooks.dispose();
      FlutterError.onError = originalFlutterHandler;
      PlatformDispatcher.instance.onError = originalPlatformHandler;
    });

    await expectLater(
      runBootstrapGuarded<void>(
        () async {
          AppUncaughtErrorHooks.install(
            AppUncaughtErrorHandler(reporter, deduplicator),
          );
        },
        reporter,
        deduplicator,
      ),
      throwsStateError,
    );

    expect(reporter.reports, hasLength(1));
    expect(reporter.reports.single.severity, ErrorSeverity.fatal);
    expect(reporter.reports.single.context.source, ErrorReportSource.bootstrap);
    expect(
      reporter.reports.single.context.operation,
      ErrorReportOperation.bootstrapInitialize,
    );
  });
}

final class _RecordingReporter implements ErrorReporter {
  final List<ErrorReport> reports = <ErrorReport>[];

  @override
  void report(ErrorReport report) {
    reports.add(report);
  }
}

final class _ThrowingReporter implements ErrorReporter {
  @override
  void report(ErrorReport report) {
    throw StateError('reporter failed');
  }
}
