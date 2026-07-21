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

狀態：Completed；Milestone 13-1 至 13-7 已完成。

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

目前提案的重要規則：

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
- Milestone 13-3 已新增 `CatalogItem`、`CatalogPage`、`CatalogRepository` 與 `SearchCatalogUseCase`。
- `CatalogPage.hasMore` 只由 `nextCursor != null` 衍生，不保存第二份 pagination state。
- `CatalogRemoteDataSource` 只負責 API 呼叫與 transport exception mapping。
- DTO Mapper 只將空 cursor 正規化為 null，非空 opaque cursor 與 Domain identity 欄位原樣保留；空 id / name 仍會被拒絕。
- `CatalogRepositoryImpl` 會驗證 request / response cursor 是否前進，並將 `AppException` 映射為 domain `Failure`；未知錯誤維持原樣拋出。
- Catalog data layer 12 個目標測試、workspace analyze 與全部 flutter tests 已通過。
- Milestone 13-4 已新增 `CatalogBloc`、`CatalogEvent` 與 `CatalogState`。
- `queryChanged` 使用預設 300ms、可注入 duration 的 RxDart debounce + normalized distinct transformer。
- Query 僅做 trim，不預設轉小寫；空 query 仍會載入預設 Catalog 清單。
- `hasCompletedInitialLoad` 會區分「尚未載入」與「成功但結果為空」，避免初始 state 被誤判為 empty result。
- Initial loading、initial failure 與 empty result 已分離建模；Refresh / Append state shape 已預留但 workflow 留待 13-5。
- `CatalogBloc` 會 fail fast 拒絕非正數 page size；測試輪詢 helper 也加入明確 timeout。
- 每次 logical initial search 都遞增 generation，response 需同時符合 generation 與 query identity 才能更新 state。
- Catalog Bloc 8 個目標測試涵蓋 initial state、page size validation、debounce、distinct、跨 query stale response、同 query generation guard、initial failure 與 empty result。
- Milestone 13-5 已完成 Load More、Refresh 與 Failure Recovery。
- Load More 使用 state guard 與 RxDart exhaust transformer，同一時間最多一個 append request。
- Append response 驗證 generation、query 與 requested cursor，並依穩定 Domain ID 去重、保留既有 item 與順序。
- Append failure 保留 items 與 cursor，清除 failure 後可使用相同 cursor retry；`nextCursor == null` 時不再請求。
- Refresh 使用目前 query 與 `cursor = null`，遞增 generation 並使舊 Initial / Append response 過期。
- Refresh 成功整批替換 items 與 cursor；失敗保留既有資料並以 `refreshFailure` 表達。
- Catalog Bloc 18 個目標測試已涵蓋 initial、debounce、append 防重、cursor、去重、retry、end reached、refresh success/failure、race protection，以及 Initial / Append / Refresh 未知錯誤的 loading cleanup 與 retry。

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

Milestone 13-6 已完成 CatalogPage、Search、List、Empty、Initial / Refresh / Append loading 與 failure surfaces、scroll load more、pull-to-refresh、Catalog route 與 Shell tab。
Catalog API、RemoteDataSource、Repository、UseCase 與 Bloc 已完成 Composition Root registration，Mock / Real graph 與 route 已驗證；完整 Page widget coverage 留在 Milestone 13-7。
Shell tab index 已由 `ShellTab` 統一定義，避免新增 tab 後登入成功導向錯誤頁面；Catalog refresh callback 使用單一 lifecycle subscription，避免快速完成時遺失完成 state。

Milestone 13-7 已完成 regression、Catalog widget coverage、文件同步與完整環境驗證。
最終驗證已通過 `dart pub get`、workspace build_runner、analyze、全部 Flutter tests，以及 development / staging / production bundle build；Flutter App 測試共 72 項。

下一個正式實作階段：Milestone 14 Offline Cache。

### Milestone 14：Offline Cache

狀態：Completed；Milestone 14-1 至 14-7 已完成。

Architecture Decision 017 已完成 review 並正式接受，核心方向如下：

```txt
Catalog feature-level opt-in cache
  不建立 generic HTTP cache

Initial / Query Switching
  Cache-first + Stale-While-Revalidate

Refresh
  強制 Remote
  成功後 replacement 第一頁並重設 cursor chain

Append
  query + requested cursor + limit 單次 page cache
  第一版不做 background revalidation

Freshness
  freshFor / retainFor

Storage
  SQLite page metadata + ordered page items

Presentation metadata
  isUsingCachedData
  isStale
  lastUpdatedAt
  isRevalidating
  revalidationFailure
```

已拍板的重要規則：

- Cache 只對 Catalog 明確 opt-in，不自動快取 Login、Refresh Token、交易、付款或 command API。
- Initial Search 與 Query Switching 使用 Cache-first + SWR；Fresh Cache 可直接回傳，Stale Cache 先顯示再背景更新。
- Pull-to-refresh 強制 Remote；Refresh failure 保留既有資料。
- Cache identity 為 normalized query + request cursor + limit；query 只 trim，不預設轉小寫。
- 第一頁與後續頁以 cursor page 儲存，不保存單一合併 List。
- Initial Cache miss、stale revalidation 與 Refresh 的 Remote 第一頁成功，都需 replacement 第一頁並失效同 query + limit 的舊後續 cursor chain。
- Repository contract 使用 `CatalogLoadPolicy.initial / refresh / append`；initial / refresh 必須使用 null cursor，append 必須使用 non-null cursor，其他組合 fail fast。
- Initial 使用 SWR 多次 emission；Refresh 使用 Remote-only 單次 emission；Append 使用 page cache hit 或 Remote fallback 的單次 emission。
- DTO、Local Entity、Domain Entity 維持分離；SQLite representation 不穿透 Data Layer。
- Repository implementation 負責 Remote + Local 協調，Initial SWR 使用明確 Stream emission contract。
- Domain snapshot 只描述 page、source、freshness 與 lastUpdatedAt；`isRevalidating`、`revalidationFailure` 留在 Bloc workflow state。
- Append 第一版只做 page cache hit / miss，不做背景 revalidation。
- 畫面級 cached / stale / lastUpdatedAt metadata 只代表第一頁 snapshot。
- Remote success 但 Cache write failure 仍可顯示 Remote data；Catalog cache failure 不採 Auth credential 的 fatal persistence policy。
- UI 不以單次 timeout / DNS / 5xx 推測全域 `isOffline`，改用 cached / stale / revalidation metadata。
- App database 預計由 version 1 升級為 version 2，migration 必須保留 `auth_user`。
- Catalog 是 public endpoint，因此 Logout 不清除 Catalog Cache。
- App 維持唯一 Composition Root，不建立 Generic Cache / Generic Pagination framework。

正式實作順序：

```txt
Milestone 14-1：Architecture Decision 與 Cache Contract（Completed）
  ↓
Milestone 14-2：SQLite Schema、Migration 與 Local Models（Completed）
  ↓
Milestone 14-3：Repository Cache Coordination（Completed）
  ↓
Milestone 14-4：Initial Search、Query Switching 與 SWR Bloc Flow（Completed）
  ↓
Milestone 14-5：Refresh、Append 與 Cursor Chain
  ↓
Milestone 14-6：UI、DI 與 Offline Cache Flow
  ↓
Milestone 14-7：Cleanup、Regression、文件與完整驗證
```

