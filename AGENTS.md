# AGENTS.md

本文件是給 AI coding agent / assistant 使用的專案工作守則。

專案文件是 Single Source of Truth。不要只依賴聊天紀錄或歷史記憶判斷目前狀態。

---

## 進入專案後先閱讀

開始任何修改前，請先閱讀：

```txt
README.md
CHANGELOG.md
VERSION
docs/project_context.md
docs/architecture_decisions.md
docs/roadmap.md
docs/conversation_rules.md
```

如果工作範圍涉及特定文件目錄，也請閱讀該目錄下相關說明。

---

## 專案定位

本專案是 Flutter Enterprise Architecture Template。

它不是 Demo，也不是 Boilerplate，而是一份可以持續演進、可直接作為企業專案起點的 Flutter 架構模板。

核心架構：

- Clean Architecture
- Feature First
- Monorepo
- Melos 8
- Dart Pub Workspaces
- flutter_bloc / flutter_hooks / hooked_bloc
- auto_route
- get_it / injectable
- Dio
- SQLite / SharedPreferences

---

## 語言與文件規範

- 文件、README、註解預設使用繁體中文。
- 技術名詞、套件名稱、類別名稱保留英文。
- 不使用簡體中文。
- 新增或改變架構規則時，必須同步更新文件。

---

## 架構守則

### Clean Architecture

依賴方向維持：

```txt
Presentation
  ↓
Domain
  ↓
Data
  ↓
Infrastructure / External Service
```

不要讓 domain layer 依賴 presentation 或 data implementation。

### Feature First

feature 內部可有：

```txt
presentation/
domain/
data/
```

跨 feature 共用能力才提升到 `packages/`。

### Bloc 邊界

- Page 只依賴自己的 Bloc。
- 不要跨 feature 直接讀取其他 feature 的 Bloc。
- 跨 feature 狀態應透過 SessionManager、Repository Interface、UseCase 或 domain abstraction。

### Route Guard 邊界

- Route Guard 不依賴 AuthBloc。
- AuthGuard 應依賴 SessionManager / AuthSessionReader 這類穩定 abstraction。

### UseCase 粒度

UseCase 以一個業務行為為單位，例如：

```txt
LoginUseCase
LogoutUseCase
RestoreSessionUseCase
GetProfileUseCase
```

不要建立過大的 `AuthUseCase`、`UserUseCase`。

---

## DI 與 package 邊界

App 是 Composition Root。

可重用 package 預設不直接綁定 DI framework：

```txt
packages/auth
packages/api_client
packages/core
```

package 內 class 使用 constructor injection 表達依賴，但不標註：

```txt
@injectable
@lazySingleton
@singleton
```

也不要在 package 內直接依賴 `get_it` 或 `injectable`。

DI lifecycle 與介面綁定由 app module 決定：

```txt
apps/flutter_architecture/lib/app/di/register_module.dart
```

例外：如果未來某個 package 明確被設計為完整 feature module，且已新增 architecture decision，才可以提供可由 App 呼叫的 DI registration module。

---

## API client 與外部系統

同一個外部系統的 client 可以集中在同一個 package。

不同外部系統若具備獨立 boundary，例如不同 auth、error format、rate limit、release cycle 或可重用性，應考慮拆成獨立 client package。

App / feature 不應直接知道底層打了幾個外部系統，應由 data source / repository implementation 協調。

---

## Generated files

不要手動修改 generated files，例如：

```txt
*.freezed.dart
*.g.dart
*.gr.dart
injection.config.dart
```

需要更新 generated files 時，請修改 source file 後執行 build_runner。

---

## 常用命令

在 workspace root 執行：

```bash
dart pub get
dart run melos run build_runner
dart run melos run analyze
dart run melos exec -- flutter test
```

Build 驗證：

```bash
cd apps/flutter_architecture
flutter build bundle
```

Web SQLite setup：

```bash
cd apps/flutter_architecture
dart run sqflite_common_ffi_web:setup
```

若 app 已有 Web platform scaffold：

```bash
flutter build web
```

---

## 修改流程

架構問題請依照：

```txt
討論
  ↓
拍板
  ↓
更新 docs/architecture_decisions.md
  ↓
實作
  ↓
驗證
  ↓
更新 CHANGELOG / 相關文件
  ↓
Commit
```

如果只是 bug fix 或小型文件修正，可不新增 architecture decision，但仍應確認 README / CHANGELOG / roadmap 是否需要同步。

---

## Commit 前檢查

Commit 前至少確認：

- `dart pub get` 通過。
- `dart run melos run analyze` 通過。
- `dart run melos exec -- flutter test` 通過。
- 若修改 generated source，已執行 build_runner。
- 若修改 app runtime flow，已執行 `flutter build bundle`。
- 文件與實作一致。
- 沒有把 DI framework 依賴加回可重用 package。

---

## Commit message

使用 Conventional Commits，例如：

```txt
feat(auth): add refresh token flow
fix(router): correct guard redirect behavior
refactor(di): centralize package registration in app module
docs(agent): add repository agent instructions
```
