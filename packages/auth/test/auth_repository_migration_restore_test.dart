import 'dart:async';
import 'dart:io';

import 'package:api_client/api_client.dart';
import 'package:auth/auth.dart';
import 'package:core/core.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const tokens = StoredAuthTokens(
    accessToken: 'secure-access',
    refreshToken: 'secure-refresh',
    userId: 'user-1',
  );
  const user = AuthUser(id: 'user-1', name: 'User');

  test('restore authority constructors remain explicit and nonnullable', () {
    final source = File(
      'lib/src/data/repositories/auth_repository_impl.dart',
    ).readAsStringSync();

    expect(source, contains('const AuthRepositoryImpl('));
    expect(source, isNot(contains('AuthCredentialMigrationCoordinator?')));
    expect(source, isNot(contains('AuthLifecycleDiagnosticSink?')));
    expect(source, isNot(contains('secureLifecycle')));
    expect(source, contains('this._migrationCoordinator'));
    expect(source, contains('this._diagnosticSink'));
  });

  test(
    'secure restore commits session and reports diagnostics best effort',
    () async {
      final secure = _CredentialStore(const AuthCredentialReadPresent(tokens));
      final legacy = _LegacyStore(
        const AuthCredentialReadPresent(tokens),
        clearError: const AppException(
          kind: AppExceptionKind.localStorage,
          message: 'legacy cleanup failed',
        ),
      );
      final userStore = _UserStore(user);
      final session = SessionManager();
      final mutationCoordinator = _TrackingMutationCoordinator();
      final sink = _RecordingSink(
        throwOnReport: true,
        onReport: () {
          expect(mutationCoordinator.isHeld, isFalse);
          expect(session.currentSession?.userId, 'user-1');
        },
      );
      final repository = _repository(
        secure,
        legacy,
        userStore,
        session,
        sink,
        mutationCoordinator: mutationCoordinator,
      );

      final result = await repository.restoreSession();

      expect(result, isA<Success<AuthUser?>>());
      expect(session.currentSession?.accessToken, 'secure-access');
      expect(session.currentSession?.userId, 'user-1');
      expect(sink.diagnostics, hasLength(1));
      expect(
        sink.diagnostics.single.operation,
        AuthLifecycleDiagnosticOperation.migrationLegacyCleanup,
      );
    },
  );

  test('migration unauthenticated clears runtime session', () async {
    final session = SessionManager()
      ..setAuthenticated(accessToken: 'old', userId: 'old-user');
    final repository = _repository(
      _CredentialStore(const AuthCredentialReadAbsent()),
      _LegacyStore(const AuthCredentialReadAbsent()),
      _UserStore(null),
      session,
      _RecordingSink(),
    );

    final result = await repository.restoreSession();

    expect(result, isA<Success<AuthUser?>>());
    expect((result as Success<AuthUser?>).data, isNull);
    expect(session.currentSession, isNull);
  });

  test('migration local storage failure maps to restore Failure', () async {
    final repository = _repository(
      _CredentialStore(
        const AuthCredentialReadAbsent(),
        readError: const AppException(
          kind: AppExceptionKind.localStorage,
          message: 'secure unavailable',
        ),
      ),
      _LegacyStore(const AuthCredentialReadAbsent()),
      _UserStore(null),
      SessionManager(),
      _RecordingSink(),
    );

    final result = await repository.restoreSession();

    expect(result, isA<FailureResult<AuthUser?>>());
  });

  test('migration data corruption maps to restore Failure', () async {
    final repository = _repository(
      _CredentialStore(
        const AuthCredentialReadAbsent(),
        postWriteResult: const AuthCredentialReadAbsent(),
      ),
      _LegacyStore(const AuthCredentialReadPresent(tokens)),
      _UserStore(user),
      SessionManager(),
      _RecordingSink(),
    );

    final result = await repository.restoreSession();

    expect(result, isA<FailureResult<AuthUser?>>());
  });

  test('migration unknown error preserves identity', () async {
    final unknown = StateError('secure bug');
    final repository = _repository(
      _CredentialStore(const AuthCredentialReadAbsent(), readError: unknown),
      _LegacyStore(const AuthCredentialReadAbsent()),
      _UserStore(null),
      SessionManager(),
      _RecordingSink(),
    );

    await expectLater(repository.restoreSession(), throwsA(same(unknown)));
  });

  test('newer lifecycle intent supersedes blocked migration restore', () async {
    final secure = _BlockingCredentialStore(
      const AuthCredentialReadPresent(tokens),
    );
    final session = SessionManager();
    final repository = _repository(
      secure,
      _LegacyStore(const AuthCredentialReadAbsent()),
      _UserStore(user),
      session,
      _RecordingSink(),
    );

    final restore = repository.restoreSession();
    await secure.readStarted;
    final logout = repository.logout();
    secure.releaseRead();

    await expectLater(
      restore,
      throwsA(isA<AuthLifecycleOperationSuperseded>()),
    );
    expect(await logout, isA<Success<void>>());
    expect(session.currentSession, isNull);
  });
}

