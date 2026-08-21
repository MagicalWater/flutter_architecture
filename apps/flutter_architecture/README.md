---
document_type: app-readme
status: accepted
authoritative_for:
  - flutter-architecture-app-local-contract
last_reviewed_baseline: 1.26.1
---

# Flutter Architecture App

此 App 是 Template 的唯一 Composition Root，負責把可重用 packages、feature presentation、Flutter plugins 與 platform lifecycle 組裝成可執行 application。

## Responsibilities

- Environment entrypoints 與 `AppConfig`。
- GetIt／Injectable registration 與 lifecycle ownership。
- Auto Route、AuthGuard 與 authentication navigation coordination。
- Drift database opener、lifecycle 與 App-owned persistence adapters。
- Flutter Secure Storage、SharedPreferences、local_auth 等 plugin adapters。
- Theme、locale 與 local unlock preference controller。
- Error reporter adapter 與 Flutter／platform uncaught error boundary。
- Typed connectivity authority、platform adapter、lifecycle recheck與App-wide offline presentation。
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
- Drift Auth User 與 Catalog Cache adapters。
- `local_auth` user-presence verifier。
- Theme、locale、local unlock preference stores。
- ErrorReporter composition seam、Firebase Crashlytics reference adapter與Flutter／platform uncaught boundaries。
- `connectivity_plus` adapter、`ConnectivityController`、`ConnectivityScope`與offline banner。

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

### Runtime Assets 與 Theme-aware Visuals

- App package使用FlutterGen產生`lib/gen/assets.gen.dart`；production UI優先消費generated accessor，不重寫相同`assets/...` path literal。
- FlutterGen只負責bundle path access，不負責判定asset屬於Design System、App、Feature或component。
- Theme-aware visual以`DsThemeId + Brightness`選擇representation；Theme Identity由`ThemeControllerScope.themeIdOf(context)`提供read-only presentation access，不由Feature讀取preference store。
- 只有需要semantic/theme selection時才建立bounded resolver；單純generated accessor已清楚表達owner時直接使用，不建立mega `AppAssets`或每個asset一層wrapper。
- Asset source、transformation、hash與consumer provenance仍由既有representation mapping authority擁有，不複製到runtime constants。

新增／調整App assets後執行：

```txt
dart run build_runner build
```

FlutterGen output是generated source，不得手改。

## UI Design-space Scaling

App Composition Root 透過 `ScreenUtilInit` 擁有 product-specific design baseline；current template placeholder 位於 `lib/app/ui/app_ui_design.dart`，採用 template 成為產品時應依主要 UI 設計來源替換。

`.w/.h/.r/.sp` 的 repository-wide 使用規則只由 `packages/design_system/README.md` 的 **Design-space Measurement / ScreenUtil 使用規則**維護；App README 不複製第二份操作規則。Scaling 只負責 design-space → runtime measurement conversion，layout primitive 仍依實際 flow / spatial semantics 選擇。

## Database Schema and Migration Route

App Drift schema 與 migration 的 current source 位於：

```txt
lib/app/database/app_database.dart
lib/app/database/schema/app_database.drift
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
確認critical migration／persistence risk已有direct regression owner；必要時才新增test
  ↓
更新受影響 Feature README並執行 focused verification
```

主要 integration points：

- `lib/app/database/app_database.dart`：schema version、migration strategy與database lifecycle。
- `lib/app/database/schema/app_database.drift`：canonical table／index／constraint schema。
- `lib/app/database/app_database_opener*.dart`：native／Web production opener與path policy。
- `lib/app/di/register_module.dart`：單一`AppDatabase` singleton與DAO／adapter wiring。
- `lib/features/<feature>/data/`：Feature-local LocalDataSource、store或Repository coordination。
- `test/app/database/`：App database lifecycle與foreign-key contract。
- `test/features/<feature>/data/`：Feature persistence behavior與migration regression。

不要把 exact DDL、逐版 migration journal 或歷史測試流水帳複製進本 README。Current database authority以 [ADR-010](../../docs/adr/adr-010-cross-platform-sqlite-initialization.md)、source、schema snapshots與tests為準。

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
依changed risk確認既有validation owner；必要時才新增temporary／permanent test
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
- Existing validation owners（若changed risk需要）：`test/app/router/`、`test/app/navigation/`與受影響 Feature presentation tests。

### Dependency Injection

- External object、plugin、Database、Dio與interface binding：`lib/app/di/register_module.dart`。
- App-owned module與generated composition：`lib/app/di/`。
- Environment-specific API selection：`lib/app/di/api_implementation_selector.dart`。
- Existing validation owner（若changed risk需要）：`test/app/di/`。

Reusable package 使用 constructor injection 表達依賴，不在 package 內加入 GetIt／Injectable ownership。

### Localization

- ARB resources：`lib/l10n/`。
- Locale bootstrap、preference與controller：`lib/app/localization/`。
- Feature user-facing Failure mapping：對應 Feature `presentation/*_localization.dart`。
- Existing validation owners（若changed risk需要）：`test/app/localization/`與受影響 Feature presentation tests。

修改 ARB、Auto Route、Injectable、Freezed、JSON serialization 或 Retrofit declaration後，執行：

```bash
dart run melos run build_runner
```

不得手動修改 `*.gr.dart`、`injection.config.dart`、`*.g.dart`或`*.freezed.dart`。

### Persistence and plugin adapters

App-owned implementation放在受影響 Feature data layer或`lib/app/` integration boundary，並由Composition Root注入。新增adapter前先確認它屬於credential、public SQLite data、preference或platform user-presence等既有authority；不要建立模糊的generic persistence layer。

### Focused validation

Test Authoring、Retention與Validation Execution分開決定。普通App／Feature修改不因存在對應test folder就固定跑完整suite；先由repository planner選出minimum sufficient validation：

```bash
python tools/ci/validation_planner.py --event push --base <base-sha> --head <head-sha> --stdout-json
```

依planner輸出的exact scope執行必要docs、analyze、critical tests、generated或platform evidence。只有修改AutoRoute／Injectable／Freezed／JSON／Retrofit等generated declaration時才需要build runner；只有changed risk命中native／platform boundary時才需要代表build。完整Test Authoring／Retention policy見[Testing Governance](../../docs/guides/testing_governance.md)。

## Feature Entry Points

- `lib/features/auth/README.md`
- `lib/features/catalog/README.md`
- `lib/features/profile/README.md`
- `lib/features/protected/README.md`
- `lib/features/shell/README.md`

## Common Verification Commands

首次checkout或generated declaration變更時常用：

```bash
dart pub get
dart run melos run build_runner
```

日常change validation不要機械執行全workspace commands；以planner-selected scope為準。

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
