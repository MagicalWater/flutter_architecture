// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format width=80

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:api_client/api_client.dart' as _i633;
import 'package:auth/auth.dart' as _i662;
import 'package:dio/dio.dart' as _i361;
import 'package:flutter_architecture/app/config/api_config.dart' as _i46;
import 'package:flutter_architecture/app/di/register_module.dart' as _i712;
import 'package:flutter_architecture/app/error_reporting/error_reporter.dart'
    as _i1041;
import 'package:flutter_architecture/app/router/app_router.dart' as _i787;
import 'package:flutter_architecture/app/router/auth_guard.dart' as _i997;
import 'package:flutter_architecture/features/auth/data/local_user_presence/local_auth_user_presence_verifier.dart'
    as _i287;
import 'package:flutter_architecture/features/auth/data/migration/auth_migration_error_reporter_adapter.dart'
    as _i112;
import 'package:flutter_architecture/features/auth/presentation/bloc/auth_bloc.dart'
    as _i1024;
import 'package:flutter_architecture/features/catalog/data/cache/catalog_cache_diagnostic_sink.dart'
    as _i460;
import 'package:flutter_architecture/features/catalog/data/cache/catalog_cache_policy.dart'
    as _i923;
import 'package:flutter_architecture/features/catalog/data/cache/catalog_clock.dart'
    as _i401;
import 'package:flutter_architecture/features/catalog/data/data_sources/catalog_local_data_source.dart'
    as _i538;
import 'package:flutter_architecture/features/catalog/data/data_sources/catalog_remote_data_source.dart'
    as _i98;
import 'package:flutter_architecture/features/catalog/domain/repositories/catalog_repository.dart'
    as _i1035;
import 'package:flutter_architecture/features/catalog/domain/use_cases/search_catalog_use_case.dart'
    as _i877;
import 'package:flutter_architecture/features/catalog/presentation/bloc/catalog_bloc.dart'
    as _i771;
import 'package:flutter_architecture/features/profile/data/data_sources/profile_remote_data_source.dart'
    as _i725;
import 'package:flutter_architecture/features/profile/data/repositories/profile_repository_impl.dart'
    as _i407;
import 'package:flutter_architecture/features/profile/domain/repositories/profile_repository.dart'
    as _i511;
import 'package:flutter_architecture/features/profile/domain/use_cases/get_profile_use_case.dart'
    as _i474;
import 'package:flutter_architecture/features/profile/presentation/bloc/profile_bloc.dart'
    as _i173;
import 'package:flutter_secure_storage/flutter_secure_storage.dart' as _i558;
import 'package:get_it/get_it.dart' as _i174;
import 'package:injectable/injectable.dart' as _i526;
import 'package:local_auth/local_auth.dart' as _i152;
import 'package:shared_preferences/shared_preferences.dart' as _i460;
import 'package:sqflite/sqflite.dart' as _i779;

