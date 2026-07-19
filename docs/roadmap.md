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

狀態：Completed；Milestone 13-1 至 13-7 已完成。

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

- [x] 建立 Retrofit `CatalogApi`。
- [x] 建立 `MockCatalogApi`，支援 query、cursor、limit 與多頁資料。
- [x] 建立 `CatalogItemDto` 與 `CatalogPageResponseDto`。
- [x] 第一頁使用 `cursor = null`，下一頁使用 response `nextCursor`。
- [x] Catalog 使用 public demo endpoint，不標記 authenticated request metadata。
- [x] App Composition Root selector 根據 ApiMode 選擇 Mock 或 Retrofit implementation。

測試至少涵蓋：

- HTTP method、path 與 query serialization。
- `cursor = null` 的第一次 request。
- 有 cursor 的下一頁 request。
- DTO JSON serialization / deserialization。
- Mock 分頁、搜尋與最後一頁 `nextCursor = null`。
- Public request 不會被加入 Authorization header。

狀態：Completed。

完成驗證：

```txt
dart run build_runner build（packages/api_client）
flutter test packages/api_client/test/api_client_smoke_test.dart
flutter test apps/flutter_architecture/test/app/di/api_implementation_selector_test.dart
dart run melos run analyze
dart run melos exec -- flutter test
git diff --check
```

### Milestone 13-3：Domain、Mapper、RemoteDataSource 與 Repository

- [x] 建立 `CatalogItem` Domain Entity。
- [x] 建立 `CatalogPage` Domain Model。
- [x] 建立 `CatalogRepository` interface。
- [x] 建立 `SearchCatalogUseCase`。
- [x] 建立 `CatalogRemoteDataSource`。
- [x] 建立 DTO 到 Domain Mapper。
- [x] 建立 `CatalogRepositoryImpl`。
- [x] RemoteDataSource 將 transport exception 映射為 `AppException`。
- [x] Repository 將 `AppException` 映射為 `Failure`，未知錯誤保留原始 stack trace。
- [x] Mapper 正規化空 cursor，並驗證 DTO 欄位。
- [x] Repository 比對 request cursor 與 response `nextCursor`，拒絕無法前進的 cursor chain。

狀態：Completed。

完成驗證：

```txt
dart run build_runner build（apps/flutter_architecture）
flutter test apps/flutter_architecture/test/features/catalog/data/catalog_data_layer_test.dart
dart run melos run analyze
dart run melos exec -- flutter test
git diff --check
```

### Milestone 13-4：Initial Search、Debounce 與 Query Switching

- [x] 建立 `CatalogBloc`、Event 與 State。
- [x] `queryChanged` 使用預設 300 ms debounce。
- [x] Debounce duration 可由 constructor 注入，方便測試。
- [x] Query 使用 trim + distinct；不預設轉小寫。
- [x] 空 query 載入預設 Catalog 清單。
- [x] Initial loading、initial failure 與 empty state 分開呈現。
- [x] 每個 logical search 使用 monotonically increasing generation。
- [x] 舊 query 或舊 generation response 不得覆蓋目前 state。

測試至少涵蓋：

- 快速輸入 `f → fl → flutter` 只搜尋最後一個 query。
- 相同 normalized query 不重複搜尋。
- 舊 query response 晚回來不覆蓋新 query。
- 同 query 的舊 generation 不覆蓋新搜尋。
- Initial error 與 empty result。

狀態：Completed。

完成驗證：

```txt
dart run build_runner build（apps/flutter_architecture）
flutter test apps/flutter_architecture/test/features/catalog/presentation/bloc/catalog_bloc_test.dart
dart run melos run analyze
dart run melos exec -- flutter test
git diff --check
```

### Milestone 13-5：Load More、Refresh 與 Failure Recovery

- [x] `loadMoreRequested` 使用 state guard 與 in-flight event suppression。
- [x] 不額外引入 `bloc_concurrency`；使用既有 RxDart 建立 feature-local exhaust transformer。
- [x] 同一時間最多一個 append request。
- [x] Append response 驗證 generation、query 與 requested cursor。
- [x] `nextCursor == null` 時停止載入；是否有下一頁只由 cursor 衍生。
- [x] 依穩定 Domain ID 去重並保留原順序。
- [x] Append failure 保留既有 items，並允許 retry。
- [x] Refresh 使用目前 query 與 `cursor = null`。
- [x] Refresh 遞增 generation，使舊 Initial / Append operation 過期。
- [x] Refresh 成功整批替換資料；失敗保留舊 items。

測試至少涵蓋：

- 連續 Load More 只呼叫一次 Repository。
- Append 使用正確 cursor。
- End reached 不再請求。
- 重複或無法前進 cursor 不形成無限 request。
- Append 去重、順序與 retry。
- Refresh 與舊 Append response race。
- Query 切換與舊 Append response race。

狀態：Completed。

完成驗證：

```txt
dart run build_runner build（apps/flutter_architecture）
flutter test apps/flutter_architecture/test/features/catalog/presentation/bloc/catalog_bloc_test.dart
dart run melos run analyze
dart run melos exec -- flutter test
git diff --check
```

### Milestone 13-6：Page、Route、DI 與 UI Flow

狀態：Completed。

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

狀態：Completed。

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

狀態：Completed；Milestone 14-1 至 14-7 已完成。

封存：已納入 Template Baseline 1.1.0（2026-07-17）；final review findings 與 chain revision 修正均已完成。

最終整體 review 已完成：新增 SQLite v4 `chain_revision` migration、相同 cursor Refresh late-write 防護，以及 expired predecessor / retained successor replacement regression coverage。

本 Milestone 只為 Catalog 建立 feature-level、明確 opt-in 的 Offline Cache，不建立所有 API 自動寫入 SQLite 的 generic HTTP cache。

核心決策：

```txt
Feature
  Catalog 專屬 Offline Cache

Initial / Query Switching
  Cache-first + Stale-While-Revalidate

Refresh
  強制 Remote
  成功後 replacement 第一頁並重設 cursor chain

Append
  以 query + requested cursor + limit 讀寫單次 page cache
  第一版不做 background revalidation

Freshness
  freshFor + retainFor

Cache identity
  normalized query + request cursor + limit

Storage
  SQLite page metadata + ordered page items

UI metadata
  isUsingCachedData / isStale / lastUpdatedAt / isRevalidating

Logout
  Public Catalog Cache 保留

非目標
  Generic Cache / Generic Pagination framework
```

架構責任邊界已由 Architecture Decision 017 拍板。

### Milestone 14-1：Architecture Decision 與 Cache Contract

狀態：Completed。

- [x] 定義 Catalog feature-level opt-in cache。
- [x] 排除 generic HTTP cache 與 command API cache。
- [x] Initial / Query Switching 採 Cache-first + SWR。
- [x] Refresh 強制 Remote，Append 使用單次 page cache，不做背景 revalidation。
- [x] 定義 fresh、stale、expired / retention。
- [x] 定義 normalized query + request cursor + limit identity。
- [x] 定義 page metadata + ordered page items storage。
- [x] 定義所有 Remote 第一頁成功時的 cursor chain invalidation。
- [x] 定義 `CatalogLoadPolicy.initial / refresh / append` 與合法 cursor 組合。
- [x] 定義 initial / refresh / append 各自的 Stream emission contract。
- [x] 定義 DTO、Local Entity、Domain Entity mapping boundary。
- [x] 定義 Repository Remote + Local coordination 與 Stream emission contract。
- [x] 定義 Domain snapshot metadata 與 Bloc workflow metadata 邊界。
- [x] 定義畫面級 freshness 只代表第一頁 snapshot。
- [x] 定義 UI metadata，不以單次 transport failure 推測全域 `isOffline`。
- [x] 定義 SQLite v1 → v2 migration 與 public cache logout policy。
- [x] 定義測試策略與 Milestone 14 分段。

