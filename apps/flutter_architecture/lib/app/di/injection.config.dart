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
import 'package:flutter_architecture/app/router/app_router.dart' as _i787;
import 'package:flutter_architecture/app/router/auth_guard.dart' as _i997;
import 'package:flutter_architecture/features/auth/presentation/bloc/auth_bloc.dart'
    as _i1024;
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
import 'package:get_it/get_it.dart' as _i174;
import 'package:injectable/injectable.dart' as _i526;
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
    gh.lazySingleton<_i662.SessionManager>(() => registerModule.sessionManager);
    gh.lazySingleton<_i662.AuthStateMutationCoordinator>(
      () => registerModule.authStateMutationCoordinator,
    );
    gh.lazySingleton<_i633.AuthTokenProvider>(
      () => registerModule.authTokenProvider(gh<_i662.SessionManager>()),
    );
    gh.lazySingleton<_i361.Dio>(
      () => registerModule.mainDio(
        gh<_i633.AppDioFactory>(),
        gh<_i633.AuthTokenProvider>(),
        gh<_i46.ApiConfig>(),
      ),
      instanceName: 'mainDio',
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
    gh.lazySingleton<_i662.AuthLocalDataSource>(
      () => registerModule.authLocalDataSource(
        gh<_i460.SharedPreferences>(),
        gh<_i779.Database>(),
      ),
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
    gh.lazySingleton<_i662.AuthRemoteDataSource>(
      () => registerModule.authRemoteDataSource(gh<_i633.AuthApi>()),
    );
    gh.lazySingleton<_i633.AuthRefreshApi>(
      () => registerModule.authRefreshApi(
        gh<_i46.ApiConfig>(),
        gh<_i361.Dio>(instanceName: 'refreshDio'),
      ),
    );
    gh.lazySingleton<_i725.ProfileRemoteDataSource>(
      () => registerModule.profileRemoteDataSource(gh<_i633.ProfileApi>()),
    );
    gh.lazySingleton<_i787.AppRouter>(
      () => _i787.AppRouter(gh<_i997.AuthGuard>()),
    );
    gh.lazySingleton<_i662.AuthRefreshRemoteDataSource>(
      () => registerModule.authRefreshRemoteDataSource(
        gh<_i633.AuthRefreshApi>(),
      ),
    );
    gh.lazySingleton<_i633.AuthRefresher>(
      () => registerModule.authRefresher(
        gh<_i662.AuthRefreshRemoteDataSource>(),
        gh<_i662.AuthLocalDataSource>(),
        gh<_i662.SessionManager>(),
        gh<_i662.AuthStateMutationCoordinator>(),
      ),
    );
    gh.lazySingleton<_i662.AuthRepository>(
      () => registerModule.authRepository(
        gh<_i662.AuthRemoteDataSource>(),
        gh<_i662.AuthLocalDataSource>(),
        gh<_i662.SessionManager>(),
        gh<_i662.AuthStateMutationCoordinator>(),
      ),
    );
    gh.lazySingleton<_i511.ProfileRepository>(
      () => _i407.ProfileRepositoryImpl(gh<_i725.ProfileRemoteDataSource>()),
    );
    gh.factory<_i474.GetProfileUseCase>(
      () => _i474.GetProfileUseCase(gh<_i511.ProfileRepository>()),
    );
    gh.factory<_i662.LoginUseCase>(
      () => registerModule.loginUseCase(gh<_i662.AuthRepository>()),
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
      () => _i1024.AuthBloc(
        gh<_i662.LoginUseCase>(),
        gh<_i662.RestoreSessionUseCase>(),
        gh<_i662.LogoutUseCase>(),
        gh<_i662.SessionManager>(),
      ),
    );
    return this;
  }
}

class _$RegisterModule extends _i712.RegisterModule {}
