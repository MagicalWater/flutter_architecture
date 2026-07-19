import 'package:auth/auth.dart';
import 'package:auth/src/data/models/auth_user_model.dart';
import 'package:flutter_architecture/app/database/app_database_schema.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  sqfliteFfiInit();

  test('sequential user writes只保留最新active user', () async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    final preferences = await SharedPreferences.getInstance();
    final database = await databaseFactoryFfi.openDatabase(
      inMemoryDatabasePath,
      options: OpenDatabaseOptions(
        version: AppDatabaseSchema.version,
        onCreate: AppDatabaseSchema.onCreate,
        onUpgrade: AppDatabaseSchema.onUpgrade,
      ),
    );
    addTearDown(database.close);
    final local = AuthLocalDataSource(preferences, database);

    await local.saveUser(const AuthUserModel(id: 'user-a', name: 'User A'));
    await local.saveUser(const AuthUserModel(id: 'user-b', name: 'User B'));

    final rows = await database.query('auth_user');
    expect(rows, hasLength(1));
    expect(rows.single['slot'], 1);
    expect(rows.single['id'], 'user-b');
    expect((await local.readUser())?.id, 'user-b');
  });

  test('v4 single row upgrade會保留user並轉為固定slot', () async {
    final path = await databaseFactoryFfi.getDatabasesPath();
    final databasePath = '$path/auth-single-row-v4-upgrade.db';
    await databaseFactoryFfi.deleteDatabase(databasePath);
    addTearDown(() => databaseFactoryFfi.deleteDatabase(databasePath));

    final old = await databaseFactoryFfi.openDatabase(
      databasePath,
      options: OpenDatabaseOptions(
        version: 4,
        onCreate: (db, version) async {
          await db.execute('''
            CREATE TABLE auth_user (
              id TEXT PRIMARY KEY,
              name TEXT NOT NULL
            )
          ''');
        },
      ),
    );
    await old.insert('auth_user', <String, Object?>{
      'id': 'user-a',
      'name': 'User A',
    });
    await old.close();

    final upgraded = await databaseFactoryFfi.openDatabase(
      databasePath,
      options: OpenDatabaseOptions(
        version: AppDatabaseSchema.version,
        onUpgrade: AppDatabaseSchema.onUpgrade,
      ),
    );
    addTearDown(upgraded.close);

    final rows = await upgraded.query('auth_user');
    expect(rows, hasLength(1));
    expect(rows.single['slot'], 1);
    expect(rows.single['id'], 'user-a');
  });

  test('v4 multi-row upgrade會清除無法證明identity的users', () async {
    final path = await databaseFactoryFfi.getDatabasesPath();
    final databasePath = '$path/auth-multi-row-v4-upgrade.db';
    await databaseFactoryFfi.deleteDatabase(databasePath);
    addTearDown(() => databaseFactoryFfi.deleteDatabase(databasePath));

    final old = await databaseFactoryFfi.openDatabase(
      databasePath,
      options: OpenDatabaseOptions(
        version: 4,
        onCreate: (db, version) async {
          await db.execute('''
            CREATE TABLE auth_user (
              id TEXT PRIMARY KEY,
              name TEXT NOT NULL
            )
          ''');
        },
      ),
    );
    await old.insert('auth_user', <String, Object?>{
      'id': 'user-a',
      'name': 'User A',
    });
    await old.insert('auth_user', <String, Object?>{
      'id': 'user-b',
      'name': 'User B',
    });
    await old.close();

    final upgraded = await databaseFactoryFfi.openDatabase(
      databasePath,
      options: OpenDatabaseOptions(
        version: AppDatabaseSchema.version,
        onUpgrade: AppDatabaseSchema.onUpgrade,
      ),
    );
    addTearDown(upgraded.close);

    expect(await upgraded.query('auth_user'), isEmpty);
  });
}
