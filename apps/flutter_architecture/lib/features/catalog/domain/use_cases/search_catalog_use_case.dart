import 'package:core/core.dart';
import 'package:flutter_architecture/features/catalog/domain/entities/catalog_load_policy.dart';
import 'package:flutter_architecture/features/catalog/domain/entities/catalog_page_snapshot.dart';
import 'package:flutter_architecture/features/catalog/domain/repositories/catalog_repository.dart';
import 'package:injectable/injectable.dart';

/// 搜尋 Catalog；Initial、Refresh 與 Append 都共用此業務行為。
@injectable
class SearchCatalogUseCase {
  const SearchCatalogUseCase(this._repository);

  final CatalogRepository _repository;

  Stream<Result<CatalogPageSnapshot>> watch({
    required String query,
    required String? cursor,
    required int limit,
    required CatalogLoadPolicy policy,
  }) {
    return _repository.watchCatalog(
      query: query,
      cursor: cursor,
      limit: limit,
      policy: policy,
    );
  }
}