Milestone 14-2 已完成：

- App database version 已由 1 最終升級為 3；v2 建立 Catalog Cache tables，v3 升級 unique position index。
- 新增集中式 `AppDatabaseSchema`，管理 onCreate、v1 → v2 與 v2 → v3 migration。
- 新增 `catalog_cache_page`、`catalog_cache_page_item` 與 page item order index。
- Local item row 保存 id、name、description 與 position，確保 Domain 完整 round-trip。
- 新增 `CatalogCachePageEntity`、`CatalogCacheItemEntity` 與 Local Mapper。
- 新增 `CatalogLocalDataSource`，支援 page read、transaction replacement、chain reset、delete 與 expired page lazy cleanup。
- 第一頁 null cursor 只在 SQLite boundary 編碼為空字串，不穿透 Domain。
- migration test 已確認保留既有 `auth_user`。
- Local Entity validation、corrupted page 自我清除、empty page、delete isolation、failure mapping、transaction rollback、query/cursor/limit identity、cursor sentinel 防護、replacement、chain reset 與 migration tests 已通過。

Milestone 14-3 已完成：

- 新增 `CatalogCachePolicy` 與可注入 `CatalogClock`。
- 新增 `CatalogPageSnapshot`、`CatalogDataSource`、`CatalogFreshness` 與 `CatalogLoadPolicy`。
- `initial` 支援 Fresh Cache 單次結果與 Stale Cache → Remote 多次 emission。
- `refresh` 使用 Remote-only；`append` 使用 retained page Cache 或 Remote fallback。
- Cache read / write failure 不覆蓋 Remote success；未知錯誤保留 Stream error channel。
- Remote cursor 驗證通過後才寫入 Cache，第一頁 success 會重設 cursor chain。
- App Composition Root 明確註冊 LocalDataSource、CachePolicy、Clock 與 Repository。
- Milestone 14-4 已完成 Presentation 遷移，舊單次 Repository / UseCase API 已移除。
- Implementation review 已將 Repository dependencies 全部改為 required，避免宣稱支援 SWR 卻缺少 Local / Policy / Clock 的半配置 instance。
- Append 空字串與空白 cursor 會 fail fast，不再被誤當 Cache miss 後傳給 Remote。
- `updatedAt` 位於未來時會視為 Stale 並 revalidate，不會形成 Fresh-only Cache。
- 16 項 Repository contract tests 已涵蓋 freshFor / retainFor 精確邊界、未來 timestamp、Cache read/write failure 分離、三種 policy、cursor validation 與未知錯誤。
- build_runner、workspace analyze 與完整 tests 已通過。

Milestone 14-4 已完成：

- CatalogBloc Initial / Query Switching 已改為消費 Repository Stream。
- Cache snapshot 可先完成 initial loading；Stale Cache 會標記 `isRevalidating`。
- Remote success 會替換 items、cursor、source、freshness 與 lastUpdatedAt。
- Remote failure 若已有 Cache，保留資料並寫入 `revalidationFailure`，不產生 blocking initial failure。
- Query switching 會取消舊 SWR subscription，並保留既有 generation / query stale-response guard。
- CatalogState 已新增 `isUsingCachedData`、`isStale`、`lastUpdatedAt`、`isRevalidating` 與 `revalidationFailure`。
- Refresh / Append 已遷移到相同 Stream contract，但 workflow metadata 的完整整合留在 Milestone 14-5。
- 21 項 CatalogBloc tests、build_runner、workspace analyze 與完整 tests 已通過。
- Implementation review 已將所有第一頁載入統一到可取消的 SWR subscription boundary；Initial、Query switching、Retry 與 Refresh 都會先取消舊第一頁 subscription。
- Refresh 會取消 stale revalidation，並以 Remote snapshot 完整更新 cached / stale / lastUpdatedAt metadata。
- Stale Cache 後 Stream 若直接關閉，會視為 protocol violation，不再無聲清除 `isRevalidating`。
- CatalogBloc tests 已增至 24 項，補齊跨事件 cancellation 與 protocol violation coverage。

Milestone 14-5 已完成：

- Refresh 使用目前 query 與 `cursor = null` 強制 Remote。
- Remote 第一頁成功會 replacement 第一頁，並失效同 query + limit 的舊後續 cursor chain。
- Refresh failure 保留既有 items、nextCursor 與 cached / stale / lastUpdatedAt metadata。
- Append 以 requested cursor page identity 讀寫 Cache。
- Append 支援 retained Cache hit、Cache miss Remote fallback 與 expired Cache replacement，第一版不執行背景 revalidation。
- Append Cache snapshot 只合併 items 與更新 nextCursor，不會覆蓋第一頁 freshness metadata。
- Refresh / Append 共用 single-result Stream protocol helper；零筆與多筆 emission 都視為 programming error，並確保 loading flag 清除。
- Repository Cache tests 已增至 19 項，CatalogBloc tests 已增至 28 項。
- Implementation review 已補強 stale Append late-write：Append page 只有在 requested cursor 仍由目前 Cache chain 指向時才允許 transaction write。
- Bloc 追蹤已消耗 requested cursors，若 nextCursor 回到任何已消耗 cursor，會回傳 `cyclic_catalog_cursor` 並停止推進。
- Local boundary 拒絕 `requestCursor == nextCursor` 的 self-loop page。
- Refresh 使用 exhaust transformer，快速重複事件只建立一個 request。
- Initial / Query / Refresh / Bloc close 會取消執行中的 Refresh 與 Append Stream，不再只靠 generation guard 忽略結果。

Milestone 14-6 已完成：

- Catalog UI 會在列表上方顯示 cached / stale status，不遮蔽既有資料。
- Cache status 顯示 UTC `lastUpdatedAt`。
- Background revalidation 使用小型 progress indicator，與 user Refresh loading 分離。
- Revalidation failure 以 non-blocking 訊息呈現，items 與 pull-to-refresh 保持可用。
- Fresh Remote data 不顯示 Cache status；Fresh Cache 與 Stale Cache 使用不同 notice。
- App Composition Root 已完整註冊 Catalog LocalDataSource、RemoteDataSource、CachePolicy、Clock、Repository、UseCase 與 Bloc。
- Mock / Real graph tests 已明確驗證完整 Catalog dependency graph。
- Catalog Widget tests 已涵蓋 cached、stale、lastUpdatedAt、revalidation loading、non-blocking failure 與 Fresh Remote notice suppression。
- Implementation review 已修正 `requestCatalogRefresh` 在既有 Refresh lifecycle 中可能永久等待的問題。
- Empty result 的 Refresh failure 會與 empty content 同時呈現，不再因 `CatalogState.isEmpty` 的 failure 語意走錯 branch。
- Revalidation UI tests 已拆成正式狀態機中的更新中與更新失敗兩種互斥狀態。
- DI tests 已鎖定 LocalDataSource / CachePolicy / Clock / Repository 為 singleton，UseCase / CatalogBloc 為 factory，並明確 close 測試 Bloc。

Milestone 14-7 已完成：

