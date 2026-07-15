import 'package:api_client/api_client.dart';
import 'package:dio/dio.dart';
import 'package:flutter_architecture/app/config/api_config.dart';
import 'package:flutter_architecture/app/di/api_implementation_selector.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final dio = Dio(BaseOptions(baseUrl: 'https://api.example.com'));

  test('Mock mode 會選擇 Mock API implementations', () {
    const config = ApiConfig(
      mode: ApiMode.mock,
      baseUrl: 'https://mock.local',
    );

    expect(
      ApiImplementationSelector.createAuthApi(config, dio),
      isA<MockAuthApi>(),
    );
    expect(
      ApiImplementationSelector.createProfileApi(config, dio),
      isA<MockProfileApi>(),
    );
  });

  test('Real mode 會選擇 Retrofit API implementations', () {
    const config = ApiConfig(
      mode: ApiMode.real,
      baseUrl: 'https://api.example.com',
    );

    expect(
      ApiImplementationSelector.createAuthApi(config, dio),
      isNot(isA<MockAuthApi>()),
    );
    expect(
      ApiImplementationSelector.createProfileApi(config, dio),
      isNot(isA<MockProfileApi>()),
    );
  });
}
