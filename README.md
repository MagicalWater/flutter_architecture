# Flutter Enterprise Architecture Template

本專案不是 Boilerplate，也不是 Demo，而是一份可以持續演進、可直接作為企業專案起點的 Flutter Enterprise Template。

它的目標是建立一個清楚、穩定、可擴充、可閱讀的 Flutter 架構模板，同時讓開發者能透過程式碼與文件理解 Clean Architecture 在中大型專案中的實際落地方式。

---

## 專案狀態

- Template Baseline Version：1.0.0
- Phase 1 / MVP：Completed
- Melos 8 / Dart Pub Workspaces Migration：Completed
- Dependency Upgrade：Completed
- Modernization Review：Completed

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
- Router
- DI composition
- ShellPage
- LoginPage
- ProfilePage
- ProtectedPage
- Feature 的 Presentation Layer

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
- API response model

### packages/auth

Auth 共用能力。

後續 Milestone 會把 Auth 的 domain / data 從 app feature 移動到這裡。

目標是：

```txt
packages/auth
  負責 Auth domain / data / session

apps/flutter_architecture/lib/features/auth
  只保留 Auth presentation
```

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
flutter build bundle
```

---

## Flutter Web 注意事項

若要在 Flutter Web 使用 SQLite，需要先準備 sqflite_common_ffi_web 的 Web binary：

```bash
cd apps/flutter_architecture
dart run sqflite_common_ffi_web:setup
```

若 app 尚未建立 web 平台資料夾：

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

建議閱讀順序：

```txt
AGENTS.md
  ↓
README.md
  ↓
CHANGELOG.md
  ↓
VERSION
  ↓
docs/project_context.md
  ↓
docs/architecture_decisions.md
  ↓
docs/roadmap.md
  ↓
docs/conversation_rules.md
```

### AGENTS.md

給 AI coding agent / assistant 使用的專案工作守則。

### docs/project_context.md

專案目前完整上下文。

新的 ChatGPT 對話應該先讀這份文件。

### docs/architecture_decisions.md

所有已拍板的架構決策。

如果某個架構問題已經在這裡被標記為 Accepted，後續不應該反覆重新討論，除非有新的需求或新的限制。

### docs/roadmap.md

接下來的 Milestone 規劃。

### docs/backlog.md

暫時不做，但未來可以加入的想法。

### docs/conversation_rules.md

本專案與 ChatGPT 協作時的工作規範。

### CHANGELOG.md

正式版本變更紀錄。

### VERSION

目前 Template Baseline Version 的唯一版本來源。

### docs/archive/

歷史進度與已完成 milestone 紀錄。

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

若需要在新的 ChatGPT 對話中延續本專案，請先閱讀：

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

閱讀完成後，請依照 `docs/roadmap.md` 與 `CHANGELOG.md` 判斷下一個目標。

不要依賴舊對話內容作為唯一上下文，專案文件才是 Single Source of Truth。