Decision 016 / 017、Roadmap、Project Context 與 CHANGELOG 已完成 consistency review；下一階段進入 Milestone 14-2。

### Milestone 14-2：SQLite Schema、Migration 與 Local Models

狀態：Completed。

- [x] 將 App database version 由 1 最終升級為 3；v2 建立 Cache tables，v3 升級 unique position index。
- [x] 建立 `catalog_cache_page`、`catalog_cache_page_item` 與必要 index。
- [x] item row 保存 id、name、description 與 position，完整支援 Domain round-trip。
- [x] 建立 v1 → v2 migration，保留 `auth_user`。
- [x] 建立 Catalog Local Entity 與 Local Mapper。
- [x] 建立 `CatalogLocalDataSource`。
- [x] 以 transaction replacement page metadata 與 ordered items。
- [x] 所有 Remote 第一頁成功可清除同 query + limit 的舊後續 chain。
- [x] 建立 cursor null sentinel boundary、空 cursor 防護與 page-level expired lazy cleanup。
- [x] 補上 in-memory SQLite、transaction rollback、migration 與 mapping tests。
- [x] Implementation review 補強 Local Entity validation、corrupted page recovery、empty page、delete isolation 與 SQLite failure mapping。

完成驗證：

```txt
flutter test test/features/catalog/data/catalog_local_data_source_test.dart
dart run melos run analyze
dart run melos exec -- flutter test
flutter build bundle
git diff --check
```

### Milestone 14-3：Repository Cache Coordination

狀態：Completed。

- [x] Repository 注入 RemoteDataSource、LocalDataSource、CachePolicy 與 Clock。
- [x] 建立 `CatalogPageSnapshot`、`CatalogDataSource` 與 `CatalogFreshness`。
- [x] 建立 `CatalogLoadPolicy.initial / refresh / append` contract、合法 cursor 組合與 fail-fast validation。
- [x] 實作 initial / refresh / append 各自明確的 Stream emission contract。
- [x] 建立 `CatalogRepository.watchCatalog()` 與 `SearchCatalogUseCase.watch()`。
- [x] Milestone 14-4 完成 Bloc 遷移後移除舊單次 `searchCatalog()` / `execute()` contract。
- [x] 實作 Cache miss、Fresh Cache、Stale Cache + revalidate。
- [x] Remote success 通過 cursor validation 後才寫入 Cache。
- [x] Cache read / write failure 採非阻斷 read-model policy。
- [x] Remote failure + Cache available 保留 Cache；無 Cache 才回傳 blocking failure。
- [x] 未知錯誤保留 Stream error channel 與原始 stack trace。
- [x] App Composition Root 明確註冊 LocalDataSource、CachePolicy、Clock 與 Repository。
- [x] Implementation review：Repository dependencies 全部改為 required，避免 silent Offline Cache misconfiguration。
- [x] Implementation review：Append 空白 cursor fail fast，未來 timestamp 視為 stale 並 revalidate。
- [x] 補齊 16 項 Repository freshness、retention boundary、failure、cursor 與 emission tests。

完成驗證：

```txt
flutter test test/features/catalog/data/catalog_repository_cache_test.dart
dart run melos run build_runner
dart run melos run analyze
dart run melos exec -- flutter test
git diff --check
```

### Milestone 14-4：Initial Search、Query Switching 與 SWR Bloc Flow

狀態：Completed。

- [x] CatalogBloc 使用 `emit.forEach` 處理 Cache → Remote 多次結果。
- [x] 保留 search generation、query identity 與 logical cancellation guard。
- [x] Query switching 使用 switchMap 取消舊 SWR subscription，且不清除其他 query Cache。
- [x] 新增 `isUsingCachedData`、`isStale`、`lastUpdatedAt`、`isRevalidating` 與 `revalidationFailure` state。
- [x] Stale Cache 先顯示並標記 background revalidation；Remote success 替換 snapshot metadata。
- [x] Revalidation failure 保留 Cache data，寫入 non-blocking `revalidationFailure`。
- [x] Background revalidation 與 user Refresh 使用不同 loading / failure state。
- [x] 移除舊單次 Repository / UseCase contract，Refresh / Append 暫以單次 Stream emission 保持既有行為。
- [x] 補齊 Initial SWR、query switching、stale response、unknown error cleanup 與 subscription cancellation tests。
- [x] Implementation review：Initial / Query / Retry / Refresh 共用可取消的第一頁 SWR subscription boundary。
- [x] Implementation review：Refresh 取消 stale revalidation 並完整更新第一頁 snapshot metadata。
- [x] Implementation review：Stale Cache 後 Stream 提前關閉視為 protocol violation。
- [x] CatalogBloc tests 增至 24 項，補齊跨事件 cancellation 與 stale-only Stream close coverage。

完成驗證：

```txt
flutter test test/features/catalog/presentation/bloc/catalog_bloc_test.dart
dart run melos run build_runner
dart run melos run analyze
dart run melos exec -- flutter test
git diff --check
```

### Milestone 14-5：Refresh、Append 與 Cursor Chain

狀態：Completed。

- [x] Refresh 使用目前 query 與 `cursor = null` 強制 Remote。
- [x] Remote 第一頁 Cache replacement 成功時，transaction 取代第一頁並失效同 query + limit 當下的舊後續 chain；Cache write failure 維持 non-blocking。
- [x] Refresh failure 保留既有 Cache、items、cursor 與 stale metadata。
- [x] Append 以 requested cursor page identity 讀寫 Cache。
- [x] Append 支援 Cache hit、miss 與 expired fallback；第一版不執行背景 revalidation。
- [x] Append Cache result 依穩定 ID 去重，不造成重複 item 或 cursor chain 污染。
- [x] Append snapshot 不覆蓋第一頁 source / freshness / lastUpdatedAt metadata。
- [x] 保留既有 generation、query、requested cursor race protection。
- [x] Refresh / Append 單次 Stream contract 明確拒絕零筆與多筆 emission。
- [x] 補齊第一頁 chain reset、append identity、expired replacement、metadata preservation 與 protocol violation tests。
- [x] Implementation review：Append conditional write 防止 Refresh 後 stale request 重新污染 Cache chain。
- [x] Implementation review：Bloc cursor history 防止多節點 cycle，Local boundary 防止 self-loop。
- [x] Implementation review：Refresh 採 exhaust，第一頁操作與 close 會取消 Refresh / Append subscription。

完成驗證：

```txt
flutter test test/features/catalog/data/catalog_repository_cache_test.dart test/features/catalog/presentation/bloc/catalog_bloc_test.dart
dart run melos run build_runner
dart run melos run analyze
dart run melos exec -- flutter test
flutter build bundle -t lib/main_development.dart
git diff --check
```

### Milestone 14-6：UI、DI 與 Offline Cache Flow

狀態：Completed。

- [x] Catalog UI 顯示 cached / stale notice。
- [x] 顯示 background revalidation indicator 與 non-blocking update failure。
- [x] 顯示 UTC `lastUpdatedAt`。
- [x] Fresh Remote data 不顯示 Cache / stale notice。
- [x] Fresh Cache 與 Stale Cache 使用不同 notice 與 visual state。
- [x] App Composition Root 註冊 LocalDataSource、RemoteDataSource、CachePolicy、Clock、Repository、UseCase 與 Bloc。
- [x] package 不加入 DI framework annotation。
- [x] 補上 Mock / Real Composition Root graph assertions。
- [x] 補上 cached、stale、lastUpdatedAt、revalidation 與 Fresh Remote Widget tests。
- [x] Implementation review：Refresh 已進行時再次呼叫 helper 會等待目前 lifecycle，不建立新 request。
- [x] Implementation review：Empty result 的 Refresh failure 與 empty content 同時可見。
- [x] Implementation review：Revalidation spinner / failure tests 符合正式互斥狀態。
- [x] Implementation review：補上 Catalog DI singleton / factory identity tests，並 close 測試 Bloc。

