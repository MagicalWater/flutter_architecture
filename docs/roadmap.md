# Roadmap

這份 Roadmap 記錄模板目前與後續 Milestone。

第一階段 MVP 已完成；後續 Milestone 用於模板基線升級、架構整理與能力擴充。

尚未排入正式 Milestone 的想法，統一放到 `docs/backlog.md`。

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
- `dart pub get` 可以成功。
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

### Milestone 3-1：Login Flow

完成登入本身，不先處理所有頁面跳轉細節。

完成定義：

- LoginPage 按鈕可以觸發 AuthBloc。
- AuthBloc 呼叫 LoginUseCase。
- LoginUseCase 經由 AuthRepository 完成 Remote + Local 流程。
- 登入成功後更新 SessionManager。
- AuthBloc state 可以正確呈現 loading / success / failure。

### Milestone 3-2：Profile Flow

完成 Profile 顯示與未登入狀態。

完成定義：

- 未登入時 Profile 顯示尚未登入。
- 已登入時 ProfileBloc 呼叫 GetProfileUseCase。
- Profile 頁面顯示目前登入用戶名稱。
- Profile loading / error 狀態正常。

### Milestone 3-3：Navigation Flow

完成登入 / 登出後的 tab 行為。

完成定義：

- Login 成功後切換到 Profile tab。
- Logout 成功後回到 Login tab。
- tab 切換不破壞 Auth / Session 狀態。

### Milestone 3-4：Protected Route Flow

完成受保護頁面的路由行為。

完成定義：

- 未登入進 ProtectedRoute 會被 AuthGuard 導回 Login。
- 已登入進 ProtectedRoute 會成功進入 ProtectedPage。
- ProtectedPage 不依賴 AuthBloc。

### Milestone 3-5：End-to-End 驗收

完成整體流程驗證。

完成定義：

- App 啟動 Restore Session。
- 未登入 → Login → Profile → Protected → Logout 流程可跑通。
- Logout 後 Profile 顯示尚未登入。
- Logout 後 ProtectedRoute 會被擋下。
- `melos run analyze` 通過。
- `flutter test` 通過。
- `flutter build bundle` 通過。

---

## Milestone 4：Route Guard 與頁面

完成四個頁面與路由。

```txt
ShellPage(A)
  ├── LoginPage(B)
  ├── ProfilePage(C)
  └── ProtectedPage(D)
```

### Milestone 4-1：ProtectedPage 展示責任整理

完成 ProtectedPage 的頁面責任整理。

完成定義：

- ProtectedPage 不直接讀取 SessionManager。
- ProtectedPage 不依賴 DI container。
- 登入檢查責任只保留在 AuthGuard。
- 補上 ProtectedPage widget test。

### Milestone 4-2：Shell / Route 結構驗收

完成 Shell 與 Route 結構的整體驗收。

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

Milestone 5 不新增業務功能，而是把目前 MVP 整理到可交付、可閱讀、可作為模板基線的狀態。

### Milestone 5-1：文件整理

完成文件與目前實際架構的同步。

完成定義：

- README 與目前實際架構一致。
- `project_context.md`、`docs/archive/progress_v1.0.0.md`、`roadmap.md` 狀態一致。
- 若有新的架構決策，已補充到 `architecture_decisions.md`。
- 完成 git diff 檢查。
- 完成 Git Commit。

### Milestone 5-2：程式碼整理

完成程式碼可讀性與一致性整理。

完成定義：

- 補齊必要中文註解。
- 清理 import。
- 檢查命名一致性。
- 移除暫時性或冗餘程式碼（若有）。
- `melos run analyze` 通過。
- `flutter test` 通過。
- 完成 git diff 檢查。
- 完成 Git Commit。

### Milestone 5-3：最終驗收

完成第一階段 MVP 的最終驗證。

完成定義：

- 程式碼結構清楚。
- 文件符合繁中規範。
- MVP 功能可以跑通。
- `dart pub get` 通過。
- `melos run build_runner` 通過。
- `melos run analyze` 通過。
- `flutter test` 通過。
- `flutter build bundle` 通過。
- 完成 Final Commit。

---

## Milestone 7：Dependency Upgrade

第一階段 MVP 已完成後，下一個獨立工作是整理 dependency upgrade。

這不是功能開發，也不是架構重設計，而是確認 Template 的 dependency baseline 是否需要更新到更適合作為長期基礎的版本。

### 背景

