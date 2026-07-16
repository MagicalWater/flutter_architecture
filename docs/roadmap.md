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

狀態：Completed。

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

## Milestone 10：App Configuration 與 Dart Environment Entrypoint

建立可供後續正式功能使用的 App Configuration 與 Dart-level environment entrypoint 基礎。

狀態：Completed。

本 Milestone 只處理 Dart 層環境與設定基礎，不包含 Native Flavor、CI/CD、GitHub Actions、Firebase、Analytics 或正式發布流程。

### Milestone 10-1：環境模型與責任邊界

- [x] 建立 `AppEnvironment`：`development`、`staging`、`production`。
- [x] 保留 `ApiMode`：`mock`、`real`，不與 App Environment 混為同一概念。
- [x] Dart entrypoint 是 `AppEnvironment` 的唯一來源，不另外使用 `APP_ENV` dart-define。
- [x] 合法組合：development 可使用 mock / real；staging 與 production 只允許 real。
- [x] package 不直接讀取 `String.fromEnvironment`。

### Milestone 10-2：Typed AppConfig

- [x] 建立集中、不可變且可測試的 App 設定模型。
- [x] `AppConfig` 組合 `AppEnvironment` 與 `ApiConfig`。
- [x] `ApiConfig` 保留為 typed sub-config，但不自行讀取 dart-define。
- [x] 在 App bootstrap 集中解析 `API_MODE`、`API_BASE_URL`。
- [x] `configureDependencies` 明確接收已驗證的 `AppConfig`。
- [x] 缺少必要設定時 fail fast。
- [x] 不將 secret 放入 `dart-define` 或編譯產物。

### Milestone 10-3：共用 Bootstrap 與 Dart Entrypoint

- [x] 建立 `main_development.dart`、`main_staging.dart`、`main_production.dart`。
- [x] `main.dart` 預設使用 development，維持既有執行方式。
- [x] 建立共用 `bootstrap`，集中 database initialization、config 建立、DI registration 與 `runApp`。
- [x] 各 entrypoint 只指定 `AppEnvironment`，不複製業務 bootstrap 流程。
- [x] 補充各環境的 run / build 使用方式。

### Milestone 10-4：安全與驗證規則

- [x] staging / production 不允許 Mock API。
- [x] Real API 必須明確提供合法 base URL。
- [x] base URL 只允許 `http` 或 `https` scheme。
- [x] production 必須使用 `https`。
- [x] production 不允許 `mock.local`、localhost、loopback 或 `.invalid` URL。
- [x] 未知 `API_MODE` 或不合法設定直接 fail fast。

### Milestone 10-5：測試與文件

- [x] 驗證各 environment 對應的 config validation。
- [x] 驗證 Mock / Real 合法組合。
- [x] 驗證 staging / production + mock 會 fail fast。
- [x] 驗證 real mode 缺少 URL、錯誤 scheme 與 production HTTP URL 會 fail fast。
- [x] 驗證 AppConfig 會明確傳入 Composition Root，並注入正確 implementation。
- [x] 維持既有 Login / Profile / Session / Route Guard 行為。
- [x] 同步 README、Project Context、Architecture Decisions、Changelog。

### 完成定義

- App Environment 與 API implementation selection 邊界清楚。
- Dart entrypoint 是 AppEnvironment 的唯一來源。
- 所有 runtime config 由 App bootstrap 集中解析並明確傳入 Composition Root。
- package 不直接依賴 environment parsing API。
- development / staging / production 具備 Dart-level entrypoint 與最小可執行基礎。
- 不建立 Android productFlavors、iOS Schemes 或其他 Native Flavor 設定。
- 不包含 CI/CD 實作。
- `dart pub get`、build_runner、analyze、test、build 驗證全部通過。

---

## Milestone 11：CI/CD（暫緩）

狀態：Deferred。

CI/CD、GitHub Actions、build matrix、automatic release 與 deployment pipeline 目前不實作。

保留 Milestone 編號，待 deployment / release requirements 明確後再重新評估。

---

## Milestone 12：Refresh Token + Concurrent 401 Handling

在 App Configuration 基礎完成後，建立完整 Refresh Token 與並行 401 處理流程。

狀態：Completed。

架構責任邊界已由 Architecture Decision 015 拍板。

### Milestone 12-1：Token Model 與 Persistence

狀態：Completed。

