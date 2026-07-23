import 'package:flutter_architecture/app/config/app_environment.dart';
import 'package:flutter_architecture/app/observability/observability_collection_policy.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('所有environment預設remote collection關閉', () {
    for (final environment in AppEnvironment.values) {
      final policy = ObservabilityCollectionPolicy.defaults(environment);

      expect(policy.remoteCollectionEnabled, isFalse);
      expect(policy.environment, environment);
    }
  });

  test('只有明確啟用才允許remote collection', () {
    const policy = ObservabilityCollectionPolicy.enabled(
      AppEnvironment.staging,
    );

    expect(policy.remoteCollectionEnabled, isTrue);
  });
}
