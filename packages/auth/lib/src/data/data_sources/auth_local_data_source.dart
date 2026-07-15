import 'dart:convert';

import 'package:auth/src/data/models/auth_user_model.dart';
import 'package:auth/src/data/models/stored_auth_tokens.dart';
import 'package:auth/src/data/exceptions/corrupted_auth_tokens_exception.dart';
import 'package:auth/src/data/data_sources/auth_local_store.dart';
import 'package:auth/src/data/data_sources/auth_refresh_local_store.dart';
import 'package:auth/src/session/auth_token_storage.dart';
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
class AuthLocalDataSource
    implements AuthTokenStorage, AuthLocalStore, AuthRefreshLocalStore {
  const AuthLocalDataSource(
    this._preferences,
    this._database,
  );

  static const String _tokensKey = 'auth.tokens';
  static const String _legacyAccessTokenKey = 'auth.accessToken';
  static const String _userTable = 'auth_user';

  final SharedPreferences _preferences;
  final Database _database;

  @override
  Future<void> saveTokens(StoredAuthTokens tokens) async {
    await _guardLocal(
      () async {
        final success = await _preferences.setString(
          _tokensKey,
          jsonEncode(tokens.toJson()),
        );
        if (!success) {
          throw const AppException(message: '儲存 token pair 失敗');
        }
      },
      message: '儲存 token pair 失敗',
    );
  }

  @override
  Future<StoredAuthTokens?> readTokens() async {
    return _guardLocal(
      () async {
        final raw = _preferences.getString(_tokensKey);
        if (raw == null) {
          if (_preferences.containsKey(_legacyAccessTokenKey)) {
            await clearTokens();
          }
          return null;
        }
        try {
          final decoded = jsonDecode(raw);
          if (decoded is! Map<String, dynamic>) {
            throw const FormatException('Invalid auth token payload');
          }
          return StoredAuthTokens.fromJson(decoded);
        } on FormatException catch (error, stackTrace) {
          Error.throwWithStackTrace(
            CorruptedAuthTokensException(cause: error),
            stackTrace,
          );
        }
      },
      message: '讀取 token pair 失敗',
    );
  }

  @override
  Future<void> clearTokens() async {
    await _guardLocal(
      () async {
        final tokensRemoved = await _preferences.remove(_tokensKey);
        final legacyRemoved = await _preferences.remove(_legacyAccessTokenKey);
        if (!tokensRemoved || !legacyRemoved) {
          throw const AppException(message: '清除 token pair 失敗');
        }
      },
      message: '清除 token pair 失敗',
    );
  }

  @override
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

  @override
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

  @override
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
