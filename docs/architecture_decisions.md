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

專案當時只有Dart application與Flutter Web SQLite dependency preparation assets，尚未建立完整Android、iOS、Web、macOS、Windows或Linux platform runner，因此本階段不適合直接導入Android productFlavors、iOS Schemes、applicationId、bundle identifier或原生App名稱切換。

Milestone 18 evidence clarification：上述歷史背景中的Web preparation不代表tracked Web runner、Web artifact或browser runtime evidence。Current baseline只有Android為Supported；Web與其餘平台維持Dependency-ready。

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
- Milestone 14 將保留既有 Catalog pagination、query、cursor 與 stale-response protection 語意，但可依 Offline Cache 需求擴充 Repository、Domain result 與 Presentation state contract。

---

## Decision 017：Catalog Offline Cache 與 Stale-While-Revalidate 責任邊界

**狀態：** Accepted

**實作狀態：** Milestone 14-1 至 14-7 已完成。SQLite migration、LocalDataSource、Repository SWR coordination、Bloc lifecycle、cursor chain protection、Offline Cache UI、Mock / Real Composition Root、Logout persistence regression 與三環境 build 均已落地並驗證；最終 review 另補上持久化 cursor chain revision。

### 背景

Milestone 13 已完成 Catalog cursor pagination、search debounce、query switching、Refresh、Append 與 stale-response guard。

Milestone 14 要在不破壞既有 Pagination / Search contract 的前提下，加入可離線顯示、可辨識 stale data、可背景更新，且不會把所有 HTTP request 自動寫入 SQLite 的 Offline Cache 範例。

若直接建立 generic HTTP cache，容易造成：

- Login、Refresh Token、付款、交易或其他 command API 被錯誤快取。
- DTO / HTTP response schema 直接成為 persistence schema。
- Cache policy 隱藏在 interceptor，Feature 無法清楚表達 freshness 與 stale UI。
- query、cursor、limit 與 cursor chain 的 identity 被忽略。
- Repository、Bloc 與 UI 無法區分 Cache、Remote 與背景更新結果。
- 在只有一個 feature 驗證前，過早建立 Generic Cache / Generic Pagination framework。

因此 Offline Cache 必須先以 Catalog feature-level、明確 opt-in 的方式實作。

### 決策

#### 1. Cache 僅對 Catalog feature 明確 opt-in

Milestone 14 只為 Catalog 建立 feature-level Offline Cache。

不建立：

```txt
全域 Dio response cache interceptor
所有 GET 自動寫入 SQLite
GenericCacheRepository<T>
GenericPagedCache<T, K>
```

Login、Refresh Token、交易、付款與其他 command API 不自動快取。

未來其他 feature 需要 Offline Cache 時，必須先定義自己的資料敏感度、identity、TTL、logout 與 invalidation policy，再決定是否重用已被多個 feature 證實穩定的共用能力。

#### 2. Initial Search 採 Cache-first + Stale-While-Revalidate

Catalog Initial Search 與 Query Switching 使用：

```txt
Cache-first display
  +
Stale-While-Revalidate
```

規則：

```txt
Cache miss
  → Remote
  → Remote 成功後寫入 Cache 並回傳 fresh data
  → Remote 失敗則回傳 blocking failure

Fresh Cache
  → 立即回傳 Cache
  → Milestone 14 第一版不強制再次打 Remote

Stale Cache
  → 立即回傳 stale Cache
  → 背景請求 Remote
  → 成功後寫回 Cache 並回傳 fresh data
  → 失敗時保留 stale Cache，回傳非阻斷 revalidation failure
```

這不是純 remote-first，也不是永遠不更新的 cache-first。

#### 3. Refresh 與 Append 使用不同 policy

Pull-to-refresh 代表使用者明確要求更新，因此：

```txt
Refresh
  → 強制 Remote
  → cursor = null
  → 成功後 replacement 第一頁 Cache
  → 失敗時保留既有資料與 Cache
```

Append 以目前 `nextCursor` 查詢指定 page：

```txt
Append page Cache 可用且未超過 retainFor
  → 直接回傳單次 Cache 結果

Append page Cache miss
  → Remote
```

Milestone 14 第一版不對 Append 執行背景 revalidation。Append 的 Cache 只作為離線 pagination 與 page cache hit / miss 範例；使用者可透過 Pull-to-refresh 強制 Remote 並重建目前 query 的 cursor chain。

這可避免同一 Append operation 先合併 stale page、再 replacement Remote page 時，額外引入 item 更新、跨 page 重複 ID、`nextCursor` 修正與 cursor chain replacement 的複合語意。

Refresh、Append 與 Initial 仍由同一個 Catalog Repository 協調，不讓 Bloc 直接操作 LocalDataSource 或 RemoteDataSource。

#### 4. Freshness、Stale 與 Retention 明確分離

Catalog Cache policy 至少包含：

```txt
freshFor
retainFor
```

預設建議值：

```txt
freshFor = 5 minutes
retainFor = 7 days
```

定義：

```txt
Fresh
  now - updatedAt <= freshFor

Stale
  freshFor < now - updatedAt <= retainFor

Expired / Evictable
  now - updatedAt > retainFor
```

Fresh Cache 可直接顯示；Stale Cache 可顯示但需標記並背景更新；Expired Cache 視為 miss，並可由 lazy cleanup 或 maintenance flow 清除。

時間判定不得在 Repository 內散落 `DateTime.now()`；需透過可注入 Clock 或等價 time provider，讓 TTL boundary 可穩定測試。

#### 5. Cache identity 使用 normalized query + request cursor + limit

Cache identity 必須完整包含：

```txt
normalized query
request cursor
limit
```

Query normalization 沿用 Decision 016：

```txt
trim
不預設轉小寫
```

因此 `Flutter` 與 `flutter` 不得在 Local Cache 被自行合併。

Domain / Repository 第一頁仍使用：

```dart
cursor = null
```

SQLite persistence 可使用空字串作為第一頁 cursor sentinel，但此 representation 不得穿透 LocalDataSource boundary。

#### 6. Cache 以 cursor page 儲存，不保存單一合併 List

Catalog Cache 以 page 為單位保存：

```txt
Page metadata
  query
  requestCursor
  requestLimit
  nextCursor
  updatedAt

Ordered page items
  item fields
  itemPosition
```

不只保存畫面目前合併後的完整 List，因為那會失去：

- requested cursor identity。
- cursor chain。
- page-level freshness。
- limit identity。
- Append retry 與 page replacement 能力。

第一頁與後續頁使用相同 schema；差別只在 request cursor。

#### 7. 所有 Remote 第一頁成功都會重設該 query + limit 的 cursor chain

下列 operation 都會以 `cursor = null` 取得 Remote 第一頁：

```txt
Initial Cache miss 後的 Remote fetch
Stale Cache background revalidation
Pull-to-refresh
```

任一 Remote 第一頁成功後，都必須在單一 SQLite transaction 中：

1. Replacement 第一頁 page metadata。
2. Replacement 第一頁 ordered items。
3. 更新 `nextCursor` 與 `updatedAt`。
4. 失效同一 normalized query + limit 的舊後續頁。

因為任一 Remote 第一頁結果都可能產生新的 cursor chain，舊 page 2 / page 3 不得再被目前查詢讀取。

Query Switching 不清除其他 query Cache；不同 query 由 cache identity 隔離並依 TTL 自然失效。

Append 成功只 replacement 該 request cursor 對應 page。孤立舊 page 可留待 retention cleanup，但只能透過目前 response `nextCursor` 讀取，不可主動掃描並合併孤立頁。

#### 8. DTO、Local Entity 與 Domain Entity 維持分離

Remote DTO 維持位於 `packages/api_client`，只負責：

```txt
HTTP JSON ↔ DTO
```

Catalog Local Entity 位於 feature data layer，負責：

```txt
SQLite row ↔ Local Entity
```

Domain 維持：

```txt
CatalogItem
CatalogPage
```

並新增 feature-specific snapshot metadata：

```txt
CatalogPageSnapshot
CatalogDataSource
CatalogFreshness
lastUpdatedAt
```

建議語意：

```txt
CatalogPageSnapshot
  page
  source
  freshness
  lastUpdatedAt

CatalogDataSource
  remote
  cache

CatalogFreshness
  fresh
  stale
```

