# Flutter Enterprise Architecture Template

本專案不是 Boilerplate，也不是 Demo，而是一份可以持續演進、可直接作為企業專案起點的 Flutter Enterprise Template。

它的目標是建立一個清楚、穩定、可擴充、可閱讀的 Flutter 架構模板，同時讓開發者能透過程式碼與文件理解 Clean Architecture 在中大型專案中的實際落地方式。

---

## 專案狀態

- Template Baseline Version：1.6.0
- Phase 1 / MVP：Completed
- Melos 8 / Dart Pub Workspaces Migration：Completed
- Dependency Upgrade：Completed
- Modernization Review：Completed
- Milestone 12 Refresh Token / Concurrent 401：Completed
- Milestone 13 Pagination / Search Debounce：Completed
- Milestone 14 Offline Cache：Archived
- Milestone 15 Design System Foundation：Completed
- Milestone 16 Localization Foundation：Completed
- Milestone 17 Exception & Failure Architecture：Completed
- Milestone 18 Template Baseline Holistic Audit：Completed
- Milestone 19 Secure Credential Storage & Migration：Completed / Archived
- Milestone 20 OTP Step-Up Authentication：Completed / Archived
- Milestone 21 Biometric-gated Local Session Unlock：Completed / Archived
- Milestone 22 Documentation Authority & Navigation Foundation：Completed / Archived
- Milestone 23 Architecture Decision Record Extraction & Normalization：Completed / Archived
- Milestone 24 CI/CD Foundation：Completed / Archived

平台能力：

| Platform | Capability |
|---|---|
| Android | Supported（含biometric-gated local session unlock） |
| iOS | Dependency-ready |
| Web | Dependency-ready |
| Windows | Dependency-ready |
| macOS | Dependency-ready |
| Linux | Dependency-ready |

目前只有 Android 包含 tracked runner、release artifact 與 runtime smoke 證據。其他平台的 Dart dependency 與 conditional implementation 已準備，但 repository 不包含可直接執行的 runner。

版本變更請參考 `CHANGELOG.md`。

---

## 專案定位

本專案適合已經會寫 Flutter，但開始遇到下列問題的開發者：

- Repository 應該放在哪？
- UseCase 到底有什麼價值？
- Feature First 要怎麼拆？
- Auth 這種跨頁面功能要放 app feature，還是 package？
- Route Guard 要不要依賴 Bloc？
- Profile 頁面可不可以直接讀 AuthBloc？
- Web / Desktop / Mobile 的本地資料庫差異要怎麼處理？

本專案不追求最少程式碼，而是追求：

```txt
可讀性
  > 炫技

清楚邊界
  > 快速堆功能

長期維護
  > 短期方便
```

---

## 技術選型

### Architecture

- Clean Architecture
- Feature First
- Monorepo
- Melos

### Presentation Layer

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
- Retrofit
- Mock API
- Authorization Header Interceptor
- Refresh Token rotation
- Concurrent 401 single-flight refresh
- Session-aware safe request replay

真實 HTTP API 統一使用 Retrofit 宣告；Mock implementation 與 Retrofit generated implementation 共用相同 API abstraction，並由 App Composition Root 決定實際注入哪一個 implementation。

Authenticated request 由 Main Dio 加入 access token；401 refresh 使用獨立 Refresh Dio，避免 refresh request 再次進入 auth interceptor。多個同 Session 的並行 401 共用一次 refresh，成功後只有可安全重送的 request 才會以新 token replay。Logout、Session expiration 或帳號切換後，舊 request / 舊 refresh response 都不得使用新 Session 身分繼續執行。

`main.dart` 與 `main_development.dart` 使用 development；staging / production 分別使用獨立 Dart entrypoint。預設 development 使用 Mock API。

Development Mock：

```bash
cd apps/flutter_architecture
flutter run
```

Development Real API：

```bash
cd apps/flutter_architecture
flutter run \
  --dart-define=API_MODE=real \
  --dart-define=API_BASE_URL=https://api.example.com
```

Staging：