extension GetItInjectableX on _i174.GetIt {
  // initializes the registration of main-scope dependencies inside of GetIt
  Future<_i174.GetIt> init({
    String? environment,
    _i526.EnvironmentFilter? environmentFilter,
  }) async {
    final gh = _i526.GetItHelper(this, environment, environmentFilter);
    final registerModule = _$RegisterModule();
    await gh.factoryAsync<_i460.SharedPreferences>(
      () => registerModule.sharedPreferences,
      preResolve: true,
    );
    await gh.factoryAsync<_i779.Database>(
      () => registerModule.database,
      preResolve: true,
    );
    gh.lazySingleton<_i633.AppDioFactory>(() => registerModule.appDioFactory);
    gh.lazySingleton<_i558.FlutterSecureStorage>(
      () => registerModule.flutterSecureStorage,
    );
    gh.lazySingleton<_i152.LocalAuthentication>(
      () => registerModule.localAuthentication,
    );
    gh.lazySingleton<_i662.SessionManager>(() => registerModule.sessionManager);
    gh.lazySingleton<_i662.AuthStateMutationCoordinator>(
      () => registerModule.authStateMutationCoordinator,
    );
    gh.lazySingleton<_i923.CatalogCachePolicy>(
      () => registerModule.catalogCachePolicy,
    );
    gh.lazySingleton<_i401.CatalogClock>(() => registerModule.catalogClock);
    gh.lazySingleton<_i662.AuthUserStore>(
      () => registerModule.authUserStore(gh<_i779.Database>()),
    );
    gh.lazySingleton<_i538.CatalogLocalDataSource>(
      () => registerModule.catalogLocalDataSource(gh<_i779.Database>()),
    );
    gh.lazySingleton<_i662.AuthCredentialStore>(
      () =>
          registerModule.authCredentialStore(gh<_i558.FlutterSecureStorage>()),
    );
    gh.lazySingleton<_i633.AuthTokenProvider>(
      () => registerModule.authTokenProvider(gh<_i662.SessionManager>()),
    );
    gh.lazySingleton<_i662.AuthLegacyCredentialStore>(
      () => registerModule.authLegacyCredentialStore(
        gh<_i460.SharedPreferences>(),
      ),
    );
    gh.lazySingleton<_i997.AuthGuard>(
      () => _i997.AuthGuard(gh<_i662.SessionManager>()),
    );
    gh.lazySingleton<_i361.Dio>(
      () => registerModule.refreshDio(
        gh<_i633.AppDioFactory>(),
        gh<_i46.ApiConfig>(),
      ),
      instanceName: 'refreshDio',
    );
    gh.lazySingleton<_i287.LocalAuthGateway>(
      () => registerModule.localAuthGateway(gh<_i152.LocalAuthentication>()),
    );
    gh.lazySingleton<_i112.AuthMigrationErrorReporterAdapter>(
      () => registerModule.authMigrationErrorReporterAdapter(
        gh<_i1041.ErrorReporter>(),
      ),
    );
    gh.lazySingleton<_i460.CatalogCacheDiagnosticSink>(
      () =>
          registerModule.catalogCacheDiagnosticSink(gh<_i1041.ErrorReporter>()),
    );
    gh.lazySingleton<_i633.AuthRefreshApi>(
      () => registerModule.authRefreshApi(
        gh<_i46.ApiConfig>(),
        gh<_i361.Dio>(instanceName: 'refreshDio'),
      ),
    );
    gh.lazySingleton<_i787.AppRouter>(
      () => _i787.AppRouter(gh<_i997.AuthGuard>()),
    );
    gh.lazySingleton<_i662.LocalUserPresenceVerifier>(
      () => registerModule.localUserPresenceVerifier(
        gh<_i287.LocalAuthGateway>(),
      ),
    );
    gh.lazySingleton<_i662.AuthRefreshRemoteDataSource>(
      () => registerModule.authRefreshRemoteDataSource(
        gh<_i633.AuthRefreshApi>(),
      ),
    );
    gh.lazySingleton<_i662.AuthCredentialMigrationCoordinator>(
      () => registerModule.authCredentialMigrationCoordinator(
        gh<_i662.AuthCredentialStore>(),
        gh<_i662.AuthLegacyCredentialStore>(),
        gh<_i662.AuthUserStore>(),
      ),
    );
    gh.lazySingleton<_i633.AuthRefresher>(
      () => registerModule.authRefresher(
        gh<_i662.AuthRefreshRemoteDataSource>(),
        gh<_i662.AuthCredentialStore>(),
        gh<_i662.AuthLegacyCredentialStore>(),
        gh<_i662.AuthUserStore>(),
        gh<_i662.SessionManager>(),
        gh<_i662.AuthStateMutationCoordinator>(),
        gh<_i112.AuthMigrationErrorReporterAdapter>(),
      ),
    );
    gh.lazySingleton<_i361.Dio>(
      () => registerModule.mainDio(
        gh<_i633.AppDioFactory>(),
        gh<_i633.AuthTokenProvider>(),
        gh<_i633.AuthRefresher>(),
        gh<_i46.ApiConfig>(),
      ),
      instanceName: 'mainDio',
    );
    gh.lazySingleton<_i633.AuthApi>(
      () => registerModule.authApi(
        gh<_i46.ApiConfig>(),
        gh<_i361.Dio>(instanceName: 'mainDio'),
      ),
    );
    gh.lazySingleton<_i633.ProfileApi>(
      () => registerModule.profileApi(
        gh<_i46.ApiConfig>(),
        gh<_i361.Dio>(instanceName: 'mainDio'),
      ),
    );
    gh.lazySingleton<_i633.CatalogApi>(
      () => registerModule.catalogApi(
        gh<_i46.ApiConfig>(),
        gh<_i361.Dio>(instanceName: 'mainDio'),
      ),
    );
    gh.lazySingleton<_i662.AuthRemoteDataSource>(
      () => registerModule.authRemoteDataSource(gh<_i633.AuthApi>()),
    );
    gh.lazySingleton<_i98.CatalogRemoteDataSource>(
      () => _i98.CatalogRemoteDataSource(gh<_i633.CatalogApi>()),
    );
    gh.lazySingleton<_i725.ProfileRemoteDataSource>(
      () => registerModule.profileRemoteDataSource(gh<_i633.ProfileApi>()),
    );
    gh.lazySingleton<_i662.AuthRepository>(
      () => registerModule.authRepository(
        gh<_i662.AuthRemoteDataSource>(),
        gh<_i662.AuthCredentialStore>(),
        gh<_i662.AuthLegacyCredentialStore>(),
        gh<_i662.AuthUserStore>(),
        gh<_i662.SessionManager>(),
        gh<_i662.AuthStateMutationCoordinator>(),
        gh<_i662.AuthCredentialMigrationCoordinator>(),
        gh<_i112.AuthMigrationErrorReporterAdapter>(),
      ),
    );
    gh.lazySingleton<_i1035.CatalogRepository>(
      () => registerModule.catalogRepository(
        gh<_i98.CatalogRemoteDataSource>(),
        gh<_i538.CatalogLocalDataSource>(),
        gh<_i923.CatalogCachePolicy>(),
        gh<_i401.CatalogClock>(),
        gh<_i460.CatalogCacheDiagnosticSink>(),
      ),
    );
    gh.lazySingleton<_i511.ProfileRepository>(
      () => _i407.ProfileRepositoryImpl(gh<_i725.ProfileRemoteDataSource>()),
    );
    gh.factory<_i877.SearchCatalogUseCase>(
      () => _i877.SearchCatalogUseCase(gh<_i1035.CatalogRepository>()),
    );
    gh.factory<_i474.GetProfileUseCase>(
      () => _i474.GetProfileUseCase(gh<_i511.ProfileRepository>()),
    );
    gh.factory<_i771.CatalogBloc>(
      () => registerModule.catalogBloc(gh<_i877.SearchCatalogUseCase>()),
    );
    gh.factory<_i662.LoginUseCase>(
      () => registerModule.loginUseCase(gh<_i662.AuthRepository>()),
    );
    gh.factory<_i662.VerifyOtpUseCase>(
      () => registerModule.verifyOtpUseCase(gh<_i662.AuthRepository>()),
    );
    gh.factory<_i662.ResendOtpUseCase>(
      () => registerModule.resendOtpUseCase(gh<_i662.AuthRepository>()),
    );
    gh.factory<_i662.LogoutUseCase>(
      () => registerModule.logoutUseCase(gh<_i662.AuthRepository>()),
    );
    gh.factory<_i662.RestoreSessionUseCase>(
      () => registerModule.restoreSessionUseCase(gh<_i662.AuthRepository>()),
    );
    gh.factory<_i173.ProfileBloc>(
      () => _i173.ProfileBloc(
        gh<_i474.GetProfileUseCase>(),
        gh<_i662.LogoutUseCase>(),
        gh<_i662.SessionManager>(),
      ),
    );
    gh.lazySingleton<_i1024.AuthBloc>(
      () => registerModule.authBloc(
        gh<_i662.LoginUseCase>(),
        gh<_i662.RestoreSessionUseCase>(),
        gh<_i662.LogoutUseCase>(),
        gh<_i662.SessionManager>(),
        gh<_i662.AuthStateMutationCoordinator>(),
        gh<_i662.VerifyOtpUseCase>(),
        gh<_i662.ResendOtpUseCase>(),
      ),
    );
    return this;
  }
}

class _$RegisterModule extends _i712.RegisterModule {}