`isRevalidating` 與 `revalidationFailure` 屬於 Bloc operation state，不放入持久資料 snapshot，避免 Domain snapshot 同時承擔資料描述與 workflow 狀態。

Remote DTO 不直接作為 SQLite Entity；Local Entity 不穿透到 Domain 或 Bloc。

#### 9. Repository 負責 Remote + Local 協調

Catalog Repository implementation 負責：

- 讀取 Local Cache。
- 判斷 freshness / stale / expired。
- 呼叫 RemoteDataSource。
- 驗證 cursor chain。
- Remote success 後寫入 Local Cache。
- 協調 Cache → Remote 的多次結果。
- 將 `AppException` 映射為 Domain `Failure`。
- 保留未知程式錯誤與原始 stack trace。

Bloc、UseCase 與 Page 不直接依賴 SQLite、DTO、Dio、LocalDataSource 或 RemoteDataSource。

因 SWR 可能先回傳 Cache、再回傳 Remote，Catalog Repository / UseCase contract 使用 feature-specific Stream 支援多次結果。不得以 callback 讓 Repository 直接操作 Bloc。

Repository contract 必須明確接收 feature-specific load policy：

```txt
CatalogLoadPolicy.initial
  Initial / Query Switching
  使用 Cache-first + SWR
  cursor 必須為 null

CatalogLoadPolicy.refresh
  強制 Remote
  cursor 必須為 null

CatalogLoadPolicy.append
  使用單次 page cache hit / miss
  cursor 必須非 null
```

Repository 必須 fail fast 拒絕不合法組合，例如：

```txt
initial + non-null cursor
refresh + non-null cursor
append + null cursor
```

此 enum 只表達 Catalog feature workflow，不提升為 Generic Cache Strategy framework。

Repository Stream contract 依 policy 明確定義為：

```txt
CatalogLoadPolicy.initial
  Fresh Cache
    emit Success(fresh cache snapshot)
    close

  Stale Cache + Remote success
    emit Success(stale cache snapshot)
    emit Success(remote fresh snapshot)
    close

  Stale Cache + Remote failure
    emit Success(stale cache snapshot)
    emit FailureResult(revalidation failure)
    close

  Cache miss + Remote success
    emit Success(remote fresh snapshot)
    close

  Cache miss + Remote failure
    emit FailureResult(blocking failure)
    close

CatalogLoadPolicy.refresh
  不以 Cache 作為本次 request result
  emit 單次 Remote Success 或 FailureResult
  close

CatalogLoadPolicy.append
  可用且未 expired 的 page Cache
    emit 單次 Success(cache snapshot)
    close

  Cache miss 或 expired
    emit 單次 Remote Success 或 FailureResult
    close
```

Bloc 必須依目前 operation 是否已收到可顯示 snapshot，判斷後續 `FailureResult` 是 blocking initial failure 或 non-blocking revalidation failure；Repository 不把 Bloc workflow flag 塞入 Domain snapshot。

預期的 Remote / Local `AppException` 透過 `Result` 表達；未知程式錯誤才使用 Stream error channel，並保留原始 stack trace。

#### 10. Local Cache failure 與 Auth persistence failure 採不同語意

Catalog Cache 是可重建的 read model，不等同 Auth Token persistence。

因此：

```txt
Cache read failure + Remote success
  → 仍顯示 Remote data
  → 不向一般 Catalog UI 暴露 cache read failure

Remote success + Cache write failure
  → 仍顯示 Remote data
  → Cache failure 為非阻斷 local diagnostic
  → 不加入 Domain snapshot 或一般 Catalog UI state

Remote failure + 可用 Cache
  → 保留 Cache
  → 回傳非阻斷 revalidation failure

Remote failure + 無 Cache
  → 回傳 blocking failure
```

不得因 Catalog Cache write failure 清除 runtime Session 或將成功的 Remote read 轉成整體失敗。

#### 11. UI 不以單次 transport failure 直接宣告全域 Offline

Timeout、DNS failure、connection error 與 server 5xx 不一定等同裝置已離線。

Milestone 14 第一版不新增推測性的全域 `isOffline`，優先使用精確 metadata：

```txt
isUsingCachedData
isStale
lastUpdatedAt
isRevalidating
revalidationFailure
```

UI 可以顯示「目前顯示先前資料」或「無法更新，顯示快取」，但 state 不應在沒有 connectivity abstraction 時宣稱已確定離線。

若未來加入 network monitor，需以獨立 transport-neutral abstraction 表達 network status。

#### 12. Background Revalidation 與 User Refresh 分離

Bloc state 應區分：

```txt
isRefreshing
  使用者 Pull-to-refresh

isRevalidating
  stale Cache 背景更新
```

兩者不可共用單一 loading flag。

`isStale` 與 `lastUpdatedAt` 應由 Repository snapshot 提供，不由 Presentation 自行實作 TTL policy。

畫面級 `isUsingCachedData`、`isStale` 與 `lastUpdatedAt` 只描述目前 query 的第一頁 snapshot。Append page 可以來自 Cache，但不改寫第一頁的畫面級 freshness 與最後更新時間，也不在第一版顯示每頁 freshness。

#### 13. SQLite schema 與 migration 由 App database boundary 管理

Milestone 14-2 最終將 database version 升級為 3：version 2 新增 Catalog Cache tables，version 3 將 page item position index 升級為 unique，並提供：

```txt
onCreate
onUpgrade(oldVersion < 2)
```

v1 → v2 migration 必須保留既有 `auth_user` 資料；v2 → v3 migration 必須保留既有 Catalog Cache page，並只升級 position index constraint。

Database instance 仍由 App Composition Root 建立。SQL migration 可整理到 app database helper，避免 DI module 直接承載大量 schema 細節，但不得把 Composition Root 移入 package。

#### 14. Public Catalog Cache 不因 Logout 清除

Catalog endpoint 在 Decision 016 已定義為 public demo endpoint，因此：

```txt
Logout
  不清除 Catalog Cache
```

Auth logout 不應控制無關的 public feature storage。

未來 authenticated 或 user-scoped cache 必須包含 account identity，並另行定義 logout / account-switch cleanup policy。

#### 15. Cache cleanup 採 page-level lazy cleanup

Milestone 14 第一版至少支援 expired page 的 lazy cleanup。

讀取指定 page 時若發現已超過 `retainFor`：

```txt
視為 Cache miss
  ↓
best-effort 刪除該 expired page 與 child rows
```

第一版不在每次 read / write 後執行全表 expired cleanup，避免每個 request 額外掃描整個 Cache table。

LRU、最大容量、背景排程與設定頁手動清除可留待未來需求，不在本 Milestone 建立通用 maintenance framework。

#### 16. App 維持唯一 Composition Root

Catalog LocalDataSource、CachePolicy、Clock、Repository implementation、UseCase 與 Bloc 的 lifecycle 仍由 App DI module 決定。

不在 `packages/core`、`packages/api_client` 或其他可重用 package 內加入 GetIt / Injectable annotation。

#### 17. 不建立 Generic Cache / Generic Pagination framework

Milestone 14 不建立：

```txt
GenericCache<T>
CacheStrategy<T>
GenericOfflineRepository<T>
GenericPagedCache<T, K>
GlobalCacheInterceptor
```

先完成 Catalog feature-local vertical slice。只有多個 feature 出現穩定且真正相同的 cache identity、freshness、storage 與 invalidation pattern，才評估提升共用能力。

### 建議 SQLite Schema

第一版建議使用：

```sql
CREATE TABLE catalog_cache_page (
  query TEXT NOT NULL,
  request_cursor TEXT NOT NULL,
  request_limit INTEGER NOT NULL,
  next_cursor TEXT,
  updated_at INTEGER NOT NULL,
  PRIMARY KEY (query, request_cursor, request_limit)
);
```

```sql
CREATE TABLE catalog_cache_page_item (
  query TEXT NOT NULL,
  request_cursor TEXT NOT NULL,
  request_limit INTEGER NOT NULL,
  item_id TEXT NOT NULL,
        item_position INTEGER NOT NULL,
        item_name TEXT NOT NULL,
        item_description TEXT NOT NULL,
        PRIMARY KEY (query, request_cursor, request_limit, item_id),
  FOREIGN KEY (query, request_cursor, request_limit)
    REFERENCES catalog_cache_page (query, request_cursor, request_limit)
    ON DELETE CASCADE
);
```

