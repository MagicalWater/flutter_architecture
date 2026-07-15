/// API 執行模式。
enum ApiMode {
  mock,
  real;

  static ApiMode parse(String value) {
    return switch (value.trim().toLowerCase()) {
      'mock' => ApiMode.mock,
      'real' => ApiMode.real,
      _ => throw ArgumentError.value(
          value,
          'API_MODE',
          '只允許 mock 或 real',
        ),
    };
  }
}

/// App Composition Root 使用的最小 API 設定。
///
/// 目前透過 `--dart-define` 提供：
///
/// ```bash
/// --dart-define=API_MODE=real
/// --dart-define=API_BASE_URL=https://api.example.com
/// ```
class ApiConfig {
  const ApiConfig({
    required this.mode,
    required this.baseUrl,
  });

  factory ApiConfig.fromEnvironment() {
    const modeValue = String.fromEnvironment(
      'API_MODE',
      defaultValue: 'mock',
    );
    const baseUrlValue = String.fromEnvironment(
      'API_BASE_URL',
      defaultValue: '',
    );

    return ApiConfig.fromValues(
      modeValue: modeValue,
      baseUrlValue: baseUrlValue,
    );
  }

  factory ApiConfig.fromValues({
    required String modeValue,
    required String baseUrlValue,
  }) {
    final mode = ApiMode.parse(modeValue);
    final normalizedBaseUrl = baseUrlValue.trim();

    if (mode == ApiMode.real && normalizedBaseUrl.isEmpty) {
      throw ArgumentError.value(
        baseUrlValue,
        'API_BASE_URL',
        'API_MODE=real 時必須提供 API_BASE_URL',
      );
    }

    return ApiConfig(
      mode: mode,
      baseUrl: _validateBaseUrl(
        normalizedBaseUrl.isEmpty ? 'https://mock.local' : normalizedBaseUrl,
      ),
    );
  }

  final ApiMode mode;
  final String baseUrl;

  static String _validateBaseUrl(String value) {
    final uri = Uri.tryParse(value.trim());
    if (uri == null || !uri.hasScheme || uri.host.isEmpty) {
      throw ArgumentError.value(
        value,
        'API_BASE_URL',
        '必須是包含 scheme 與 host 的絕對 URL',
      );
    }

    return uri.toString();
  }
}
