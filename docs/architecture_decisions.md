# Architecture Decisions

本文件記錄目前已拍板的架構決策。

如果某個決策已標記為 Accepted，後續不應反覆重新討論，除非出現新的需求、限制或實作問題。

---

## Decision 001：使用 Clean Architecture + Feature First

**狀態：** Accepted

### 背景

本專案目標是建立中大型 Flutter 專案模板。

單純 layer-first 容易讓 feature 邊界分散；單純 feature-first 又容易忽略依賴方向。

### 決策

使用：

```txt
Feature First folder structure
Clean Architecture dependency rule
```

Feature 內部維持：

```txt
presentation
  ↓
domain
  ↓
data
```

### 原因

Feature First 讓功能邊界清楚。

Clean Architecture 讓依賴方向穩定。

### 影響

每個 feature 內都會有 presentation / domain / data。

但跨 feature 共用能力可以提升到 packages。

---

## Decision 002：使用 Monorepo + Melos

**狀態：** Accepted

### 背景

本專案需要同時管理 app 與多個 package。

### 決策

使用：

```txt
root/
  apps/
  packages/
```

並透過 Melos 管理 workspace。

### 原因

Monorepo 能讓共用能力獨立成 package，同時保持本地開發方便。

### 影響

根目錄需要 root `pubspec.yaml` 管理 Dart Pub Workspaces 與 Melos 8 設定。

`melos.yaml` 只保留遷移提示，不再作為主要設定來源。

workspace package 需要在各自 `pubspec.yaml` 加上：

```yaml
resolution: workspace
```

Melos 指令統一使用：

```bash
dart run melos ...
```

避免依賴全域安裝的 melos。

`build_runner` 需要依 dependency graph 順序執行，避免乾淨 workspace 下游 package 早於上游 generated files 完成：

```bash
dart run melos exec --depends-on=build_runner --order-dependents --concurrency=1 -- dart run build_runner build
```

---

## Decision 003：Presentation 使用 flutter_bloc + flutter_hooks + hooked_bloc

**狀態：** Accepted

### 背景

Bloc 適合表達明確的業務狀態流，但傳統 BlocBuilder / BlocListener 容易產生巢狀。

### 決策

使用：

- flutter_bloc：業務狀態管理。
- flutter_hooks：UI 暫態，例如 TextEditingController。
- hooked_bloc：降低 BlocBuilder / BlocListener 巢狀。

### 原因

Bloc 負責業務狀態。

Hooks 負責 UI-local state。

hooked_bloc 負責讓 UI 讀取 Bloc 更簡潔。

### 影響

UI 可以使用：

```dart
final bloc = useBloc<AuthBloc>();
final state = useBlocBuilder(bloc);
```

但這不代表可以跨 feature 任意讀取對方 Bloc。

---

## Decision 004：使用 get_it + injectable

**狀態：** Accepted

### 背景

Clean Architecture 會產生大量依賴：Bloc、UseCase、Repository、DataSource、ApiClient、Database、Storage。

### 決策

使用：

- get_it 作為 DI container。
- injectable 產生註冊程式碼。

### 原因

手寫所有 DI 註冊容易膨脹且容易漏。

injectable 可以讓依賴註冊更穩定。

### 影響

第三方物件，例如 SharedPreferences、Database、Dio，透過 module 註冊。

---

## Decision 005：Auth domain / data 移動到 packages/auth

**狀態：** Accepted

### 背景

Auth 不是單一頁面的功能。

登入狀態、token、session、restore session、logout 都是跨整個 App 的共用能力。

### 決策

長期架構應調整為：

```txt
packages/auth
  domain
  data
  session

apps/flutter_architecture/lib/features/auth
  presentation
```

### 原因

Auth 的 domain / data 被多個 feature 使用，不應綁在 app 內某個 feature presentation 旁邊。

### 影響

AuthBloc 仍在 app 的 presentation layer。

LoginUseCase、LogoutUseCase、RestoreSessionUseCase、AuthRepository、AuthRepositoryImpl、AuthLocalDataSource、AuthRemoteDataSource 後續移到 packages/auth。

---

## Decision 006：AuthGuard 不依賴 AuthBloc

**狀態：** Accepted

### 背景

目前 AuthGuard 依賴 AuthBloc 可以運作，但 AuthGuard 真正需要的是「是否已登入」。

AuthBloc 是 Auth feature 的 presentation detail。

### 決策

AuthGuard 後續改依賴：

```txt
SessionManager / AuthSessionReader
```

不要依賴：

```txt
AuthBloc
```

### 原因

Route Guard 屬於 app router 邏輯，不應依賴某個 feature 的 UI 狀態管理實作。

### 影響

未來如果 AuthBloc 改成 Cubit / Riverpod / 其他狀態管理，AuthGuard 不需要改。

---

## Decision 007：跨 Feature 不直接依賴對方 Bloc

**狀態：** Accepted

### 背景

ProfilePage 目前可透過 AuthBloc 得知登入狀態，但這會讓 profile feature 依賴 auth feature 的 presentation layer。

### 決策

ProfilePage 不直接讀 AuthBloc。

跨 feature 登入狀態應透過：

- SessionManager
- Repository interface
- UseCase
- Domain abstraction

### 原因

Bloc 是某個 feature 的 presentation detail。

跨 feature 溝通應依賴更穩定的 domain 或 application service。

### 影響

ProfilePage 只依賴 ProfileBloc。

ProfileBloc / UseCase 負責判斷未登入、取得 Profile、回傳 UI state。

---

## Decision 008：一個 UseCase 對應一個業務行為

**狀態：** Accepted

### 背景

Auth 目前有 login、logout、restore session 三個行為。

可以合併成 AuthUseCase，也可以拆成三個 UseCase。

### 決策

維持拆分：

