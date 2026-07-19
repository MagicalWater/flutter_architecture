import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_architecture/app/error_reporting/error_report.dart';
import 'package:flutter_architecture/app/error_reporting/error_reporter.dart';
import 'package:flutter_architecture/app/localization/locale_preference.dart';
import 'package:flutter_architecture/app/localization/locale_preference_store.dart';
import 'package:flutter_architecture/app/preferences/preference_exception.dart';

final class LocaleController extends ChangeNotifier {
  LocaleController({
    required LocalePreferenceStore store,
    required AppLocalePreference initialPreference,
    required ErrorReporter errorReporter,
    PreferenceDiagnostic? restoreDiagnostic,
  }) : _store = store,
       _errorReporter = errorReporter,
       _preference = initialPreference,
       _diagnostic = restoreDiagnostic;

  final LocalePreferenceStore _store;
  final ErrorReporter _errorReporter;

  AppLocalePreference _preference;
  PreferenceDiagnostic? _diagnostic;
  Future<void> _writeTail = Future<void>.value();
  int _revision = 0;

  AppLocalePreference get preference => _preference;
  Locale? get locale => _preference.materialLocale;
  PreferenceDiagnostic? get diagnostic => _diagnostic;

  void select(AppLocalePreference preference) {
    if (preference == _preference) return;
    _preference = preference;
    _diagnostic = null;
    final revision = ++_revision;
    notifyListeners();

    final snapshot = preference;
    _writeTail = _writeTail.then((_) async {
      try {
        await _store.save(snapshot);
        if (revision != _revision || _diagnostic == null) return;
        _diagnostic = null;
        notifyListeners();
      } on PreferenceException catch (error, stackTrace) {
        final expected =
            error.preference == PreferenceKind.locale &&
            error.operation == PreferenceOperation.write;
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
            source: ErrorReportSource.preference,
            operation: ErrorReportOperation.preferenceWrite,
          ),
        ),
      );
    } on Object {
      // Reporting不得中斷serialized write queue。
    }
  }

  Future<void> waitForPendingWrites() => _writeTail;

  void clearDiagnostic() {
    if (_diagnostic == null) return;
    _diagnostic = null;
    notifyListeners();
  }
}

final class LocaleControllerScope extends InheritedNotifier<LocaleController> {
  const LocaleControllerScope({
    required LocaleController controller,
    required super.child,
    super.key,
  }) : super(notifier: controller);

  static LocaleController of(BuildContext context) {
    final scope = context
        .dependOnInheritedWidgetOfExactType<LocaleControllerScope>();
    if (scope == null) {
      throw FlutterError(
        'LocaleControllerScope.of() was called without a '
        'LocaleControllerScope ancestor.',
      );
    }
    return scope.notifier!;
  }
}
