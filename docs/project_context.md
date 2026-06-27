# Project Context

本文件是本專案目前狀態的完整上下文。

它的目的不是取代 README，而是讓人或 ChatGPT 在新的對話中快速恢復專案脈絡。

---

## 專案定位

本專案是 Flutter Enterprise Architecture Template。

它不是 Demo，也不是 Boilerplate。

它是一份可以持續演進、可直接作為企業專案起點的 Flutter 架構模板。

核心目標：

- 示範 Clean Architecture 在 Flutter 中的實際落地。
- 示範 Feature First + Monorepo 如何組織中大型專案。
- 示範 Bloc / Hooks / Auto Route / DI / Dio / SQLite 的整合方式。
- 讓專案本身成為可閱讀、可學習、可延續的架構教材。

---

## 語言規範

文件與註解預設使用繁體中文。

技術名詞保留英文，例如：

- Clean Architecture
- Feature First
- Bloc
- Hook
- Repository
- UseCase
- Entity
- Model
- DataSource
- Presentation Layer
- Domain Layer
- Data Layer
- Route Guard
- Dependency Injection

---

## 技術棧

### Architecture

- Clean Architecture
- Feature First
- Monorepo
- Melos

### Presentation

- flutter_bloc
- flutter_hooks
- hooked_bloc

### Navigation

- auto_route
- Route Guard
- Nested Route
- Bottom Navigation

### Dependency Injection

- get_it
- injectable

### Model / Code Generation

- freezed
- json_serializable
- build_runner

### Network

- Dio
- Mock API
- Authorization Header Interceptor

### Storage

- SharedPreferences
- SQLite
- sqflite
- sqflite_common_ffi
- sqflite_common_ffi_web

### Reactive

- RxDart

---

## 已完成狀態

### Milestone 1：Project Skeleton

狀態：Completed。

已完成：

- Monorepo 結構。
- apps / packages 分層。
- core / api_client / auth package。
- flutter_architecture app。
- Clean Architecture + Feature First 基礎骨架。
- auto_route / get_it / injectable / freezed / json_serializable。
- flutter_bloc / flutter_hooks / hooked_bloc。
- Dio mock API。
- SharedPreferences / SQLite。
- Smoke tests。
- Melos scripts。
- 第一個 Git commit。

Commit：

```txt
8ed9095 feat(mvp): initialize enterprise architecture template
```

---

## 已完成狀態

### Milestone 2C：跨平台 SQLite 初始化

狀態：Completed。

已完成：

- Desktop 使用 sqflite_common_ffi 初始化 databaseFactory。
- Web 使用 sqflite_common_ffi_web 初始化 databaseFactory。
- main.dart 移除直接 dart:io import。
- 使用條件匯入隔離平台差異。
- analyze / test / build bundle 已通過。

收尾紀錄：

- README 已補充 Web setup 指令。
- 已確認 app 目前只有 sqflite web binary，尚未建立完整 Flutter Web 平台 scaffold；`flutter build web` 需待執行 `flutter create . --platforms web` 後再驗證。
- 已完成 Commit。

Commit：

```txt
f1e869b docs(progress): complete sqlite platform milestone
```

### Milestone 2A：Auth Package 邊界重構

狀態：Completed。

已完成：

- Auth Entity / Result / Repository / UseCase / DataSource / RepositoryImpl 已移動到 packages/auth。
- AuthBloc 已改為依賴 packages/auth 的 UseCase。
- apps/flutter_architecture/lib/features/auth 只保留 presentation layer。
- package export 邊界已整理。
- analyze / test / build bundle 已通過。

Web SQLite setup 指令：

```bash
cd apps/flutter_architecture
dart run sqflite_common_ffi_web:setup
```

---

### Milestone 2B：SessionManager 與跨 Feature 登入狀態

狀態：Completed。

已完成：

- SessionManager 已成為跨 feature 登入狀態入口。
- AuthRepositoryImpl 在 login / restore / logout 時同步更新 SessionManager。
- AuthGuard 已改為依賴 SessionManager，不再依賴 AuthBloc。
- ProfilePage 不再直接讀 AuthBloc。
- ProfileBloc 透過 SessionManager 判斷登入狀態，並透過 LogoutUseCase 登出。
- ProtectedPage 不再直接讀 AuthBloc。
- build_runner / analyze / test 已通過。

---

## 目前進行中

### Milestone 3：Auth + Profile Flow

狀態：In Progress。

已完成：

- Milestone 3-1 Login Flow：LoginPage → AuthBloc → LoginUseCase → AuthRepository → Remote / Local → SessionManager 已串好。
- Milestone 3-2 Profile Flow：ProfileBloc 透過 SessionManager 判斷登入狀態，已登入時呼叫 GetProfileUseCase，ProfilePage 顯示目前登入用戶名稱，並補上 ProfileBloc 測試。
- Milestone 3-3 Navigation Flow：Login 成功後切換到 Profile tab，Logout 成功後回到 Login tab，AuthBloc 會監聽 SessionManager 避免跨 feature 登出後 UI state 與 Session state 不同步。
- Milestone 3-4 Protected Route Flow：ProtectedRoute 已掛上 AuthGuard，AuthGuard 依賴 SessionManager 判斷可否進入，ProtectedPage 不依賴 AuthBloc，並補上 AuthGuard 測試。

目前進行中：

- Milestone 3-5 End-to-End 驗收。

後續需要處理：

- End-to-End 驗收。

---

## 已拍板的重要設計

### 1. Auth domain / data 應該放在 packages/auth

Auth 是跨整個 App 的共用能力，不應長期放在 app feature 內。

App 的 auth feature 只保留 presentation layer。

### 2. AuthGuard 不應依賴 AuthBloc

AuthGuard 真正需要的是「目前是否已登入」，不是整個 AuthBloc。

後續應改為：

```txt
AuthGuard
  ↓
SessionManager / AuthSessionReader
```

### 3. ProfilePage 不應直接讀 AuthBloc

跨 feature 不應直接依賴對方的 Bloc。

後續應改為：

```txt
ProfilePage
  ↓
ProfileBloc
  ↓
GetProfileUseCase / SessionManager
```

### 4. 一個 UseCase 對應一個業務行為

維持：

```txt
LoginUseCase
LogoutUseCase
RestoreSessionUseCase
```

不要合成過大的：

```txt
AuthUseCase
```

### 5. hooked_bloc 的定位

hooked_bloc 用來降低 BlocBuilder / BlocListener 的巢狀。

目前透過 HookedBlocConfigProvider 將 injector 接到 get_it。

```dart
HookedBlocConfigProvider(
  injector: () => getIt.get,
  child: const ArchitectureApp(),
)
```

這讓 UI 可以使用：

```dart
final authBloc = useBloc<AuthBloc>();
final authState = useBlocBuilder(authBloc);
```

但跨 feature 不應因此直接讀別人的 Bloc。

---

## 驗證命令

每個 Milestone 收尾至少執行：

```bash
dart run melos bootstrap
dart run melos run build_runner
dart run melos run analyze
dart run melos exec -- flutter test
cd apps/flutter_architecture
flutter build bundle
```

若有 Web 平台：

```bash
cd apps/flutter_architecture
flutter build web
```

---

## 新對話恢復流程

新的 ChatGPT 對話請先閱讀：

```txt
README.md
docs/project_context.md
docs/architecture_decisions.md
docs/progress.md
docs/roadmap.md
docs/conversation_rules.md
```

閱讀後依照 `docs/progress.md` 的目前 Milestone 繼續。