完成驗證：

```txt
flutter test test/features/catalog/presentation/pages/catalog_view_test.dart test/app/di/configuration_injection_test.dart
dart run melos run build_runner
dart run melos run analyze
dart run melos exec -- flutter test
flutter build bundle -t lib/main_development.dart
git diff --check
```

### Milestone 14-7：Cleanup、Regression、文件與完整驗證

狀態：Completed。

- [x] 驗證 retention-based expired page lazy cleanup 與 retainFor boundary。
- [x] 新增同一 SQLite database 的 Logout integration test，確認 Auth token / user / runtime Session 清除，但 public Catalog Cache 保留。
- [x] 補齊 migration、LocalDataSource、Repository、Bloc、Widget、Refresh lifecycle 與 DI scope coverage。
- [x] 驗證 Login、Refresh Token、Profile、Session、Route Guard 與 Milestone 13 pagination / search regression。
- [x] 同步 README、Project Context、Architecture Decisions、Roadmap、Changelog 與 Catalog feature 文件。
- [x] 執行完整 dependency、generation、analyze、test 與 development / staging / production bundle build。

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

- Catalog 可在 Cache 存在時離線顯示。
- Fresh / stale / expired policy 清楚且可測試。
- Stale Cache 可先顯示並背景更新。
- Cache identity 正確隔離 query、cursor 與 limit。
- 第一頁與後續頁以 cursor page 儲存，不保存單一合併 List。
- Refresh 成功可安全重設 cursor chain。
- DTO、Local Entity 與 Domain Entity 維持分離。
- Repository 負責 Remote + Local coordination，Bloc 不直接操作 DataSource。
- UI 可表達 cached、stale、last updated 與 background revalidation。
- 不以單次 transport failure 推測全域 Offline。
- Public Catalog Cache 不因 Logout 清除。
- 不建立 Generic Cache / Generic Pagination framework。
- App 仍是唯一 Composition Root。
- analyze / test / development、staging、production build 全部通過。

---

## 暫不處理

以下內容目前暫不實作，且不代表仍全部留在 Backlog；已排入 Milestone 12 至 15 的項目以本 Roadmap 為準：

- 完整 ADR 系列。
- 大量測試範例。
- CI/CD。
- WebSocket。
- 多個業務 feature。

CI/CD 已保留為 Milestone 11，但狀態為 Deferred。

---

## Milestone 15：Design System Foundation

建立可重用、可切換 Theme Identity、支援 Light / Dark / System mode，並具備明確 feature 使用邊界的 Design System Foundation。

狀態：Completed；Milestone 15-1 至 15-10 已完成。

Milestone 15 不把 Light / Dark 當成兩套互斥主題，而是將主題拆成兩個正交維度：

```txt
Theme Identity
  決定品牌色、semantic colors、Typography、Radius、Elevation
  與 Material component appearance

Theme Mode
  system / light / dark
  只決定目前使用該 Theme Identity 的 Light 或 Dark variant
```

第一版至少提供：

```txt
Default Theme
  ├── Light variant
  └── Dark variant

第二套示範 Theme
  ├── Light variant
  └── Dark variant
```

第二套 Theme 的目的，是證明 registry、semantic token、persistence 與 feature independence 確實成立；Milestone 15 不建立換膚商城、remote theme 或 runtime token editor。

Architecture Decision 018 定義 package、App、Feature、Theme Registry、Theme preference 與 Accessibility 的責任邊界。

### Milestone 15-1：Architecture Contract 與 Visual Audit

狀態：Completed。

- [x] 新增並 review Architecture Decision 018。
- [x] 確認 `packages/design_system` 為純 Flutter UI package。
- [x] 定義 App、Design System、Feature 的依賴方向。
- [x] 定義 Theme Identity 與 Theme Mode 的獨立 contract。
- [x] 定義每套 Theme 必須提供 Light / Dark variants。
- [x] 定義 System mode 不改變 Theme Identity。
- [x] 盤點 `ThemeData`、`ColorScheme`、`TextTheme`、`Colors.*`、固定 spacing、radius、elevation 與 presentation components。
- [x] 區分 visual token、layout token 與 feature behavior parameter；例如 Catalog load-more threshold 不提升為 spacing token。
- [x] 定義 Material Theme 優先與 `ThemeExtension` 使用條件。
- [x] 定義非目標、測試策略與完成定義。

Decision 018、Roadmap、Project Context、Backlog 與 CHANGELOG 已完成同步；後續已於 Milestone 15-2 完成 package skeleton、tokens 與 registry。

### Milestone 15-2：Package Skeleton、Design Tokens 與 Theme Registry

狀態：Completed。

- [x] 新增 `packages/design_system` 並加入 Dart Pub Workspace。
- [x] 建立穩定 public exports，禁止 feature 深層 import package internal files。
- [x] 建立 spacing、radius、elevation、icon size 與必要 layout primitives。
- [x] 建立 package-internal raw palettes；Feature 不直接使用 raw palette。
- [x] 建立 semantic color roles，包括 success、warning、info 與 Material error roles 的協調策略。
- [x] 建立穩定的 Theme ID value object、Theme metadata、Theme definition 與 registry contract。
- [x] Registry 驗證 default theme 存在、Theme ID 唯一，未知 ID fallback 至 Default Theme。
- [x] 以測試用 fake Theme definition 驗證 registry 可取得 Light / Dark ThemeData；正式 production Theme 留在 Milestone 15-3 與 15-4。
- [x] Package 不加入 GetIt、Injectable、SharedPreferences 或 feature dependency。
- [x] 補上 token、registry、duplicate ID、unknown ID 與 fallback tests。

完成實作：

- `DsSpace`、`DsRadius`、`DsElevation`、`DsIconSize`。
- `DsSemanticColorRole.success / warning / info`。
- `DsThemeId`、`DsThemeMetadata`、`DsThemeDefinition`、`DsThemeRegistry`。
- `DsThemeId` 採 canonical lowercase contract；`DsThemeMetadata` 拒絕空白 display name。
- Raw palette 保持 `lib/src/palette/` internal，未由 package entrypoint export。
- Registry 拒絕空 definitions、重複 ID、缺少 default theme，未知 ID fallback 至 default。
- Registry tests 鎖定 definition / metadata ID 一致性與 available themes 不可修改。
- Fake Theme definitions 驗證 Light / Dark ThemeData contract，尚未加入 production Theme。

後續已於 Milestone 15-3 完成 Default Theme Light / Dark。

### Milestone 15-3：Default Theme Light / Dark

狀態：Completed。

- [x] 建立 Default Theme 的 Light / Dark ColorScheme。
- [x] 建立 Typography hierarchy，不再由 feature 直接宣告 page title font size。
- [x] 建立 Radius、Elevation 與 surface hierarchy。
- [x] 建立 `AppBarTheme`、`NavigationBarThemeData`、`InputDecorationTheme`、Button themes、Card、Divider、ProgressIndicator 與 SnackBar themes。
- [x] 使用 `ThemeExtension` 補足 semantic colors；layout 仍使用既有 public primitive tokens，不把所有 spacing 塞入 extension。
- [x] ThemeExtension 正確實作 `copyWith` 與 `lerp`。
- [x] 補上 Default Light / Dark ThemeData contract tests。

完成實作：