```txt
LoginUseCase
LogoutUseCase
RestoreSessionUseCase
```

不要合成：

```txt
AuthUseCase
```

### 原因

UseCase 表示一個明確業務行為，不是功能分類。

AuthUseCase 容易膨脹成 AuthService。

### 影響

檔案較多，但職責更清楚。

---

## Decision 009：文件與註解預設使用繁體中文

**狀態：** Accepted

### 背景

本專案主要面向中文使用者與學習者。

### 決策

文件、README、註解使用繁體中文。

技術名詞、套件名稱、類別名稱保留英文。

### 原因

降低閱讀成本，同時保持業界常用術語。

### 影響

不得混用簡體中文。

專有名詞不強行翻譯。

---

## Decision 010：跨平台 SQLite 初始化使用條件匯入

**狀態：** Accepted

### 背景

sqflite 在不同平台初始化方式不同。

Web 與 Desktop 若未初始化 databaseFactory，會出現錯誤。

### 決策

使用條件匯入：

```txt
Mobile
  sqflite 原生

Desktop
  sqflite_common_ffi

Web
  sqflite_common_ffi_web
```

### 原因

main.dart 不應直接 import dart:io，否則 Web 編譯不安全。

平台差異應隔離在 database initializer。

### 影響

Web 首次需要執行：

```bash
dart run sqflite_common_ffi_web:setup
```

---

## Decision 011：專案文件是 Single Source of Truth

**狀態：** Accepted

### 背景

ChatGPT 對話會變長，也不適合作為長期專案記憶。

### 決策

專案狀態與架構決策必須沉澱到文件。

關鍵文件：

```txt
AGENTS.md
README.md
CHANGELOG.md
VERSION
docs/project_context.md
docs/architecture_decisions.md
docs/roadmap.md
docs/conversation_rules.md
docs/archive/progress_v1.0.0.md
```

### 原因

新對話、新成員或未來的自己，都應該透過文件恢復上下文。

### 影響

如果架構決策改變，先更新 architecture_decisions.md，再改程式。

---

## Decision 012：可重用 package 不直接綁定 DI framework

**狀態：** Accepted

### 背景

本專案的 `packages/auth`、`packages/api_client`、`packages/core` 是可被 App 重用的能力邊界。

若 package 內直接標註 `@injectable`、`@lazySingleton` 或依賴 `get_it` / `injectable`，會讓 package 同時負責提供能力與決定組裝方式，造成 Composition Root 分散。

### 決策

可重用 package 預設不直接依賴 DI framework。

package 內 class 使用 constructor injection 表達自身依賴，但不宣告 DI lifecycle。

App 專案負責 Composition Root，統一在 app 的 DI module 決定：

```txt
factory
lazySingleton
singleton
第三方物件初始化
介面與實作綁定
```

### 原因

package 應提供能力，不應決定自己在某個 App 裡如何被建立、共用或替換。

把 DI lifecycle 集中在 App 可以讓：

- package 更容易被不同 App 重用。
- package 不綁定特定 DI framework。
- 測試與替換 fake / mock 更直接。
- 專案只有一個清楚的 Composition Root。

### 影響

`packages/auth` 不再使用 `injectable` annotation，也不再依賴 `injectable` package。

Auth 相關 data source、repository、use case、session 物件仍由 `apps/flutter_architecture/lib/app/di/register_module.dart` 註冊與組裝。

---

## Decision 013：所有真實 HTTP API 統一使用 Retrofit

**狀態：** Accepted

### 背景

目前 `packages/api_client` 已使用 Dio，並以手寫方式建立 API client。

隨著 API 數量增加，如果每個 endpoint 都自行處理 request method、path、query、body、response parsing 與錯誤轉送，容易出現重複程式碼與不一致的實作方式。

本專案需要一套統一、可預期且方便 code generation 的 HTTP API 宣告方式，同時維持 Mock API 的彈性。

### 決策

所有真實 HTTP API 必須透過 Retrofit 宣告與產生實作。

一般 feature、repository、data source 不直接呼叫：

```dart
dio.get(...)
dio.post(...)
dio.put(...)
dio.delete(...)
```

Dio 保留作為底層 transport，負責：

- BaseOptions。
- Timeout。
- Interceptor。
- Authorization header。
- Request / response transport。
- Retrofit 無法合理表達的少數底層能力。

Mock API 可以手寫，但 Mock 與 Retrofit implementation 必須遵守相同的 API abstraction，並由 App Composition Root 決定使用哪一個 implementation。

Retrofit abstract class 本身同時作為 API abstraction 與真實 HTTP implementation 的宣告來源，不額外建立只有轉呼叫責任的 `RetrofitXxxApi` adapter。

建議結構：

```txt
AuthApi
  ├── _AuthApi（Retrofit generated implementation）
  └── MockAuthApi（手寫 mock implementation）
```

### DTO 與 Mapper 邊界

Retrofit 只負責：

```txt
HTTP JSON
  ↓
DTO
```

DTO 仍需明確定義，並透過 Freezed / json_serializable 處理 JSON serialization。

DTO 不等於 Domain Entity。

DTO 到 Domain Entity 的 Mapper 保留在使用該 DTO 的 data layer，例如：

```txt
packages/auth/lib/src/data/mappers/
```

`packages/api_client` 不依賴 `packages/auth` 的 Domain Model。

Mapper 只負責純資料轉換，不處理持久化、Session 更新或流程協調；Repository implementation 仍負責上述副作用與資料來源協調。

### RemoteDataSource 與錯誤邊界

RemoteDataSource 保留作為 Data Layer 的遠端資料來源邊界，責任包括：

- 建立 request DTO。
- 呼叫 API abstraction。
- 必要時協調同一外部系統的多個 endpoint。
- 將 `DioException` 等 transport exception 映射為 `AppException`。

