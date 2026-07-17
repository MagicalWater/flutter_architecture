/// Catalog page item 的 SQLite Local Entity。
class CatalogCacheItemEntity {
  const CatalogCacheItemEntity({
    required this.id,
    required this.name,
    required this.description,
    required this.position,
  });

  final String id;
  final String name;
  final String description;
  final int position;
}
