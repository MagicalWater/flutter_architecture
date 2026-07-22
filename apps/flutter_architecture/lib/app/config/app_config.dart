import 'package:flutter_architecture/app/config/api_config.dart';
import 'package:flutter_architecture/app/config/app_environment.dart';

/// App Composition Root 使用的 typed configuration。
class AppConfig {
  const AppConfig({
    required this.environment,
    required this.api,
  });

  final AppEnvironment environment;
  final ApiConfig api;
}

/// 集中建立與驗證 AppConfig。
abstract final class AppConfigFactory {
  static AppConfig fromEnvironment({
    required AppEnvironment environment,
    bool allowMissingNativeEnvironment = false,
  }) {
    const nativeEnvironmentValue = String.fromEnvironment(
      'NATIVE_ENVIRONMENT',
      defaultValue: '',
    );
    const apiModeValue = String.fromEnvironment(
      'API_MODE',
      defaultValue: 'mock',
    );
    const apiBaseUrlValue = String.fromEnvironment(
      'API_BASE_URL',
      defaultValue: '',
    );

    return fromValues(
      environment: environment,
      nativeEnvironmentValue: nativeEnvironmentValue,
      allowMissingNativeEnvironment: allowMissingNativeEnvironment,
      apiModeValue: apiModeValue,
      apiBaseUrlValue: apiBaseUrlValue,
    );
  }

  static AppConfig fromValues({
    required AppEnvironment environment,
    required String nativeEnvironmentValue,
    bool allowMissingNativeEnvironment = false,
    required String apiModeValue,
    required String apiBaseUrlValue,
  }) {
    _validateNativeEnvironment(
      environment: environment,
      nativeEnvironmentValue: nativeEnvironmentValue,
      allowMissingNativeEnvironment: allowMissingNativeEnvironment,
    );

    final mode = ApiMode.parse(apiModeValue);

    if (environment != AppEnvironment.development && mode == ApiMode.mock) {
      throw ArgumentError.value(
        apiModeValue,
        'API_MODE',
        '${environment.name} 不允許使用 mock API',
      );
    }

    final normalizedBaseUrl = apiBaseUrlValue.trim();
    if (mode == ApiMode.real && normalizedBaseUrl.isEmpty) {
      throw ArgumentError.value(
        apiBaseUrlValue,
        'API_BASE_URL',
        'API_MODE=real 時必須提供 API_BASE_URL',
      );
    }

    final baseUri = mode == ApiMode.mock
        ? Uri.parse('https://mock.local')
        : _parseRealBaseUri(normalizedBaseUrl, environment);

    return AppConfig(
      environment: environment,
      api: ApiConfig(mode: mode, baseUri: baseUri),
    );
  }

  static Uri _parseRealBaseUri(
    String value,
    AppEnvironment environment,
  ) {
    final uri = Uri.tryParse(value);
    if (uri == null || !uri.hasScheme || uri.host.isEmpty) {
      throw ArgumentError.value(
        value,
        'API_BASE_URL',
        '必須是包含 scheme 與 host 的絕對 URL',
      );
    }

    if (uri.scheme != 'http' && uri.scheme != 'https') {
      throw ArgumentError.value(
        value,
        'API_BASE_URL',
        '只允許 http 或 https scheme',
      );
    }

    if (environment != AppEnvironment.development && uri.scheme != 'https') {
      throw ArgumentError.value(
        value,
        'API_BASE_URL',
        '${environment.name} 必須使用 https',
      );
    }

    if (environment == AppEnvironment.production) {
      if (_isBlockedProductionHost(uri.host)) {
        throw ArgumentError.value(
          value,
          'API_BASE_URL',
          'production 不允許 mock、localhost、loopback、.invalid 或 template placeholder URL',
        );
      }
    }

    return uri;
  }

  static bool _isBlockedProductionHost(String value) {
    final host = value.toLowerCase();
    final isIpv4Loopback = host == '127.0.0.1' || host.startsWith('127.');
    final isIpv6Loopback = host == '::1';

    return host == 'mock.local' ||
        host.endsWith('.mock.local') ||
        host == 'localhost' ||
        host.endsWith('.localhost') ||
        host.endsWith('.invalid') ||
        host == 'example.com' ||
        host.endsWith('.example.com') ||
        host == 'example.org' ||
        host.endsWith('.example.org') ||
        host == 'example.net' ||
        host.endsWith('.example.net') ||
        isIpv4Loopback ||
        isIpv6Loopback;
  }

  static void _validateNativeEnvironment({
    required AppEnvironment environment,
    required String nativeEnvironmentValue,
    required bool allowMissingNativeEnvironment,
  }) {
    final normalized = nativeEnvironmentValue.trim();
    if (normalized.isEmpty) {
      if (allowMissingNativeEnvironment &&
          environment == AppEnvironment.development) {
        return;
      }
      throw ArgumentError.value(
        nativeEnvironmentValue,
        'NATIVE_ENVIRONMENT',
        '原生環境 sentinel 不可為空',
      );
    }

    if (normalized != environment.name) {
      throw ArgumentError.value(
        nativeEnvironmentValue,
        'NATIVE_ENVIRONMENT',
        '原生環境 $normalized 與 Dart entrypoint ${environment.name} 不一致',
      );
    }
  }
}
