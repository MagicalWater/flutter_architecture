import 'dart:convert';
import 'dart:typed_data';

import 'package:api_client/api_client.dart';
import 'package:core/core.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('MockAuthApi.login 會回傳 mock token 與使用者資料', () async {
    const client = MockAuthApi();

    final response = await client.login(
      const LoginRequestDto(
        account: 'demo',
        password: 'password',
      ),
    );

    expect(response.accessToken, isNotEmpty);
    expect(response.userName, 'Water Magical');
  });

  test('MockProfileApi.getProfile 會回傳 mock 使用者資料', () async {
    const api = MockProfileApi();

    final response = await api.getProfile();

    expect(response.id, 'user-001');
    expect(response.name, 'Water Magical');
  });

  test('MockCatalogApi 支援 cursor pagination 與搜尋', () async {
    const api = MockCatalogApi(responseDelay: Duration.zero);

    final firstPage = await api.searchCatalog(
      query: '',
      cursor: null,
      limit: 5,
    );
    final secondPage = await api.searchCatalog(
      query: '',
      cursor: firstPage.nextCursor,
      limit: 5,
    );
    final lastPage = await api.searchCatalog(
      query: '',
      cursor: secondPage.nextCursor,
      limit: 5,
    );
    final searchPage = await api.searchCatalog(
      query: 'flutter',
      cursor: null,
      limit: 10,
    );

    expect(firstPage.items, hasLength(5));
    expect(firstPage.nextCursor, 'offset:5');
    expect(secondPage.items, hasLength(5));
    expect(secondPage.items.first.id, 'catalog-006');
    expect(secondPage.nextCursor, 'offset:10');
    expect(lastPage.items, hasLength(2));
    expect(lastPage.nextCursor, isNull);
    expect(searchPage.items.map((item) => item.id), contains('catalog-001'));
  });

  test('Login DTO 可以正確進行 JSON serialization', () {
    const request = LoginRequestDto(
      account: 'demo',
      password: 'super-secret',
    );
    const response = LoginResponseDto(
      accessToken: 'token',
      refreshToken: 'refresh-token',
      userId: 'user-001',
      userName: 'Water Magical',
    );

    expect(request.toJson(), <String, dynamic>{
      'account': 'demo',
      'password': 'super-secret',
    });
    expect(LoginResponseDto.fromJson(response.toJson()), response);
    expect(request.toString(), isNot(contains('super-secret')));
    expect(request.toString(), isNot(contains('demo')));
  });

  test('ProfileResponseDto 可以正確進行 JSON serialization', () {
    const response = ProfileResponseDto(
      id: 'user-001',
      name: 'Water Magical',
    );

    expect(ProfileResponseDto.fromJson(response.toJson()), response);
  });

  test('Catalog DTO 可以正確進行 JSON serialization', () {
    const response = CatalogPageResponseDto(
      items: <CatalogItemDto>[
        CatalogItemDto(
          id: 'catalog-001',
          name: 'Flutter',
          description: '跨平台 App 開發框架',
        ),
      ],
      nextCursor: 'cursor-002',
    );

    expect(CatalogPageResponseDto.fromJson(response.toJson()), response);
  });

  test('Transport mapper 會把 DioException 轉為 AppException', () {
    final request = RequestOptions(path: '/auth/login', method: 'POST');
    final error = DioException(
      requestOptions: request,
      response: Response<void>(
        requestOptions: request,
        statusCode: 503,
      ),
    );

    expect(
      () => rethrowMappedTransportException(error, StackTrace.current),
      throwsA(
        isA<AppException>()
            .having((value) => value.code, 'code', '503')
            .having(
              (value) => value.cause,
              'safe cause',
              isA<TransportFailureDetails>()
                  .having((details) => details.method, 'method', 'POST')
                  .having((details) => details.path, 'path', '/auth/login'),
            ),
      ),
    );
  });

  test('Transport mapper 不會吞掉未知錯誤', () {
    final error = StateError('mapper bug');

    expect(
      () => rethrowMappedTransportException(error, StackTrace.current),
      throwsA(same(error)),
    );
  });

  test('AuthApi 會以 POST JSON 呼叫登入 endpoint 並解析 DTO', () async {
    final adapter = _RecordingAdapter();
    final dio = Dio(BaseOptions(baseUrl: 'https://example.test'))
      ..httpClientAdapter = adapter;
    final api = AuthApi(dio);

    final response = await api.login(
      const LoginRequestDto(
        account: 'demo',
        password: 'password',
      ),
    );

    expect(adapter.method, 'POST');
    expect(adapter.path, '/auth/login');
    expect(adapter.extra[RequestExtras.requiresAuth], isNot(true));
    expect(adapter.body, <String, dynamic>{
      'account': 'demo',
      'password': 'password',
    });
    expect(response.accessToken, 'real-access-token');
    expect(response.userId, 'user-002');
  });

  test('AuthRefreshApi 使用獨立 endpoint 並標記 skipAuthRefresh', () async {
    final adapter = _RecordingAdapter();
    final dio = Dio(BaseOptions(baseUrl: 'https://example.test'))
      ..httpClientAdapter = adapter;
    final api = AuthRefreshApi(dio);

    final response = await api.refresh(
      const RefreshTokenRequestDto(refreshToken: 'refresh-token'),
    );

    expect(adapter.method, 'POST');
    expect(adapter.path, '/auth/refresh');
    expect(adapter.extra[RequestExtras.requiresAuth], isNot(true));
    expect(adapter.extra[RequestExtras.skipAuthRefresh], isTrue);
    expect(response.accessToken, 'new-access-token');
    expect(response.refreshToken, 'new-refresh-token');
  });

  test('Public request 不帶 requiresAuth metadata', () async {
    final adapter = _RecordingAdapter();
    final dio = Dio(BaseOptions(baseUrl: 'https://example.test'))
      ..httpClientAdapter = adapter;

    await dio.get<dynamic>('/public');

    expect(adapter.path, '/public');
    expect(adapter.extra[RequestExtras.requiresAuth], isNot(true));
  });

  test('ProfileApi 會以 GET 呼叫 endpoint 並標記 requiresAuth metadata', () async {
    final adapter = _RecordingAdapter();
    final dio = Dio(BaseOptions(baseUrl: 'https://example.test'))
      ..httpClientAdapter = adapter;
    final api = ProfileApi(dio);

    final response = await api.getProfile();

    expect(adapter.method, 'GET');
    expect(adapter.path, '/profile');
    expect(adapter.extra[RequestExtras.requiresAuth], isTrue);
    expect(response.id, 'user-003');
    expect(response.name, 'Profile User');
  });

  test('CatalogApi 會傳遞 public search query 與 cursor parameters', () async {
    final adapter = _RecordingAdapter();
    final dio = Dio(BaseOptions(baseUrl: 'https://example.test'))
      ..httpClientAdapter = adapter;
    final api = CatalogApi(dio);

    final response = await api.searchCatalog(
      query: 'flutter',
      cursor: 'cursor-001',
      limit: 20,
    );

    expect(adapter.method, 'GET');
    expect(adapter.path, '/catalog');
    expect(adapter.queryParameters, <String, dynamic>{
      'query': 'flutter',
      'cursor': 'cursor-001',
      'limit': 20,
    });
    expect(adapter.extra[RequestExtras.requiresAuth], isNot(true));
    expect(response.items.single.id, 'catalog-101');
    expect(response.nextCursor, 'cursor-002');
  });

  test('CatalogApi 第一次 request 不傳 cursor parameter', () async {
    final adapter = _RecordingAdapter();
    final dio = Dio(BaseOptions(baseUrl: 'https://example.test'))
      ..httpClientAdapter = adapter;
    final api = CatalogApi(dio);

    await api.searchCatalog(
      query: '',
      cursor: null,
      limit: 20,
    );

    expect(adapter.queryParameters, <String, dynamic>{
      'query': '',
      'limit': 20,
    });
    expect(adapter.extra[RequestExtras.requiresAuth], isNot(true));
  });
}