Repository implementation 再將 Data Layer exception 映射為 Domain 可接受的 `Failure`。

錯誤依賴流維持：

```txt
DioException
  ↓ RemoteDataSource
AppException
  ↓ RepositoryImpl
Failure
  ↓ UseCase / Result<T>
```

### 命名規則

API model 使用：

```txt
XxxRequestDto
XxxResponseDto
XxxDto
```

Domain Model 使用不帶 `Dto` 的業務名稱。

### 認證 Request

需要登入的 Retrofit endpoint 透過 request extra metadata 標記，並由 `AuthHeaderInterceptor` 統一加入 Authorization header。

不在各個 API method 手動組合 token 或 header。

### 例外

若遇到 Retrofit 無法合理處理的特殊 transport 行為，例如特定大型檔案串流、底層下載進度或特殊 protocol bridge，可以在 `packages/api_client` 內建立封裝後的 Dio service，但不得讓 Dio 穿透 package boundary。

只有當例外做法會形成新的全域架構規則時，才需要新增 Architecture Decision；單一特殊 endpoint 只需在相關文件或程式碼中記錄原因。

### 影響

- `packages/api_client` 會提供 Retrofit API abstraction、generated implementation 與 Mock implementation。
- Mock implementation 放在明確的 `mocks/` 目錄，避免與真實 API declaration 混淆。
- 若正式產品不允許 runtime mock，可將 Mock implementation 移至 App development module 或獨立 test-support package。
- App Composition Root 負責依環境選擇 Mock 或 Retrofit implementation。
- 真實 API 不再以手寫 Dio request 作為一般實作方式。
- RemoteDataSource 只依賴 API abstraction，不知道底層是 Mock 或 Retrofit。
- Domain Layer 不依賴 Dio、Retrofit、JSON annotation 或 generated API client。

---

## Decision 014：App Configuration 與 Dart Environment Entrypoint

**狀態：** Accepted

### 背景

Milestone 9 已建立 `ApiConfig`、`ApiMode` 與 Mock / Retrofit implementation selection，但目前設定解析仍由 DI module 內部直接讀取 `String.fromEnvironment`。

專案目前只有 Dart / Flutter Web scaffold，尚未建立 Android、iOS、macOS、Windows 或 Linux platform scaffold，因此本階段不適合直接導入 Android productFlavors、iOS Schemes、applicationId、bundle identifier 或原生 App 名稱切換。

### 決策

Milestone 10 只建立 App Configuration 與 Dart-level environment entrypoint 基礎，不建立 Native Flavor。

環境模型分為兩個不同概念：

```txt
AppEnvironment
  development
  staging
  production

ApiMode
  mock
  real
```

`AppEnvironment` 表示部署環境；`ApiMode` 表示 API implementation selection，兩者不得合併成同一個 enum。

Dart entrypoint 是 `AppEnvironment` 的唯一來源：

```txt
main.dart
main_development.dart
main_staging.dart
main_production.dart
```

各 entrypoint 只決定 `AppEnvironment`，並進入共用 `bootstrap`。不另外使用 `APP_ENV` dart-define，避免 entrypoint 與 `--dart-define` 出現互相衝突的 environment source of truth。

`--dart-define` 只提供環境內可變設定，例如：

```txt
API_MODE
API_BASE_URL
```

所有 environment parsing 必須集中在 App bootstrap / Composition Root；可重用 package 不直接讀取 `String.fromEnvironment`。

設定模型採 typed configuration：

```txt
AppConfig
  environment: AppEnvironment
  api: ApiConfig

ApiConfig
  mode: ApiMode
  baseUri: Uri
```

`ApiConfig` 保留為 `AppConfig` 的子設定，但不自行讀取 dart-define。App bootstrap 先建立並驗證 `AppConfig`，再將其明確傳入 DI Composition Root。

合法組合定義為：

```txt
development + mock：允許
development + real：允許
staging + mock：不允許
staging + real：允許
production + mock：不允許
production + real：允許
```

Real API 規則：

- 必須明確提供 `API_BASE_URL`。
- 只允許 `http` 或 `https` scheme。
- production 必須使用 `https`。
- production 不允許 `mock.local`、localhost、loopback 或 `.invalid` URL。
- 未知 `API_MODE` 或不合法設定直接 fail fast，不可靜默退回 development 或 mock。

### 非目標

Milestone 10 不包含：

- Android productFlavors。
- iOS Schemes / Build Configurations。
- applicationId / bundle identifier 切換。
- 原生 App 名稱或圖示切換。
- Signing configuration。
- Firebase configuration。
- Crashlytics / Analytics。
- CI/CD / GitHub Actions。
- dotenv、remote config 或 secrets management。
- 尚未存在的 network logger、debug tools 或 feature flag framework。

### 原因

先建立 Dart-level configuration boundary，可以讓後續 Refresh Token、Pagination、Offline Cache 與正式 API integration 都依賴同一個清楚的 Composition Root。

Native Flavor 需要平台 scaffold 與實際發布需求，若現在一併處理會讓 Milestone 範圍失控，也會引入大量與目前模板基礎無直接關係的原生檔案。

### 影響

- `main.dart` 預設使用 development，維持既有 IDE 與開發指令可直接執行。
- `main_development.dart`、`main_staging.dart`、`main_production.dart` 只負責指定環境。
- 共用 `bootstrap` 負責 Flutter binding、database initialization、AppConfig 建立、DI registration 與 `runApp`。
- `configureDependencies` 需要明確接收已完成驗證的 `AppConfig`，而不是由 DI module 自行讀取 dart-define。
- `ApiConfig.baseUrl` 後續調整為已驗證的 `Uri` 或等價 typed value，再於 transport boundary 轉成字串。
- 未來若加入 Android / iOS platform scaffold，Native Flavor 必須另行討論並新增或更新 Architecture Decision。

---

