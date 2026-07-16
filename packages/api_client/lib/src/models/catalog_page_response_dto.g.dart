// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'catalog_page_response_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_CatalogPageResponseDto _$CatalogPageResponseDtoFromJson(
  Map<String, dynamic> json,
) => _CatalogPageResponseDto(
  items: _itemsFromJson(json['items'] as List),
  nextCursor: json['nextCursor'] as String?,
);

Map<String, dynamic> _$CatalogPageResponseDtoToJson(
  _CatalogPageResponseDto instance,
) => <String, dynamic>{
  'items': _itemsToJson(instance.items),
  'nextCursor': instance.nextCursor,
};