- retention-based expired cleanup 已由 LocalDataSource 與 Repository boundary tests 鎖定。
- 新增 Auth / Catalog 共用 SQLite database 的 Logout integration test；Logout 清除 token、user 與 runtime Session，但 public Catalog Cache 仍可讀。
- Migration、LocalDataSource、Repository、Bloc、Widget、Refresh lifecycle 與 Mock / Real DI scope coverage 已完整回歸。
- README、Architecture Decision 017、Roadmap、Changelog 與 Catalog feature 文件已同步。
- dependency、generation、workspace analyze、完整 tests 與 development / staging / production bundle build 全部通過。
- 最終整體 review 新增 SQLite v4 `chain_revision` migration；第一頁 replacement 遞增 revision，Append Remote 回寫以 transaction CAS 驗證。
- 即使 Refresh 重用相同 opaque cursor，舊 Append response 也不能污染新 chain。
- Expired predecessor 可在同 revision retained successor 存在時合法 replacement，cycle 改以 ancestor path 判斷。

Milestone 14 已於 Template Baseline 1.1.0 正式封存。

### Milestone 15：Design System Foundation

狀態：Milestone 15-1 至 15-10 全部 Completed；Design System Foundation 已完成並通過完整 regression 與三環境 build 驗證。

目前已確認：

- 建立 `packages/design_system`，作為可重用的純 Flutter UI package。
- Design System package 不依賴 App、Feature、Bloc、DI framework、SharedPreferences 或其他 persistence implementation。
- App 維持唯一 Composition Root，負責 Theme preference restore、controller lifecycle、persistence 與 `MaterialApp` wiring。
- Theme Identity 與 Theme Mode 是兩個獨立概念。
- 每一套 Theme Identity 必須提供 Light / Dark variants。
- `system` 只決定目前使用 Light 或 Dark variant，不會切換 Theme Identity。
- 第一版至少提供 Default Theme 與第二套示範 Theme，證明多主題架構不是單一 ThemeData 的理論抽象。
- Feature 只使用 Material semantic roles、Design System semantic tokens 與 public primitives，不直接依賴 raw palette。
- Material `ThemeData` 與 component themes 優先；`ThemeExtension` 只補 success、warning、info 與 layout 等 Material contract 缺口。
- Theme preference 使用單一 versioned JSON，storage key 為 `app.theme.preference`，Version 1 保存 `version`、`themeId` 與 `mode`。
- 資料不存在、JSON 損壞或未知 version 時整體 fallback 至 Default Theme + System；未知 Theme ID 或 mode 採欄位級 fallback。
- Theme 切換先更新 runtime，再非同步持久化；寫入失敗不回滾畫面 Theme，只暴露 non-blocking persistence failure。
- Theme preference writes 透過單一序列化 queue 保存完整 snapshot，保證快速連續切換時 latest preference wins；舊寫入不得覆蓋新值。
- 前一次寫入失敗不阻止後續較新 preference 繼續持久化。
- Storage read exception 時仍以 Default Theme + System 啟動，保留 non-blocking diagnostic，不阻止 `runApp`，也不自動寫回 fallback。
- Appearance selector 屬於 App-level theme presentation，Shell 只負責提供入口。
- Primitive components 不知道 Auth、Profile、Catalog、Cache、Failure 或 Bloc state；feature-local composite component 負責將 feature state 映射為純 presentation properties。
- Milestone 15 已導入 Loading、Empty、Error、Message 與 Status Banner 等 page state surfaces，並完成 Accessibility、Semantics、text scaling 與窄畫面驗證。

規劃分段：

```txt
Milestone 15-1  Architecture Contract 與 Visual Audit（Completed）
Milestone 15-2  Package Skeleton、Design Tokens 與 Theme Registry（Completed）
Milestone 15-3  Default Theme Light / Dark（Completed）
Milestone 15-4  第二套示範 Theme Light / Dark（Completed）
Milestone 15-5  Primitive Components（Completed）
Milestone 15-6  Page State Surfaces（Completed）
Milestone 15-7  Theme Preference、Persistence 與 Selector UI（Completed）
Milestone 15-8  Protected / Profile / Login 導入（Completed）
Milestone 15-9  Catalog / Shell 導入（Completed）
Milestone 15-10 Regression、文件與完整驗證（Completed）
```

Milestone 15-2 已完成：

- `packages/design_system` 已加入 workspace。
- 建立 stable package entrypoint 與 package README。
- 建立 spacing、radius、elevation、icon size primitive tokens。
- 建立 success、warning、info semantic color role contract。
- Raw palette 保持 package internal，不由 public entrypoint export。
- 建立 `DsThemeId`、`DsThemeMetadata`、`DsThemeDefinition` 與 `DsThemeRegistry`。
- `DsThemeId` 採 canonical lowercase contract，`DsThemeMetadata` 拒絕空白 display name。
- Registry 已驗證空 definitions、重複 ID、缺少 default theme 與未知 ID fallback。
- Registry 已驗證 definition / metadata ID 一致性與 available themes 不可修改。
- 測試用 fake Theme definition 已驗證 Light / Dark ThemeData contract。
- Package 沒有加入 DI framework、SharedPreferences 或 feature dependency。

Milestone 15-3 已完成：

- 建立 production `DefaultThemeDefinition`。
- 建立 Material 3 Light / Dark `ColorScheme` 與 `ThemeData`。
- 建立 Typography hierarchy 與 surface hierarchy。
- 建立 AppBar、NavigationBar、Input、Button、Card、Divider、ProgressIndicator 與 SnackBar themes。
- 建立 `DsSemanticColors` success、warning、info foreground / container semantic roles。
- `DsSemanticColors` 已實作並測試 `copyWith` / `lerp`。
- Default Theme tests 已鎖定 Light / Dark brightness、Typography exact hierarchy、核心 component theme 精確值、touch target、radius、elevation 與 semantic color contrast。
- 第二套 Theme 實作只抽取兩套 Theme 已證明重複的 package-internal factory 或 theme spec，不直接複製完整 Default Theme builder。

Milestone 15-4 已完成：

- 建立 production `OceanThemeDefinition` Light / Dark。
- Ocean Theme 使用穩定 `ocean` ID 與 `Ocean` metadata。
- Ocean Theme 提供獨立 ColorScheme 與 success、warning、info semantic colors。
- Ocean Theme 以較重 title weight 與較緊湊 radius 驗證 Theme Identity 不只替換 seed color。
- 抽取 package-internal `DsMaterialThemeFactory`，只共用 Default / Ocean 已證明重複的 Material 組裝。
- Registry 已驗證 Default / Ocean × Light / Dark 四種有效 ThemeData 組合。
- Ocean tests 已鎖定同 brightness semantic identity、六組 foreground / container contrast，以及 Registry definition identity。

Milestone 15-5 已完成：

- 建立 `DsStatusBanner`，以純 presentation properties 支援 neutral、info、success、warning、error tone。
- Status Banner 使用 Material semantic roles 與 `DsSemanticColors`，支援 optional action 與 Semantics。
- 建立 `DsConstrainedContent`，統一 max width、置中與 page padding。
- 建立 `DsButtonContent`，只處理 Material Button 內部 loading presentation，不封裝 callback 或 button variant。
- Primitive API 不依賴 Bloc、Failure、Catalog snapshot、Cache state 或 domain entity。
- Widget tests 已覆蓋 Default / Ocean × Light / Dark、action、disabled/loading、長文字與窄 viewport。
- Review 後未建立 compact progress / search abstraction，因目前沒有第二個穩定 consumer。

Milestone 15-6 已完成：

