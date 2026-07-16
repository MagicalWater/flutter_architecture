import 'package:api_client/src/models/catalog_item_dto.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'catalog_page_response_dto.freezed.dart';
part 'catalog_page_response_dto.g.dart';

/// Catalog cursor-based pagination response DTO。
@freezed
abstract class CatalogPageResponseDto with _$CatalogPageResponseDto {
  const factory CatalogPageResponseDto({
    @JsonKey(fromJson: _itemsFromJson, toJson: _itemsToJson)
    required List<CatalogItemDto> items,
    String? nextCursor,
  }) = _CatalogPageResponseDto;

  factory CatalogPageResponseDto.fromJson(Map<String, dynamic> json) =>
      _$CatalogPageResponseDtoFromJson(json);
}

List<CatalogItemDto> _itemsFromJson(List<dynamic> json) {
  return json
      .map((item) => CatalogItemDto.fromJson(item as Map<String, dynamic>))
      .toList(growable: false);
}

List<Map<String, dynamic>> _itemsToJson(List<CatalogItemDto> items) {
  return items.map((item) => item.toJson()).toList(growable: false);
}
