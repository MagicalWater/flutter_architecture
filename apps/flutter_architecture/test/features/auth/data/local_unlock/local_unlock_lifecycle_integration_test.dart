import 'package:auth/auth.dart';
import 'package:flutter_architecture/app/config/api_config.dart';
import 'package:flutter_architecture/app/config/app_config.dart';
import 'package:flutter_architecture/app/config/app_environment.dart';
import 'package:flutter_architecture/app/di/injection.dart';
import 'package:flutter_architecture/app/error_reporting/error_reporter.dart';
import 'package:core/core.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  setUp(() {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    FlutterSecureStorage.setMockInitialValues(<String, String>{});
  });

  tearDown(() => getIt.reset());

  test('restore without credential clears stale enabled preference', () async {
    await _configure();
    final store = getIt<LocalUnlockPreferenceStore>();
    await store.write(LocalUnlockPreference.enabled);

    final result = await getIt<AuthRepository>().restoreSession();

    expect(result, isA<Success<AuthUser?>>());
    expect(await store.read(), isA<LocalUnlockPreferenceReadAbsent>());
    expect(getIt<SessionManager>().currentSession, isNull);
  });

  test('logout clears local unlock preference with auth stores', () async {
    await _configure();
    final repository = getIt<AuthRepository>();
    final store = getIt<LocalUnlockPreferenceStore>();
    final login = await repository.login(account: 'demo', password: 'password');
    expect(login, isA<Success<AuthLoginResult>>());
    await store.write(LocalUnlockPreference.enabled);

    final result = await repository.logout();

    expect(result, isA<Success<void>>());
    expect(await store.read(), isA<LocalUnlockPreferenceReadAbsent>());
    expect(getIt<SessionManager>().currentSession, isNull);
  });
}

Future<void> _configure() {
  return configureDependencies(
    AppConfig(
      environment: AppEnvironment.development,
      api: ApiConfig(
        mode: ApiMode.mock,
        baseUri: Uri.parse('https://mock.local'),
      ),
    ),
    const NoopErrorReporter(),
  );
}