並建立 page item order index。

若實作環境未明確啟用 SQLite foreign key enforcement，LocalDataSource 必須在 transaction 中明確清除 child rows，不可假設 cascade 一定生效。

### 測試要求

Milestone 14 至少驗證：

- 第一頁 null cursor 與 Local sentinel round-trip。
- query trim、大小寫與 limit identity isolation。
- page metadata、item order 與 empty page round-trip。
- 同一 page replacement 不殘留舊 item。
- 任一 Remote 第一頁成功都清除同 query + limit 的舊後續 chain，不影響其他 query / limit。
- v1 → v2 migration 保留 `auth_user`。
- Fresh Cache 不呼叫 Remote。
- Stale Cache 先回傳 Cache，再回傳 Remote fresh data。
- Stale Cache revalidation failure 保留既有資料。
- Cache miss + Remote success / failure。
- Cache read failure 不阻止 Remote success。
- Cache write failure 不吞掉 Remote success。
- Non-advancing cursor 不寫入 Cache。
- Query switch、Refresh 與舊 Cache / Remote result race protection。
- Append Cache hit、miss、expired fallback、去重與 cursor identity；第一版 Append 不執行背景 revalidation。
- `isUsingCachedData`、`isStale`、`lastUpdatedAt`、`isRevalidating` 與 revalidation failure UI。
- Logout 不清除 public Catalog Cache。
- Login、Refresh Token、Profile、Session、Route Guard 與 Milestone 13 regression。

### 非目標

Milestone 14 不包含：

- 全域 HTTP Cache。
- Login、Refresh Token、交易、付款或 command API cache。
- Generic Cache / Generic Pagination framework。
- Connectivity monitoring framework。
- Background task scheduler。
- LRU / disk quota framework。
- 跨帳號 authenticated cache。
- Cache encryption。
- Server push、WebSocket 或 sync conflict resolution。

### 影響

- Catalog Domain contract 會增加可表達 Cache source、stale 與 update metadata 的 feature-specific snapshot。
- Catalog Repository / UseCase 會調整為可支援 SWR 多次結果與 `CatalogLoadPolicy` 的 contract。
- Catalog Data Layer 會新增 Local Entity、Local Mapper、LocalDataSource、CachePolicy 與 Clock dependency。
- App SQLite database 會新增 version 2 migration 與 Catalog Cache tables。
- CatalogBloc 會增加 Cache / stale / background revalidation state，但保留既有 generation、query 與 cursor guard。
- App Composition Root 仍負責所有 lifecycle 與 implementation binding。

---

## Decision 018：Design System、Theme Identity 與 Theme Mode 責任邊界

**狀態：** Accepted

**實作狀態：** Milestone 15-1 至 15-10 已完成。Design System foundations、page-state surfaces、App-local Theme preference 與 selector 已落地；Protected、Profile、Login、Catalog 與 Shell 已完成 semantic surfaces 與 Theme-aware integration，且保留既有 Auth、Profile、Logout、Route Guard、Pagination、SWR 與 Offline Cache 行為。最終 regression 只保留一個 stable Design System gallery golden fixture，並已完成 production hard-coded style audit、未使用 token 清理與三環境 build 驗證。

### 背景

目前 App 只有一個直接建立於 `app.dart` 的 Material 3 Theme：

```dart
ThemeData(
  colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
  useMaterial3: true,
)
```

Login、Profile、Protected 與 Catalog 頁面各自宣告固定 spacing、font size、loading、empty、error 與 status UI。Catalog 已出現 cached、stale、revalidation 與 blocking / non-blocking failure 等重複 presentation pattern，但目前沒有 Design token、ThemeExtension、Dark Theme、Theme persistence 或 feature 使用 Design System 的邊界規則。

只建立一組 Light ThemeData 與 Dark ThemeData，雖然足以支援裝置亮暗模式，卻不構成完整主題系統。主題身份與顯示模式必須分離，否則未來加入另一組品牌 Theme 時，容易把 Light / Dark 誤當成兩套 Theme，或讓 Feature 直接依賴 raw color。

### 決策

#### 1. 建立 `packages/design_system`

Milestone 15 建立：

```txt
packages/design_system
```

它是一個純 Flutter UI package，負責：

- Primitive design tokens。
- Semantic tokens。
- Theme definitions 與 Theme registry contract。
- Light / Dark ThemeData factories。
- Material component themes。
- 必要的 ThemeExtension。
- Primitive components。
- Page state surfaces。
- Accessibility-friendly presentation contract 與 tests。

它不負責：

- App bootstrap。
- Router。
- Bloc 或 feature state。
- Repository / UseCase / DataSource。
- SharedPreferences 或其他 persistence implementation。
- GetIt / Injectable registration。
- Auth、Profile、Catalog、Cache 或 Failure domain semantics。

App 仍是唯一 Composition Root。

#### 2. Theme Identity 與 Theme Mode 分離

主題系統有兩個獨立維度：

```txt
Theme Identity
  決定品牌色、semantic colors、Typography、Radius、Elevation
  與 Material component appearance

Theme Mode
  system / light / dark
  決定目前使用該 Theme Identity 的 Light 或 Dark variant
```

每一套 Theme Identity 必須同時提供：

```txt
Theme Definition
  ├── Light ThemeData
  └── Dark ThemeData
```

`system` 不代表另一套 Theme。它只讓 Flutter 根據平台 brightness 選擇目前 Theme Identity 的 Light 或 Dark variant。

例如：

```txt
themeId = ocean
mode = system

系統 Light → Ocean Light
系統 Dark  → Ocean Dark
```

#### 3. 第一版提供兩套 Theme Identity

Milestone 15 第一版至少提供：

```txt
Default Theme
  ├── Light
  └── Dark

第二套示範 Theme
  ├── Light
  └── Dark
```

第二套 Theme 用來驗證：

- Feature 沒有依賴 raw palette。
- Theme registry 能解析不同 Theme ID。
- Theme preference 能持久化與恢復。
- Theme Identity 與 Mode 可以交叉組合。
- Component themes 不只替換單一 seed color。

Milestone 15 不建立 Theme marketplace、remote Theme、runtime token editor 或任意 JSON skin engine。

#### 4. Theme ID 使用穩定 value contract

Theme ID 必須是可持久化的穩定值，不直接將 class name、display name 或 Flutter enum 當成 storage contract。

Theme ID 採 canonical lowercase contract：必須以小寫英文字母開頭，且只允許小寫英文字母、數字、底線與連字號。前後空白、大寫字母與其他符號直接拒絕，不進行隱式 trim 或 lowercase 正規化。

Registry 必須：

- 有一個明確 Default Theme ID。
- 拒絕重複 Theme ID。
- 確認 Default Theme 存在。
- 將未知或已移除的 Theme ID fallback 至 Default Theme。
- 提供 presentation 可使用的 Theme metadata，但不負責 persistence。

#### 5. Design token 分成三層

```txt
Primitive Tokens
  spacing / radius / elevation / icon size / raw palette

Semantic Tokens
  surface / content / border / success / warning / info / error

Component Tokens
  只有 Material Theme 無法清楚表達，且已有穩定 consumer 時才建立
```

Raw palette 保持 package internal。Feature 不得直接使用 `DefaultPalette`、`OceanPalette` 或特定色階。

Feature 應使用：

- Material `ColorScheme` semantic roles。
- Design System semantic ThemeExtension。
- Public spacing / radius / layout tokens。
- Public primitive components。

#### 6. Material Theme 優先，ThemeExtension 補缺口

以下優先使用 `ThemeData` 與 Material component themes：

- `ColorScheme`。
- `TextTheme`。
- `AppBarTheme`。
- `NavigationBarThemeData`。
- `InputDecorationTheme`。
- Filled / Outlined / Text Button themes。
- Card、Divider、ProgressIndicator、SnackBar themes。

ThemeExtension 只補 Material contract 沒有完整表達的語意，例如：

- success。
- warning。
- info。
- 對應 container / on-container colors。
- 必要的 semantic layout values。