## Decision 015：Refresh Token 與 Concurrent 401 Handling 責任邊界

**狀態：** Accepted

**實作狀態：** Milestone 12 已完成。Main / Refresh Dio、identity-aware single-flight、Token Pair rotation、safe replay、Session invalidation、UI synchronization、regression tests、文件同步與完整環境建置驗證均已落地。

### 背景

Milestone 9 已建立 Retrofit API boundary、Dio transport、`AuthHeaderInterceptor`、`AuthTokenProvider`、Auth Repository 與 SessionManager。

目前登入流程只保存 access token，且 authenticated request 收到 401 時不會自動 refresh。

若直接把 refresh、token persistence、session invalidation、request replay 與 navigation 全部放進 Dio interceptor，會造成：

- `packages/api_client` 與 `packages/auth` 循環依賴。
- Interceptor 同時負責 transport、Auth application flow 與 UI 導航。
- 多個並行 401 重複呼叫 refresh endpoint。
- Refresh request 自己再次被攔截而形成無限 retry。
- Logout 後舊 refresh response 將 Session 復活。
- 舊帳號 refresh 覆蓋新帳號登入。
- 暫時性網路錯誤被誤判為 refresh token 無效並強制登出。
- 不可重播的 request body 被錯誤 replay。

因此 Refresh Token 與 concurrent 401 必須先建立清楚的 package、transport、persistence 與 runtime session 邊界。

### 決策

#### 1. AuthHeaderInterceptor 只負責加入 access token

`AuthHeaderInterceptor` 保持單一責任：

```txt
authenticated request
  ↓
AuthHeaderInterceptor
  ↓
讀取目前 access token
  ↓
加入 Authorization header
```

它不負責：

- 呼叫 refresh endpoint。
- single-flight 協調。
- request replay。
- 清除 Session。
- 操作 Router、Bloc 或 UseCase。

#### 2. 新增獨立 AuthRefreshInterceptor

401 handling 由獨立 interceptor 負責。

它只處理同時符合下列條件的 request：

```txt
statusCode == 401
requiresAuth == true
skipAuthRefresh != true
authRetryCount == 0
request 曾實際帶上 access token
```

Login、Refresh、public endpoint、已 replay 過的 request 與沒有 token 的 request，不進入 refresh flow。

`AuthRefreshInterceptor` 的責任限於：

- 辨識可處理的 authenticated 401。
- 比較 failed request token 與目前 token。
- 等待或觸發 single-flight refresh abstraction。
- refresh 成功後 replay 原 request。
- refresh 失敗時將錯誤交還上層。

它不直接依賴 `AuthRepository`、`SessionManager`、Router、Bloc 或 LogoutUseCase。

#### 3. Refresh API 與 refresh abstraction 分離

Login 與 Refresh 使用不同的 Retrofit API abstraction：

```txt
AuthApi
  └── login

AuthRefreshApi
  └── refresh
```

`AuthRefreshApi` 固定使用 Refresh Dio 建立，不與使用 Main Dio 的一般 API instance 共用。

這樣可以避免：

- 同一個 `AuthApi` instance 同時要求 Main Dio 與 Refresh Dio。
- 透過 named DI / qualifier 才能區分同型別 instance。
- `Main Dio → AuthRefreshInterceptor → Refresher → AuthApi → Main Dio` 的依賴循環。

Mock implementation 也維持相同邊界：

```txt
MockAuthApi
MockAuthRefreshApi
```

#### 4. Refresh abstraction 定義於 api_client，實作位於 auth

`packages/api_client` 定義 transport 所需的最小 refresh abstraction 與 result type。

`packages/auth` 提供實作，負責：

- 讀取 refresh token。
- 判斷 refresh eligibility。
- 呼叫 refresh API。
- single-flight refresh。
- refresh token rotation。
- 保存完整 Token Pair。
- 更新 SessionManager runtime state。
- refresh failure classification。
- session invalidation。

App Composition Root 負責 abstraction 與 implementation 的綁定與 lifecycle。

此方向避免：

```txt
packages/api_client
  ↓
packages/auth
  ↓
packages/api_client
```

形成 package dependency cycle。

#### 5. single-flight 由 auth-side refresher 負責

single-flight 不放在 Interceptor 內，而由 refresh coordinator / refresher implementation 統一管理。

同一個 Session identity 同一時間只允許一個 refresh Future：

```txt
Request A 401 ─┐
Request B 401 ─┼─→ 同一個 refresh Future
Request C 401 ─┘
```

所有等待者共用同一結果。

In-flight identity 必須至少包含：

```txt
sessionGeneration
userId
failedAccessToken
```

只有三者皆相同的 caller 才能加入同一個 refresh Future。新 Session 遇到舊 Session 的 in-flight operation 時，必須等待舊 operation 結束後重新判斷目前 Session，不得直接繼承舊結果。

完成後清除 in-flight Future 時，必須做 identity check，避免較舊 Future 的 completion 清除較新的 refresh operation。

Auth persistence 與 runtime Session 的複合修改必須透過共享 mutation coordinator 序列化。Login、Restore、Logout、Refresh commit 與 passive invalidation 使用同一個 coordinator；Refresh HTTP request 本身不得持有該 lock。

任何 passive invalidation 在取得 lock 後都必須再次驗證原 operation 的 generation / userId。若 Session 已改變，回傳 `sessionChanged`，不得清除新 Session 的 Token Pair、User persistence 或 SessionManager。

#### 6. failed token 與 current token 不同時不再次 refresh

每個 authenticated request 在送出前，除了加入 access token，也必須保存該 request 所屬的 Session identity snapshot：

```txt
accessToken
sessionGeneration
userId
```

可透過 request extra metadata 保存，例如：

```txt
authSessionGeneration
authSessionUserId
```