- `DefaultThemeDefinition` 使用穩定 `default` Theme ID 與 `Default` metadata。
- Light / Dark 均使用 Material 3，並提供獨立 `ColorScheme` 與 surface hierarchy。
- Typography 明確定義 display、headline、title、body 與 label hierarchy。
- Button themes 維持合理 minimum size，並統一 radius 與 text style。
- `DsSemanticColors` 提供 success、warning、info 的 foreground / container / on-container colors。
- Default Theme contract tests 驗證 Light / Dark、Typography exact hierarchy、component theme 精確值、semantic color contrast 與 ThemeExtension `copyWith` / `lerp`。
- Milestone 15-4 只抽取 Default／示範 Theme 已證明重複的 package-internal factory 或 theme spec，不直接複製整份 Theme builder，也不建立 generic skin engine。

後續已於 Milestone 15-4 完成第二套示範 Theme Light / Dark。

### Milestone 15-4：第二套示範 Theme Light / Dark

狀態：Completed。

- [x] 建立第二套示範 Theme 的 Light / Dark variants。
- [x] 第二套 Theme 至少具有可辨識的 ColorScheme 與 semantic colors。
- [x] 有限度調整 Radius 與 Typography weight，以驗證 Theme definition 不只替換 seed color。
- [x] 不擴張為完整 skin marketplace、remote config 或動態 Theme editor。
- [x] 驗證 Default / 示範 Theme 與 Light / Dark 可形成四種有效 ThemeData 組合。

完成實作：

- 新增 `OceanThemeDefinition`，使用穩定 `ocean` ID 與 `Ocean` metadata。
- Ocean Theme 提供獨立 Light / Dark ColorScheme 與 semantic colors。
- Ocean Theme 使用較緊湊 radius 與較重 `titleLarge`，證明差異不只來自 seed color。
- 從 Default / Ocean 已確認的重複內容抽取 package-internal `DsMaterialThemeFactory`。
- Shared factory 只接受 brightness、seed、semantic colors、radius 與 title weight 等已被兩套 Theme 使用的明確參數。
- Registry tests 驗證 Default Light / Dark 與 Ocean Light / Dark 四種有效組合。
- Ocean tests 會同 brightness 比較 Default / Ocean semantic identity、驗證六組 semantic contrast，並鎖定 Registry 回傳正確 definition instance。

後續已於 Milestone 15-5 完成 Primitive Components。

### Milestone 15-5：Primitive Components

狀態：Completed。

- [x] 建立可重用 Status Banner / Inline Notice primitive。
- [x] 建立 constrained content primitive，統一 max width、page padding 與置中行為。
- [x] 建立 Button loading content，保留 Material Button variants，而不建立巨型 generic button。
- [x] Review 後不建立 compact progress 或 search primitive；目前沒有第二個穩定 consumer。
- [x] Primitive API 只接收純 presentation properties，不接收 Bloc state、Failure、Catalog snapshot 或 domain entity。
- [x] 補上 Light / Dark、兩套 Theme、Semantics、callback、disabled/loading、長文字與窄畫面 widget tests。

完成實作：

- 新增 `DsStatusBanner` 與 neutral、info、success、warning、error tone。
- Status Banner 使用 Material `ColorScheme` 與 `DsSemanticColors`，支援 optional icon、message、action 與可辨識 Semantics。
- 新增 `DsConstrainedContent`，預設 max width 640、置中與 `DsSpace.lg` padding，並允許 consumer 明確覆寫。
- 新增 `DsButtonContent`，只負責 Material Button 內部 idle / loading presentation 與 progress Semantics。
- callback、disabled 與 button variant 仍由 `FilledButton`、`OutlinedButton`、`TextButton` 等 Material widgets 負責。
- Widget tests 驗證 Default / Ocean × Light / Dark、action callback、disabled/loading、長文字與窄 viewport。
- Milestone 15-5 不建立 Loading / Empty / Blocking Error page state；其屬於 Milestone 15-6。

後續已於 Milestone 15-6 完成 Page State Surfaces。

### Milestone 15-6：Page State Surfaces

狀態：Completed。

- [x] 建立 Loading、Empty、Blocking Error 與 Generic Message page state surfaces。
- [x] Page state 支援 title、message、Widget icon slot、primary action 與必要 secondary action。
- [x] Blocking error 與 non-blocking error 分離；Refresh、Append、Revalidation failure 不自動提升為全頁 error。
- [x] Shared layout 使用 viewport-aware min height 與 scrollable content，不使用固定高度推動 empty state。
- [x] Loading indicator、Error 與 Retry 提供可辨識 Semantics；Banner contract 已由 Milestone 15-5 提供。
- [x] 驗證 text scaling 1.0、1.3、2.0 與 320px 窄 viewport 不裁切主要內容。

完成實作：

- 新增 typed `DsPageStateAction`，將 action label 與 callback 組成不可分割的 presentation contract。
- 新增 `DsLoadingState`、`DsEmptyState`、`DsBlockingErrorState` 與 `DsMessageState`。
- Empty、Blocking Error 與 Message surfaces 支援真正的 Widget icon slot；未提供時使用 Design System default icon。
- Package internal `_DsPageStateLayout` 統一 max width、page padding、viewport-aware centering、scrolling 與 action Wrap layout。
- Blocking Error 提供 error Semantics；Loading indicator 可指定獨立 progress Semantics label。
- Widget tests 驗證 Default / Ocean × Light / Dark、primary / secondary callbacks、custom icon slot、Error / Retry Semantics，以及 1.0 / 1.3 / 2.0 text scaling。

後續已於 Milestone 15-7 完成 Theme Preference、Persistence 與 Selector UI。

### Milestone 15-7：Theme Preference、Persistence 與 Selector UI

狀態：Completed。

- [x] App 定義 Theme preference，分別保存 Theme ID 與 mode。
- [x] Mode 支援 `system`、`light`、`dark`。
- [x] 使用單一 versioned JSON，storage key 為 `app.theme.preference`。
- [x] Version 1 明確保存 `version`、`themeId` 與 `mode`。
- [x] 未知 Theme ID fallback 至 Default Theme；未知 mode fallback 至 System。
- [x] 資料不存在、JSON 損壞或未知 version 時，整體 fallback 至 Default Theme + System mode。
- [x] 未知 Theme ID 或 mode 採欄位級 fallback，保留另一個合法欄位。
- [x] Theme 切換先更新 runtime，再非同步持久化；寫入失敗不回滾 runtime Theme，只暴露 non-blocking persistence failure。
- [x] Theme preference writes 使用單一序列化 queue，且每次保存完整 snapshot，保證 latest preference wins。
- [x] 前一次 persistence write failure 不阻止後續較新 preference 繼續寫入。
- [x] App Composition Root 組裝 Theme registry、store 與 controller；Design System package 不自行註冊 DI。
- [x] Bootstrap 在 `runApp` 前 restore preference，避免啟動後 Theme 明顯閃爍。
- [x] Storage read exception 時使用 Default Theme + System 啟動，暴露 non-blocking diagnostic，不阻止 `runApp`，也不自動寫回 fallback。
- [x] `MaterialApp.router` 使用選中 Theme definition 的 Light / Dark ThemeData 與 mode。
- [x] Appearance selector 放在 App-level theme presentation；Shell 只提供入口，不承擔 settings workflow。
- [x] 提供簡單 Appearance selector UI，可分別選擇 Theme Identity 與 mode；不建立完整 Settings feature。
- [x] 補上 persistence round-trip、unknown/corrupted value、removed theme fallback 與 selector wiring tests。
- [x] 補上 persistence write failure 不回滾 runtime Theme 的 controller test。
- [x] 補上快速連續 Theme / mode mutation 的 latest-write-wins tests。
- [x] 補上前一次 write failure 後較新 preference 仍可成功持久化的 test。
- [x] 補上 storage read exception fallback、diagnostic 與不自動寫回的 bootstrap tests。

完成實作：App-local `ThemePreference`、codec/store、`ThemeController`、bootstrap restore、MaterialApp wiring 與 Appearance selector；後續已於 Milestone 15-8 完成 Protected、Profile 與 Login 導入。

