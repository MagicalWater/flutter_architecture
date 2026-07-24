import 'package:api_client/api_client.dart';
import 'package:auth/auth.dart';
import 'package:core/core.dart';
import 'package:drift/native.dart';
import 'package:flutter_architecture/app/database/app_database.dart' as db;
import 'package:flutter_architecture/app/database/dao/auth_user_dao.dart';
import 'package:flutter_architecture/app/database/dao/catalog_cache_dao.dart';
import 'package:flutter_architecture/features/auth/data/stores/drift_auth_user_store.dart';
import 'package:flutter_architecture/features/auth/data/stores/shared_preferences_auth_credential_store.dart';
import 'package:flutter_architecture/features/auth/data/stores/shared_preferences_auth_legacy_credential_store.dart';
import 'package:flutter_architecture/features/catalog/data/data_sources/catalog_local_data_source.dart';
import 'package:flutter_architecture/features/catalog/data/mappers/catalog_cache_page_mapper.dart';
import 'package:flutter_architecture/features/catalog/domain/entities/catalog_item.dart';
import 'package:flutter_architecture/features/catalog/domain/entities/catalog_page.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('Logout 清除 Auth state，但保留 public Catalog Cache', () async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    final preferences = await SharedPreferences.getInstance();
    final database = db.AppDatabase.forTesting(NativeDatabase.memory());
    addTearDown(database.close);

    final credentialStore = SharedPreferencesAuthCredentialStore(preferences);
    final legacyCredentialStore = SharedPreferencesAuthLegacyCredentialStore(
      preferences,
    );
    final userStore = DriftAuthUserStore(AuthUserDao(database));
    final sessionManager = SessionManager();
    addTearDown(sessionManager.dispose);
    final authRepository = AuthRepositoryImpl(
      AuthRemoteDataSource(MockAuthApi()),
      credentialStore,
      legacyCredentialStore,
      userStore,
      sessionManager,
      AuthStateMutationCoordinator(),
      AuthCredentialMigrationCoordinator(
        credentialStore,
        legacyCredentialStore,
        userStore,
      ),
      const _NoopLifecycleDiagnosticSink(),
    );
    final catalogLocal = CatalogLocalDataSource(
      DriftCatalogCacheDao(database),
    );
    final updatedAt = DateTime.utc(2026, 7, 17, 6);

    final login = await authRepository.login(
      account: 'demo@example.com',
      password: 'password',
    );
    expect(login, isA<Success<AuthLoginResult>>());
    expect(sessionManager.currentSession, isNotNull);

    await catalogLocal.replacePage(
      const CatalogPage(
        items: <CatalogItem>[
          CatalogItem(
            id: 'public-item',
            name: 'Public Catalog Item',
            description: 'persists across logout',
          ),
        ],
        nextCursor: null,
      ).toCacheEntity(
        query: '',
        requestCursor: null,
        requestLimit: 20,
        updatedAt: updatedAt,
      ),
      resetFollowingPages: true,
    );

    final logout = await authRepository.logout();
    expect(logout, isA<Success<void>>());
    expect(sessionManager.currentSession, isNull);
    expect(
      await credentialStore.readCredential(),
      isA<AuthCredentialReadAbsent>(),
    );
    expect(await userStore.readUser(), isNull);

    final cached = await catalogLocal.readPage(
      query: '',
      cursor: null,
      limit: 20,
      now: updatedAt.add(const Duration(hours: 1)),
      retainFor: const Duration(days: 7),
    );
    expect(cached, isNotNull);
    expect(cached!.items.single.id, 'public-item');
  });
}

final class _NoopLifecycleDiagnosticSink
    implements AuthLifecycleDiagnosticSink {
  const _NoopLifecycleDiagnosticSink();

  @override
  void reportAll(Iterable<AuthLifecycleDiagnostic> diagnostics) {}
}
