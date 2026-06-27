import 'package:api_client/api_client.dart';
import 'package:auth/src/data/models/auth_user_model.dart';
import 'package:auth/src/session/token_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';

/// Auth 本地資料來源。
///
/// ## 所屬 Layer
///
/// Data Layer。
///
/// ## 責任
///
/// - token 存在 SharedPreferences。
/// - profile 存在 SQLite。
///
/// 這樣可以示範兩種常見本地持久化方式。
class AuthLocalDataSource implements AuthTokenProvider, TokenStorage {
  const AuthLocalDataSource(
    this._preferences,
    this._database,
  );

  static const String _accessTokenKey = 'auth.accessToken';
  static const String _userTable = 'auth_user';

  final SharedPreferences _preferences;
  final Database _database;

  @override
  Future<void> saveAccessToken(String token) async {
    await _preferences.setString(_accessTokenKey, token);
  }

  @override
  Future<String?> readAccessToken() async {
    return _preferences.getString(_accessTokenKey);
  }

  /// 給 Dio interceptor 使用的 token 讀取方法。
  ///
  /// Interceptor 只知道 AuthTokenProvider，
  /// 不需要知道 token 實際上存在 SharedPreferences。
  @override
  Future<String?> getAccessToken() {
    return readAccessToken();
  }

  @override
  Future<void> clearAccessToken() async {
    await _preferences.remove(_accessTokenKey);
  }

  Future<void> saveUser(AuthUserModel user) async {
    await _database.insert(
      _userTable,
      user.toJson(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<AuthUserModel?> readUser() async {
    final rows = await _database.query(_userTable, limit: 1);

    if (rows.isEmpty) {
      return null;
    }

    return AuthUserModel.fromJson(rows.first);
  }

  Future<void> clearUser() async {
    await _database.delete(_userTable);
  }
}
