/// Catalog cache 發生問題時，當時正在做哪一個資料庫動作。
enum CatalogCacheOperation {
  /// 從 cache 讀取一頁資料。
  readPage,

  /// 寫入查詢結果的第一頁，建立新的 cache chain。
  writeFirstPage,

  /// 寫入一般頁面資料。
  writePage,

  /// 把下一頁資料接到既有 cache chain 後方。
  writeAppendPage,

  /// 讀取目前 cache chain 的 revision，用來判斷資料是否仍是同一批。
  readChainRevision,

  /// 刪除指定 cache page。
  deletePage,

  /// 發現 cache 損壞後進行清理。
  corruptionCleanup,

  /// 清除已過期 cache。
  expiredCleanup,
}

/// Catalog cache 失敗時可以安全拿去記錄的診斷摘要。
///
/// 刻意不保存 query、cursor、item、SQL 或 raw row，避免把使用者資料或大量內容送進
/// error reporter；只留下「做哪個動作、是否有 cursor、limit 多大」這類低敏感度資訊。
class CatalogCacheFailureDetails {
  const CatalogCacheFailureDetails({
    required this.operation,
    required this.isQueryEmpty,
    required this.hasCursor,
    required this.limit,
    required this.originalError,
  });

  final CatalogCacheOperation operation;
  final bool isQueryEmpty;
  final bool hasCursor;
  final int limit;

  /// 保留原始 SQLite error identity；[toString] 不會展開其內容。
  final Object originalError;

  @override
  String toString() {
    return 'CatalogCacheFailureDetails('
        'operation: $operation, '
        'isQueryEmpty: $isQueryEmpty, '
        'hasCursor: $hasCursor, '
        'limit: $limit)';
  }
}
