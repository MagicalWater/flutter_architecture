# Architecture Decisions

本文件記錄目前已拍板的架構決策。

如果某個決策已標記為 Accepted，後續不應反覆重新討論，除非出現新的需求、限制或實作問題。

---

## Decision 001：使用 Clean Architecture + Feature First

**狀態：** Accepted

### 背景

本專案目標是建立中大型 Flutter 專案模板。

單純 layer-first 容易讓 feature 邊界分散；單純 feature-first 又容易忽略依賴方向。

### 決策

使用：

```txt
Feature First folder structure
Clean Architecture dependency rule
```

Feature 內部維持：

```txt
presentation
  ↓
domain
  ↓
data
```

### 原因

Feature First 讓功能邊界清楚。

Clean Architecture 讓依賴方向穩定。

### 影響

每個 feature 內都會有 presentation / domain / data。

但跨 feature 共用能力可以提升到 packages。

---

## Decision 002：使用 Monorepo + Melos

**狀態：** Accepted

### 背景

本專案需要同時管理 app 與多個 package。

### 決策

使用：

```txt
root/
  apps/
  packages/
```

並透過 Melos 管理 workspace。

### 原因

Monorepo 能讓共用能力獨立成 package，同時保持本地開發方便。

### 影響

根目錄需要 root `pubspec.yaml` 管理 Dart Pub Workspaces 與 Melos 8 設定。

`melos.yaml` 只保留遷移提示，不再作為主要設定來源。

workspace package 需要在各自 `pubspec.yaml` 加上：

```yaml
resolution: workspace
```

Melos 指令統一使用：

```bash
dart run melos ...
```

避免依賴全域安裝的 melos。

`build_runner` 需要依 dependency graph 順序執行，避免乾淨 workspace 下游 package 早於上游 generated files 完成：

```bash
dart run melos exec --depends-on=build_runner --order-dependents --concurrency=1 -- dart run build_runner build
```

---

## Decision 003：Presentation 使用 flutter_bloc + flutter_hooks + hooked_bloc

**狀態：** Accepted

### 背景

Bloc 適合表達明確的業務狀態流，但傳統 BlocBuilder / BlocListener 容易產生巢狀。

### 決策

使用：

- flutter_bloc：業務狀態管理。
- flutter_hooks：UI 暫態，例如 TextEditingController。
- hooked_bloc：降低 BlocBuilder / BlocListener 巢狀。

### 原因

Bloc 負責業務狀態。

Hooks 負責 UI-local state。

hooked_bloc 負責讓 UI 讀取 Bloc 更簡潔。

### 影響

UI 可以使用：

```dart
final bloc = useBloc<AuthBloc>();
final state = useBlocBuilder(bloc);
```

但這不代表可以跨 feature 任意讀取對方 Bloc。

---

## Decision 004：使用 get_it + injectable

**狀態：** Accepted

### 背景

Clean Architecture 會產生大量依賴：Bloc、UseCase、Repository、DataSource、ApiClient、Database、Storage。

### 決策

使用：

- get_it 作為 DI container。
- injectable 產生註冊程式碼。

### 原因

手寫所有 DI 註冊容易膨脹且容易漏。

injectable 可以讓依賴註冊更穩定。

### 影響

第三方物件，例如 SharedPreferences、Database、Dio，透過 module 註冊。

---

## Decision 005：Auth domain / data 移動到 packages/auth

**狀態：** Accepted

### 背景

Auth 不是單一頁面的功能。

登入狀態、token、session、restore session、logout 都是跨整個 App 的共用能力。

### 決策

長期架構應調整為：

```txt
packages/auth
  domain
  data
  session

apps/flutter_architecture/lib/features/auth
  presentation
```

### 原因

Auth 的 domain / data 被多個 feature 使用，不應綁在 app 內某個 feature presentation 旁邊。

### 影響

AuthBloc 仍在 app 的 presentation layer。