```bash
cd apps/flutter_architecture
flutter run \
  -t lib/main_staging.dart \
  --dart-define=API_MODE=real \
  --dart-define=API_BASE_URL=https://staging-api.example.com
```

Production：

```bash
cd apps/flutter_architecture
flutter run \
  -t lib/main_production.dart \
  --dart-define=API_MODE=real \
  --dart-define=API_BASE_URL=https://api.example.com
```

規則：

- `API_MODE` 只接受 `mock` 或 `real`。
- development 可使用 Mock 或 Real API。
- staging / production 只允許 Real API。
- Real API 必須明確提供 `API_BASE_URL`。
- URL 只允許 HTTP / HTTPS；production 強制 HTTPS，並拒絕 mock.local、localhost、loopback 與 `.invalid` URL。
- Dart entrypoint 是 App Environment 的唯一來源，不使用 `APP_ENV` dart-define。
- 預設 Android application ID 是模板 placeholder：`com.example.flutterarchitecture`。建立正式產品時必須替換 application ID、namespace、Kotlin package、App label 與 signing configuration。
- Repository 的 release build 使用 debug signing，只用於本地 artifact verification，不可直接當作正式上架簽名。

### Storage

- SharedPreferences
- SQLite
- sqflite
- sqflite_common_ffi
- sqflite_common_ffi_web

### Reactive

- RxDart

### Design System

- Reusable `packages/design_system`
- Default / Ocean Theme identities
- Light / Dark / System mode
- Persistent appearance preference
- Semantic colors and Material component themes
- Shared blocking page-state surfaces
- Non-blocking status banner and loading button content
- Narrow viewport, large text and four-theme-combination regression coverage

### Localization

- Flutter official `gen_l10n`
- English and Traditional Chinese (`zh_TW`)
- System / English / Traditional Chinese locale preference
- Runtime locale switching with persisted App-local preference
- Explicit locale-list resolution for Traditional and Simplified Chinese
- Feature-local user-facing failure mapping
- Locale-aware Catalog date and time formatting through `intl`
- App-owned localization; Design System only receives localized presentation text

---

## 專案結構

```txt
root/
  apps/
    flutter_architecture/
  packages/
    core/
    api_client/
    auth/
    design_system/
  docs/
  melos.yaml
  pubspec.yaml
  analysis_options.yaml
  README.md
```

### apps/flutter_architecture

主 App 專案。

負責：

- App bootstrap
- Typed AppConfig
- Dart environment entrypoints
- Router
- DI composition
- ShellPage
- LoginPage
- ProfilePage
- CatalogPage
- ProtectedPage
- Feature 的 Presentation Layer
- Catalog cursor pagination、search debounce、refresh 與 load more 範例
- Catalog feature-level Offline Cache、Stale-While-Revalidate、retention cleanup 與 cached/stale UI
- App-local Theme 與 Locale preference、bootstrap restore、runtime selector 與 `MaterialApp.router` wiring
- English / `zh_TW` App chrome、Auth、Profile、Protected 與 Catalog localization

Catalog Cache 以 `query + requested cursor + limit` 作為 page identity。Fresh Cache 可直接呈現，Stale Cache 先顯示並背景更新，Pull-to-refresh 強制 Remote，Append 使用 retained page Cache 或 Remote fallback。Cache 是可重建的 public read model，因此 Logout 只清除 Auth state，不清除 Catalog Cache。

### packages/core

共用基礎能力。

例如：

- Result
- Failure
- AppException
- Storage abstraction

### packages/api_client

Network boundary。

例如：

- Dio factory
- API client
- AuthHeaderInterceptor
- AuthRefreshInterceptor
- Auth refresh abstraction / result
- Safe request replay metadata
- API response model

### packages/auth

Auth 共用能力。

目前負責：

```txt
packages/auth
  負責 Auth domain / data / session
  負責 Token Pair persistence
  負責 refresh single-flight 與 token rotation
  負責 Session invalidation 與 mutation coordination

apps/flutter_architecture/lib/features/auth
  只保留 Auth presentation
```

