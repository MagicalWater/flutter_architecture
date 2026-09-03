import 'package:auth/src/data/cleanup/auth_cleanup_diagnostic.dart';
import 'package:auth/src/data/migration/auth_credential_migration_result.dart';
import 'package:auth/src/data/models/stored_auth_tokens.dart';
import 'package:auth/src/data/stores/auth_credential_read_result.dart';
import 'package:auth/src/data/stores/auth_credential_store.dart';
import 'package:auth/src/data/stores/auth_legacy_credential_store.dart';
import 'package:auth/src/data/stores/auth_user_store.dart';
import 'package:core/core.dart';

/// App 啟動時檢查新舊 credential storage，決定能不能安全還原登入 Session。
///
/// 它會優先採用 secure storage；只有 secure storage 完全沒有資料時才考慮舊版
/// SharedPreferences。Credential 與 persisted user 必須屬於同一個 userId，否則就清掉
/// 不一致資料並回到未登入。這個類別只整理 storage，不直接修改 runtime Session。
final class AuthCredentialMigrationCoordinator {
  const AuthCredentialMigrationCoordinator(
    this._secureCredentialStore,
    this._legacyCredentialStore,
    this._userStore,
  );

  final AuthCredentialStore _secureCredentialStore;
  final AuthLegacyCredentialStore _legacyCredentialStore;
  final AuthUserStore _userStore;

  /// 依目前三個 store 的實際內容，整理出「可還原登入」或「應視為未登入」。
  Future<AuthCredentialMigrationResult> resolveUnlocked() async {
    final secure = await _secureCredentialStore.readCredential();

    // Secure storage 是目前正式來源。只要這裡已有資料，就不允許舊版 storage 覆蓋它；
    // 如果 secure 內容已損壞，相關登入資料一起清掉，避免拿不一致狀態建立 Session。
    if (secure is AuthCredentialReadCorrupted) {
      await _clearDestructive(
        clearSecure: true,
        clearLegacy: true,
        clearUser: true,
      );
      return AuthCredentialMigrationUnauthenticated();
    }

    if (secure is AuthCredentialReadPresent) {
      // Credential 與 persisted user 必須同時存在且 userId 一致；否則無法確認這兩份
      // 資料是不是同一次登入留下的，不能直接還原成已登入。
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
      // Secure credential 已確認可用後，Legacy 只剩歷史殘留。即使清除 Legacy 失敗，
      // 也不能再把舊 credential 拿回來當登入來源，只記錄診斷即可。
      final diagnostics = await _clearLegacyAfterSecureAuthority();
      return AuthCredentialMigrationResolved(
        tokens: secure.tokens,
        user: user,
        diagnostics: diagnostics,
      );
    }

    // 只有 Secure 完全沒有資料時才讀 Legacy，避免舊版本資料蓋過已經建立的新資料。
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

    // Legacy credential 只有在 userId 能和 persisted user 對上時才可以搬遷；
    // 對不上就無法確認資料歸屬，直接當成不可安全採用的歷史殘留。
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

    // 寫入 Secure 後不能立刻刪 Legacy。先重新讀回並比對完整 token，確認真的寫成功，
    // 才能移除舊資料；否則要回滾剛寫入的 Secure，避免只搬了一半。
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

  /// Secure 寫入尚未通過 read-back 驗證時，先清掉可能只寫了一半的新資料。
  /// 如果 rollback 自己也失敗，優先回報 rollback；否則重拋原本 migration error。
  Future<Never> _rollbackUnverifiedSecure(
    Object originalError,
    StackTrace originalStackTrace,
  ) async {
    // Secure 尚未驗證成功前不能當正式 credential 使用；migration 中途失敗就先清掉
    // 這份可能不完整的新資料，再把真正的錯誤拋回去。
    try {
      await _secureCredentialStore.clearCredential();
    } catch (rollbackError, rollbackStackTrace) {
      Error.throwWithStackTrace(rollbackError, rollbackStackTrace);
    }
    Error.throwWithStackTrace(originalError, originalStackTrace);
  }

  /// Secure credential 已確認可用後，清掉舊版 credential。
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
    // 修復不一致資料時，每個指定 store 都要盡量清；不能第一個 local-storage error
    // 就停下來，否則可能只清掉一半，下一次啟動還是會看到互相矛盾的資料。
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
