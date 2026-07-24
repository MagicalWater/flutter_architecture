import 'package:drift/drift.dart';
import 'package:flutter_architecture/app/database/app_database.dart';

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
