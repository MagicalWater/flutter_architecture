enum CatalogCacheOperation {
  readPage,
  writeFirstPage,
  writePage,
  writeAppendPage,
  readChainRevision,
  deletePage,
  corruptionCleanup,
  expiredCleanup,
}

/// Catalog Cache degraded operation 的安全診斷摘要。
///
/// 不保存 query、cursor、item、SQL 或 raw row；只保留 operation 與低敏感度
/// identity shape，供 Milestone 17-6 的 non-fatal reporting adapter 使用。
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
