import 'package:flutter_architecture/app/localization/locale_bootstrap.dart';
import 'package:flutter_architecture/app/localization/locale_preference.dart';
import 'package:flutter_architecture/app/localization/locale_preference_store.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const codec = LocalePreferenceCodec();

  test('restoreLocaleController restores persisted preference', () async {
    final storage = _RecordingLocaleStorage(
      raw: codec.encode(AppLocalePreference.traditionalChinese),
    );

    final controller = await restoreLocaleController(storage: storage);

    expect(controller.preference, AppLocalePreference.traditionalChinese);
    expect(controller.diagnostic, isNull);
    expect(storage.writeCount, 0);
  });

  test(
    'restoreLocaleController falls back without rewriting invalid data',
    () async {
      final storage = _RecordingLocaleStorage(raw: 'invalid-json');

      final controller = await restoreLocaleController(storage: storage);

      expect(controller.preference, AppLocalePreference.system);
      expect(controller.diagnostic, isNull);
      expect(storage.writeCount, 0);
    },
  );

  test('restoreLocaleController keeps read failure as diagnostic', () async {
    final storage = _RecordingLocaleStorage(
      readError: StateError('read failed'),
    );

    final controller = await restoreLocaleController(storage: storage);

    expect(controller.preference, AppLocalePreference.system);
    expect(controller.diagnostic, isA<StateError>());
    expect(storage.writeCount, 0);
  });
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