### Milestone 15-8：Protected、Profile 與 Login 導入

狀態：Completed。

- [x] ProtectedPage 導入 Typography、icon size 與 message state surface。
- [x] ProfilePage 導入 unauthenticated、loading、blocking error 與 content state surfaces。
- [x] LoginPage 導入 constrained content、Typography、spacing、InputDecorationTheme 與 loading button content。
- [x] 移除上述頁面的直接 `TextStyle(fontSize: ...)` 與重複 loading/error layout。
- [x] 驗證大型文字、鍵盤、窄畫面、Dark mode 與替代 Theme。
- [x] 保留 Auth、Profile、Logout 與 Route Guard 既有行為。
- [x] Profile 有既存內容時，登出進度與失敗保留 content surface，使用 non-blocking presentation。
- [x] 補上 Login / Profile presentation callback wiring tests。

完成實作：Protected 使用 `DsMessageState`；Profile 將 unauthenticated、loading、blocking error 與 content 映射至 Design System surfaces／constrained content；Login 導入 Theme InputDecoration、scrollable constrained form 與 `DsButtonContent`；後續已於 Milestone 15-9 完成 Catalog 與 Shell 導入。

### Milestone 15-9：Catalog 與 Shell 導入

狀態：Completed。

- [x] Catalog cache/stale notice 保留 feature-local composite，由其映射為 Design System Status Banner properties。
- [x] Catalog 導入 initial loading、empty、blocking error、append loading/failure 與 refresh/revalidation non-blocking surfaces。
- [x] Catalog Design System 導入不改變 Pagination、SWR、Refresh、Append、cursor chain 或 cache metadata contract。
- [x] 移除 Catalog empty state 固定 `SizedBox(height: 160)` layout。
- [x] Shell 驗證 AppBar、NavigationBar、icon 與 Appearance selector theme behavior。
- [x] 驗證替代 Theme Dark 與既有 Theme matrix contract 下核心頁面可正常 render。
- [x] Catalog empty surface 維持單一 scroll owner，並驗證 pull-to-refresh、窄畫面、2.0 text scaling 與長 refresh failure。

完成實作：Catalog 將 initial loading／empty／blocking failure 映射為 page-state surfaces，append、refresh、cache、stale 與 revalidation 保持 non-blocking；Shell chrome 抽為可測 `ShellScaffold`，未改變 AutoTabsRouter 或 Appearance／Protected routing；後續已於 Milestone 15-10 完成 regression、文件與完整驗證。

### Milestone 15-10：Regression、文件與完整驗證

狀態：Completed。

- [x] 搜尋並 review 殘留 `Colors.*`、直接 font size、固定 spacing、radius 與 elevation。
- [x] 確認合理的 feature-specific 數值不被錯誤提升為 global token。
- [x] 移除沒有穩定 consumer 的 token、ThemeExtension 或 generic component。
- [x] 補上必要的少量 stable golden fixtures，不替每個 feature page 建立高維護成本 golden matrix。
- [x] 回歸 Login、Profile、Logout、AuthGuard、Refresh Token、Catalog Pagination 與 Offline Cache。
- [x] 同步 README、Project Context、Architecture Decisions、Roadmap、Backlog、Changelog 與 package README。
- [x] 執行 dependency、generation、analyze、完整 tests 與 development / staging / production bundle builds。

完成實作：production Feature / App UI 已無 raw `Colors.*`、直接 `TextStyle`、直接 font size 或未語意化 spacing / radius / elevation；Theme factory 中的數值保留為 Typography contract。移除只被 token test 使用、尚無穩定 consumer 的 spacing、radius、elevation 與 icon-size token，保留已由 production UI 證明的最小集合。新增單一 Design System gallery golden fixture，並完成全 workspace regression 與三環境 bundle build。

### 完成定義

- `packages/design_system` 已加入 workspace，且不依賴 App、Feature、DI framework 或 persistence implementation。
- App 仍是唯一 Composition Root。
- Theme Identity 與 Theme Mode 有獨立 Single Source of Truth。
- 每套 Theme Identity 都提供 Light / Dark variants。
- System mode 只依系統 brightness 選擇 variant，不改變 Theme Identity。
- Default Theme 與第二套示範 Theme 均可在 Light / Dark 下正常使用。
- Theme ID 與 mode 可持久化、恢復，未知或損壞資料有安全 fallback。
- Feature 只使用 semantic roles、public tokens 與 primitive components，不直接使用 raw palette。
- Material component themes 優先，`ThemeExtension` 只補 Material contract 缺口。
- spacing、colors、Typography、Radius、Elevation 與 component states 有明確 contract。
- Blocking Loading / Empty / Error / Message 有共用 page state surfaces。
- Non-blocking error 保留 operation context，不錯誤提升為全頁 failure。
- Catalog-specific Cache / stale / revalidation 語意仍留在 Catalog feature。
- 主要 UI 在大型 text scaling、窄畫面、Light / Dark 與兩套 Theme 下不發生主要 overflow 或裁切。
- 原有 Auth、Profile、Route Guard、Pagination 與 Offline Cache regression 全部通過。
- analyze、test 與 development / staging / production build 全部通過。

---

## Milestone 16：Localization Foundation

使用 Flutter 官方 `gen_l10n` 建立 English 與繁體中文 `zh_TW` localization foundation，並加入 App-local locale preference、restore、persistence 與 runtime switching。

狀態：Completed；Milestone 16-1 至 16-7 已完成。

### Milestone 16-1：Architecture Contract、文字盤點與規劃 Review

狀態：Completed。

- [x] 盤點 production user-facing text、Tooltip、Semantics、Dialog、SnackBar、test fixture、diagnostic、server content 與 technical ID。
- [x] 拍板 App、Feature Presentation、Design System、Domain、Data、Repository、Theme metadata 與 formatting 責任。
- [x] 限制本 Milestone 不全面重構 Failure / Exception hierarchy。
- [x] Review state contract：Catalog 已保存 `Failure`；Auth / Profile 後續只做最小 stable identity 調整。
- [x] 拍板 `system / en / zh_TW` preference 與繁簡中文 resolution policy。
- [x] 拍板 `system` 使用 `MaterialApp.locale = null` + `localeListResolutionCallback`，LocaleController 不保存 resolved locale 或自行監聽平台 locale。

### Milestone 16-2：gen_l10n Skeleton 與 App Wiring

狀態：Completed。

- [x] 加入官方 `flutter_localizations`，在 App `pubspec.yaml` 啟用 `flutter.generate: true`，建立 `l10n.yaml`。
- [x] 建立 English template ARB、`zh_TW` ARB 與 generator 所需的 base `zh` fallback ARB；App supported locales 仍只公開 `en` 與 `zh_TW`。
- [x] 建立純 locale resolution callback，驗證 platform locale list 的 English、繁中、簡中與 unsupported fallback；此階段不依賴 preference model。
- [x] 設定 delegates、supported locales、`localeListResolutionCallback` 與 generated localization contract tests。
- [x] App title 使用 `onGenerateTitle`。
- [x] Design System 未新增 App localization dependency。

完成實作：App 已接上 generated `AppLocalizations`、delegates、`en / zh_TW` supported locales、明確 locale list resolution 與 localized App title。`zh_TW`、`zh_Hant`、`zh_HK`、`zh_MO` 解析為繁中；`zh_CN`、`zh_SG`、`zh_Hans` 與 unsupported locale fallback 至英文。Workspace analyze 與 App 完整 167 tests 已通過。

### Milestone 16-3：Locale Preference、Persistence 與 Bootstrap

狀態：Completed。

