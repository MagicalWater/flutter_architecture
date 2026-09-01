import 'package:flutter/foundation.dart';
import 'package:flutter_architecture/app/error_reporting/error_report.dart';
import 'package:flutter_architecture/app/error_reporting/error_report_deduplicator.dart';
import 'package:flutter_architecture/app/error_reporting/error_reporter.dart';

typedef FlutterErrorCallback = void Function(FlutterErrorDetails details);
typedef PlatformErrorCallback =
    bool Function(Object error, StackTrace stackTrace);

/// App-owned Flutter framework與root isolate uncaught error boundary。
final class AppUncaughtErrorHandler {
  const AppUncaughtErrorHandler(this._reporter, this._deduplicator);

  final ErrorReporter _reporter;
  final ErrorReportDeduplicator _deduplicator;

  void handleFlutterError(FlutterErrorDetails details) {
    _reportBestEffort(
      ErrorReport(
        error: details.exception,
        stackTrace: details.stack ?? StackTrace.empty,
        severity: ErrorSeverity.unexpected,
        context: const ErrorReportContext(
          operation: ErrorReportOperation.flutterFrameworkError,
        ),
      ),
    );
  }

  bool handlePlatformError(Object error, StackTrace stackTrace) {
    if (_deduplicator.consumeReported(error, stackTrace)) return true;
    _reportBestEffort(
      ErrorReport(
        error: error,
        stackTrace: stackTrace,
        severity: ErrorSeverity.fatal,
        context: const ErrorReportContext(
          operation: ErrorReportOperation.platformUncaughtAsync,
        ),
      ),
    );
    return true;
  }

  void _reportBestEffort(ErrorReport report) {
    try {
      _reporter.report(report);
    } on Object {
      // Reporting不得取代原始uncaught error flow。
    }
  }
}

/// 安裝global Flutter / Platform hooks並保留既有handler語意。
final class AppUncaughtErrorHooks {
  AppUncaughtErrorHooks._({
    required FlutterErrorCallback? previousFlutterHandler,
    required PlatformErrorCallback? previousPlatformHandler,
    required FlutterErrorCallback installedFlutterHandler,
    required PlatformErrorCallback installedPlatformHandler,
  }) : _previousFlutterHandler = previousFlutterHandler,
       _previousPlatformHandler = previousPlatformHandler,
       _installedFlutterHandler = installedFlutterHandler,
       _installedPlatformHandler = installedPlatformHandler;

  final FlutterErrorCallback? _previousFlutterHandler;
  final PlatformErrorCallback? _previousPlatformHandler;
  final FlutterErrorCallback _installedFlutterHandler;
  final PlatformErrorCallback _installedPlatformHandler;
  bool _isDisposed = false;
  static AppUncaughtErrorHooks? _activeHooks;

  static AppUncaughtErrorHooks install(AppUncaughtErrorHandler handler) {
    if (_activeHooks case final active? when !active._isDisposed) {
      throw StateError('AppUncaughtErrorHooks is already installed');
    }
    final previousFlutterHandler = FlutterError.onError;
    final previousPlatformHandler = PlatformDispatcher.instance.onError;
    late final FlutterErrorCallback installedFlutterHandler;
    late final PlatformErrorCallback installedPlatformHandler;
    installedFlutterHandler = (details) {
      handler.handleFlutterError(details);
      previousFlutterHandler?.call(details);
    };
    installedPlatformHandler = (error, stackTrace) {
      handler.handlePlatformError(error, stackTrace);
      return previousPlatformHandler?.call(error, stackTrace) ?? true;
    };
    final hooks = AppUncaughtErrorHooks._(
      previousFlutterHandler: previousFlutterHandler,
      previousPlatformHandler: previousPlatformHandler,
      installedFlutterHandler: installedFlutterHandler,
      installedPlatformHandler: installedPlatformHandler,
    );

    FlutterError.onError = installedFlutterHandler;
    PlatformDispatcher.instance.onError = installedPlatformHandler;
    _activeHooks = hooks;
    return hooks;
  }

  void dispose() {
    if (_isDisposed) return;
    _isDisposed = true;
    if (identical(_activeHooks, this)) {
      _activeHooks = null;
    }
    if (identical(FlutterError.onError, _installedFlutterHandler)) {
      FlutterError.onError = _previousFlutterHandler;
    }
    if (identical(
      PlatformDispatcher.instance.onError,
      _installedPlatformHandler,
    )) {
      PlatformDispatcher.instance.onError = _previousPlatformHandler;
    }
  }
}
