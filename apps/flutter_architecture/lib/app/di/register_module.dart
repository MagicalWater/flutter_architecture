import 'package:api_client/api_client.dart';
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
  AppDioFactory get appDioFactory => const AppDioFactory();

  @lazySingleton
  AuthApiClient get authApiClient => const AuthApiClient();

  @lazySingleton
  Dio dio(
    AppDioFactory factory,
    AuthTokenProvider tokenProvider,
  ) {
    return factory.create(tokenProvider: tokenProvider);
  }

  @lazySingleton
  ProfileApiClient profileApiClient(Dio dio) {
    return ProfileApiClient(dio);
  }
}