不把所有 spacing、所有 component state 或 raw palette 都塞進 ThemeExtension。

#### 7. Typography、Radius 與 Elevation 的主題能力

Spacing scale、minimum interactive size 與核心 accessibility contract 預設跨 Theme 共用。

Theme definition 可以覆寫：

- ColorScheme。
- Semantic colors。
- Font family 與有限的 Typography characteristics。
- Radius family。
- Elevation / surface treatment。
- Material component appearance。

第二套示範 Theme 第一版只需有限度展示差異，避免測試矩陣與 scope 失控。

#### 8. Feature 與 Design System 邊界

Feature 可以：

- 使用 `Theme.of(context)` 與公開 semantic extensions。
- 使用 public tokens。
- 使用 primitive components 與 page state surfaces。
- 建立 feature-local composite component。

Feature 不可以：

- import raw palette。
- 深層 import Design System internal files。
- 將 Bloc state、Failure、Catalog snapshot 或 domain entity 傳入 Design System primitive。
- 為單一 feature 情境要求 Design System 建立未經驗證的 generic abstraction。

例如 Catalog cache banner 應維持：

```txt
CatalogCacheStatus
  將 cached / stale / revalidation state
  映射為 DsStatusBanner 的純 presentation properties
```

Design System 不知道 Cache 或 SWR。

#### 9. Primitive components 與 Page State Surfaces

第一版優先建立已有實際 consumer 的能力：

- Status Banner / Inline Notice。
- Constrained Content。
- Button loading content。
- Loading State。
- Empty State。
- Blocking Error State。
- Generic Message State。

Material Button variants 繼續使用 `FilledButton`、`OutlinedButton`、`TextButton` 等明確型別，不建立單一巨型 `DsButton(variant: ...)`。

Blocking error 與 non-blocking error 必須分開。Refresh、Append、Revalidation failure 應保留原內容與 operation context，不自動使用全頁 Error State。

#### 10. Theme preference 與 persistence 留在 App

Theme preference 至少包含：

```txt
themeId
mode = system | light | dark
```

App 負責：

- Theme preference model / application policy。
- Persistence abstraction 與 implementation。
- Bootstrap restore。
- Theme controller lifecycle。
- Theme registry composition。
- `MaterialApp.theme` / `darkTheme` / `themeMode` wiring。
- Appearance selector UI 的組裝。

Design System package 不直接依賴 SharedPreferences。

Persistence 使用單一 versioned JSON，儲存於：

```txt
app.theme.preference
```

Version 1 contract：

```json
{
  "version": 1,
  "themeId": "default",
  "mode": "system"
}
```

Fallback policy：

- 資料不存在、JSON 損壞或未知 version：整體 fallback 至 Default Theme + System mode。
- 未知或已移除的 Theme ID：只將 Theme ID fallback 至 Default Theme，保留合法 mode。
- 未知 mode：只將 mode fallback 至 System，保留合法 Theme ID。

Theme preference 是非關鍵 UI setting。使用者切換 Theme Identity 或 Theme Mode 時，Runtime state 先立即更新，再非同步持久化；若寫入失敗：

- 不回滾目前 runtime Theme，避免畫面切換後跳回。
- Controller 暴露 non-blocking persistence failure，供 UI 或 diagnostic boundary 處理。
- 不提升為 blocking page error，也不使 App crash。
- 下次啟動仍以最後一次成功持久化的 preference 為準。

多次 Theme preference mutation 必須遵守 latest preference wins。Controller 每次都持久化完整 preference snapshot，並透過單一序列化 write queue 保證寫入順序；不得將 Theme ID 與 mode 拆成彼此獨立、可交錯完成的非同步寫入。

序列化寫入必須符合：

- 快速連續切換時，最後一次使用者選擇是最後 persisted snapshot。
- 前一次寫入失敗不得阻止後續較新的 preference 繼續寫入。
- 每次寫入都保存完整 `version`、`themeId` 與 `mode`。
- 較舊 mutation 不得在較新 mutation 完成後覆蓋 storage。

Bootstrap restore 若遇到 storage read exception，仍必須啟動 App：

- Runtime 使用 Default Theme + System mode。
- 保留 non-blocking restore diagnostic，供 controller 或 diagnostic boundary 觀察。
- 不阻止 `runApp`，也不提升為 blocking page error。
- 不因 read failure 自動寫回 fallback preference，避免啟動時再觸發第二個 storage error。

內容不存在或無效屬於 fallback / repair policy；storage read exception 屬於 diagnostic failure，兩者需分開測試。

Bootstrap 應在 `runApp` 前恢復 preference，避免先顯示錯誤 Theme 再切換造成明顯閃爍。

Appearance selector 屬於 App-level presentation，建議放在：

```txt
apps/flutter_architecture/lib/app/theme/presentation/
```

Shell 只負責提供入口並開啟 selector；Design System package 不知道 Theme controller 或 persistence workflow，也不需要建立完整 Settings feature。

#### 11. Accessibility 與 text scaling 是完成條件

Milestone 15 不禁止系統 text scaling，也不以固定高度承載可換行文字。

至少驗證：

- Text scaling 1.0、1.3、2.0。
- 窄 viewport。
- Light / Dark variants。
- 兩套 Theme Identity。
- Loading、Error、Retry、Status Banner 與 icon-only action Semantics。
- 主要互動元件維持合理 touch target。
- Semantic foreground / container colors 成對使用。

Catalog empty state 現有 `SizedBox(height: 160)` 屬於 layout hack，導入 Page State Surface 時應移除，而不是提升為 global token。

#### 12. 現有頁面導入順序

依風險由低至高：

```txt
Theme infrastructure
  ↓
ProtectedPage
  ↓
ProfilePage
  ↓
LoginPage
  ↓
CatalogPage
  ↓
ShellPage final verification
```

Catalog 最後導入，因為它同時包含 Initial、Empty、Refresh、Append、Cache、Stale 與 Revalidation states；Design System 遷移不得改變 Milestone 13 / 14 的 state machine 與 lifecycle contract。

### 測試要求

Milestone 15 至少驗證：

- Token 與 semantic role contract。
- Theme registry default、duplicate、unknown ID 與 fallback。
- Default / 示範 Theme 都能建立 Light / Dark ThemeData。
- ThemeExtension `copyWith` / `lerp`。
- Material component themes 的關鍵設定。
- Primitive component callback、disabled/loading、Semantics、長文字與窄畫面。
- Page State Surfaces 在 text scaling 1.0、1.3、2.0 下不發生主要 overflow。
- Theme preference round-trip、unknown/corrupted value 與 removed Theme fallback。
- `MaterialApp` 正確使用選中 Theme 的 Light / Dark ThemeData 與 ThemeMode。
- Login、Profile、Logout、AuthGuard、Catalog Pagination 與 Offline Cache regression。

Golden tests 保持少量且穩定，優先測 Design System gallery / state fixtures，不為所有 feature page 建立完整 Theme × Mode golden matrix。

### 非目標

Milestone 15 不包含：

- Theme marketplace。
- Remote Theme / server-driven UI theme。
- Runtime JSON token editor。
- Generic form framework。
- Generic responsive framework。
- 完整 icon library。
- Motion / animation framework。
- Localizations infrastructure。
- Failure taxonomy 或 error code mapping 重構。
- 為沒有穩定 consumer 的 component 建立抽象。

### 影響

- Workspace 會新增 `packages/design_system`。
- App 會新增 Theme preference、persistence、controller 與 Appearance selector wiring。
- `ArchitectureApp` 會從直接建立單一 ThemeData，改為消費目前 Theme Identity 的 Light / Dark ThemeData 與 Theme Mode。
- Login、Profile、Protected、Catalog 與 Shell presentation 會逐步改用 semantic tokens、Material component themes 與 Design System primitives。
- Feature business state、Bloc、Repository 與 Milestone 13 / 14 data flow 不因 Design System 導入而改變。

---

## Decision 019：Localization、Locale Preference 與 User-facing Failure Mapping 責任邊界

**狀態：** Accepted

**實作狀態：** Milestone 16-1 至 16-7 已完成；`gen_l10n`、locale preference、persistence、bootstrap、selector、Shell / Appearance、Theme metadata、Auth / Profile / Protected / Catalog localization、feature-local failure mapping、locale-aware date formatting、production text audit 與完整 regression 已落地。

