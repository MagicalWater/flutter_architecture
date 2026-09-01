import 'package:api_client/api_client_infrastructure.dart' as api_client;
import 'package:auth/auth_infrastructure.dart' as auth;
import 'package:dio/dio.dart';
import 'package:flutter_architecture/app/config/api_config.dart';
import 'package:flutter_architecture/app/connectivity/connectivity_adapter.dart';
import 'package:flutter_architecture/app/connectivity/connectivity_controller.dart';
import 'package:flutter_architecture/app/connectivity/connectivity_plus_adapter.dart';
import 'package:flutter_architecture/app/database/app_database.dart';
import 'package:flutter_architecture/app/database/dao/auth_user_dao.dart';
import 'package:flutter_architecture/app/database/dao/catalog_cache_dao.dart';
import 'package:flutter_architecture/app/di/api_implementation_selector.dart';
import 'package:flutter_architecture/app/error_reporting/catalog_cache_error_reporter_adapter.dart';
import 'package:flutter_architecture/app/error_reporting/error_reporter.dart';
import 'package:flutter_architecture/features/auth/data/cleanup/auth_cleanup_error_reporter_adapter.dart';
import 'package:flutter_architecture/features/auth/data/local_user_presence/local_auth_user_presence_verifier.dart';
import 'package:flutter_architecture/features/auth/data/local_unlock/shared_preferences_local_unlock_preference_store.dart';
import 'package:flutter_architecture/features/auth/data/stores/flutter_secure_auth_credential_store.dart';
import 'package:flutter_architecture/features/auth/data/stores/shared_preferences_auth_legacy_credential_store.dart';
import 'package:flutter_architecture/features/auth/data/stores/drift_auth_user_store.dart';
import 'package:flutter_architecture/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:flutter_architecture/features/catalog/data/cache/catalog_cache_diagnostic_sink.dart';
import 'package:flutter_architecture/features/catalog/data/cache/catalog_cache_policy.dart';
import 'package:flutter_architecture/features/catalog/data/cache/catalog_clock.dart';
import 'package:flutter_architecture/features/catalog/data/data_sources/catalog_local_data_source.dart';
import 'package:flutter_architecture/features/catalog/data/data_sources/catalog_remote_data_source.dart';
import 'package:flutter_architecture/features/catalog/data/repositories/catalog_repository_impl.dart';
import 'package:flutter_architecture/features/catalog/domain/repositories/catalog_repository.dart';
import 'package:flutter_architecture/features/profile/data/data_sources/profile_remote_data_source.dart';
import 'package:flutter_architecture/features/catalog/domain/use_cases/search_catalog_use_case.dart';
import 'package:flutter_architecture/features/catalog/presentation/bloc/catalog_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:local_auth/local_auth.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

/// Injectable Module。
///
/// ## 為什麼需要 Module？
///
/// 有些物件不是我們自己用 `@injectable` 標註的 class，
/// 例如 SharedPreferences、Database、Dio。
///
/// 這些外部物件需要透過 module 告訴 injectable 如何建立。
@module
abstract class RegisterModule {
  @lazySingleton
  Connectivity get connectivity => Connectivity();

  @lazySingleton
  ConnectivityAdapter connectivityAdapter(Connectivity connectivity) =>
      ConnectivityPlusAdapter(connectivity: connectivity);

  @lazySingleton
  ConnectivityController connectivityController(ConnectivityAdapter adapter) =>
      ConnectivityController(adapter);

  @lazySingleton
  AuthCleanupErrorReporterAdapter authCleanupErrorReporterAdapter(
    ErrorReporter errorReporter,
  ) => AuthCleanupErrorReporterAdapter(errorReporter);

  @lazySingleton
  CatalogCacheDiagnosticSink catalogCacheDiagnosticSink(
    ErrorReporter errorReporter,
  ) {
    return CatalogCacheErrorReporterAdapter(errorReporter);
  }

  @preResolve
  Future<SharedPreferences> get sharedPreferences =>
      SharedPreferences.getInstance();

