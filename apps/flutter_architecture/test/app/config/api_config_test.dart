import 'package:flutter_architecture/app/config/api_config.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('ApiMode.parse 可以解析 mock 與 real', () {
    expect(ApiMode.parse('mock'), ApiMode.mock);
    expect(ApiMode.parse('REAL'), ApiMode.real);
  });

  test('ApiMode.parse 遇到未知值會拋出 ArgumentError', () {
    expect(() => ApiMode.parse('staging'), throwsArgumentError);
  });

  test('ApiConfig 接受明確的 mode 與 baseUrl', () {
    const config = ApiConfig(
      mode: ApiMode.real,
      baseUrl: 'https://api.example.com',
    );

    expect(config.mode, ApiMode.real);
    expect(config.baseUrl, 'https://api.example.com');
  });

  test('Mock mode 未提供 baseUrl 時使用 mock 預設值', () {
    final config = ApiConfig.fromValues(
      modeValue: 'mock',
      baseUrlValue: '',
    );

    expect(config.mode, ApiMode.mock);
    expect(config.baseUrl, 'https://mock.local');
  });

  test('Real mode 未提供 baseUrl 時會拋出 ArgumentError', () {
    expect(
      () => ApiConfig.fromValues(
        modeValue: 'real',
        baseUrlValue: '',
      ),
      throwsArgumentError,
    );
  });

  test('不合法的 baseUrl 會拋出 ArgumentError', () {
    expect(
      () => ApiConfig.fromValues(
        modeValue: 'real',
        baseUrlValue: 'api.example.com',
      ),
      throwsArgumentError,
    );
  });
}
