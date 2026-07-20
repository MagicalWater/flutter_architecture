import 'dart:convert';

import 'package:auth/auth.dart';
import 'package:core/core.dart';
import 'package:flutter_architecture/features/auth/data/stores/flutter_secure_auth_credential_store.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_secure_storage_platform_interface/flutter_secure_storage_platform_interface.dart';
import 'package:flutter_test/flutter_test.dart';

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

  for (final entry in <String, String>{
    'non JSON': '{',
    'JSON non-map': '[]',
    'missing access token': jsonEncode(<String, Object?>{
      ..._validPayload,
      'accessToken': null,
    }),
    'missing refresh token': jsonEncode(<String, Object?>{
      ..._validPayload,
      'refreshToken': null,
    }),
    'missing userId': jsonEncode(<String, Object?>{
      ..._validPayload,
      'userId': null,
    }),
    'empty userId': jsonEncode(<String, Object?>{
      ..._validPayload,
      'userId': '',
    }),
    'blank userId': jsonEncode(<String, Object?>{
      ..._validPayload,
      'userId': '   ',
    }),
    'invalid access expiration': jsonEncode(<String, Object?>{
      ..._validPayload,
      'accessTokenExpiresAt': 'invalid',
    }),
    'invalid refresh expiration': jsonEncode(<String, Object?>{
      ..._validPayload,
      'refreshTokenExpiresAt': 123,
    }),
  }.entries) {
    test('readCredential returns corrupted for ${entry.key}', () async {
      FlutterSecureStorage.setMockInitialValues(<String, String>{
        'auth.tokens': entry.value,
      });
      final store = _createStore();

      expect(await store.readCredential(), isA<AuthCredentialReadCorrupted>());
    });
  }

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

  for (final userId in <String?>[null, '', '   ']) {
    test('writeCredential rejects invalid userId $userId', () async {
      final storage = const FlutterSecureStorage();
      final store = FlutterSecureAuthCredentialStore(storage);

      expect(
        () => store.writeCredential(
          StoredAuthTokens(
            accessToken: 'access-secret',
            refreshToken: 'refresh-secret',
            userId: userId,
          ),
        ),
        throwsArgumentError,
      );
      expect(await storage.readAll(), isEmpty);
    });
  }

  for (final tokens in <StoredAuthTokens>[
    const StoredAuthTokens(
      accessToken: '',
      refreshToken: 'refresh-secret',
      userId: 'user-001',
    ),
    const StoredAuthTokens(
      accessToken: 'access-secret',
      refreshToken: '',
      userId: 'user-001',
    ),
  ]) {
    test('writeCredential rejects an incomplete Token Pair', () async {
      final storage = const FlutterSecureStorage();
      final store = FlutterSecureAuthCredentialStore(storage);

      try {
        store.writeCredential(tokens);
        fail('Expected ArgumentError');
      } on ArgumentError catch (error) {
        expect(error.toString(), isNot(contains('access-secret')));
        expect(error.toString(), isNot(contains('refresh-secret')));
      }
      expect(await storage.readAll(), isEmpty);
    });
  }

  test('clearCredential is idempotent', () async {
    FlutterSecureStorage.setMockInitialValues(<String, String>{
      'auth.tokens': jsonEncode(_validPayload),
    });
    final store = _createStore();

    await store.clearCredential();
    await store.clearCredential();

    expect(await store.readCredential(), isA<AuthCredentialReadAbsent>());
  });

  test('result diagnostics do not expose credential sentinels', () async {
    FlutterSecureStorage.setMockInitialValues(<String, String>{
      'auth.tokens': jsonEncode(_validPayload),
    });
    final store = _createStore();

    final result = await store.readCredential();

    expect(result.toString(), isNot(contains('access-secret')));
    expect(result.toString(), isNot(contains('refresh-secret')));
  });

  for (final operation in _SecureOperation.values) {
    test(
      '${operation.name} PlatformException becomes local storage failure',
      () async {
        final originStack = StackTrace.current;
        final failure = PlatformException(
          code: 'secure_storage_unavailable',
          message: 'access-secret refresh-secret',
        );
        FlutterSecureStoragePlatform.instance =
            _ControlledSecureStoragePlatform(
              operation: operation,
              error: failure,
              stackTrace: originStack,
            );
        final store = _createStore();

        try {
          await _invoke(operation, store);
          fail('Expected AppException');
        } on AppException catch (error, stackTrace) {
          expect(error.kind, AppExceptionKind.localStorage);
          expect(error.cause, same(failure));
          expect(error.stackTrace, same(originStack));
          expect(stackTrace, same(originStack));
          expect(error.message, operation.expectedFailureMessage);
          expect(error.toString(), isNot(contains('access-secret')));
          expect(error.toString(), isNot(contains('refresh-secret')));
        }
      },
    );
  }

  test('MissingPluginException becomes local storage failure', () async {
    final originStack = StackTrace.current;
    final failure = MissingPluginException('secure storage unavailable');
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
    }
  });

  test('existing AppException is rethrown unchanged', () async {
    final failure = AppException(
      kind: AppExceptionKind.protocol,
      message: 'existing failure',
      stackTrace: StackTrace.current,
    );
    FlutterSecureStoragePlatform.instance = _ControlledSecureStoragePlatform(
      operation: _SecureOperation.write,
      error: failure,
      stackTrace: failure.stackTrace!,
    );
    final store = _createStore();

    try {
      await store.writeCredential(_tokens);
      fail('Expected existing AppException');
    } catch (error, stackTrace) {
      expect(error, same(failure));
      expect(stackTrace, same(failure.stackTrace));
    }
  });

  for (final failure in <Object>[
    StateError('programming error'),
    TypeError(),
  ]) {
    test('${failure.runtimeType} keeps original error and stack', () async {
      final originStack = StackTrace.current;
      FlutterSecureStoragePlatform.instance = _ControlledSecureStoragePlatform(
        operation: _SecureOperation.delete,
        error: failure,
        stackTrace: originStack,
      );
      final store = _createStore();

      try {
        await store.clearCredential();
        fail('Expected original error');
      } catch (error, stackTrace) {
        expect(error, same(failure));
        expect(stackTrace, same(originStack));
      }
    });
  }
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

const _tokens = StoredAuthTokens(
  accessToken: 'access-secret',
  refreshToken: 'refresh-secret',
  userId: 'user-001',
);

enum _SecureOperation { read, write, delete }

extension on _SecureOperation {
  String get expectedFailureMessage => switch (this) {
    _SecureOperation.read => '讀取 Secure Auth credential 失敗',
    _SecureOperation.write => '儲存 Secure Auth credential 失敗',
    _SecureOperation.delete => '清除 Secure Auth credential 失敗',
  };
}

Future<void> _invoke(
  _SecureOperation operation,
  FlutterSecureAuthCredentialStore store,
) async {
  switch (operation) {
    case _SecureOperation.read:
      await store.readCredential();
    case _SecureOperation.write:
      await store.writeCredential(_tokens);
    case _SecureOperation.delete:
      await store.clearCredential();
  }
}

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
