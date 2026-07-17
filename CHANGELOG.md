# Changelog

本文件記錄 Flutter Enterprise Architecture Template 的版本變更。

版本號代表 **Template Baseline Version**，不是 App 上架版本，也不是任何單一 package 的發布版本。

## Versioning Policy

本專案使用 Semantic Versioning 的概念管理模板基線：

- `MAJOR`：模板架構或使用方式有不相容變更，例如更換 Router、DI、State Management，或大幅調整資料夾結構。
- `MINOR`：新增可選能力或模板能力，例如新增 CI/CD、Design System、Refresh Token、Pagination 範例。
- `PATCH`：修 bug、文件修正、相容性修正、小型 dependency update。

由於這是模板專案，不一定需要每次 commit 都調整版本。只有當模板達到可交付基線，或完成一個明確 Milestone 時，才記錄版本。

---

## [Unreleased]

尚無未發布變更。

---

## [1.1.0] - 2026-07-17

### Added

- 規劃 Milestone 14 Offline Cache，正式採用 Catalog feature-level、明確 opt-in 的 Cache-first + Stale-While-Revalidate。
- 新增 Architecture Decision 017，拍板 freshness / retention、query + cursor + limit cache identity、cursor page storage、所有 Remote 第一頁成功時的 chain invalidation、Remote + Local coordination 與 UI metadata。
- Catalog Cache 不使用 generic HTTP interceptor，不自動快取 Login、Refresh Token、交易、付款或其他 command API。
- Initial / Query Switching 使用 Fresh Cache 或 Stale Cache + background revalidation；Pull-to-refresh 強制 Remote，Append 第一版使用單次 cursor page cache，不做背景 revalidation。
- SQLite Cache 採 page metadata + ordered page items，DTO、Local Entity 與 Domain Entity 維持分離。
- Domain snapshot 將表達 page source、freshness 與 `lastUpdatedAt`；Bloc state 表達 `isUsingCachedData`、`isStale`、`isRevalidating` 與 revalidation failure，不以單次 transport failure 推測全域 Offline。
- 明確定義 Initial SWR 的 Repository Stream emissions、預期 failure 使用 `Result`、未知程式錯誤才走 Stream error channel。
- 明確定義 `CatalogLoadPolicy.initial / refresh / append` contract、合法 cursor 組合，以及三種 policy 各自的 Stream emission 語意。
- 畫面級 freshness metadata 只代表第一頁 snapshot；Append page freshness 不提升為整體清單最後更新時間。
- Cache read / write failure 維持非阻斷 local diagnostic，不加入一般 Catalog UI contract；expired cleanup 採讀取指定 page 時的 page-level lazy cleanup。
- 將 Milestone 14 拆分為 Architecture Contract、SQLite / Migration、Repository Coordination、Initial SWR、Refresh / Append、UI / DI 與 Final Verification 七個階段。
- 明確定義 public Catalog Cache 不因 Logout 清除，App 仍是唯一 Composition Root，且不建立 Generic Cache / Generic Pagination framework。
- 完成 Milestone 14-2 SQLite Schema、Migration 與 Local Models。
- App database version 最終升級為 3：v1 → v2 建立 Catalog Cache tables，v2 → v3 將 item position index 升級為 unique，並保留既有 `auth_user`。
- 新增 `catalog_cache_page`、`catalog_cache_page_item` 與 page item order index；Local item row 保存 id、name、description 與 position。
- 新增 Catalog Local Entity、Local Mapper 與 `CatalogLocalDataSource`，支援 page read、transaction replacement、第一頁 chain reset、cursor sentinel 與 expired page lazy cleanup。
- 新增 16 項 in-memory SQLite tests，涵蓋完整欄位與順序 round-trip、identity isolation、cursor sentinel 防護、empty page、replacement、chain reset、expiration、delete isolation、corrupted cache recovery、failure mapping、transaction rollback 與 migration。
- 依 Milestone 14-2 implementation review 補強 Local Entity validation、position unique constraint 與損壞 page 自我清除。
- 完成 Milestone 14-3 Repository Cache Coordination。
- 新增 `CatalogCachePolicy`、可注入 `CatalogClock`、`CatalogPageSnapshot`、source / freshness metadata 與 `CatalogLoadPolicy`。
- 新增 `CatalogStreamingRepository.watchCatalog()` 與 `SearchCatalogUseCase.watch()`，支援 Initial SWR 多次 emission、Refresh Remote-only 與 Append 單次 Cache/Remote fallback。
- Cache read / write failure 維持非阻斷，Remote cursor 驗證通過後才寫入 Cache，未知程式錯誤保留 Stream error channel。
- App Composition Root 明確註冊 Catalog LocalDataSource、CachePolicy、Clock 與 Repository；舊單次 API 暫時保留至 Milestone 14-4 Bloc 遷移。
- 新增 10 項 Repository Cache tests，涵蓋 fresh/stale/expired、三種 policy、Local failure、cursor validation 與未知錯誤。
- 依 Milestone 14-3 implementation review，將 Catalog Repository 的 Remote、Local、CachePolicy 與 Clock dependencies 全部改為 required，避免 silent misconfiguration。
- 補強 policy / cursor validation，Append 的空字串與空白 cursor 現在會在 Cache read 或 Remote request 前 fail fast。
- 未來 `updatedAt` 不再被判定為 Fresh-only，而是視為 Stale 並執行 revalidation；Repository Cache tests 增至 16 項，補齊 freshFor / retainFor 精確邊界與 read/write failure 分離。
- 完成 Milestone 14-4 Initial Search、Query Switching 與 SWR Bloc Flow。
- CatalogBloc 改為直接消費 `CatalogRepository.watchCatalog()` Stream，支援 Cache → Remote 多次 emission，並移除舊單次 Repository / UseCase contract。
- CatalogState 新增 cached/stale/lastUpdatedAt/revalidating/revalidationFailure metadata；Stale Cache revalidation failure 會保留現有資料並以 non-blocking failure 表達。
- Query switching 會取消舊 SWR subscription，並保留 generation、query identity 與 stale-response guard；Refresh / Append 暫以單次 Stream emission 維持既有 workflow。
- CatalogBloc tests 增至 21 項，新增 Cache → Remote、revalidation failure、query switch cancellation 與 Stream error cleanup coverage。
- 依 Milestone 14-4 implementation review，第一頁 Initial / Query / Retry / Refresh 現在共用可取消的 SWR subscription boundary，不再只靠 generation guard 忽略舊結果。
- Refresh 會取消 stale revalidation，並完整更新 `isUsingCachedData`、`isStale`、`lastUpdatedAt`、`isRevalidating` 與 `revalidationFailure` metadata。
- Stale Cache 後 Stream 若未產生 Remote success / failure 就關閉，現在視為 protocol violation，不再靜默結束 revalidation。
- CatalogBloc tests 增至 24 項，補齊 Initial → Query、Initial retry、Stale → Refresh cancellation 與 stale-only Stream close coverage。
- 完成 Milestone 14-5 Refresh、Append 與 Cursor Chain。
- Refresh 使用目前 query 與 null cursor 強制 Remote；Remote 第一頁成功會 transaction replacement 第一頁，並失效同 query + limit 的舊後續 cursor chain。
- Refresh failure 會保留既有 items、cursor 與 cached / stale / lastUpdatedAt metadata。
- Append 以 requested cursor page identity 讀寫 Cache，支援 retained Cache hit、Cache miss Remote fallback 與 expired page replacement；第一版不做背景 revalidation。
- Append Cache snapshot 只影響 appended items 與 nextCursor，不覆蓋第一頁 freshness metadata；既有 generation、query、requested cursor race protection 維持不變。
- Refresh / Append 現在透過明確 single-result Stream protocol helper 驗證零筆與多筆 emission，違規時會清除 loading 並保留原始錯誤。
- Repository Cache tests 增至 19 項、CatalogBloc tests 增至 28 項，涵蓋第一頁 chain reset、append identity、expired fallback、metadata preservation 與 Stream protocol violation。
- 依 Milestone 14-5 implementation review 補強 cursor chain consistency 與跨操作 cancellation。
- Append Cache write 改為 conditional transaction：只有 requested cursor 仍由目前 chain 指向時才寫入，避免 Refresh chain reset 後較晚完成的舊 Append 重新污染 SQLite。
- CatalogBloc 追蹤已消耗 cursor，阻止多節點 cursor cycle；Local boundary 也拒絕 self-loop Cache page。
- Refresh 採 exhaust transformer 防止重複請求；Initial、Query、Refresh 與 Bloc close 會實際取消執行中的 Refresh / Append Stream。
- 補齊 stale Append late-write、cursor cycle、連續 Refresh、Query → Refresh cancellation、Refresh → Append cancellation 與 Local self-loop tests。
- 完成 Milestone 14-6 UI、DI 與 Offline Cache Flow。
- Catalog UI 新增 cached / stale status banner，顯示 UTC `lastUpdatedAt`、background revalidation indicator 與 non-blocking revalidation failure，且保留現有 items 可操作。
- Fresh Remote data 不顯示 Cache notice；Fresh Cache 與 Stale Cache 使用不同文案與視覺狀態。
- Mock / Real Composition Root tests 現在明確驗證 CatalogApi、LocalDataSource、RemoteDataSource、CachePolicy、Clock、Repository、UseCase 與 Bloc graph。
- Catalog Widget tests 補齊 cached、stale、lastUpdatedAt、revalidation loading、non-blocking failure 與 Fresh Remote 隱藏 notice coverage。
- 完成 Milestone 14-7 Cleanup、Regression、文件與完整驗證，Milestone 14 Offline Cache 全階段完成。
- 依 Milestone 14 最終整體 review 新增 SQLite v4 `chain_revision` migration；Append Remote request 會捕捉 revision 並於 transaction write 時 compare-and-set，防止 Refresh 重用相同 cursor 的 stale late-write。
- Cursor cycle persistence validation 改為 ancestor path + revision，允許 expired predecessor 在 retained successor 尚存在時合法 replacement。
- 新增 Auth / Catalog 共用 SQLite database 的 Logout integration test，確認 Logout 清除 token、user 與 runtime Session，但保留 public Catalog Cache。
- retention-based expired page lazy cleanup、retainFor boundary、migration、Repository、Bloc、Widget、Refresh lifecycle 與 DI scope regression 已完整驗證。
- 同步 README、Architecture Decision 017、Roadmap、Project Context 與 Catalog feature 文件，並完成 development / staging / production bundle builds。
- 依 Milestone 14-6 implementation review 修正 Refresh lifecycle 等待與 empty failure 呈現。
- `requestCatalogRefresh` 在 Refresh 已進行中時會等待目前 lifecycle 結束，不再等待不存在的新一輪 `isRefreshing = true`。
- Empty result 的 Refresh failure 現在與 empty content 同時可見，且保留 pull-to-refresh。
- Revalidation Widget tests 改為正式狀態機中的互斥案例：更新中只顯示 spinner，更新失敗只顯示 non-blocking failure。
- DI graph tests 補上 LocalDataSource / CachePolicy / Clock / Repository singleton identity，以及 UseCase / CatalogBloc factory identity；測試建立的 Bloc 會明確 close。