- 將既有 access-token-only storage 升級為完整 Token Pair storage abstraction。
- 建立 persistence model，包含 access token、refresh token 與可用的 expiration metadata。
- Access / Refresh Token 以單一 logical value 保存，避免分開寫入造成不一致。
- Login response、Mock Auth 與 mapper 支援 refresh token 與 token rotation 所需欄位。
- Restore Session 只有在完整 Token Pair 與 User persistence 都有效時才恢復登入。
- 舊 `auth.accessToken` 單 token state 不做複雜 migration；讀到不完整狀態時清除並視為未登入。
- SessionManager 維持 runtime-only，不向跨 feature consumer 暴露 refresh token。
- `packages/api_client` 定義 runtime Session snapshot abstraction，包含 access token、userId 與 generation。
- `packages/auth` 實作只從 SessionManager 提供 snapshot，不在每個 request 時讀取 persistence。
- Login 保存 Token Pair 與 User 時採補償式一致性；任一步驟失敗都會 best-effort 清除兩者，且不更新 SessionManager。
- Restore Session 遇到 Token Pair / User 任一缺少或不合法時，best-effort 清除兩者並視為未登入。
- Logout / invalidation 必須分別嘗試清除 Token Pair 與 User，不可因第一個 cleanup 失敗而跳過第二個，最後一定清除 SessionManager。
- SharedPreferences 寫入與刪除必須檢查回傳結果，避免 persistence operation 回傳 `false` 卻被視為成功。
- Token Pair payload 損壞時必須與一般 I/O failure 區分；損壞資料會清除本地 Auth state 並視為未登入。
- Login / Logout 遇到未知 persistence error 時仍必須完成補償或第二個 cleanup，並保留原始 error 與 stack trace。
- `AuthLocalStore` 僅作為 auth package 內部 data-layer seam，不成為 public package API。

完成驗證：

```txt
dart run melos run build_runner
dart run melos run analyze
dart run melos exec -- flutter test
flutter build bundle
git diff --check
```

### Milestone 12-2：Refresh API 與 Auth Refresh Flow

狀態：Completed。

- 建立獨立 Retrofit `AuthRefreshApi`，只包含 refresh endpoint。
- `AuthApi` 維持 login boundary；`AuthRefreshApi` 固定使用 Refresh Dio。
- Mock implementation 分為 `MockAuthApi` 與 `MockAuthRefreshApi`。
- 建立 Refresh request / response DTO 與 mapper。
- 建立獨立 Refresh Dio，不安裝 AuthHeaderInterceptor 或 AuthRefreshInterceptor。
- 在 `packages/api_client` 定義最小 refresh abstraction 與 result type。
- 在 `packages/auth` 實作 refresh coordinator / refresher。
- single-flight refresh 以 generation、userId 與 failed access token 綁定同一 Session identity；相同 identity 共用同一個 Future，不同 Session 不得互相加入。
- 支援 refresh token rotation。
- Refresh 成功先保存完整 Token Pair，再更新 SessionManager。
- Refresh result 明確區分 `success`、`sessionExpired`、`temporarilyUnavailable`、`sessionChanged` 與 `localStateFailure`。
- Invalid refresh credential 執行被動 Session invalidation，不透過 LogoutUseCase。
- 防止 refresh 期間 Logout、重新 Login 或切換帳號後，舊 response 覆蓋新 Session。
- `SessionManager` 持有 monotonically increasing session generation。
- Login、Restore Session、Logout 與 Session invalidation 會遞增 generation；一般 refresh 成功不遞增。
- Refresh 開始時捕獲 generation、userId 與 failed access token，寫入新 Token Pair 前再次驗證 Session identity。
- Session identity 已改變時回傳 `sessionChanged`，不得保存、更新 Session 或 replay。
- Login、Restore、Logout、Refresh persistence commit 與 passive invalidation 共用 `AuthStateMutationCoordinator`，確保 Token Pair、User persistence 與 runtime Session 的複合修改序列化。
- Refresh HTTP request 不持有 mutation lock；只有讀取或提交本地 auth state 與更新 SessionManager 時進入臨界區。
- Passive invalidation 在取得 mutation lock 後必須再次驗證 generation / userId；舊 Session operation 不得清除新 Session。
- HTTP 401 / 403 暫時視為 invalid refresh credential；一般 400、5xx、timeout、malformed 200 與 serialization failure 保留 Session 並回傳 `temporarilyUnavailable`。

完成驗證：

