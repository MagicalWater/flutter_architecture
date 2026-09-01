import 'package:auth/auth_infrastructure.dart';
import 'package:core/core.dart';
import 'package:sqflite/sqflite.dart';

final class SqfliteAuthUserStore implements AuthUserStore {
  const SqfliteAuthUserStore(this._database);

  final Database _database;

  @override
  Future<AuthUser?> readUser() async {
    try {
      final rows = await _database.query(
        'auth_user',
        where: 'slot = ?',
        whereArgs: const <Object?>[1],
        limit: 1,
      );
      if (rows.isEmpty) return null;
      return AuthUser(
        id: rows.single['id'] as String,
        name: rows.single['name'] as String,
      );
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
      await _database.insert('auth_user', <String, Object?>{
        'slot': 1,
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
        'auth_user',
        where: 'slot = ?',
        whereArgs: const <Object?>[1],
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
