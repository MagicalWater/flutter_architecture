import 'dart:convert';

import 'package:auth/auth.dart';
import 'package:flutter_architecture/features/auth/data/stores/shared_preferences_auth_legacy_credential_store.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  tearDown(SharedPreferences.resetStatic);

  test('reads a complete legacy token pair', () async {
    final store = await _createStore(<String, Object>{
      'auth.tokens': jsonEncode(<String, Object?>{
        'accessToken': 'access-secret',
        'refreshToken': 'refresh-secret',
        'userId': 'user-001',
      }),
    });

    final result = await store.readLegacyCredential();

    expect(result, isA<AuthCredentialReadPresent>());
    expect((result as AuthCredentialReadPresent).tokens.userId, 'user-001');
  });

  test('returns corrupted for invalid legacy payload', () async {
    final store = await _createStore(<String, Object>{'auth.tokens': '{'});

    expect(
      await store.readLegacyCredential(),
      isA<AuthCredentialReadCorrupted>(),
    );
  });

  test(
    'single access-token legacy key is cleared and cannot restore',
    () async {
      final preferences = await _createPreferences(<String, Object>{
        'auth.accessToken': 'legacy-access-secret',
      });
      final store = SharedPreferencesAuthLegacyCredentialStore(preferences);

      expect(
        await store.readLegacyCredential(),
        isA<AuthCredentialReadAbsent>(),
      );
      expect(preferences.containsKey('auth.accessToken'), isFalse);
    },
  );

  test('clearLegacyCredential clears both keys and is idempotent', () async {
    final preferences = await _createPreferences(<String, Object>{
      'auth.tokens': jsonEncode(<String, Object?>{
        'accessToken': 'access-secret',
        'refreshToken': 'refresh-secret',
        'userId': 'user-001',
      }),
      'auth.accessToken': 'legacy-access-secret',
    });
    final store = SharedPreferencesAuthLegacyCredentialStore(preferences);

    await store.clearLegacyCredential();
    await store.clearLegacyCredential();

    expect(preferences.containsKey('auth.tokens'), isFalse);
    expect(preferences.containsKey('auth.accessToken'), isFalse);
  });
}

Future<SharedPreferencesAuthLegacyCredentialStore> _createStore(
  Map<String, Object> values,
) async {
  return SharedPreferencesAuthLegacyCredentialStore(
    await _createPreferences(values),
  );
}

Future<SharedPreferences> _createPreferences(Map<String, Object> values) async {
  SharedPreferences.resetStatic();
  SharedPreferences.setMockInitialValues(values);
  return SharedPreferences.getInstance();
}
