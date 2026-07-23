---
document_type: app-readme
status: accepted
authoritative_for:
  - flutter-architecture-app-local-contract
last_reviewed_baseline: 1.8.0
---

# Flutter Architecture App

此 App 是 Template 的唯一 Composition Root，負責把可重用 packages、feature presentation、Flutter plugins 與 platform lifecycle 組裝成可執行 application。

## Responsibilities

- Environment entrypoints 與 `AppConfig`。
- GetIt／Injectable registration 與 lifecycle ownership。
- Auto Route、AuthGuard 與 authentication navigation coordination。
- SQLite factory、database lifecycle 與 App-owned persistence adapters。
- Flutter Secure Storage、SharedPreferences、local_auth 等 plugin adapters。
- Theme、locale 與 local unlock preference controller。
- Error reporter adapter 與 Flutter／platform uncaught error boundary。
- Feature presentation composition。

## Non-responsibilities

- 不在 App 內複製 `packages/auth` 的 Domain／Data／Session contract。
- 不讓 reusable package 反向依賴 App、GetIt、Injectable 或 plugin implementation。
- 不以 Router、Bloc 或 Widget 取代 Domain boundary。

## Entrypoints

```txt
lib/main_development.dart
lib/main_staging.dart
lib/main_production.dart
  ↓
bootstrap
  ↓
AppConfig + DI + database + controllers
  ↓
App
```

Environment 由 Dart entrypoint 與 `--dart-define` 組合決定；App 不在 runtime UI 中切換正式環境。

## Routing and Startup

- `AppRouter` 定義 Login、OTP、Local Unlock、Shell、Profile 與 Protected routes。
- `AuthGuard` 依賴 `SessionManager`／Auth session abstraction，不依賴 `AuthBloc`。
- `AuthNavigationCoordinator` 擁有 authentication destination transition。
- `StartupLocalUnlockCoordinator` 在 restore candidate 上執行 local user-presence gate。
- Shell 只負責 layout 與使用者主動 navigation action。

## Platform Adapters

App-owned adapters 包含：

- Flutter Secure Storage credential adapter。
- Legacy SharedPreferences credential migration adapter。
- SQLite Auth User 與 Catalog Cache adapters。
- `local_auth` user-presence verifier。
- Theme、locale、local unlock preference stores。
- ErrorReporter composition seam、Debug adapter與Flutter／platform uncaught boundaries；production remote adapter仍待Milestone 27。

Package 只定義 interface、policy 或純 Dart orchestration；plugin ownership 留在 App。

## Persistence Authority

```txt
Credential Token Pair
→ Flutter Secure Storage

Public AuthUser identity
→ SQLite

Legacy SharedPreferences credential
→ migration / cleanup only

Catalog public read cache
→ SQLite

Theme / Locale / Local Unlock preference
→ App-owned preference stores
```

Logout 清除 Auth credential、Auth User 與 runtime Session，但保留 public Catalog Cache。

## Localization and Appearance

- 使用 Flutter `gen_l10n`。
- Supported locales：English、`zh_TW`。
- App 擁有 locale preference、restore 與 controller。
- `design_system` 提供 Theme definitions 與 UI primitives；App 擁有 theme preference、controller 與 Appearance selector。

## Database Schema and Migration Route

App SQLite schema 與 migration 的 current source 位於：

```txt
lib/app/database/app_database_schema.dart
```

新增 table、column、index、constraint 或資料清理 migration 時，依下列順序處理：

```txt
確認受影響 Feature 與 persistence authority
  ↓
提高 AppDatabaseSchema.version
  ↓
更新 onCreate fresh-install path
  ↓
新增由 oldVersion 判斷的 incremental onUpgrade path
  ↓
確認 onConfigure / foreign-key contract仍成立
  ↓
更新受影響 LocalDataSource 或 App-owned store
  ↓
新增 fresh-create、upgrade與persistence regression tests
  ↓
更新受影響 Feature README並執行 focused verification
```

主要 integration points：

- `lib/app/database/app_database_schema.dart`：schema version、fresh-create與incremental upgrade。
- `lib/app/di/register_module.dart`：Database open lifecycle、`onConfigure`、`onCreate`與`onUpgrade` wiring。
- `lib/features/<feature>/data/`：Feature-local LocalDataSource、store或Repository coordination。
- `test/app/database/`：App database lifecycle與foreign-key contract。
- `test/features/<feature>/data/`：Feature persistence behavior與migration regression。