```txt
dart run melos run build_runner
dart run melos run analyze
dart run melos exec -- flutter test
flutter build bundle
git diff --check
```

### Milestone 12-3：Concurrent 401 Interceptor

狀態：Completed。

- 保留 AuthHeaderInterceptor 只負責加入 access token。
- 新增獨立 AuthRefreshInterceptor。
- 只處理 authenticated、未 retry、未 skip 且實際帶 token 的 401。
- AuthHeaderInterceptor 在 request metadata 保存原 Session generation 與 userId。
- Login、Refresh、public endpoint 與已 replay request 不進入 refresh flow。
- 只有 request generation / userId 與 current Session 相同，且 failed token 與 current token 不同時，才直接以最新 token replay，不再次 refresh。
- generation 或 userId 不同時回傳 `sessionChanged` 或原始 401，不 refresh、不 replay，避免跨帳號 request replay。
- 多個並行 401 等待同一個 single-flight refresh。
- Refresh request 本身不進入 refresh interceptor。

### Milestone 12-4：Safe Request Replay

狀態：Completed。

- Refresh 成功後以最新 access token replay 原 request。
- Replay request 標記 `authRetryCount = 1`。
- Replay 再次 401 時直接回傳錯誤，不進入第二次 refresh。
- 一般 JSON、query 與可重建 body 可 replay。
- Stream、Multipart、upload、特殊 download 或其他不可安全重送 request，必須顯式關閉 auth replay。
- Request replay 不取代業務 Idempotency Key。

### Milestone 12-5：Session Expiration 與既有 UI Flow

狀態：Completed。

- Refresh credential 無效時清除 Token Pair、User persistence 與 SessionManager。
- Interceptor 不直接操作 Router、Bloc 或 LogoutUseCase。
- AuthBloc 透過 SessionManager stream 同步未登入狀態。
- ProfileBloc 與 AuthGuard 維持既有依賴邊界。
- 驗證 Session expiration 後 Profile、ProtectedRoute 與 Login UI 行為。

### Milestone 12-6：Concurrency / Failure / Regression Tests

狀態：Completed。

至少涵蓋：

- 10 個 authenticated request 同時收到 401，只呼叫一次 refresh。
- Refresh 成功後所有 request 使用新 token replay。
- 較晚返回的舊 401 不再次 refresh。
- 帳號 A 的舊 request 不會使用帳號 B 的 token replay。
- Logout 後的舊 request 不會在重新登入後被 replay。
- Replay 再次 401 不形成無限 retry。
- Login、Refresh、public endpoint 401 不觸發 refresh。
- 缺少 refresh token或 invalid refresh credential 時 Session 失效。
- Timeout、DNS、無網路與 server 5xx 不清除 Session。
- `sessionChanged` 不清除新的 Session，也不 replay 舊 request。
- Refresh token rotation 正確保存。
- Persistence failure 不更新 runtime token，會 best-effort 清除本地 auth state、清除 SessionManager，並回傳 `localStateFailure`。
- Login partial persistence failure 會補償清除 Token Pair 與 User，且不建立 runtime Session。
- Logout / invalidation 的兩個 local cleanup 都會被嘗試，最後一定清除 SessionManager。
- Refresh 中途 Logout / relogin 時舊 response 被丟棄。
- Login / Restore / Logout / AuthGuard / Profile regression。
- Mock / Real Composition Root graph 都能建立。

### Milestone 12-7：文件與完整驗證

狀態：Completed。

- 同步 README、Project Context、Architecture Decisions、Changelog 與相關 feature / package 文件。
- 執行 `dart pub get`。
- 執行 build_runner。
- 執行 analyze。
- 執行全部 flutter test。
- 執行 development / staging / production bundle build。

完成驗證：

```txt
dart pub get
dart run melos run build_runner
dart run melos run analyze
dart run melos exec -- flutter test
flutter build bundle -t lib/main_development.dart
flutter build bundle -t lib/main_staging.dart --dart-define=API_MODE=real --dart-define=API_BASE_URL=https://staging-api.example.com
flutter build bundle -t lib/main_production.dart --dart-define=API_MODE=real --dart-define=API_BASE_URL=https://api.example.com
git diff --check
```

### 完成定義

