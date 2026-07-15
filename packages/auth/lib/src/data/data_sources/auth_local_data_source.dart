import 'package:api_client/api_client.dart';
import 'package:auth/src/data/models/auth_user_model.dart';
import 'package:auth/src/session/token_storage.dart';
import 'package:core/core.dart';
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
    await _guardLocal(
      () => _preferences.setString(_accessTokenKey, token),
      message: '儲存 access token 失敗',
    );
  }

  @override
  Future<String?> readAccessToken() async {
    return _guardLocal(
      () async => _preferences.getString(_accessTokenKey),
      message: '讀取 access token 失敗',
    );
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
    await _guardLocal(
      () => _preferences.remove(_accessTokenKey),
      message: '清除 access token 失敗',
    );
  }

  Future<void> saveUser(AuthUserModel user) async {
    await _guardLocal(
      () => _database.insert(
        _userTable,
        user.toJson(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      ),
      message: '儲存登入使用者失敗',
    );
  }

  Future<AuthUserModel?> readUser() async {
    final rows = await _guardLocal(
      () => _database.query(_userTable, limit: 1),
      message: '讀取登入使用者失敗',
    );

    if (rows.isEmpty) {
      return null;
    }

    return AuthUserModel.fromJson(rows.first);
  }

  Future<void> clearUser() async {
    await _guardLocal(
      () => _database.delete(_userTable),
      message: '清除登入使用者失敗',
    );
  }

  Future<T> _guardLocal<T>(
    Future<T> Function() action, {
    required String message,
  }) async {
    try {
      return await action();
    } on AppException {
      rethrow;
    } catch (error, stackTrace) {
      Error.throwWithStackTrace(
        AppException(message: message, cause: error),
        stackTrace,
      );
    }
  }
}
