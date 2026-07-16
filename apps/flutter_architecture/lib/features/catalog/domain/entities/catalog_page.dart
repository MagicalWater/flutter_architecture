import 'package:flutter_architecture/features/catalog/domain/entities/catalog_item.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'catalog_page.freezed.dart';

/// Catalog cursor-based pagination 的 Domain Model。
@freezed
abstract class CatalogPage with _$CatalogPage {
  const factory CatalogPage({
    required List<CatalogItem> items,
    String? nextCursor,
  }) = _CatalogPage;

  const CatalogPage._();

  /// 是否仍有下一頁；唯一真相仍是 [nextCursor]。
  bool get hasMore => nextCursor != null;
}