不要把 exact DDL、逐版 migration journal 或歷史測試流水帳複製進本 README。SQLite initialization與Feature persistence policy分別以 [ADR-010](../../docs/adr/adr-010-cross-platform-sqlite-initialization.md)、相關 persistence ADR、source與tests為準。

## App Integration Route

新增或整合 Feature 時，先使用 [How to Add a Feature](../../docs/guides/how-to-add-feature.md) 作為完整操作入口；App-specific integration 依下列順序檢查：

```txt
Router declaration / Guard / App coordinator
  ↓
App DI registration and environment selection
  ↓
Localization resources and feature-local failure mapping
  ↓
App-owned persistence or plugin adapter
  ↓
App / Feature regression tests
  ↓
build_runner when generated source is affected
  ↓
repository validation
```

### Router and navigation

- Route declaration：`lib/app/router/app_router.dart`。
- Guard：`lib/app/router/auth_guard.dart`。
- Authentication destination transition：`lib/app/navigation/auth_navigation_coordinator.dart`。
- Generated route：`lib/app/router/app_router.gr.dart`，不得手動修改。
- Regression tests：`test/app/router/`、`test/app/navigation/`與受影響 Feature page tests。

### Dependency Injection

- External object、plugin、Database、Dio與interface binding：`lib/app/di/register_module.dart`。
- App-owned module與generated composition：`lib/app/di/`。
- Environment-specific API selection：`lib/app/di/api_implementation_selector.dart`。
- Regression tests：`test/app/di/`。

Reusable package 使用 constructor injection 表達依賴，不在 package 內加入 GetIt／Injectable ownership。

### Localization

- ARB resources：`lib/l10n/`。
- Locale bootstrap、preference與controller：`lib/app/localization/`。
- Feature user-facing Failure mapping：對應 Feature `presentation/*_localization.dart`。
- Regression tests：`test/app/localization/`與受影響 Feature presentation tests。

修改 ARB、Auto Route、Injectable、Freezed、JSON serialization 或 Retrofit declaration後，執行：

```bash
dart run melos run build_runner
```

不得手動修改 `*.gr.dart`、`injection.config.dart`、`*.g.dart`或`*.freezed.dart`。

### Persistence and plugin adapters

App-owned implementation放在受影響 Feature data layer或`lib/app/` integration boundary，並由Composition Root注入。新增adapter前先確認它屬於credential、public SQLite data、preference或platform user-presence等既有authority；不要建立模糊的generic persistence layer。

### Focused validation

依修改內容至少執行相關 App／Feature tests，並在repository root執行：

```bash
dart run melos run docs_check
dart run melos run build_runner
dart run melos run analyze
dart run melos exec -- flutter test
```

只有文件變更且未影響generated source或runtime contract時，可以依change-aware CI contract省略不相關的重量驗證；實作變更仍須依受影響scope執行focused tests與代表build。

## Feature Entry Points

- `lib/features/auth/README.md`
- `lib/features/catalog/README.md`
- `lib/features/profile/README.md`
- `lib/features/protected/README.md`
- `lib/features/shell/README.md`

## Verification Commands

在 repository root：

```bash
dart pub get
dart run melos run build_runner
dart run melos run analyze
dart run melos exec -- flutter test
```

App build：

```bash
bash tools/ci/build_android_development.sh
API_BASE_URL=https://staging-api.your-domain.example \
  bash tools/ci/build_android_environment.sh \
    staging debug lib/main_staging.dart real
API_BASE_URL=https://api.your-domain.example \
  bash tools/ci/build_android_production.sh

bash tools/ci/build_ios_development.sh
API_BASE_URL=https://staging-api.your-domain.example \
  bash tools/ci/build_ios_environment.sh \
    staging Staging Debug-staging iphonesimulator \
    lib/main_staging.dart real
API_BASE_URL=https://api.your-domain.example \
  bash tools/ci/build_ios_production.sh
```

以上是 repository verification commands，不是 production signing／Store distribution commands。產品 identifier、display name、API domain 與 signing 採用流程請讀 `docs/guides/native_environment_adoption.md`。

## Related Decisions

主要 authority 位於 `docs/adr/README.md`，特別是 Composition Root、environment、refresh、offline cache、design system、localization、failure architecture與authentication security相關 ADR。

本 README 只保存 App local current contract，不保存 Milestone journal、test count 或 commit timeline。