  @lazySingleton
  api_client.AppDioFactory get appDioFactory =>
      const api_client.AppDioFactory();

  @lazySingleton
  api_client.AuthEndpoint authEndpoint(
    ApiConfig config,
    @Named('mainDio') Dio dio,
  ) {
    return ApiImplementationSelector.createAuthApi(config, dio);
  }

  @lazySingleton
  api_client.AuthRefreshEndpoint authRefreshEndpoint(
    ApiConfig config,
    @Named('refreshDio') Dio dio,
  ) {
    return ApiImplementationSelector.createAuthRefreshApi(config, dio);
  }

  @lazySingleton
  FlutterSecureStorage get flutterSecureStorage => const FlutterSecureStorage();

  @lazySingleton
  LocalAuthentication get localAuthentication => LocalAuthentication();

  @lazySingleton
  LocalAuthGateway localAuthGateway(LocalAuthentication authentication) =>
      PluginLocalAuthGateway(authentication);

  @lazySingleton
  auth.LocalUserPresenceVerifier localUserPresenceVerifier(
    LocalAuthGateway gateway,
  ) => LocalAuthUserPresenceVerifier(gateway);

  @lazySingleton
  auth.AuthCredentialStore authCredentialStore(FlutterSecureStorage storage) =>
      FlutterSecureAuthCredentialStore(storage);

  @lazySingleton
  auth.AuthLegacyCredentialStore authLegacyCredentialStore(
    SharedPreferences preferences,
  ) => SharedPreferencesAuthLegacyCredentialStore(preferences);

  @lazySingleton
  auth.AuthUserStore authUserStore(AppDatabase database) =>
      DriftAuthUserStore(AuthUserDao(database));

  @lazySingleton
  auth.LocalUnlockPreferenceStore localUnlockPreferenceStore(
    SharedPreferences preferences,
  ) => SharedPreferencesLocalUnlockPreferenceStore(preferences);

  @lazySingleton
  auth.LocalUnlockPolicy localUnlockPolicy(
    auth.SessionManager sessionManager,
    auth.AuthStateMutationCoordinator mutationCoordinator,
    auth.LocalUserPresenceVerifier verifier,
    auth.LocalUnlockPreferenceStore store,
  ) => auth.LocalUnlockPolicy(
    sessionManager,
    mutationCoordinator,
    verifier,
    store,
  );

  @lazySingleton
  auth.AuthCredentialMigrationCoordinator authCredentialMigrationCoordinator(
    auth.AuthCredentialStore secureCredentialStore,
    auth.AuthLegacyCredentialStore legacyCredentialStore,
    auth.AuthUserStore userStore,
  ) {
    return auth.AuthCredentialMigrationCoordinator(
      secureCredentialStore,
      legacyCredentialStore,
      userStore,
    );
  }

  @lazySingleton
  auth.AuthRemoteDataSource authRemoteDataSource(
    api_client.AuthEndpoint authEndpoint,
  ) {
    return auth.AuthRemoteDataSource(authEndpoint);
  }

  @lazySingleton
  auth.AuthRefreshRemoteDataSource authRefreshRemoteDataSource(
    api_client.AuthRefreshEndpoint authRefreshEndpoint,
  ) {
    return auth.AuthRefreshRemoteDataSource(authRefreshEndpoint);
  }

  @lazySingleton
  api_client.AuthRefresher authRefresher(
    auth.AuthRefreshRemoteDataSource remoteDataSource,
    auth.AuthCredentialStore credentialStore,
    auth.AuthLegacyCredentialStore legacyCredentialStore,
    auth.AuthUserStore userStore,
    auth.SessionManager sessionManager,
    auth.AuthStateMutationCoordinator mutationCoordinator,
    AuthCleanupErrorReporterAdapter diagnosticSink,
    auth.LocalUnlockPreferenceStore localUnlockPreferenceStore,
  ) {
    return auth.AuthSessionRefresher(
      remoteDataSource,
      credentialStore,
      legacyCredentialStore,
      userStore,
      sessionManager,
      mutationCoordinator,
      diagnosticSink,
    );
  }

