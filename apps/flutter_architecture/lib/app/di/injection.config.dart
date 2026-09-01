// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format width=80

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:api_client/api_client_infrastructure.dart' as _i408;
import 'package:auth/auth.dart' as _i662;
import 'package:auth/auth_infrastructure.dart' as _i207;
import 'package:connectivity_plus/connectivity_plus.dart' as _i895;
import 'package:dio/dio.dart' as _i361;
import 'package:flutter_architecture/app/config/api_config.dart' as _i46;
import 'package:flutter_architecture/app/connectivity/connectivity_adapter.dart'
    as _i1037;
import 'package:flutter_architecture/app/connectivity/connectivity_controller.dart'
    as _i462;
import 'package:flutter_architecture/app/database/app_database.dart' as _i1048;
import 'package:flutter_architecture/app/di/register_module.dart' as _i712;
import 'package:flutter_architecture/app/error_reporting/error_reporter.dart'
    as _i1041;
import 'package:flutter_architecture/app/router/app_router.dart' as _i787;
import 'package:flutter_architecture/app/router/auth_guard.dart' as _i997;
import 'package:flutter_architecture/features/auth/data/cleanup/auth_cleanup_error_reporter_adapter.dart'
    as _i633;
import 'package:flutter_architecture/features/auth/data/local_user_presence/local_auth_user_presence_verifier.dart'
    as _i287;
import 'package:flutter_architecture/features/auth/presentation/bloc/auth_bloc.dart'
    as _i1024;
import 'package:flutter_architecture/features/catalog/data/cache/catalog_cache_diagnostic_sink.dart'
    as _i461;
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
import 'package:flutter_architecture/features/catalog/presentation/bloc/catalog_bloc.dart'
    as _i771;
import 'package:flutter_architecture/features/profile/data/data_sources/profile_remote_data_source.dart'
    as _i725;
import 'package:flutter_architecture/features/profile/data/repositories/profile_repository_impl.dart'
    as _i407;
import 'package:flutter_architecture/features/profile/domain/repositories/profile_repository.dart'
    as _i511;
import 'package:flutter_architecture/features/profile/presentation/bloc/profile_bloc.dart'
    as _i173;
