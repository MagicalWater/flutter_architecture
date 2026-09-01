import 'dart:convert';

import 'package:auth/auth_infrastructure.dart';
import 'package:core/core.dart';
import 'package:flutter_architecture/features/auth/data/stores/flutter_secure_auth_credential_store.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_secure_storage_platform_interface/flutter_secure_storage_platform_interface.dart';
import 'package:flutter_test/flutter_test.dart';

const _accessSentinel = 'M19_ACCESS_SECRET_7f4a';
const _refreshSentinel = 'M19_REFRESH_SECRET_2c91';
const _passwordSentinel = 'M19_PASSWORD_SECRET_11de';
const _pluginSentinel = 'M19_PLUGIN_SECRET_a63b';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final originalPlatform = FlutterSecureStoragePlatform.instance;

  setUp(() {
    FlutterSecureStorage.setMockInitialValues(<String, String>{});
  });

  tearDown(() {
    FlutterSecureStoragePlatform.instance = originalPlatform;
  });

  test(
    'readCredential returns absent when secure payload does not exist',
    () async {
      final store = _createStore();

      expect(await store.readCredential(), isA<AuthCredentialReadAbsent>());
    },
  );

  test('valid Token Pair round-trips as one logical payload', () async {
    final store = _createStore();
    final accessExpiresAt = DateTime.utc(2026, 7, 20, 17);
    final refreshExpiresAt = DateTime.utc(2026, 8, 20, 17);
    final tokens = StoredAuthTokens(
      accessToken: 'access-secret',
      refreshToken: 'refresh-secret',
      userId: 'user-001',
      accessTokenExpiresAt: accessExpiresAt,
      refreshTokenExpiresAt: refreshExpiresAt,
    );

    await store.writeCredential(tokens);

    final result = await store.readCredential() as AuthCredentialReadPresent;
    expect(result.tokens.accessToken, tokens.accessToken);
    expect(result.tokens.refreshToken, tokens.refreshToken);
    expect(result.tokens.userId, tokens.userId);
    expect(result.tokens.accessTokenExpiresAt, accessExpiresAt);
    expect(result.tokens.refreshTokenExpiresAt, refreshExpiresAt);
  });

  test('malformed secure payload fails closed as corrupted', () async {
    FlutterSecureStorage.setMockInitialValues(<String, String>{
      'auth.tokens': '{',
    });

    expect(
      await _createStore().readCredential(),
      isA<AuthCredentialReadCorrupted>(),
    );
  });

  test('writeCredential stores exactly one secure logical payload', () async {
    final storage = const FlutterSecureStorage();
    final store = FlutterSecureAuthCredentialStore(storage);

    await store.writeCredential(
      const StoredAuthTokens(
        accessToken: 'access-secret',
        refreshToken: 'refresh-secret',
        userId: 'user-001',
      ),
    );

    final all = await storage.readAll();
    expect(all.keys, <String>['auth.tokens']);
    expect(all['auth.tokens'], isNotNull);
    expect(jsonDecode(all['auth.tokens']!), isA<Map<String, dynamic>>());
  });

  test('writeCredential rejects incomplete credential without persistence', () async {
    final storage = const FlutterSecureStorage();
    final store = FlutterSecureAuthCredentialStore(storage);

    expect(
      () => store.writeCredential(
        const StoredAuthTokens(
          accessToken: '',
          refreshToken: 'refresh-secret',
          userId: 'user-001',
        ),
      ),
      throwsArgumentError,
    );
    expect(await storage.readAll(), isEmpty);
  });

  test('clearCredential is idempotent', () async {
    FlutterSecureStorage.setMockInitialValues(<String, String>{
      'auth.tokens': jsonEncode(_validPayload),
    });
    final store = _createStore();

    await store.clearCredential();
    await store.clearCredential();

    expect(await store.readCredential(), isA<AuthCredentialReadAbsent>());
  });

  test('secure adapter result hides unified credential sentinels', () async {
    FlutterSecureStorage.setMockInitialValues(<String, String>{
      'auth.tokens': jsonEncode(<String, Object?>{
        'accessToken': _accessSentinel,
        'refreshToken': _refreshSentinel,
        'userId': _passwordSentinel,
        'accessTokenExpiresAt': null,
        'refreshTokenExpiresAt': null,
      }),
    });
    final result = await _createStore().readCredential();

    _expectNoCredentialSentinel(result.toString());
  });

  test('mapped secure error hides unified credential sentinels', () async {
    final originStack = StackTrace.fromString(_pluginSentinel);
    final failure = PlatformException(
      code: 'secure_storage_unavailable',
      message:
          '$_pluginSentinel $_accessSentinel $_refreshSentinel $_passwordSentinel',
    );
    FlutterSecureStoragePlatform.instance = _ControlledSecureStoragePlatform(
      operation: _SecureOperation.read,
      error: failure,
      stackTrace: originStack,
    );

    try {
      await _createStore().readCredential();
      fail('Expected AppException');
    } on AppException catch (error) {
      _expectNoCredentialSentinel(error.toString());
    }
  });

  test('PlatformException becomes redacted local storage failure', () async {
    final originStack = StackTrace.current;
    final failure = PlatformException(
      code: 'secure_storage_unavailable',
      message: 'access-secret refresh-secret',
    );
    FlutterSecureStoragePlatform.instance = _ControlledSecureStoragePlatform(
      operation: _SecureOperation.read,
      error: failure,
      stackTrace: originStack,
    );
    final store = _createStore();

    try {
      await store.readCredential();
      fail('Expected AppException');
    } on AppException catch (error, stackTrace) {
      expect(error.kind, AppExceptionKind.localStorage);
      expect(error.cause, same(failure));
      expect(error.stackTrace, same(originStack));
      expect(stackTrace, same(originStack));
      expect(error.message, '讀取 Secure Auth credential 失敗');
      expect(error.toString(), isNot(contains('access-secret')));
      expect(error.toString(), isNot(contains('refresh-secret')));
    }
  });
}