- [x] 建立 App-local `system / en / zh_TW` preference model與 Version 1 JSON storage，key 為 `app.locale.preference`。
- [x] 建立 runtime-first LocaleController 與 serialized write queue；read / write failure 採 non-blocking policy。
- [x] Bootstrap 在 `runApp` 前 restore preference，並重用 App Composition Root 已取得的 SharedPreferences instance。
- [x] `system` 對 `MaterialApp.router.locale` 提供 `null`；explicit preference 提供具體 Locale。
- [x] LocaleController 不保存 resolved system locale，也不自行實作 platform locale observer。
- [x] 加入 App-level locale selector 與 localized selector labels / tooltip；不抽象 Generic Preference Framework。
- [x] 驗證 round-trip、invalid payload fallback、read diagnostic、runtime-first、serialized writes、latest preference、write recovery 與 runtime locale rebuild。

完成實作：Locale preference 使用獨立 Version 1 JSON contract；`LocaleController` 先更新 runtime，再透過 serialized queue 保存完整 snapshot。Bootstrap 於 `runApp` 前 restore Theme 與 Locale controller；System preference 維持 `MaterialApp.locale = null`，English / `zh_TW` 使用 explicit locale。Shell 提供 App-level language selector 入口，selector 文案會隨 locale 即時重建。

### Milestone 16-4：Shell、Appearance 與 Theme Metadata Localization

狀態：Completed。

- [x] Localization Shell title、Navigation、Tooltip、Semantics、Appearance dialog、Theme mode 與 actions。
- [x] 使用 App-side Theme ID → localized display name mapping；Theme ID 與 persistence contract 不變。
- [x] 未知或外部 Theme 使用 Design System metadata fallback display name。
- [x] 補 English / `zh_TW` runtime switching widget tests。

完成實作：Shell AppBar title、Language / Appearance / Protected tooltips 與 Login / Catalog / Profile Navigation labels 已由 App ARB 提供；Appearance dialog 的 title、section labels、Theme mode labels、actions 與內建 Default / Ocean Theme display name 已 localization。Theme ID 仍維持 stable persistence identity，未知 Theme 不要求 App ARB key，直接使用 metadata fallback display name。App 完整 183 tests、analyze 與 bundle build 已通過。

### Milestone 16-5：Auth、Profile 與 Protected Localization

狀態：Completed。

- [x] Localization Login、Profile、Logout 與 Protected user-facing text。
- [x] Profile name 使用 ARB placeholder。
- [x] Auth / Profile Bloc 不再以 `error.toString()` / `String? errorMessage` 作為 user-facing contract，只做最小 state 調整保留 `Failure` 與 operation context。
- [x] Login / Logout / Profile failure 使用 feature-local localized mapping 與 unknown fallback；目前只有可安全判定未授權的 `401` 進行特定 UX 映射，`403` 與其他 code 使用操作專屬 fallback。
- [x] 修正 Core `Failure.message` / mapper 註解與 Repository 固定語言 fallback contract。
- [x] 不全面重構 `Failure`、`AppException`、`Result` 或 Repository hierarchy。

完成實作：Login、Profile、Logout 與 Protected 固定文案已進 App ARB；Profile name 使用 generated placeholder API。Auth / Profile state 保存 `Failure + operation`，Presentation 依 stable code 與操作建立 feature-local localized copy，unknown code 使用操作專屬 generic fallback，diagnostic `Failure.message` 不直接顯示。Core 與 Repository contract 已同步修正，未建立全域 error taxonomy 或 generic mapper。

### Milestone 16-6：Catalog Localization、Failure Mapping 與 Date Formatting

狀態：Completed。

- [x] Localization Search、Loading、Empty、Blocking Error、Append、Refresh、Cache、Stale 與 Revalidation UI。
- [x] Catalog failure 使用 feature-local localized mapping與 unknown fallback；`408 / 429` 進行語意明確的特定映射，其餘依 surface fallback。
- [x] 加入直接使用的 `intl` dependency；`lastUpdatedAt` 轉為 local time 後依目前 locale 的日期與時間慣例格式化。
- [x] Cache timestamp 與 Data / Domain UTC contract 不變；server item content 不進 ARB。
- [x] 保留 Pagination、SWR、Refresh、Append、cursor chain 與 Offline Cache regression。

完成實作：Catalog search、initial loading / failure、empty、append、refresh、cached / stale、background revalidation 與 Semantics 文案已移入 App ARB。Catalog Presentation 依 initial / refresh / append / revalidation surface 將 `Failure` 映射為 localized copy，`Failure.message` 不直接顯示；HTTP `408 / 429` 使用安全的 timeout / rate-limit 文案，其餘使用 surface-specific fallback。`lastUpdatedAt` 僅在 Presentation 先 `toLocal()` 再以 `intl` 與目前 locale 的日期與時間慣例格式化，不強制固定 12 或 24 小時制；Cache、Domain 與 Data UTC contract、item name / description、cursor 與 SWR lifecycle 均未改變。

### Milestone 16-7：Production Text Audit、Regression、文件與完整驗證

- [x] 再次盤點 hard-coded production text、Tooltip、Semantics、Dialog、SnackBar、Navigation 與 page-state surfaces。
- [x] 確認 Domain、Data、Repository、exception、log、technical ID 與 server content 未被誤 localization。
- [x] 確認 Design System 不依賴 App generated localization；移除 `DsButtonContent` 內建英文 progress semantics fallback。
- [x] 採分層 Theme × Locale 測試矩陣，避免完整笛卡兒積。
- [x] 同步 README、Project Context、Architecture Decisions、Roadmap、Backlog 與 CHANGELOG。
- [x] 執行 dependency、generation、analyze、完整 tests 與 development / staging / production bundle builds。

完成實作：Production text audit 已覆蓋 App chrome、Feature Presentation、Tooltip、Semantics、Dialog、Navigation、page-state surfaces 與 user-facing failure path；Domain、Data、Repository、exception、log、technical ID、server content 與 Design System dependency boundary 均維持原責任。`DsButtonContent` 不再自行拼接固定英文 semantics，未提供專用 progress label 時只重用呼叫方已 localized 的 label。測試採 Theme render matrix、English / `zh_TW` runtime switching、Feature-local localization 與既有 business regression 分層驗證，未建立完整 Theme × Locale 笛卡兒積。

### 完成定義

- App 使用官方 `gen_l10n`，支援 English 與 `zh_TW`。
- Locale preference 可 restore、persist、runtime switch；system mode 可自然跟隨 platform locale list。
- System resolution 不會將 `zh_CN` / `zh_Hans` 錯誤映射為繁體中文。
- Design System 只接收已 localized presentation text。
- Theme ID 穩定，內建 Theme display name 由 App localization。
- 固定 UI 文案、Tooltip、Semantics、Navigation、Loading／Empty／Error／Message 已進 ARB。
- User-facing failure 不再直接顯示 diagnostic `Failure.message`；Auth / Profile 可取得 stable failure identity。
- 日期顯示 locale-aware，Data / Cache timestamp 維持 UTC。
- 本 Milestone 未擴張為全域 Failure / Exception 重構或 Generic Preference Framework。
- analyze、test 與三環境 bundle build 全部通過。

---

## Milestone 17：Exception & Failure Architecture

整理全專案 Exception / Failure 系統，建立 typed、可追蹤、保留 stack trace、區分 expected failure 與 programming error，且不讓敏感資料進入 diagnostic 的錯誤架構。

狀態：In Progress；Milestone 17-1 至 17-4 已完成。

核心流程：

```txt
Infrastructure / Transport Exception
  ↓ DataSource typed mapping
AppException
  ↓ Repository operation mapping
Failure
  ↓ Result / Bloc
Feature Presentation localized message

Unexpected error
  ↓ 保留 error + stack trace
Framework / Bloc / App reporting boundary
```

限制：

