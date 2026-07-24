import 'package:api_client/api_client.dart';
import 'package:auth/auth.dart';
import 'package:core/core.dart';
import 'package:drift/native.dart';
import 'package:flutter_architecture/app/database/app_database.dart' as db;
import 'package:flutter_architecture/app/database/dao/auth_user_dao.dart';
import 'package:flutter_architecture/features/auth/data/stores/drift_auth_user_store.dart';
import 'package:flutter_architecture/features/auth/data/stores/flutter_secure_auth_credential_store.dart';
import 'package:flutter_architecture/features/auth/data/stores/shared_preferences_auth_legacy_credential_store.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    FlutterSecureStorage.setMockInitialValues(<String, String>{});
    SharedPreferences.setMockInitialValues(<String, Object>{});
  });

  test('Sequential Login A再Login B後restart只restore User B', () async {
    final preferences = await SharedPreferences.getInstance();
    final database = db.AppDatabase.forTesting(NativeDatabase.memory());
    addTearDown(database.close);
    final credentialStore = FlutterSecureAuthCredentialStore(
      const FlutterSecureStorage(),
    );
    final legacyCredentialStore = SharedPreferencesAuthLegacyCredentialStore(
      preferences,
    );
    final userStore = DriftAuthUserStore(AuthUserDao(database));
    final firstSession = SessionManager();
    addTearDown(firstSession.dispose);
    final repository = _repository(
      api: _SequencedAuthApi(const <LoginResponseDto>[
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
      credentialStore: credentialStore,
      legacyCredentialStore: legacyCredentialStore,
      userStore: userStore,
      session: firstSession,
    );

    await repository.login(account: 'a', password: 'password');
    await repository.login(account: 'b', password: 'password');

    final restartedSession = SessionManager();
    addTearDown(restartedSession.dispose);
    final restartedRepository = _repository(
      api: _SequencedAuthApi(const <LoginResponseDto>[]),
      credentialStore: credentialStore,
      legacyCredentialStore: legacyCredentialStore,
      userStore: userStore,
      session: restartedSession,
    );
    final restored = await restartedRepository.restoreSession();

    expect(restored, isA<Success<AuthUser?>>());
    expect((restored as Success<AuthUser?>).data?.id, 'user-b');
    final credential = await credentialStore.readCredential();
    expect((credential as AuthCredentialReadPresent).tokens.userId, 'user-b');
    expect((await userStore.readUser())?.id, 'user-b');
    expect(restartedSession.currentSession?.userId, 'user-b');
    final rows = await database.customSelect('SELECT * FROM auth_user').get();
    expect(rows, hasLength(1));
    expect(rows.single.read<int>('slot'), 1);
  });

  test('Restore identity mismatch會清除Drift user與secure credential', () async {
    final preferences = await SharedPreferences.getInstance();
    final database = db.AppDatabase.forTesting(NativeDatabase.memory());
    addTearDown(database.close);
    final credentialStore = FlutterSecureAuthCredentialStore(
      const FlutterSecureStorage(),
    );
    final legacyCredentialStore = SharedPreferencesAuthLegacyCredentialStore(
      preferences,
    );
    final userStore = DriftAuthUserStore(AuthUserDao(database));
    await credentialStore.writeCredential(
      const StoredAuthTokens(
        accessToken: 'access-a',
        refreshToken: 'refresh-a',
        userId: 'user-a',
      ),
    );
    await userStore.writeUser(const AuthUser(id: 'user-b', name: 'User B'));
    final session = SessionManager();
    addTearDown(session.dispose);
    final repository = _repository(
      api: _SequencedAuthApi(const <LoginResponseDto>[]),
      credentialStore: credentialStore,
      legacyCredentialStore: legacyCredentialStore,
      userStore: userStore,
      session: session,
    );

    final result = await repository.restoreSession();

    expect(result, isA<Success<AuthUser?>>());
    expect((result as Success<AuthUser?>).data, isNull);
    expect(await credentialStore.readCredential(), isA<AuthCredentialReadAbsent>());
    expect(await userStore.readUser(), isNull);
    expect(session.currentSession, isNull);
  });
}

AuthRepositoryImpl _repository({
  required AuthApi api,
  required AuthCredentialStore credentialStore,
  required AuthLegacyCredentialStore legacyCredentialStore,
  required AuthUserStore userStore,
  required SessionManager session,
}) {
  return AuthRepositoryImpl(
    AuthRemoteDataSource(api),
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
