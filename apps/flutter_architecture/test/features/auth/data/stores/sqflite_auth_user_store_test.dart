import 'package:auth/auth.dart';
import 'package:core/core.dart';
import 'package:flutter_architecture/app/database/app_database_schema.dart';
import 'package:flutter_architecture/features/auth/data/stores/sqflite_auth_user_store.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  sqfliteFfiInit();

  test('readUser returns null when slot does not exist', () async {
    final database = await _openDatabase();
    addTearDown(database.close);
    final store = SqfliteAuthUserStore(database);

    expect(await store.readUser(), isNull);
  });

  test('writeUser replaces the single active user', () async {
    final database = await _openDatabase();
    addTearDown(database.close);
    final store = SqfliteAuthUserStore(database);

    await store.writeUser(const AuthUser(id: 'user-a', name: 'User A'));
    await store.writeUser(const AuthUser(id: 'user-b', name: 'User B'));

    expect(
      await store.readUser(),
      const AuthUser(id: 'user-b', name: 'User B'),
    );
    final rows = await database.query('auth_user');
    expect(rows, hasLength(1));
    expect(rows.single['slot'], 1);
  });

  test('clearUser is idempotent', () async {
    final database = await _openDatabase();
    addTearDown(database.close);
    final store = SqfliteAuthUserStore(database);

    await store.writeUser(const AuthUser(id: 'user-a', name: 'User A'));
    await store.clearUser();
    await store.clearUser();

    expect(await store.readUser(), isNull);
  });

  test(
    'database operational failure becomes local storage exception',
    () async {
      final database = await databaseFactoryFfi.openDatabase(
        inMemoryDatabasePath,
      );
      addTearDown(database.close);
      final store = SqfliteAuthUserStore(database);

      try {
        await store.readUser();
        fail('Expected AppException');
      } on AppException catch (error) {
        expect(error.kind, AppExceptionKind.localStorage);
        expect(error.cause, isA<DatabaseException>());
        expect(error.stackTrace, isNotNull);
      }
    },
  );

  test('invalid row mapping remains an unexpected error', () async {
    final database = await databaseFactoryFfi.openDatabase(
      inMemoryDatabasePath,
      options: OpenDatabaseOptions(
        onCreate: (db, version) async {
          await db.execute('''
            CREATE TABLE auth_user (
              slot INTEGER PRIMARY KEY,
              id INTEGER NOT NULL,
              name TEXT NOT NULL
            )
          ''');
        },
        version: 1,
      ),
    );
    addTearDown(database.close);
    await database.insert('auth_user', <String, Object?>{
      'slot': 1,
      'id': 123,
      'name': 'Invalid User',
    });
    final store = SqfliteAuthUserStore(database);

    await expectLater(store.readUser(), throwsA(isA<TypeError>()));
  });
}

Future<Database> _openDatabase() {
  return databaseFactoryFfi.openDatabase(
    inMemoryDatabasePath,
    options: OpenDatabaseOptions(
      version: AppDatabaseSchema.version,
      onCreate: AppDatabaseSchema.onCreate,
      onUpgrade: AppDatabaseSchema.onUpgrade,
    ),
  );
}