- 建立 `DsLoadingState`、`DsEmptyState`、`DsBlockingErrorState` 與 `DsMessageState`。
- 建立 typed `DsPageStateAction`，維持 action label / callback 的 release-safe contract。
- Empty、Blocking Error 與 Message surfaces 支援 Widget icon slot 與 primary / secondary actions。
- Shared private layout 使用 viewport-aware min height、scrollable content、max width 與 Wrap actions，不使用固定高度 layout hack。
- Loading progress、Blocking Error 與 Retry action 提供可辨識 Semantics。
- Tests 驗證 Default / Ocean × Light / Dark、callback、custom icon、320px viewport 與 text scale 1.0 / 1.3 / 2.0。
- Blocking Error 僅用於 blocking state；Refresh、Append、Revalidation failure 繼續使用 non-blocking Status Banner 或 feature-local UI。

Milestone 15-7 已完成：App-local Theme preference、Version 1 JSON persistence、serialized write queue、bootstrap restore、MaterialApp Light / Dark / ThemeMode wiring 與 Appearance selector 已落地。

最近完成目標：Milestone 16 Localization Foundation。

目前狀態：Milestone 17 Exception & Failure Architecture 已完成並封存。

Milestone 18 Template Baseline Holistic Audit & Release Review已完成並封存，Template Baseline正式為1.2.0。18-7A至18-7E均Reviewed / Closed，9項findings全部Resolved。Android已有tracked runner、debug / release APK artifact與Android 35 emulator runtime smoke；bootstrap、Mock Login、Catalog、Protected Route、Theme / Locale持久化、restart Auth restore、SharedPreferences / SQLite與Logout均通過，因此Android為Supported。iOS、Web、Windows、macOS與Linux維持Dependency-ready。Decision 014已補充Web evidence clarification，Backlog只保留future / deferred scope。

### Milestone 17：Exception & Failure Architecture

狀態：Completed；Milestone 17-1 至 17-7 已完成。

Milestone 17-1 已完成全專案 Exception / Failure audit，並新增 Architecture Decision 020。正式分類為：

```txt
Expected operational failure
  → typed AppException → typed Failure → Result

Unexpected programming / system error
  → 保留原始 error + stack trace
  → 不轉 Failure

Cancellation
  → control flow

External protocol violation
  → typed protocol failure + non-fatal reporting

Internal invariant violation
  → programming error

Session lifecycle result
  → typed AuthRefreshResult
```

Audit 的 Critical findings：

- `FailureResult.error` 仍為 `Object`，expected failure channel 尚未封閉。
- Auth / Profile Bloc 遇到非 Failure 時會使用 `error.toString()` 重新包裝，可能吞掉 programming error與 stack trace。
- AuthSessionRefresher / AuthRefreshInterceptor 存在廣泛 `catch (_)`，unknown error 可能被降級為 localStateFailure、temporarilyUnavailable或原始 401。
- Bootstrap 尚未建立 Flutter framework、platform async、Bloc與 non-fatal degraded operation 的 reporting adapter boundary。
- Milestone 9 的一般 Auth / Profile / Catalog transport mapping 已集中於 `packages/api_client`，但 Milestone 12 新增的 `AuthRefreshRemoteDataSource` 目前直接捕捉 `DioException` 做 401 / 403 分類；此例外 boundary 需於 17-3 / 17-4 明確收斂或記錄，不再沿用「packages/auth 完全不依賴 Dio」的舊敘述。
- Theme / Locale preference Codec、Store 與 serialized write queue 廣泛捕捉 `Object`；invalid payload 目前靜默 fallback，unknown codec / persistence error 也可能被降級成 non-blocking diagnostic。
- 既有 Auth Refresh tests 明確鎖定「unknown local error → localStateFailure」與「refresher StateError → 原始 401」行為；17-4 必須主動修訂這些舊 regression expectation，而不是只新增測試。

已拍板保留的正確設計：

- App 是唯一 Composition Root。
- RemoteDataSource 隔離 Dio，Repository 只映射已知 AppException。
- Catalog expected failure 使用 Result，unknown Stream error保留 error channel與 stack trace。
- Catalog Cache read / write failure維持 non-blocking fallback，但後續需加入 non-fatal reporting。
- AuthRefreshResult 的 success、sessionExpired、temporarilyUnavailable、sessionChanged與 localStateFailure維持 typed lifecycle result。
- Session generation / userId、concurrent 401 single-flight、safe replay、Pagination、SWR與 Offline Cache contract不得破壞。
- Failure identity 與 feature operation context分離；Feature Presentation 繼續負責 localized copy。

Milestone 17 正式順序：

```txt
17-1 Audit 與 Architecture Contract（Completed）
17-2 Typed Result Failure Channel（Completed）
17-3 Typed AppException 與 Transport / Backend Boundary（Completed）
17-4 Auth Local State 與 Session Lifecycle（Completed）
17-5 Catalog Protocol / Cache Failure Contract
17-6 App Uncaught Error、Reporting Adapter 與 App Preference Error Boundary
17-7 Sensitive Data Audit、Regression、文件與完整驗證
```

Milestone 17 不建立 Global Error Handler、Generic Exception / Failure Mapper framework、每個 HTTP status class或全域 backend code enum。Crashlytics 先建立 App-owned adapter boundary；17-6最終決定本階段不加入 Firebase / Crashlytics dependency，未來可由 App Composition Root 提供production adapter。

Milestone 17-2 實作前 review 已拍板：17-2 只將 `FailureResult.error: Object` 與 `Result.when` failure callback 收斂為 `Failure`，並移除 Auth / Profile Bloc 的 `Object → Failure` fallback。Failure subclass taxonomy 延後至 17-3，與 typed AppException identity 同步落地，避免先依模糊字串 code 猜測類型。

Milestone 17-2 已完成：`FailureResult<T>` 現在只持有 `Failure`，`Result.when` failure callback 為 typed `Failure`；Auth / Profile Bloc 已移除 `error.toString()` fallback，unexpected error 會先清除 loading state，再保留原始 stack trace 進入 framework error flow。Catalog Bloc 的冗餘 runtime type checks 與測試中的舊 casts亦已清理。新增 Core typed channel test，以及 Auth / Profile unknown `StateError` 不寫入 Failure state、不殘留 loading 的 regression。Workspace analyze 與五個 package / app 完整 tests 全部通過。

Milestone 17-3 已完成：Core 採 `AppExceptionKind`、`TransportExceptionKind`、`FailureKind` 的單一 model + typed kind 設計，分離 `httpStatus`、`backendCode`、`diagnosticCode` 並保存 stack trace。api_client 將 Dio type 映射成 Core enum，只保留 URI path、不保存 query，unknown error原樣拋出；`AppException.toString()` / `Failure.toString()` 不再展開 cause。Auth / Profile / Catalog Presentation 的 HTTP policy 已由字串 code 遷移到 `httpStatus`。`code` 只保留相容橋接；Auth Refresh session lifecycle 決策留待 17-4。

Milestone 17-4A 已完成：Auth Refresh local state boundary 已收窄。known token read storage failure回傳 `AuthRefreshLocalStateFailure` 並保留目前 Session；known rotated-token save storage failure執行 cleanup並清除 Session；unknown local read / save error原樣拋出且不清 Session。Concurrent refresh、Session identity與 mutation coordinator contract未改變。

