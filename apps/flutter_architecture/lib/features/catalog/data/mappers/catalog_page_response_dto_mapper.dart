import 'package:api_client/api_client.dart';
import 'package:core/core.dart';
import 'package:flutter_architecture/features/catalog/domain/entities/catalog_item.dart';
import 'package:flutter_architecture/features/catalog/domain/entities/catalog_page.dart';

/// 將 Catalog API DTO 轉為 Domain Model。
extension CatalogPageResponseDtoMapper on CatalogPageResponseDto {
  CatalogPage toDomain() {
    final mappedItems = items
        .map((item) => item.toDomain())
        .toList(growable: false);
    final rawCursor = nextCursor;

    return CatalogPage(
      items: mappedItems,
      nextCursor: rawCursor == null || rawCursor.trim().isEmpty
          ? null
          : rawCursor,
    );
  }
}

/// 將 Catalog item DTO 轉為 Domain Entity，並驗證必要欄位。
extension CatalogItemDtoMapper on CatalogItemDto {
  CatalogItem toDomain() {
    if (id.trim().isEmpty || name.trim().isEmpty) {
      throw const AppException(
        message: 'Catalog response 欄位不完整',
        code: 'malformed_catalog_response',
      );
    }

    return CatalogItem(
      id: id,
      name: name,
      description: description,
    );
  }
}
