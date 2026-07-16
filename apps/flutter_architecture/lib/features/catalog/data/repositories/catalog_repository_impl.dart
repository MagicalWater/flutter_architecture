import 'package:core/core.dart';
import 'package:flutter_architecture/features/catalog/data/data_sources/catalog_remote_data_source.dart';
import 'package:flutter_architecture/features/catalog/data/mappers/catalog_page_response_dto_mapper.dart';
import 'package:flutter_architecture/features/catalog/domain/entities/catalog_page.dart';
import 'package:flutter_architecture/features/catalog/domain/repositories/catalog_repository.dart';

/// CatalogRepository 的 Data Layer 實作。
class CatalogRepositoryImpl implements CatalogRepository {
  const CatalogRepositoryImpl(this._remoteDataSource);

  final CatalogRemoteDataSource _remoteDataSource;

  @override
  Future<Result<CatalogPage>> searchCatalog({
    required String query,
    required String? cursor,
    required int limit,
  }) async {
    try {
      final response = await _remoteDataSource.searchCatalog(
        query: query,
        cursor: cursor,
        limit: limit,
      );
      final page = response.toDomain();

      if (cursor != null &&
          cursor.trim().isNotEmpty &&
          page.nextCursor == cursor) {
        throw const AppException(
          message: 'Catalog pagination cursor 無法前進',
          code: 'non_advancing_catalog_cursor',
        );
      }

      return Success(page);
    } on AppException catch (error) {
      return FailureResult(
        mapAppExceptionToFailure(error, fallbackMessage: '取得 Catalog 失敗'),
      );
    }
  }
}
