import 'package:auth/auth.dart';
import 'package:flutter_architecture/features/auth/data/local_unlock/shared_preferences_local_unlock_preference_store.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() => SharedPreferences.setMockInitialValues(<String, Object>{}));

  test('absent preference defaults to typed absent', () async {
    final store = await _createStore();
    expect(await store.read(), isA<LocalUnlockPreferenceReadAbsent>());
  });

  test('enabled preference survives a new store instance', () async {
    final first = await _createStore();
    await first.write(LocalUnlockPreference.enabled);

    final restarted = SharedPreferencesLocalUnlockPreferenceStore(
      await SharedPreferences.getInstance(),
    );
    final result = await restarted.read() as LocalUnlockPreferenceReadPresent;
    expect(result.preference, LocalUnlockPreference.enabled);
  });

  test('corrupted payload fails closed without becoming absent', () async {
    SharedPreferences.setMockInitialValues(<String, Object>{
      SharedPreferencesLocalUnlockPreferenceStore.key: '{broken',
    });
    final store = await _createStore();

    expect(await store.read(), isA<LocalUnlockPreferenceReadCorrupted>());
  });

  test('serialized writes preserve latest preference', () async {
    final store = await _createStore();

    await Future.wait(<Future<void>>[
      store.write(LocalUnlockPreference.enabled),
      store.write(LocalUnlockPreference.disabled),
      store.write(LocalUnlockPreference.enabled),
    ]);

    final result = await store.read() as LocalUnlockPreferenceReadPresent;
    expect(result.preference, LocalUnlockPreference.enabled);
  });

  test('clear removes preference instead of writing identity data', () async {
    final store = await _createStore();
    await store.write(LocalUnlockPreference.enabled);
    await store.clear();

    expect(await store.read(), isA<LocalUnlockPreferenceReadAbsent>());
    expect(
      (await SharedPreferences.getInstance()).getKeys(),
      isNot(contains(anyOf('userId', 'biometricType', 'enrollmentId'))),
    );
  });
}

Future<SharedPreferencesLocalUnlockPreferenceStore> _createStore() async =>
    SharedPreferencesLocalUnlockPreferenceStore(
      await SharedPreferences.getInstance(),
    );
