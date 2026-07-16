import 'package:api_client/src/models/catalog_page_response_dto.dart';
import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

part 'catalog_retrofit_api.g.dart';

/// Catalog public HTTP API boundary。
@RestApi()
abstract class CatalogApi {
  factory CatalogApi(Dio dio, {String? baseUrl}) = _CatalogApi;

  @GET('/catalog')
  Future<CatalogPageResponseDto> searchCatalog({
    @Query('query') required String query,
    @Query('cursor') String? cursor,
    @Query('limit') required int limit,
  });
}