401 回來時，只有同時符合下列條件，才能判定為同一個 Session 內已有其他流程完成 refresh：

```txt
current Session 仍存在
current generation == request generation
current userId == request userId
current access token != failed access token
```

此時直接以目前 token replay，不再次呼叫 refresh endpoint。

若 generation 或 userId 不同，代表該 request 所屬 Session 已被 Logout、invalidation、重新 Login 或切換帳號取代。此時不得 refresh，也不得使用新的 Session 身分 replay 舊 request，應回傳 `sessionChanged` 或保留原始 401。

這個規則同時避免：

- 較晚返回的舊 401 造成 sequential duplicate refresh。
- 帳號 A 的舊 request 被帳號 B 的 token replay。
- Logout 後的舊 request 被重新登入後的 Session 復活。

#### 7. Main Dio 與 Refresh Dio 分離

App Composition Root 建立兩個 Dio：

```txt
Main Dio
  ├── AuthHeaderInterceptor
  └── AuthRefreshInterceptor

Refresh Dio
  └── 不安裝 AuthHeaderInterceptor
  └── 不安裝 AuthRefreshInterceptor
```

`AuthRefreshApi` 使用 Refresh Dio，從結構上避免 interceptor recursion 與過期 access token 被誤帶入 refresh request。

Refresh endpoint 仍應標記 `skipAuthRefresh`，作為第二層防護。

#### 8. Token Pair 以單一 persistence abstraction 保存

既有只保存 access token 的 `TokenStorage` 需要升級為完整 Token Pair storage abstraction。

Persistence model 至少包含：

```txt
accessToken
refreshToken
accessTokenExpiresAt（若 API 提供）
refreshTokenExpiresAt（若 API 提供）
```

Access Token 與 Refresh Token 不分開以兩個互不關聯的寫入操作保存，避免一新一舊的不一致狀態。

目前 Demo implementation 可使用 SharedPreferences 的單一 JSON entry 表達完整 Token Pair。

Milestone 12 不同時導入 Android Keystore、iOS Keychain 或 secure storage package；但 storage abstraction 必須保留未來替換能力，文件需明確註記 production 應採平台安全儲存。

#### 9. SessionManager 維持純 runtime state holder

`SessionManager` 不負責 persistence、refresh API 或 Dio exception。

Runtime Session 預設只暴露跨 feature 真正需要的資訊，例如：

```txt
userId
accessToken
accessTokenExpiresAt（若需要）
```

Refresh Token 不透過 SessionManager 暴露給 Route Guard、Profile 或其他跨 feature consumer；它只存在 Auth data boundary 與 persistence。

HTTP request 使用的 current access token source of truth 是 SessionManager runtime state。

`packages/api_client` 應定義能提供完整 runtime Session snapshot 的窄 abstraction，而不只提供 access token 字串。

建議契約語意為：

```txt
AuthSessionSnapshot
  accessToken
  userId
  generation

AuthSessionSnapshotProvider
  getCurrentSession()
```

其 `packages/auth` 實作只從 `SessionManager.currentSession` 與 generation 取得 snapshot，不在每次 request 時讀取 SharedPreferences 或其他 persistence。

`AuthHeaderInterceptor` 使用同一份 snapshot：

- 加入 Authorization header。
- 將 generation 與 userId 寫入 request metadata。

`AuthRefreshInterceptor` 再使用 request snapshot 與 current snapshot 做安全比較。

Persistence 的責任限定為：

- Login 成功後保存 Token Pair。
- App 啟動 Restore Session 時讀取 Token Pair。
- Refresh 成功後更新 Token Pair。
- Logout 或 Session invalidation 時清除 Token Pair。

因此：

```txt
HTTP request 的 current token source of truth
  = SessionManager

App restart 後的 restore source of truth
  = AuthTokenStorage
```

這可避免每個 request 都讀取本地 storage，並確保 refresh 完成後的新 access token 能立即被後續 request 與 failed-token comparison 使用。

`SessionManager` 同時持有 monotonically increasing session generation，用來識別目前登入 Session 的 identity。

下列操作建立新的 Session identity，因此 generation 必須遞增：

- Login 成功。
- Restore Session 成功。
- 主動 Logout。
- 被動 Session invalidation。

一般 access token refresh 成功不遞增 generation，因為它仍屬於同一個登入 Session，只更新 credentials。

#### 10. Refresh 成功先持久化，再更新 runtime Session

Refresh 成功後順序為：

```txt
驗證 refresh response
  ↓
確認 Session identity 仍有效
  ↓
保存完整 Token Pair
  ↓
更新 SessionManager
  ↓
完成 refresh Future
  ↓
等待中的 request replay
```

若 persistence 失敗，不更新 runtime token，也不 replay request。

無法安全保存新 Token Pair 時，視為不可恢復的 local auth state failure：

```txt
新 Token Pair persistence 失敗
  ↓
不更新 runtime token
  ↓
best-effort 清除 Token Pair 與 User persistence
  ↓
無論 local clear 是否成功，都清除 SessionManager
  ↓
回傳 localStateFailure
```

這樣可以避免保留一個已收到 401、但又無法安全更新 credentials 的 runtime Session。

#### 11. Auth persistence 採補償式一致性

Token Pair 與 User persistence 位於不同 storage boundary：

```txt
SharedPreferences
  └── Token Pair

SQLite
  └── Auth User
```

兩者無法形成同一個跨 storage transaction，因此 Auth flow 必須明確採用補償式一致性策略。

Login 成功後順序為：

```txt
保存 Token Pair
  ↓
保存 User
  ↓
兩者皆成功後才更新 SessionManager
```

任一步驟失敗時：

```txt
best-effort 清除 Token Pair
best-effort 清除 User
SessionManager 保持未登入
回傳 local persistence failure
```

Restore Session 時：

