import 'package:auth/src/data/cleanup/auth_cleanup_diagnostic.dart';
import 'package:auth/src/data/migration/auth_credential_migration_result.dart';
import 'package:auth/src/data/models/stored_auth_tokens.dart';
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

    // Secure store 是現行 credential authority。只要 secure state 已存在，就不得
    // 再讓 Legacy 覆蓋它；若 secure 本身損壞，則所有相依 Auth state 都失去可信度。
    if (secure is AuthCredentialReadCorrupted) {
      await _clearDestructive(
        clearSecure: true,
        clearLegacy: true,
        clearUser: true,
      );
      return AuthCredentialMigrationUnauthenticated();
    }

    if (secure is AuthCredentialReadPresent) {
      // Credential 與 persisted user 必須共同構成同一個 identity authority；
      // 任一缺失或 userId 不一致，都不能恢復成 authenticated state。
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
      // Secure 已經通過 identity 驗證後，Legacy 只剩待清理殘留；cleanup failure
      // 可診斷但不能讓舊 credential 重新取得 authority。
      final diagnostics = await _clearLegacyAfterSecureAuthority();
      return AuthCredentialMigrationResolved(
        tokens: secure.tokens,
        user: user,
        diagnostics: diagnostics,
      );
    }

    // 只有 Secure 完全 absent 時，Legacy 才有資格成為 migration source；這個
    // precedence 防止舊 storage 覆寫已建立的新 credential authority。
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

    // Legacy credential 只有在能與 persisted user 建立同一 identity 時才能搬遷；
    // 否則舊資料視為不可安全採用的殘留 state。
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

    // Migration write 尚不能立即升格成新 authority。必須 read-back 驗證完整 token
    // identity 後才可刪除 Legacy；驗證前的 Secure 只視為可能的 partial state。
    try {
      await _secureCredentialStore.writeCredential(legacyTokens);
    } catch (error, stackTrace) {
      await _rollbackUnverifiedSecure(error, stackTrace);
    }

    AuthCredentialReadResult readBack;
    try {
      readBack = await _secureCredentialStore.readCredential();
    } catch (error, stackTrace) {
      await _rollbackUnverifiedSecure(error, stackTrace);
    }

    if (readBack is! AuthCredentialReadPresent ||
        !_sameTokens(readBack.tokens, legacyTokens)) {
      final validationError = AppException(
        kind: AppExceptionKind.dataCorruption,
        message: 'Secure credential migration read-back validation failed.',
        diagnosticCode: 'auth_secure_migration_read_back_invalid',
      );
      await _rollbackUnverifiedSecure(validationError, StackTrace.current);
    }

    final diagnostics = await _clearLegacyAfterSecureAuthority();
    return AuthCredentialMigrationResolved(
      tokens: legacyTokens,
      user: user,
      diagnostics: diagnostics,
    );
  }

  bool _sameTokens(StoredAuthTokens left, StoredAuthTokens right) {
    return left.accessToken == right.accessToken &&
        left.refreshToken == right.refreshToken &&
        left.userId == right.userId &&
        left.accessTokenExpiresAt == right.accessTokenExpiresAt &&
        left.refreshTokenExpiresAt == right.refreshTokenExpiresAt;
  }

  /// Secure migration 尚未通過 read-back 驗證時，先移除可能的 partial authority。
  /// Rollback 自身失敗優先拋出；否則保留並重拋原始 migration error。
  Future<Never> _rollbackUnverifiedSecure(
    Object originalError,
    StackTrace originalStackTrace,
  ) async {
    // Secure write / read-back 尚未驗證前不能成為 credential authority；任何
    // migration failure 都先移除可能的 partial secure state，再拋回原始錯誤。
    try {
      await _secureCredentialStore.clearCredential();
    } catch (rollbackError, rollbackStackTrace) {
      Error.throwWithStackTrace(rollbackError, rollbackStackTrace);
    }
    Error.throwWithStackTrace(originalError, originalStackTrace);
  }

  /// Secure credential 已成為 authority 後清理 legacy credential。
  /// 預期 storage failure 轉成可上報 diagnostic，未知異常仍直接拋出。
  Future<List<AuthCleanupDiagnostic>> _clearLegacyAfterSecureAuthority() async {
    try {
      await _legacyCredentialStore.clearLegacyCredential();
      return const <AuthCleanupDiagnostic>[];
    } catch (error, stackTrace) {
      if (error is AppException &&
          error.kind == AppExceptionKind.localStorage) {
        return <AuthCleanupDiagnostic>[
          AuthCleanupDiagnostic(
            operation: AuthCleanupOperation.migrationLegacyCleanup,
            error: error,
            stackTrace: stackTrace,
          ),
        ];
      }
      Error.throwWithStackTrace(error, stackTrace);
    }
  }

  /// 對不一致 / 損壞 auth state 執行 best-effort destructive cleanup。
  /// 所有指定 store 都會嘗試清理，最後以 unknown failure 優先於預期 storage failure。
  Future<void> _clearDestructive({
    required bool clearSecure,
    required bool clearLegacy,
    required bool clearUser,
  }) async {
    // Destructive recovery 必須盡量清除所有被指定的 state，而不是第一個
    // expected local-storage failure 就中止，否則可能留下彼此矛盾的 authority。
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
