import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter_architecture/app/error_reporting/error_report.dart';
import 'package:flutter_architecture/app/error_reporting/error_reporter.dart';
import 'package:flutter_architecture/app/error_reporting/error_reporting_router.dart';
import 'package:flutter_architecture/app/observability/observability_collection_policy.dart';
import 'package:flutter_architecture/app/observability/observability_provider_lifecycle.dart';

/// 把 App 需要的 Crashlytics 操作整理成小介面，避免其他 observability code 直接依賴 Firebase SDK。
abstract interface class FirebaseCrashlyticsGateway {
  Future<void> initializeFirebase();
  Future<void> setCollectionEnabled(bool enabled);
  Future<void> setCustomKeys(Map<String, String> values);
  Future<void> recordError(
    Object error,
    StackTrace stackTrace, {
    required bool fatal,
  });
  Future<void> setUserIdentifier(String identifier);
}

/// 直接呼叫 Firebase SDK 的 production 實作。
final class FirebaseSdkCrashlyticsGateway
    implements FirebaseCrashlyticsGateway {
  const FirebaseSdkCrashlyticsGateway();

  @override
  Future<void> initializeFirebase() => Firebase.initializeApp();

  @override
  Future<void> setCollectionEnabled(bool enabled) {
    return FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(
      enabled,
    );
  }

  @override
  Future<void> setCustomKeys(Map<String, String> values) async {
    for (final entry in values.entries) {
      await FirebaseCrashlytics.instance.setCustomKey(entry.key, entry.value);
    }
  }

  @override
  Future<void> recordError(
    Object error,
    StackTrace stackTrace, {
    required bool fatal,
  }) {
    return FirebaseCrashlytics.instance.recordError(
      error,
      stackTrace,
      fatal: fatal,
    );
  }

  @override
  Future<void> setUserIdentifier(String identifier) {
    return FirebaseCrashlytics.instance.setUserIdentifier(identifier);
  }
}

/// 將 Firebase / Crashlytics 初始化收斂到受 collection policy 控制的單一入口。
final class FirebaseObservabilityInitializer
    implements ObservabilityProviderInitializer {
  const FirebaseObservabilityInitializer({
    required FirebaseCrashlyticsGateway gateway,
    required ObservabilityCollectionPolicy collectionPolicy,
    this.initialKeys = const <String, String>{},
  }) : _gateway = gateway,
       _collectionPolicy = collectionPolicy;

  final FirebaseCrashlyticsGateway _gateway;
  final ObservabilityCollectionPolicy _collectionPolicy;
  final Map<String, String> initialKeys;

  @override
  Future<void> initialize() async {
    await _gateway.initializeFirebase();
    await _gateway.setCollectionEnabled(
      _collectionPolicy.remoteCollectionEnabled,
    );
    if (initialKeys.isNotEmpty) {
      await _gateway.setCustomKeys(initialKeys);
    }
  }
}

/// Best-effort Crashlytics reporter；provider failure 不得反向改變 App control flow。
final class FirebaseCrashlyticsErrorReporter implements ErrorReporter {
  const FirebaseCrashlyticsErrorReporter(this._gateway);

  final FirebaseCrashlyticsGateway _gateway;

  @override
  void report(ErrorReport report) {
    unawaited(_report(report));
  }

  Future<void> _report(ErrorReport report) async {
    try {
      await _gateway.setCustomKeys(
        ErrorReportMetadata.fromReport(report).values,
      );
      await _gateway.recordError(
        report.error,
        report.stackTrace,
        fatal: report.severity == ErrorSeverity.fatal,
      );
    } on Object {
      // Provider adapter必須維持best effort，且不得遞迴上報自身失敗。
    }
  }
}

/// Crashlytics 組裝完成後，回傳實際可用的 reporter 與 provider 初始化結果。
///
/// 初始化失敗時 [reporter] 會是 local fallback，讓 App 仍可啟動並保留本機診斷能力。
final class FirebaseObservabilityCompositionResult {
  const FirebaseObservabilityCompositionResult({
    required this.reporter,
    required this.initialization,
  });

  final ErrorReporter reporter;
  final ObservabilityProviderInitializationResult initialization;
}

/// 嘗試啟用 Firebase Crashlytics；如果初始化失敗，就退回既有 local reporter。
final class FirebaseObservabilityComposition {
  const FirebaseObservabilityComposition({
    required this.gateway,
    required this.collectionPolicy,
    required this.localFallback,
    this.initialKeys = const <String, String>{},
  });

  final FirebaseCrashlyticsGateway gateway;
  final ObservabilityCollectionPolicy collectionPolicy;
  final ErrorReporter localFallback;
  final Map<String, String> initialKeys;

  Future<FirebaseObservabilityCompositionResult> compose() async {
    final initialization = await ObservabilityProviderLifecycle(
      FirebaseObservabilityInitializer(
        gateway: gateway,
        collectionPolicy: collectionPolicy,
        initialKeys: initialKeys,
      ),
    ).initialize();

    return FirebaseObservabilityCompositionResult(
      reporter: initialization.available
          ? FirebaseCrashlyticsErrorReporter(gateway)
          : localFallback,
      initialization: initialization,
    );
  }
}