目前 `dart pub outdated` 顯示多個核心套件已有新版，但大多是 major upgrade。

例如：

- `auto_route` 9.x → 11.x
- `freezed` 2.x → 3.x
- `get_it` 7.x → 9.x
- `injectable` 2.x → 3.x
- `build_runner` 2.5.x → 2.15.x
- `flutter_lints` 4.x → 6.x

這些升級可能影響 generated code、router、DI、analyzer 與 lint 規則，因此需要獨立處理。

### 升級原則

- 不更換架構。
- 不更換 Bloc / AutoRoute / Injectable / GetIt。
- 不藉升級做功能重構。
- 每次只升級一組高度相關套件。
- 每組升級後都要重新產生程式碼並驗證。
- 若 generator 套件受到 `analyzer` / `source_gen` / `build_runner` constraints 牽動，允許合併為同一批升級。
- 若 migration 成本過高，允許暫時維持現有版本。

### 建議拆分

#### Milestone 7-1：Dependency Audit

- 重新執行 `dart pub outdated`。
- 區分 patch / minor / major upgrade。
- 閱讀 major upgrade migration notes。
- 決定升級順序與暫緩項目。

#### Milestone 7-2：Code Generation Stack Upgrade

範圍：

- `build_runner`
- `freezed`
- `freezed_annotation`
- `json_serializable`
- `json_annotation`

注意：Freezed / Json Serializable 新版可能要求提高 Dart SDK constraint。

#### Milestone 7-3：Dependency Injection Stack Upgrade

範圍：

- `get_it`
- `injectable`
- `injectable_generator`

#### Milestone 7-4：Router Stack Upgrade

範圍：

- `auto_route`
- `auto_route_generator`

#### Milestone 7-5：Lint Rules Upgrade

範圍：

- `flutter_lints`
- `lints`

#### Milestone 7-6：Final Verification

最終至少執行：

```bash
dart pub get
dart run melos run build_runner
dart run melos run analyze
dart run melos exec -- flutter test
cd apps/flutter_architecture
flutter build bundle
```

### 完成定義

- 決定升級的 direct dependencies 已完成升級。
- generated files 已重新產生並檢查。
- MVP flow 行為不變。
- analyze / test / build 全部通過。
- README / progress / roadmap 已同步。

---

## Milestone 8：Modernization Review

在 Dependency Upgrade 完成後，進行一輪 Modernization Review。

此 Milestone **不是再次升級套件**，而是確認升級後是否仍保留舊版相容寫法，並評估是否值得採用新版 API 或 Best Practice。

### 原則

- 不新增功能。
- 不重構架構。
- 不為了新而新。
- 維持 Backward Compatible。
- 只有在可讀性、維護性、穩定性有明確收益時才修改。

### Review 範圍

#### Milestone 8-1：Freezed Modernization

- 評估 `abstract class` 是否適合改為 `sealed class`。
- 檢查是否有可採用的新 annotation 或 generated API。
- 確認 union / copyWith / JSON 使用方式符合最新版建議。

#### Milestone 8-2：Dependency Injection Review

- 檢查 GetIt / Injectable 是否仍使用舊版相容 API。
- 移除已 deprecated 的用法（若有）。
- 確認 generated DI 維持最小且清楚。

#### Milestone 8-3：AutoRoute Review

- 檢查 Router API 是否有新版建議寫法。
- 檢查 Guard、Nested Route、Tabs Router 是否仍符合官方 Best Practice。
- 不因 API 更新而改變既有導覽行為。

#### Milestone 8-4：Flutter / Dart Best Practice Review

- 檢查新版 lint 與官方建議。
- 僅修正具有明確收益的項目。
- 不做純風格性重寫。

#### Milestone 8-5：Final Verification

- `dart pub get`
- `dart run melos run build_runner`
- `dart run melos run analyze`
- `dart run melos exec -- flutter test`
- `flutter build bundle`

### Definition of Done

- 已完成新版 API 與 Best Practice Review。
- 無保留已知 deprecated API。
- 所有修改皆有明確收益。
- analyze / test / build 全部通過。
- 文件同步完成。

---

## Milestone 9：Retrofit API Client Standardization

將 `packages/api_client` 的真實 HTTP API 統一遷移為 Retrofit，並建立 Mock / Retrofit 可替換的 API boundary。

狀態：In Progress。

### Milestone 9-1：文件與邊界定義

狀態：Completed。

