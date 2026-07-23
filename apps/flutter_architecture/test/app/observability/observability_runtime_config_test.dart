import 'package:flutter_architecture/app/config/app_environment.dart';
import 'package:flutter_architecture/app/observability/observability_runtime_config.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('remote collection remains disabled without explicit build flag', () {
    final config = ObservabilityRuntimeConfig.resolve(
      environment: AppEnvironment.staging,
      remoteCollectionRequested: false,
      acceptanceEventRequested: false,
    );

    expect(config.collectionPolicy.remoteCollectionEnabled, isFalse);
    expect(config.emitAcceptanceEvent, isFalse);
  });

  test('staging acceptance requires explicit collection and event flags', () {
    final config = ObservabilityRuntimeConfig.resolve(
      environment: AppEnvironment.staging,
      remoteCollectionRequested: true,
      acceptanceEventRequested: true,
    );

    expect(config.collectionPolicy.remoteCollectionEnabled, isTrue);
    expect(config.emitAcceptanceEvent, isTrue);
  });

  test('acceptance event cannot be enabled outside staging', () {
    expect(
      () => ObservabilityRuntimeConfig.resolve(
        environment: AppEnvironment.production,
        remoteCollectionRequested: true,
        acceptanceEventRequested: true,
      ),
      throwsArgumentError,
    );
  });
}
