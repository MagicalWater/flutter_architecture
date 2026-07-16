/// Shell bottom navigation 的固定 tab 順序。
///
/// Route、NavigationDestination 與跨頁面 tab 導向都應使用此 enum 的 index，
/// 避免新增 tab 後留下失效的 magic number。
enum ShellTab { login, catalog, profile }
