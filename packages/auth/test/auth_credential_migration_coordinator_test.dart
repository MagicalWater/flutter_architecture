import 'package:auth/auth_infrastructure.dart';
import 'package:core/core.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const tokens = StoredAuthTokens(
    accessToken: 'access-secret',
    refreshToken: 'refresh-secret',
    userId: 'user-1',
  );
  const user = AuthUser(id: 'user-1', name: 'User');
  test('caller owns the only exclusive section around migration', () async {
    final guard = _ExclusiveGuard();
    final secure = _GuardedCredentialStore(
      guard,
      const AuthCredentialReadPresent(tokens),
    );
    final legacy = _GuardedLegacyStore(guard, const AuthCredentialReadAbsent());
    final userStore = _GuardedUserStore(guard, user);
    final coordinator = AuthCredentialMigrationCoordinator(
      secure,
      legacy,
      userStore,
    );

    final result = await guard.runExclusive(coordinator.resolveUnlocked);

    expect(result, isA<AuthCredentialMigrationResolved>());
    expect(guard.runExclusiveCalls, 1);
    expect(guard.nestedRunExclusiveCalls, 0);
    expect(guard.isHeld, isFalse);
  });

  test(
    'migration store access fails when caller does not own exclusivity',
    () async {
      final guard = _ExclusiveGuard();
      final coordinator = AuthCredentialMigrationCoordinator(
        _GuardedCredentialStore(guard, const AuthCredentialReadPresent(tokens)),
        _GuardedLegacyStore(guard, const AuthCredentialReadAbsent()),
        _GuardedUserStore(guard, user),
      );

      await expectLater(
        coordinator.resolveUnlocked(),
        throwsA(isA<StateError>()),
      );
      expect(guard.runExclusiveCalls, 0);
    },
  );

  test('same coordinator re-evaluates a changed authority state', () async {
    const secondTokens = StoredAuthTokens(
      accessToken: 'second-access',
      refreshToken: 'second-refresh',
      userId: 'user-2',
    );
    const secondUser = AuthUser(id: 'user-2', name: 'Second User');
    final stores = _MigrationStores(
      secureResult: const AuthCredentialReadPresent(tokens),
      user: user,
    );
    final coordinator = stores.coordinator;

    final first = await coordinator.resolveUnlocked();
    expect(first, isA<AuthCredentialMigrationResolved>());
    expect((first as AuthCredentialMigrationResolved).tokens, same(tokens));

    stores.secure.result = const AuthCredentialReadAbsent();
    stores.legacy.result = const AuthCredentialReadPresent(secondTokens);
    stores.user.value = secondUser;

    final second = await coordinator.resolveUnlocked();

    expect(second, isA<AuthCredentialMigrationResolved>());
    final resolved = second as AuthCredentialMigrationResolved;
    expect(resolved.tokens, same(secondTokens));
    expect(resolved.user, same(secondUser));
    expect(stores.secure.writeCalls, 1);
    expect(stores.legacy.clearCalls, 1);
  });

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

    test('secure read failure stops before legacy and user reads', () async {
      final failure = AppException(
        kind: AppExceptionKind.localStorage,
        message: 'secure unavailable',
      );
      final failureStack = StackTrace.current;
      final stores =
          _MigrationStores(
              legacyResult: const AuthCredentialReadPresent(tokens),
              user: user,
            )
            ..secure.readError = failure
            ..secure.readStackTrace = failureStack;

      try {
        await stores.coordinator.resolveUnlocked();
        fail('Expected secure read failure');
      } catch (error, stackTrace) {
        expect(error, same(failure));
        expect(stackTrace, same(failureStack));
      }

      expect(stores.secure.readCalls, 1);
      expect(stores.legacy.readCalls, 0);
      expect(stores.user.readCalls, 0);
      expect(stores.secure.clearCalls, 0);
      expect(stores.legacy.clearCalls, 0);
      expect(stores.user.clearCalls, 0);
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

    test(
      'expected cleanup failure keeps caught stack after all attempts',
      () async {
        final failure = AppException(
          kind: AppExceptionKind.localStorage,
          message: 'expected',
        );
        final failureStack = StackTrace.current;
        final stores =
            _MigrationStores(
                secureResult: const AuthCredentialReadCorrupted(),
                user: user,
              )
              ..secure.clearError = failure
              ..secure.clearStackTrace = failureStack;

        try {
          await stores.coordinator.resolveUnlocked();
          fail('Expected cleanup failure');
        } catch (error, stackTrace) {
          expect(error, same(failure));
          expect(stackTrace, same(failureStack));
        }
        expect(stores.secure.clearCalls, 1);
        expect(stores.legacy.clearCalls, 1);
        expect(stores.user.clearCalls, 1);
      },
    );
  });

  group('secure authority and legacy cleanup', () {
    test(
      'secure valid with matching user and no legacy resolves directly',
      () async {
        final stores = _MigrationStores(
          secureResult: const AuthCredentialReadPresent(tokens),
          user: user,
        );

        final result = await stores.coordinator.resolveUnlocked();

        expect(result, isA<AuthCredentialMigrationResolved>());
        final resolved = result as AuthCredentialMigrationResolved;
        expect(resolved.tokens, same(tokens));
        expect(resolved.user, same(user));
        expect(resolved.diagnostics, isEmpty);
        expect(stores.legacy.clearCalls, 0);
        expect(stores.secure.writeCalls, 0);
      },
    );

    test(
      'secure remains authority and clears conflicting legacy credential',
      () async {
        final stores = _MigrationStores(
          secureResult: const AuthCredentialReadPresent(tokens),
          legacyResult: const AuthCredentialReadPresent(
            StoredAuthTokens(
              accessToken: 'legacy-access',
              refreshToken: 'legacy-refresh',
              userId: 'user-1',
            ),
          ),
          user: user,
        );

        final result = await stores.coordinator.resolveUnlocked();

        expect(result, isA<AuthCredentialMigrationResolved>());
        expect(stores.legacy.clearCalls, 1);
        expect(stores.secure.clearCalls, 0);
        expect(stores.secure.writeCalls, 0);
      },
    );

    test('legacy read failure prevents resolved authority', () async {
      final failure = AppException(
        kind: AppExceptionKind.localStorage,
        message: 'legacy unavailable',
      );
      final failureStack = StackTrace.current;
      final stores =
          _MigrationStores(
              secureResult: const AuthCredentialReadPresent(tokens),
              user: user,
            )
            ..legacy.readError = failure
            ..legacy.readStackTrace = failureStack;

      try {
        await stores.coordinator.resolveUnlocked();
        fail('Expected legacy read failure');
      } catch (error, stackTrace) {
        expect(error, same(failure));
        expect(stackTrace, same(failureStack));
      }
      expect(stores.legacy.clearCalls, 0);
      expect(stores.secure.clearCalls, 0);
      expect(stores.user.clearCalls, 0);
    });

    test(
      'expected legacy cleanup failure resolves with safe pending diagnostic',
      () async {
        final failure = AppException(
          kind: AppExceptionKind.localStorage,
          message: 'legacy cleanup secret',
        );
        final failureStack = StackTrace.current;
        final stores =
            _MigrationStores(
                secureResult: const AuthCredentialReadPresent(tokens),
                legacyResult: const AuthCredentialReadPresent(tokens),
                user: user,
              )
              ..legacy.clearError = failure
              ..legacy.clearStackTrace = failureStack;

        final result = await stores.coordinator.resolveUnlocked();

        expect(result, isA<AuthCredentialMigrationResolved>());
        final resolved = result as AuthCredentialMigrationResolved;
        expect(resolved.tokens, same(tokens));
        expect(resolved.user, same(user));
        expect(resolved.diagnostics, hasLength(1));
        final diagnostic = resolved.diagnostics.single;
        expect(
          diagnostic.operation,
          AuthCleanupOperation.migrationLegacyCleanup,
        );
        expect(diagnostic.error, same(failure));
        expect(diagnostic.stackTrace, same(failureStack));
        expect(diagnostic.toString(), isNot(contains('legacy cleanup secret')));
        expect(stores.secure.clearCalls, 0);
        expect(stores.user.clearCalls, 0);
      },
    );

    test(
      'cleanup pending state retries from store state without rewriting secure',
      () async {
        final stores =
            _MigrationStores(
                secureResult: const AuthCredentialReadPresent(tokens),
                legacyResult: const AuthCredentialReadPresent(tokens),
                user: user,
              )
              ..legacy.clearError = AppException(
                kind: AppExceptionKind.localStorage,
                message: 'first cleanup failed',
              );

        final coordinator = stores.coordinator;
        final first = await coordinator.resolveUnlocked();
        expect(first.diagnostics, hasLength(1));
        expect(stores.legacy.clearCalls, 1);
        expect(stores.secure.writeCalls, 0);

        stores.legacy.clearError = null;
        final second = await coordinator.resolveUnlocked();

        expect(second, isA<AuthCredentialMigrationResolved>());
        expect(second.diagnostics, isEmpty);
        expect(stores.legacy.clearCalls, 2);
        expect(stores.secure.writeCalls, 0);
      },
    );
  });

  group('legacy migration and read-back validation', () {
    final expiringTokens = StoredAuthTokens(
      accessToken: 'legacy-access',
      refreshToken: 'legacy-refresh',
      userId: 'user-1',
      accessTokenExpiresAt: DateTime.utc(2030, 1, 2),
      refreshTokenExpiresAt: DateTime.utc(2030, 2, 3),
    );

    test('writes secure, validates full payload, then clears legacy', () async {
      final stores = _MigrationStores(
        legacyResult: AuthCredentialReadPresent(expiringTokens),
        user: user,
      );

      final result = await stores.coordinator.resolveUnlocked();

      expect(result, isA<AuthCredentialMigrationResolved>());
      final resolved = result as AuthCredentialMigrationResolved;
      expect(resolved.tokens, same(expiringTokens));
      expect(resolved.user, same(user));
      expect(resolved.diagnostics, isEmpty);
      expect(stores.operations, <String>[
        'secure.read',
        'legacy.read',
        'user.read',
        'secure.write',
        'secure.read',
        'legacy.clear',
      ]);
    });

    test(
      'expected secure write failure preserves legacy and caught stack',
      () async {
        final failure = AppException(
          kind: AppExceptionKind.localStorage,
          message: 'write unavailable',
        );
        final failureStack = StackTrace.current;
        final stores =
            _MigrationStores(
                legacyResult: const AuthCredentialReadPresent(tokens),
                user: user,
              )
              ..secure.writeError = failure
              ..secure.writeStackTrace = failureStack;

        try {
          await stores.coordinator.resolveUnlocked();
          fail('Expected secure write failure');
        } catch (error, stackTrace) {
          expect(error, same(failure));
          expect(stackTrace, same(failureStack));
        }
        expect(stores.legacy.clearCalls, 0);
        expect(stores.secure.clearCalls, 1);
      },
    );

    test(
      'write failure rollback error outranks original write error',
      () async {
        final writeFailure = AppException(
          kind: AppExceptionKind.localStorage,
          message: 'write unavailable',
        );
        final rollbackFailure = StateError('rollback failed');
        final rollbackStack = StackTrace.current;
        final stores =
            _MigrationStores(
                legacyResult: const AuthCredentialReadPresent(tokens),
                user: user,
              )
              ..secure.writeError = writeFailure
              ..secure.clearError = rollbackFailure
              ..secure.clearStackTrace = rollbackStack;

        try {
          await stores.coordinator.resolveUnlocked();
          fail('Expected rollback failure');
        } catch (error, stackTrace) {
          expect(error, same(rollbackFailure));
          expect(stackTrace, same(rollbackStack));
        }
        expect(stores.legacy.clearCalls, 0);
      },
    );

    final invalidReadBackCases = <String, AuthCredentialReadResult>{
      'absent': const AuthCredentialReadAbsent(),
      'identity mismatch': const AuthCredentialReadPresent(
        StoredAuthTokens(
          accessToken: 'access-secret',
          refreshToken: 'refresh-secret',
          userId: 'user-2',
        ),
      ),
    };
    for (final entry in invalidReadBackCases.entries) {
      test('invalid read-back ${entry.key} rolls back secure', () async {
        final stores = _MigrationStores(
          legacyResult: const AuthCredentialReadPresent(tokens),
          user: user,
        )..secure.postWriteResult = entry.value;

        try {
          await stores.coordinator.resolveUnlocked();
          fail('Expected read-back validation failure');
        } on AppException catch (error) {
          expect(error.kind, AppExceptionKind.dataCorruption);
          expect(
            error.diagnosticCode,
            'auth_secure_migration_read_back_invalid',
          );
        }
        expect(stores.secure.clearCalls, 1);
        expect(stores.legacy.clearCalls, 0);
      });
    }

    test(
      'read-back operational failure keeps legacy and rolls back secure',
      () async {
        final failure = AppException(
          kind: AppExceptionKind.localStorage,
          message: 'read unavailable',
        );
        final failureStack = StackTrace.current;
        final stores =
            _MigrationStores(
                legacyResult: const AuthCredentialReadPresent(tokens),
                user: user,
              )
              ..secure.readErrorAfterCalls = 1
              ..secure.readError = failure
              ..secure.readStackTrace = failureStack;

        try {
          await stores.coordinator.resolveUnlocked();
          fail('Expected read-back operational failure');
        } catch (error, stackTrace) {
          expect(error, same(failure));
          expect(stackTrace, same(failureStack));
        }
        expect(stores.secure.clearCalls, 1);
        expect(stores.legacy.clearCalls, 0);
      },
    );

    test(
      'rollback unknown error outranks original validation failure',
      () async {
        final rollback = StateError('rollback bug');
        final rollbackStack = StackTrace.current;
        final stores =
            _MigrationStores(
                legacyResult: const AuthCredentialReadPresent(tokens),
                user: user,
              )
              ..secure.postWriteResult = const AuthCredentialReadAbsent()
              ..secure.clearError = rollback
              ..secure.clearStackTrace = rollbackStack;

        try {
          await stores.coordinator.resolveUnlocked();
          fail('Expected rollback failure');
        } catch (error, stackTrace) {
          expect(error, same(rollback));
          expect(stackTrace, same(rollbackStack));
        }
        expect(stores.legacy.clearCalls, 0);
      },
    );

    test(
      'rollback local-storage error outranks original validation failure',
      () async {
        final rollback = AppException(
          kind: AppExceptionKind.localStorage,
          message: 'rollback unavailable',
        );
        final rollbackStack = StackTrace.current;
        final stores =
            _MigrationStores(
                legacyResult: const AuthCredentialReadPresent(tokens),
                user: user,
              )
              ..secure.postWriteResult = const AuthCredentialReadAbsent()
              ..secure.clearError = rollback
              ..secure.clearStackTrace = rollbackStack;

        try {
          await stores.coordinator.resolveUnlocked();
          fail('Expected rollback failure');
        } catch (error, stackTrace) {
          expect(error, same(rollback));
          expect(stackTrace, same(rollbackStack));
        }
        expect(stores.legacy.clearCalls, 0);
      },
    );

    test(
      'verified secure with legacy cleanup failure resolves pending',
      () async {
        final cleanup = AppException(
          kind: AppExceptionKind.localStorage,
          message: 'cleanup pending',
        );
        final stores = _MigrationStores(
          legacyResult: const AuthCredentialReadPresent(tokens),
          user: user,
        )..legacy.clearError = cleanup;

        final result = await stores.coordinator.resolveUnlocked();

        expect(result, isA<AuthCredentialMigrationResolved>());
        expect(result.diagnostics, hasLength(1));
        expect(result.diagnostics.single.error, same(cleanup));
        expect(stores.secure.writeCalls, 1);
      },
    );
  });
}

