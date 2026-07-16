import 'package:freezed_annotation/freezed_annotation.dart';

part 'catalog_item_dto.freezed.dart';
part 'catalog_item_dto.g.dart';

/// Catalog item API DTO。
@freezed
abstract class CatalogItemDto with _$CatalogItemDto {
  const factory CatalogItemDto({
    required String id,
    required String name,
    required String description,
  }) = _CatalogItemDto;

  factory CatalogItemDto.fromJson(Map<String, dynamic> json) =>
      _$CatalogItemDtoFromJson(json);
}
