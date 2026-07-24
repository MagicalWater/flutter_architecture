import 'package:auth/auth.dart' as auth;
import 'package:core/core.dart';
import 'package:flutter_architecture/app/database/dao/auth_user_dao.dart';
import 'package:sqlite3/sqlite3.dart';

/// 以App-owned Drift DAO實作公開的AuthUserStore contract。
final class DriftAuthUserStore implements auth.AuthUserStore {
  const DriftAuthUserStore(this._dao);

  final AuthUserDao _dao;

  @override
  Future<auth.AuthUser?> readUser() async {
    try {
      final row = await _dao.readActive();
      if (row == null) return null;
      return auth.AuthUser(id: row.id, name: row.name);
    } on SqliteException catch (error, stackTrace) {
      _throwStorageFailure('讀取登入使用者失敗', error, stackTrace);
    }
  }

  @override
  Future<void> writeUser(auth.AuthUser user) async {
    try {
      await _dao.replaceActive(id: user.id, name: user.name);
    } on SqliteException catch (error, stackTrace) {
      _throwStorageFailure('儲存登入使用者失敗', error, stackTrace);
    }
  }

  @override
  Future<void> clearUser() async {
    try {
      await _dao.clearActive();
    } on SqliteException catch (error, stackTrace) {
      _throwStorageFailure('清除登入使用者失敗', error, stackTrace);
    }
  }
}

Never _throwStorageFailure(
  String message,
  SqliteException error,
  StackTrace stackTrace,
) {
  Error.throwWithStackTrace(
    AppException(
      kind: AppExceptionKind.localStorage,
      message: message,
      cause: error,
      stackTrace: stackTrace,
    ),
    stackTrace,
  );
}
