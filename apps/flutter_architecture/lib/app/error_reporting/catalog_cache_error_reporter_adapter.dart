import 'package:core/core.dart';
import 'package:flutter_architecture/app/error_reporting/error_report.dart';
import 'package:flutter_architecture/app/error_reporting/error_reporter.dart';
import 'package:flutter_architecture/features/catalog/data/cache/catalog_cache_diagnostic_sink.dart';
import 'package:flutter_architecture/features/catalog/data/cache/catalog_cache_failure_details.dart';

/// 將 Catalog cache diagnostics 映射到 App error reporting，且不得干擾 cache fallback。
final class CatalogCacheErrorReporterAdapter
    implements CatalogCacheDiagnosticSink {
  const CatalogCacheErrorReporterAdapter(this._reporter);

  final ErrorReporter _reporter;

  @override
  void report({
    required AppException error,
    required StackTrace stackTrace,
    required CatalogCacheOperation operation,
  }) {
    try {
      _reporter.report(
        ErrorReport(
          error: error,
          stackTrace: stackTrace,
          severity: ErrorSeverity.degraded,
          context: ErrorReportContext(operation: _operationFor(operation)),
        ),
      );
    } on Object {
      // Reporting不得改變Catalog cache fallback或Remote success。
    }
  }
}

ErrorReportOperation _operationFor(CatalogCacheOperation operation) {
  return switch (operation) {
    CatalogCacheOperation.readPage || CatalogCacheOperation.readChainRevision =>
      ErrorReportOperation.catalogCacheRead,
    CatalogCacheOperation.corruptionCleanup ||
    CatalogCacheOperation.expiredCleanup ||
    CatalogCacheOperation.deletePage =>
      ErrorReportOperation.catalogCacheCleanup,
    CatalogCacheOperation.writeFirstPage ||
    CatalogCacheOperation.writePage ||
    CatalogCacheOperation.writeAppendPage =>
      ErrorReportOperation.catalogCacheWrite,
  };
}