AuthRepositoryImpl _repository(
  AuthCredentialStore secure,
  AuthLegacyCredentialStore legacy,
  AuthUserStore userStore,
  SessionManager session,
  AuthLifecycleDiagnosticSink sink, {
  AuthStateMutationCoordinator? mutationCoordinator,
}) {
  return AuthRepositoryImpl(
    AuthRemoteDataSource(MockAuthApi()),
    secure,
    legacy,
    userStore,
    session,
    mutationCoordinator ?? AuthStateMutationCoordinator(),
    AuthCredentialMigrationCoordinator(secure, legacy, userStore),
    sink,
  );
}

class _CredentialStore implements AuthCredentialStore {
  _CredentialStore(this.result, {this.readError, this.postWriteResult});
  AuthCredentialReadResult result;
  final Object? readError;
  final AuthCredentialReadResult? postWriteResult;

  @override
  Future<void> clearCredential() async {
    result = const AuthCredentialReadAbsent();
  }

  @override
  Future<AuthCredentialReadResult> readCredential() async {
    final error = readError;
    if (error != null) throw error;
    return result;
  }

  @override
  Future<void> writeCredential(StoredAuthTokens tokens) async {
    result = postWriteResult ?? AuthCredentialReadPresent(tokens);
  }
}

final class _BlockingCredentialStore extends _CredentialStore {
  _BlockingCredentialStore(super.result);
  final _started = Completer<void>();
  final _release = Completer<void>();
  Future<void> get readStarted => _started.future;
  void releaseRead() => _release.complete();

  @override
  Future<AuthCredentialReadResult> readCredential() async {
    if (!_started.isCompleted) _started.complete();
    await _release.future;
    return super.readCredential();
  }
}

final class _LegacyStore implements AuthLegacyCredentialStore {
  _LegacyStore(this.result, {this.clearError});
  AuthCredentialReadResult result;
  final Object? clearError;

  @override
  Future<void> clearLegacyCredential() async {
    final error = clearError;
    if (error != null) throw error;
    result = const AuthCredentialReadAbsent();
  }

  @override
  Future<AuthCredentialReadResult> readLegacyCredential() async => result;
}

final class _UserStore implements AuthUserStore {
  _UserStore(this.value);
  AuthUser? value;

  @override
  Future<void> clearUser() async => value = null;
  @override
  Future<AuthUser?> readUser() async => value;
  @override
  Future<void> writeUser(AuthUser user) async => value = user;
}

final class _RecordingSink implements AuthLifecycleDiagnosticSink {
  _RecordingSink({this.throwOnReport = false, this.onReport});
  final bool throwOnReport;
  final void Function()? onReport;
  final List<AuthLifecycleDiagnostic> diagnostics = <AuthLifecycleDiagnostic>[];

  @override
  void reportAll(Iterable<AuthLifecycleDiagnostic> diagnostics) {
    onReport?.call();
    this.diagnostics.addAll(diagnostics);
    if (throwOnReport) throw StateError('reporter failed');
  }
}

final class _TrackingMutationCoordinator extends AuthStateMutationCoordinator {
  bool isHeld = false;

  @override
  Future<T> runExclusive<T>(Future<T> Function() action) {
    return super.runExclusive(() async {
      isHeld = true;
      try {
        return await action();
      } finally {
        isHeld = false;
      }
    });
  }
}
