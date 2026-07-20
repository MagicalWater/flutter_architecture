import 'package:auth/src/data/migration/auth_credential_migration_diagnostic.dart';
import 'package:auth/src/data/models/stored_auth_tokens.dart';
import 'package:auth/src/domain/entities/auth_user.dart';

/// Credential migration resolution。
sealed class AuthCredentialMigrationResult {
  AuthCredentialMigrationResult({
    List<AuthCredentialMigrationDiagnostic> diagnostics = const [],
  }) : diagnostics = List<AuthCredentialMigrationDiagnostic>.unmodifiable(
         diagnostics,
       );

  /// 可安全交給App reporting adapter處理的immutable diagnostics。
  final List<AuthCredentialMigrationDiagnostic> diagnostics;
}

/// Migration resolution後沒有可建立Session的credential。
final class AuthCredentialMigrationUnauthenticated
    extends AuthCredentialMigrationResult {
  AuthCredentialMigrationUnauthenticated({super.diagnostics});

  @override
  String toString() {
    return 'AuthCredentialMigrationUnauthenticated('
        'diagnosticCount: ${diagnostics.length})';
  }
}

/// Migration resolution後取得可建立Session的credential與User。
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
