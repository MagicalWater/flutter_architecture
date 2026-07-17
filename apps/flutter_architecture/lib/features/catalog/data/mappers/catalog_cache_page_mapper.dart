import 'package:flutter_architecture/features/catalog/data/models/catalog_cache_item_entity.dart';
import 'package:flutter_architecture/features/catalog/data/models/catalog_cache_page_entity.dart';
import 'package:flutter_architecture/features/catalog/domain/entities/catalog_item.dart';
import 'package:flutter_architecture/features/catalog/domain/entities/catalog_page.dart';

extension CatalogPageToCacheEntity on CatalogPage {
  CatalogCachePageEntity toCacheEntity({
    required String query,
    required String? requestCursor,
    required int requestLimit,
    required DateTime updatedAt,
  }) {
    return CatalogCachePageEntity(
      query: query.trim(),
      requestCursor: requestCursor,
      requestLimit: requestLimit,
      nextCursor: nextCursor,
      updatedAt: updatedAt.toUtc(),
      items: <CatalogCacheItemEntity>[
        for (var index = 0; index < items.length; index++)
          CatalogCacheItemEntity(
            id: items[index].id,
            name: items[index].name,
            description: items[index].description,
            position: index,
          ),
      ],
    );
  }
}

extension CatalogCachePageEntityToDomain on CatalogCachePageEntity {
  CatalogPage toDomain() {
    final sortedItems = [...items]
      ..sort((left, right) => left.position.compareTo(right.position));

    return CatalogPage(
      items: <CatalogItem>[
        for (final item in sortedItems)
          CatalogItem(
            id: item.id,
            name: item.name,
            description: item.description,
          ),
      ],
      nextCursor: nextCursor,
    );
  }
}
