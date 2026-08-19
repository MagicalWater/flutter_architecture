# AGENTS.md

本文件是給 AI coding agent / assistant 使用的專案工作守則。

專案文件是 Single Source of Truth。不要只依賴聊天紀錄或歷史記憶判斷目前狀態。

---

## 進入專案後先閱讀

每次進入 repository 的固定最小讀取集：

```txt
AGENTS.md
repository_identity.json
VERSION
docs/README.md
docs/project_context.md
docs/roadmap.md
```

完成最小讀取後，依 `docs/README.md` 的 task-based reading route 按需載入文件。不要把 `CHANGELOG.md`、完整 Architecture Decisions、所有 audits 或所有 plans 當成每次必讀內容。

常見路由：

```txt
Architecture task
→ docs/adr/README.md 的相關 ADR + 受影響 README + source/tests

Feature task
→ Feature README + 相關 Decision + source/tests

Package task
→ Package README + 相關 Decision + public API/source/tests

Milestone execution
→ active roadmap + spec + plan + planning/phase review

Review / release
→ current contract + evidence + final review + VERSION/CHANGELOG
```

Historical 文件只能用來理解過去，不能覆蓋 current authority。

---

## 語言與文件規範

- 文件、README、註解、commit message 預設使用繁體中文。
- Commit message 使用 Conventional Commits，但描述文字必須使用繁體中文。
- 技術名詞、套件名稱、類別名稱保留英文。
- 不使用簡體中文。
- 新增或改變架構規則時，必須同步更新文件。

---

## Development Workflow Governance

任何新需求、Bug、Refactor、Migration、Architecture、Release或repository governance工作，在開始Design、Plan或Implementation前，必須先使用repository-local `governing-template-development` Skill：

```txt
.agents/skills/governing-template-development/SKILL.md
```

該Skill負責Requirement Decision、Level 0～5分類、Superpowers routing與雙層Task模式。不得直接以brainstorming、TDD、systematic-debugging或writing-plans跳過此入口。

Repository policy與current artifacts高於Skill；完整人類治理總覽見`docs/governance/development_workflow.md`。

已分類且已核准的repository-local `.pen` → Flutter工作，由中央治理在所有approval／worktree／visual authority gates通過後路由：

```txt
.agents/skills/implementing-pencil-flutter-design/SKILL.md
```

人類操作入口見`docs/guides/pencil_to_flutter_workflow.md`。本文件不複製Pencil MCP procedure；Design／Plan未核准、source仍在external path或manifest未通過時，不得提前操作Pencil或開始Flutter implementation。

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

### Presentation Component 邊界

- `Page`、`View`、`Section`、`Component`、`Surface`、`Layout`是responsibility roles，不是固定class/file/folder模板；stable authority見ADR-032。
- Handwritten source遵循「one coherent primary responsibility」，但不要求one-class-one-file；private helpers只要同lifecycle／change reason且沒有獨立authority即可共檔。
- Page/View orchestration不得同時直接擁有獨立custom RenderObject／projection engine；handwritten `part`／`part of`不能用來假裝cross-owner已拆分。
- UI-local transient state預設由State／Hook／Controller擁有；只有workflow transition、async ordering、retry/failure/concurrency等責任成立才升Cubit／Bloc。
- Dialog／BottomSheet／Overlay要分辨invocation owner與surface implementation owner；Shell可以觸發surface，不代表Shell必須擁有surface實作。
- 不使用file line count、class/widget count、fixed folder tree、`setState` ban或Bloc/Cubit presence作architecture oracle。

### UI Design Ownership 邊界

- Shared semantic／Theme Identity／validated reusable component 才由 `packages/design_system` 擁有。
- Raster／vector／icon／font／texture 的 identity、source、hash 與 provenance 走既有 asset／representation authority，不塞進 generic visual constants class。
- Canonical viewport／DPR／comparison metadata 屬 visual authority，不進 Design System。
- Single-screen exact geometry、decorative gradient、局部 spacing／radius 等只留在 smallest correct component owner；不得因 raw value 相同就 promotion。
- 不建立 `*VisualSpec`、`*VisualTokens`、`*UiSpec`、`*StyleConfig` 或等價 catch-all，把 colors、dimensions、typography、assets、gradients、geometry、canonical metadata 混成 feature 內第二套 Design System。
- Pencil/source-driven mapping 的完整 contract 由 ADR-018、ADR-028 與 `implementing-pencil-flutter-design` Skill 擁有；一般 feature 也不得違反上述 repository-wide ownership boundary。

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
dart run melos run docs_check
dart run melos run analyze
dart run melos exec --scope=flutter_architecture --scope=auth --scope=api_client -- flutter test
```

Build 驗證：

```bash
cd apps/flutter_architecture
flutter build bundle
```

Repository Android verification artifact：

```bash
bash tools/ci/build_android_release.sh
```

CI、Branch Protection、failure與rollback操作請讀：

```txt
docs/guides/ci_cd_operations.md
```

Drift Web assets重新生成：

```bash
cd apps/flutter_architecture
dart compile js web/drift_worker.dart -O4 -o web/drift_worker.js
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
更新 docs/adr/README.md 與相關 canonical ADR
  ↓
實作
  ↓
驗證
  ↓
更新 CHANGELOG / 相關文件
  ↓
Commit
```

如果只是 bug fix 或小型文件修正，可不新增 Architecture Decision，但仍應依文件 ownership 確認 current snapshot、README、roadmap 或 CHANGELOG 是否需要同步。不要為了「全面同步」而在多份文件複製同一段內容。

---

## 測試治理

新增、搬移、合併或刪除測試前，先閱讀`docs/guides/testing_governance.md`。永久test採test-by-exception：temporary test驗證完成後預設在Task closure前刪除；只有critical failure protection才保留。低價值protection可用`replacement = NONE`退休，不要求逐case deletion manifest。盤點命令：

```bash
python3 tools/testing/inventory.py
```

日常Task採 **Minimum Sufficient Validation**。不得由Agent自行猜測要跑哪些tests；先以repository-owned planner依changed range產生validation plan：

```bash
python3 tools/ci/validation_planner.py --event push --base <base-sha> --head <head-sha> --stdout-json
```

依plan執行最低充分validation；ordinary source change只跑focused／affected critical owners。Workspace full只執行目前實際擁有permanent tests的`flutter_architecture`、`auth`、`api_client`，不對空test packages執行Flutter。Full只保留給explicit full／release candidate或真正高風險cross-cutting，不再因Milestone holistic、VERSION、manual或post-release名稱自動執行。

## Commit 前檢查

Commit 前至少確認：

- 已依`tools/ci/validation_planner.py`取得本次Task／range的Minimum Sufficient Validation plan。
- planner要求的focused／affected／workspace validations全部通過。
- planner要求dependency resolution、analyze、generated、Android或iOS gate時，對應驗證已通過。
- 若本次是explicit full或release candidate，fresh logical full regression已通過；same exact SHA的post-release不得重跑相同full source regression。
- 若修改 generated source，已執行 build_runner。
- 若修改 app runtime flow，已執行 `flutter build bundle`。
- 文件與實作一致。
- 沒有把 DI framework 依賴加回可重用 package。

---

## Commit message

使用 Conventional Commits，例如：

```txt
feat(auth): 新增 Refresh Token 流程
fix(router): 修正 AuthGuard 導向邏輯
refactor(di): 將 package 註冊集中到 app module
docs(agent): 精簡 AGENTS 工作守則
```