Milestone 17-4B 已完成：Refresh remote boundary改用 api_client typed Dio mapper。401 / 403明確映射為 invalid credential；temporary transport / HTTP failure與 malformed response保留 Session並回傳 temporary unavailable；FormatException建立 protocol diagnostic，TypeError與其他 unexpected error不再降級。新增 408、429、send / receive timeout、bad certificate與 unknown TypeError regression。

Milestone 17-4C 已完成：Auth Refresh Interceptor 只對 typed lifecycle result保留原始 401；unexpected refresher / replay error改以 `DioExceptionType.unknown` 傳遞，並保存 original error object與 stack trace，不再被第一次 401掩蓋。Single-flight、generation / userId identity、safe replay與 replay-once contract維持不變。

Milestone 17-4D 已完成：AuthRepository catch boundary已完成review與收窄。Login繼續映射 remote / local expected AppException；Restore與Logout只消化local storage operational failure，其他 typed identity或unknown error原樣拋出。Restore failure不清 runtime Session；Logout cleanup即使失敗仍完成其餘cleanup並清runtime Session。正式review revision修正多重cleanup error的優先級：unexpected / non-localStorage error優先於expected localStorage failure，避免programming error被第一個operational failure掩蓋。Workspace analyze與五個 package / app完整 tests通過，Milestone 17-4正式完成。

Milestone 17-5A 已完成：Catalog LocalDataSource 只將 SQLite `DatabaseException` 視為 expected local storage failure。Persisted row corruption 由狹窄 parser / validator辨識，刪除受影響 page後回傳 Cache miss；未知 TypeError與其他 programming error原樣拋出。Local API contract violation改為 ArgumentError / StateError，不再偽裝成 protocol或data corruption AppException。Pagination、cursor chain、chain revision與Repository fallback尚未改動，下一步為17-5B Repository Cache Fallback Boundary。

Milestone 17-5B 已完成：Catalog Repository的 Cache read、linked chain revision與 Cache write fallback只吸收 typed localStorage failure。protocol、dataCorruption與其他 AppException保留原始identity與stack trace進入Stream error channel；unknown error同樣不降級。Remote expected failure mapping與Cache side-effect已拆開，避免Cache contract error被誤轉為普通Catalog Failure。Catalog Repository / Data layer targeted 37 tests與 App analyze通過。

Milestone 17-5C 已完成：Catalog external protocol、persisted corruption與internal invariant已明確分離。Remote malformed item與non-advancing cursor建立 typed protocol diagnostic並保存 stack trace；Bloc偵測多節點cursor cycle時使用 `FailureKind.protocol`。LocalDataSource呼叫契約錯誤仍使用 `ArgumentError` / `StateError`，不轉成AppException或Failure。

Milestone 17-5D 已完成：Catalog Cache localStorage AppException現在攜帶 feature-local `CatalogCacheFailureDetails`，以安全方式描述read、write、append、chain revision、delete、corruption cleanup與expired cleanup operation。Context只暴露query是否為空、cursor是否存在與limit；不保存query、cursor token、item、SQL或raw row。原始SQLite error與stack trace仍保留，實際ErrorReporter接線留待17-6。

Milestone 17-5E 已完成：Catalog targeted 107 tests、workspace五個package analyze與五個package / app完整333 tests全部通過。Cursor chain、chain revision CAS、SWR、Refresh、Append、revalidation、query switching、cancellation、localized UI、public Cache logout persistence與unknown error preservation均無回歸。Milestone 17-5 Catalog Protocol / Cache Failure Contract正式完成，下一步為17-6 App Uncaught Error與Reporting Adapter implementation review。

Milestone 17-5正式review revision已完成：cursor-chain所有persisted `chain_revision`與`next_cursor`讀取都改走狹窄parser。損壞的第一頁revision可由Remote第一頁replacement清除同query / limit chain並重建；linked revision或Append traversal corruption則清除同chain並安全回null / false。Unknown implementation error仍原樣拋出，沒有重新加入broad TypeError catch。

Milestone 17-6A 已完成：App layer新增不依賴localization或Crashlytics SDK的狹窄 `ErrorReporter` contract。`ErrorReport`保留原始error與stack trace identity，但一般字串輸出只包含runtime type、severity與typed source / operation；context不接受任意Map。Development Debug adapter為best effort且不展開error內容，test Recording adapter可驗證完整report。實際Composition Root、Preference、Catalog、Bloc與uncaught entrypoint wiring留待後續17-6子階段。

Milestone 17-6B 已完成：Theme與Locale preference codec / store / SharedPreferences adapter boundary已收窄。Persisted corruption與storage operational failure各自使用typed `PreferenceCorruptionException` / `PreferenceStorageException`，包含封閉的preference kind與operation；Store只對這兩類採fallback diagnostic，unknown implementation error不再被降級。Runtime-first與serialized write語意尚未改動，write queue reporting留待17-6C。

Milestone 17-6C 已完成：Theme / Locale serialized write queue不再使用 `.catchError((Object _) {})` 吞掉前序錯誤。Expected同kind write failure會保存typed diagnostic、以degraded severity送入ErrorReporter並允許較新snapshot繼續；wrong-kind與unknown write error以unexpected severity上報，不進UI diagnostic，也不阻塞後續寫入。Bootstrap restore fallback會以degraded preferenceRestore上報。Catalog透過feature-local `CatalogCacheDiagnosticSink`維持Feature與App隔離，Repository在吸收localStorage read / chain revision / write failure前上報，App Composition Root以Debug reporter與Catalog adapter組裝；Firebase dependency仍未加入。

17-6C review revision補強best-effort contract：所有production Controller、bootstrap與Catalog Repository都必須顯式注入reporting dependency；Noop只能由測試或刻意呼叫端明確選擇。Preference restore reporter與Catalog sink即使拋錯，也不能阻止fallback controller、Remote success或cache miss後的Remote流程。Catalog sink signature直接包含封閉`CatalogCacheOperation`，adapter不再解析`AppException.cause`猜測operation，也不再將未知情況默認為write。

Milestone 17-6D 已完成：App新增 `AppBlocObserver`，由bootstrap在任何App Bloc建立前指定給 `Bloc.observer`。Bloc未處理錯誤以unexpected severity與固定safe context上報，保留原始error / stack identity，不讀event、state或Bloc內容；Reporter自身失敗會被observer吸收，不改變原有Bloc error propagation。Flutter framework與Platform uncaught hooks仍留待17-6E，duplicate policy於後續entrypoint review統一確認。

Milestone 17-6E 已完成：App新增 `AppUncaughtErrorHandler`與`AppUncaughtErrorHooks`。Flutter framework error使用unexpected severity，root isolate uncaught async error使用fatal severity，兩者皆使用封閉flutterFramework / platform context；Reporting失敗不取代原始flow。Global installer會保留並委派既有 `FlutterError.onError` / `PlatformDispatcher.instance.onError` handler，並提供dispose供測試還原。Bootstrap於取得ErrorReporter後、runApp前安裝；DI建立前的bootstrap error與Bloc / Platform duplicate policy留待17-6F。

