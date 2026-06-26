// dart format width=80
// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:api_client/api_client.dart' as _i633;
import 'package:dio/dio.dart' as _i361;
import 'package:flutter_architecture/app/di/register_module.dart' as _i712;
import 'package:flutter_architecture/app/router/app_router.dart' as _i787;
import 'package:flutter_architecture/app/router/auth_guard.dart' as _i997;
import 'package:flutter_architecture/features/auth/data/data_sources/auth_local_data_source.dart'
    as _i914;
import 'package:flutter_architecture/features/auth/data/data_sources/auth_remote_data_source.dart'
    as _i810;
import 'package:flutter_architecture/features/auth/data/data_sources/auth_token_provider_impl.dart'
    as _i113;
import 'package:flutter_architecture/features/auth/data/repositories/auth_repository_impl.dart'
    as _i446;
import 'package:flutter_architecture/features/auth/domain/repositories/auth_repository.dart'
    as _i727;
import 'package:flutter_architecture/features/auth/domain/use_cases/login_use_case.dart'
    as _i127;
import 'package:flutter_architecture/features/auth/domain/use_cases/logout_use_case.dart'
    as _i496;
import 'package:flutter_architecture/features/auth/domain/use_cases/restore_session_use_case.dart'
    as _i336;
import 'package:flutter_architecture/features/auth/presentation/bloc/auth_bloc.dart'
    as _i1024;
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
    final gh = _i526.GetItHelper(
      this,
      environment,
      environmentFilter,
    );
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
    gh.lazySingleton<_i633.AuthApiClient>(() => registerModule.authApiClient);
    gh.lazySingleton<_i914.AuthLocalDataSource>(() => _i914.AuthLocalDataSource(
          gh<_i460.SharedPreferences>(),
          gh<_i779.Database>(),
        ));
    gh.lazySingleton<_i810.AuthRemoteDataSource>(
        () => _i810.AuthRemoteDataSource(gh<_i633.AuthApiClient>()));
    gh.lazySingleton<_i633.AuthTokenProvider>(
        () => _i113.AuthTokenProviderImpl(gh<_i914.AuthLocalDataSource>()));
    gh.lazySingleton<_i727.AuthRepository>(() => _i446.AuthRepositoryImpl(
          gh<_i810.AuthRemoteDataSource>(),
          gh<_i914.AuthLocalDataSource>(),
        ));
    gh.lazySingleton<_i361.Dio>(() => registerModule.dio(
          gh<_i633.AppDioFactory>(),
          gh<_i633.AuthTokenProvider>(),
        ));
    gh.lazySingleton<_i633.ProfileApiClient>(
        () => registerModule.profileApiClient(gh<_i361.Dio>()));
    gh.factory<_i127.LoginUseCase>(
        () => _i127.LoginUseCase(gh<_i727.AuthRepository>()));
    gh.factory<_i496.LogoutUseCase>(
        () => _i496.LogoutUseCase(gh<_i727.AuthRepository>()));
    gh.factory<_i336.RestoreSessionUseCase>(
        () => _i336.RestoreSessionUseCase(gh<_i727.AuthRepository>()));
    gh.lazySingleton<_i1024.AuthBloc>(() => _i1024.AuthBloc(
          gh<_i127.LoginUseCase>(),
          gh<_i336.RestoreSessionUseCase>(),
          gh<_i496.LogoutUseCase>(),
        ));
    gh.lazySingleton<_i511.ProfileRepository>(
        () => _i407.ProfileRepositoryImpl(gh<_i633.ProfileApiClient>()));
    gh.lazySingleton<_i997.AuthGuard>(
        () => _i997.AuthGuard(gh<_i1024.AuthBloc>()));
    gh.factory<_i474.GetProfileUseCase>(
        () => _i474.GetProfileUseCase(gh<_i511.ProfileRepository>()));
    gh.lazySingleton<_i787.AppRouter>(
        () => _i787.AppRouter(gh<_i997.AuthGuard>()));
    gh.factory<_i173.ProfileBloc>(
        () => _i173.ProfileBloc(gh<_i474.GetProfileUseCase>()));
    return this;
  }
}

class _$RegisterModule extends _i712.RegisterModule {}
