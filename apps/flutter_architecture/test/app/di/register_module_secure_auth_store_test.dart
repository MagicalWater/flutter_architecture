import 'package:api_client/api_client.dart' as api_client;
import 'package:auth/auth.dart';
import 'package:core/core.dart';
import 'package:drift/native.dart';
import 'package:flutter_architecture/app/config/api_config.dart';
import 'package:flutter_architecture/app/config/app_config.dart';
import 'package:flutter_architecture/app/config/app_environment.dart';
import 'package:flutter_architecture/app/database/app_database.dart'
    show AppDatabase;
import 'package:flutter_architecture/app/di/injection.dart';
import 'package:flutter_architecture/app/error_reporting/error_reporter.dart';
import 'package:flutter_architecture/features/auth/data/migration/auth_migration_error_reporter_adapter.dart';
import 'package:flutter_architecture/features/auth/data/stores/flutter_secure_auth_credential_store.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUp(() {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    FlutterSecureStorage.setMockInitialValues(<String, String>{});
  });

  tearDown(() async {
    await getIt.reset();
  });

  test('Secure credential store成為唯一production authority', () async {
    final config = AppConfig(
      environment: AppEnvironment.development,
      api: ApiConfig(
        mode: ApiMode.mock,
        baseUri: Uri.parse('https://mock.local'),
      ),
    );

    await configureDependencies(
      config,
      const NoopErrorReporter(),
      database: AppDatabase.forTesting(NativeDatabase.memory()),
    );

    final defaultStore = getIt<AuthCredentialStore>();
    final coordinator = getIt<AuthCredentialMigrationCoordinator>();

    expect(defaultStore, isA<FlutterSecureAuthCredentialStore>());
    expect(
      getIt.isRegistered<AuthCredentialStore>(
        instanceName: 'secureAuthCredentialStore',
      ),
      isFalse,
    );
    expect(
      identical(coordinator, getIt<AuthCredentialMigrationCoordinator>()),
      isTrue,
    );
    expect(getIt<AuthMigrationErrorReporterAdapter>(), isNotNull);
    expect(
      identical(getIt<FlutterSecureStorage>(), getIt<FlutterSecureStorage>()),
      isTrue,
    );

    await defaultStore.writeCredential(
      const StoredAuthTokens(
        accessToken: 'secure-only-access',
        refreshToken: 'secure-only-refresh',
        userId: 'secure-only-user',
      ),
    );
    await getIt<AuthUserStore>().writeUser(
      const AuthUser(id: 'secure-only-user', name: 'Secure User'),
    );

    final restoreResult = await getIt<AuthRepository>().restoreSession();

    expect(restoreResult, isA<Success<AuthUser?>>());
    expect((restoreResult as Success<AuthUser?>).data?.id, 'secure-only-user');
    expect(
      getIt<SessionManager>().currentSession?.accessToken,
      'secure-only-access',
    );

    expect(getIt<AuthRepository>(), isA<AuthRepositoryImpl>());
    expect(getIt<api_client.AuthRefresher>(), isA<AuthSessionRefresher>());

    await defaultStore.writeCredential(
      const StoredAuthTokens(
        accessToken: 'default-access',
        refreshToken: 'default-refresh',
        userId: 'default-user',
      ),
    );
    await getIt<AuthUserStore>().writeUser(
      const AuthUser(id: 'default-user', name: 'Default User'),
    );
    await getIt<AuthRepository>().restoreSession();

    final refreshResult = await getIt<api_client.AuthRefresher>().refresh(
      failedAccessToken: 'default-access',
    );

    expect(refreshResult, isA<api_client.AuthRefreshSuccess>());
    final defaultCredential =
        await defaultStore.readCredential() as AuthCredentialReadPresent;
    expect(defaultCredential.tokens.accessToken, 'mock-refreshed-access-token');
    final secureCredential =
        await defaultStore.readCredential() as AuthCredentialReadPresent;
    expect(secureCredential.tokens.accessToken, 'mock-refreshed-access-token');
    expect(secureCredential.tokens.refreshToken, 'mock-rotated-refresh-token');
  });
}
