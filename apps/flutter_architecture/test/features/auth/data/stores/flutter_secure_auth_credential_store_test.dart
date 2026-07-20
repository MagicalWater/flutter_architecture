import 'dart:convert';

import 'package:auth/auth.dart';
import 'package:flutter_architecture/features/auth/data/stores/flutter_secure_auth_credential_store.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    FlutterSecureStorage.setMockInitialValues(<String, String>{});
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
