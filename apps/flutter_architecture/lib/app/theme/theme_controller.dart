import 'dart:async';

import 'package:design_system/design_system.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_architecture/app/error_reporting/error_report.dart';
import 'package:flutter_architecture/app/error_reporting/error_reporter.dart';
import 'package:flutter_architecture/app/preferences/preference_exception.dart';
import 'package:flutter_architecture/app/theme/theme_preference.dart';
import 'package:flutter_architecture/app/theme/theme_preference_store.dart';

/// 擁有 runtime theme preference，並序列化 durable writes 避免快速切換造成 stale write。
final class ThemeController extends ChangeNotifier {
  ThemeController({
    required this.registry,
    required ThemePreferenceStore store,
    required ThemePreference initialPreference,
    required ErrorReporter errorReporter,
    PreferenceDiagnostic? restoreDiagnostic,
  }) : _store = store,
       _errorReporter = errorReporter,
       _preference = initialPreference,
       _diagnostic = restoreDiagnostic;

  final DsThemeRegistry registry;
  final ThemePreferenceStore _store;
  final ErrorReporter _errorReporter;

  ThemePreference _preference;
  PreferenceDiagnostic? _diagnostic;
  Future<void> _writeTail = Future<void>.value();
  int _revision = 0;

  ThemePreference get preference => _preference;
  PreferenceDiagnostic? get diagnostic => _diagnostic;
  DsThemeDefinition get definition => registry.resolve(_preference.themeId);

  void selectTheme(DsThemeId themeId) {
    _setPreference(
      _preference.copyWith(themeId: registry.resolve(themeId).metadata.id),
    );
  }

  void selectMode(AppThemeMode mode) {
    _setPreference(_preference.copyWith(mode: mode));
  }

  Future<void> waitForPendingWrites() => _writeTail;

  void clearDiagnostic() {
    if (_diagnostic == null) return;
    _diagnostic = null;
    notifyListeners();
  }

  void _setPreference(ThemePreference next) {
    if (next == _preference) return;
    _preference = next;
    _diagnostic = null;
    final revision = ++_revision;
    notifyListeners();

    // UI 先採 optimistic state；durable write 依序執行，避免快速切換時讓較舊
    // save 完成順序覆蓋較新的 preference。revision 只決定誰能回寫 diagnostic。
    final snapshot = next;
    _writeTail = _writeTail.then((_) async {
      try {
        await _store.save(snapshot);
        if (revision != _revision || _diagnostic == null) return;
        _diagnostic = null;
        notifyListeners();
      } on PreferenceException catch (error, stackTrace) {
        final expected =
            error.preference == PreferenceKind.theme &&
            error is PreferenceStorageException &&
            error.operation == PreferenceStorageOperation.write;
        _reportWriteFailure(error, stackTrace, expected: expected);
        if (!expected || revision != _revision) return;
        _diagnostic = PreferenceDiagnostic(
          error: error,
          stackTrace: stackTrace,
        );
        notifyListeners();
      } catch (error, stackTrace) {
        _reportWriteFailure(error, stackTrace, expected: false);
      }
    });
  }

  void _reportWriteFailure(
    Object error,
    StackTrace stackTrace, {
    required bool expected,
  }) {
    try {
      _errorReporter.report(
        ErrorReport(
          error: error,
          stackTrace: stackTrace,
          severity: expected
              ? ErrorSeverity.degraded
              : ErrorSeverity.unexpected,
          context: const ErrorReportContext(
            operation: ErrorReportOperation.preferenceWrite,
          ),
        ),
      );
    } on Object {
      // Reporting不得中斷serialized write queue。
    }
  }
}

final class ThemeControllerScope extends InheritedNotifier<ThemeController> {
  const ThemeControllerScope({
    required ThemeController controller,
    required super.child,
    super.key,
  }) : super(notifier: controller);

  static ThemeController of(BuildContext context) {
    final scope = context
        .dependOnInheritedWidgetOfExactType<ThemeControllerScope>();
    if (scope == null) {
      throw FlutterError(
        'ThemeControllerScope.of() was called without a '
        'ThemeControllerScope ancestor.',
      );
    }
    return scope.notifier!;
  }

  /// Presentation consumer 取得目前已由 registry resolve 的 Theme Identity。
  ///
  /// Theme-aware visual selection 應依賴這個 stable identity，而不是讀取
  /// preference persistence 或用 raw color 反推目前 Theme。
  static DsThemeId themeIdOf(BuildContext context) =>
      of(context).definition.metadata.id;
}
