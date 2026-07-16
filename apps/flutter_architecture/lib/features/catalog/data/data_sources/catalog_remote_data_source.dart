import 'package:api_client/api_client.dart';
import 'package:injectable/injectable.dart';

/// Catalog 遠端資料來源。
///
/// 負責呼叫 Catalog API abstraction，並在 transport boundary 將已知 HTTP
/// exception 映射為共用 AppException。
@lazySingleton
class CatalogRemoteDataSource {
  const CatalogRemoteDataSource(this._catalogApi);

  final CatalogApi _catalogApi;

  Future<CatalogPageResponseDto> searchCatalog({
    required String query,
    required String? cursor,
    required int limit,
  }) async {
    try {
      return await _catalogApi.searchCatalog(
        query: query,
        cursor: cursor,
        limit: limit,
      );
    } catch (error, stackTrace) {
      rethrowMappedTransportException(error, stackTrace);
    }
  }
}