```txt
Token Pair 與 User 皆存在且合法
  → Restore Session

任一缺少、解析失敗或資料不合法
  → best-effort 清除兩者
  → SessionManager.clear
  → 視為未登入或依錯誤類型回傳 Failure
```

Logout 與被動 Session invalidation 時，Token Pair 與 User 的清除必須分別嘗試；不可因第一個 clear 失敗而跳過第二個。

清除流程完成後，無論 local clear 是否全部成功，都必須清除 SessionManager。若需要回報本地清除錯誤，應在兩個 cleanup 都嘗試後再彙整錯誤。

Refresh 成功只更新 Token Pair，不更新 User；但 refresh 的 `localStateFailure` cleanup 仍必須分別嘗試清除 Token Pair 與 User。

#### 12. Refresh failure 必須分類

Refresh result 至少區分：

```txt
success
sessionExpired
temporarilyUnavailable
sessionChanged
localStateFailure
```

下列情況可判定 Session 失效：

- 本地不存在 refresh token。
- Refresh token 已知過期。
- Refresh endpoint 明確回傳 invalid refresh credential。
- Refresh response 缺少必要欄位或 token rotation response 不合法。

下列情況不得直接清除 Session：

- 無網路。
- DNS failure。
- Timeout。
- Server 5xx。
- 其他暫時性 transport failure。

暫時性失敗保留 Session，讓後續 request 可再次嘗試。

`sessionChanged` 表示 refresh 期間發生 Logout、重新 Login、切換帳號或其他 Session identity 改變，舊 refresh 結果被主動丟棄。

`localStateFailure` 表示新 Token Pair 無法安全持久化；此時 SessionManager 必須清除，且不得 replay request。

#### 13. Session invalidation 不等同主動 Logout

使用者主動 Logout 維持：

```txt
LogoutUseCase
  ↓
AuthRepository.logout
```

Refresh credential 失效屬於被動 Session invalidation，不透過 LogoutUseCase。

被動 invalidation 由 auth refresh flow 清除 Token Pair、User persistence 與 SessionManager。

Interceptor 不操作 Router 或 Bloc；UI、AuthBloc、ProfileBloc 與 AuthGuard 透過 SessionManager stream 自然進入未登入狀態。

#### 14. 防止 logout / relogin race

Refresh 開始時必須捕獲：

```txt
session generation
userId
failed access token
```

Refresh response 寫入 persistence 前必須再次確認：

```txt
current generation == captured generation
current userId == captured userId
```

若 refresh 期間發生：

- Logout。
- Session invalidation。
- 重新 Login。
- 切換帳號。

舊 refresh response 必須被丟棄，不得保存 token、更新 Session 或 replay request，並回傳 `sessionChanged`。

#### 15. Request replay 僅允許一次

Replay request 必須標記：

```txt
authRetryCount = 1
```

Replay 後再次收到 401，不再觸發第二次 refresh，避免無限循環。

Replay 時使用最新 access token覆蓋原 Authorization header，並透過 Dio `fetch()` 或等價底層 API 重送原 RequestOptions。

#### 16. 特殊 request 必須明確定義 replay policy

一般 JSON、query 與可重建的 request body 可自動 replay。

下列 request 不應假設可安全重播：

- Stream body。
- Multipart / upload stream。
- 已被消耗的 request data。
- 特殊 download / progress flow。
- 已取消的 request。

新增此類 endpoint 時，必須顯式標記 `skipAuthRefresh` 或等價 replay policy。

Refresh Token 只解決身份更新，不解決業務冪等性；付款、下單等非冪等 API 仍需獨立的 Idempotency Key 設計。

#### 17. Token expiration 採 reactive 401 為基礎

Milestone 12 的必要基礎是 server 401 驅動的 reactive refresh。

Token model 可保存 expiration metadata 與 refresh eligibility，但 proactive pre-request refresh 屬於可選的後續子階段。

即使未來加入 proactive refresh，server 401 仍是最終保護，因為 token 可能被 revoke、server session 可能失效，或 client / server clock 存在偏差。

### 測試要求

Milestone 12 至少驗證：

- 多個並行 401 只呼叫一次 refresh。
- 所有等待 request 使用新 token replay。
- 舊 401 在 token 已更新後不再次 refresh。
- 舊 Session / 舊帳號 request 不會被新 Session token replay。
- Replay request 再次 401 不形成循環。
- Refresh endpoint、Login endpoint、public endpoint 不進入 refresh flow。
- Refresh token rotation 正確保存。
- Invalid refresh credential 清除 persistence 與 runtime Session。
- Timeout / 5xx 不清除 Session。
- Persistence failure 不更新 runtime token。
- Persistence failure 會清除 SessionManager，並回傳 `localStateFailure`。
- Login partial persistence failure 會補償清除 Token Pair 與 User，且不建立 runtime Session。
- Logout / invalidation 即使其中一個 local clear 失敗，仍會嘗試另一個 cleanup 並清除 SessionManager。
- Refresh 期間 Logout / relogin 不會被舊 response 覆蓋。
- Login / Restore / Logout / AuthGuard / Profile flow regression。

### 非目標

Milestone 12 不包含：

- Native secure storage 實作。
- OAuth browser flow。
- Multi-device token management。
- Server-side revoke endpoint，除非現有 API contract 明確要求。
- 全域 Router / Navigation Service。
- Idempotency Key framework。
- Multipart / streaming request 的通用 replay engine。

### 影響

- `packages/api_client` 會增加 `AuthRefreshApi`、refresh abstraction、result、request metadata 與 401 interceptor。
- `packages/auth` 會增加 Token Pair persistence model、refresh data flow、single-flight coordinator 與 session invalidation。
- App Composition Root 會建立 Main Dio 與 Refresh Dio，並綁定 refresh abstraction implementation。
- Auth Login response、Mock Auth 與 Restore Session 流程需要支援 Refresh Token。
- SessionManager 仍維持 runtime-only，不直接依賴 storage、Dio 或 Retrofit。

