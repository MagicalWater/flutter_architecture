import 'package:auth/src/data/migration/auth_credential_migration_result.dart';
import 'package:auth/src/data/migration/auth_credential_migration_diagnostic.dart';
import 'package:auth/src/data/stores/auth_credential_read_result.dart';
import 'package:auth/src/data/stores/auth_credential_store.dart';
import 'package:auth/src/data/stores/auth_legacy_credential_store.dart';
import 'package:auth/src/data/stores/auth_user_store.dart';
import 'package:core/core.dart';

/// Secure、Legacy與User store之間唯一的credential migration policy owner。
///
/// 呼叫方必須先取得Auth lifecycle的exclusive ownership；Coordinator本身只根據
/// 三個Auth-specific stores的真實狀態進行resolution，不持有runtime Session狀態。
final class AuthCredentialMigrationCoordinator {
  const AuthCredentialMigrationCoordinator(
    this._secureCredentialStore,
    this._legacyCredentialStore,
    this._userStore,
  );

  final AuthCredentialStore _secureCredentialStore;
  final AuthLegacyCredentialStore _legacyCredentialStore;
  final AuthUserStore _userStore;

  /// 在呼叫方已持有exclusive ownership時解析credential authority。
  Future<AuthCredentialMigrationResult> resolveUnlocked() async {
    final secure = await _secureCredentialStore.readCredential();

    if (secure is AuthCredentialReadCorrupted) {
      await _clearDestructive(
        clearSecure: true,
        clearLegacy: true,
        clearUser: true,
      );
      return AuthCredentialMigrationUnauthenticated();
    }

    if (secure is AuthCredentialReadPresent) {
      final user = await _userStore.readUser();
      if (user == null) {
        await _clearDestructive(
          clearSecure: true,
          clearLegacy: true,
          clearUser: false,
        );
        return AuthCredentialMigrationUnauthenticated();
      }
      if (secure.tokens.userId == null || secure.tokens.userId != user.id) {
        await _clearDestructive(
          clearSecure: true,
          clearLegacy: true,
          clearUser: true,
        );
        return AuthCredentialMigrationUnauthenticated();
      }
      final legacy = await _legacyCredentialStore.readLegacyCredential();
      if (legacy is AuthCredentialReadAbsent) {
        return AuthCredentialMigrationResolved(
          tokens: secure.tokens,
          user: user,
        );
      }
      final diagnostics = await _clearLegacyAfterSecureAuthority();
      return AuthCredentialMigrationResolved(
        tokens: secure.tokens,
        user: user,
        diagnostics: diagnostics,
      );
    }

    final legacy = await _legacyCredentialStore.readLegacyCredential();
    final user = await _userStore.readUser();

    if (legacy is AuthCredentialReadAbsent) {
      if (user != null) {
        await _clearDestructive(
          clearSecure: false,
          clearLegacy: false,
          clearUser: true,
        );
      }
      return AuthCredentialMigrationUnauthenticated();
    }

    if (legacy is AuthCredentialReadCorrupted) {
      await _clearDestructive(
        clearSecure: false,
        clearLegacy: true,
        clearUser: user != null,
      );
      return AuthCredentialMigrationUnauthenticated();
    }

    final legacyTokens = (legacy as AuthCredentialReadPresent).tokens;
    if (user == null ||
        legacyTokens.userId == null ||
        legacyTokens.userId != user.id) {
      await _clearDestructive(
        clearSecure: false,
        clearLegacy: true,
        clearUser: user != null,
      );
      return AuthCredentialMigrationUnauthenticated();
    }

    throw UnimplementedError('Legacy migration is not implemented.');
  }

  Future<List<AuthCredentialMigrationDiagnostic>>
  _clearLegacyAfterSecureAuthority() async {
    try {
      await _legacyCredentialStore.clearLegacyCredential();
      return const <AuthCredentialMigrationDiagnostic>[];
    } catch (error, stackTrace) {
      if (error is AppException &&
          error.kind == AppExceptionKind.localStorage) {
        return <AuthCredentialMigrationDiagnostic>[
          AuthCredentialMigrationDiagnostic(
            operation: AuthCredentialMigrationDiagnosticOperation.legacyCleanup,
            error: error,
            stackTrace: stackTrace,
          ),
        ];
      }
      Error.throwWithStackTrace(error, stackTrace);
    }
  }

  Future<void> _clearDestructive({
    required bool clearSecure,
    required bool clearLegacy,
    required bool clearUser,
  }) async {
    Object? firstExpectedError;
    StackTrace? firstExpectedStackTrace;
    Object? firstUnknownError;
    StackTrace? firstUnknownStackTrace;

    void capture(Object error, StackTrace stackTrace) {
      if (error is AppException &&
          error.kind == AppExceptionKind.localStorage) {
        firstExpectedError ??= error;
        firstExpectedStackTrace ??= stackTrace;
        return;
      }
      firstUnknownError ??= error;
      firstUnknownStackTrace ??= stackTrace;
    }

    Future<void> attempt(Future<void> Function() action) async {
      try {
        await action();
      } catch (error, stackTrace) {
        capture(error, stackTrace);
      }
    }

    if (clearSecure) {
      await attempt(_secureCredentialStore.clearCredential);
    }
    if (clearLegacy) {
      await attempt(_legacyCredentialStore.clearLegacyCredential);
    }
    if (clearUser) {
      await attempt(_userStore.clearUser);
    }

    final unknownError = firstUnknownError;
    if (unknownError != null) {
      Error.throwWithStackTrace(unknownError, firstUnknownStackTrace!);
    }
    final expectedError = firstExpectedError;
    if (expectedError != null) {
      Error.throwWithStackTrace(expectedError, firstExpectedStackTrace!);
    }
  }
}
