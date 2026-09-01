/// Identifies which durable auth state cleanup step failed.
enum AuthCleanupOperation {
  migrationLegacyCleanup,
  secureCleanup,
  legacyCleanup,
  userCleanup,
  localUnlockPreferenceCleanup,
}

final class AuthCleanupDiagnostic {
  const AuthCleanupDiagnostic({
    required this.operation,
    required this.error,
    required this.stackTrace,
  });

  final AuthCleanupOperation operation;
  final Object error;
  final StackTrace stackTrace;

  @override
  String toString() {
    return 'AuthCleanupDiagnostic('
        'operation: $operation, '
        'errorType: ${error.runtimeType})';
  }
}