---

## Decision 016：Pagination 與 Search Debounce 責任邊界

**狀態：** Accepted

**實作狀態：** Milestone 13 已完成。Catalog API、Data、Domain、Bloc、Page、Route、DI、競態防護、regression tests 與三環境 build 驗證均已落地。

### 背景

Milestone 13 要建立一個可閱讀、可測試、可延續到 Offline Cache 的清單搜尋範例。

若未先定義 Pagination contract、Search debounce 所在層級、過期 response 判定與取消語意，實作容易出現：

- page key 與 cursor contract 混用。
- Page 自行管理 Timer、Repository 或 Dio cancellation。
- 舊 query response 覆蓋新 query state。
- Refresh 與 Load More response 交錯後錯誤合併資料。
- Scroll event 重複觸發多個相同 page request。
- 為單一範例過早建立通用 Pagination framework。
- 為了真正取消 HTTP request，讓 Dio `CancelToken` 穿透 Presentation / Domain boundary。

因此 Milestone 13 必須先建立清楚的 API、Data、Domain、Bloc 與 UI 責任邊界。

### 決策

#### 1. Milestone 13 使用 Catalog feature 作為垂直切片

Milestone 13 建立具備業務語意的 `Catalog` feature，示範完整流程：

```txt
CatalogPage
  ↓
CatalogBloc
  ↓
SearchCatalogUseCase
  ↓
CatalogRepository
  ↓
CatalogRepositoryImpl
  ↓
CatalogRemoteDataSource
  ↓
CatalogApi
```

不建立以技術名稱命名的 `pagination`、`search` 或 `list` feature。

Catalog 預設放在 App feature 內；只有跨多個 feature 證實可重用的能力，才考慮提升到 package。

#### 2. 正式 Pagination contract 使用 cursor-based pagination

Milestone 13 使用 cursor-based pagination，不同時實作 page-based strategy。

Request contract：

```txt
query
cursor
limit
```

第一次載入與 Refresh 使用：

```txt
cursor = null
```

Load More 使用上一個 response 提供的 `nextCursor`。

Domain page model 至少包含：

```txt
items
nextCursor
```

`nextCursor` 是是否能繼續載入的唯一 source of truth。`nextCursor != null` 表示可繼續載入；`nextCursor == null` 表示已到最後一頁。若 UI 為可讀性需要 `hasMore`，應由 `nextCursor` 衍生，不另外保存一份可能不一致的 mutable state。

`nextCursor` 屬於產生它的 query、filter、sort 與 search generation；任一搜尋條件改變後，不得沿用舊 cursor。

API 若回傳空字串 cursor，由 Mapper 正規化為 `null`。若 response 的 `nextCursor` 與 request cursor 相同，Repository 必須視為無法前進的 pagination response，不得讓 Bloc 形成無限 Load More。

page-based pagination 不列入 Milestone 13；未來若實際 API 使用 page number，只替換 API / Repository page key contract，不建立多 strategy framework。

#### 3. API、DTO、Mapper、Repository 維持既有邊界

所有真實 Catalog HTTP endpoint 使用 Retrofit 宣告；Mock 與 generated implementation 實作相同 `CatalogApi` abstraction，並由 App Composition Root 選擇。

Catalog 在 Milestone 13 定義為 public demo endpoint，不要求登入，也不標記 authenticated request metadata。Pagination / Search 範例不應與 Auth Session 綁定；既有 Profile endpoint 已負責示範 authenticated Retrofit request。

API Layer 負責：

- HTTP method、path 與 query parameters。
- JSON serialization / deserialization。
- public request contract，不加入 authenticated metadata。

RemoteDataSource 負責：

- 呼叫 `CatalogApi`。
- 傳遞 query、cursor 與 limit。
- 將 transport exception 映射為 `AppException`。

Mapper 負責：

- DTO 到 Domain Entity / Page 的純資料轉換。
- cursor 正規化與 DTO 欄位 validation。

Repository implementation 負責：

- 協調 RemoteDataSource。
- 呼叫 Mapper。
- 比對 request cursor 與 response `nextCursor`，驗證 cursor chain 能否前進。
- 將 `AppException` 映射為 `Failure`。

Repository 不保存 UI state、不管理 debounce、不合併既有 pages。

#### 4. UseCase 以單一搜尋業務行為建模

Milestone 13 使用單一：

```txt
SearchCatalogUseCase
```

輸入包含：

```txt
query
cursor
limit
```

不拆成 `InitialLoadCatalogUseCase`、`LoadMoreCatalogUseCase` 與 `RefreshCatalogUseCase`，因為三者在 Domain 中都是同一個搜尋行為；Initial、Refresh 與 Append 是 Presentation workflow。

#### 5. Search debounce 位於 Bloc event pipeline

`CatalogPage` 只負責將 TextField 變化轉成 `queryChanged` event。

Debounce、distinct 與 latest-query-wins 語意由 `CatalogBloc` 管理，不在 Page 使用 Timer，也不讓 Page 直接呼叫 Repository。

預設 debounce 為：

```txt
300 milliseconds
```

Debounce duration 必須可由 Bloc constructor 注入，讓測試可以使用 `Duration.zero` 或較短時間。

Query normalization 使用：

```txt
trim + distinct
```

不預設轉成小寫，大小寫是否等價由 API contract 決定。

空 query 代表載入預設 Catalog 清單，而不是直接清空頁面，讓同一個 feature 同時示範一般分頁與搜尋。

#### 6. 過期 response 使用 search generation 防護

`CatalogBloc` 持有 monotonically increasing search generation。

下列操作建立新的 logical search，因此 generation 必須遞增：

- Debounced query 真正開始搜尋。
- Pull-to-refresh。
- 清空或改變 query。
- 未來 filter / sort 改變。

