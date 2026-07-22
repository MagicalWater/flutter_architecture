import 'package:flutter_architecture/app/config/api_config.dart';
import 'package:flutter_architecture/app/config/app_config.dart';
import 'package:flutter_architecture/app/config/app_environment.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('ApiMode.parse 可以解析 mock 與 real', () {
    expect(ApiMode.parse('mock'), ApiMode.mock);
    expect(ApiMode.parse('REAL'), ApiMode.real);
  });

  test('ApiMode.parse 遇到未知值會拋出 ArgumentError', () {
    expect(() => ApiMode.parse('staging'), throwsArgumentError);
  });

  test('ApiConfig 接受明確的 mode 與 baseUri', () {
    final config = ApiConfig(
      mode: ApiMode.real,
      baseUri: Uri.parse('https://api.example.com'),
    );

    expect(config.mode, ApiMode.real);
    expect(config.baseUri, Uri.parse('https://api.example.com'));
  });

  test('development + mock 使用 mock 預設 URL', () {
    final config = AppConfigFactory.fromValues(
      environment: AppEnvironment.development,
      nativeEnvironmentValue: 'development',
      apiModeValue: 'mock',
      apiBaseUrlValue: '',
    );

    expect(config.api.mode, ApiMode.mock);
    expect(config.api.baseUri, Uri.parse('https://mock.local'));
  });

  test('native sentinel 與 entrypoint environment 相符時建立設定', () {
    final config = AppConfigFactory.fromValues(
      environment: AppEnvironment.staging,
      nativeEnvironmentValue: 'staging',
      apiModeValue: 'real',
      apiBaseUrlValue: 'https://staging-api.acme.com',
    );

    expect(config.environment, AppEnvironment.staging);
  });

  test('native sentinel 與 entrypoint environment 不符時 fail fast', () {
    expect(
      () => AppConfigFactory.fromValues(
        environment: AppEnvironment.production,
        nativeEnvironmentValue: 'staging',
        apiModeValue: 'real',
        apiBaseUrlValue: 'https://api.acme.com',
      ),
      throwsArgumentError,
    );
  });

  test('只有 development compatibility entrypoint 可缺少 native sentinel', () {
    expect(
      () => AppConfigFactory.fromValues(
        environment: AppEnvironment.development,
        nativeEnvironmentValue: '',
        allowMissingNativeEnvironment: true,
        apiModeValue: 'mock',
        apiBaseUrlValue: '',
      ),
      returnsNormally,
    );

    expect(
      () => AppConfigFactory.fromValues(
        environment: AppEnvironment.development,
        nativeEnvironmentValue: '',
        apiModeValue: 'mock',
        apiBaseUrlValue: '',
      ),
      throwsArgumentError,
    );
  });

  test('Real mode 未提供 baseUrl 時會拋出 ArgumentError', () {
    expect(
      () => AppConfigFactory.fromValues(
        environment: AppEnvironment.development,
        nativeEnvironmentValue: 'development',
        apiModeValue: 'real',
        apiBaseUrlValue: '',
      ),
      throwsArgumentError,
    );
  });

  test('不合法的 baseUrl 會拋出 ArgumentError', () {
    expect(
      () => AppConfigFactory.fromValues(
        environment: AppEnvironment.development,
        nativeEnvironmentValue: 'development',
        apiModeValue: 'real',
        apiBaseUrlValue: 'api.example.com',
      ),
      throwsArgumentError,
    );
  });

  test('staging 與 production 不允許 mock', () {
    for (final environment in [
      AppEnvironment.staging,
      AppEnvironment.production,
    ]) {
      expect(
        () => AppConfigFactory.fromValues(
          environment: environment,
          nativeEnvironmentValue: environment.name,
          apiModeValue: 'mock',
          apiBaseUrlValue: '',
        ),
        throwsArgumentError,
      );
    }
  });

  test('Real mode 只允許 http 或 https', () {
    expect(
      () => AppConfigFactory.fromValues(
        environment: AppEnvironment.development,
        nativeEnvironmentValue: 'development',
        apiModeValue: 'real',
        apiBaseUrlValue: 'ftp://api.example.com',
      ),
      throwsArgumentError,
    );
  });

  test('production 必須使用 https', () {
    expect(
      () => AppConfigFactory.fromValues(
        environment: AppEnvironment.production,
        nativeEnvironmentValue: 'production',
        apiModeValue: 'real',
        apiBaseUrlValue: 'http://api.example.com',
      ),
      throwsArgumentError,
    );
  });

  test('staging 必須使用 https', () {
    expect(
      () => AppConfigFactory.fromValues(
        environment: AppEnvironment.staging,
        nativeEnvironmentValue: 'staging',
        apiModeValue: 'real',
        apiBaseUrlValue: 'http://staging-api.acme.com',
      ),
      throwsArgumentError,
    );
  });

  test('production 不允許 mock placeholder URL', () {
    for (final url in [
      'https://mock.local',
      'https://api.mock.local',
      'https://localhost',
      'https://api.localhost',
      'https://127.0.0.1',
      'https://127.10.20.30',
      'https://[::1]',
      'https://api.invalid',
    ]) {
      expect(
        () => AppConfigFactory.fromValues(
          environment: AppEnvironment.production,
          nativeEnvironmentValue: 'production',
          apiModeValue: 'real',
          apiBaseUrlValue: url,
        ),
        throwsArgumentError,
      );
    }
  });

  test('production 不允許 template placeholder host', () {
    for (final url in [
      'https://example.com',
      'https://api.example.com',
      'https://example.org',
      'https://api.example.net',
    ]) {
      expect(
        () => AppConfigFactory.fromValues(
          environment: AppEnvironment.production,
          nativeEnvironmentValue: 'production',
          apiModeValue: 'real',
          apiBaseUrlValue: url,
        ),
        throwsArgumentError,
      );
    }
  });

  test('staging 與 production 接受合法 real API', () {
    for (final environment in [
      AppEnvironment.staging,
      AppEnvironment.production,
    ]) {
      final config = AppConfigFactory.fromValues(
        environment: environment,
        nativeEnvironmentValue: environment.name,
        apiModeValue: 'real',
        apiBaseUrlValue: 'https://api.acme.com',
      );

      expect(config.environment, environment);
      expect(config.api.mode, ApiMode.real);
      expect(config.api.baseUri, Uri.parse('https://api.acme.com'));
    }
  });
}
