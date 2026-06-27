# Roadmap

這份 Roadmap 只描述第一階段 MVP。

第一階段的目標是完成一份可以直接拿來開新專案的 Flutter 架構模板。

不在第一階段做的內容，統一放到 `docs/backlog.md`。

---

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
- Root `pubspec.yaml`，讓 Melos 可以透過 `dart run melos` 執行
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
- `melos bootstrap` 可以成功。
- `melos run analyze` 可以成功。
- `flutter test` 可以成功。
- `flutter build bundle` 可以成功。

---

## Milestone 2A：Auth Package 邊界重構

調整 Auth 的位置與責任邊界。

目前 Auth 的 domain / data 暫時放在 app 的 feature 內，這適合作為初始骨架，但不適合作為長期模板標準。

Auth 是跨整個 App 都會使用的能力，因此第一階段 MVP 需要把 Auth 的非 UI 部分整理到 `packages/auth`。

### 需要完成

移動到 `packages/auth`：

- Auth Entity
- Auth Result
- Auth Repository Interface
- LoginUseCase
- LogoutUseCase
- RestoreSessionUseCase
- AuthRepositoryImpl
- AuthRemoteDataSource
- AuthLocalDataSource
- Token / Session 相關能力
- AuthTokenProvider 實作或 adapter

保留在 `apps/flutter_architecture/lib/features/auth`：

- LoginPage
- AuthBloc
- AuthEvent
- AuthState
- Auth UI widgets

### 架構目標

調整後依賴方向應該變成：

```txt
app/features/auth/presentation
  ↓
packages/auth
```

而不是：

```txt
app/features/profile
  ↓
app/features/auth/presentation/AuthBloc
```

### 完成定義

- Auth 的 domain / data 不再放在 app feature 內。
- app 只保留 Auth 的 presentation layer。
- AuthBloc 依賴 `packages/auth` 的 UseCase。
- Profile 不直接依賴 AuthBloc。
- AuthGuard 不直接依賴 AuthBloc。
- `melos run analyze` 通過。
- `flutter test` 通過。

---

## Milestone 2B：SessionManager 與跨 Feature 登入狀態

建立跨 feature 使用的登入狀態入口。

### 背景

AuthGuard 與 ProfilePage 真正需要知道的不是 `AuthBloc`，而是：

```txt
目前是否已登入？
目前登入者是誰？
```

因此它們不應該依賴 Auth feature 的 presentation layer。

### 需要完成

- 建立 `SessionManager` 或 `AuthSessionReader`。
- `AuthGuard` 改為依賴 SessionManager。
- `ProfileBloc` 或 Profile use case 透過 SessionManager / Repository 判斷登入狀態。
- `ProfilePage` 不再直接讀取 AuthBloc。
- 登入成功後更新 SessionManager。
- 登出後清除 SessionManager。

### 完成定義

- AuthGuard 不 import AuthBloc。
- ProfilePage 不 import AuthBloc。
- 跨 feature 登入狀態統一透過 SessionManager 或 domain abstraction 取得。
- UI 只依賴自己 feature 的 Bloc。
- `melos run analyze` 通過。
- `flutter test` 通過。

---

## Milestone 2C：跨平台 SQLite 初始化

整理 SQLite 在 Mobile / Desktop / Web 的初始化方式。

### 背景

`sqflite` 在不同平台的初始化方式不同：

```txt
Mobile
  使用 sqflite 原生實作

Desktop
  使用 sqflite_common_ffi

Web
  使用 sqflite_common_ffi_web
```

Web 另外需要先執行：

```bash
dart run sqflite_common_ffi_web:setup
```

### 需要完成

- 使用條件匯入隔離 SQLite 平台差異。
- main.dart 不直接 import `dart:io`。
- Desktop 初始化 `databaseFactoryFfi`。
- Web 初始化 `databaseFactoryFfiWeb`。
- README 補充 Web setup 指令。

### 完成定義

- Flutter Web 不再因 sqflite databaseFactory 未初始化而白畫面。
- Desktop 不再因 sqflite databaseFactory 未初始化而錯誤。
- `melos run analyze` 通過。
- `flutter test` 通過。
- 若 app 有 web 平台資料夾，`flutter build web` 通過。

---

## Milestone 3：Auth + Profile Flow

完成主要業務流程。

需要完成：

- Login 完整流程
- Restore Session
- Logout
- GetProfile
- AuthBloc
- ProfileBloc
- LoginPage
- ProfilePage

完成定義：

- Login 頁面按鈕可以觸發完整 Clean Architecture 流程。
- 登入成功後自動切換到 Profile 頁面。
- Profile 頁面可以顯示當前登入用戶名稱。
- App 重開後可以自動登入。
- 未登入時 Profile 顯示尚未登入。

---

## Milestone 4：Route Guard 與頁面

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

---

## Milestone 5：整理與驗證

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
- `melos bootstrap` 通過。
- `melos run analyze` 通過。
- `flutter test` 通過。
- `flutter build bundle` 通過。

---

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