Initial / Refresh request 至少捕獲：

```txt
generation
query
```

Load More request 至少捕獲：

```txt
generation
query
requestedCursor
```

Response 回來後，只有 identity 仍與目前 state 一致時才可 emit。

即使 event transformer 使用 restart / switch 語意，仍不得假設底層 Future 或 HTTP request 已真正取消；generation guard 是防止 stale response 覆蓋新 state 的必要條件。

#### 7. Load More 使用多層防重策略

Load More 同時採用：

```txt
state guard
  + in-flight event suppression
  + generation / query / cursor response validation
```

Milestone 13 不為此額外引入 `bloc_concurrency`。實作可使用現有 RxDart 建立 feature-local exhaust / droppable transformer，或使用等價的 Bloc event transformer；無論採用哪種 transformer，state guard 都是不可省略的正確性防線。

收到 `loadMoreRequested` 時，至少確認：

- 不在 Initial Loading。
- 不在 Refreshing。
- 不在 Loading More。
- 已有可顯示的 items。
- `nextCursor != null`。

通過後先同步更新 `isLoadingMore`，再開始 async request，避免同一 event loop 內的重複 scroll event 穿透。

#### 8. Refresh 會使舊 Initial / Append operation 過期

Refresh 使用目前 query 與 `cursor = null`，並遞增 generation。

Refresh 開始後：

- 保留目前 items。
- 阻擋新的 Load More。
- 舊 Initial / Append response 因 generation 不符而被丟棄。

Refresh 成功整批替換 items 與 cursor chain；Refresh failure 保留舊 items。

#### 9. Page merge 與 item 去重由 Bloc 負責

Mapper 不合併 pages；Bloc 在 Append 成功時依穩定 Domain ID 合併。

規則：

- 保留既有順序。
- 只加入尚未存在的 ID。
- Append 遇到重複 ID 時保留既有 item。
- Refresh 成功時以新 page 整批替換。

不使用未明確定義 equality 語意的 `Set<CatalogItem>` 直接去重。

#### 10. Loading 與 Failure state 分離建模

Catalog state 至少需要表達：

```txt
isInitialLoading
isRefreshing
isLoadingMore
initialFailure
refreshFailure
appendFailure
items
query
nextCursor
```

`hasMore` 由 `nextCursor != null` 衍生，不作為第二份獨立 state。

UI 語意：

- Initial Loading：全頁 loading。
- Initial Failure：全頁錯誤與 retry。
- Empty Result：獨立 empty state。
- Refreshing：保留清單並顯示 refresh indicator。
- Refresh Failure：保留清單並顯示非阻斷錯誤。
- Loading More：清單底部 loading。
- Append Failure：清單底部 retry。
- End Reached：停止 Load More。

不使用單一 `isLoading` 或單一 `errorMessage` 混合所有狀態。

#### 11. Milestone 13 採 logical cancellation，不導入 Dio CancelToken 跨層傳遞

Milestone 13 的取消保證為：

```txt
舊 operation 可以完成
但不得更新目前 UI state
```

實作手段包括：

- Debounce。
- Latest-query-wins event semantics。
- Search generation。
- Query / cursor identity validation。

Milestone 13 不將 Dio `CancelToken` 傳入 Bloc、UseCase 或 Repository interface，避免 Presentation / Domain 依賴 transport detail。

Logical cancellation 不保證已送出的 HTTP request 停止消耗網路或 server resource。若未來真實 API 有高成本查詢、嚴格 quota 或大型 response，再新增 transport-neutral cancellation abstraction 與 Architecture Decision。

#### 12. 不建立通用 Pagination framework

Milestone 13 不建立：

```txt
GenericPagedBloc<T, K>
PaginationController
PaginationStrategy
CursorPaginationStrategy
PagePaginationStrategy
```

先以 Catalog feature-local implementation 驗證真正需求。Milestone 14 Offline Cache 完成後，若多個 feature 出現穩定重複模式，再評估提升共用能力。

### 測試要求

Milestone 13 至少驗證：

- 快速輸入多個 query，只執行最後一個 debounced query。
- 相同 normalized query 不重複搜尋。
- 舊 query response 晚回來不覆蓋新 query。
- 相同 query 的舊 generation 不覆蓋 Refresh 或重新搜尋。
- 連續多次 Load More 只呼叫一次 Repository。
- Append 使用正確 cursor。
- `nextCursor == null` 時不再載入。
- 重複或無法前進的 cursor 不形成無限 request。
- Append item 依穩定 ID 去重並保留順序。
- Append failure 保留既有 items，並可使用相同 cursor retry。
- Refresh 使用 `cursor = null` 並整批替換成功結果。
- Refresh failure 保留舊 items。
- Refresh 或 query 切換後，舊 Append response 被丟棄。
- Mock / Real Composition Root graph 都能建立。
- 既有 Login、Refresh Token、Profile、Session 與 Route Guard flow 不退化。

### 非目標

Milestone 13 不包含：

- Page-based pagination implementation。
- 多種 Pagination strategy framework。
- Offline Cache、SQLite page storage 或 stale policy。
- Dio `CancelToken` 跨 Presentation / Domain boundary。
- Transport-level cancellation abstraction。
- Server-side search index、ranking 或全文檢索設計。
- Infinite list virtualization framework。
- 跨 feature 共用 Generic Pagination Bloc。

### 影響

- App 會新增 Catalog feature 的 Presentation / Domain / Data 垂直切片。
- `packages/api_client` 會新增 Catalog Retrofit API、DTO 與 Mock implementation。
- App Composition Root 會新增 Catalog API selection 與 feature dependency registration。
- Milestone 14 可在不改變 Presentation / Domain contract 的前提下，於 Repository implementation 加入 Remote + Local 協調。
