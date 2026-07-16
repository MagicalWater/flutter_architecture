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

### Auth Session / Refresh

- 完整 Token Pair persistence。
- SessionManager runtime generation / userId identity。
- Main Dio 與 Refresh Dio 分離。
- Concurrent 401 single-flight refresh。
- Refresh token rotation 與 persistence-first runtime update。
- Session-aware safe request replay。
- Logout / relogin / account-switch race protection。

---

## 已完成狀態

### Milestone 12：Refresh Token + Concurrent 401 Handling

狀態：Completed。

已完成：

- Login、Mock、DTO、Domain 與 persistence 全面支援 access token + refresh token。
- `AuthSessionRefresher` 以 generation / userId / failed token 管理 identity-aware single-flight refresh。
- Main Dio 安裝 `AuthHeaderInterceptor` 與 `AuthRefreshInterceptor`；Refresh Dio 不安裝 auth interceptors。
- Refresh 成功先保存 rotated Token Pair，再更新 SessionManager runtime access token。
- 只有同一 Session identity 且可安全重送的 authenticated request 才允許 replay。
- `authRetryCount` 防止 replay 再次 401 形成無限 retry。
- Stream、Multipart、upload、progress callback 與特殊 download request 不自動 replay。
- Invalid refresh credential 或缺少 refresh token 會 best-effort 清除 Token Pair、User 與 SessionManager。
- Timeout、connection error、5xx、一般 400 與 malformed success 不會錯誤清除 Session。
- AuthBloc、ProfileBloc、AuthGuard 透過 SessionManager 自然同步 Session expiration。
- 已覆蓋 10-request concurrent 401、account switch、logout/relogin、persistence failure、cleanup failure、Login / Restore / Logout / AuthGuard / Profile regression，以及 Mock / Real Composition Root graph。
- `dart pub get`、build_runner、analyze、全部 flutter test，以及 development / staging / production bundle build 均已通過。

主要 commits：

```txt
d73f6d3 test(auth): 完成 Milestone 12-6 regression coverage
ec7acd2 feat(auth): 完成 Milestone 12-5 Session Expiration UI Flow
c2c3ad6 feat(auth): 完成 Milestone 12-4 Safe Request Replay
e5ee421 feat(auth): 完成 Milestone 12-3 Concurrent 401 Interceptor
```

---

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

## 已完成狀態

### Milestone 3：Auth + Profile Flow

狀態：Completed（前次 build bundle 因工具安全檢查擋下，未能重跑；Milestone 4 收尾會重新驗證）。

已完成：

- Milestone 3-1 Login Flow：LoginPage → AuthBloc → LoginUseCase → AuthRepository → Remote / Local → SessionManager 已串好。
- Milestone 3-2 Profile Flow：ProfileBloc 透過 SessionManager 判斷登入狀態，已登入時呼叫 GetProfileUseCase，ProfilePage 顯示目前登入用戶名稱，並補上 ProfileBloc 測試。
- Milestone 3-3 Navigation Flow：Login 成功後切換到 Profile tab，Logout 成功後回到 Login tab，AuthBloc 會監聽 SessionManager 避免跨 feature 登出後 UI state 與 Session state 不同步。
- Milestone 3-4 Protected Route Flow：ProtectedRoute 已掛上 AuthGuard，AuthGuard 依賴 SessionManager 判斷可否進入，ProtectedPage 不依賴 AuthBloc，並補上 AuthGuard 測試。
- Milestone 3-5 End-to-End 驗收：補上 AuthBloc restore session 測試，並以 AuthBloc / ProfileBloc / AuthGuard 測試覆蓋 Login、Profile、Logout、ProtectedRoute 的核心狀態流。

---

## 已完成狀態

### Milestone 4：Route Guard 與頁面整理

狀態：Completed。

已完成：

- ShellPage 有 AppBar 與 BottomNavigationBar。
- LoginRoute / ProfileRoute 是 ShellRoute 的 nested routes。
- AppBar action 可以 push ProtectedRoute。
- ProtectedRoute 已掛上 AuthGuard。
- 未登入進 ProtectedRoute 會由 AuthGuard 導回 ShellRoute(LoginRoute)。
- ProtectedPage 已整理成純展示頁，不直接讀取 SessionManager，也不依賴 DI container。
- 已補上 AppRouter route 結構測試與 ProtectedPage widget test。
- analyze / flutter test / flutter build bundle 已通過。

---

## 已完成狀態

### Milestone 5：整理與驗證

狀態：Completed。

目標：收尾第一階段 MVP，確認文件、程式碼可讀性與完整驗證流程都達到可交付狀態。

已完成：