- 規劃 Milestone 13 Pagination + Search Debounce，正式採用 Catalog feature 與 cursor-based pagination。
- 新增 Architecture Decision 016，拍板 query / cursor / limit contract、300 ms debounce、search generation、stale-response guard、Load More 防重與 logical cancellation。
- Catalog 定義為 public demo endpoint；`nextCursor` 為唯一分頁 source of truth，Repository 負責驗證 cursor chain，不額外引入 `bloc_concurrency`。
- 將 Milestone 13 拆分為 Architecture Contract、API / DTO、Domain / Repository、Initial Search、Load More / Refresh、UI / DI 與 Final Verification 七個階段。
- 明確將 page-based strategy、Generic Pagination framework、Dio CancelToken 跨層傳遞與 Offline Cache 排除於 Milestone 13。
- 完成 Milestone 13-2 Catalog API、DTO、Mock 與 Retrofit Contract。
- 新增 public Retrofit `CatalogApi`、`CatalogItemDto`、`CatalogPageResponseDto` 與 `MockCatalogApi`。
- `MockCatalogApi` 支援 query、opaque cursor、limit、多頁資料與最後一頁 null cursor。
- App API selector 已支援 Mock / Real Catalog implementation，並補上 Retrofit query、public metadata、DTO round-trip 與 selector tests。
- 修正 Mock Catalog cursor identity：cursor 現在綁定 normalized query，避免舊 query cursor 被新 query 接受並回傳錯頁。
- 完成 Milestone 13-3 Catalog Domain、Mapper、RemoteDataSource、Repository 與 Search UseCase。
- 新增 `CatalogItem`、`CatalogPage`、`CatalogRepository`、`SearchCatalogUseCase` 與 Catalog data layer implementation。
- Catalog Mapper 會正規化空 cursor 並驗證必要欄位；Repository 會拒絕無法前進的 cursor chain。
- 補上 Catalog mapper、transport mapping、repository success/failure/cursor validation、unknown error 與 use case parameter tests。
- 修正 Catalog Mapper 不應改寫 opaque cursor 與穩定 Domain ID；trim 僅用於空值驗證。
- 完成 Milestone 13-4 Catalog Initial Search、Debounce 與 Query Switching。
- 修正 Catalog 初始 state 不應被視為 empty result，並加入 page size validation 與測試等待 timeout。
- 新增 `CatalogBloc`、Event、State 與 generated Freezed code；query pipeline 使用預設 300ms、可注入的 debounce + trim distinct。
- 新增 search generation 與 query identity guard，避免舊 query 或同 query 舊 generation response 覆蓋目前 state。
- 補上 initial loading/failure/empty、快速輸入、normalized distinct 與 stale response regression tests。
- 完成 Milestone 13-5 Catalog Load More、Refresh 與 Failure Recovery。
- 修正 Initial、Append、Refresh 遇到未知錯誤時 loading state 可能永久卡住；錯誤仍保留原樣向外傳遞，Append / Refresh 可再次重試。
- Load More 使用 state guard 與 RxDart exhaust transformer，驗證 generation、query 與 requested cursor，避免重複 append 與 stale response。
- Append 依穩定 Domain ID 去重並保留既有順序；failure 保留 items/cursor 並允許 retry，end reached 停止請求。
- Refresh 使用目前 query 與 cursor = null，遞增 generation，成功整批替換、失敗保留資料，並防止舊 Append response 污染 state。
- Catalog Bloc 目標測試增加至 18 項，涵蓋 append 防重、cursor、去重、retry、end reached、refresh success/failure、race protection 與未知錯誤 loading cleanup。
- 完成 Milestone 13-6 Catalog Page、Route、DI 與 UI Flow。
- 新增 Catalog Shell tab、AutoRoute route、搜尋欄位、清單、empty、initial/refresh/append loading 與 failure surfaces、scroll load more 與 pull-to-refresh。
- 完成 Catalog API、RemoteDataSource、Repository、UseCase、Bloc 的 Composition Root registration，並補上 Mock / Real DI graph 與 route tests；完整 Page widget coverage 留在 Milestone 13-7。
- 修正新增 Catalog tab 後登入成功誤導向 Catalog 的回歸，Shell tab index 改由 `ShellTab` 統一定義。
- 修正 pull-to-refresh 快速完成時可能遺失完成 state、導致 RefreshIndicator 永久等待的 stream subscription race。
- 完成 Milestone 13-7 Regression、文件與完整驗證。
- 將 Catalog list body 抽為可獨立測試的 `CatalogView`，補上 initial loading/failure/empty、item、append loading/failure 與 retry widget tests。
- Decision 016、Project Context 與 Roadmap 已同步標記 Milestone 13 完成；下一階段為 Milestone 14 Offline Cache。
- Milestone 13 最終驗證通過 dependency resolution、workspace code generation、analyze、全部 Flutter tests，以及 development / staging / production bundle build。

