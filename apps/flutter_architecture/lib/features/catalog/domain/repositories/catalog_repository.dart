import 'package:core/core.dart';
import 'package:flutter_architecture/features/catalog/domain/entities/catalog_page.dart';

/// Catalog Repository 抽象。
abstract interface class CatalogRepository {
  Future<Result<CatalogPage>> searchCatalog({
    required String query,
    required String? cursor,
    required int limit,
  });
}
