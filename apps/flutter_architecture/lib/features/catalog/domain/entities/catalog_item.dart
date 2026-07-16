import 'package:freezed_annotation/freezed_annotation.dart';

part 'catalog_item.freezed.dart';

/// Catalog 清單項目的 Domain Entity。
@freezed
abstract class CatalogItem with _$CatalogItem {
  const factory CatalogItem({
    required String id,
    required String name,
    required String description,
  }) = _CatalogItem;
}
