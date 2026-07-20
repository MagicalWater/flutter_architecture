import 'dart:convert';

import 'package:auth/auth.dart';
import 'package:core/core.dart';
import 'package:flutter_architecture/features/auth/data/stores/shared_preferences_auth_credential_store.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_platform_interface.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  tearDown(SharedPreferences.resetStatic);

  test(
    'readCredential returns absent when auth.tokens does not exist',
    () async {
      final store = await _createStore();

      expect(await store.readCredential(), isA<AuthCredentialReadAbsent>());
    },
  );

  test('readCredential returns present for a valid token pair', () async {
    final store = await _createStore(
      values: <String, Object>{'auth.tokens': jsonEncode(_validPayload)},
    );

    final result = await store.readCredential();

    expect(result, isA<AuthCredentialReadPresent>());
    final tokens = (result as AuthCredentialReadPresent).tokens;
    expect(tokens.accessToken, 'access-secret');
    expect(tokens.refreshToken, 'refresh-secret');
    expect(tokens.userId, 'user-001');
  });

  for (final entry in <String, Object>{
    'non JSON': '{',
    'non map': '[]',
    'missing token': jsonEncode(<String, Object?>{'accessToken': 'access'}),
    'invalid expiration': jsonEncode(<String, Object?>{
      ..._validPayload,
      'refreshTokenExpiresAt': 'invalid',
    }),
  }.entries) {
    test('readCredential returns corrupted for ${entry.key}', () async {
      final store = await _createStore(
        values: <String, Object>{'auth.tokens': entry.value},
      );

      expect(await store.readCredential(), isA<AuthCredentialReadCorrupted>());
    });
  }

  test('writeCredential persists one safe logical payload', () async {
    final store = await _createStore();
    const tokens = StoredAuthTokens(
      accessToken: 'access-secret',
      refreshToken: 'refresh-secret',
      userId: 'user-001',
    );

    await store.writeCredential(tokens);

    final result = await store.readCredential() as AuthCredentialReadPresent;
    expect(result.tokens.accessToken, tokens.accessToken);
    expect(result.tokens.refreshToken, tokens.refreshToken);
    expect(result.tokens.userId, tokens.userId);
  });

  test('clearCredential is idempotent', () async {
    final store = await _createStore(
      values: <String, Object>{'auth.tokens': jsonEncode(_validPayload)},
    );

    await store.clearCredential();
    await store.clearCredential();

    expect(await store.readCredential(), isA<AuthCredentialReadAbsent>());
  });

  test('write false result becomes typed local storage exception', () async {
    final platform = _ControlledPreferencesPlatform(setResult: false);
    final store = await _createStore(platform: platform);

    await expectLater(
      store.writeCredential(
        const StoredAuthTokens(
          accessToken: 'access-secret',
          refreshToken: 'refresh-secret',
          userId: 'user-001',
        ),
      ),
      throwsA(
        isA<AppException>().having(
          (error) => error.kind,
          'kind',
          AppExceptionKind.localStorage,
        ),
      ),
    );
  });

  test('plugin error preserves cause and stack without secrets', () async {
    final failure = StateError('platform unavailable');
    final platform = _ControlledPreferencesPlatform(setError: failure);
    final store = await _createStore(platform: platform);

    try {
      await store.writeCredential(
        const StoredAuthTokens(
          accessToken: 'access-secret',
          refreshToken: 'refresh-secret',
          userId: 'user-001',
        ),
      );
      fail('Expected AppException');
    } on AppException catch (error) {
      expect(error.kind, AppExceptionKind.localStorage);
      expect(error.cause, same(failure));
      expect(error.stackTrace, isNotNull);
      expect(error.toString(), isNot(contains('access-secret')));
      expect(error.toString(), isNot(contains('refresh-secret')));
    }
  });
}

const _validPayload = <String, Object?>{
  'accessToken': 'access-secret',
  'refreshToken': 'refresh-secret',
  'userId': 'user-001',
};

Future<SharedPreferencesAuthCredentialStore> _createStore({
  Map<String, Object> values = const <String, Object>{},
  SharedPreferencesStorePlatform? platform,
}) async {
  SharedPreferences.resetStatic();
  if (platform == null) {
    SharedPreferences.setMockInitialValues(values);
  } else {
    SharedPreferencesStorePlatform.instance = platform;
  }
  return SharedPreferencesAuthCredentialStore(
    await SharedPreferences.getInstance(),
  );
}

final class _ControlledPreferencesPlatform
    extends SharedPreferencesStorePlatform {
  _ControlledPreferencesPlatform({this.setResult = true, this.setError});

  final bool setResult;
  final Object? setError;
  final Map<String, Object> _values = <String, Object>{};

  @override
  Future<bool> clear() async {
    _values.clear();
    return true;
  }

  @override
  Future<Map<String, Object>> getAll() async => Map.of(_values);

  @override
  Future<bool> remove(String key) async {
    _values.remove(key);
    return true;
  }

  @override
  Future<bool> setValue(String valueType, String key, Object value) async {
    final error = setError;
    if (error != null) throw error;
    if (setResult) _values[key] = value;
    return setResult;
  }
}
