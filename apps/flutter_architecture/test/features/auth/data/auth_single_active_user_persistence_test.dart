import 'dart:convert';

import 'package:api_client/api_client.dart';
import 'package:auth/auth.dart';
import 'package:core/core.dart';
import 'package:flutter_architecture/app/database/app_database_schema.dart';
import 'package:flutter_architecture/features/auth/data/stores/flutter_secure_auth_credential_store.dart';
import 'package:flutter_architecture/features/auth/data/stores/shared_preferences_auth_legacy_credential_store.dart';
import 'package:flutter_architecture/features/auth/data/stores/sqflite_auth_user_store.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  sqfliteFfiInit();

  setUp(() {
    FlutterSecureStorage.setMockInitialValues(<String, String>{});
  });

  test('sequential user writes只保留最新active user', () async {
    final database = await databaseFactoryFfi.openDatabase(
      inMemoryDatabasePath,
      options: OpenDatabaseOptions(
        version: AppDatabaseSchema.version,
        onCreate: AppDatabaseSchema.onCreate,
        onUpgrade: AppDatabaseSchema.onUpgrade,
      ),
    );
    addTearDown(database.close);
    final userStore = SqfliteAuthUserStore(database);

    await userStore.writeUser(const AuthUser(id: 'user-a', name: 'User A'));
    await userStore.writeUser(const AuthUser(id: 'user-b', name: 'User B'));

    final rows = await database.query('auth_user');
    expect(rows, hasLength(1));
    expect(rows.single['slot'], 1);
    expect(rows.single['id'], 'user-b');
    expect((await userStore.readUser())?.id, 'user-b');
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

  test('schema拒絕非法slot與第二個active row', () async {
    final database = await databaseFactoryFfi.openDatabase(
      inMemoryDatabasePath,
      options: OpenDatabaseOptions(
        version: AppDatabaseSchema.version,
        onCreate: AppDatabaseSchema.onCreate,
      ),
    );
    addTearDown(database.close);

    await expectLater(
      database.insert('auth_user', <String, Object?>{
        'slot': 2,
        'id': 'user-a',
        'name': 'User A',
      }),
      throwsA(isA<DatabaseException>()),
    );
    await database.insert('auth_user', <String, Object?>{
      'slot': 1,
      'id': 'user-a',
      'name': 'User A',
    });
    await expectLater(
      database.insert('auth_user', <String, Object?>{
        'slot': 1,
        'id': 'user-b',
        'name': 'User B',
      }),
      throwsA(isA<DatabaseException>()),
    );
  });

  test('v4 multi-row與existing token升級後restore會清除全部auth state', () async {
    SharedPreferences.setMockInitialValues(<String, Object>{
      'auth.tokens': jsonEncode(<String, Object?>{
        'accessToken': 'legacy-access',
        'refreshToken': 'legacy-refresh',
      }),
    });
    final preferences = await SharedPreferences.getInstance();
    final path = await databaseFactoryFfi.getDatabasesPath();
    final databasePath = '$path/auth-multi-row-restore-v4-upgrade.db';
    await databaseFactoryFfi.deleteDatabase(databasePath);
    addTearDown(() => databaseFactoryFfi.deleteDatabase(databasePath));

    final old = await databaseFactoryFfi.openDatabase(
      databasePath,
      options: OpenDatabaseOptions(
        version: 4,
        onCreate: (db, version) async {
          await db.execute(
            'CREATE TABLE auth_user (id TEXT PRIMARY KEY, name TEXT NOT NULL)',
          );
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
    final credentialStore = FlutterSecureAuthCredentialStore(
      const FlutterSecureStorage(),
    );
    final legacyCredentialStore = SharedPreferencesAuthLegacyCredentialStore(
      preferences,
    );
    final userStore = SqfliteAuthUserStore(upgraded);
    final session = SessionManager();
    addTearDown(session.dispose);
    final repository = AuthRepositoryImpl(
      AuthRemoteDataSource(_SequencedAuthApi(const <LoginResponseDto>[])),
      credentialStore,
      legacyCredentialStore,
      userStore,
      session,
      AuthStateMutationCoordinator(),
      AuthCredentialMigrationCoordinator(
        credentialStore,
        legacyCredentialStore,
        userStore,
      ),
      const _NoopLifecycleDiagnosticSink(),
    );

    final result = await repository.restoreSession();

    expect(result, isA<Success<AuthUser?>>());
    expect(
      await credentialStore.readCredential(),
      isA<AuthCredentialReadAbsent>(),
    );
    expect(await userStore.readUser(), isNull);
    expect(session.currentSession, isNull);
  });

  test('Sequential Login A再Login B後restart只restore User B', () async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    final preferences = await SharedPreferences.getInstance();
    final database = await databaseFactoryFfi.openDatabase(
      inMemoryDatabasePath,
      options: OpenDatabaseOptions(
        version: AppDatabaseSchema.version,
        onCreate: AppDatabaseSchema.onCreate,
      ),
    );
    addTearDown(database.close);
    final credentialStore = FlutterSecureAuthCredentialStore(
      const FlutterSecureStorage(),
    );
    final legacyCredentialStore = SharedPreferencesAuthLegacyCredentialStore(
      preferences,
    );
    final userStore = SqfliteAuthUserStore(database);
    final firstSession = SessionManager();
    addTearDown(firstSession.dispose);
    final repository = AuthRepositoryImpl(
      AuthRemoteDataSource(
        _SequencedAuthApi(const <LoginResponseDto>[
          LoginResponseDto.authenticated(
            authenticated: AuthenticatedResponseDto(
              accessToken: 'access-a',
              refreshToken: 'refresh-a',
              userId: 'user-a',
              userName: 'User A',
            ),
          ),
          LoginResponseDto.authenticated(
            authenticated: AuthenticatedResponseDto(
              accessToken: 'access-b',
              refreshToken: 'refresh-b',
              userId: 'user-b',
              userName: 'User B',
            ),
          ),
        ]),
      ),
      credentialStore,
      legacyCredentialStore,
      userStore,
      firstSession,
      AuthStateMutationCoordinator(),
      AuthCredentialMigrationCoordinator(
        credentialStore,
        legacyCredentialStore,
        userStore,
      ),
      const _NoopLifecycleDiagnosticSink(),
    );

    await repository.login(account: 'a', password: 'password');
    await repository.login(account: 'b', password: 'password');

    final restartedSession = SessionManager();
    addTearDown(restartedSession.dispose);
    final restartedRepository = AuthRepositoryImpl(
      AuthRemoteDataSource(_SequencedAuthApi(const <LoginResponseDto>[])),
      credentialStore,
      legacyCredentialStore,
      userStore,
      restartedSession,
      AuthStateMutationCoordinator(),
      AuthCredentialMigrationCoordinator(
        credentialStore,
        legacyCredentialStore,
        userStore,
      ),
      const _NoopLifecycleDiagnosticSink(),
    );
    final restored = await restartedRepository.restoreSession();

    expect(restored, isA<Success<AuthUser?>>());
    expect((restored as Success<AuthUser?>).data?.id, 'user-b');
    final credential = await credentialStore.readCredential();
    expect((credential as AuthCredentialReadPresent).tokens.userId, 'user-b');
    expect((await userStore.readUser())?.id, 'user-b');
    expect(restartedSession.currentSession?.userId, 'user-b');
    expect(await database.query('auth_user'), hasLength(1));
  });
}

class _SequencedAuthApi implements AuthApi {
  _SequencedAuthApi(this.responses);

  final List<LoginResponseDto> responses;
  int _index = 0;

  @override
  Future<LoginResponseDto> login(LoginRequestDto request) async {
    return responses[_index++];
  }

  @override
  Future<AuthenticatedResponseDto> verifyOtp(VerifyOtpRequestDto request) =>
      throw UnimplementedError();

  @override
  Future<OtpChallengeDto> resendOtp(ResendOtpRequestDto request) =>
      throw UnimplementedError();
}

final class _NoopLifecycleDiagnosticSink
    implements AuthLifecycleDiagnosticSink {
  const _NoopLifecycleDiagnosticSink();

  @override
  void reportAll(Iterable<AuthLifecycleDiagnostic> diagnostics) {}
}
