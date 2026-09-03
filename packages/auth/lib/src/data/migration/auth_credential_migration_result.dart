import 'package:auth/src/data/cleanup/auth_cleanup_diagnostic.dart';
import 'package:auth/src/data/models/stored_auth_tokens.dart';
import 'package:auth/src/domain/entities/auth_user.dart';

/// App 啟動時檢查舊／新 credential storage 後的最終結果。
sealed class AuthCredentialMigrationResult {
  AuthCredentialMigrationResult({
    List<AuthCleanupDiagnostic> diagnostics = const [],
  }) : diagnostics = List<AuthCleanupDiagnostic>.unmodifiable(diagnostics);

  /// Migration 過程中可以額外記錄、但不影響最終登入判定的 cleanup 問題。
  final List<AuthCleanupDiagnostic> diagnostics;
}

/// 最後沒有找到一組可以安全還原 Session 的 credential。
final class AuthCredentialMigrationUnauthenticated
    extends AuthCredentialMigrationResult {
  AuthCredentialMigrationUnauthenticated({super.diagnostics});

  @override
  String toString() {
    return 'AuthCredentialMigrationUnauthenticated('
        'diagnosticCount: ${diagnostics.length})';
  }
}

/// 已取得彼此一致的 credential 與使用者資料，可以建立登入 Session。
final class AuthCredentialMigrationResolved
    extends AuthCredentialMigrationResult {
  AuthCredentialMigrationResolved({
    required this.tokens,
    required this.user,
    super.diagnostics,
  });

  final StoredAuthTokens tokens;
  final AuthUser user;

  @override
  String toString() {
    return 'AuthCredentialMigrationResolved('
        'diagnosticCount: ${diagnostics.length})';
  }
}
