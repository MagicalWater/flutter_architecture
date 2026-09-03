import 'package:flutter_architecture/app/config/app_environment.dart';
import 'package:flutter_architecture/app/observability/observability_collection_policy.dart';

/// 決定這次 App 執行是否真的把 crash／error 送到遠端，以及是否發 acceptance event。
///
/// Acceptance event 只允許 staging，且必須同時開啟 remote collection，避免在 production
/// 或完全沒啟用 provider 的情況下誤送測試事件。
final class ObservabilityRuntimeConfig {
  const ObservabilityRuntimeConfig._({
    required this.collectionPolicy,
    required this.emitAcceptanceEvent,
  });

  factory ObservabilityRuntimeConfig.fromBuildEnvironment(
    AppEnvironment environment,
  ) {
    return ObservabilityRuntimeConfig.resolve(
      environment: environment,
      remoteCollectionRequested: const bool.fromEnvironment(
        'OBSERVABILITY_REMOTE_COLLECTION_ENABLED',
      ),
      acceptanceEventRequested: const bool.fromEnvironment(
        'OBSERVABILITY_ACCEPTANCE_EVENT_ENABLED',
      ),
    );
  }

  factory ObservabilityRuntimeConfig.resolve({
    required AppEnvironment environment,
    required bool remoteCollectionRequested,
    required bool acceptanceEventRequested,
  }) {
    if (acceptanceEventRequested && environment != AppEnvironment.staging) {
      throw ArgumentError(
        'Observability acceptance events are restricted to staging.',
      );
    }
    if (acceptanceEventRequested && !remoteCollectionRequested) {
      throw ArgumentError(
        'Observability acceptance requires remote collection.',
      );
    }

    return ObservabilityRuntimeConfig._(
      collectionPolicy: remoteCollectionRequested
          ? ObservabilityCollectionPolicy.enabled(environment)
          : ObservabilityCollectionPolicy.defaults(environment),
      emitAcceptanceEvent: acceptanceEventRequested,
    );
  }

  final ObservabilityCollectionPolicy collectionPolicy;
  final bool emitAcceptanceEvent;
}
