import 'package:flutter_architecture/features/catalog/domain/entities/catalog_page.dart';

/// 這份 Catalog 資料實際來自哪裡。
enum CatalogDataSource {
  /// 剛從後端取得。
  remote,

  /// 從本機 cache 還原。
  cache,
}

/// 這份資料是否仍在允許的有效時間內。
enum CatalogFreshness {
  /// 資料仍在有效期限內。
  fresh,

  /// 資料已過期，但在遠端更新完成前仍可暫時顯示。
  stale,
}

/// 一頁 Catalog 資料，以及它是從哪裡來、目前是否過期。
class CatalogPageSnapshot {
  const CatalogPageSnapshot({
    required this.page,
    required this.source,
    required this.freshness,
    required this.lastUpdatedAt,
  });

  final CatalogPage page;
  final CatalogDataSource source;
  final CatalogFreshness freshness;
  final DateTime lastUpdatedAt;
}
