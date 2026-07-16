import 'package:core/core.dart';
import 'package:flutter_architecture/features/catalog/domain/entities/catalog_page.dart';
import 'package:flutter_architecture/features/catalog/domain/repositories/catalog_repository.dart';
import 'package:injectable/injectable.dart';

/// 搜尋 Catalog；Initial、Refresh 與 Append 都共用此業務行為。
@injectable
class SearchCatalogUseCase {
  const SearchCatalogUseCase(this._repository);

  final CatalogRepository _repository;

  Future<Result<CatalogPage>> execute({
    required String query,
    required String? cursor,
    required int limit,
  }) {
    return _repository.searchCatalog(
      query: query,
      cursor: cursor,
      limit: limit,
    );
  }
}
