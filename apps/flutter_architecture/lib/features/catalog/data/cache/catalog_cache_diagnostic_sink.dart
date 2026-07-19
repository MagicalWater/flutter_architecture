import 'package:core/core.dart';
import 'package:flutter_architecture/features/catalog/data/cache/catalog_cache_failure_details.dart';

abstract interface class CatalogCacheDiagnosticSink {
  void report({
    required AppException error,
    required StackTrace stackTrace,
    required CatalogCacheOperation operation,
  });
}

final class NoopCatalogCacheDiagnosticSink
    implements CatalogCacheDiagnosticSink {
  const NoopCatalogCacheDiagnosticSink();

  @override
  void report({
    required AppException error,
    required StackTrace stackTrace,
    required CatalogCacheOperation operation,
  }) {}
}
