enum PreferenceStorageOperation { read, write }

enum PreferenceKind { theme, locale }

sealed class PreferenceException implements Exception {
  const PreferenceException({
    required this.preference,
    this.cause,
    this.stackTrace,
  });
  final PreferenceKind preference;
  final Object? cause;
  final StackTrace? stackTrace;

  @override
  String toString() {
    return '$runtimeType(preference: $preference)';
  }
}

/// 已保存的 preference payload 無法依目前 contract 還原。
final class PreferenceCorruptionException extends PreferenceException {
  const PreferenceCorruptionException({
    required super.preference,
    super.cause,
    super.stackTrace,
  });
}

/// Preference storage 的 read / write operational failure。
final class PreferenceStorageException extends PreferenceException {
  const PreferenceStorageException.read({
    required super.preference,
    super.cause,
    super.stackTrace,
  }) : operation = PreferenceStorageOperation.read;

  const PreferenceStorageException.write({
    required super.preference,
    super.cause,
    super.stackTrace,
  }) : operation = PreferenceStorageOperation.write;

  final PreferenceStorageOperation operation;

  @override
  String toString() {
    return '$runtimeType(operation: $operation, preference: $preference)';
  }
}

final class PreferenceDiagnostic {
  const PreferenceDiagnostic({required this.error, required this.stackTrace});

  final PreferenceException error;
  final StackTrace stackTrace;
}