- 完成 Milestone 12-3 至 12-6：Concurrent 401 Interceptor、Safe Request Replay、Session Expiration UI Flow，以及 concurrency / failure / regression coverage。
- Main Dio 新增 `AuthRefreshInterceptor`；同 Session 的並行 401 共用 auth-side single-flight refresh，refresh 成功後使用最新 access token 安全 replay。
- Authenticated request 保存 generation / userId / failed token identity，禁止舊帳號 request 使用新帳號 token replay，並阻止 logout / relogin 後舊 request 復活。
- Replay 使用 `authRetryCount` 防止無限 retry；Stream、Multipart、upload、progress callback 與特殊 download request 不自動重送。
- Session expiration 透過 `SessionManager` stream 自然同步 AuthBloc、ProfileBloc 與 AuthGuard；interceptor 不直接操作 Router、Bloc 或 LogoutUseCase。
- 新增 10-request concurrent 401、logout/relogin race、invalid refresh cleanup failure、network failure、AuthBloc login/logout regression，以及 Mock / Real Composition Root graph 測試。

- 完成 Milestone 12-2 Refresh API 與 Auth Refresh Flow。
- 新增獨立 `AuthRefreshApi`、`MockAuthRefreshApi`、Refresh DTO、Refresh Dio 與 `AuthRefresher` 五種結果語意。
- 新增 auth-side identity-aware single-flight refresher，支援 refresh token rotation、persistence-first runtime update 與跨 Session race protection。
- 新增 `AuthStateMutationCoordinator`，序列化 Login、Restore、Logout、Refresh commit 與 passive invalidation 的 Auth state 複合修改。
- Passive invalidation 會在 lock 內再次驗證 generation / userId，舊 refresh operation 不得清除新 Session。
- Refresh failure classification 調整為只有 401 / 403 使 Session 失效；400、5xx、timeout 與 malformed success response 保留 Session。
- 新增 refresh concurrency、token rotation、persistence failure、跨帳號 in-flight、Token Pair overwrite race 與 invalidation race 測試。