void _expectNoCredentialSentinel(String text) {
  expect(text, isNot(contains(_accessSentinel)));
  expect(text, isNot(contains(_refreshSentinel)));
  expect(text, isNot(contains(_passwordSentinel)));
  expect(text, isNot(contains(_pluginSentinel)));
}

const _validPayload = <String, Object?>{
  'accessToken': 'access-secret',
  'refreshToken': 'refresh-secret',
  'userId': 'user-001',
  'accessTokenExpiresAt': '2026-07-20T17:00:00.000Z',
  'refreshTokenExpiresAt': '2026-08-20T17:00:00.000Z',
};

FlutterSecureAuthCredentialStore _createStore() =>
    const FlutterSecureAuthCredentialStore(FlutterSecureStorage());

enum _SecureOperation { read, write, delete }

final class _ControlledSecureStoragePlatform
    extends FlutterSecureStoragePlatform {
  _ControlledSecureStoragePlatform({
    required this.operation,
    required this.error,
    required this.stackTrace,
  });

  final _SecureOperation operation;
  final Object error;
  final StackTrace stackTrace;

  Never _throwIf(_SecureOperation current) {
    if (operation != current) {
      throw StateError('Unexpected operation: $current');
    }
    Error.throwWithStackTrace(error, stackTrace);
  }

  @override
  Future<void> delete({
    required String key,
    required Map<String, String> options,
  }) async => _throwIf(_SecureOperation.delete);

  @override
  Future<void> deleteAll({required Map<String, String> options}) async {}

  @override
  Future<String?> read({
    required String key,
    required Map<String, String> options,
  }) async => _throwIf(_SecureOperation.read);

  @override
  Future<Map<String, String>> readAll({
    required Map<String, String> options,
  }) async => const <String, String>{};

  @override
  Future<void> write({
    required String key,
    required String value,
    required Map<String, String> options,
  }) async => _throwIf(_SecureOperation.write);

  @override
  Future<bool> containsKey({
    required String key,
    required Map<String, String> options,
  }) async => false;
}
