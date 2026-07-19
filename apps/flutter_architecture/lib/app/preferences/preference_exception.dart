enum PreferenceOperation { read, write, decode }

enum PreferenceKind { theme, locale }

sealed class PreferenceException implements Exception {
  const PreferenceException({
    required this.operation,
    required this.preference,
    this.cause,
    this.stackTrace,
  });

  final PreferenceOperation operation;
  final PreferenceKind preference;
  final Object? cause;
  final StackTrace? stackTrace;

  @override
  String toString() {
    return '$runtimeType('
        'operation: $operation, '
        'preference: $preference)';
  }
}

/// 已保存的preference payload無法依目前contract還原。
final class PreferenceCorruptionException extends PreferenceException {
  const PreferenceCorruptionException({
    required super.preference,
    super.cause,
    super.stackTrace,
  }) : super(operation: PreferenceOperation.decode);
}

/// Preference storage的預期operational failure。
final class PreferenceStorageException extends PreferenceException {
  const PreferenceStorageException.read({
    required super.preference,
    super.cause,
    super.stackTrace,
  }) : super(operation: PreferenceOperation.read);

  const PreferenceStorageException.write({
    required super.preference,
    super.cause,
    super.stackTrace,
  }) : super(operation: PreferenceOperation.write);
}

final class PreferenceDiagnostic {
  const PreferenceDiagnostic({required this.error, required this.stackTrace});

  final PreferenceException error;
  final StackTrace stackTrace;
}