final class _ExclusiveGuard {
  bool isHeld = false;
  int runExclusiveCalls = 0;
  int nestedRunExclusiveCalls = 0;

  Future<T> runExclusive<T>(Future<T> Function() action) async {
    runExclusiveCalls += 1;
    if (isHeld) {
      nestedRunExclusiveCalls += 1;
      throw StateError('Nested exclusive ownership is forbidden.');
    }
    isHeld = true;
    try {
      return await action();
    } finally {
      isHeld = false;
    }
  }

  void assertHeld() {
    if (!isHeld) {
      throw StateError('Migration store accessed without ownership.');
    }
  }
}

final class _GuardedCredentialStore implements AuthCredentialStore {
  _GuardedCredentialStore(this.guard, this.result);

  final _ExclusiveGuard guard;
  AuthCredentialReadResult result;

  @override
  Future<void> clearCredential() async => guard.assertHeld();

  @override
  Future<AuthCredentialReadResult> readCredential() async {
    guard.assertHeld();
    return result;
  }

  @override
  Future<void> writeCredential(StoredAuthTokens tokens) async {
    guard.assertHeld();
    result = AuthCredentialReadPresent(tokens);
  }
}

final class _GuardedLegacyStore implements AuthLegacyCredentialStore {
  _GuardedLegacyStore(this.guard, this.result);

