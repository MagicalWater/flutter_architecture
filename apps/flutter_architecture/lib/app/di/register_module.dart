import 'package:api_client/api_client.dart' as api_client;
import 'package:auth/auth.dart' as auth;
import 'package:dio/dio.dart';
import 'package:flutter_architecture/app/config/api_config.dart';
import 'package:flutter_architecture/app/database/app_database_schema.dart';
import 'package:flutter_architecture/app/di/api_implementation_selector.dart';
import 'package:flutter_architecture/app/error_reporting/catalog_cache_error_reporter_adapter.dart';
import 'package:flutter_architecture/app/error_reporting/error_reporter.dart';
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
import 'package:path/path.dart' as p;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';

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
  CatalogCacheDiagnosticSink catalogCacheDiagnosticSink(
    ErrorReporter errorReporter,
  ) {
    return CatalogCacheErrorReporterAdapter(errorReporter);
  }

  @preResolve
  Future<SharedPreferences> get sharedPreferences =>
      SharedPreferences.getInstance();

  @preResolve
  Future<Database> get database async {
    final databasePath = await getDatabasesPath();
    final path = p.join(databasePath, 'flutter_architecture.db');

    return openDatabase(
      path,
      version: AppDatabaseSchema.version,
      onConfigure: AppDatabaseSchema.onConfigure,
      onCreate: AppDatabaseSchema.onCreate,
      onUpgrade: AppDatabaseSchema.onUpgrade,
    );
  }

  @lazySingleton
  api_client.AppDioFactory get appDioFactory =>
      const api_client.AppDioFactory();

  @lazySingleton
  api_client.AuthApi authApi(ApiConfig config, @Named('mainDio') Dio dio) {
    return ApiImplementationSelector.createAuthApi(config, dio);
  }

  @lazySingleton
  api_client.AuthRefreshApi authRefreshApi(
    ApiConfig config,
    @Named('refreshDio') Dio dio,
  ) {
    return ApiImplementationSelector.createAuthRefreshApi(config, dio);
  }

  @lazySingleton
  auth.AuthLocalDataSource authLocalDataSource(
    SharedPreferences preferences,
    Database database,
  ) {
    return auth.AuthLocalDataSource(preferences, database);
  }

  @lazySingleton
  auth.AuthRemoteDataSource authRemoteDataSource(api_client.AuthApi authApi) {
    return auth.AuthRemoteDataSource(authApi);
  }

  @lazySingleton
  auth.AuthRefreshRemoteDataSource authRefreshRemoteDataSource(
    api_client.AuthRefreshApi authRefreshApi,
  ) {
    return auth.AuthRefreshRemoteDataSource(authRefreshApi);
  }

  @lazySingleton
  api_client.AuthRefresher authRefresher(
    auth.AuthRefreshRemoteDataSource remoteDataSource,
    auth.AuthLocalDataSource localDataSource,
    auth.SessionManager sessionManager,
    auth.AuthStateMutationCoordinator mutationCoordinator,
  ) {
    return auth.AuthSessionRefresher(
      remoteDataSource,
      localDataSource,
      sessionManager,
      mutationCoordinator,
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
    auth.AuthLocalDataSource localDataSource,
    auth.SessionManager sessionManager,
    auth.AuthStateMutationCoordinator mutationCoordinator,
  ) {
    return auth.AuthRepositoryImpl(
      remoteDataSource,
      localDataSource,
      sessionManager,
      mutationCoordinator,
    );
  }

  @injectable
  auth.LoginUseCase loginUseCase(auth.AuthRepository repository) {
    return auth.LoginUseCase(repository);
  }

  @injectable
  auth.LogoutUseCase logoutUseCase(auth.AuthRepository repository) {
    return auth.LogoutUseCase(repository);
  }

  @injectable
  auth.RestoreSessionUseCase restoreSessionUseCase(
    auth.AuthRepository repository,
  ) {
    return auth.RestoreSessionUseCase(repository);
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
  CatalogLocalDataSource catalogLocalDataSource(Database database) {
    return CatalogLocalDataSource(database);
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