class _RecordingAdapter implements HttpClientAdapter {
  String? method;
  String? path;
  Map<String, dynamic>? body;
  Map<String, dynamic> extra = <String, dynamic>{};
  Map<String, dynamic> queryParameters = <String, dynamic>{};

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    method = options.method;
    path = options.path;
    extra = Map<String, dynamic>.from(options.extra);
    queryParameters = Map<String, dynamic>.from(options.queryParameters);

    final bytes = <int>[];
    if (requestStream != null) {
      await for (final chunk in requestStream) {
        bytes.addAll(chunk);
      }
    }

    if (bytes.isNotEmpty) {
      final encodedBody = utf8.decode(bytes);
      if (encodedBody.trimLeft().startsWith('{')) {
        body = jsonDecode(encodedBody) as Map<String, dynamic>;
      }
    }

    final response = switch (options.path) {
      '/auth/login' => <String, dynamic>{
        'accessToken': 'real-access-token',
        'refreshToken': 'real-refresh-token',
        'userId': 'user-002',
        'userName': 'Retrofit User',
      },
      '/auth/refresh' => <String, dynamic>{
        'accessToken': 'new-access-token',
        'refreshToken': 'new-refresh-token',
      },
      '/profile' => <String, dynamic>{
        'id': 'user-003',
        'name': 'Profile User',
      },
      '/catalog' => <String, dynamic>{
        'items': <Map<String, dynamic>>[
          <String, dynamic>{
            'id': 'catalog-101',
            'name': 'Flutter Catalog Item',
            'description': 'Catalog response',
          },
        ],
        'nextCursor': 'cursor-002',
      },
      _ => <String, dynamic>{},
    };

    return ResponseBody.fromString(
      jsonEncode(response),
      200,
      headers: <String, List<String>>{
        Headers.contentTypeHeader: <String>[Headers.jsonContentType],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}
