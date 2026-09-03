/// 目前啟動的是哪一套 App 環境設定。
enum AppEnvironment {
  /// 開發環境，可使用 Mock API 或開發用後端。
  development,

  /// 上線前的整合／驗收環境。
  staging,

  /// 正式產品環境。
  production,
}
