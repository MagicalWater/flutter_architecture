/// Preference storage 發生錯誤時，當時正在做哪個動作。
enum PreferenceStorageOperation {
  /// 從本機讀取 preference。
  read,

  /// 把 preference 寫回本機。
  write,
}

/// 發生問題的是哪一種 App preference。
enum PreferenceKind {
  /// Theme／亮暗模式相關設定。
  theme,

  /// App 語系設定。
  locale,
}

/// Theme／語系 preference 讀寫與還原時的共用錯誤基底。
sealed class PreferenceException implements Exception {
  const PreferenceException({
    required this.preference,
    this.providerCode,
    this.cause,
    this.stackTrace,
  });
  final PreferenceKind preference;
  /// 底層 storage／plugin 回傳的 machine-readable code；沒有 provider code 時為 null。
  final String? providerCode;
  final Object? cause;
  final StackTrace? stackTrace;

  @override
  String toString() {
    return '$runtimeType(preference: $preference, providerCode: $providerCode)';
  }
}

/// 本機確實有保存 preference，但內容已損壞或格式已無法解析。
final class PreferenceCorruptionException extends PreferenceException {
  const PreferenceCorruptionException({
    required super.preference,
    super.providerCode,
    super.cause,
    super.stackTrace,
  });
}

/// SharedPreferences 等 storage 在實際讀取或寫入時失敗。
final class PreferenceStorageException extends PreferenceException {
  const PreferenceStorageException.read({
    required super.preference,
    super.providerCode,
    super.cause,
    super.stackTrace,
  }) : operation = PreferenceStorageOperation.read;

  const PreferenceStorageException.write({
    required super.preference,
    super.providerCode,
    super.cause,
    super.stackTrace,
  }) : operation = PreferenceStorageOperation.write;

  final PreferenceStorageOperation operation;

  @override
  String toString() {
    return '$runtimeType('
        'operation: $operation, '
        'preference: $preference, '
        'providerCode: $providerCode)';
  }
}

/// 保存一次 preference 問題的原始錯誤與 stack trace，供上層統一記錄。
final class PreferenceDiagnostic {
  const PreferenceDiagnostic({required this.error, required this.stackTrace});

  final PreferenceException error;
  final StackTrace stackTrace;
}
