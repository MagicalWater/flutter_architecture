import 'package:api_client/api_client.dart' as api_client;
import 'package:auth/auth.dart' as auth;
import 'package:dio/dio.dart';
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
  @preResolve
  Future<SharedPreferences> get sharedPreferences =>
      SharedPreferences.getInstance();

  @preResolve
  Future<Database> get database async {
    final databasePath = await getDatabasesPath();
    final path = p.join(databasePath, 'flutter_architecture.db');

    return openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE auth_user (
            id TEXT PRIMARY KEY,
            name TEXT NOT NULL
          )
        ''');
      },
    );
  }

  @lazySingleton
  api_client.AppDioFactory get appDioFactory => const api_client.AppDioFactory();

  @lazySingleton
  api_client.AuthApiClient get authApiClient => const api_client.AuthApiClient();

  @lazySingleton
  auth.AuthLocalDataSource authLocalDataSource(
    SharedPreferences preferences,
    Database database,
  ) {
    return auth.AuthLocalDataSource(
      preferences,
      database,
    );
  }

  @lazySingleton
  auth.AuthRemoteDataSource authRemoteDataSource(
    api_client.AuthApiClient authApiClient,
  ) {
    return auth.AuthRemoteDataSource(authApiClient);
  }

  @lazySingleton
  api_client.AuthTokenProvider authTokenProvider(
    auth.AuthLocalDataSource localDataSource,
  ) {
    return auth.AuthTokenProviderImpl(localDataSource);
  }

  @lazySingleton
  auth.SessionManager sessionManager(auth.AuthLocalDataSource localDataSource) {
    return auth.SessionManager(localDataSource);
  }

  @lazySingleton
  auth.AuthRepository authRepository(
    auth.AuthRemoteDataSource remoteDataSource,
    auth.AuthLocalDataSource localDataSource,
    auth.SessionManager sessionManager,
  ) {
    return auth.AuthRepositoryImpl(
      remoteDataSource,
      localDataSource,
      sessionManager,
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
  auth.RestoreSessionUseCase restoreSessionUseCase(auth.AuthRepository repository) {
    return auth.RestoreSessionUseCase(repository);
  }

  @lazySingleton
  Dio dio(
    api_client.AppDioFactory factory,
    api_client.AuthTokenProvider tokenProvider,
  ) {
    return factory.create(tokenProvider: tokenProvider);
  }

  @lazySingleton
  api_client.ProfileApiClient profileApiClient(Dio dio) {
    return api_client.ProfileApiClient(dio);
  }
}
