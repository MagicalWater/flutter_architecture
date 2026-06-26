# Roadmap

這份 Roadmap 只描述第一階段 MVP。

第一階段的目標是完成一份可以直接拿來開新專案的 Flutter 架構模板。

不在第一階段做的內容，統一放到 `docs/backlog.md`。

## Milestone 1：Monorepo 與專案骨架

建立最外層結構：

```txt
root/
  apps/
    flutter_architecture/
  packages/
    core/
    api_client/
    auth/
```

需要完成：

- `melos.yaml`
- Root `analysis_options.yaml`
- Root `README.md`
- `docs/` 基礎文件
- `apps/flutter_architecture` Flutter App
- `packages/core` Dart Package
- `packages/api_client` Dart Package
- `packages/auth` Dart Package

完成定義：

- 專案結構建立完成。
- 每個 package 都有 `pubspec.yaml`。
- 文件已經說明第一階段範圍。

## Milestone 2：核心依賴與基礎設定

加入第一階段需要的套件。

App 主要依賴：

- `flutter_bloc`
- `flutter_hooks`
- `hooked_bloc`
- `auto_route`
- `get_it`
- `injectable`
- `freezed_annotation`
- `json_annotation`
- `shared_preferences`
- `sqflite`
- `rxdart`

Package 主要依賴：

- `dio`
- `freezed_annotation`
- `json_annotation`

Dev dependencies：

- `build_runner`
- `freezed`
- `json_serializable`
- `injectable_generator`
- `auto_route_generator`

完成定義：

- `flutter pub get` 可以成功。
- build_runner 相關依賴放置正確。
- 專案可以準備產生 Freezed、Auto Route、Injectable 程式碼。

## Milestone 3：Clean Architecture 基礎骨架

建立 feature-first 資料夾。

```txt
apps/flutter_architecture/lib/
  app/
    di/
    router/
    theme/
  features/
    auth/
      presentation/
      domain/
      data/
    profile/
      presentation/
      domain/
      data/
    protected/
      presentation/
    shell/
      presentation/
```

完成定義：

- 各 feature 有固定的 layer 結構。
- 每個重要資料夾有簡短 README。
- 目前只建立必要骨架，不加入過度抽象。

## Milestone 4：API 與 Storage

完成 Mock API 與本地保存。

需要完成：

- Dio client
- Mock login API
- Mock profile API
- Auth interceptor
- SharedPreferences token storage
- SQLite profile storage

完成定義：

- Login API 可以回傳 mock token。
- Profile API 需要 token。
- 登入後 token 可以自動加到需要登入的 API header。
- token 與 profile 可以持久化。

## Milestone 5：Auth + Profile Flow

完成主要業務流程。

需要完成：

- `LoginUseCase`
- `RestoreSessionUseCase`
- `GetProfileUseCase`
- `AuthRepository`
- `AuthRepositoryImpl`
- `AuthRemoteDataSource`
- `AuthLocalDataSource`
- `AuthBloc`
- `ProfileBloc`

完成定義：

- Login 頁面按鈕可以觸發完整流程。
- 登入成功後自動切換到 Profile 頁面。
- Profile 頁面可以顯示當前登入用戶名稱。
- App 重開後可以自動登入。

## Milestone 6：Route Guard 與頁面

完成四個頁面與路由。

```txt
ShellPage(A)
  ├── LoginPage(B)
  ├── ProfilePage(C)
  └── ProtectedPage(D)
```

完成定義：

- ShellPage 有 AppBar。
- ShellPage 有 BottomNavigationBar。
- Login / Profile 是 ShellPage 內層頁面。
- AppBar action 可以跳轉 ProtectedPage。
- ProtectedPage 有 Route Guard。
- 未登入時進入 ProtectedPage 會導回 LoginPage。

## Milestone 7：整理與驗證

收尾第一階段。

需要完成：

- 補齊必要中文註解。
- 補齊必要 README。
- 確認架構流程可讀。
- 執行基本分析與 build_runner。

完成定義：

- 程式碼結構清楚。
- 文件符合繁中規範。
- MVP 功能可以跑通。

## 第一階段不做

以下內容暫不實作：

- 完整 ADR 系列。
- 大量測試範例。
- CI/CD。
- Design System。
- Refresh Token 完整流程。
- WebSocket。
- Pagination。
- 多個業務 feature。

這些都放到 `docs/backlog.md`。