### packages/design_system

Design System 共用能力。

Milestone 15 已完成，現在提供：

- Primitive design tokens。
- Semantic color role contract。
- Theme ID / metadata / definition contract。
- Theme Registry 與 default / duplicate / fallback validation。
- Default / Ocean Theme 的 Material 3 Light / Dark variants。
- Typography、核心 Material component themes 與 semantic colors。
- App-local Theme preference、persistence 與 Appearance selector。
- Status Banner、constrained content、loading button content 與共用 page-state surfaces。
- Login、Profile、Protected、Catalog 與 Shell 的 Theme-aware 導入範例。
- 窄畫面、大型文字、四組 Theme composition 與 stable gallery golden regression。

Package 不依賴 App、Feature、DI framework 或 persistence implementation；Theme preference、controller、storage 與 selector workflow 留在 App，App 仍是唯一 Composition Root。

---

## Demo Flow

目前 MVP 只需要四個頁面：

```txt
ShellPage(A)
  ├── LoginPage(B)
  ├── ProfilePage(C)
  └── ProtectedPage(D)
```

需求：

- ShellPage 有 AppBar 與 BottomNavigationBar。
- BottomNavigationBar 有 Login 與 Profile 兩個 tab。
- Login 頁面按下登入後，走完整 Clean Architecture 流程。
- 登入成功後保存 token 與 profile。
- Profile 頁面顯示目前登入的使用者名稱。
- 沒登入時 Profile 頁面顯示尚未登入。
- AppBar 右上角按鈕可以進入 ProtectedPage。
- ProtectedPage 需要登入才能進入。
- 未登入時 Route Guard 會導回 LoginPage。

---

## Runtime Flow

```txt
UI
  ↓
Bloc
  ↓
UseCase
  ↓
Repository Interface
  ↓
RepositoryImpl
  ↓
DataSource
  ↓
ApiClient / SQLite / SharedPreferences
```

---

## 快速開始

本專案使用 Melos 8 + Dart Pub Workspaces。

目前 workspace SDK constraint 為：

```yaml
environment:
  sdk: ">=3.8.0 <4.0.0"
```

Workspace 設定集中在 root `pubspec.yaml`：

```txt
workspace:
  - apps/flutter_architecture
  - packages/api_client
  - packages/auth
  - packages/core
  - packages/design_system

melos:
  scripts:
    analyze
    build_runner
```

各 app / package 的 `pubspec.yaml` 需要設定：

```yaml
resolution: workspace
```

### 1. 安裝 dependencies

本專案使用 Melos 8 + Dart Pub Workspaces，日常安裝 dependencies 請在 workspace root 執行：

```bash
dart pub get
```

### 2. 清理 workspace 狀態（需要時）

遇到 dependency link、build cache 或 workspace 狀態異常時，先清理：

```bash
dart run melos clean
dart pub get
```

### 3. 產生程式碼

```bash
dart run melos run build_runner
```

`build_runner` script 會使用 `dart run build_runner build`，並搭配 `--order-dependents --concurrency=1`，確保上游 package 先產生 Freezed / JSON / Injectable / Auto Route 檔案，再產生下游 package。

### 4. 分析與測試

```bash
dart run melos run analyze
dart run melos exec -- flutter test
```

### 5. Build 驗證

```bash
cd apps/flutter_architecture
flutter build bundle
```

---

## 第一階段收尾流程

第一階段 MVP 完成前，Milestone 5 會以 Release Candidate 的方式收尾。

Milestone 5 不新增業務功能，而是確認專案可以作為 Flutter Enterprise Template 的穩定基線。

```txt
Milestone 5-1：文件整理
  ↓
Milestone 5-2：程式碼整理
  ↓
Milestone 5-3：最終驗收
```

最終驗收至少執行：

```bash
dart pub get
dart run melos run build_runner
dart run melos run analyze
dart run melos exec -- flutter test
cd apps/flutter_architecture
flutter build apk --release
```