Milestone 17-6F 已完成並封閉17-6：App Composition Root在DI前建立唯一Debug Reporter與identity-based deduplicator，先安裝global uncaught hooks及BlocObserver，再把同一Reporter instance註冊進GetIt，確保Preference、Catalog與global entrypoints共用相同outlet。`runBootstrapGuarded`涵蓋database factory、config、DI preResolve、preference restore與runApp前初始化，fatal bootstrap failure上報後保留原stack重拋。Bloc與bootstrap若已成功上報，會在同一event-loop turn以error object identity＋stack object identity標記；Platform hook只消費相同propagation pair，避免rethrow造成duplicate。相同error但不同stack、不同error identity與下一turn重新出現都不受抑制；cleanup另使用generation ownership，避免較舊cleanup刪除較新的標記。Milestone 17-6維持Debug / Test-compatible implementation，不加入Firebase或Crashlytics dependency。

17-6F review revision補強propagation ownership：Deduplicator現在同時比較原始error與stack object identity，不將相同exception instance但不同throw stack誤判為duplicate；每次mark具有generation token，舊cleanup不能刪除較新的標記。Bootstrap guard外層已擴大至Widgets binding、global hook與BlocObserver安裝，hook install自身失敗也會走fatal bootstrap report。去重仍不使用error / stack字串、runtime type或任意時間毫秒窗。

Milestone 17-7已完成並封閉Milestone 17：Sensitive Data audit確認exception、failure、cause、typed context、Debug reporter、Catalog / Preference diagnostic與global error entrypoints都不輸出password、token、Authorization、Cookie、raw body、raw storage payload、敏感query或Bloc state / event。修正RefreshTokenRequestDto、LoginResponseDto、RefreshTokenResponseDto、AuthResult與AuthEvent.loginRequested的Freezed欄位型`toString()`，並以secret sentinel tests鎖定Login account / password、access token與refresh token不可進一般字串輸出。Workspace五個package analyze與382項完整tests通過，development / staging / production bundle builds通過；Milestone 17 Exception & Failure Architecture正式完成。

17-6E review revision補強severity與hook lifecycle contract：Flutter framework caught error使用unexpected，Platform root isolate uncaught async error維持fatal；FlutterErrorDetails沒有stack時以`StackTrace.empty`誠實表示未知，不製造reporting handler stack。Installer禁止同時重複安裝；dispose只恢復自己仍持有的wrapper，不覆蓋後來安裝的外部global handler，且可安全重複呼叫。

Milestone 17-6B正式review revision已完成：Theme / Locale Store只接受同kind的decode corruption與read storage failure作為restore fallback；wrong kind或write operation視為contract mismatch並保留原始stack重拋。新增typed `PreferenceDiagnostic`保存error與catch stack trace，Controller diagnostic同步收窄；Storage exception只可透過read / write named constructors建立。

Milestone 17-6A正式review revision已完成：Error reporting context已封閉，不能由外部subclass覆寫 `toString()`；operation由String改為`ErrorReportOperation` enum，阻止敏感內容透過operation注入。Debug adapter固定格式化安全欄位，不再插入整個context物件。

### Milestone 16：Localization Foundation

狀態：Completed；Milestone 16-1 至 16-7 已完成。

已拍板：

- 使用 Flutter 官方 `gen_l10n`，第一版支援 English 與繁體中文 `zh_TW`。
- App 負責 locale、delegates、supported locales、preference、restore、persistence、controller、selector 與 `MaterialApp.router` wiring；App title 使用 `onGenerateTitle`。
- `system` 對 `MaterialApp.router.locale` 提供 `null`，由 `localeListResolutionCallback` 解析 platform locale list；explicit preference 才提供具體 Locale。
- LocaleController 不另外保存 resolved system locale，也不自行監聽 platform locale。
- `zh_TW` / `zh_Hant` / `zh_HK` / `zh_MO` → `zh_TW`；`zh_CN` / `zh_SG` / `zh_Hans` 與其他 unsupported locale → English。
- `packages/design_system` 不依賴 App generated `AppLocalizations`；primitive 只接收已 localized presentation text。
- Theme ID 維持穩定；App 依 Theme ID 映射 localized display name，metadata 只保留 fallback display name。
- Data、Domain 與 Cache timestamp 維持 UTC；Presentation 轉為 local time 後依 locale 的日期與時間慣例格式化。
- Theme 與 Locale preference 不抽象成 Generic Preference Framework。

Failure / Exception 範圍：Milestone 16 不全面重構 hierarchy。Catalog 已保存 `Failure`；Auth / Profile 只做最小 state contract 調整，使 Presentation 能取得 stable failure identity。只有目前 user-facing 的 Login、Logout、Profile 與 Catalog failure path 建立 feature-local mapping，且不建立全域 mapper 或 taxonomy。

規劃分段：

```txt
Milestone 16-1  Architecture Contract、文字盤點與規劃 Review（Completed）
Milestone 16-2  gen_l10n Skeleton 與 App Wiring（Completed）
Milestone 16-3  Locale Preference、Persistence 與 Bootstrap（Completed）
Milestone 16-4  Shell、Appearance 與 Theme Metadata Localization（Completed）
Milestone 16-5  Auth、Profile 與 Protected Localization（Completed）
Milestone 16-6  Catalog Localization、Failure Mapping 與 Date Formatting（Completed）
Milestone 16-7  Production Text Audit、Regression、文件與完整驗證（Completed）
```

Milestone 16-2 已完成：

- App 加入 Flutter 官方 `flutter_localizations` 並啟用 `flutter.generate`。
- 建立 `l10n.yaml`、English template ARB、`zh_TW` ARB 與 generator 所需的 base `zh` fallback ARB。
- App 實際 `supportedLocales` 仍只公開 `en` 與 `zh_TW`。
- `MaterialApp.router` 已接上 generated delegates、明確 locale list resolution 與 `onGenerateTitle`。
- Locale resolution 已驗證繁中 script / region、簡中 exclusion、platform priority order 與 English fallback。
- Design System 未新增 App localization dependency。
- Workspace analyze 與 App 完整 167 tests 已通過。

Milestone 16-3 已完成：

- 新增 `AppLocalePreference.system / english / traditionalChinese`，storage value 固定為 `system / en / zh_TW`。
- 新增獨立 Version 1 JSON codec / store，SharedPreferences key 為 `app.locale.preference`。
- 新增 runtime-first `LocaleController` 與 serialized snapshot write queue；快速連續切換時依序保存，最新 preference 為 runtime truth。
- Storage read exception 以 System 啟動並保留 non-blocking diagnostic；寫入失敗不回滾 runtime，也不阻止後續較新 preference 保存。
- Bootstrap 在 `runApp` 前 restore Theme 與 Locale controller，並重用相同 SharedPreferences instance。
- `ArchitectureApp` 由 `LocaleControllerScope` 提供 App-local locale state；System 回傳 `null`，explicit English / `zh_TW` 回傳具體 Locale。
- Shell 新增語言 selector 入口；dialog 支援 System、English、繁體中文，並在 runtime locale 切換後即時重建 localized labels。
- 未建立 Generic Preference Framework，也未保存 resolved system locale 或加入 platform locale observer。
- Locale preference、selector、Shell callback、完整 App 177 tests、analyze 與 bundle build 已通過。

Milestone 16-4 已完成：

- Shell title、Language / Appearance / Protected tooltips 與 Login / Catalog / Profile Navigation labels 已移入 ARB。
- Appearance dialog title、Theme / Mode section labels、System / Light / Dark labels 與 Done action 已 localization。
- App 依 stable Theme ID 將內建 `default` / `ocean` 映射為 localized display name；Design System metadata 仍保留 fallback display name。
- 未知或外部 Theme 不要求 App 預先建立 ARB key，直接顯示 metadata fallback display name。
- English / `zh_TW` runtime switching、Appearance localized labels 與 Theme fallback tests 已補齊。
- 完整 App 183 tests、analyze 與 bundle build 已通過。