- Token Pair persistence 與 runtime Session 邊界清楚。
- concurrent 401 只會產生一次 refresh request。
- Refresh 成功可安全 replay 原 request。
- Refresh request與 replay request 不會形成無限 retry。
- 暫時性 refresh failure 不會錯誤清除 Session。
- Invalid refresh credential 會清除 auth state，並透過 SessionManager 自然驅動 UI 進入未登入狀態。
- Logout / relogin race 不會讓舊 refresh response 復活或覆蓋 Session。
- package 不綁定 DI framework，App 仍是唯一 Composition Root。
- analyze / test / build 全部通過。

---

## Milestone 13：Pagination + Search Debounce

建立可重用但不過度抽象的清單載入與搜尋範例。

狀態：Planned；Architecture Review 已完成，Decision 016 已拍板，尚未開始功能實作。

本 Milestone 使用 `Catalog` feature 示範完整垂直切片，正式採用 cursor-based pagination。

核心決策：

```txt
Feature
  Catalog

Pagination
  Cursor-based

Search debounce
  300 ms
  trim + distinct
  位於 Bloc event pipeline

過期 response
  search generation + query + cursor identity

Load More
  state guard + in-flight suppression + response validation

取消策略
  logical cancellation
  不讓 Dio CancelToken 穿透 Presentation / Domain

UseCase
  SearchCatalogUseCase

Cache
  不屬於 Milestone 13，留給 Milestone 14
```

### Milestone 13-1：Architecture Decision 與 Feature Contract

- [x] 新增 Architecture Decision 016。
- [x] 拍板使用 cursor-based pagination。
- [x] 定義 query / cursor / limit contract。
- [x] 定義 search generation 與 stale-response guard。
- [x] 定義 debounce、query normalization 與 logical cancellation。
- [x] 定義 Initial / Refresh / Append loading 與 failure state。
- [x] 定義 Milestone 13 不處理 Offline Cache、page-based strategy 與 transport cancellation。

### Milestone 13-2：Catalog API、DTO、Mock 與 Retrofit Contract

- 建立 Retrofit `CatalogApi`。
- 建立 `MockCatalogApi`，支援 query、cursor、limit 與多頁資料。
- 建立 `CatalogItemDto` 與 `CatalogPageResponseDto`。
- 第一頁使用 `cursor = null`，下一頁使用 response `nextCursor`。
- Catalog 使用 public demo endpoint，不標記 authenticated request metadata。
- App Composition Root 根據 ApiMode 選擇 Mock 或 Retrofit implementation。

測試至少涵蓋：

- HTTP method、path 與 query serialization。
- `cursor = null` 的第一次 request。
- 有 cursor 的下一頁 request。
- DTO JSON serialization / deserialization。
- Mock 分頁、搜尋與最後一頁 `nextCursor = null`。
- Public request 不會被加入 Authorization header。

### Milestone 13-3：Domain、Mapper、RemoteDataSource 與 Repository

- 建立 `CatalogItem` Domain Entity。
- 建立 `CatalogPage` Domain Model。
- 建立 `CatalogRepository` interface。
- 建立 `SearchCatalogUseCase`。
- 建立 `CatalogRemoteDataSource`。
- 建立 DTO 到 Domain Mapper。
- 建立 `CatalogRepositoryImpl`。
- RemoteDataSource 將 transport exception 映射為 `AppException`。
- Repository 將 `AppException` 映射為 `Failure`，未知錯誤保留原始 stack trace。
- Mapper 正規化空 cursor，並驗證 DTO 欄位。
- Repository 比對 request cursor 與 response `nextCursor`，拒絕無法前進的 cursor chain。

### Milestone 13-4：Initial Search、Debounce 與 Query Switching

- 建立 `CatalogBloc`、Event 與 State。
- `queryChanged` 使用預設 300 ms debounce。
- Debounce duration 可由 constructor 注入，方便測試。
- Query 使用 trim + distinct；不預設轉小寫。
- 空 query 載入預設 Catalog 清單。
- Initial loading、initial failure 與 empty state 分開呈現。
- 每個 logical search 使用 monotonically increasing generation。
- 舊 query 或舊 generation response 不得覆蓋目前 state。

測試至少涵蓋：

- 快速輸入 `f → fl → flutter` 只搜尋最後一個 query。
- 相同 normalized query 不重複搜尋。
- 舊 query response 晚回來不覆蓋新 query。
- 同 query 的舊 generation 不覆蓋新搜尋。
- Initial error 與 empty result。

### Milestone 13-5：Load More、Refresh 與 Failure Recovery

