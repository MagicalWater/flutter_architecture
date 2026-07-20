import 'package:auth/auth.dart';
import 'package:core/core.dart';
import 'package:sqflite/sqflite.dart';

/// 使用既有 `auth_user` single-active-row schema 保存 AuthUser。
final class SqfliteAuthUserStore implements AuthUserStore {
  const SqfliteAuthUserStore(this._database);

  static const String _table = 'auth_user';
  static const int _slot = 1;

  final Database _database;

  @override
  Future<AuthUser?> readUser() async {
    try {
      final rows = await _database.query(
        _table,
        where: 'slot = ?',
        whereArgs: const <Object?>[_slot],
        limit: 1,
      );
      if (rows.isEmpty) return null;

      final row = rows.single;
      return AuthUser(id: row['id'] as String, name: row['name'] as String);
    } on DatabaseException catch (error, stackTrace) {
      Error.throwWithStackTrace(
        AppException(
          kind: AppExceptionKind.localStorage,
          message: '讀取登入使用者失敗',
          cause: error,
          stackTrace: stackTrace,
        ),
        stackTrace,
      );
    }
  }

  @override
  Future<void> writeUser(AuthUser user) async {
    try {
      await _database.insert(_table, <String, Object?>{
        'slot': _slot,
        'id': user.id,
        'name': user.name,
      }, conflictAlgorithm: ConflictAlgorithm.replace);
    } on DatabaseException catch (error, stackTrace) {
      Error.throwWithStackTrace(
        AppException(
          kind: AppExceptionKind.localStorage,
          message: '儲存登入使用者失敗',
          cause: error,
          stackTrace: stackTrace,
        ),
        stackTrace,
      );
    }
  }

  @override
  Future<void> clearUser() async {
    try {
      await _database.delete(
        _table,
        where: 'slot = ?',
        whereArgs: const <Object?>[_slot],
      );
    } on DatabaseException catch (error, stackTrace) {
      Error.throwWithStackTrace(
        AppException(
          kind: AppExceptionKind.localStorage,
          message: '清除登入使用者失敗',
          cause: error,
          stackTrace: stackTrace,
        ),
        stackTrace,
      );
    }
  }
}