- Milestone 5-1 文件整理：已同步 README 與目前實際架構，並確認 `project_context.md`、`docs/archive/progress_v1.0.0.md`、`roadmap.md` 狀態一致。
- Milestone 5-2 程式碼整理：已補齊重要中文註解、清理 import、檢查命名一致性，並整理暫時性或冗餘程式碼。
- Milestone 5-3 最終驗收：`dart pub get`、`melos run build_runner`、`melos run analyze`、`melos exec -- flutter test`、`flutter build bundle` 全部通過。

完成定義：

- 程式碼結構清楚。
- 文件符合繁中規範。
- MVP 功能可以跑通。
- `dart pub get` 通過。
- `melos run build_runner` 通過。
- `melos run analyze` 通過。
- `flutter test` 通過。
- `flutter build bundle` 通過。

---

## 已完成狀態

### Milestone 6：Melos 8 / Pub Workspaces Migration

狀態：Completed。

已完成：

- 先執行 `dart run melos clean`，清掉舊版 bootstrap 狀態。
- root `pubspec.yaml` 已升級為 Melos 8 + Dart Pub Workspaces 設定。
- workspace package 清單已移到 root `pubspec.yaml` 的 `workspace:`。
- Melos scripts 已移到 root `pubspec.yaml` 的 `melos:`。
- 各 app / package 已加上 `resolution: workspace`。
- SDK constraint 已升級為 `>=3.8.0 <4.0.0`。
- 舊版 bootstrap 產生的 `pubspec_overrides.yaml` 已移除。
- 純 Dart package 測試已改用 `flutter_test`，避免 workspace resolution 與 Flutter SDK pinned dependencies 衝突。
- `build_runner` script 使用 `dart run build_runner build`，並加上 `--order-dependents --concurrency=1`，避免乾淨 workspace 下游 package 早於上游 generated files 完成。
- `dart pub get`、`dart run melos run build_runner`、`dart run melos run analyze`、`dart run melos exec -- flutter test`、`flutter build bundle` 全部通過。

---

## 已完成狀態

### Milestone 7：Dependency Upgrade

狀態：Completed。

已完成：

- 重新執行 dependency audit，確認現有 constraints 下無可直接升級的 direct dependency。
- 升級 generator / DI / router stack：`build_runner`、`freezed`、`json_serializable`、`get_it`、`injectable`、`auto_route`。
- 升級 lint stack：`flutter_lints`、`lints`。
- SDK constraint 升級為 `>=3.8.0 <4.0.0`。
- `build_runner` script 改為 `dart run build_runner build`。
- Freezed 3 相容性修正：`@freezed` class 改為 `abstract class`。
- AutoRoute 11 相容性修正：router test 改為直接讀取 `children` list。
- `dart pub get`、`dart run melos run build_runner`、`dart run melos run analyze`、`dart run melos exec -- flutter test`、`flutter build bundle` 全部通過。

未升級項目：

- `meta`
- `sqflite`
- `sqflite_common_ffi`
- `sqflite_common_ffi_web`
- `auto_route_generator` 10.6.0
- `injectable_generator` 3.1.0
- 部分 transitive dependencies

### Milestone 8：Modernization Review

狀態：Completed。

已完成：

- 完成 Freezed / AutoRoute / GetIt / Injectable / Flutter / Dart Best Practice Review。
- Bloc Event union type 已改為 `sealed class`，符合 Freezed 3 union 語意。
- Data model / Entity / State 維持 `abstract class`，避免不必要的 sealed 限制。
- GetIt / Injectable 註冊方式維持現狀，沒有需要立即處理的 deprecated API。
- AutoRoute 沒有使用 11.0 移除的 named-route APIs 或舊 redirect API。
- `dart pub get`、`dart run melos run build_runner`、`dart run melos run analyze`、`dart run melos exec -- flutter test`、`flutter build bundle` 全部通過。

---

## 已完成狀態

### Package DI Boundary Review

狀態：Completed。

已完成：

- 新增 Architecture Decision 012：可重用 package 不直接綁定 DI framework。
- `packages/auth` 已移除 `injectable` dependency。
- `packages/auth` 內 data source、repository、use case 已移除 DI annotations。
- Auth package 物件仍由 app 的 `RegisterModule` 統一註冊與組裝，維持 app 作為唯一 Composition Root。
- `packages/auth`、`packages/api_client`、`packages/core` 已確認無 package-level DI annotation 殘留。
- 已新增 `AGENTS.md`，作為 AI coding agent / assistant 的 repo root 工作守則。
- `dart pub get`、`dart run melos run analyze`、`dart run melos exec -- flutter test`、`flutter build bundle` 已通過。

備註：本次 `dart run melos run build_runner` 因工具安全檢查擋下，未能重跑；本次未修改 source generator input，不影響 generated files。

---

## 下一個工作目標

### Milestone 13：Pagination + Search Debounce

狀態：In Progress；Milestone 13-1 與 13-2 已完成。

