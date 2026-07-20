import 'dart:io';

import 'package:auth/auth.dart';
import 'package:core/core.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const tokens = StoredAuthTokens(
    accessToken: 'access-secret',
    refreshToken: 'refresh-secret',
    userId: 'user-1',
  );
  const user = AuthUser(id: 'user-1', name: 'User');
  final diagnostic = AuthCredentialMigrationDiagnostic(
    operation: AuthCredentialMigrationDiagnosticOperation.legacyCleanup,
    error: StateError('plugin-secret'),
    stackTrace: StackTrace.current,
  );

  test(
    'migration result exposes closed variants with immutable diagnostics',
    () {
      final sourceDiagnostics = <AuthCredentialMigrationDiagnostic>[diagnostic];
      final unauthenticated = AuthCredentialMigrationUnauthenticated(
        diagnostics: sourceDiagnostics,
      );
      final resolved = AuthCredentialMigrationResolved(
        tokens: tokens,
        user: user,
        diagnostics: sourceDiagnostics,
      );

      sourceDiagnostics.clear();

      expect(unauthenticated, isA<AuthCredentialMigrationResult>());
      expect(resolved, isA<AuthCredentialMigrationResult>());
      expect(unauthenticated.diagnostics, hasLength(1));
      expect(resolved.diagnostics, hasLength(1));
      expect(
        () => unauthenticated.diagnostics.add(diagnostic),
        throwsUnsupportedError,
      );
      expect(() => resolved.diagnostics.clear(), throwsUnsupportedError);
    },
  );

  test('migration diagnostic preserves error and stack identity', () {
    final error = StateError('plugin-secret');
    final stackTrace = StackTrace.current;
    final value = AuthCredentialMigrationDiagnostic(
      operation: AuthCredentialMigrationDiagnosticOperation.legacyCleanup,
      error: error,
      stackTrace: stackTrace,
    );

    expect(value.error, same(error));
    expect(value.stackTrace, same(stackTrace));
  });

  test(
    'migration result and diagnostic toString do not expose credentials',
    () {
      final values = <Object>[
        AuthCredentialMigrationUnauthenticated(
          diagnostics: <AuthCredentialMigrationDiagnostic>[diagnostic],
        ),
        AuthCredentialMigrationResolved(
          tokens: tokens,
          user: user,
          diagnostics: <AuthCredentialMigrationDiagnostic>[diagnostic],
        ),
        diagnostic,
      ];

      for (final value in values) {
        final text = value.toString();
        expect(text, isNot(contains('access-secret')));
        expect(text, isNot(contains('refresh-secret')));
        expect(text, isNot(contains('plugin-secret')));
      }
    },
  );

  test('coordinator contract only accepts Auth-specific stores', () {
    final coordinator = AuthCredentialMigrationCoordinator(
      _CredentialStore(),
      _LegacyCredentialStore(),
      _UserStore(),
    );

    final resolver = coordinator.resolveUnlocked;
    expect(resolver, isA<Future<AuthCredentialMigrationResult> Function()>());
  });

  test(
    'coordinator source does not depend on session or mutation ownership',
    () {
      final source = File(
        'lib/src/data/migration/auth_credential_migration_coordinator.dart',
      ).readAsStringSync();

      expect(source, isNot(contains('SessionManager')));
      expect(source, isNot(contains('AuthStateMutationCoordinator')));
      expect(source, isNot(contains('runExclusive')));
      expect(source, isNot(contains('package:flutter')));
      expect(source, isNot(contains('package:get_it')));
      expect(source, isNot(contains('package:injectable')));
    },
  );

  group('unauthenticated and destructive matrix', () {
    test(
      'all stores absent returns unauthenticated without mutation',
      () async {
        final stores = _MigrationStores();

        final result = await stores.coordinator.resolveUnlocked();

        expect(result, isA<AuthCredentialMigrationUnauthenticated>());
        expect(stores.secure.clearCalls, 0);
        expect(stores.legacy.clearCalls, 0);
        expect(stores.user.clearCalls, 0);
      },
    );

    test('orphan user is cleared', () async {
      final stores = _MigrationStores(user: user);

      final result = await stores.coordinator.resolveUnlocked();

      expect(result, isA<AuthCredentialMigrationUnauthenticated>());
      expect(stores.user.clearCalls, 1);
    });

    test('corrupted legacy clears legacy and orphan user', () async {
      final stores = _MigrationStores(
        legacyResult: const AuthCredentialReadCorrupted(),
        user: user,
      );

      final result = await stores.coordinator.resolveUnlocked();

      expect(result, isA<AuthCredentialMigrationUnauthenticated>());
      expect(stores.legacy.clearCalls, 1);
      expect(stores.user.clearCalls, 1);
      expect(stores.secure.clearCalls, 0);
    });

    test('legacy identity mismatch clears legacy and user', () async {
      final stores = _MigrationStores(
        legacyResult: const AuthCredentialReadPresent(tokens),
        user: const AuthUser(id: 'user-2', name: 'Other'),
      );

      final result = await stores.coordinator.resolveUnlocked();

      expect(result, isA<AuthCredentialMigrationUnauthenticated>());
      expect(stores.legacy.clearCalls, 1);
      expect(stores.user.clearCalls, 1);
    });

    test('secure present without user clears secure and legacy', () async {
      final stores = _MigrationStores(
        secureResult: const AuthCredentialReadPresent(tokens),
      );

      final result = await stores.coordinator.resolveUnlocked();

      expect(result, isA<AuthCredentialMigrationUnauthenticated>());
      expect(stores.secure.clearCalls, 1);
      expect(stores.legacy.clearCalls, 1);
      expect(stores.user.clearCalls, 0);
    });

    test('secure identity mismatch clears all auth state', () async {
      final stores = _MigrationStores(
        secureResult: const AuthCredentialReadPresent(tokens),
        user: const AuthUser(id: 'user-2', name: 'Other'),
      );

      final result = await stores.coordinator.resolveUnlocked();

      expect(result, isA<AuthCredentialMigrationUnauthenticated>());
      expect(stores.secure.clearCalls, 1);
      expect(stores.legacy.clearCalls, 1);
      expect(stores.user.clearCalls, 1);
    });

    test('secure corruption clears all without reading legacy', () async {
      final stores = _MigrationStores(
        secureResult: const AuthCredentialReadCorrupted(),
        legacyResult: const AuthCredentialReadPresent(tokens),
        user: user,
      );

      final result = await stores.coordinator.resolveUnlocked();

      expect(result, isA<AuthCredentialMigrationUnauthenticated>());
      expect(stores.legacy.readCalls, 0);
      expect(stores.secure.clearCalls, 1);
      expect(stores.legacy.clearCalls, 1);
      expect(stores.user.clearCalls, 1);
    });

    test(
      'destructive cleanup attempts all and preserves unknown priority',
      () async {
        final expected = AppException(
          kind: AppExceptionKind.localStorage,
          message: 'expected',
          stackTrace: StackTrace.current,
        );
        final unknown = StateError('unknown');
        final unknownStack = StackTrace.current;
        final stores =
            _MigrationStores(
                secureResult: const AuthCredentialReadCorrupted(),
                user: user,
              )
              ..secure.clearError = expected
              ..legacy.clearError = unknown
              ..legacy.clearStackTrace = unknownStack;

        try {
          await stores.coordinator.resolveUnlocked();
          fail('Expected cleanup failure');
        } catch (error, stackTrace) {
          expect(error, same(unknown));
          expect(stackTrace, same(unknownStack));
        }
        expect(stores.secure.clearCalls, 1);
        expect(stores.legacy.clearCalls, 1);
        expect(stores.user.clearCalls, 1);
      },
    );

    test('expected cleanup failure is rethrown after all attempts', () async {
      final failure = AppException(
        kind: AppExceptionKind.localStorage,
        message: 'expected',
        stackTrace: StackTrace.current,
      );
      final stores = _MigrationStores(
        secureResult: const AuthCredentialReadCorrupted(),
        user: user,
      )..secure.clearError = failure;

      await expectLater(
        stores.coordinator.resolveUnlocked(),
        throwsA(same(failure)),
      );
      expect(stores.secure.clearCalls, 1);
      expect(stores.legacy.clearCalls, 1);
      expect(stores.user.clearCalls, 1);
    });
  });
}

