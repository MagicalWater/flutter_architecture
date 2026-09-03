/// 管理「較新的操作會讓較早操作失效」的簡單 generation。
///
/// 每個 owner／使用端各自持有自己的 instance；它只提供遞增與比對，不承擔任何業務語意。
final class OperationGeneration {
  int _value = 0;

  /// 取得目前 generation，不建立新操作。
  int get current => _value;

  /// 開始一個新操作，並回傳這次操作的 generation。
  int begin() => ++_value;

  /// 不開始新操作，只讓目前尚未完成的舊操作全部失效。
  void invalidate() => ++_value;

  /// 判斷 [value] 是否仍代表目前最新的操作。
  bool isCurrent(int value) => value == _value;
}
