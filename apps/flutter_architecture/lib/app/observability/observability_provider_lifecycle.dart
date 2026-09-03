/// 啟動遠端 crash／error observability provider。
abstract interface class ObservabilityProviderInitializer {
  Future<void> initialize();
}

/// Observability provider 初始化後的結果。
///
/// Provider 掛掉不應直接讓 App 無法啟動，因此失敗時把原始 error 保存起來交給上層處理。
final class ObservabilityProviderInitializationResult {
  const ObservabilityProviderInitializationResult._({
    required this.available,
    this.error,
    this.stackTrace,
  });

  const ObservabilityProviderInitializationResult.available()
    : this._(available: true);

  const ObservabilityProviderInitializationResult.unavailable(
    Object error,
    StackTrace stackTrace,
  ) : this._(available: false, error: error, stackTrace: stackTrace);

  final bool available;
  final Object? error;
  final StackTrace? stackTrace;

  @override
  String toString() {
    return 'ObservabilityProviderInitializationResult('
        'available: $available, '
        'hasError: ${error != null}, '
        'hasStackTrace: ${stackTrace != null})';
  }
}

/// 執行 provider 初始化，但把初始化失敗轉成「目前不可用」而不是讓 App 直接崩潰。
final class ObservabilityProviderLifecycle {
  const ObservabilityProviderLifecycle(this._initializer);

  final ObservabilityProviderInitializer _initializer;

  Future<ObservabilityProviderInitializationResult> initialize() async {
    try {
      await _initializer.initialize();
      return const ObservabilityProviderInitializationResult.available();
    } catch (error, stackTrace) {
      return ObservabilityProviderInitializationResult.unavailable(
        error,
        stackTrace,
      );
    }
  }
}
