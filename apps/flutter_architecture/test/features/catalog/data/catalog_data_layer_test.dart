import 'package:api_client/api_client.dart';
import 'package:core/core.dart';
import 'package:dio/dio.dart';
import 'package:flutter_architecture/app/database/app_database_schema.dart';
import 'package:flutter_architecture/features/catalog/data/cache/catalog_cache_policy.dart';
import 'package:flutter_architecture/features/catalog/data/cache/catalog_clock.dart';
import 'package:flutter_architecture/features/catalog/data/data_sources/catalog_local_data_source.dart';
import 'package:flutter_architecture/features/catalog/data/data_sources/catalog_remote_data_source.dart';
import 'package:flutter_architecture/features/catalog/data/mappers/catalog_page_response_dto_mapper.dart';
import 'package:flutter_architecture/features/catalog/data/repositories/catalog_repository_impl.dart';
import 'package:flutter_architecture/features/catalog/domain/entities/catalog_item.dart';
import 'package:flutter_architecture/features/catalog/domain/entities/catalog_load_policy.dart';
import 'package:flutter_architecture/features/catalog/domain/entities/catalog_page.dart';
import 'package:flutter_architecture/features/catalog/domain/entities/catalog_page_snapshot.dart';
import 'package:flutter_architecture/features/catalog/domain/repositories/catalog_repository.dart';
import 'package:flutter_architecture/features/catalog/domain/use_cases/search_catalog_use_case.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  sqfliteFfiInit();

  late Database database;
  late CatalogLocalDataSource localDataSource;

  setUp(() async {
    database = await databaseFactoryFfi.openDatabase(
      inMemoryDatabasePath,
      options: OpenDatabaseOptions(
        version: AppDatabaseSchema.version,
        onCreate: AppDatabaseSchema.onCreate,
        onUpgrade: AppDatabaseSchema.onUpgrade,
      ),
    );
    localDataSource = CatalogLocalDataSource(database);
  });

  tearDown(() => database.close());

  test('Catalog mapper 只將空 cursor 正規化為 null，其他欄位保留原值', () {
    const dto = CatalogPageResponseDto(
      items: <CatalogItemDto>[
        CatalogItemDto(
          id: ' catalog-001 ',
          name: ' Flutter ',
          description: ' framework ',
        ),
      ],
      nextCursor: '   ',
    );

    final page = dto.toDomain();

    expect(page.items.single.id, ' catalog-001 ');
    expect(page.items.single.name, ' Flutter ');
    expect(page.items.single.description, ' framework ');
    expect(page.nextCursor, isNull);
    expect(page.hasMore, isFalse);
  });

  test('Catalog mapper 會原樣保留非空 opaque cursor', () {
    const dto = CatalogPageResponseDto(
      items: <CatalogItemDto>[],
      nextCursor: ' cursor-token ',
    );

    final page = dto.toDomain();

    expect(page.nextCursor, ' cursor-token ');
    expect(page.hasMore, isTrue);
  });

  test('Catalog mapper 驗證 ID 時可 trim，但輸出 ID 必須保持原值', () {
    const dto = CatalogPageResponseDto(
      items: <CatalogItemDto>[
        CatalogItemDto(id: ' catalog-001 ', name: 'Flutter', description: ''),
      ],
    );

    final page = dto.toDomain();

    expect(page.items.single.id, ' catalog-001 ');
  });

  test('Catalog mapper 遇到空 id 或 name 會拋出 AppException', () {
    const dto = CatalogPageResponseDto(
      items: <CatalogItemDto>[
        CatalogItemDto(id: ' ', name: 'Flutter', description: ''),
      ],
    );

    expect(
      dto.toDomain,
      throwsA(
        isA<AppException>().having(
          (error) => error.code,
          'code',
          'malformed_catalog_response',
        ),
      ),
    );
  });

  test('CatalogRemoteDataSource 會傳遞參數並回傳 DTO', () async {
    final api = _RecordingCatalogApi();
    final dataSource = CatalogRemoteDataSource(api);

    final response = await dataSource.searchCatalog(
      query: 'flutter',
      cursor: 'cursor-001',
      limit: 20,
    );

    expect(api.query, 'flutter');
    expect(api.cursor, 'cursor-001');
    expect(api.limit, 20);
    expect(response.nextCursor, 'cursor-002');
  });

  test('CatalogRemoteDataSource 會把 DioException 映射為 AppException', () async {
    final dataSource = CatalogRemoteDataSource(
      _ThrowingCatalogApi(_dioException()),
    );

    await expectLater(
      dataSource.searchCatalog(query: '', cursor: null, limit: 20),
      throwsA(isA<AppException>().having((error) => error.code, 'code', '503')),
    );
  });

  test('CatalogRepository 會把 DTO 映射為成功結果', () async {
    final repository = _repository(_RecordingCatalogApi(), localDataSource);

    final result = await repository
        .watchCatalog(
          query: 'flutter',
          cursor: null,
          limit: 20,
          policy: CatalogLoadPolicy.refresh,
        )
        .single;

    final page = result.when(
      success: (value) => value.page,
      failure: (_) => throw StateError('unexpected failure'),
    );

    expect(page.items.single.id, 'catalog-001');
    expect(page.nextCursor, 'cursor-002');
  });

  test('CatalogRepository 拒絕無法前進的 cursor chain', () async {
    final repository = _repository(
      const _StaticCatalogApi(
        CatalogPageResponseDto(
          items: <CatalogItemDto>[],
          nextCursor: 'cursor-001',
        ),
      ),
      localDataSource,
    );

    final result = await repository
        .watchCatalog(
          query: '',
          cursor: 'cursor-001',
          limit: 20,
          policy: CatalogLoadPolicy.append,
        )
        .single;

    final failure = result.when(
      success: (_) => throw StateError('unexpected success'),
      failure: (value) => value as Failure,
    );

    expect(failure.code, 'non_advancing_catalog_cursor');
    expect(failure.message, '取得 Catalog 失敗');
  });

  test('CatalogRepository 會把 AppException 轉為 domain Failure', () async {
    final repository = _repository(
      const _ThrowingCatalogApi(
        AppException(message: 'API failed', code: '503'),
      ),
      localDataSource,
    );

    final result = await repository
        .watchCatalog(
          query: '',
          cursor: null,
          limit: 20,
          policy: CatalogLoadPolicy.refresh,
        )
        .single;

    final failure = result.when(
      success: (_) => throw StateError('unexpected success'),
      failure: (value) => value as Failure,
    );

    expect(failure.message, '取得 Catalog 失敗');
    expect(failure.code, '503');
  });

  test(
    'CatalogRepository 會把 Mapper 的 AppException 轉為 domain Failure',
    () async {
      final repository = _repository(
        const _StaticCatalogApi(
          CatalogPageResponseDto(
            items: <CatalogItemDto>[
              CatalogItemDto(id: ' ', name: 'Flutter', description: ''),
            ],
          ),
        ),
        localDataSource,
      );

      final result = await repository
          .watchCatalog(
            query: '',
            cursor: null,
            limit: 20,
            policy: CatalogLoadPolicy.refresh,
          )
          .single;

      final failure = result.when(
        success: (_) => throw StateError('unexpected success'),
        failure: (value) => value as Failure,
      );

      expect(failure.code, 'malformed_catalog_response');
      expect(failure.message, '取得 Catalog 失敗');
    },
  );

  test('CatalogRepository 不會把未知錯誤轉為 Failure', () async {
    final error = StateError('mapper bug');
    final repository = _repository(_ThrowingCatalogApi(error), localDataSource);

    await expectLater(
      repository.watchCatalog(
        query: '',
        cursor: null,
        limit: 20,
        policy: CatalogLoadPolicy.refresh,
      ),
      emitsError(same(error)),
    );
  });

  test('SearchCatalogUseCase 會原樣傳遞搜尋參數', () async {
    final repository = _RecordingCatalogRepository();
    final useCase = SearchCatalogUseCase(repository);

    await useCase
        .watch(
          query: 'flutter',
          cursor: 'cursor-001',
          limit: 30,
          policy: CatalogLoadPolicy.append,
        )
        .single;

    expect(repository.query, 'flutter');
    expect(repository.cursor, 'cursor-001');
    expect(repository.limit, 30);
  });
}