- App 仍是唯一 Composition Root。
- 不建立 `GlobalErrorHandler.handleEverything()`。
- 不建立過度抽象的 Generic Exception / Failure Mapper framework。
- 不為每個 HTTP status 建立 class。
- 不把所有 backend business code 做成全域 enum。
- Feature Presentation 繼續負責 localized user-facing copy。
- Unknown programming error 不可被吞掉或轉成普通 Failure。
- 不破壞 Auth Session、Concurrent 401、Pagination、SWR、Offline Cache 與既有 regression。

### Milestone 17-1：Exception / Failure 現況 Audit 與 Architecture Contract

狀態：Completed；只完成 audit、Decision 020 與正式規劃，未修改 production code。

- [x] 盤點 production source 的 `throw`、`rethrow`、`catch`、`on ... catch` 與 `Error.throwWithStackTrace`。
- [x] 盤點 `AppException`、`Failure`、`FailureResult`、`Result` 定義、建立點與 mapping。
- [x] 盤點 `error.toString()`、`.message`、HTTP status 與 error code 判斷。
- [x] 盤點 Dio、backend response、SharedPreferences、SQLite、serialization、cache corruption 與 preference fallback。
- [x] 盤點 Refresh Token、Concurrent 401、Session generation、session expired、temporarily unavailable 與 localStateFailure。
- [x] 盤點 Catalog cursor protocol、pagination、SWR、refresh、append 與 revalidation failure。
- [x] 確認 CatalogBloc 已保留 unknown Stream error stack trace；Auth / Profile Bloc 仍可能將非 Failure 降級。
- [x] 確認 Refresh subsystem 與 interceptor 存在吞掉 unknown error 的 `catch (_)` 路徑。
- [x] 確認 App 尚無 Flutter / Platform / Bloc 統一 reporting adapter boundary。
- [x] 拍板 expected operational failure、unexpected error、cancellation、protocol violation 與 session lifecycle result 的分類規則。
- [x] 拍板 retryability、session clearing、cache fallback、reporting 與 sensitive data contract。
- [x] 新增 Architecture Decision 020。

Audit 關鍵發現：

- Critical：`FailureResult.error` 是 `Object`，expected failure channel 沒有型別保證。
- Critical：Auth / Profile Bloc 使用 `error.toString()` fallback，可能把 programming error 轉成普通 Failure。
- Critical：AuthSessionRefresher / AuthRefreshInterceptor 的廣泛 catch 可能隱藏 stack trace與真正原因。
- Critical：目前沒有 Flutter framework、platform async、Bloc 與 non-fatal degraded-mode reporting entrypoint。
- Important：HTTP status、backend code、transport kind與 protocol identity 共用模糊 code。
- Important：一般 transport mapper 位於 `packages/api_client`，但 Auth Refresh data source 直接依賴 Dio 做 status 分類；17-3 / 17-4 需明確收斂此例外 boundary。
- Important：Theme / Locale preference Codec、Store 與 write queue 廣泛捕捉 `Object`；invalid payload 靜默 fallback，unknown error 可能被降級成 preference diagnostic。
- Important：AppException / Failure 的 `toString()` 會展開 cause，存在 sensitive data 風險。
- Important：Catalog Cache、Theme 與 Locale fallback policy 正確，但缺少 non-fatal reporting outlet。

### Milestone 17-2：Typed Result Failure Channel

狀態：Completed。

- [x] 將 `FailureResult<T>` 收斂為只接受 typed `Failure`。
- [x] 暫不建立 Failure subclass taxonomy；只先封閉 typed Failure channel。
- [x] 更新 `Result.when` failure callback type。
- [x] 移除 Auth / Profile Bloc 的 `error.toString()` fallback。
- [x] 補上 unknown error 不會降級為 Failure 的 Core / Bloc regression。
- [x] 保持 Milestone 16 feature-local localized failure mapping。

完成定義：任意 `Object` 無法進入 expected failure channel；Auth / Profile Bloc 只處理 `Failure`，unknown thrown error 保留 framework error flow；localized mapping 與 feature operation context 不變。

完成實作：`FailureResult<T>` 欄位已由 `Object error` 改為 `Failure failure`，`Result.when` failure callback 亦收斂為 `Failure`。Auth / Profile Bloc 已移除 `_asFailure(Object)` 與 `error.toString()` fallback；unexpected error 會先清除 loading state，再以原始 stack trace 重新拋出。Catalog Bloc 同步移除因 typed channel 而永遠不成立的 runtime type check。Core、Auth 與 Profile regression 驗證 unknown `StateError` 不會寫入 Failure state，並保留 Bloc framework error flow。Workspace analyze 與五個 package / app 完整 tests 全部通過。

### Milestone 17-3：Typed AppException 與 Transport / Backend Boundary

狀態：Completed。

- [x] 建立最小 AppException taxonomy與 safe diagnostic context。
- [x] 依 typed AppException identity 同步建立最小 shared Failure taxonomy，不建立 operation-specific class 笛卡兒積。
- [x] 分離 transport kind、HTTP status、backend code 與 diagnostic code。
- [x] 保留原始 stack trace；非已知第三方 operational exception 原樣拋出。
- [x] 收斂一般 Dio mapping、malformed success response與 cancellation identity contract。
- [x] 不為每個 HTTP status 建 class，不建立全域 backend code enum。
- [x] 補 sensitive request query / cause 不進 exception diagnostic 的 tests。

完成實作：Core 新增 `AppExceptionKind`、`TransportExceptionKind` 與 `FailureKind`；`AppException` / `Failure` 分離 `httpStatus`、`backendCode`、`diagnosticCode` 並保存 stack trace。`code` 僅保留為相容 constructor / getter，新 production HTTP 判斷已改用 `httpStatus`。api_client 將 Dio type 映射為 Core-owned enum、只保存 URI path 不保存 query，且 unknown error 原樣拋出。Auth local storage、Catalog protocol / corruption建立點已補 typed identity；Auth Refresh 的 lifecycle mapping仍留待 17-4。Workspace analyze 與五個 package / app 完整 tests 全部通過。

### Milestone 17-4：Auth Local State 與 Session Lifecycle

狀態：Completed。

- [x] 收窄 Auth Repository、AuthSessionRefresher與 AuthRefreshInterceptor 的 catch。
- [x] `localStateFailure` 只由 typed local operational exception 產生；read storage failure 保留 Session，save storage failure清除 Session。
- [x] Auth Refresh remote boundary 使用 typed transport identity；401 / 403 視為 session expired，其餘 transport / HTTP / malformed response 視為 temporary unavailable，TypeError / unknown error 原樣拋出。
- [x] unknown refresh / replay error保留原始 error與 stack trace，不再降級成原始 401；Reporting integration留待 17-6。
- [x] 修訂目前將 unknown local error 鎖定為 `localStateFailure`、將 refresher `StateError` 鎖定為原始 401 的既有 regression tests。
- [x] 集中 Auth subsystem 的 session clearing contract，不建立 global handler。
- [x] 保留 concurrent 401 single-flight、generation / userId identity與 safe replay。
- [x] 驗證 401 / 403、timeout、5xx、storage failure、cleanup failure與 unknown error。

17-4A 完成實作：`AuthSessionRefresher` 只將 `AppExceptionKind.localStorage` 視為 expected local operational failure。讀取 Token Pair 的已知 storage failure 回傳 `localStateFailure` 但不清除 Session；保存 rotated Token Pair 的已知 storage failure執行 best-effort cleanup並清除 Session。unknown read / save error 保留原始 error與 stack trace重新拋出，不再降級、不再登出。Auth targeted 19 tests與 package analyze通過。

17-4B 完成實作：api_client 新增可重用的 `mapDioException` typed mapper，Auth Refresh RemoteDataSource 不再自行直接依 Dio status建立模糊例外。401 / 403 轉為 invalid refresh credential；400 / 408 / 429 / 5xx、connection / send / receive timeout、connection error與 bad certificate轉為 temporary unavailable且不清 Session。空 token與 FormatException以 protocol diagnostic表示；TypeError / unknown error原樣拋出。Auth Refresh targeted 27 tests、api_client smoke tests與兩個 package analyze通過。

