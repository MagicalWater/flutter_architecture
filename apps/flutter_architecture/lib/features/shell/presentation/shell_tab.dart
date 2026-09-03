/// Shell bottom navigation 的固定 tab 順序。
///
/// Route、NavigationDestination 與跨頁面 tab 導向都應使用此 enum 的 index，
/// 避免新增 tab 後留下失效的 magic number。
enum ShellTab {
  /// 登入頁入口。
  login,

  /// Catalog 列表入口。
  catalog,

  /// 會員資料入口。
  profile,
}