目前 Android runtime smoke 已驗證：bootstrap、Mock Login、Login → Profile、Catalog 顯示與搜尋、Protected Route、Theme / Locale 持久化、Secure credential Login、force-stop / restart Restore、real API 401 → Refresh rotation → Replay、predecessor release Legacy migration、Logout destructive cleanup，以及 Android 上實際建立 Secure Storage、SharedPreferences 與 SQLite database。

Auth persistence authority：

```txt
Credential Token Pair
  → FlutterSecureStorage

Public AuthUser identity
  → SQLite

Legacy SharedPreferences credential
  → migration / cleanup only
```

Secure credential storage只提供credential-at-rest hardening，不代表可防止rooted device、runtime memory擷取或server compromise。

目前baseline另包含server-issued OTP step-up authentication，以及Android上的biometric-gated local session unlock。OTP不宣稱可防止SIM-swap或保證SMS provider delivery；Biometric只驗證本機user presence，不是Server authentication，也不構成cryptographic Device Binding。Device Binding與Passkey仍不屬於目前baseline。

---

## Flutter Web 注意事項

若要在 Flutter Web 使用 SQLite，需要先準備 sqflite_common_ffi_web 的 Web binary：

```bash
cd apps/flutter_architecture
dart run sqflite_common_ffi_web:setup
```

Web 目前是 Dependency-ready，repository 不包含 tracked Web runner。要在自己的分支提升為可執行 Web application，可先建立 runner：

```bash
cd apps/flutter_architecture
flutter create . --platforms web
```

之後可以執行：

```bash
flutter build web
```

SQLite 初始化已透過條件匯入處理：

```txt
Mobile
  使用 sqflite 原生實作

Desktop
  使用 sqflite_common_ffi

Web
  使用 sqflite_common_ffi_web
```

---

## 文件導覽

文件系統的正式入口是：

```txt
docs/README.md
```

它定義文件 taxonomy、authoritative owner、AI 最小讀取集，以及 Architecture、Feature、Package、Milestone、Review、Release 與 historical investigation 的按需路由。

主要入口：

- `AGENTS.md`：AI 操作規則與安全邊界。
- `VERSION`：目前 Template Baseline Version 的唯一來源。
- `docs/project_context.md`：目前有效 project snapshot。
- `docs/roadmap.md`：Active、candidate、deferred 與 closed routing。
- `docs/adr/README.md`：canonical Architecture Decision index與正式 authority。
- `docs/architecture_decisions.md`：legacy compatibility route。
- `docs/audits/README.md`：Review 與 runtime evidence 索引。
- `docs/superpowers/README.md`：Design specs 與 implementation plans 索引。
- `docs/milestones/README.md`：Milestone artifacts routing。
- `docs/guides/ci_cd_operations.md`：CI、Branch Protection、artifact與failure／rollback操作指南。
- `CHANGELOG.md`：正式版本變更紀錄。

不要把所有文件都放入每次必讀清單；依 `docs/README.md` 的任務式路由讀取即可。

---

## 開發原則

- 文件、README、註解預設使用繁體中文。
- 技術名詞、套件名稱、類別名稱保留英文。
- 可讀性優先於技巧。
- 不為了少寫幾行而犧牲架構邊界。
- 跨 Feature 不直接依賴對方的 Bloc。
- Route Guard 不依賴 AuthBloc，而應依賴 SessionManager 或 domain abstraction。
- UseCase 以一個業務行為為單位，不使用過大的 AuthUseCase。
- 每個 Milestone 必須驗證 analyze / test / build。

---

## 開新對話（給 ChatGPT）

若需要在新的 ChatGPT 對話中延續本專案，固定先閱讀：

```txt
AGENTS.md
VERSION
docs/README.md
docs/project_context.md
docs/roadmap.md
```

閱讀完成後，再依 `docs/README.md` 的 task-based route 載入該任務需要的 Decision、Feature／Package README、spec、plan、review、source 與 tests。

不要依賴舊對話內容作為唯一上下文，也不要把全部歷史文件載入 active context。
