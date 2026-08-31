/// Remote observability provider 的初始化 boundary。
abstract interface class ObservabilityProviderInitializer {
  Future<void> initialize();
}

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

/// 將 provider initialization failure 收斂成 availability result，避免啟動流程直接崩潰。
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