import 'package:flutter_secure_storage/flutter_secure_storage.dart' as _i558;
import 'package:get_it/get_it.dart' as _i174;
import 'package:injectable/injectable.dart' as _i526;
import 'package:local_auth/local_auth.dart' as _i152;
import 'package:shared_preferences/shared_preferences.dart' as _i460;

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
    gh.lazySingleton<_i895.Connectivity>(() => registerModule.connectivity);
    gh.lazySingleton<_i408.AppDioFactory>(() => registerModule.appDioFactory);
    gh.lazySingleton<_i558.FlutterSecureStorage>(
      () => registerModule.flutterSecureStorage,
    );
    gh.lazySingleton<_i152.LocalAuthentication>(
      () => registerModule.localAuthentication,
    );
    gh.lazySingleton<_i207.SessionManager>(() => registerModule.sessionManager);
    gh.lazySingleton<_i207.AuthStateMutationCoordinator>(
      () => registerModule.authStateMutationCoordinator,
    );
    gh.lazySingleton<_i923.CatalogCachePolicy>(
      () => registerModule.catalogCachePolicy,
    );
    gh.lazySingleton<_i401.CatalogClock>(() => registerModule.catalogClock);
    gh.lazySingleton<_i207.AuthCredentialStore>(
      () =>
          registerModule.authCredentialStore(gh<_i558.FlutterSecureStorage>()),
    );
    gh.lazySingleton<_i207.AuthUserStore>(
      () => registerModule.authUserStore(gh<_i1048.AppDatabase>()),
    );
    gh.lazySingleton<_i538.CatalogLocalDataSource>(
      () => registerModule.catalogLocalDataSource(gh<_i1048.AppDatabase>()),
    );
    gh.lazySingleton<_i1037.ConnectivityAdapter>(
      () => registerModule.connectivityAdapter(gh<_i895.Connectivity>()),
    );
    gh.lazySingleton<_i361.Dio>(
      () => registerModule.refreshDio(
        gh<_i408.AppDioFactory>(),
        gh<_i46.ApiConfig>(),
      ),
      instanceName: 'refreshDio',
    );
    gh.lazySingleton<_i207.AuthLegacyCredentialStore>(
      () => registerModule.authLegacyCredentialStore(
        gh<_i460.SharedPreferences>(),
      ),
    );
    gh.lazySingleton<_i207.LocalUnlockPreferenceStore>(
      () => registerModule.localUnlockPreferenceStore(
        gh<_i460.SharedPreferences>(),
      ),
    );
    gh.lazySingleton<_i997.AuthGuard>(
      () => _i997.AuthGuard(gh<_i662.SessionManager>()),
    );
    gh.lazySingleton<_i287.LocalAuthGateway>(
      () => registerModule.localAuthGateway(gh<_i152.LocalAuthentication>()),
    );
    gh.lazySingleton<_i408.AuthTokenProvider>(
      () => registerModule.authTokenProvider(gh<_i207.SessionManager>()),
    );
    gh.lazySingleton<_i633.AuthCleanupErrorReporterAdapter>(
      () => registerModule.authCleanupErrorReporterAdapter(
        gh<_i1041.ErrorReporter>(),
      ),
    );
    gh.lazySingleton<_i461.CatalogCacheDiagnosticSink>(
      () =>
          registerModule.catalogCacheDiagnosticSink(gh<_i1041.ErrorReporter>()),
    );
    gh.lazySingleton<_i462.ConnectivityController>(
      () => registerModule.connectivityController(
        gh<_i1037.ConnectivityAdapter>(),
      ),
    );
    gh.lazySingleton<_i207.AuthCredentialMigrationCoordinator>(
      () => registerModule.authCredentialMigrationCoordinator(
        gh<_i207.AuthCredentialStore>(),
        gh<_i207.AuthLegacyCredentialStore>(),
        gh<_i207.AuthUserStore>(),
      ),
    );
    gh.lazySingleton<_i408.AuthRefreshEndpoint>(
      () => registerModule.authRefreshEndpoint(
        gh<_i46.ApiConfig>(),
        gh<_i361.Dio>(instanceName: 'refreshDio'),
      ),
    );
    gh.lazySingleton<_i787.AppRouter>(
      () => _i787.AppRouter(gh<_i997.AuthGuard>()),
    );
    gh.lazySingleton<_i207.LocalUserPresenceVerifier>(
      () => registerModule.localUserPresenceVerifier(
        gh<_i287.LocalAuthGateway>(),
      ),
    );
    gh.lazySingleton<_i207.LocalUnlockPolicy>(
      () => registerModule.localUnlockPolicy(
        gh<_i207.SessionManager>(),
        gh<_i207.AuthStateMutationCoordinator>(),
        gh<_i207.LocalUserPresenceVerifier>(),
        gh<_i207.LocalUnlockPreferenceStore>(),
      ),
    );
    gh.lazySingleton<_i207.AuthRefreshRemoteDataSource>(
      () => registerModule.authRefreshRemoteDataSource(
        gh<_i408.AuthRefreshEndpoint>(),
      ),
    );
    gh.lazySingleton<_i408.AuthRefresher>(
      () => registerModule.authRefresher(
        gh<_i207.AuthRefreshRemoteDataSource>(),
        gh<_i207.AuthCredentialStore>(),
        gh<_i207.AuthLegacyCredentialStore>(),
        gh<_i207.AuthUserStore>(),
        gh<_i207.SessionManager>(),
        gh<_i207.AuthStateMutationCoordinator>(),
        gh<_i633.AuthCleanupErrorReporterAdapter>(),
        gh<_i207.LocalUnlockPreferenceStore>(),
      ),
    );
    gh.lazySingleton<_i361.Dio>(
      () => registerModule.mainDio(
        gh<_i408.AppDioFactory>(),
        gh<_i408.AuthTokenProvider>(),
        gh<_i408.AuthRefresher>(),
        gh<_i46.ApiConfig>(),
      ),
      instanceName: 'mainDio',
    );
    gh.lazySingleton<_i408.AuthEndpoint>(
      () => registerModule.authEndpoint(
        gh<_i46.ApiConfig>(),
        gh<_i361.Dio>(instanceName: 'mainDio'),
      ),
    );
    gh.lazySingleton<_i408.ProfileApi>(
      () => registerModule.profileApi(
        gh<_i46.ApiConfig>(),
        gh<_i361.Dio>(instanceName: 'mainDio'),
      ),
    );
    gh.lazySingleton<_i408.CatalogApi>(
      () => registerModule.catalogApi(
        gh<_i46.ApiConfig>(),
        gh<_i361.Dio>(instanceName: 'mainDio'),
      ),
    );
    gh.lazySingleton<_i207.AuthRemoteDataSource>(
      () => registerModule.authRemoteDataSource(gh<_i408.AuthEndpoint>()),
    );
    gh.lazySingleton<_i98.CatalogRemoteDataSource>(
      () => _i98.CatalogRemoteDataSource(gh<_i408.CatalogApi>()),
    );
    gh.lazySingleton<_i207.AuthRepository>(
      () => registerModule.authRepository(
        gh<_i207.AuthRemoteDataSource>(),
        gh<_i207.AuthCredentialStore>(),
        gh<_i207.AuthLegacyCredentialStore>(),
        gh<_i207.AuthUserStore>(),
        gh<_i207.SessionManager>(),
        gh<_i207.AuthStateMutationCoordinator>(),
        gh<_i207.AuthCredentialMigrationCoordinator>(),
        gh<_i633.AuthCleanupErrorReporterAdapter>(),
        gh<_i207.LocalUnlockPreferenceStore>(),
      ),
    );
    gh.lazySingleton<_i725.ProfileRemoteDataSource>(
      () => registerModule.profileRemoteDataSource(gh<_i408.ProfileApi>()),
    );
    gh.lazySingleton<_i511.ProfileRepository>(
      () => _i407.ProfileRepositoryImpl(gh<_i725.ProfileRemoteDataSource>()),
    );
    gh.lazySingleton<_i1024.AuthBloc>(
      () => registerModule.authBloc(
        gh<_i207.AuthRepository>(),
        gh<_i207.SessionManager>(),
        gh<_i207.AuthStateMutationCoordinator>(),
      ),
    );
    gh.factory<_i173.ProfileBloc>(
      () => _i173.ProfileBloc(
        gh<_i511.ProfileRepository>(),
        gh<_i662.AuthRepository>(),
        gh<_i662.SessionManager>(),
      ),
    );
    gh.lazySingleton<_i1035.CatalogRepository>(
      () => registerModule.catalogRepository(
        gh<_i98.CatalogRemoteDataSource>(),
        gh<_i538.CatalogLocalDataSource>(),
        gh<_i923.CatalogCachePolicy>(),
        gh<_i401.CatalogClock>(),
        gh<_i461.CatalogCacheDiagnosticSink>(),
      ),
    );
    gh.factory<_i771.CatalogBloc>(
      () => registerModule.catalogBloc(gh<_i1035.CatalogRepository>()),
    );
    return this;
  }
}

class _$RegisterModule extends _i712.RegisterModule {}
