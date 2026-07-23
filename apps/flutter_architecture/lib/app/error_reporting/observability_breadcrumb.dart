import 'dart:collection';

enum ObservabilityStartupStage {
  appStarted,
  bindingsReady,
  dependenciesReady,
  appMounted,
}

enum ObservabilityNavigationEvent { routeChanged, authenticationRedirect }

typedef ObservabilityBreadcrumbSink =
    void Function(ObservabilityBreadcrumb breadcrumb);

final class ObservabilityBreadcrumb {
  ObservabilityBreadcrumb._(Map<String, String> values)
    : values = UnmodifiableMapView<String, String>(values);

  factory ObservabilityBreadcrumb.startup(ObservabilityStartupStage stage) {
    return ObservabilityBreadcrumb._(<String, String>{
      'category': 'startup',
      'event': stage.name,
    });
  }

  factory ObservabilityBreadcrumb.navigation(
    ObservabilityNavigationEvent event,
  ) {
    return ObservabilityBreadcrumb._(<String, String>{
      'category': 'navigation',
      'event': event.name,
    });
  }

  final Map<String, String> values;

  @override
  String toString() => 'ObservabilityBreadcrumb(${values.values.join(':')})';
}

final class ObservabilityBreadcrumbRecorder {
  const ObservabilityBreadcrumbRecorder({
    required ObservabilityBreadcrumbSink sink,
  }) : _sink = sink;

  final ObservabilityBreadcrumbSink _sink;

  void record(ObservabilityBreadcrumb breadcrumb) {
    try {
      _sink(breadcrumb);
    } on Object {
      // Breadcrumb寫入不得改變App behavior。
    }
  }
}
