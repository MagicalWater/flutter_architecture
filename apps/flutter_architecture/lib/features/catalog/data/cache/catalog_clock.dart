/// Catalog cache 判斷過期時間時使用的時鐘。
///
/// 抽成介面讓測試可以固定時間，不需要真的等待系統時間經過。
abstract interface class CatalogClock {
  DateTime nowUtc();
}

/// Production 使用的 UTC 系統時間。
class SystemCatalogClock implements CatalogClock {
  const SystemCatalogClock();

  @override
  DateTime nowUtc() => DateTime.now().toUtc();
}