### 決策

#### Localization owner

- App 是 localization owner 與唯一 Composition Root，負責 `gen_l10n`、ARB、delegates、supported locales、locale resolution、preference、restore、persistence、controller、selector 與 `MaterialApp.router` wiring。
- App title 使用 `onGenerateTitle` 取得 localized text。
- `gen_l10n` 對 `zh_TW` 要求存在 base `zh` ARB 作為 generator fallback；該檔案只滿足 generated localization fallback contract，App 的 `supportedLocales` 仍只公開 `en` 與 `zh_TW`。
- `packages/design_system` 不依賴 App generated `AppLocalizations`，只接收呼叫方傳入的 title、message、label、tooltip、Semantics 與 action text。
- Design System primitive 不自行拼接固定語言的 user-facing fallback；例如 loading semantics 未提供專用文案時，只能重用呼叫方已 localized 的 label。
- Domain、Data、Repository、exception 與 log 不依賴 `BuildContext`、`AppLocalizations` 或 App locale，也不建立可直接顯示的 localized UI sentence。
- Server / user content，例如 Profile name、Catalog item name / description，不進 App ARB。

#### Locale preference 與 resolution

- 第一版支援 `system / en / zh_TW`，使用獨立 App-local versioned persistence contract，storage key 為 `app.locale.preference`。
- `system` preference 不保存 resolved locale；`MaterialApp.router.locale` 維持 `null`，由 `localeListResolutionCallback` 根據 platform locale list 解析，因此自然跟隨平台 locale 變化。
- Explicit `en` / `zh_TW` preference 由 controller 提供具體 Locale，直接覆蓋 system resolution。
- LocaleController 只保存 preference 與 persistence 狀態，不另外保存 resolved system locale，也不自行實作 `WidgetsBindingObserver`。
- `zh_TW`、script `Hant`、`zh_HK`、`zh_MO` 解析為 `zh_TW`；`zh_CN`、`zh_SG`、script `Hans` 與其他 unsupported locale fallback 至 English。
- Theme preference 與 Locale preference 不抽象成 Generic Preference Framework。
- Locale preference 使用 Version 1 JSON `{version, locale}`，SharedPreferences key 為 `app.locale.preference`。
- `LocaleController` 採 runtime-first 與 serialized complete-snapshot write queue；寫入失敗不回滾 runtime，且不阻止較新 preference 繼續保存。
- Storage read exception 以 System 啟動，保留 non-blocking diagnostic，不阻止 `runApp`，也不自動寫回 fallback。
- Bootstrap 在 `runApp` 前 restore Locale preference，App-level selector 支援 System、English 與繁體中文。

#### Failure / Exception 範圍

- Milestone 16 不全面重構 `Failure`、`AppException`、`Result`、cause chain、Repository mapping 或 Bloc hierarchy。
- `Failure.message` 定義為 diagnostic / fallback information，不保證是可直接顯示的 localized UI text。
- 只處理目前實際顯示到 UI 的 Login、Logout、Profile load 與 Catalog initial / refresh / append / revalidation failure。
- Catalog Bloc 原本已保存 `Failure`；Auth / Profile Bloc 已於 Milestone 16-5 完成最小 state contract 調整，改為保存 `Failure + operation context`，使 Presentation 能取得 stable failure identity。
- Feature Presentation 依 stable code / kind 做 feature-local mapping；只有語意足夠明確的 code 才能產生特定 UX copy。現有 HTTP status contract 下，`401` 可用於 Login invalid credentials / Profile session expired，`403` 不推導成這兩種語意，改用操作專屬 localized fallback。
- Catalog 保留既有 initial / refresh / append / revalidation `Failure` 欄位，由 Presentation 依 surface 映射；HTTP `408 / 429` 可安全映射 timeout / rate-limit copy，其餘使用 surface-specific fallback。
- 不建立 Global Error Localization Service、Generic Failure Mapper 或全域 typed failure taxonomy。
- `Failure.message` 與 `mapAppExceptionToFailure` 的既有註解需同步修正；Repository 固定語言 fallback 不再宣稱可直接交給 UI。

正式流程：

```txt
AppException / technical diagnostic
  ↓
Repository 建立穩定 Failure identity
  ↓
Bloc 保存 Failure
  ↓
Feature Presentation 映射 AppLocalizations
  ↓
Design System 顯示已 localized String
```

#### Theme、ARB 與 formatting

- Theme ID 維持 stable persistence identity；App 依 Theme ID 映射 localized display name，Design System metadata 只保留 fallback display name。
- ARB key 使用 lowerCamelCase 與 feature + semantic purpose；parameterized message 使用 placeholder，不在 Dart 拼接句子。
- Data、Domain 與 Cache timestamp 維持 UTC；Presentation 轉為 local time 後依目前 locale 的日期與時間慣例格式化，不強制固定 12 或 24 小時制。
- Catalog 日期顯示使用 App 直接依賴的 `intl`；formatter 不回寫或改變原始 UTC timestamp。
- Localization 不改變 cursor、ID、version、HTTP code、SQL schema 或 storage value。

### 非目標

- 全專案 Failure / Exception hierarchy 重構。
- Generic Localization Service、Generic Error Localization Service 或 Generic Preference Framework。
- Design System 依賴 App generated localization。
- Remote language pack、server content 自動翻譯、timezone / currency preference、完整 region settings 或完整 RTL。

---

## Decision 020：Exception、Failure、Unexpected Error 與 Reporting 責任邊界

**狀態：** Accepted

**實作狀態：** Milestone 17-1至17-7已全部完成。Typed Result、AppException / Failure、Auth lifecycle、Catalog protocol / cache boundary、Preference diagnostics、App uncaught reporting、Composition Root、duplicate policy與Sensitive Data audit均已落地；完整382項tests與三環境bundle build已通過。Firebase / Crashlytics dependency未加入，可由未來App-owned production adapter替換Debug implementation。

### 背景

Milestone 16 已將 `Failure.message` 改為 diagnostic / fallback contract，並由 Auth、Profile 與 Catalog Presentation 依 `Failure + operation context` 建立 localized user-facing copy。

目前專案也已存在以下正確基礎：

```txt
DioException
  ↓ RemoteDataSource
AppException
  ↓ Repository
Failure
  ↓ Result / Bloc
Feature Presentation localized copy
```

Milestone 17-1 全專案 audit 當時發現以下結構性問題；其中前兩項已由 Milestone 17-2 修正，其餘留待 17-3 至 17-7：

- `FailureResult.error` 仍為 `Object`，expected failure channel 沒有型別保證。
- Auth / Profile Bloc 對非 `Failure` 使用 `error.toString()` 重新包裝，可能將 programming error 降級成普通 Failure。
- Refresh Token 與 Interceptor 路徑存在多個 `catch (_)`，unknown error 可能被降級為 `localStateFailure`、`temporarilyUnavailable` 或原始 401。
- `AppException` / `Failure` 只有 message、code、cause，HTTP status、backend code、transport kind、local storage、corruption、protocol 與 session identity 尚未明確分類。
- 一般 RemoteDataSource 使用 `packages/api_client` transport mapper，但 Auth Refresh data source 目前直接依賴 Dio 做 refresh-specific status 分類，transport ownership 尚未完全一致。
- Theme / Locale preference Codec、Store 與 serialized write queue 目前廣泛捕捉 `Object`；invalid payload 會靜默 fallback，unknown codec / persistence programming error 也可能被降級成 non-blocking diagnostic。
- `AppException.toString()` / `Failure.toString()` 直接展開 cause，存在敏感資料進入一般 log 的風險。
- App 尚未建立 Flutter framework、platform async、Bloc 與 non-fatal degraded operation 的 reporting adapter boundary。

### 核心分類

錯誤流程正式分成五種不同語意，不得互相冒充：

```txt
Expected operational failure
  → typed AppException
  → typed Failure
  → Result<T>

Unexpected programming / system error
  → 保留原始 error + stack trace
  → 不轉 Failure
  → uncaught / reporting boundary

Cancellation
  → control flow
  → 預設不產生 user-facing Failure

Protocol violation
  → external contract violation：typed AppException / Failure + reporting
  → internal invariant violation：programming error，直接拋出

Session lifecycle result
  → typed result
  → 不冒充 Exception 或 Failure
```

