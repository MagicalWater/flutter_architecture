import 'package:api_client/api_client.dart';
import 'package:dio/dio.dart';
import 'package:flutter_architecture/app/config/api_config.dart';
import 'package:flutter_architecture/app/di/api_implementation_selector.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final dio = Dio(BaseOptions(baseUrl: 'https://api.example.com'));

  test('Mock mode 會選擇 Mock API implementations', () {
    final config = ApiConfig(
      mode: ApiMode.mock,
      baseUri: Uri.parse('https://mock.local'),
    );

    expect(
      ApiImplementationSelector.createAuthApi(config, dio),
      isA<MockAuthApi>(),
    );
    expect(
      ApiImplementationSelector.createAuthRefreshApi(config, dio),
      isA<MockAuthRefreshApi>(),
    );
    expect(
      ApiImplementationSelector.createProfileApi(config, dio),
      isA<MockProfileApi>(),
    );
    expect(
      ApiImplementationSelector.createCatalogApi(config, dio),
      isA<MockCatalogApi>(),
    );
  });

  test('Real mode 會選擇 Retrofit API implementations', () {
    final config = ApiConfig(
      mode: ApiMode.real,
      baseUri: Uri.parse('https://api.example.com'),
    );

    expect(
      ApiImplementationSelector.createAuthApi(config, dio),
      isA<DioAuthEndpoint>(),
    );
    expect(
      ApiImplementationSelector.createAuthRefreshApi(config, dio),
      isA<DioAuthRefreshEndpoint>(),
    );
    expect(
      ApiImplementationSelector.createProfileApi(config, dio),
      isNot(isA<MockProfileApi>()),
    );
    expect(
      ApiImplementationSelector.createCatalogApi(config, dio),
      isNot(isA<MockCatalogApi>()),
    );
  });
}