- 完成 Milestone 12-1 Token Model 與 Persistence：Login / Mock / DTO / Domain 支援 refresh token，新增完整 Token Pair storage、runtime Session snapshot 與 generation。
- 新增 Auth persistence 補償式一致性：Login partial write、Restore incomplete/corrupted state、Logout dual cleanup 與 unknown error cleanup 均保持 runtime/persistence 一致。
- 新增 `StoredAuthTokens`、`AuthTokenStorage`、package-internal `AuthLocalStore` 與 `CorruptedAuthTokensException`。
- 新增 Repository persistence tests，覆蓋 User save failure、corrupted Token Pair、cleanup failure 與 unknown error stack-preserving behavior。
- 新增 Architecture Decision 015，拍板 Refresh Token、concurrent 401、single-flight refresh、request replay、session invalidation 與 Main Dio / Refresh Dio 的責任邊界。
- 將 Milestone 12 拆分為 Token Model、Refresh Flow、Concurrent 401 Interceptor、Safe Replay、Session Expiration、Concurrency Tests 與 Final Verification 七個階段。
- 補充 Decision 015：Refresh endpoint 使用獨立 `AuthRefreshApi` 與 Refresh Dio；Session identity 由 SessionManager generation 管理；Token Pair persistence failure 會清除 runtime Session 並回傳 `localStateFailure`。
- 補充 Decision 015：HTTP request 的 current access token 以 SessionManager runtime state 為唯一來源，並統一 Refresh result 的五種語意。
- 補充 Decision 015：authenticated request 需保存 Session generation / userId，禁止跨 Session 或跨帳號 replay；Token Pair 與 User 跨 storage 採補償式一致性與完整 cleanup policy。
- 完成 Milestone 10 App Configuration 與 Dart Environment Entrypoint。
- 新增 `AppEnvironment`、typed `AppConfig` / `ApiConfig` 與集中式 validation。
- 新增共用 `bootstrap` 與 development / staging / production Dart entrypoints。
- 新增 staging / production 禁止 Mock、production 強制 HTTPS 與 URL scheme validation 測試。
- 新增 Composition Root integration test，驗證 AppConfig、ApiConfig、Dio 與 Mock API graph 的實際註冊結果。
- production URL validation 擴充拒絕 mock.local、localhost、loopback 與 `.invalid` host。
- 規劃 Milestone 10：App Configuration 與 Dart Environment Entrypoint，範圍限定為 typed config、共用 bootstrap、Dart-level entrypoint 與 environment validation。
- 新增 Architecture Decision 014，明確將 Dart entrypoint 定義為 AppEnvironment 唯一來源，並將 Native Flavor 排除於 Milestone 10。
- 固定後續 Roadmap：Milestone 12 Refresh Token + Concurrent 401 Handling、Milestone 13 Pagination + Search Debounce、Milestone 14 Offline Cache。
- 新增 `AGENTS.md`，作為 AI coding agent / assistant 進入專案後的基本工作守則。
- 新增 Architecture Decision 012，明確規範可重用 package 不直接綁定 DI framework。
- 新增 Architecture Decision 013，規範所有真實 HTTP API 統一使用 Retrofit，Mock API 則透過相同 abstraction 提供替代實作。
- 新增 Milestone 9，規劃 Auth / Profile API 的 Retrofit 遷移、DTO / Mapper 邊界、DI 切換與驗證流程。
- 在 `packages/api_client` 加入 `retrofit` 與 `retrofit_generator`，作為後續宣告式 Dio API client code generation 基底。
- 新增 Retrofit `AuthApi`、`MockAuthApi`、`LoginRequestDto` 與 `LoginResponseDto`。
- 新增 Retrofit `ProfileApi`、`MockProfileApi` 與 `ProfileResponseDto`。
- 新增 Login response DTO 到 Auth domain result 的 Mapper。
- 新增 Profile response DTO 到 Profile domain entity 的 Mapper。
- 新增 transport exception mapper，將 DioException 隔離在 `api_client` package 內。
- 新增 App layer `ApiConfig`、`ApiMode` 與 `ApiImplementationSelector`，支援 Mock / Retrofit environment selection。
- 新增共用 `mapAppExceptionToFailure` 與 ProfileRemoteDataSource。
- 新增 Auth Retrofit request test，驗證 POST path、JSON body 與 response DTO parsing。
- 新增 Mock Profile、DTO JSON serialization、Auth / Profile mapper、transport exception 與 Profile Repository regression tests。
- 完成 Retrofit 架構審查，簡化 API abstraction、明確 Mock 目錄、RemoteDataSource 錯誤映射與 Dio 特殊例外規則。