### Result 與 Failure contract

- `FailureResult<T>` 的失敗值必須收斂為 `Failure`，不可繼續接受任意 `Object`。
- Bloc 不得使用 `error.toString()` 將 unknown error 轉成 Failure。
- Failure 提供跨 feature 可重用的 stable identity；operation context 仍由各 Feature Bloc / Presentation 保存。
- 不建立 `CatalogAppendTimeoutFailure`、`ProfileLoadTimeoutFailure` 這類 operation × failure class 笛卡兒積。
- `Failure.message` 維持 diagnostic / fallback，不直接作為 localized UI copy。
- Feature Presentation 繼續負責 localized message、surface、action 與 retry UX。

第一版 Failure taxonomy 的候選語意類別控制在少量穩定範圍：

```txt
Failure
├─ NetworkFailure
├─ ServiceFailure
├─ AuthenticationFailure
├─ LocalStateFailure
└─ ProtocolFailure
```

上述名稱描述的是穩定語意；Milestone 17-3 已採單一 immutable model + typed `kind` enum，不建立 subclass tree。

Milestone 17-2 只先封閉 `Result` failure channel，確保 `FailureResult<T>` 與 `Result.when` 的 failure callback 只接受 `Failure`，並移除 Bloc 的 `Object → Failure` fallback。

Milestone 17-2 已完成上述 contract：production Repository 原有 Failure 建立流程不變，Auth / Profile Bloc 不再進行 runtime wrapping，Catalog Bloc 的舊防禦型 type check 亦已移除；unknown thrown error 維持 framework error channel。

Milestone 17-3 已完成 typed kind shape：`AppExceptionKind`、`TransportExceptionKind` 與 `FailureKind` 分離 transport、HTTP status、backend code、diagnostic code、local storage、corruption、protocol 與 session identity。`code` 僅保留作相容橋接，新 production policy不得再依字串猜 HTTP status。不建立 Generic Failure framework。

### AppException contract

DataSource / Infrastructure boundary 將第三方 exception 隔離成少量 typed `AppException` category：

```txt
AppException
├─ TransportException
├─ BackendException
├─ LocalStorageException
├─ DataCorruptionException
├─ ProtocolException
└─ SessionException
```

規則：

- 不為每個 HTTP status 建立一個 class。
- HTTP status、backend code 與 transport kind 必須是不同欄位 / identity，不再共用單一模糊 `code` 語意。
- Backend business code 不建立全域 enum；只有實際擁有該語意的 feature / bounded context 才做局部 interpretation。
- DataSource 只捕捉其能明確分類的第三方 operational exception；其他 error 使用原始 stack trace 重新拋出。
- typed AppException 保存安全 diagnostic context 與原始 stack trace；不得把 request body、token、password 或 raw storage payload放入 context。

### Exception → Failure mapping responsibility

```txt
Infrastructure / DataSource
  - 隔離 Dio、SQLite、SharedPreferences、serialization 等第三方 exception
  - 建立 typed AppException
  - 保存 stack trace
  - 加入安全 diagnostic context

Repository
  - 只捕捉已知 AppException
  - 依業務 operation 映射 typed Failure
  - 決定 compensation、cache fallback 與 local cleanup
  - unknown error 原樣拋出

UseCase
  - 表達業務行為與參數規則
  - 通常不重新映射 technical failure

Bloc
  - expected Failure 寫入 state
  - unexpected error 可先清理 loading state，再保留 stack trace 重新拋出

Feature Presentation
  - 使用 shared Failure identity + feature operation context
  - 產生 localized user-facing copy 與 action
```

不得建立：

```txt
GlobalErrorHandler.handleEverything()
GlobalExceptionMapper.mapAnything()
GenericRepositoryFailureMapper<T>
```

允許在擁有語意的 boundary 附近建立小型純 mapper，例如 transport mapper、Auth mapper 或 Catalog mapper。

### Cancellation 與 protocol violation

- Query switching、subscription cancellation、navigation disposal 等預期 cancellation 是 control flow，不進一般 Failure，也不預設 reporting。
- Dio cancellation 只有在 operation contract 明確需要呈現時才可映射為 Failure。
- API response 缺必要欄位、malformed success response、non-advancing cursor 等外部 contract violation，映射為 `ProtocolException` / `ProtocolFailure`，使用 generic localized fallback 並進行 non-fatal reporting。
- Repository / Bloc 自身宣告的 Stream emission contract 被 implementation 破壞，屬 internal invariant violation，使用 `StateError` 等 programming error，禁止轉普通 Failure。

### Auth Session lifecycle

既有 sealed `AuthRefreshResult` 保留：

```txt
success
sessionExpired
temporarilyUnavailable
sessionChanged
localStateFailure
```

規則：

- `sessionChanged` 是 race-resolution result，不是 Failure。
- 只有 refresh credential 明確失效、credential 缺失 / 過期、auth local state corruption 或 explicit logout 可清除 Session。
- timeout、connection error、429、5xx、一般 temporary backend failure 不清除 Session。
- `localStateFailure` 只可由 typed local operational exception 產生；unknown error 不得降級成此 result。
- Concurrent 401 single-flight、generation / userId identity、safe replay 與跨 Session race protection不得破壞。

### Cache 與 preference degraded-mode

Catalog Cache 與 Theme / Locale preference 的 non-blocking policy 保留，但「不阻斷 UI」不等於「完全吞掉 error」。

```txt
Expected Cache read failure
  → non-fatal report
  → Remote fallback

Expected Cache write failure
  → non-fatal report
  → 保留 Remote success

Cache corruption
  → 清除受影響的可重建資料
  → non-fatal report
  → Remote fallback

Unknown Cache implementation error
  → unexpected error
  → 不得靜默忽略
```

Theme / Locale preference read failure可 fallback，write failure不回滾 runtime；兩者仍需保留安全 diagnostic 並透過 non-fatal reporting adapter 觀測。

Preference Codec / Store 需另外遵守：

- 已知的 unsupported version、invalid stored value 或 malformed persisted payload 可視為 recoverable corruption，fallback 至預設值並保留 non-fatal diagnostic。
- serialized write queue 可吸收「前一筆已分類的 expected persistence failure」，讓後續較新 snapshot 繼續保存，但不得吞掉任意 unknown error。
- Codec、registry interaction 或 controller invariant 的 programming error 不得因 `on Object` / `catchError(Object)` 被降級成普通 preference diagnostic。

### Retryability 與 policy owner

不在 `Failure` 上加入全域 `isRetryable`、`shouldClearSession`、`shouldReport` 等萬用 boolean，因為同一 failure 在不同 operation 的處理可能不同。

- Connection、timeout、408、部分 5xx 預設可由 feature operation明確 retry。
- 429 依 Retry-After / operation policy 決定。
- Invalid credential、authorization denied、protocol violation 不自動無限 retry。
- Repository 不建立隱式全域 retry；retry 必須由擁有 operation 語意的 interceptor、repository coordination 或 presentation workflow 明確 opt-in。

### Logging、reporting 與 Composition Root

建立狹窄 reporting abstraction，例如：

```dart
abstract interface class ErrorReporter {
  void report(
    Object error,
    StackTrace stackTrace, {
    ErrorSeverity severity,
    SafeDiagnosticContext? context,
  });
}
```

- App 是唯一 Composition Root，負責組裝 Debug、Test、Crashlytics 或 Composite adapter。
- Packages 不直接依賴 Firebase Crashlytics、App localization 或 router。
- framework entrypoint 分別處理 `FlutterError.onError`、`PlatformDispatcher.instance.onError` 與 `BlocObserver.onError`，不是建立一個接管所有決策的 Global Error Handler。
- expected UI failure 通常不重複 report；unexpected error與重要 degraded-mode failure 才進 reporting。
- Crashlytics 是否立即加入 dependency 原留待 Milestone 17-6 implementation review；最終決定為本階段不加入 Firebase / Crashlytics dependency，只保留 App-owned adapter boundary，未來由 production Composition Root 替換 Debug implementation。