- 新增 Architecture Decision 013。
- 定義所有真實 HTTP API 必須使用 Retrofit。
- 定義 Mock API 例外與 API abstraction。
- 定義 DTO、Mapper、Domain Entity 的責任邊界。
- 定義直接操作 Dio 的允許範圍。

### Milestone 9-2：Auth API 遷移

狀態：Completed。

- 建立 Auth API abstraction。
- 由 Retrofit abstract class 同時作為 Auth API abstraction 與真實 HTTP declaration。
- 建立 Mock Auth implementation。
- 建立 `LoginRequestDto`。
- 將既有 Login response model 明確調整為 DTO 命名。
- Mock implementation 放在 `packages/api_client/lib/src/mocks/`。
- 既有 Demo 預設繼續使用 Mock implementation。
- 已驗證 Retrofit 會以 `POST /auth/login` 傳送 JSON request body，並將 JSON response 解析為 `LoginResponseDto`。
- RemoteDataSource 建立 `LoginRequestDto` 並呼叫 `AuthApi`。
- Login response 透過 Mapper 轉為 `AuthResult`，Repository 保留持久化與 Session 更新責任。
- Dio transport exception mapping 保留在 `api_client`，避免 `packages/auth` 直接依賴 Dio。

### Milestone 9-3：Profile API 遷移

狀態：Completed。

- 建立 Profile API abstraction。
- 由 Retrofit abstract class 同時作為 Profile API abstraction 與真實 HTTP declaration。
- 建立 Mock Profile implementation。
- 將既有 Profile response model 明確調整為 DTO 命名。
- 驗證 authenticated request metadata 是否正確進入 Dio `Options.extra`。
- 移除手寫 Dio request 示範方法，改由 Retrofit endpoint 表達 authenticated request。
- 已補上 `GET /profile` request test，驗證 `requiresAuth` metadata 會進入 Dio `Options.extra`。

### Milestone 9-4：DI 與環境切換

狀態：Completed。

- App Composition Root 決定 Mock 或 Retrofit implementation。
- package 內不加入 GetIt / Injectable annotation。
- 使用最小 `ApiConfig` / `ApiMode` 表達 Mock / Real selection，並預留給後續完整 AppConfig / Flavor。
- RemoteDataSource 只依賴 API abstraction。
- `API_MODE` / `API_BASE_URL` 透過 `--dart-define` 提供；預設使用 Mock mode。
- Dio 的 base URL 由 `ApiConfig` 注入，不再硬編碼在 `api_client` package。
- 已補上 Mock / Real implementation selector tests。

### Milestone 9-5：Mapper 與錯誤邊界整理

狀態：Completed。

- DTO 到 Domain Entity 的 Mapper 放在對應 package 的 data layer。
- Mapper 只做純資料轉換；Repository implementation 負責持久化與 Session 更新。
- Domain Layer 不暴露 DTO。
- RemoteDataSource 將 DioException 映射為 AppException。
- Repository implementation 將 Data Layer exception 映射為 Failure。
- 保留後續統一 API Error Mapping 的擴充點。
- Auth / Profile Repository 只將 `AppException` 映射為 `Failure`；未知程式錯誤不再被吞掉。
- Profile 新增 RemoteDataSource，統一處理 transport exception mapping。
- SharedPreferences / SQLite 錯誤在 AuthLocalDataSource boundary 轉為 `AppException`。

### Milestone 9-6：測試與驗證

狀態：Completed。

- [x] Mock API test。
- [x] DTO JSON serialization test。
- [x] Mapper test。
- [x] Retrofit endpoint generation / request test。
- [x] Repository 與 RemoteDataSource regression test。
- [x] 已知 `AppException` 轉為 domain `Failure`，未知錯誤保持拋出。
- [x] Failure 顯示 domain fallback message，技術 exception 保留於 cause chain。

最終至少執行：

```bash
dart pub get
dart run melos run build_runner
dart run melos run analyze
dart run melos exec -- flutter test
cd apps/flutter_architecture
flutter build bundle
```

### 完成定義

- 所有真實 HTTP endpoint 都由 Retrofit 宣告。
- Mock 與 Retrofit implementation 實作相同 API abstraction。
- Feature、Repository、RemoteDataSource 不直接操作 Dio。
- DTO 與 Domain Entity 維持分離。
- Mock / Real implementation 由 App Composition Root 決定。
- 既有 Login、Profile、Session 與 Route Guard 行為不變。
- analyze / test / build 全部通過。

Milestone 9 狀態：Completed。

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
