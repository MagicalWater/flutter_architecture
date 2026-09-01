import 'package:api_client/src/api/catalog_retrofit_api.dart';
import 'package:api_client/src/models/catalog_item_dto.dart';
import 'package:api_client/src/models/catalog_page_response_dto.dart';

/// Catalog API 的 Mock implementation。
///
/// Cursor 是 Mock 私有的 opaque value；呼叫端只應保存並原樣傳回。
class MockCatalogApi implements CatalogApi {
  const MockCatalogApi({
    this.responseDelay = const Duration(milliseconds: 300),
  });

  final Duration responseDelay;

  static const List<CatalogItemDto> _items = <CatalogItemDto>[
    CatalogItemDto(
      id: 'catalog-001',
      name: 'Flutter',
      description: '跨平台 App 開發框架',
    ),
    CatalogItemDto(
      id: 'catalog-002',
      name: 'Dart',
      description: 'Flutter 使用的程式語言',
    ),
    CatalogItemDto(id: 'catalog-003', name: 'Bloc', description: '事件驅動狀態管理'),
    CatalogItemDto(
      id: 'catalog-004',
      name: 'Freezed',
      description: 'Immutable model 與 union code generation',
    ),
    CatalogItemDto(
      id: 'catalog-005',
      name: 'Retrofit',
      description: '宣告式 HTTP API client',
    ),
    CatalogItemDto(
      id: 'catalog-006',
      name: 'Dio',
      description: 'Dart HTTP transport client',
    ),
    CatalogItemDto(
      id: 'catalog-007',
      name: 'AutoRoute',
      description: 'Flutter typed routing',
    ),
    CatalogItemDto(
      id: 'catalog-008',
      name: 'GetIt',
      description: 'Service locator 與 composition support',
    ),
    CatalogItemDto(
      id: 'catalog-009',
      name: 'Injectable',
      description: 'GetIt registration code generation',
    ),
    CatalogItemDto(
      id: 'catalog-010',
      name: 'RxDart',
      description: 'Reactive stream extensions',
    ),
    CatalogItemDto(id: 'catalog-011', name: 'SQLite', description: '本地關聯式資料庫'),
    CatalogItemDto(
      id: 'catalog-012',
      name: 'SharedPreferences',
      description: '簡單 key-value persistence',
    ),
  ];

  @override
  Future<CatalogPageResponseDto> searchCatalog({
    required String query,
    String? cursor,
    required int limit,
  }) async {
    if (limit <= 0) {
      throw ArgumentError.value(limit, 'limit', '必須大於 0');
    }

    await Future<void>.delayed(responseDelay);

    final normalizedQuery = query.trim().toLowerCase();
    final filteredItems = normalizedQuery.isEmpty
        ? _items
        : _items
              .where((item) {
                return item.name.toLowerCase().contains(normalizedQuery) ||
                    item.description.toLowerCase().contains(normalizedQuery);
              })
              .toList(growable: false);
    final offset = _decodeCursor(cursor, expectedQuery: normalizedQuery);
    if (offset > filteredItems.length) {
      throw ArgumentError.value(cursor, 'cursor', '超出目前搜尋結果範圍');
    }

    final end = (offset + limit).clamp(0, filteredItems.length);
    final pageItems = filteredItems.sublist(offset, end);
    final nextCursor = end < filteredItems.length
        ? _encodeCursor(offset: end, normalizedQuery: normalizedQuery)
        : null;

    return CatalogPageResponseDto(items: pageItems, nextCursor: nextCursor);
  }

  /// 解析 mock cursor，並驗證它仍屬於目前 query；跨 query 沿用 cursor 視為無效。
  static int _decodeCursor(String? cursor, {required String expectedQuery}) {
    if (cursor == null) {
      return 0;
    }

    const prefix = 'offset:';
    if (!cursor.startsWith(prefix)) {
      throw ArgumentError.value(cursor, 'cursor', '格式不合法');
    }

    final separatorIndex = cursor.indexOf(':', prefix.length);
    if (separatorIndex < 0) {
      throw ArgumentError.value(cursor, 'cursor', '格式不合法');
    }

    final offset = int.tryParse(
      cursor.substring(prefix.length, separatorIndex),
    );
    if (offset == null || offset < 0) {
      throw ArgumentError.value(cursor, 'cursor', '格式不合法');
    }

    final cursorQuery = Uri.decodeComponent(
      cursor.substring(separatorIndex + 1),
    );
    if (cursorQuery != expectedQuery) {
      throw ArgumentError.value(cursor, 'cursor', '不屬於目前搜尋條件');
    }

    return offset;
  }

  /// 建立 mock 私有的 opaque cursor；格式只供 deterministic fixture 使用。
  static String _encodeCursor({
    required int offset,
    required String normalizedQuery,
  }) {
    return 'offset:$offset:${Uri.encodeComponent(normalizedQuery)}';
  }
}
