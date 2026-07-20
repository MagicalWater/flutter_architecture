import 'package:api_client/api_client.dart';
import 'package:auth/auth.dart';
import 'package:core/core.dart';
import 'package:flutter_architecture/app/config/api_config.dart';
import 'package:flutter_architecture/app/config/app_config.dart';
import 'package:flutter_architecture/app/config/app_environment.dart';
import 'package:flutter_architecture/app/di/injection.dart';
import 'package:flutter_architecture/app/error_reporting/error_reporter.dart';
import 'package:flutter_architecture/features/auth/data/stores/shared_preferences_auth_credential_store.dart';
import 'package:flutter_architecture/features/auth/data/stores/shared_preferences_auth_legacy_credential_store.dart';
import 'package:flutter_architecture/features/auth/data/stores/sqflite_auth_user_store.dart';
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
  });

  tearDown(() async {
    await getIt.reset();
  });

  test('Auth persistence contracts由App adapters以singleton組裝', () async {
    final config = AppConfig(
      environment: AppEnvironment.development,
      api: ApiConfig(
        mode: ApiMode.mock,
        baseUri: Uri.parse('https://mock.local'),
      ),
    );

    await configureDependencies(config, const NoopErrorReporter());

    expect(
      getIt<AuthCredentialStore>(),
      isA<SharedPreferencesAuthCredentialStore>(),
    );
    expect(
      getIt<AuthLegacyCredentialStore>(),
      isA<SharedPreferencesAuthLegacyCredentialStore>(),
    );
    expect(getIt<AuthUserStore>(), isA<SqfliteAuthUserStore>());

    expect(
      identical(getIt<AuthCredentialStore>(), getIt<AuthCredentialStore>()),
      isTrue,
    );
    expect(
      identical(
        getIt<AuthLegacyCredentialStore>(),
        getIt<AuthLegacyCredentialStore>(),
      ),
      isTrue,
    );
    expect(identical(getIt<AuthUserStore>(), getIt<AuthUserStore>()), isTrue);

    expect(getIt<AuthRepository>(), isA<AuthRepositoryImpl>());
    expect(getIt<AuthRefresher>(), isA<AuthSessionRefresher>());

    final credentialStore = getIt<AuthCredentialStore>();
    final userStore = getIt<AuthUserStore>();
    await credentialStore.writeCredential(
      const StoredAuthTokens(
        accessToken: 'shared-access-token',
        refreshToken: 'shared-refresh-token',
        userId: 'shared-user',
      ),
    );
    await userStore.writeUser(
      const AuthUser(id: 'shared-user', name: 'Shared User'),
    );

    final restoreResult = await getIt<AuthRepository>().restoreSession();
    expect(restoreResult, isA<Success<AuthUser?>>());
    expect(
      getIt<SessionManager>().currentSession?.accessToken,
      'shared-access-token',
    );

    final refreshResult = await getIt<AuthRefresher>().refresh(
      failedAccessToken: 'shared-access-token',
    );
    expect(refreshResult, isA<AuthRefreshSuccess>());
    final refreshedCredential = await credentialStore.readCredential();
    expect(refreshedCredential, isA<AuthCredentialReadPresent>());
    expect(
      (refreshedCredential as AuthCredentialReadPresent).tokens.accessToken,
      'mock-refreshed-access-token',
    );
  });
}
