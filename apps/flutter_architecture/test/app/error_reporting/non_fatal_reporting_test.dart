import 'package:design_system/design_system.dart';
import 'package:flutter_architecture/app/error_reporting/catalog_cache_error_reporter_adapter.dart';
import 'package:flutter_architecture/app/error_reporting/error_report.dart';
import 'package:flutter_architecture/app/error_reporting/error_reporter.dart';
import 'package:flutter_architecture/app/localization/locale_controller.dart';
import 'package:flutter_architecture/app/localization/locale_preference.dart';
import 'package:flutter_architecture/app/localization/locale_preference_store.dart';
import 'package:flutter_architecture/app/preferences/preference_exception.dart';
import 'package:flutter_architecture/app/theme/theme_controller.dart';
import 'package:flutter_architecture/app/theme/theme_preference.dart';
import 'package:flutter_architecture/app/theme/theme_preference_store.dart';
import 'package:flutter_architecture/features/catalog/data/cache/catalog_cache_failure_details.dart';
import 'package:core/core.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Theme expected write failure 以 degraded 上報且不阻止較新寫入', () async {
    final reporter = _RecordingReporter();
    final storage = _ThemeStorage(<Object>[
      const PreferenceStorageException.write(preference: PreferenceKind.theme),
    ]);
    final defaultTheme = DefaultThemeDefinition();
    final oceanTheme = OceanThemeDefinition();
    final registry = DsThemeRegistry(
      definitions: <DsThemeDefinition>[defaultTheme, oceanTheme],
      defaultThemeId: defaultTheme.id,
    );
    final controller = ThemeController(
      registry: registry,
      store: ThemePreferenceStore(storage, ThemePreferenceCodec(registry)),
      initialPreference: ThemePreference.defaults(registry),
      errorReporter: reporter,
    );

    controller.selectTheme(oceanTheme.id);
    controller.selectMode(AppThemeMode.dark);
    await controller.waitForPendingWrites();

    expect(storage.writes, hasLength(2));
    expect(reporter.reports, hasLength(1));
    expect(reporter.reports.single.severity, ErrorSeverity.degraded);
    expect(
      reporter.reports.single.context.operation,
      ErrorReportOperation.preferenceWrite,
    );
  });

  test('Locale unknown write failure 以 unexpected 上報且不會消失', () async {
    final reporter = _RecordingReporter();
    final error = StateError('implementation bug');
    final storage = _LocaleStorage(<Object>[error]);
    final controller = LocaleController(
      store: LocalePreferenceStore(storage, const LocalePreferenceCodec()),
      initialPreference: AppLocalePreference.system,
      errorReporter: reporter,
    );

    controller.select(AppLocalePreference.english);
    controller.select(AppLocalePreference.traditionalChinese);
    await controller.waitForPendingWrites();

    expect(storage.writes, hasLength(2));
    expect(reporter.reports, hasLength(1));
    expect(reporter.reports.single.error, same(error));
    expect(reporter.reports.single.severity, ErrorSeverity.unexpected);
    expect(controller.diagnostic, isNull);
  });

  test('Catalog adapter將read failure映射為degraded safe context', () {
    final reporter = _RecordingReporter();
    final adapter = CatalogCacheErrorReporterAdapter(reporter);
    final stackTrace = StackTrace.current;
    final error = AppException(
      kind: AppExceptionKind.localStorage,
      message: 'cache failed',
      cause: const CatalogCacheFailureDetails(
        operation: CatalogCacheOperation.readPage,
        isQueryEmpty: false,
        hasCursor: true,
        limit: 20,
        originalError: 'sqlite unavailable',
      ),
    );

    adapter.report(
      error: error,
      stackTrace: stackTrace,
      operation: CatalogCacheOperation.readPage,
    );

    expect(reporter.reports, hasLength(1));
    expect(reporter.reports.single.error, same(error));
    expect(reporter.reports.single.stackTrace, same(stackTrace));
    expect(reporter.reports.single.severity, ErrorSeverity.degraded);
    expect(
      reporter.reports.single.context.operation,
      ErrorReportOperation.catalogCacheRead,
    );
  });
}

final class _RecordingReporter implements ErrorReporter {
  final List<ErrorReport> reports = <ErrorReport>[];

  @override
  void report(ErrorReport report) => reports.add(report);
}

final class _ThemeStorage implements ThemePreferenceStorage {
  _ThemeStorage(this.errors);

  final List<Object> errors;
  final List<String> writes = <String>[];

  @override
  Future<String?> read() async => null;

  @override
  Future<void> write(String value) async {
    final index = writes.length;
    writes.add(value);
    if (index < errors.length) throw errors[index];
  }
}

final class _LocaleStorage implements LocalePreferenceStorage {
  _LocaleStorage(this.errors);

  final List<Object> errors;
  final List<String> writes = <String>[];

  @override
  Future<String?> read() async => null;

  @override
  Future<void> write(String value) async {
    final index = writes.length;
    writes.add(value);
    if (index < errors.length) throw errors[index];
  }
}
