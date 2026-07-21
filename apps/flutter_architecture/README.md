---
document_type: app-readme
status: accepted
authoritative_for:
  - flutter-architecture-app-local-contract
last_reviewed_baseline: 1.5.1
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
- Debug／production error reporter composition。

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
cd apps/flutter_architecture
flutter build bundle
flutter build apk --release -t lib/main_production.dart
```

## Related Decisions

主要 authority 位於 `docs/architecture_decisions.md`，特別是 Composition Root、environment、refresh、offline cache、design system、localization、failure architecture 與 authentication security 相關 Decisions。

本 README 只保存 App local current contract，不保存 Milestone journal、test count 或 commit timeline。
