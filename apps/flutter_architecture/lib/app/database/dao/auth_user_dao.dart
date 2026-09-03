import 'package:drift/drift.dart';
import 'package:flutter_architecture/app/database/app_database.dart';

/// 讀寫 Drift 中唯一一筆「目前登入使用者」資料。
///
/// 固定使用 slot 1，避免其他層自己決定 table key；上層只需要處理 read／replace／clear。
final class AuthUserDao {
  const AuthUserDao(this._database);

  static const int _activeSlot = 1;

  final AppDatabase _database;

  Future<AuthUserData?> readActive() {
    final query = _database.select(_database.authUser)
      ..where((table) => table.slot.equals(_activeSlot))
      ..limit(1);
    return query.getSingleOrNull();
  }

  Future<void> replaceActive({required String id, required String name}) {
    return _database
        .into(_database.authUser)
        .insert(
          AuthUserCompanion.insert(
            slot: const Value(_activeSlot),
            id: id,
            name: name,
          ),
          mode: InsertMode.insertOrReplace,
        );
  }

  Future<void> clearActive() async {
    await (_database.delete(
      _database.authUser,
    )..where((table) => table.slot.equals(_activeSlot))).go();
  }
}