Milestone 11 CI/CD 維持 Deferred，不處理。Milestone 12 已全部完成。

Milestone 13 已拍板 Architecture Decision 016，核心方向如下：

```txt
Catalog feature
  作為 Pagination + Search 的完整垂直切片

Pagination
  使用 cursor-based
  request = query + cursor + limit

Search debounce
  300 ms
  trim + distinct
  位於 CatalogBloc event pipeline

Stale response protection
  search generation + query + requested cursor

Load More
  state guard + in-flight suppression + response identity validation

Cancellation
  logical cancellation
  不讓 Dio CancelToken 穿透 Presentation / Domain

Offline Cache
  不屬於 Milestone 13，留給 Milestone 14
```

已拍板的重要規則：

- 使用具有業務語意的 Catalog feature，不建立 pagination / search 技術型 feature。
- 正式 Pagination contract 使用 cursor-based，不同時實作 page-based strategy。
- 第一頁與 Refresh 使用 `cursor = null`；Load More 使用 response `nextCursor`。
- `nextCursor` 是是否可繼續載入的唯一 source of truth，不另存獨立 `hasMore` state。
- Query、filter、sort 或 search generation 改變後，不得沿用舊 cursor。
- Mapper 將空 cursor 正規化為 null；Repository 驗證 request / response cursor chain 是否能前進。
- Catalog 使用 public demo endpoint，不與 Auth Session 或 authenticated metadata 綁定。
- `SearchCatalogUseCase` 表達單一搜尋業務行為；Initial、Refresh、Append 是 Bloc workflow。
- Page 只發送 event，不自行管理 Timer、Repository 或 cancellation。
- Debounce duration 可注入，測試可使用 `Duration.zero`。
- 每個 logical search 使用 monotonically increasing generation。
- 即使 event handler 被 restart，仍必須使用 generation guard 防止底層 Future 的舊 response emit。
- Load More 同時使用 state guard、in-flight event suppression 與 generation/query/cursor validation；不額外引入 `bloc_concurrency`。
- Refresh 遞增 generation，使舊 Initial / Append operation 過期。
- Initial、Refresh、Append 的 loading 與 failure state 分開建模。
- Append 由 Bloc 依穩定 Domain ID 去重並保留原順序；Refresh 成功整批替換。
- Milestone 13 只保證 logical cancellation，不讓 Dio `CancelToken` 穿透架構邊界。
- 不建立 Generic Pagination Bloc、PaginationController 或多 strategy framework。
- Milestone 14 再於 Repository implementation 加入 Remote + Local cache coordination。

目前進度：

- Milestone 13-1 Architecture Decision 與 Feature Contract 已完成。
- Milestone 13-2 Catalog API、DTO、Mock 與 Retrofit Contract 已完成。
- 已新增 public Retrofit `CatalogApi`，使用 `query`、`cursor`、`limit` query parameters。
- 已新增 `CatalogItemDto`、`CatalogPageResponseDto` 與 generated JSON / Freezed code。
- Nested item serialization 使用明確 field converter，確保 DTO JSON round-trip 正確。
- 已新增 `MockCatalogApi`，使用 opaque `offset:<n>` cursor，支援搜尋、多頁資料與最後一頁 null cursor。
- Mock cursor 會綁定 normalized query identity，舊 query cursor 不得套用到新 query。
- App `ApiImplementationSelector` 已支援 Mock / Real Catalog API selection。
- 已驗證第一次 request 不傳 cursor、下一頁傳遞 cursor、public endpoint 不標記 requiresAuth、Mock pagination/search 與 DTO serialization。
- api_client 目標測試、selector tests、workspace analyze 與全部 flutter tests 已通過。

正式實作順序：

```txt
Milestone 13-1：Architecture Decision 與 Feature Contract
  ↓
Milestone 13-2：Catalog API、DTO、Mock 與 Retrofit Contract
  ↓
Milestone 13-3：Domain、Mapper、RemoteDataSource 與 Repository
  ↓
Milestone 13-4：Initial Search、Debounce 與 Query Switching
  ↓
Milestone 13-5：Load More、Refresh 與 Failure Recovery
  ↓
Milestone 13-6：Page、Route、DI 與 UI Flow
  ↓
Milestone 13-7：Regression、文件與完整驗證
```

下一個實作階段：Milestone 13-3 Domain、Mapper、RemoteDataSource 與 Repository。Catalog route 與 Shell UI 入口可在 13-6 實作前依現有 Shell 結構做最小決定。

---

## Milestone 9 完成摘要

### Milestone 9：Retrofit API Client Standardization

狀態：Completed。

Milestone 9-1 至 Milestone 9-6 已全部完成。

已拍板：