  @lazySingleton
  api_client.AuthTokenProvider authTokenProvider(
    auth.SessionManager sessionManager,
  ) {
    return auth.AuthTokenProviderImpl(sessionManager);
  }

  @lazySingleton
  auth.SessionManager get sessionManager => auth.SessionManager();

  @lazySingleton
  auth.AuthStateMutationCoordinator get authStateMutationCoordinator =>
      auth.AuthStateMutationCoordinator();

  @lazySingleton
  auth.AuthRepository authRepository(
    auth.AuthRemoteDataSource remoteDataSource,
    auth.AuthCredentialStore credentialStore,
    auth.AuthLegacyCredentialStore legacyCredentialStore,
    auth.AuthUserStore userStore,
    auth.SessionManager sessionManager,
    auth.AuthStateMutationCoordinator mutationCoordinator,
    auth.AuthCredentialMigrationCoordinator migrationCoordinator,
    AuthCleanupErrorReporterAdapter diagnosticSink,
    auth.LocalUnlockPreferenceStore localUnlockPreferenceStore,
  ) {
    return auth.AuthRepositoryImpl(
      remoteDataSource,
      credentialStore,
      legacyCredentialStore,
      userStore,
      sessionManager,
      mutationCoordinator,
      migrationCoordinator,
      diagnosticSink,
      localUnlockPreferenceStore,
    );
  }

  @lazySingleton
  AuthBloc authBloc(
    auth.AuthRepository repository,
    auth.SessionManager sessionManager,
    auth.AuthStateMutationCoordinator mutationCoordinator,
  ) {
    return AuthBloc(repository, sessionManager, mutationCoordinator);
  }

  @Named('mainDio')
  @lazySingleton
  Dio mainDio(
    api_client.AppDioFactory factory,
    api_client.AuthTokenProvider tokenProvider,
    api_client.AuthRefresher authRefresher,
    ApiConfig config,
  ) {
    return factory.createMain(
      baseUrl: config.baseUri.toString(),
      tokenProvider: tokenProvider,
      authRefresher: authRefresher,
    );
  }

  @Named('refreshDio')
  @lazySingleton
  Dio refreshDio(api_client.AppDioFactory factory, ApiConfig config) {
    return factory.createRefresh(baseUrl: config.baseUri.toString());
  }

  @lazySingleton
  api_client.ProfileApi profileApi(
    ApiConfig config,
    @Named('mainDio') Dio dio,
  ) {
    return ApiImplementationSelector.createProfileApi(config, dio);
  }

  @lazySingleton
  api_client.CatalogApi catalogApi(
    ApiConfig config,
    @Named('mainDio') Dio dio,
  ) {
    return ApiImplementationSelector.createCatalogApi(config, dio);
  }

  @lazySingleton
  CatalogLocalDataSource catalogLocalDataSource(AppDatabase database) {
    return CatalogLocalDataSource(DriftCatalogCacheDao(database));
  }

  @lazySingleton
  CatalogCachePolicy get catalogCachePolicy => CatalogCachePolicy();

  @lazySingleton
  CatalogClock get catalogClock => const SystemCatalogClock();

  @lazySingleton
  CatalogRepository catalogRepository(
    CatalogRemoteDataSource remoteDataSource,
    CatalogLocalDataSource localDataSource,
    CatalogCachePolicy cachePolicy,
    CatalogClock clock,
    CatalogCacheDiagnosticSink diagnosticSink,
  ) {
    return CatalogRepositoryImpl(
      remoteDataSource,
      localDataSource,
      cachePolicy,
      clock,
      diagnosticSink,
    );
  }

  @injectable
  CatalogBloc catalogBloc(SearchCatalogUseCase searchCatalogUseCase) {
    return CatalogBloc(searchCatalogUseCase);
  }

  @lazySingleton
  ProfileRemoteDataSource profileRemoteDataSource(
    api_client.ProfileApi profileApi,
  ) {
    return ProfileRemoteDataSource(profileApi);
  }
}
