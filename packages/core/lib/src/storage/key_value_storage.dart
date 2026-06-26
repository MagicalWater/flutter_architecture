/// Key-value storage 抽象。
///
/// ## 為什麼需要抽象？
///
/// Domain / Data 層不應該到處直接依賴 SharedPreferences。
///
/// 透過這個抽象，未來可以替換成 secure storage、memory storage，
/// 或測試用 fake storage。
abstract interface class KeyValueStorage {
  Future<void> setString(String key, String value);

  Future<String?> getString(String key);

  Future<void> remove(String key);
}
