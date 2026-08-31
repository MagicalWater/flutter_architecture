import 'dart:async';

import 'package:auth/auth.dart';
import 'package:core/core.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// SharedPreferences adapter，序列化 local unlock writes 以維持呼叫順序。
final class SharedPreferencesLocalUnlockPreferenceStore
    implements LocalUnlockPreferenceStore {
  SharedPreferencesLocalUnlockPreferenceStore(
    this._preferences, {
    LocalUnlockPreferenceCodec codec = const LocalUnlockPreferenceCodec(),
  }) : _codec = codec;

  static const key = 'auth.localUnlock.preference';

  final SharedPreferences _preferences;
  final LocalUnlockPreferenceCodec _codec;
  // SharedPreferences write / clear 必須保持呼叫順序；否則快速 enable→disable
  // 可能因 platform Future 完成順序不同而讓舊值最後落盤。
  Future<void> _tail = Future<void>.value();

  @override
  Future<LocalUnlockPreferenceReadResult> read() async {
    try {
      final raw = _preferences.get(key);
      if (raw == null) return const LocalUnlockPreferenceReadResult.absent();
      if (raw is! String) {
        return const LocalUnlockPreferenceReadResult.corrupted();
      }
      try {
        return LocalUnlockPreferenceReadResult.present(_codec.decode(raw));
      } on FormatException {
        return const LocalUnlockPreferenceReadResult.corrupted();
      }
    } on PlatformException catch (error, stackTrace) {
      Error.throwWithStackTrace(
        AppException(
          kind: AppExceptionKind.localStorage,
          message: 'Unable to read local unlock preference.',
          diagnosticCode: 'local_unlock_preference_read_failed',
          cause: error,
          stackTrace: stackTrace,
        ),
        stackTrace,
      );
    }
  }

  @override
  Future<void> write(LocalUnlockPreference preference) {
    return _enqueue(() async {
      try {
        final saved = await _preferences.setString(
          key,
          _codec.encode(preference),
        );
        if (!saved) {
          throw const AppException(
            kind: AppExceptionKind.localStorage,
            message: 'Unable to write local unlock preference.',
            diagnosticCode: 'local_unlock_preference_write_failed',
          );
        }
      } on AppException {
        rethrow;
      } on PlatformException catch (error, stackTrace) {
        Error.throwWithStackTrace(
          AppException(
            kind: AppExceptionKind.localStorage,
            message: 'Unable to write local unlock preference.',
            diagnosticCode: 'local_unlock_preference_write_failed',
            cause: error,
            stackTrace: stackTrace,
          ),
          stackTrace,
        );
      }
    });
  }

  @override
  Future<void> clear() {
    return _enqueue(() async {
      try {
        final removed = await _preferences.remove(key);
        if (!removed && _preferences.containsKey(key)) {
          throw const AppException(
            kind: AppExceptionKind.localStorage,
            message: 'Unable to clear local unlock preference.',
            diagnosticCode: 'local_unlock_preference_clear_failed',
          );
        }
      } on AppException {
        rethrow;
      } on PlatformException catch (error, stackTrace) {
        Error.throwWithStackTrace(
          AppException(
            kind: AppExceptionKind.localStorage,
            message: 'Unable to clear local unlock preference.',
            diagnosticCode: 'local_unlock_preference_clear_failed',
            cause: error,
            stackTrace: stackTrace,
          ),
          stackTrace,
        );
      }
    });
  }

  Future<void> _enqueue(Future<void> Function() operation) {
    final completer = Completer<void>();
    _tail = _tail.then((_) async {
      try {
        await operation();
        completer.complete();
      } catch (error, stackTrace) {
        completer.completeError(error, stackTrace);
      }
    });
    return completer.future;
  }
}
