import 'package:core/core.dart';
import 'package:flutter_architecture/features/catalog/domain/entities/catalog_load_policy.dart';
import 'package:flutter_architecture/features/catalog/domain/entities/catalog_page_snapshot.dart';

/// 支援 Offline Cache / SWR 多次 emission 的 Catalog Repository contract。
abstract interface class CatalogRepository {
  Stream<Result<CatalogPageSnapshot>> watchCatalog({
    required String query,
    required String? cursor,
    required int limit,
    required CatalogLoadPolicy policy,
  });
}