17-4C 完成實作：`AuthRefreshInterceptor` 對 expected non-success lifecycle result仍保留原始 401且不 replay；unexpected refresher與 replay error改以 `DioExceptionType.unknown` 傳遞，`error` 保留原始物件、`stackTrace` 保留來源，不再偽裝成第一次 401。新增兩條 regression，api_client完整 42 tests與 analyze通過。

17-4D 完成實作與驗證：AuthRepository Login保留 remote / local typed AppException mapping；Restore與Logout只消化 `AppExceptionKind.localStorage`，其他 typed identity與 unknown error保留原始 stack重新拋出。Restore local storage failure不清 runtime Session；Logout無論第一個 cleanup為 known或unknown error，都繼續第二個 cleanup並清除 runtime Session。正式review revision補強多重cleanup failure優先級：unexpected / non-localStorage error優先於expected localStorage failure，避免programming error被降級掩蓋。Auth targeted 41 tests、workspace analyze與五個 package / app完整 tests全部通過。剩餘 broad catch只存在明確 best-effort cleanup helper，non-fatal reporting留待17-6。

### Milestone 17-5：Catalog Protocol / Cache Failure Contract

狀態：Completed；17-5A 至 17-5E 已完成。

- [x] 區分 cache unavailable、corruption、transaction failure與 unknown implementation error。
- [x] 建立 external protocol violation identity，保留 internal invariant error channel。
- [x] 為 non-blocking cache read / write / cleanup failure準備安全、reporting-ready diagnostic；實際 ErrorReporter wiring留待17-6。
- [x] 保持 initial / refresh / append / revalidation operation context與 localized mapping。
- [x] 不建立 Generic Cache / Pagination failure framework。
- [x] 完整驗證 cursor chain、chain revision、SWR、refresh、append與 revalidation regression。

17-5A 已完成：`CatalogLocalDataSource` 的 SQLite boundary 已收窄。只有 `DatabaseException` 會映射為 `AppExceptionKind.localStorage`；persisted row 的欄位型別、cursor、item 與 position corruption 會透過狹窄 corruption path刪除受影響 page並視為 Cache miss。未知 `TypeError` / `StateError` 不再被降級成 localStorage或 corruption。Local API misuse（空 cursor、非法 limit、非第一頁 chain reset、Append缺少 cursor、寫入 page invariant）改為 `ArgumentError` / `StateError` fail fast。Local targeted 20 tests、Catalog Repository / Data layer 33 tests與 App analyze通過。

17-5B 已完成：`CatalogRepositoryImpl` 的 Cache read、linked chain revision與 Cache write只吸收 `AppExceptionKind.localStorage`，維持可重建 read-model 的 non-blocking fallback。`dataCorruption`、`protocol`與其他 typed AppException不再被降級成 Cache miss、null revision或 Remote success；unknown error維持 Stream error channel。Remote expected failure mapping與 Cache side-effect已拆成兩個階段，避免 Cache contract error被外層 Remote AppException catch轉成普通 Failure。Catalog Repository / Data layer targeted 37 tests與 App analyze通過。

17-5C 已完成：Catalog external protocol、persisted corruption與internal invariant identity已收斂。Malformed Remote item與non-advancing Remote cursor使用 `AppExceptionKind.protocol + diagnosticCode`並保存 stack trace；Bloc偵測跨頁cursor cycle時建立 `FailureKind.protocol + cyclic_catalog_cursor`。Local API misuse維持 `ArgumentError` / `StateError` programming error channel，不進 expected Failure。Catalog Data / Repository / Bloc targeted 69 tests與 App analyze通過。

17-5D 已完成：新增 feature-local `CatalogCacheFailureDetails` 與 `CatalogCacheOperation`，為 Cache read、first-page write、page write、append write、chain revision read、delete、corruption cleanup與expired cleanup建立安全 operation identity。Diagnostic只保存 query是否為空、cursor是否存在與limit，不保存query、cursor token、item、SQL或raw row；原始SQLite error identity保留於details但 `toString()` 不展開。實際 non-fatal reporter與Composition Root wiring留待17-6。Catalog Data / Repository targeted 58 tests與 App analyze通過。

17-5E 已完成：Catalog LocalDataSource、Repository、Data mapper、Bloc、Widget與Refresh targeted 107 tests全部通過；workspace五個package analyze全數通過。完整tests結果為 api_client 42、auth 41、core 4、design_system 43、flutter_architecture 203，合計333 tests。Fresh / stale / expired、future timestamp、Cache read/write fallback、corruption repair、unknown error channel、Remote protocol、cursor chain、chain revision CAS、Refresh重用cursor、stale Append late-write、SWR、Refresh / Append emission、query switching、cancellation、localized UI與Logout保留public Cache均無回歸。Milestone 17-5正式完成。

正式review revision已完成：所有cursor-chain persisted欄位改用狹窄parser。第一頁舊revision損壞時會在同一transaction清除相同query / limit chain並以revision 1重建；linked revision與Append traversal遇到revision或next cursor corruption時會清除同chain，回傳null / false，不讓private corruption sentinel或TypeError逃出Local boundary。新增四組regression，Catalog Local / Repository / Data targeted 62 tests與App analyze通過。

### Milestone 17-6：App Uncaught Error 與 Reporting Adapter

狀態：Planned。

- [ ] 建立不依賴 App localization 的狹窄 `ErrorReporter` abstraction。
- [ ] 收窄 Theme / Locale preference Codec、Store 與 serialized write queue 的 catch boundary，區分 recoverable persisted corruption、expected storage failure 與 unexpected programming error。
- [ ] invalid preference payload fallback 保留安全 non-fatal diagnostic；前一筆 expected write failure 可由 queue 吸收以繼續最新寫入，但 unknown error 不得被吞掉。
- [ ] 由 App Composition Root 組裝 Debug / Test / Crashlytics-compatible adapter。
- [ ] 接上 `FlutterError.onError`、`PlatformDispatcher.instance.onError` 與 `BlocObserver.onError`。
- [ ] 區分 fatal uncaught、unexpected Bloc error與 important non-fatal degraded operation。
- [ ] Crashlytics implementation 不進可重用 package；是否加入 Firebase dependency於 implementation review 決定。
- [ ] 驗證 stack trace、context sanitization與 duplicate reporting policy。

### Milestone 17-7：Sensitive Data Audit、Regression、文件與完整驗證

狀態：Planned。

- [ ] Audit exception、failure、cause、context、log 與 `toString()`。
- [ ] 確認 password、token、Authorization、Cookie、raw body、raw storage payload與敏感 query 不進 diagnostic。
- [ ] 完成 Auth、Profile、Catalog、Theme、Locale、Route Guard 與 Composition Root regression。
- [ ] 同步 README、Project Context、Architecture Decisions、Roadmap、Backlog 與 CHANGELOG。
- [ ] 執行 dependency、generation、analyze、完整 tests 與 development / staging / production bundle builds。

### Milestone 17 完成定義

- Expected operational failure 使用 typed AppException → typed Failure → Result。
- Unknown programming / system error 不被吞掉、不轉普通 Failure，且保留 stack trace。
- Cancellation、external protocol violation、internal invariant與 session lifecycle result 有明確分類。
- Feature operation context 與 shared failure identity 維持分離。
- Retry、session clearing、cache fallback與 reporting owner 明確。
- App 是唯一 reporting Composition Root，packages不直接依賴 Crashlytics或 App localization。
- Sensitive data 不進 exception、failure、cause、log或 `toString()`。
- Auth Session、Concurrent 401、Pagination、SWR、Offline Cache與 Localization regression 全部通過。
- analyze、test與 development / staging / production build全部通過。
