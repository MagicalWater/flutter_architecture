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
