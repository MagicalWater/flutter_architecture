import 'package:flutter_architecture/app/config/app_environment.dart';

/// 決定目前 environment 是否允許 remote observability collection。
final class ObservabilityCollectionPolicy {
  const ObservabilityCollectionPolicy._({
    required this.environment,
    required this.remoteCollectionEnabled,
  });

  const ObservabilityCollectionPolicy.enabled(AppEnvironment environment)
    : this._(environment: environment, remoteCollectionEnabled: true);

  factory ObservabilityCollectionPolicy.defaults(AppEnvironment environment) {
    return ObservabilityCollectionPolicy._(
      environment: environment,
      remoteCollectionEnabled: false,
    );
  }

  final AppEnvironment environment;
  final bool remoteCollectionEnabled;
}