  final _ExclusiveGuard guard;
  AuthCredentialReadResult result;

  @override
  Future<void> clearLegacyCredential() async {
    guard.assertHeld();
    result = const AuthCredentialReadAbsent();
  }

  @override
  Future<AuthCredentialReadResult> readLegacyCredential() async {
    guard.assertHeld();
    return result;
  }
}

final class _GuardedUserStore implements AuthUserStore {
  _GuardedUserStore(this.guard, this.value);

  final _ExclusiveGuard guard;
  AuthUser? value;

  @override
  Future<void> clearUser() async {
    guard.assertHeld();
    value = null;
  }

  @override
  Future<AuthUser?> readUser() async {
    guard.assertHeld();
    return value;
  }

  @override
  Future<void> writeUser(AuthUser user) async {
    guard.assertHeld();
    value = user;
  }
}

final class _MigrationStores {
  _MigrationStores({
    AuthCredentialReadResult secureResult = const AuthCredentialReadAbsent(),
    AuthCredentialReadResult legacyResult = const AuthCredentialReadAbsent(),
    AuthUser? user,
  }) : secure = _RecordingCredentialStore(secureResult, <String>[]),
       operations = <String>[],
       legacy = _RecordingLegacyStore(legacyResult, <String>[]),
       user = _RecordingUserStore(user, <String>[]) {
    secure.operations = operations;
    legacy.operations = operations;
    this.user.operations = operations;
  }

