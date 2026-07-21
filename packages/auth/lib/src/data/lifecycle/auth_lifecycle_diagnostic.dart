enum AuthLifecycleDiagnosticOperation {
  migrationLegacyCleanup,
  secureCleanup,
  legacyCleanup,
  userCleanup,
  localUnlockPreferenceCleanup,
}

final class AuthLifecycleDiagnostic {
  const AuthLifecycleDiagnostic({
    required this.operation,
    required this.error,
    required this.stackTrace,
  });

  final AuthLifecycleDiagnosticOperation operation;
  final Object error;
  final StackTrace stackTrace;

  @override
  String toString() {
    return 'AuthLifecycleDiagnostic('
        'operation: $operation, '
        'errorType: ${error.runtimeType})';
  }
}
