import 'dart:collection';

/// App 啟動流程已完成到哪一個階段，用來留下除錯 breadcrumb。
enum ObservabilityStartupStage {
  /// Dart main／bootstrap 已開始。
  appStarted,

  /// Flutter bindings 已初始化。
  bindingsReady,

  /// DI 與必要依賴已完成建立。
  dependenciesReady,

  /// Root App widget 已掛上 widget tree。
  appMounted,
}

/// 導航相關 breadcrumb 的事件種類。
enum ObservabilityNavigationEvent {
  /// 一般 route 發生切換。
  routeChanged,

  /// 因登入狀態改變而自動導向其他頁面。
  authenticationRedirect,
}

typedef ObservabilityBreadcrumbSink =
    void Function(ObservabilityBreadcrumb breadcrumb);

/// 一筆只含低敏感度文字欄位的 breadcrumb，記錄 App 剛才發生了哪類事件。
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

/// 將 breadcrumb 安全送到 observability provider；provider 失敗不能影響 App 流程。
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
