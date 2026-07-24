import 'package:auth/auth.dart' as auth;
import 'package:core/core.dart';
import 'package:drift/native.dart';
import 'package:flutter_architecture/app/database/app_database.dart';
import 'package:flutter_architecture/app/database/dao/auth_user_dao.dart';
import 'package:flutter_architecture/features/auth/data/stores/drift_auth_user_store.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('readUser returns null when slot does not exist', () async {
    final database = AppDatabase.forTesting(NativeDatabase.memory());
    addTearDown(database.close);
    final store = DriftAuthUserStore(AuthUserDao(database));

    expect(await store.readUser(), isNull);
  });

  test('writeUser replaces the single active user', () async {
    final database = AppDatabase.forTesting(NativeDatabase.memory());
    addTearDown(database.close);
    final store = DriftAuthUserStore(AuthUserDao(database));

    await store.writeUser(const auth.AuthUser(id: 'user-a', name: 'User A'));
    await store.writeUser(const auth.AuthUser(id: 'user-b', name: 'User B'));

    expect(
      await store.readUser(),
      const auth.AuthUser(id: 'user-b', name: 'User B'),
    );
    final rows = await database.customSelect('SELECT * FROM auth_user').get();
    expect(rows, hasLength(1));
    expect(rows.single.read<int>('slot'), 1);
  });

  test('clearUser is idempotent', () async {
    final database = AppDatabase.forTesting(NativeDatabase.memory());
    addTearDown(database.close);
    final store = DriftAuthUserStore(AuthUserDao(database));

    await store.writeUser(const auth.AuthUser(id: 'user-a', name: 'User A'));
    await store.clearUser();
    await store.clearUser();

    expect(await store.readUser(), isNull);
  });

  test(
    'database operational failure becomes local storage exception',
    () async {
      final database = AppDatabase.forTesting(NativeDatabase.memory());
      addTearDown(database.close);
      final store = DriftAuthUserStore(AuthUserDao(database));
      await database.customStatement('DROP TABLE auth_user');

      try {
        await store.readUser();
        fail('Expected AppException');
      } on AppException catch (error) {
        expect(error.kind, AppExceptionKind.localStorage);
        expect(error.cause, isA<SqliteException>());
        expect(error.stackTrace, isNotNull);
      }
    },
  );
}
