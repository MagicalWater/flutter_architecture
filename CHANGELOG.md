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

- 新增 `AGENTS.md`，作為 AI coding agent / assistant 進入專案後的基本工作守則。
- 新增 Architecture Decision 012，明確規範可重用 package 不直接綁定 DI framework。

### Changed

- 移除 `packages/auth` 對 `injectable` 的依賴。
- 移除 `packages/auth` 內 data source、repository、use case 的 DI annotations。
- Auth package 物件改由 app 的 `RegisterModule` 統一註冊與組裝，維持 app 作為唯一 Composition Root。

### Verified

- `dart pub get`
- `dart run melos run analyze`
- `dart run melos exec -- flutter test`
- `flutter build bundle`

> 本次 `dart run melos run build_runner` 因工具安全檢查擋下，未能重跑；本次未修改 source generator input，不影響 generated files。

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