### Sensitive data contract

Exception、Failure、cause、context、log 與 `toString()` 不得包含：

- password、access token、refresh token、Authorization header、Cookie。
-完整 request / response body。
- raw SharedPreferences auth payload、SQLite row content。
- 非必要 PII 或敏感 URL query parameter。

允許的 safe diagnostic context包括：

- operation name、HTTP method、sanitized path template、HTTP status、backend code、transport kind。
- session generation、`hasSession`、resource identity、cache operation、page limit。
- cursor 是否存在，但不保存 cursor value。

`AppException.toString()` / `Failure.toString()` 不得直接展開任意 `cause.toString()`。

任何持有 credential、secret 或可直接識別使用者登入資料的 Freezed class / union，預設不得使用欄位型 `toString()`。例如 password、access token、refresh token、OTP、PIN、recovery code、private key 或 device-binding secret；應使用 `@Freezed(toStringOverride: false)`，除非另有經review的安全摘要，而且摘要不得包含原始credential值。

### 非目標

- 不建立 Global Error Handler 或 Generic Exception / Failure Mapper framework。
- 不為每個 HTTP status 建 class。
- 不將所有 backend business code 建為全域 enum。
- 不讓 Design System、Domain、Data 或 Repository 依賴 App localization。
- 不改變 App 作為唯一 Composition Root。
- 不在本 Decision 直接修改 Auth Session、Pagination、SWR、Offline Cache 或既有 regression 行為。

---

## Decision 021：Auth Startup 與跨 Feature Navigation 由 App Composition Layer 擁有

**狀態：** Accepted

**實作狀態：** Milestone 18-7D Reviewed / Closed。

### 背景

Milestone 18 Architecture Audit確認兩個邊界問題：

- `ShellPage`直接取得`AuthBloc`並送出`AuthStarted`，使Shell presentation承擔Auth startup ownership。
- `LoginPage`與`ProfilePage`直接依賴`ShellTab`及tab index，讓Auth / Profile presentation反向知道Shell navigation identity。

### 決策

Auth startup與Auth state到Shell destination的映射提升至App composition layer：

```txt
ArchitectureApp
  ↓ start
AuthNavigationCoordinator
  ↓ AuthStarted
AuthBloc
  ↓ authoritative authentication transition
AuthNavigationDestination
  ↓ App-owned route mapping
ShellRoute(LoginRoute / ProfileRoute)
```

規則：

- App啟動時由App-owned coordinator觸發Auth restore；Shell不得dispatch Auth lifecycle event。
- Auth feature只表達login result與Auth state，不import `ShellTab`或tab index。
- Profile feature只表達logout result；Session清除後由AuthBloc權威狀態變化驅動App navigation。
- Login成功的`unauthenticated → authenticated`映射至Profile destination。
- 已登入狀態轉為未登入時映射至Login destination。
- 相同authentication identity不重複導航；loading或failure field改變不構成navigation intent。
- 具體`ShellRoute` child mapping只存在App router / composition boundary。
- Coordinator只在Router首個frame掛載後啟動，避免快速restore在Router mount前導航。
- Auth destination以root `replaceAll`重整為單一`ShellRoute`，確保Protected等root route會在失去登入狀態時被移除。

### 非目標

- 不建立Generic Navigation Coordinator framework。
- 不讓Domain或可重用package依賴AutoRoute。
- 不改變Shell使用`AutoTabsRouter`管理使用者手動tab切換的責任。
- 不讓AuthBloc直接操作Router。

---

## Decision 022：Authentication Security 能力拆分與責任邊界

**狀態：** Accepted；Milestone 19與20已完成並封存，Milestone 21-0 Planning Review已通過

**實作狀態：** Milestone 19 Secure Credential Storage & Migration與Milestone 20 OTP Step-Up Authentication均已完成並封存，Template Baseline為1.4.0。Milestone 21已完成21-0 Planning Review，但尚未開始production implementation。

### 背景

Template Baseline 1.3.0 已具備Secure Token Pair persistence、SharedPreferences legacy migration、Refresh Token rotation、concurrent 401 single-flight、Session generation、latest-intent ordering、single-active-user persistence、App-owned Auth navigation與Android Supported baseline。

下一階段原本考慮在單一 Milestone 同時加入 Secure Token Storage、OTP 雙重驗證與 Biometric-gated local session unlock。三者都屬於 Authentication Security，但實際涉及三種不同責任：

```txt
Credential-at-rest security
  → Secure Storage、legacy migration、rotation、cleanup

Server authentication state machine
  → Password login、OTP challenge、verify、resend、session issuance

Local device access control
  → Biometric capability、user presence、startup unlock gating
```

若在同一 implementation batch 處理，Secure Storage migration、OTP server contract 與 Android biometric runtime 會互相阻塞，也會使 review、rollback、測試與版本判斷失去清楚邊界。

### 決策

Authentication Security & Step-Up Verification 正式拆分為三個依序執行的 Milestone：

```txt
Milestone 19 — Secure Credential Storage & Migration
  ↓
Milestone 20 — OTP Step-Up Authentication
  ↓
Milestone 21 — Biometric-gated Local Session Unlock
```

每個 Milestone 都必須獨立完成 Architecture Review、implementation review、regression、文件同步與封存。後一個 Milestone 不得假設前一個尚未 review 或尚未封存的 production contract。

### Milestone 19 邊界

Milestone 19 只處理 credential-at-rest security：

- Access Token 與 Refresh Token 遷移至 platform secure storage。
- AuthUser 等非 credential 資料維持 SQLite。
- SharedPreferences legacy Token Pair 與單 access-token key 的安全 migration。
- Migration 的 write failure、read-back validation、partial migration、identity mismatch、legacy corruption、secure corruption、cleanup retry 與 refresh rotation ordering。
- Login、Restore、Refresh rotation、Logout 與 Session invalidation 改用 Secure credential source of truth。

Milestone 19 不包含 OTP、Biometric Prompt、Device Binding、Passkey 或 Native biometric configuration。

Legacy source policy：

- `auth.tokens`若包含完整Token Pair與可驗證`userId`，才具有migration資格。
- `auth.accessToken`缺少Refresh Token與identity，不得升級為有效Session；只允許安全清除並維持未登入。
- Secure credential合法且與SQLite User identity一致時，Secure Store為權威；Legacy資料即使不同或損壞，也只清除Legacy，不得覆蓋Secure credential。
- Secure credential與SQLite User identity不一致時，不得猜測，清除完整Auth state。
- Secure credential不存在時，只有完整且與SQLite User identity一致的Legacy Token Pair可進入migration。

### Milestone 20 邊界

Milestone 20 只處理 server-issued OTP challenge flow：

```txt
account + password
  ↓
authenticated
或
otpChallenge
  ↓
challengeId + otpCode
  ↓
驗證成功後才簽發、保存並建立 Session
```

規則：

- Login result 必須是 typed union，不以 nullable token / challenge 欄位表達。
- OTP 完成前不得寫入 credential、建立 Session 或通過 Protected Route。
- challengeId、expiration、masked destination、resend cooldown、invalid code、expired challenge、too many attempts 與 resend replacement 必須有明確 contract。
- 舊 Login、Verify 或 Resend response 不得覆蓋最新 Auth intent 或 active challenge。
- Mock API 必須可完整演示；Real API 只定義 contract，不綁定 SMS provider SDK。

### Milestone 21 邊界

Milestone 21 的定位是 Biometric-gated local session unlock，不是 cryptographic Device Binding。

規則：

- Biometric 只驗證本機 user presence，不代表 Server authentication。
- 不保存指紋、臉部或任何 biometric template。
- Local unlock 成功後才允許讀取 credential、restore 或 refresh Session。
- Locked 階段 `SessionManager` 必須維持 unauthenticated，避免 AuthGuard、Dio、Profile 或 Navigation 提前取得已登入狀態。
- 真正 Device Binding 所需的 Keystore / Secure Enclave key pair、public key registration、server challenge 與 signature verification不在本 Milestone。
- Android 是唯一 Supported runtime target；iOS 與其他平台只維持 dependency-ready，不因套件宣稱能力就提升 platform capability。

### Package 與 App responsibility

`packages/auth` 只定義純 Dart、Auth-specific 狹窄 abstraction與 application / domain contract，例如：