### Changed

- 修正 Roadmap 的 Milestone 13 狀態，正式標記 Milestone 13-1 至 13-7 全部完成。

- `configureDependencies` 改為明確接收已驗證的 `AppConfig`，DI module 不再自行讀取 dart-define。
- `ApiConfig.baseUrl` 改為已驗證的 `Uri baseUri`。
- 將 Milestone 11 CI/CD 標記為 Deferred，目前不實作 GitHub Actions、build matrix 或 deployment pipeline。
- 修正 Roadmap 中 Milestone 9 開頭仍標記為 In Progress 的狀態不一致。
- 將 Android productFlavors、iOS Schemes 與其他 Native Flavor 工作移回 Backlog，等待平台 scaffold 與發布需求明確後再規劃。
- 移除 `packages/auth` 對 `injectable` 的依賴。
- 移除 `packages/auth` 內 data source、repository、use case 的 DI annotations。
- Auth package 物件改由 app 的 `RegisterModule` 統一註冊與組裝，維持 app 作為唯一 Composition Root。
- Auth RemoteDataSource 改為依賴 `AuthApi` abstraction，並由 App Composition Root 預設注入 `MockAuthApi`。
- Auth Repository 改用 DTO mapper 建立 Domain Model，持久化與 Session 更新責任維持在 Repository。
- Auth / Profile API implementation 改由 `API_MODE` 決定，Dio base URL 改由 `API_BASE_URL` 注入。
- Auth / Profile Repository 改為只映射 `AppException`，未知程式錯誤不再轉成一般 Failure。
- AuthLocalDataSource 將 SharedPreferences / SQLite 例外統一轉為 `AppException`。
- SessionManager 改為純 runtime state holder，token / user persistence 統一由 AuthRepositoryImpl 負責，移除重複 token 寫入。
- LoginRequestDto 關閉欄位型 `toString()`，並以安全 transport 摘要取代完整 DioException cause，避免敏感資料進入一般 log。
- `API_MODE=real` 時強制要求合法 `API_BASE_URL`，並補上可直接測試的 config parsing。
- 預設 API mode 維持 Mock，真實 API 可透過 `--dart-define` 啟用。
- Profile Repository 改為依賴 `ProfileRemoteDataSource`，再由其呼叫 `ProfileApi` abstraction；App Composition Root 預設注入 `MockProfileApi`。
- Authenticated Profile endpoint 改由 Retrofit `@Extra` metadata 標記，不再保留手寫 Dio request 示範方法。
- Login request DTO 明確宣告 `toJson()` contract，修正 Retrofit request body 被轉成字串而非 JSON 的問題。
- Failure 顯示訊息統一使用 Repository 提供的 domain fallback，技術 exception message 保留在 cause chain。
- 同步更新 Root README、Auth feature README、Clean Architecture 文件與 docs 導覽中的 Auth API 流程。

