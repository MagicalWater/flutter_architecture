import 'package:core/core.dart';
import 'package:flutter_architecture/features/catalog/data/cache/catalog_cache_failure_details.dart';

/// Catalog cache 發生可降級處理的錯誤時，統一把診斷資料交給 App error reporter。
///
/// Cache 失敗通常不該讓整個 Catalog 畫面崩潰，因此 Data 層只回報必要資訊，
/// 實際要送到哪個 observability provider 由外部實作決定。
abstract interface class CatalogCacheDiagnosticSink {
  void report({
    required AppException error,
    required StackTrace stackTrace,
    required CatalogCacheOperation operation,
  });
}

/// 不需要記錄 cache diagnostic 的情境使用，例如測試或未啟用 observability。
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