```txt
AuthCredentialStore
AuthLegacyCredentialStore
AuthUserStore
LocalUserPresenceVerifier
```

App layer 負責 plugin 與平台 implementation，例如：

```txt
FlutterSecureAuthCredentialStore
SharedPreferencesLegacyCredentialStore
SqfliteAuthUserStore
LocalAuthUserPresenceVerifier
```

規則：

- `flutter_secure_storage` 與 `local_auth` 只允許由 App layer依賴與組裝。
- Milestone 19完成後，`packages/auth`不再直接依賴`shared_preferences`或`sqflite`；既有plugin implementation移至App layer。
- Domain、`packages/auth` public contract 與 `packages/api_client` 不得暴露 plugin class、Android Keystore、Apple Keychain、`BiometricType` 或平台 exception。
- App 維持唯一 Composition Root。
- 不建立 Generic Secure Store、Generic Key-Value Store、Generic Authentication State Machine 或 Generic Navigation Coordinator framework。

Secure credential adapter可先建立、測試與完成DI shape，但在migration coordinator與lifecycle integration完成前不得提前成為production唯一authority。切換source of truth只允許在Milestone 19-4進行。

Milestone 19-0 Planning Review另拍板：

- Credential read使用`absent / present / corrupted` sealed result；Secure Storage operational unavailable拋typed local-storage `AppException`，不得被當成absence。
- `AuthCredentialMigrationCoordinator`是唯一migration policy owner，但不自行取得`AuthStateMutationCoordinator`；Lifecycle owner必須先取得一次exclusive ownership。
- 目前mutation coordinator不可重入，禁止在`runExclusive`內再次等待`runExclusive`；已持有ownership的內部流程使用`...Unlocked` helper。
- Milestone 19不建立persistent migration marker；migration phase由Secure、Legacy與User的真實store state推導。
- Secure read operational failure不得fallback Legacy；Secure payload corrupted時不得以Legacy覆蓋，必須清除完整Auth state並維持未登入。
- Secure已驗證且只有Legacy cleanup失敗時，Secure仍為權威，可繼續restore，但必須non-fatal report並在後續Auth lifecycle重試cleanup。
- Interactive Logout與passive invalidation都必須清除runtime Session並嘗試清除三個store；unknown cleanup error不得被空catch吞掉。

完整Threat Model、Decision Matrix、findings與Gate結論位於：

```txt
docs/audits/milestone_19_planning_review.md
```

### Review gates

每個 Milestone 都採下列 gate：

```txt
Planning / Architecture Review
  ↓
Approved implementation phases
  ↓
Implementation Review
  ↓
Regression / Platform Evidence
  ↓
Documentation / Baseline Decision
```

Milestone 19 Planning Review 通過前，不新增 `flutter_secure_storage`、不修改 Auth persistence production code、不修改 Native 設定，也不更新 VERSION。

Milestone 20 Planning Review 通過前，不新增 OTP API、route、Bloc 或 UI production code，也不假設任何實際 SMS provider。

Milestone 20-0 Planning Review已於2026-07-21通過，正式補充以下contract：

- Password Login使用`authenticated | otpChallenge` discriminated typed union，不使用nullable credential / challenge欄位組合。
- OTP Verify成功是OTP流程唯一可進入Secure credential、SQLite User與runtime Session commit的boundary；Password Login直接authenticated時共用相同commit helper。
- OTP Resend成功必須回傳完整replacement challenge與新的`challengeId`，predecessor challenge及其in-flight Verify / Resend response立即失去authority。
- Login、Verify、Resend、Restore、Logout與account switch共用既有`AuthStateMutationCoordinator`latest-intent generation；Repository以generation在credential、User與Session commit前阻擋stale response，Bloc active challenge identity只保護presentation metadata與state transition。
- OTP pending時`SessionManager`維持unauthenticated，Protected Route繼續只依SessionManager，不改為依賴AuthBloc。
- Challenge只保存Server提供的opaque identity、UTC expiration、masked destination、resend availability與optional attempts metadata；Client不持久化OTP code，也不自行推導完整destination或attempt limit。

完整Threat Model、state transition、findings與implementation phase位於：

```txt
docs/audits/milestone_20_planning_review.md
docs/superpowers/plans/2026-07-21-milestone-20-implementation-plan.md
```

Planning Gate通過只代表20-1可以在後續獨立工作開始，不代表已存在OTP production capability，也不允許跨階段提前加入UI、provider SDK或更新VERSION。

Milestone 21 Planning Review 通過前，不新增 `local_auth`、不修改 Android Native configuration，也不宣稱 Face ID / Touch ID runtime support。

Milestone 21-0 Planning Review已於2026-07-21通過，正式補充以下contract：

- local unlock preference與device capability分離；既有使用者預設disabled，不能因偵測到hardware而自動啟用。
- Enabled cold start必須在credential restore與Session commit前完成local user-presence verification；不得先建立Session再以UI遮罩。
- Locked與prompting階段`SessionManager`維持null，因此Guard、Dio、Refresh、Profile與navigation不會提前取得authenticated authority。
- Cancel、not-enrolled、no hardware、unsupported、temporary / permanent lockout不得fallback自動restore；提供retry或重新登入安全出口。
- App-owned coordinator持有prompt、startup與resume orchestration；Repository仍是credential、User與Session restore commit owner。
- Unlock、Login、OTP、Logout、external clear與resume re-lock共用既有Auth lifecycle latest-intent authority；Bloc / UI generation只保護presentation metadata。
- Cold start每次重新unlock；background resume使用可注入5分鐘grace period，prompt自身lifecycle抖動不得產生第二個prompt。
- `local_auth`只在App layer，Android Native設定延後21-5；其他平台不提升runtime support。

完整Threat Model、state machine、findings與implementation plan位於：

```txt
docs/audits/milestone_21_planning_review.md
docs/superpowers/plans/2026-07-21-milestone-21-implementation-plan.md
```

Planning Gate通過只允許後續獨立開始21-1，不代表Biometric production capability已存在，也不允許提前修改Native或VERSION。

### 版本規則

- Milestone 規劃、audit 與 review 落檔不更新 VERSION。
- 每個 Milestone 完成後可獨立決定是否發布新的 Template Baseline。
- 不預先承諾 1.3.0、1.4.0 或其他版本號；版本只在 final baseline review 時決定。

Milestone 19 final baseline review已依此規則判定為新的可交付Template能力，正式發布1.3.0；此決定不預先承諾Milestone 20或21的版本號。

### Milestone 20 Final Decision

Milestone 20於2026-07-21完成並封存，最終contract如下：

- Login wire與Domain result均為`authenticated | otpChallenge` closed union。
- 只有Direct Login authenticated與Verify success可進入共用Secure credential → AuthUser → Session commit helper。
- Repository lifecycle generation是credential、User與Session side-effect的唯一stale-response authority。
- Bloc presentation generation與active challenge identity只保護UI metadata與state transition，不反向補償Repository commit。
- OTP pending不保存credential、不建立Session，也不通過Protected Route。
- Resend成功回傳完整replacement challenge並使predecessor失效；UI cooldown只是authoritative `retryAt` / `resendAvailableAt`的projection。
- Invalid code attempts與Resend cooldown使用typed metadata，不解析backend message。
- App composition layer持有Login → OTP → Profile與clear → Login navigation；Auth pages不持有Shell或跨feature routing authority。
- Password、OTP code、Token與raw challenge identity不得出現在generated／manual `toString()`、reporting context或production log。

Security scope只涵蓋server-issued OTP step-up authentication flow，不宣稱SIM-swap prevention、SMS delivery assurance、provider compromise defense、rooted-device defense或server compromise defense。

Final review確認11項planning findings均有implementation與regression evidence，無Open P0 / P1。此能力構成新的可交付模板功能，因此Template Baseline由1.3.0提升至1.4.0。

### 非目標

- Cryptographic Device Binding。
- Passkey。
- TOTP Authenticator enrollment。
- QR Code enrollment。
- Recovery codes。
- Firebase Auth。
- SMS provider SDK。
- Root / Jailbreak detection。
- iOS Face ID runtime support。
- Web、Windows、macOS、Linux biometric runner。
