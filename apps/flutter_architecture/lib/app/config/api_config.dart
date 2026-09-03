/// App 目前要連 Mock API 還是真實後端。
enum ApiMode {
  /// 使用 repository 內建的 Mock 實作，不發真實網路 request。
  mock,

  /// 連到 [ApiConfig.baseUri] 指定的真實後端。
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

/// Bootstrap 驗證完成後，交給 DI 使用的 API 設定。
class ApiConfig {
  const ApiConfig({
    required this.mode,
    required this.baseUri,
  });

  final ApiMode mode;
  final Uri baseUri;
}
