/// Credential migration可安全交給App reporting boundary的診斷操作。
enum AuthCredentialMigrationDiagnosticOperation { legacyCleanup }

/// Credential migration的typed diagnostic。
///
/// 保留原始error與stack供明確的reporting adapter使用，但[toString]不展開
/// error內容，避免plugin message或credential-bearing內容進入一般診斷文字。
final class AuthCredentialMigrationDiagnostic {
  const AuthCredentialMigrationDiagnostic({
    required this.operation,
    required this.error,
    required this.stackTrace,
  });

  final AuthCredentialMigrationDiagnosticOperation operation;
  final Object error;
  final StackTrace stackTrace;

  @override
  String toString() {
    return 'AuthCredentialMigrationDiagnostic('
        'operation: $operation, '
        'errorType: ${error.runtimeType})';
  }
}