Milestone 16-5 已完成：

- Login、Profile、Logout 與 Protected 固定 user-facing text 已移入 English / `zh_TW` ARB。
- Profile current user 使用 generated ARB placeholder，不在 Dart 直接拼接句子。
- Auth / Profile Bloc state 改為保存 `Failure` 與 operation context，不再以 `error.toString()` / `String? errorMessage` 作為 UI contract。
- Login、restore、logout、Profile load 與 Profile logout 使用 feature-local localized mapping；目前只有 `401` 映射為帳密錯誤或 Session 失效，`403` 與其他 code 使用操作專屬 generic fallback，避免由 HTTP forbidden 狀態推導錯誤 UX。
- `Failure.message` 與 mapper contract 已改為 diagnostic / fallback；Repository fallback 不再使用固定 UI 語言，也不宣稱可直接交給 UI。
- 未建立全域 Failure taxonomy、Generic Error Localization Service 或 Generic Failure Mapper。

Milestone 16-6 已完成：

- Catalog Search、Initial Loading / Failure、Empty、Append、Refresh、Cached、Stale、Revalidation 與相關 Semantics / action text 已移入 English / `zh_TW` ARB。
- Catalog Bloc state shape 不變，Presentation 依 initial / refresh / append / revalidation surface 做 feature-local failure mapping，diagnostic `Failure.message` 不直接顯示。
- HTTP `408` / `429` 映射為 timeout / rate-limit localized copy；其他 code 使用 surface-specific generic fallback，不建立全域 error taxonomy。
- App 新增直接 `intl` dependency；`lastUpdatedAt` 於 Presentation `toLocal()` 後，依目前 locale 的日期與時間慣例產生字串，不固定所有語系使用同一種 12／24 小時制。
- Data、Domain 與 Cache timestamp 維持 UTC；Catalog item name / description、cursor、pagination、SWR、refresh、append 與 Offline Cache contract 未改變。
- Catalog targeted 52 tests 與 App analyze 已通過。

Milestone 16-7 已完成：

- 完成 production user-facing text、Tooltip、Semantics、Dialog、Navigation、page-state surface 與 failure path audit。
- 確認 Domain、Data、Repository、exception、log、technical ID、storage value 與 server content 不進 App localization。
- 確認 `packages/design_system` 不依賴 App generated localization；`DsButtonContent` 移除固定英文 progress semantics fallback，改為重用呼叫方 localized label。
- 採 Theme matrix、locale runtime switching、feature localization 與既有 business flow regression 的分層測試，不建立完整笛卡兒積。
- README、Catalog feature README、Architecture Decision、Roadmap、Backlog 與 CHANGELOG 已同步。

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
- Milestone 9 的 Login transport path 由 `packages/api_client` 辨識 DioException 並轉換 AppException；Milestone 12 後新增的 Auth Refresh path仍由 `packages/auth` 保有refresh-specific lifecycle分類，但Dio operational identity已統一透過`packages/api_client` typed mapper，401 / 403、temporary failure、protocol與unknown error boundary已由Milestone 17-3 / 17-4完成review與收斂。

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

---

## 下一個正式方向：Milestone 20 OTP Step-Up Authentication Planning Review

狀態：Milestone 19 Secure Credential Storage & Migration已完成、final review、獨立Holistic Final Review、封存並發布Template Baseline 1.3.0。Milestone 20-0已完成規劃與final document review；Milestone 20-1 typed API與Stateful Mock也已完成並通過implementation review。下一步為20-2。

原候選Milestone 19「Authentication Security & Step-Up Verification」已正式拆分為：

```txt
Milestone 19 — Secure Credential Storage & Migration
Milestone 20 — OTP Step-Up Authentication
Milestone 21 — Biometric-gated Local Session Unlock
```

拆分理由：

- Secure Storage屬於credential-at-rest與migration問題。
- OTP屬於Server authentication state machine。
- Biometric屬於local device user-presence gating與Android runtime問題。
- 三者的威脅模型、失敗後果、API contract、Native evidence與rollback邊界不同，不應綁成單一implementation batch。

Architecture Decision 022已建立上述依賴順序與責任邊界。App仍是唯一Composition Root；`flutter_secure_storage`與`local_auth`只允許由App layer依賴並實作adapter，`packages/auth`只定義純Dart、Auth-specific狹窄abstraction。

Milestone 19-0正式review文件為：

```txt
docs/audits/milestone_19_planning_review.md
```

Review拍板：

- Credential read採`absent / present / corrupted` sealed result；Secure operational unavailable不得當成absence或fallback Legacy。
- `AuthCredentialMigrationCoordinator`是唯一migration policy owner，但Lifecycle owner必須先取得一次exclusive ownership；禁止nested `runExclusive`。
- Milestone 19不建立persistent migration marker，以Secure、Legacy與User真實store state推導migration phase。
- Secure已驗證且只剩Legacy cleanup failure時允許restore，並non-fatal report與後續重試。
- Interactive Logout與passive invalidation都清除runtime Session並嘗試清除Secure、Legacy與User；unknown error不得被空catch吞掉。

Milestone 19-0已由commit `07b5d89 docs(auth): 封存 Milestone 19-0 規劃審查`提交並推送至`origin/main`。

Milestone 19-1詳細implementation plan已建立並完成review：

```txt
docs/superpowers/plans/2026-07-20-milestone-19-1-auth-persistence-seam.md
```

Milestone 19-1 Auth Persistence Seam已完成implementation、逐Task review與完整review：

```txt
建立Auth-specific store abstraction與sealed read taxonomy
  ↓
移除AuthLocalDataSource與聚合local-store介面
  ↓
將SharedPreferences / SQLite adapter與plugin ownership移至App layer
  ↓
Repository / Refresher改用三個明確store boundaries
  ↓
App Composition Root綁定共享lazy singleton instances
```

19-1 review結果：

- `packages/auth`不再依賴`shared_preferences`、`sqflite`或DI framework。
- Credential read明確區分`absent / present / corrupted`；operational failure維持typed `AppException`。
- SharedPreferences仍是production credential authority，SQLite仍保存公開Domain `AuthUser`。
- Login、Restore、Refresh、Logout、latest-intent、single-flight、generation與safe replay regression未退化。
- Auth package 56 tests、App auth / DI targeted 45 tests與workspace完整437 tests通過；workspace analyze與App bundle build通過。
- 未新增`flutter_secure_storage`、migration policy、Android Native設定或VERSION變更。

Milestone 19-4 Auth Lifecycle Integration已完成並通過implementation review gate；Milestone 19-5 Security Review、Android Smoke與封存亦已完成。

Milestone 19-4詳細implementation plan已建立：

```txt
docs/superpowers/plans/2026-07-20-milestone-19-4-auth-lifecycle-integration.md
```

19-4已將migration policy正式整合至Restore，並將Login、Refresh、Logout與passive invalidation全部切換至Secure credential lifecycle。Package新增Auth lifecycle diagnostic taxonomy與共用cleanup policy；Restore migration resolution、latest-intent check與Session commit位於同一exclusive ownership，diagnostics只在lock外report。Login固定Secure credential → SQLite User → Session，Refresh rotation固定Secure persistence-first；destructive與passive cleanup皆依Secure、Legacy、User順序全部嘗試，unknown與expected failure依Decision 020表達。

