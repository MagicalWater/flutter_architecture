import 'package:flutter_architecture/features/catalog/domain/entities/catalog_page.dart';

enum CatalogDataSource { remote, cache }

enum CatalogFreshness { fresh, stale }

/// Catalog page 與資料來源 metadata。
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
