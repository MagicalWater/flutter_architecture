import 'package:flutter_architecture/app/error_reporting/error_report.dart';
import 'package:flutter_architecture/app/localization/locale_bootstrap.dart';
import 'package:flutter_architecture/app/error_reporting/error_reporter.dart';
import 'package:flutter_architecture/app/localization/locale_preference.dart';
import 'package:flutter_architecture/app/localization/locale_preference_store.dart';
import 'package:flutter_architecture/app/preferences/preference_exception.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const codec = LocalePreferenceCodec();

  test('restoreLocaleController restores persisted preference', () async {
    final storage = _RecordingLocaleStorage(
      raw: codec.encode(AppLocalePreference.traditionalChinese),
    );

    final controller = await restoreLocaleController(
      storage: storage,
      errorReporter: const NoopErrorReporter(),
    );

    expect(controller.preference, AppLocalePreference.traditionalChinese);
    expect(controller.diagnostic, isNull);
    expect(storage.writeCount, 0);
  });

  test(
    'restoreLocaleController falls back without rewriting invalid data',
    () async {
      final storage = _RecordingLocaleStorage(raw: 'invalid-json');

      final controller = await restoreLocaleController(
        storage: storage,
        errorReporter: const NoopErrorReporter(),
      );

      expect(controller.preference, AppLocalePreference.system);
      expect(
        controller.diagnostic?.error,
        isA<PreferenceCorruptionException>(),
      );
      expect(storage.writeCount, 0);
    },
  );

  test('restoreLocaleController keeps read failure as diagnostic', () async {
    final storage = _RecordingLocaleStorage(
      readError: const PreferenceStorageException.read(
        preference: PreferenceKind.locale,
      ),
    );

    final controller = await restoreLocaleController(
      storage: storage,
      errorReporter: const NoopErrorReporter(),
    );

    expect(controller.preference, AppLocalePreference.system);
    expect(controller.diagnostic?.error, isA<PreferenceStorageException>());
    expect(storage.writeCount, 0);
  });

  test('restore reporter failure does not block fallback controller', () async {
    final storage = _RecordingLocaleStorage(
      readError: const PreferenceStorageException.read(
        preference: PreferenceKind.locale,
      ),
    );

    final controller = await restoreLocaleController(
      storage: storage,
      errorReporter: const _ThrowingErrorReporter(),
    );

    expect(controller.preference, AppLocalePreference.system);
    expect(controller.diagnostic?.error, isA<PreferenceStorageException>());
  });
}

final class _ThrowingErrorReporter implements ErrorReporter {
  const _ThrowingErrorReporter();

  @override
  void report(ErrorReport report) {
    throw StateError('reporter failed');
  }
}

final class _RecordingLocaleStorage implements LocalePreferenceStorage {
  _RecordingLocaleStorage({this.raw, this.readError});

  final String? raw;
  final Object? readError;
  int writeCount = 0;

  @override
  Future<String?> read() async {
    if (readError case final error?) throw error;
    return raw;
  }

  @override
  Future<void> write(String value) async {
    writeCount += 1;
  }
}
