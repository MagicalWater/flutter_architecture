import 'dart:io';

import 'package:auth/auth.dart';
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
      final unauthenticated = AuthCredentialMigrationUnauthenticated(
        diagnostics: <AuthCredentialMigrationDiagnostic>[diagnostic],
      );
      final resolved = AuthCredentialMigrationResolved(
        tokens: tokens,
        user: user,
        diagnostics: <AuthCredentialMigrationDiagnostic>[diagnostic],
      );

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