CatalogRepositoryImpl _repository(
  CatalogApi api,
  CatalogLocalDataSource localDataSource,
) {
  return CatalogRepositoryImpl(
    CatalogRemoteDataSource(api),
    localDataSource,
    CatalogCachePolicy(),
    const SystemCatalogClock(),
  );
}

class _RecordingCatalogApi implements CatalogApi {
  String? query;
  String? cursor;
  int? limit;

  @override
  Future<CatalogPageResponseDto> searchCatalog({
    required String query,
    String? cursor,
    required int limit,
  }) async {
    this.query = query;
    this.cursor = cursor;
    this.limit = limit;

    return const CatalogPageResponseDto(
      items: <CatalogItemDto>[
        CatalogItemDto(
          id: 'catalog-001',
          name: 'Flutter',
          description: 'framework',
        ),
      ],
      nextCursor: 'cursor-002',
    );
  }
}

class _StaticCatalogApi implements CatalogApi {
  const _StaticCatalogApi(this.response);

  final CatalogPageResponseDto response;

  @override
  Future<CatalogPageResponseDto> searchCatalog({
    required String query,
    String? cursor,
    required int limit,
  }) async {
    return response;
  }
}

class _ThrowingCatalogApi implements CatalogApi {
  const _ThrowingCatalogApi(this.error);

  final Object error;

  @override
  Future<CatalogPageResponseDto> searchCatalog({
    required String query,
    String? cursor,
    required int limit,
  }) async {
    throw error;
  }
}

class _RecordingCatalogRepository implements CatalogRepository {
  String? query;
  String? cursor;
  int? limit;

  @override
  Stream<Result<CatalogPageSnapshot>> watchCatalog({
    required String query,
    required String? cursor,
    required int limit,
    required CatalogLoadPolicy policy,
  }) async* {
    this.query = query;
    this.cursor = cursor;
    this.limit = limit;
    yield Success<CatalogPageSnapshot>(
      CatalogPageSnapshot(
        page: const CatalogPage(items: <CatalogItem>[]),
        source: CatalogDataSource.remote,
        freshness: CatalogFreshness.fresh,
        lastUpdatedAt: DateTime.utc(2026, 7, 17),
      ),
    );
  }
}

DioException _dioException() {
  final request = RequestOptions(path: '/catalog');
  return DioException(
    requestOptions: request,
    response: Response<void>(requestOptions: request, statusCode: 503),
  );
}
