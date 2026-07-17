import 'package:core/core.dart';
import 'package:flutter_architecture/features/catalog/domain/entities/catalog_load_policy.dart';
import 'package:flutter_architecture/features/catalog/domain/entities/catalog_page.dart';
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
    final repository = _repository;
    if (repository is CatalogStreamingRepository) {
      return repository.watchCatalog(
        query: query,
        cursor: cursor,
        limit: limit,
        policy: policy,
      );
    }

    return _legacyWatch(repository, query: query, cursor: cursor, limit: limit);
  }

  Stream<Result<CatalogPageSnapshot>> _legacyWatch(
    CatalogRepository repository, {
    required String query,
    required String? cursor,
    required int limit,
  }) async* {
    final result = await repository.searchCatalog(
      query: query,
      cursor: cursor,
      limit: limit,
    );
    yield result.when(
      success: (page) => Success(
        CatalogPageSnapshot(
          page: page,
          source: CatalogDataSource.remote,
          freshness: CatalogFreshness.fresh,
          lastUpdatedAt: DateTime.now().toUtc(),
        ),
      ),
      failure: FailureResult.new,
    );
  }

  /// Milestone 14-3 的 Presentation 相容入口。
  ///
  /// 14-4 會讓 Bloc 改為直接消費 [watch]，屆時移除此單次 remote-only API。
  Future<Result<CatalogPage>> execute({
    required String query,
    required String? cursor,
    required int limit,
  }) async {
    return _repository.searchCatalog(
      query: query,
      cursor: cursor,
      limit: limit,
    );
  }
}