- `loadMoreRequested` 使用 state guard 與 in-flight event suppression。
- 不額外引入 `bloc_concurrency`；可使用既有 RxDart 建立 feature-local exhaust / droppable transformer。
- 同一時間最多一個 append request。
- Append response 驗證 generation、query 與 requested cursor。
- `nextCursor == null` 時停止載入；是否有下一頁只由 cursor 衍生。
- 依穩定 Domain ID 去重並保留原順序。
- Append failure 保留既有 items，並提供底部 retry。
- Refresh 使用目前 query 與 `cursor = null`。
- Refresh 遞增 generation，使舊 Initial / Append operation 過期。
- Refresh 成功整批替換資料；失敗保留舊 items。

測試至少涵蓋：

- 連續 Load More 只呼叫一次 Repository。
- Append 使用正確 cursor。
- End reached 不再請求。
- 重複或無法前進 cursor 不形成無限 request。
- Append 去重、順序與 retry。
- Refresh 與舊 Append response race。
- Query 切換與舊 Append response race。

### Milestone 13-6：Page、Route、DI 與 UI Flow

- 建立 `CatalogPage`。
- 建立 Search TextField、清單、empty state 與錯誤呈現。
- Scroll 接近底部時觸發 Load More。
- Pull-to-refresh 觸發 Refresh。
- Initial / Refresh / Append loading 與 failure 使用不同 UI surface。
- Page 只依賴 `CatalogBloc`，不直接依賴 Repository、API 或 Dio。
- 建立 Catalog route 與 Shell 入口。
- 完成 Catalog API、DataSource、Repository、UseCase 與 Bloc 的 Composition Root registration。
- 驗證 Mock / Real graph。

### Milestone 13-7：Regression、文件與完整驗證

- 補齊 Catalog API、DTO、Mapper、Repository、Bloc 與 Widget tests。
- 補齊 debounce、query switching、stale response、duplicate load 與 refresh race tests。
- 驗證 Login、Refresh Token、Profile、Session 與 Route Guard regression。
- 同步 README、Project Context、Architecture Decisions、Roadmap、Changelog 與 feature 文件。
- 執行完整 dependency、generation、analyze、test 與 environment build 驗證。

完成驗證至少包含：

```txt
dart pub get
dart run melos run build_runner
dart run melos run analyze
dart run melos exec -- flutter test
flutter build bundle -t lib/main_development.dart
flutter build bundle -t lib/main_staging.dart --dart-define=API_MODE=real --dart-define=API_BASE_URL=https://staging-api.example.com
flutter build bundle -t lib/main_production.dart --dart-define=API_MODE=real --dart-define=API_BASE_URL=https://api.example.com
git diff --check
```

### 完成定義

- Catalog feature 具備 Bloc / UseCase / Repository / RemoteDataSource / DTO / Mapper / API 完整流程。
- Cursor-based pagination contract 清楚，且不混用 page-based state。
- Search debounce、query normalization 與 latest-query-wins 行為可測試。
- Initial、Refresh 與 Load More loading / failure state 分離。
- 重複 scroll event 不產生重複 append request。
- 舊 query、舊 generation、舊 cursor response 不會覆蓋或污染目前 state。
- Refresh 與 Query 切換可使舊 Append operation 安全過期。
- Append item 依穩定 ID 去重並維持順序。
- 不讓 Dio cancellation detail 穿透 Presentation / Domain boundary。
- 不建立通用 Generic Pagination framework。
- Offline Cache 維持 Milestone 14 範圍。
- package 不綁定 DI framework，App 仍是唯一 Composition Root。
- analyze / test / development、staging、production build 全部通過。

---

## Milestone 14：Offline Cache

建立 Remote + Local 協調的 Offline Cache 範例。

預計涵蓋：

- Cache policy 與資料新鮮度。
- Remote-first、cache-first 或 stale-while-revalidate 的明確示範。
- SQLite Entity 與 Domain Entity mapping。
- Offline 狀態、同步失敗與 stale data 呈現。
- 與 Pagination / Search 的整合邊界。

---

## 暫不處理

以下內容目前暫不實作，且不代表仍全部留在 Backlog；已排入 Milestone 12 至 14 的項目以本 Roadmap 為準：

- 完整 ADR 系列。
- 大量測試範例。
- CI/CD。
- Design System。
- WebSocket。
- 多個業務 feature。

CI/CD 已保留為 Milestone 11，但狀態為 Deferred。
