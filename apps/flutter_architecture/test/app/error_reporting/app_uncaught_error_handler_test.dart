import 'package:flutter/foundation.dart';
import 'package:flutter_architecture/app/error_reporting/app_uncaught_error_handler.dart';
import 'package:flutter_architecture/app/error_reporting/error_report.dart';
import 'package:flutter_architecture/app/error_reporting/error_report_deduplicator.dart';
import 'package:flutter_architecture/app/error_reporting/error_reporter.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Flutter framework error以unexpected與固定safe context上報', () {
    final reporter = _RecordingReporter();
    final handler = AppUncaughtErrorHandler(
      reporter,
      ErrorReportDeduplicator(),
    );
    final error = FlutterError('framework failed');
    final stackTrace = StackTrace.current;

    handler.handleFlutterError(
      FlutterErrorDetails(exception: error, stack: stackTrace),
    );

    expect(reporter.reports, hasLength(1));
    final report = reporter.reports.single;
    expect(report.error, same(error));
    expect(report.stackTrace, same(stackTrace));
    expect(report.severity, ErrorSeverity.unexpected);
    expect(report.context.source, ErrorReportSource.flutterFramework);
    expect(
      report.context.operation,
      ErrorReportOperation.flutterFrameworkError,
    );
  });

  test('Flutter framework缺少stack時不製造handler origin stack', () {
    final reporter = _RecordingReporter();
    final handler = AppUncaughtErrorHandler(
      reporter,
      ErrorReportDeduplicator(),
    );

    handler.handleFlutterError(
      FlutterErrorDetails(exception: StateError('framework failed')),
    );

    expect(reporter.reports.single.stackTrace, same(StackTrace.empty));
  });

  test('Platform uncaught error以fatal上報並標記handled', () {
    final reporter = _RecordingReporter();
    final handler = AppUncaughtErrorHandler(
      reporter,
      ErrorReportDeduplicator(),
    );
    final error = StateError('async failed');
    final stackTrace = StackTrace.current;

    final handled = handler.handlePlatformError(error, stackTrace);

    expect(handled, isTrue);
    expect(reporter.reports, hasLength(1));
    final report = reporter.reports.single;
    expect(report.error, same(error));
    expect(report.stackTrace, same(stackTrace));
    expect(report.severity, ErrorSeverity.fatal);
    expect(report.context.source, ErrorReportSource.platform);
    expect(
      report.context.operation,
      ErrorReportOperation.platformUncaughtAsync,
    );
  });

  test('Reporter失敗不會從uncaught handler逃出', () {
    final handler = AppUncaughtErrorHandler(
      _ThrowingReporter(),
      ErrorReportDeduplicator(),
    );

    expect(
      () => handler.handleFlutterError(
        FlutterErrorDetails(exception: StateError('framework failed')),
      ),
      returnsNormally,
    );
    expect(
      () => handler.handlePlatformError(
        StateError('async failed'),
        StackTrace.current,
      ),
      returnsNormally,
    );
  });

  testWidgets('Global hooks會委派既有handler並可還原', (tester) async {
    final originalFlutterHandler = FlutterError.onError;
    final originalPlatformHandler = PlatformDispatcher.instance.onError;
    var flutterDelegateCalls = 0;
    var platformDelegateCalls = 0;
    FlutterError.onError = (_) => flutterDelegateCalls += 1;
    PlatformDispatcher.instance.onError = (_, _) {
      platformDelegateCalls += 1;
      return false;
    };
    addTearDown(() {
      FlutterError.onError = originalFlutterHandler;
      PlatformDispatcher.instance.onError = originalPlatformHandler;
    });
    final reporter = _RecordingReporter();
    final hooks = AppUncaughtErrorHooks.install(
      AppUncaughtErrorHandler(reporter, ErrorReportDeduplicator()),
    );

    FlutterError.onError?.call(
      FlutterErrorDetails(exception: StateError('framework failed')),
    );
    final platformHandled = PlatformDispatcher.instance.onError?.call(
      StateError('async failed'),
      StackTrace.current,
    );

    expect(reporter.reports, hasLength(2));
    expect(flutterDelegateCalls, 1);
    expect(platformDelegateCalls, 1);
    expect(platformHandled, isFalse);

    hooks.dispose();
    expect(FlutterError.onError, isNotNull);
    expect(PlatformDispatcher.instance.onError, isNotNull);
  });

  testWidgets('hook存在時禁止重複install', (tester) async {
    final originalFlutterHandler = FlutterError.onError;
    final originalPlatformHandler = PlatformDispatcher.instance.onError;
    addTearDown(() {
      FlutterError.onError = originalFlutterHandler;
      PlatformDispatcher.instance.onError = originalPlatformHandler;
    });
    final hooks = AppUncaughtErrorHooks.install(
      AppUncaughtErrorHandler(_RecordingReporter(), ErrorReportDeduplicator()),
    );
    addTearDown(hooks.dispose);

    expect(
      () => AppUncaughtErrorHooks.install(
        AppUncaughtErrorHandler(
          _RecordingReporter(),
          ErrorReportDeduplicator(),
        ),
      ),
      throwsStateError,
    );
  });

  testWidgets('dispose不會覆蓋後來安裝的外部global handler', (tester) async {
    final originalFlutterHandler = FlutterError.onError;
    final originalPlatformHandler = PlatformDispatcher.instance.onError;
    addTearDown(() {
      FlutterError.onError = originalFlutterHandler;
      PlatformDispatcher.instance.onError = originalPlatformHandler;
    });
    final hooks = AppUncaughtErrorHooks.install(
      AppUncaughtErrorHandler(_RecordingReporter(), ErrorReportDeduplicator()),
    );
    void externalFlutterHandler(FlutterErrorDetails _) {}
    bool externalPlatformHandler(Object _, StackTrace _) => false;
    FlutterError.onError = externalFlutterHandler;
    PlatformDispatcher.instance.onError = externalPlatformHandler;

    hooks.dispose();

    expect(FlutterError.onError, same(externalFlutterHandler));
    expect(PlatformDispatcher.instance.onError, same(externalPlatformHandler));
  });

  testWidgets('dispose可重複呼叫且只還原一次', (tester) async {
    final originalFlutterHandler = FlutterError.onError;
    final originalPlatformHandler = PlatformDispatcher.instance.onError;
    addTearDown(() {
      FlutterError.onError = originalFlutterHandler;
      PlatformDispatcher.instance.onError = originalPlatformHandler;
    });
    final hooks = AppUncaughtErrorHooks.install(
      AppUncaughtErrorHandler(_RecordingReporter(), ErrorReportDeduplicator()),
    );

    hooks.dispose();
    hooks.dispose();

    expect(FlutterError.onError, same(originalFlutterHandler));
    expect(PlatformDispatcher.instance.onError, same(originalPlatformHandler));
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
