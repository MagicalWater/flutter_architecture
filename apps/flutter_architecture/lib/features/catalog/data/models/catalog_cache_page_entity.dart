import 'package:flutter_architecture/features/catalog/data/models/catalog_cache_item_entity.dart';

/// Catalog cursor page 的 SQLite Local Entity。
class CatalogCachePageEntity {
  const CatalogCachePageEntity({
    required this.query,
    required this.requestCursor,
    required this.requestLimit,
    required this.nextCursor,
    this.chainRevision = 0,
    required this.updatedAt,
    required this.items,
  });

  final String query;
  final String? requestCursor;
  final int requestLimit;
  final String? nextCursor;
  final int chainRevision;
  final DateTime updatedAt;
  final List<CatalogCacheItemEntity> items;
}
