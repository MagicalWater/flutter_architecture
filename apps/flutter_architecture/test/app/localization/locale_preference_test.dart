import 'dart:async';

import 'package:flutter_architecture/app/localization/app_locale_resolution.dart';
import 'package:flutter_architecture/app/localization/locale_controller.dart';
import 'package:flutter_architecture/app/localization/locale_preference.dart';
import 'package:flutter_architecture/app/localization/locale_preference_store.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const codec = LocalePreferenceCodec();

  test('LocalePreferenceCodec round-trips all preferences', () {
    for (final preference in AppLocalePreference.values) {
      expect(codec.decode(codec.encode(preference)), preference);
    }
  });

  test('LocalePreferenceCodec falls back to system for invalid payloads', () {
    for (final raw in <String?>[
      null,
      '',
      '{}',
      '{"version":2,"locale":"en"}',
      '{"version":1,"locale":"unknown"}',
      'not-json',
    ]) {
      expect(codec.decode(raw), AppLocalePreference.system);
    }
  });

  test('preference maps system to null and explicit values to locales', () {
    expect(AppLocalePreference.system.materialLocale, isNull);
    expect(AppLocalePreference.english.materialLocale, appEnglishLocale);
    expect(
      AppLocalePreference.traditionalChinese.materialLocale,
      appTraditionalChineseLocale,
    );
  });

  test('store exposes read failures as non-blocking diagnostic', () async {
    final result = await LocalePreferenceStore(
      _MemoryLocaleStorage(readError: StateError('read failed')),
      codec,
    ).restore();

    expect(result.preference, AppLocalePreference.system);
    expect(result.diagnostic, isA<StateError>());
  });

  test('controller updates runtime before persistence completes', () async {
    final storage = _MemoryLocaleStorage(blockWrites: true);
    final controller = LocaleController(
      store: LocalePreferenceStore(storage, codec),
      initialPreference: AppLocalePreference.system,
    );

    controller.select(AppLocalePreference.traditionalChinese);

    expect(controller.preference, AppLocalePreference.traditionalChinese);
    expect(controller.locale, appTraditionalChineseLocale);
    expect(storage.values, isEmpty);

    await storage.waitForPendingWrite();
    storage.releaseNextWrite();
    await controller.waitForPendingWrites();
    expect(
      codec.decode(storage.values.single),
      AppLocalePreference.traditionalChinese,
    );
  });

  test('serialized writes preserve latest preference', () async {
    final storage = _MemoryLocaleStorage(blockWrites: true);
    final controller = LocaleController(
      store: LocalePreferenceStore(storage, codec),
      initialPreference: AppLocalePreference.system,
    );

    controller.select(AppLocalePreference.english);
    controller.select(AppLocalePreference.traditionalChinese);

    await storage.waitForPendingWrite();
    storage.releaseNextWrite();
    await storage.waitForPendingWrite();
    storage.releaseNextWrite();
    await controller.waitForPendingWrites();

    expect(storage.values.map(codec.decode), <AppLocalePreference>[
      AppLocalePreference.english,
      AppLocalePreference.traditionalChinese,
    ]);
    expect(controller.preference, AppLocalePreference.traditionalChinese);
  });

  test('a failed write does not block a newer preference', () async {
    final storage = _MemoryLocaleStorage(failFirstWrite: true);
    final controller = LocaleController(
      store: LocalePreferenceStore(storage, codec),
      initialPreference: AppLocalePreference.system,
    );

    controller.select(AppLocalePreference.english);
    await controller.waitForPendingWrites();
    expect(controller.diagnostic, isA<StateError>());

    controller.select(AppLocalePreference.traditionalChinese);
    await controller.waitForPendingWrites();

    expect(controller.preference, AppLocalePreference.traditionalChinese);
    expect(controller.diagnostic, isNull);
    expect(
      codec.decode(storage.values.single),
      AppLocalePreference.traditionalChinese,
    );
  });
}

final class _MemoryLocaleStorage implements LocalePreferenceStorage {
  _MemoryLocaleStorage({
    this.readError,
    this.blockWrites = false,
    this.failFirstWrite = false,
  });

  final Object? readError;
  final bool blockWrites;
  final bool failFirstWrite;
  final List<String> values = <String>[];
  final List<Completer<void>> _pendingWrites = <Completer<void>>[];
  Completer<void>? _pendingWriteSignal;
  int _writeCount = 0;

  @override
  Future<String?> read() async {
    if (readError case final error?) throw error;
    return values.lastOrNull;
  }

  @override
  Future<void> write(String value) async {
    _writeCount += 1;
    if (failFirstWrite && _writeCount == 1) {
      throw StateError('write failed');
    }
    if (blockWrites) {
      final completer = Completer<void>();
      _pendingWrites.add(completer);
      _pendingWriteSignal?.complete();
      _pendingWriteSignal = null;
      await completer.future;
    }
    values.add(value);
  }

  void releaseNextWrite() {
    _pendingWrites.removeAt(0).complete();
  }

  Future<void> waitForPendingWrite() {
    if (_pendingWrites.isNotEmpty) return Future<void>.value();
    return (_pendingWriteSignal ??= Completer<void>()).future;
  }
}
