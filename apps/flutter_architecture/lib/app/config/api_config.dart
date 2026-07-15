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

/// 已完成驗證的 API 設定。
class ApiConfig {
  const ApiConfig({
    required this.mode,
    required this.baseUri,
  });

  final ApiMode mode;
  final Uri baseUri;
}
