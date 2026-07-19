import 'package:flutter_architecture/app/error_reporting/error_report.dart';
import 'package:flutter_architecture/app/error_reporting/error_reporter.dart';
import 'package:flutter_architecture/app/localization/locale_controller.dart';
import 'package:flutter_architecture/app/localization/locale_preference_store.dart';

Future<LocaleController> restoreLocaleController({
  required LocalePreferenceStorage storage,
  required ErrorReporter errorReporter,
}) async {
  final store = LocalePreferenceStore(storage, const LocalePreferenceCodec());
  final restore = await store.restore();
  final diagnostic = restore.diagnostic;
  if (diagnostic != null) {
    try {
      errorReporter.report(
        ErrorReport(
          error: diagnostic.error,
          stackTrace: diagnostic.stackTrace,
          severity: ErrorSeverity.degraded,
          context: const ErrorReportContext(
            source: ErrorReportSource.preference,
            operation: ErrorReportOperation.preferenceRestore,
          ),
        ),
      );
    } on Object {
      // Reporting不得阻止fallback controller建立。
    }
  }
  return LocaleController(
    store: store,
    initialPreference: restore.preference,
    errorReporter: errorReporter,
    restoreDiagnostic: restore.diagnostic,
  );
}
