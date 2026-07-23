import 'package:flutter_architecture/app/error_reporting/observability_breadcrumb.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('startup與navigation breadcrumb只保留typed欄位', () {
    final startup = ObservabilityBreadcrumb.startup(
      ObservabilityStartupStage.dependenciesReady,
    );
    final navigation = ObservabilityBreadcrumb.navigation(
      ObservabilityNavigationEvent.routeChanged,
    );

    expect(startup.values, <String, String>{
      'category': 'startup',
      'event': 'dependenciesReady',
    });
    expect(navigation.values, <String, String>{
      'category': 'navigation',
      'event': 'routeChanged',
    });
  });

  test('breadcrumb recorder sink失敗時不向外拋出', () {
    final recorder = ObservabilityBreadcrumbRecorder(
      sink: (_) => throw StateError('provider failure'),
    );

    expect(
      () => recorder.record(
        ObservabilityBreadcrumb.startup(
          ObservabilityStartupStage.appStarted,
        ),
      ),
      returnsNormally,
    );
  });
}