App Composition Root已原子切換default `AuthCredentialStore`為`FlutterSecureAuthCredentialStore` singleton；Repository、Refresher與Migration Coordinator共用同一Secure authority，named Secure binding與所有transitional constructor / subclass均已移除。Legacy SharedPreferences只保留migration與cleanup責任。

19-5完成Android release runtime evidence：Secure Login、force-stop / restart Restore、real API 401 → Refresh rotation → Replay、access-v2 restart persistence、`05b3412` predecessor production Login建立Legacy資料後的signed in-place upgrade migration，以及Logout destructive cleanup均通過。ADB沒有直接寫入credential、User或Session；App／host evidence無raw secret。Release artifact實際minSdk 24、targetSdk 36、`allowBackup=false`，permissions只有既有必要權限。Workspace五個packages analyze、542項Flutter tests、7項Python fixture tests與release APK build全數通過。`M19-PR01`至`M19-PR06`全部關閉或完成正式disposition，無Open P0 / P1。

版本review判定Milestone 19新增可交付的Secure credential storage與migration能力，因此Template Baseline由1.2.0提升為1.3.0。能力只描述為credential-at-rest hardening，不防rooted device、runtime memory或server compromise；OTP、Biometric、Device Binding與Passkey仍屬後續Milestone。

封存後另完成獨立`docs/audits/milestone_19_holistic_final_review.md`，重新跨19-0至19-5審查architecture、production source、generated DI、concurrency、failure、security、runtime evidence與1.3.0版本判斷。Review只發現缺少獨立holistic review紀錄的P2治理finding `M19-H01`，已隨文件建立關閉；另重跑63項核心Auth targeted tests全部通過，沒有重開production implementation，也沒有新增P0／P1。

Milestone 19-3詳細implementation plan已建立：

```txt
docs/superpowers/plans/2026-07-20-milestone-19-3-shared-preferences-legacy-migration.md
```

19-3實作已建立`AuthCredentialMigrationCoordinator`作為唯一migration policy owner，完整覆蓋Secure × Legacy × User decision matrix、destructive cleanup、Secure authority、Legacy cleanup pending、write/read-back/cleanup順序、partial migration re-entry、identity validation與cleanup failure ownership。Resolution使用immutable diagnostics list；read-back比較完整Token Pair、userId與兩個expiration欄位，validation failure固定為`AppExceptionKind.dataCorruption`與`auth_secure_migration_read_back_invalid`，plugin operational failure保持`localStorage`。Write或read-back失敗會保留Legacy並嘗試rollback Secure；rollback error優先於原始錯誤。

Coordinator公開入口為`resolveUnlocked()`，不依賴`SessionManager`或`AuthStateMutationCoordinator`。Guard fake證明呼叫方只取得一次exclusive ownership，Coordinator不取得nested lock；同一instance re-entry只依Secure、Legacy與User真實store state，不使用persistent marker或跨呼叫mutable authority state。App新增migration diagnostic reporter adapter與fixed safe context，逐項上報所有diagnostics且reporter failure不阻止後續項目。DI以named Secure store組裝Coordinator，但Repository與Refresher仍保持default SharedPreferences authority，production source of truth尚未切換。

19-3 regression gate：Auth migration targeted 39項、App adapter / DI targeted 3項；workspace五個packages共506項tests與analyze全數通過，App `flutter build bundle`成功。同步修正Android scaffold contract test，使其符合19-2已核准的`minSdk = maxOf(flutter.minSdkVersion, 23)`。VERSION維持1.2.0，未加入OTP、Biometric、Device Binding或額外Native permission。下一步為19-4，由Login / Restore / Refresh / Logout lifecycle owner在單一exclusive section內整合migration與Secure authority切換。

Milestone 19-2詳細implementation plan已建立：

```txt
docs/superpowers/plans/2026-07-20-milestone-19-2-secure-credential-store-adapter.md
```

19-2實作結果：`flutter_secure_storage: ^10.3.1`只存在App；新增App-owned `FlutterSecureAuthCredentialStore`，以單一payload保存完整Token Pair並明確區分absent、present、corrupted與operational unavailable。`PlatformException` / `MissingPluginException`映射為typed local-storage `AppException`，保留cause與origin stack且不輸出secret；unknown programming error維持原始identity。DI採named Secure binding，default SharedPreferences authority與Repository / Refresher behavior保持不變。Android以`minSdk = maxOf(flutter.minSdkVersion, 23)`固定Secure Storage下限並允許Flutter提高最低版本，App-wide停用backup；release merged manifest實際minSdk 24、targetSdk 36，未加入Biometric / Fingerprint permission。Workspace analyze、465項tests與release APK build通過，VERSION維持1.2.0。

Milestone 21目前只保存正式scope、依賴順序、子階段與完成定義。Milestone 20-0 Planning Review、20-1 typed API / Stateful Mock與20-2 Domain / Repository已完成；目前已有OTP transport、Domain與credential commit boundary，但仍沒有OTP route、完整Bloc state machine或UI production code。

Milestone 20-0正式文件已建立：

```txt
docs/audits/milestone_20_planning_review.md
docs/superpowers/plans/2026-07-21-milestone-20-implementation-plan.md
```

Review拍板：Login使用`authenticated | otpChallenge` typed union；Verify成功是OTP流程唯一credential簽發與commit boundary；Resend成功必須回完整replacement challenge並使predecessor失效。OTP pending時Secure credential、SQLite AuthUser與SessionManager均不得mutation，Protected Route繼續只依SessionManager而自然拒絕。Login、Verify、Resend、Logout、Restore與account switch共用既有latest-intent generation；Repository generation負責在credential commit前阻擋stale Verify，Bloc challenge identity只保護UI metadata。Invalid-code attempts與Resend cooldown retry time採typed details，OTP pending即使Session原本為null，authoritative clear仍必須清除challenge。共11項planning findings，無Open P0，P1均已有approved disposition。

Milestone 20-1已完成並review：`packages/api_client`已提供typed Login union、Verify / Resend Retrofit endpoints、authenticated / challenge DTO與敏感transport model保護。`MockAuthApi`現在是Auth-specific stateful deterministic Mock，支援注入clock、expiration、attempt exhaustion、resend cooldown、replacement與predecessor invalidation。既有Auth mapper在20-1只接受authenticated variant，OTP challenge domain / Repository行為留待20-2，避免提前建立Session。Workspace analyze與554項tests通過；VERSION仍為1.3.0。Review文件：`docs/audits/milestone_20/20-1_api_mock_review.md`。

Milestone 20-2已完成並review：`packages/auth`新增typed Login Domain union、credential-bearing authenticated result、validated OTP challenge、Verify / Resend use cases與endpoint-aware typed failure metadata。Repository只允許Direct Login authenticated與Verify success進入共用Secure credential → SQLite User → Session commit helper；Login challenge與Resend replacement不修改任何persistence或runtime Session。Verify晚於Login、Resend或Logout完成時會由共用generation在credential commit前判定stale。Workspace analyze與570項完整tests通過；VERSION仍為1.3.0。Review文件：`docs/audits/milestone_20/20-2_domain_repository_review.md`。