- 所有真實 HTTP API 必須使用 Retrofit。
- Mock API 可以手寫，但必須與 Retrofit implementation 實作相同 API abstraction。
- Retrofit abstract class 本身即為 API abstraction，不額外增加純轉呼叫 adapter。
- App Composition Root 負責選擇 Mock 或 Retrofit implementation。
- RemoteDataSource 不直接操作 Dio。
- RemoteDataSource 負責將 transport exception 映射為 Data Layer exception，Repository 再映射為 Failure。
- Retrofit 負責 HTTP 與 JSON 到 DTO；DTO 到 Domain Entity 仍由 Mapper 處理。
- Mapper 只負責純資料轉換，不處理持久化與 Session 更新。
- DTO 使用 `RequestDto` / `ResponseDto` 命名，Domain Model 不帶 `Dto`。
- package 內仍不直接綁定 DI framework。
- Mock implementation 放在明確的 `mocks/` 目錄。

Auth API 已完成：

- `AuthApi` 由 Retrofit abstract class 宣告。
- `_AuthApi` 由 Retrofit generator 產生真實 HTTP implementation。
- `MockAuthApi` 實作相同 API abstraction，Demo 預設注入此實作。
- Login request / response 已改為 `LoginRequestDto` / `LoginResponseDto`。
- Profile response 已改為 `ProfileResponseDto`，並由 mapper 轉為 Profile Domain Entity。
- Profile 真實 HTTP declaration 已改為 Retrofit `ProfileApi`，Demo 預設注入 `MockProfileApi`。
- `GET /profile` 使用 request extra metadata 標記 authenticated request，並已由測試驗證 metadata 會進入 Dio `Options.extra`。
- 已新增 Retrofit request test，驗證 `POST /auth/login`、JSON request serialization 與 response DTO parsing。
- `LoginRequestDto` 明確宣告 `toJson()` contract，確保 Retrofit generator 產生正確的 request serialization。
- Login response mapper 位於 `packages/auth` data layer。
- DioException 的辨識與 AppException 轉換留在 `packages/api_client`，`packages/auth` 不直接依賴 Dio。

DI 與環境切換已完成：

- App layer 提供最小 `ApiConfig` / `ApiMode`，package 不依賴 GetIt / Injectable。
- `API_MODE=mock|real` 決定 Auth / Profile 注入 Mock 或 Retrofit implementation。
- `API_BASE_URL` 由 App Composition Root 注入 Dio。
- 未提供 `--dart-define` 時預設使用 Mock mode 與 `https://mock.local`。
- `ApiImplementationSelector` 集中 Mock / Real 選擇邏輯，並已測試兩種 mode。
- Profile 新增 `ProfileRemoteDataSource`，與 Auth 一致在 remote boundary 將 DioException 轉為 AppException。
- Auth / Profile Repository 只將 AppException 轉為 Failure，未知錯誤保留原始 stack trace。
- AuthLocalDataSource 將 SharedPreferences / SQLite 錯誤轉為 AppException。
- 共用 `mapAppExceptionToFailure` 使用 domain fallback message，並保留 code 與 cause 作為診斷資訊。
- `API_MODE=real` 時必須明確提供合法 `API_BASE_URL`，避免誤用 mock 預設網址。
- `SessionManager` 只管理 runtime session state；token / user persistence 統一由 `AuthRepositoryImpl` 協調。
- `LoginRequestDto` 關閉欄位型 `toString()`，避免帳號密碼進入一般 log。
- Dio transport failure 只保留不含 body / headers / token 的安全摘要，不再把完整 `DioException` 帶入 `Failure.cause`。
- Mock Auth / Profile、DTO JSON serialization、DTO mapper、Retrofit request、transport exception、Repository regression tests 已補齊。
- 已驗證 Repository 只轉換 `AppException`；未知錯誤不會被包成一般 Failure。

實作順序：

```txt
Auth API
  ↓
Profile API
  ↓
DI / Environment selection
  ↓
Mapper / Error boundary
  ↓
Test / Analyze / Build
```

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

### 5. 可重用 package 不直接綁定 DI framework

`packages/auth`、`packages/api_client`、`packages/core` 預設不直接依賴 `get_it` / `injectable`。

package 內 class 使用 constructor injection 表達依賴，但 DI lifecycle 與介面綁定由 app 的 Composition Root 決定。

目前 Auth 相關 data source、repository、use case、session 物件由：

```txt
apps/flutter_architecture/lib/app/di/register_module.dart
```

統一註冊與組裝。

### 6. hooked_bloc 的定位

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
dart pub get
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
AGENTS.md
README.md
CHANGELOG.md
VERSION
docs/project_context.md
docs/architecture_decisions.md
docs/roadmap.md
docs/conversation_rules.md
```

閱讀後依照 `docs/roadmap.md` 與 `CHANGELOG.md` 判斷下一個目標。
