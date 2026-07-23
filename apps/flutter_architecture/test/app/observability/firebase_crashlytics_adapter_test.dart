import 'package:flutter_architecture/app/config/app_environment.dart';
import 'package:flutter_architecture/app/error_reporting/error_report.dart';
import 'package:flutter_architecture/app/error_reporting/error_reporter.dart';
import 'package:flutter_architecture/app/observability/firebase_crashlytics_adapter.dart';
import 'package:flutter_architecture/app/observability/observability_collection_policy.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test(
    'initializer applies explicit collection policy after Firebase init',
    () async {
      final gateway = _FakeGateway();
      final initializer = FirebaseObservabilityInitializer(
        gateway: gateway,
        collectionPolicy: const ObservabilityCollectionPolicy.enabled(
          AppEnvironment.staging,
        ),
        initialKeys: const <String, String>{
          'release': '1.8.0+42',
          'environment': 'staging',
          'commit_sha': 'abc1234',
        },
      );

      await initializer.initialize();

      expect(gateway.calls, <String>['initialize', 'collection:true']);
      expect(gateway.keys.single, containsPair('environment', 'staging'));
    },
  );

  test(
    'disabled policy remains disabled even when provider is available',
    () async {
      final gateway = _FakeGateway();
      final initializer = FirebaseObservabilityInitializer(
        gateway: gateway,
        collectionPolicy: ObservabilityCollectionPolicy.defaults(
          AppEnvironment.production,
        ),
      );

      await initializer.initialize();

      expect(gateway.calls, <String>['initialize', 'collection:false']);
    },
  );

  test('adapter maps fatal and non-fatal without user identifier', () async {
    final gateway = _FakeGateway();
    final adapter = FirebaseCrashlyticsErrorReporter(gateway);
    final stack = StackTrace.current;

    adapter.report(
      ErrorReport(
        error: StateError('secret-token'),
        stackTrace: stack,
        severity: ErrorSeverity.fatal,
        context: const ErrorReportContext(
          source: ErrorReportSource.platform,
          operation: ErrorReportOperation.platformUncaughtAsync,
        ),
      ),
    );
    adapter.report(
      ErrorReport(
        error: ArgumentError('otp=123456'),
        stackTrace: stack,
        severity: ErrorSeverity.unexpected,
        context: const ErrorReportContext(
          source: ErrorReportSource.bloc,
          operation: ErrorReportOperation.blocUnhandledError,
        ),
      ),
    );

    await Future<void>.delayed(Duration.zero);

    expect(gateway.records.map((record) => record.fatal), <bool>[true, false]);
    expect(gateway.userIdentifierCalls, 0);
    expect(gateway.keys, hasLength(2));
    expect(
      gateway.keys.first.keys,
      containsAll(<String>['severity', 'source', 'operation', 'error_type']),
    );
    expect(gateway.keys.toString(), isNot(contains('secret-token')));
    expect(gateway.keys.toString(), isNot(contains('123456')));
  });

  test('adapter absorbs asynchronous gateway failure', () async {
    final gateway = _FakeGateway()..throwOnRecord = true;
    final adapter = FirebaseCrashlyticsErrorReporter(gateway);

    adapter.report(
      ErrorReport(
        error: StateError('failure'),
        stackTrace: StackTrace.current,
        severity: ErrorSeverity.unexpected,
        context: const ErrorReportContext(
          source: ErrorReportSource.flutterFramework,
          operation: ErrorReportOperation.flutterFrameworkError,
        ),
      ),
    );

    await Future<void>.delayed(Duration.zero);
  });

  test(
    'composition falls back locally when Firebase initialization fails',
    () async {
      final gateway = _FakeGateway()..throwOnInitialize = true;
      const fallback = NoopErrorReporter();

      final result = await FirebaseObservabilityComposition(
        gateway: gateway,
        collectionPolicy: ObservabilityCollectionPolicy.defaults(
          AppEnvironment.development,
        ),
        localFallback: fallback,
      ).compose();

      expect(result.initialization.available, isFalse);
      expect(result.reporter, same(fallback));
    },
  );
}

final class _FakeGateway implements FirebaseCrashlyticsGateway {
  final List<String> calls = <String>[];
  final List<Map<String, String>> keys = <Map<String, String>>[];
  final List<({Object error, StackTrace stackTrace, bool fatal})> records = [];
  bool throwOnRecord = false;
  bool throwOnInitialize = false;
  int userIdentifierCalls = 0;

  @override
  Future<void> initializeFirebase() async {
    if (throwOnInitialize) throw StateError('firebase unavailable');
    calls.add('initialize');
  }

  @override
  Future<void> setCollectionEnabled(bool enabled) async {
    calls.add('collection:$enabled');
  }

  @override
  Future<void> setCustomKeys(Map<String, String> values) async {
    keys.add(values);
  }

  @override
  Future<void> recordError(
    Object error,
    StackTrace stackTrace, {
    required bool fatal,
  }) async {
    if (throwOnRecord) throw StateError('provider failed');
    records.add((error: error, stackTrace: stackTrace, fatal: fatal));
  }

  @override
  Future<void> setUserIdentifier(String identifier) async {
    userIdentifierCalls += 1;
  }
}
