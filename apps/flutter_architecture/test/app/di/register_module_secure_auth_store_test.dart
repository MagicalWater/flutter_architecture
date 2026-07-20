import 'package:api_client/api_client.dart' as api_client;
import 'package:auth/auth.dart';
import 'package:core/core.dart';
import 'package:flutter_architecture/app/config/api_config.dart';
import 'package:flutter_architecture/app/config/app_config.dart';
import 'package:flutter_architecture/app/config/app_environment.dart';
import 'package:flutter_architecture/app/di/injection.dart';
import 'package:flutter_architecture/app/error_reporting/error_reporter.dart';
import 'package:flutter_architecture/features/auth/data/migration/auth_migration_error_reporter_adapter.dart';
import 'package:flutter_architecture/features/auth/data/stores/flutter_secure_auth_credential_store.dart';
import 'package:flutter_architecture/features/auth/data/stores/shared_preferences_auth_credential_store.dart';
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

  tearDown(() async {
    await getIt.reset();
  });

  test(
    'Secure credential store以named singleton組裝且不切換production authority',
    () async {
      final config = AppConfig(
        environment: AppEnvironment.development,
        api: ApiConfig(
          mode: ApiMode.mock,
          baseUri: Uri.parse('https://mock.local'),
        ),
      );

      await configureDependencies(config, const NoopErrorReporter());

      final defaultStore = getIt<AuthCredentialStore>();
      final secureStore = getIt<AuthCredentialStore>(
        instanceName: 'secureAuthCredentialStore',
      );
      final coordinator = getIt<AuthCredentialMigrationCoordinator>();

      expect(defaultStore, isA<SharedPreferencesAuthCredentialStore>());
      expect(secureStore, isA<FlutterSecureAuthCredentialStore>());
      expect(identical(defaultStore, secureStore), isFalse);
      expect(
        identical(coordinator, getIt<AuthCredentialMigrationCoordinator>()),
        isTrue,
      );
      expect(getIt<AuthMigrationErrorReporterAdapter>(), isNotNull);
      expect(
        identical(
          secureStore,
          getIt<AuthCredentialStore>(instanceName: 'secureAuthCredentialStore'),
        ),
        isTrue,
      );
      expect(
        identical(getIt<FlutterSecureStorage>(), getIt<FlutterSecureStorage>()),
        isTrue,
      );

      await secureStore.writeCredential(
        const StoredAuthTokens(
          accessToken: 'secure-only-access',
          refreshToken: 'secure-only-refresh',
          userId: 'secure-only-user',
        ),
      );

      final restoreResult = await getIt<AuthRepository>().restoreSession();

      expect(restoreResult, isA<Success<AuthUser?>>());
      expect((restoreResult as Success<AuthUser?>).data, isNull);
      expect(getIt<SessionManager>().currentSession, isNull);

      await getIt<AuthUserStore>().writeUser(
        const AuthUser(id: 'secure-only-user', name: 'Secure User'),
      );
      final migrationResult = await coordinator.resolveUnlocked();
      expect(migrationResult, isA<AuthCredentialMigrationResolved>());
      final migrationResolved =
          migrationResult as AuthCredentialMigrationResolved;
      expect(migrationResolved.tokens.accessToken, 'secure-only-access');
      expect(migrationResolved.tokens.refreshToken, 'secure-only-refresh');
      expect(migrationResolved.user.id, 'secure-only-user');

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
      expect(
        defaultCredential.tokens.accessToken,
        'mock-refreshed-access-token',
      );
      final secureCredential =
          await secureStore.readCredential() as AuthCredentialReadPresent;
      expect(secureCredential.tokens.accessToken, 'secure-only-access');
      expect(secureCredential.tokens.refreshToken, 'secure-only-refresh');
    },
  );
}
