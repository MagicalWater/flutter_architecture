# Milestone 18-1 — Architecture & Dependency Audit

## 狀態

Completed audit；尚未進入 remediation。

本文件保存 repository inventory、dependency evidence、boundary分析與 test evidence。所有正式 finding 的唯一 Single Source of Truth 為 `docs/audits/milestone_18/findings.md`。

---

## 1. Repository inventory

### Workspace

```txt
root
├─ apps/flutter_architecture
├─ packages/core
├─ packages/api_client
├─ packages/auth
└─ packages/design_system
```

Tracked pubspec：

```txt
pubspec.yaml
apps/flutter_architecture/pubspec.yaml
packages/core/pubspec.yaml
packages/api_client/pubspec.yaml
packages/auth/pubspec.yaml
packages/design_system/pubspec.yaml
```

非 generated Dart source約為：

```txt
App                  85
core                  6
api_client            24
auth                  25
design_system         19
```

### App-owned areas

```txt
app/
  config
  database
  di
  error_reporting
  localization
  preferences
  router
  theme

features/
  auth
  catalog
  profile
  protected
  shell
```

責任判定：

- `app/` 擁有 bootstrap、environment、database factory、Composition Root、global reporting、router、Theme與Locale。
- `features/auth` 只保存 Auth Presentation；Auth Data / Domain / Session能力位於`packages/auth`。
- `features/catalog` 為完整App-local Feature，包含Data / Domain / Presentation。
- `features/profile` 為完整App-local Feature，包含Data / Domain / Presentation，並使用`packages/auth`提供的Session能力。
- `features/protected` 目前只有Presentation，認證判斷由App router guard負責。
- `features/shell` 擁有App主要navigation chrome與tab mapping。

### Package responsibilities

| Package | Current responsibility | Direct workspace dependencies |
|---|---|---|
| `core` | AppException、Failure、Result、KeyValueStorage等穩定shared contract | 無 |
| `api_client` | Dio factory、interceptors、Retrofit APIs、DTO、transport mapping與mock APIs | `core` |
| `auth` | Auth Data / Domain、Session、Refresh coordination與storage adapters | `api_client`、`core` |
| `design_system` | Theme definitions、semantic colors、tokens與primitive/page-state components | Flutter SDK |

---

## 2. Dependency graph

### Workspace package graph

```txt
flutter_architecture app
  ├─ core
  ├─ api_client ──> core
  ├─ auth ────────> api_client ──> core
  │                  └────────────> core
  └─ design_system ──> Flutter SDK
```

沒有發現 package cycle。

### App source dependency direction

Catalog與Profile目前的source dependency維持：

```txt
Presentation ──> Domain
Data ─────────> Domain
Data ─────────> api_client / core / SQLite adapters
```

Domain沒有反向依賴Presentation或Data implementation。

Auth目前的source dependency維持：

```txt
App Auth Presentation ──> packages/auth Domain / Session
packages/auth Data ─────> packages/auth Domain / Session
packages/auth Data ─────> api_client / SharedPreferences / SQLite
```

`packages/auth`本身直接依賴`dio`、`shared_preferences`與`sqflite`，但這些依賴只存在於Auth Data / Infrastructure boundary；Repository、UseCase、Entity與Session contract不直接依賴plugin implementation。Refresh transport classification仍使用`api_client`提供的typed mapper，因此此結構符合Decision 020與Milestone 17既有accepted boundary，不建立finding。

### Runtime call flow

Catalog與Profile主要runtime flow為：

```txt
Page / Bloc
  ↓
UseCase
  ↓
Repository interface
  ↓
Repository implementation
  ↓
DataSource / external service
```

Auth主要runtime flow為：

```txt
Auth Page / AuthBloc
  ↓
Auth UseCase / Session contract
  ↓
Auth Repository / Refresh coordinator
  ↓
Auth DataSource
  ↓
api_client / SharedPreferences / SQLite
```

### Composition Root

`apps/flutter_architecture/lib/app/di/register_module.dart`集中組裝：

- SharedPreferences與Database。
- Main / Refresh Dio。
- Mock / Retrofit API selection。
- Auth DataSource、Repository、UseCase、Session與Refresh協調。
- Catalog API、LocalDataSource、Repository、UseCase與Bloc。
- Profile API與RemoteDataSource；其餘Profile types由App annotations生成。
- Catalog diagnostic sink與App ErrorReporter adapter。

Packages內沒有發現`get_it`、`injectable`或DI annotation。App仍是唯一Composition Root。

---

## 3. Cross-feature dependency inventory

排除同一feature內部import後，production cross-feature依賴只有：

```txt
features/shell/presentation/pages/shell_page.dart
  └─ features/auth/presentation/bloc/auth_bloc.dart

features/auth/presentation/pages/login_page.dart
  └─ features/shell/presentation/shell_tab.dart

features/profile/presentation/pages/profile_page.dart
  └─ features/shell/presentation/shell_tab.dart
```

判定：

- Shell→AuthBloc直接違反目前專案「不要跨Feature直接依賴Bloc」的明文規則，正式記錄為`M18-A01`。
- Auth/Profile→ShellTab使feature presentation依賴Shell implementation identity，形成反向navigation依賴，正式記錄為`M18-A02`。
- ProfileBloc→`packages/auth`的`LogoutUseCase`、`SessionManager`與`AuthSession`屬跨feature shared domain capability，不是依賴另一個feature presentation detail；判定為Not an issue。
- App router與App DI引用各feature implementation屬Composition Root / routing ownership；判定為Not an issue。

---

## 4. DI ownership audit

### Package boundary

