import 'package:flutter_architecture/app/observability/observability_provider_lifecycle.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('provider初始化成功時回傳available', () async {
    final lifecycle = ObservabilityProviderLifecycle(
      const _SuccessfulProviderInitializer(),
    );

    final result = await lifecycle.initialize();

    expect(result.available, isTrue);
    expect(result.error, isNull);
  });

  test('provider初始化失敗時回傳unavailable且不向外拋出', () async {
    final error = StateError('provider unavailable');
    final lifecycle = ObservabilityProviderLifecycle(
      _ThrowingProviderInitializer(error),
    );

    final result = await lifecycle.initialize();

    expect(result.available, isFalse);
    expect(result.error, same(error));
    expect(result.stackTrace, isNotNull);
    expect(result.toString(), isNot(contains('provider unavailable')));
    expect(result.toString(), contains('hasError: true'));
  });
}

final class _SuccessfulProviderInitializer
    implements ObservabilityProviderInitializer {
  const _SuccessfulProviderInitializer();

  @override
  Future<void> initialize() async {}
}

final class _ThrowingProviderInitializer
    implements ObservabilityProviderInitializer {
  const _ThrowingProviderInitializer(this.error);

  final Object error;

  @override
  Future<void> initialize() async => throw error;
}