### Verified

- Milestone 12-7：`dart pub get`、build_runner、analyze、全部 flutter test，以及 development / staging / production bundle build 全部通過。
- Milestone 12-6：10 個 authenticated request 同時 401 只呼叫一次 refresh，並全部使用新 token replay。
- Login / Restore / Logout / AuthGuard / Profile regression、refresh token rotation、persistence compensation、Session identity race 與 invalidation cleanup failure tests。

- Milestone 10：`dart run melos run build_runner`、`dart run melos run analyze`、`dart run melos exec -- flutter test`、`flutter build bundle`。
- staging / production Dart entrypoint 已分別完成 `flutter build bundle` 驗證。
- `dart pub get`
- `dart run melos run build_runner`
- `dart run melos run analyze`
- `dart run melos exec -- flutter test`
- `flutter build bundle`
- Retrofit `POST /auth/login` request body serialization test。
- Retrofit `GET /profile` authenticated metadata test。
- Mock Auth / Profile tests、DTO JSON serialization tests、Mapper tests。
- Transport exception mapping 與 Profile Repository known / unknown error regression tests。

---

## [1.0.0] - 2026-06-27

### Added

- 建立 Flutter Enterprise Architecture Template 第一個穩定基線。
- 完成 Clean Architecture + Feature First 專案結構。
- 完成 Login Flow、Profile Flow、Route Guard、Session Restore。
- 完成 Repository Pattern、UseCase、Bloc、API Client、SQLite、SharedPreferences 整合。
- 完成 GetIt + Injectable dependency injection。
- 完成 AutoRoute shell route、nested routes 與 guarded route。
- 完成 Melos 8 + Dart Pub Workspaces migration。
- 新增 `CHANGELOG.md` 作為後續模板版本紀錄。

### Changed

- 升級 workspace SDK constraint 至 `>=3.8.0 <4.0.0`。
- 升級核心 dependency / generator / DI / router / lint stack。
- `build_runner` script 改為使用 `dart run build_runner build`。
- Freezed 3 相容性調整：`@freezed` class 改為 `abstract class`。
- Bloc Event union type 改為 `sealed class`。
- AutoRoute 測試相容新版 `children` API。
- 移除 package entrypoint 中不必要的 `library xxx;`。
- 移除 `core` package 未使用的 dependencies。

### Verified

- `dart pub get`
- `dart run melos run build_runner`
- `dart run melos exec -- flutter analyze`
- `dart run melos exec -- flutter test`
- `flutter build bundle`
