/// 告訴 Catalog Repository 這次要怎麼載入資料。
enum CatalogLoadPolicy {
  /// 第一次進入畫面；可以先顯示 cache，再取得遠端資料。
  initial,

  /// 使用者主動重新整理；重新取得第一頁資料。
  refresh,

  /// 載入下一頁並接在目前列表後方。
  append,
}