- `packages/core`、`api_client`、`auth`、`design_system`均未依賴`get_it`或`injectable`。
- Package classes使用constructor injection或plain factory表達dependency。
- App透過`RegisterModule`與App-owned annotations決定lifecycle與binding。

結論：符合既有DI與package boundary contract。

### App annotations

App annotations分布於：

- `RegisterModule`外部dependency與package wiring。
- App router / AuthGuard。
- App-local Bloc、UseCase與RemoteDataSource。

`RegisterModule`目前約230行，責任仍是Composition Root wiring，沒有業務流程或feature policy搬入。雖然後續feature增加時可能需要按bounded context拆App-owned module，但目前沒有足夠evidence支持立即重構；記錄為architecture observation，不建立finding。

---

## 5. Package public API surface

### `core`

Export surface小且集中於shared contract：AppException、Failure、Result、storage abstraction。判定合理。

### `api_client`

單一entrypoint export Retrofit API、DTO、Dio factory、interceptors、transport mapper與mock APIs。

這個surface較寬，但目前App Composition Root需要選擇Mock / Real API，Auth package需要Refresh transport contract，Catalog / Profile Data需要API與DTO。Mock APIs也是模板runtime mock mode的一部分，不只是test fixture。

結論：目前沒有證據顯示export造成不合法依賴或誤用；不因surface數量本身建立finding。後續若package要獨立發布，可再評估拆分`api_client.dart`與mock entrypoint。

### `auth`

單一entrypoint同時export Domain、Session與App Composition Root需要建立的Data implementations。

目前App只透過`package:auth/auth.dart`組裝，沒有直接import`package:auth/src/...`。Package test有兩處直接import自身`src`以測內部persistence model，屬package內測試，不構成consumer boundary leak。

結論：對目前monorepo template用途可接受，不建立finding。

### `design_system`

Export components、theme definitions與仍有consumer的tokens。沒有App localization、Bloc、Failure或feature model依賴。判定合理。

---

## 6. Mapper與abstraction audit

### Mapper

現有mapper均靠近來源boundary：

- Login response DTO → Auth domain。
- Profile response DTO → Profile domain。
- Catalog remote DTO → Catalog domain。
- Catalog cache entity → Catalog domain。

Catalog remote mapper與cache mapper處理不同來源contract，並非可無損合併的重複。沒有建立Generic Mapper的理由。

### Abstractions

- `AuthRepository`、`CatalogRepository`、`ProfileRepository`對應實際Domain use case。
- `AuthTokenProvider`、`AuthRefresher`用於隔離api_client與Auth implementation。
- `CatalogClock`、`CatalogCachePolicy`、`CatalogCacheDiagnosticSink`各有明確time policy、cache policy與App reporting adapter consumer。
- Theme / Locale preference與ErrorReporter abstractions有production / test adapter或跨boundary需求。

沒有發現只為mock而存在、沒有production語意的abstraction，也沒有Generic Repository / Cache / Pagination framework。

---

## 7. Test evidence

### Existing evidence

- `app/di/configuration_injection_test.dart`覆蓋主要DI組裝與implementation selection。
- `app/router/auth_guard_test.dart`驗證Guard依賴Session abstraction而非AuthBloc。
- `app/router/app_router_test.dart`以`ShellTab.profile.index`鎖定Shell child route mapping。
- `features/shell/presentation/pages/shell_scaffold_test.dart`覆蓋navigation chrome、callback、Theme與Locale render。
- Auth / Profile Bloc tests覆蓋Session同步與logout lifecycle。
- Package tests透過package entrypoint測主要public contract；Auth persistence test另測package internal storage detail。

### Coverage gaps

- 沒有widget / integration test直接鎖定Login成功後由LoginPage切到Profile tab。
- 沒有widget / integration test直接鎖定Profile logout成功後由ProfilePage切回Login tab。
- 沒有測試用architecture rule阻止新增cross-feature Bloc import。

前兩項與`M18-A02`一起保留，後續由18-5決定是否屬baseline test gap。第三項目前不建議為單一規則引入custom lint或architecture test；先透過audit與review維持。

---

## 8. Open-ended scan

除初始風險假設外，另檢查：

- Package cycles。
- Package直接綁定DI framework。
- App直接import package `src`。
- Package直接依賴App implementation。
- Domain依賴Presentation / Data implementation。
- Generated file被手動當作source ownership。
- Test-only abstraction。
- Mapper為消除型別而形成的generic layer。

沒有發現額外P0 / P1 architecture finding。

---

## 9. 18-1 conclusion

Architecture foundation整體健康：

- App仍是唯一Composition Root。
- Package graph無cycle。
- Package未綁定DI framework。
- Core、API、Auth與Design System責任大致清楚。
- App-localFeature維持Presentation → Domain → Data方向。
- Mapper與abstraction沒有明顯過早generic化。

正式findings：

```txt
M18-A01 — ShellPage跨Feature直接依賴AuthBloc
M18-A02 — Auth / Profile presentation反向依賴ShellTab
```

本階段只完成audit與落檔，不修改production code。Findings需等18-6C Audit Review Gate統一決定remediation。

---

## 10. 18-1 review closure

Review已完成並封閉18-1：

- 修正App非generated Dart source數量為85。
- 將source dependency direction與runtime call flow分開描述，避免將Clean Architecture依賴方向誤寫為Domain依賴Data implementation。
- 補記`packages/auth`直接使用Dio、SharedPreferences與SQLite屬既有accepted infrastructure boundary，不是新finding。
- 重查相對路徑import、package cycle、package→App依賴與DI framework洩漏，未發現額外P0 / P1 architecture finding。
- `M18-A01`維持P1，`M18-A02`維持P2。

18-1狀態：Reviewed / Closed。下一個正式階段為18-2 Runtime Critical Flow Audit。