  final _RecordingCredentialStore secure;
  final List<String> operations;
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
  _RecordingCredentialStore(this.result, this.operations);

  AuthCredentialReadResult result;
  List<String> operations;
  int readCalls = 0;
  Object? readError;
  StackTrace? readStackTrace;
  int? readErrorAfterCalls;
  int writeCalls = 0;
  Object? writeError;
  StackTrace? writeStackTrace;
  AuthCredentialReadResult? postWriteResult;

  @override
  Future<void> clearCredential() {
    operations.add('secure.clear');
    return clearRecorded();
  }

  @override
  Future<AuthCredentialReadResult> readCredential() async {
    readCalls += 1;
    operations.add('secure.read');
    final error = readError;
    if (error != null &&
        (readErrorAfterCalls == null || readCalls > readErrorAfterCalls!)) {
      Error.throwWithStackTrace(error, readStackTrace ?? StackTrace.current);
    }
    return result;
  }

  @override
  Future<void> writeCredential(StoredAuthTokens tokens) async {
    writeCalls += 1;
    operations.add('secure.write');
    final error = writeError;
    if (error != null) {
      Error.throwWithStackTrace(error, writeStackTrace ?? StackTrace.current);
    }
    result = postWriteResult ?? AuthCredentialReadPresent(tokens);
  }
}

final class _RecordingLegacyStore
    with _RecordingClearStore
    implements AuthLegacyCredentialStore {
  _RecordingLegacyStore(this.result, this.operations);

  AuthCredentialReadResult result;
  List<String> operations;
  int readCalls = 0;
  Object? readError;
  StackTrace? readStackTrace;

  @override
  Future<void> clearLegacyCredential() {
    operations.add('legacy.clear');
    return clearRecorded();
  }

  @override
  Future<AuthCredentialReadResult> readLegacyCredential() async {
    readCalls += 1;
    operations.add('legacy.read');
    final error = readError;
    if (error != null) {
      Error.throwWithStackTrace(error, readStackTrace ?? StackTrace.current);
    }
    return result;
  }
}

final class _RecordingUserStore
    with _RecordingClearStore
    implements AuthUserStore {
  _RecordingUserStore(this.value, this.operations);

  AuthUser? value;
  List<String> operations;
  int readCalls = 0;

  @override
  Future<void> clearUser() {
    operations.add('user.clear');
    return clearRecorded();
  }

  @override
  Future<AuthUser?> readUser() async {
    readCalls += 1;
    operations.add('user.read');
    return value;
  }

  @override
  Future<void> writeUser(AuthUser user) async => value = user;
}