LoginUseCase、LogoutUseCase、RestoreSessionUseCase、AuthRepository、AuthRepositoryImpl、AuthLocalDataSource、AuthRemoteDataSource 後續移到 packages/auth。

---

## Decision 006：AuthGuard 不依賴 AuthBloc

**狀態：** Accepted

### 背景

目前 AuthGuard 依賴 AuthBloc 可以運作，但 AuthGuard 真正需要的是「是否已登入」。

AuthBloc 是 Auth feature 的 presentation detail。

### 決策

AuthGuard 後續改依賴：

```txt
SessionManager / AuthSessionReader
```

不要依賴：

```txt
AuthBloc
```

### 原因

Route Guard 屬於 app router 邏輯，不應依賴某個 feature 的 UI 狀態管理實作。

### 影響

未來如果 AuthBloc 改成 Cubit / Riverpod / 其他狀態管理，AuthGuard 不需要改。

---

## Decision 007：跨 Feature 不直接依賴對方 Bloc

**狀態：** Accepted

### 背景

ProfilePage 目前可透過 AuthBloc 得知登入狀態，但這會讓 profile feature 依賴 auth feature 的 presentation layer。

### 決策

ProfilePage 不直接讀 AuthBloc。

跨 feature 登入狀態應透過：

- SessionManager
- Repository interface
- UseCase
- Domain abstraction

### 原因

Bloc 是某個 feature 的 presentation detail。

跨 feature 溝通應依賴更穩定的 domain 或 application service。

### 影響

ProfilePage 只依賴 ProfileBloc。

ProfileBloc / UseCase 負責判斷未登入、取得 Profile、回傳 UI state。

---

## Decision 008：一個 UseCase 對應一個業務行為

**狀態：** Accepted

### 背景

Auth 目前有 login、logout、restore session 三個行為。

可以合併成 AuthUseCase，也可以拆成三個 UseCase。

### 決策

維持拆分：

```txt
LoginUseCase
LogoutUseCase
RestoreSessionUseCase
```

不要合成：

```txt
AuthUseCase
```

### 原因

UseCase 表示一個明確業務行為，不是功能分類。

AuthUseCase 容易膨脹成 AuthService。

### 影響

檔案較多，但職責更清楚。

---

## Decision 009：文件與註解預設使用繁體中文

**狀態：** Accepted

### 背景

本專案主要面向中文使用者與學習者。

### 決策

文件、README、註解使用繁體中文。

技術名詞、套件名稱、類別名稱保留英文。

### 原因

降低閱讀成本，同時保持業界常用術語。

### 影響

不得混用簡體中文。

專有名詞不強行翻譯。

---

## Decision 010：跨平台 SQLite 初始化使用條件匯入

**狀態：** Accepted

### 背景

sqflite 在不同平台初始化方式不同。

Web 與 Desktop 若未初始化 databaseFactory，會出現錯誤。

### 決策

使用條件匯入：

```txt
Mobile
  sqflite 原生

Desktop
  sqflite_common_ffi

Web
  sqflite_common_ffi_web
```

### 原因

main.dart 不應直接 import dart:io，否則 Web 編譯不安全。

平台差異應隔離在 database initializer。

### 影響

Web 首次需要執行：

```bash
dart run sqflite_common_ffi_web:setup
```

---

## Decision 011：專案文件是 Single Source of Truth

**狀態：** Accepted

### 背景

ChatGPT 對話會變長，也不適合作為長期專案記憶。

### 決策

專案狀態與架構決策必須沉澱到文件。

關鍵文件：

```txt
README.md
docs/project_context.md
docs/architecture_decisions.md
docs/progress.md
docs/roadmap.md
docs/conversation_rules.md
```

### 原因

新對話、新成員或未來的自己，都應該透過文件恢復上下文。

### 影響

如果架構決策改變，先更新 architecture_decisions.md，再改程式。
