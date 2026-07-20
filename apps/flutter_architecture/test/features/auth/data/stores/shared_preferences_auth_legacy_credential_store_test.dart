import 'dart:convert';

import 'package:auth/auth.dart';
import 'package:core/core.dart';
import 'package:flutter_architecture/features/auth/data/stores/shared_preferences_auth_legacy_credential_store.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_platform_interface.dart';

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

  test(
    'clearLegacyCredential preserves unknown error over expected failure',
    () async {
      final unknown = StateError('unexpected remove failure');
      final platform = _ControlledPreferencesPlatform(
        removeBehaviors: <String, Object?>{
          'flutter.auth.tokens': false,
          'flutter.auth.accessToken': unknown,
        },
      );
      SharedPreferences.resetStatic();
      SharedPreferencesStorePlatform.instance = platform;
      final store = SharedPreferencesAuthLegacyCredentialStore(
        await SharedPreferences.getInstance(),
      );

      await expectLater(store.clearLegacyCredential(), throwsA(same(unknown)));
      expect(
        platform.removedKeys,
        containsAll(<String>[
          'flutter.auth.tokens',
          'flutter.auth.accessToken',
        ]),
      );
    },
  );
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

final class _ControlledPreferencesPlatform
    extends SharedPreferencesStorePlatform {
  _ControlledPreferencesPlatform({required this.removeBehaviors});

  final Map<String, Object?> removeBehaviors;
  final List<String> removedKeys = <String>[];

  @override
  Future<bool> clear() async => true;

  @override
  Future<Map<String, Object>> getAll() async => <String, Object>{};

  @override
  Future<bool> remove(String key) async {
    removedKeys.add(key);
    final behavior = removeBehaviors[key];
    if (behavior is Object && behavior is! bool) {
      throw behavior;
    }
    return behavior as bool? ?? true;
  }

  @override
  Future<bool> setValue(String valueType, String key, Object value) async {
    throw const AppException(
      kind: AppExceptionKind.localStorage,
      message: 'unexpected setValue call',
    );
  }
}