final class _CredentialStore implements AuthCredentialStore {
  @override
  Future<void> clearCredential() async {}

  @override
  Future<AuthCredentialReadResult> readCredential() async {
    return const AuthCredentialReadAbsent();
  }

  @override
  Future<void> writeCredential(StoredAuthTokens tokens) async {}
}

final class _LegacyCredentialStore implements AuthLegacyCredentialStore {
  @override
  Future<void> clearLegacyCredential() async {}

  @override
  Future<AuthCredentialReadResult> readLegacyCredential() async {
    return const AuthCredentialReadAbsent();
  }
}

final class _UserStore implements AuthUserStore {
  @override
  Future<void> clearUser() async {}

  @override
  Future<AuthUser?> readUser() async => null;

  @override
  Future<void> writeUser(AuthUser user) async {}
}

final class _MigrationStores {
  _MigrationStores({
    AuthCredentialReadResult secureResult = const AuthCredentialReadAbsent(),
    AuthCredentialReadResult legacyResult = const AuthCredentialReadAbsent(),
    AuthUser? user,
  }) : secure = _RecordingCredentialStore(secureResult),
       legacy = _RecordingLegacyStore(legacyResult),
       user = _RecordingUserStore(user);

  final _RecordingCredentialStore secure;
  final _RecordingLegacyStore legacy;
  final _RecordingUserStore user;

  AuthCredentialMigrationCoordinator get coordinator =>
      AuthCredentialMigrationCoordinator(secure, legacy, user);
}

base mixin _RecordingClearStore {
  int clearCalls = 0;
  Object? clearError;
  StackTrace? clearStackTrace;

  Future<void> clearRecorded() async {
    clearCalls += 1;
    final error = clearError;
    if (error != null) {
      Error.throwWithStackTrace(error, clearStackTrace ?? StackTrace.current);
    }
  }
}

final class _RecordingCredentialStore
    with _RecordingClearStore
    implements AuthCredentialStore {
  _RecordingCredentialStore(this.result);

  AuthCredentialReadResult result;

  @override
  Future<void> clearCredential() => clearRecorded();

  @override
  Future<AuthCredentialReadResult> readCredential() async => result;

  @override
  Future<void> writeCredential(StoredAuthTokens tokens) async {}
}

final class _RecordingLegacyStore
    with _RecordingClearStore
    implements AuthLegacyCredentialStore {
  _RecordingLegacyStore(this.result);

  AuthCredentialReadResult result;
  int readCalls = 0;

  @override
  Future<void> clearLegacyCredential() => clearRecorded();

  @override
  Future<AuthCredentialReadResult> readLegacyCredential() async {
    readCalls += 1;
    return result;
  }
}

final class _RecordingUserStore
    with _RecordingClearStore
    implements AuthUserStore {
  _RecordingUserStore(this.value);

  AuthUser? value;

  @override
  Future<void> clearUser() => clearRecorded();

  @override
  Future<AuthUser?> readUser() async => value;

  @override
  Future<void> writeUser(AuthUser user) async => value = user;
}
