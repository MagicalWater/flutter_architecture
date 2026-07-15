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

### Added

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
