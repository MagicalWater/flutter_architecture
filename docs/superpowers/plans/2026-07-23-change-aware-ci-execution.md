---
document_type: implementation-plan
status: accepted
authoritative_for:
  - change-aware-ci-execution-implementation-plan
last_reviewed_baseline: 1.8.0
---

# Change-aware CI Execution Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 讓純文件變更只執行輕量治理檢查，程式／原生／依賴變更執行必要的完整驗證，且 `VERSION` 與 manual dispatch 永遠執行完整 CI、Android 與 iOS 代表矩陣。

**Architecture:** 新增 repository-owned Python change classifier，集中解析 event、base/head SHA 與 changed paths，輸出 `docs_only`、`full_ci`、`android_build`、`ios_build`、`release_full`。三份 GitHub Actions workflow 先在 Ubuntu classification job 執行 classifier；既有required-check job永遠建立並在同一job內執行重量步驟或明確no-op，非required平台job才可使用job-level `if:` skipped。

**Tech Stack:** Python 3 unittest、Git CLI、GitHub Actions YAML、Bash、Flutter 3.41.6、Dart 3.11.4、repository docs checker。

## Global Constraints

- 不使用 workflow-level `paths-ignore` 作為主要控制，避免 required check 缺失或 pending。
- 不新增第三方 path-filter action；分類邏輯由 repository-owned Python 實作。
- Unknown path、無效 base SHA、分類錯誤與首次 push 必須 fail-safe 到完整矩陣。
- `VERSION` 變更與 `workflow_dispatch` 必須設定 `full_ci=true`、`android_build=true`、`ios_build=true`、`release_full=true`。
- 純文件變更不得啟動 Android／iOS build runner，也不得執行 analyze、generated consistency或全部 Flutter tests。
- 穩定 required check名稱維持可預測；不得透過更名繞過 Branch Protection。
- `CI / Generated Consistency`、`CI / Tests`與`iOS / Simulator Build`不得因docs-only而整個job skipped；必須以原名稱成功完成no-op路徑。
- External Actions維持full SHA pin，workflow不得讀取 signing／Store secrets。
- 每個Task完成test-first implementation、self-review、findings disposition、validation與獨立commit；未經明確要求不得push。

---

## Task 1 — Change Classifier Contract

**Files:**
- Create: `tools/ci/change_classifier.py`
- Create: `tools/ci/test_change_classifier.py`

**Interfaces:**
- Produces: `Classification` dataclass，欄位為 `docs_only: bool`、`full_ci: bool`、`android_build: bool`、`ios_build: bool`、`release_full: bool`、`reason: str`。
- Produces: `classify_paths(paths: Sequence[str], *, manual: bool = False, invalid_range: bool = False) -> Classification`。
- Produces: CLI `python3 tools/ci/change_classifier.py --event <push|pull_request|workflow_dispatch> --base <sha> --head <sha> --output <path>`，以 GitHub output格式寫出五個boolean與`reason`。

- [x] **Step 1: Write failing path classification tests**

在`tools/ci/test_change_classifier.py`建立tests，至少包含：

```python
def test_docs_only_change_skips_heavy_work():
    result = classify_paths(["docs/audits/example.md", "README.md"])
    assert result.docs_only is True
    assert result.full_ci is False
    assert result.android_build is False
    assert result.ios_build is False

def test_version_change_forces_full_matrix():
    result = classify_paths(["VERSION", "CHANGELOG.md"])
    assert result.release_full is True
    assert result.full_ci is True
    assert result.android_build is True
    assert result.ios_build is True

def test_unknown_path_fails_safe():
    result = classify_paths(["unexpected/config.bin"])
    assert result.full_ci is True
    assert result.android_build is True
    assert result.ios_build is True
```

另外覆蓋 Dart source、Android-only native、iOS-only native、package、dependency、workflow、toolchain、classifier自身變更、manual與invalid range。

- [x] **Step 2: Run focused tests and confirm failure**

Run:

```bash
python3 -m unittest tools.ci.test_change_classifier -v
```

Expected: FAIL，因`tools.ci.change_classifier`尚不存在。

- [x] **Step 3: Implement minimal classifier**

在`tools/ci/change_classifier.py`實作：

```python
@dataclass(frozen=True)
class Classification:
    docs_only: bool
    full_ci: bool
    android_build: bool
    ios_build: bool
    release_full: bool
    reason: str
```

分類規則使用明確prefix／exact-match helpers；`VERSION`與manual優先，未知路徑或`invalid_range=True`回傳完整矩陣。CLI以`git diff --name-only <base> <head>`取得paths；base不存在、全零SHA或Git命令失敗時fail-safe。

- [x] **Step 4: Run classifier tests**

Run:

```bash
python3 -m unittest tools.ci.test_change_classifier -v
```

Expected: all tests PASS。

- [x] **Step 5: Run CLI simulations**

Run temporary Git ranges或直接使用CLI test fixture，確認output包含：

```txt
docs_only=true|false
full_ci=true|false
android_build=true|false
ios_build=true|false
release_full=true|false
reason=<non-empty>
```

- [x] **Step 6: Review and commit**

Review unknown path、empty diff、all-zero before SHA、path normalization與shell-safe output。Commit：

```bash
git add tools/ci/change_classifier.py tools/ci/test_change_classifier.py
git commit -m "feat(ci): 建立變更分類契約"
```

---

## Task 2 — CI Workflow Change-aware Execution

**Files:**
- Modify: `.github/workflows/ci.yml`
- Modify: `tools/ci/test_environment_workflow_matrix_contract.py`

**Interfaces:**
- Consumes classifier CLI from Task 1。
- Produces job outputs `docs_only`與`full_ci` from `classify-changes` job。
- Keeps required check names `CI / Quality`、`CI / Generated Consistency`、`CI / Tests`；三個job都永遠建立，不新增替代Gate名稱。

- [x] **Step 1: Add failing workflow contract tests**

在`tools/ci/test_environment_workflow_matrix_contract.py`新增assertions：

```python
self.assertIn("name: Classify Changes", self.quality)
self.assertIn("tools/ci/change_classifier.py", self.quality)
self.assertIn("needs.classify-changes.outputs.full_ci == 'true'", self.quality)
self.assertIn("name: Quality", self.quality)
self.assertIn("name: Generated Consistency", self.quality)
self.assertIn("name: Tests", self.quality)
self.assertNotIn("Generated Consistency Gate", self.quality)
self.assertNotIn("Tests Gate", self.quality)
```

並確認docs checker與workflow contracts在Quality永遠執行，analyze只在`full_ci=true`執行；Generated Consistency與Tests job沒有job-level `if:`，各自具有docs-only no-op step。

- [x] **Step 2: Run tests and confirm failure**

```bash
python3 -m unittest tools.ci.test_environment_workflow_matrix_contract -v
```

Expected: FAIL，因workflow尚未有classification wiring。

- [x] **Step 3: Add classification job**

在`ci.yml`新增Ubuntu `classify-changes` job，checkout使用`fetch-depth: 0`，依event設定base/head：

```txt
pull_request: pull_request.base.sha → pull_request.head.sha
push: github.event.before → github.sha
workflow_dispatch: manual full matrix
```

執行classifier並將五個outputs暴露給後續jobs。

- [x] **Step 4: Gate heavy CI work**

- `Quality`永遠執行docs checker、classifier／workflow contracts、whitespace。
- Dependency resolution與analyze使用step-level `if: needs.classify-changes.outputs.full_ci == 'true'`。
- `Generated Consistency`與`Tests`job永遠建立；dependency setup、generator與test steps使用step-level `if: needs.classify-changes.outputs.full_ci == 'true'`。
- 兩個job各自加入`full_ci != 'true'`的no-op step，輸出skip reason並成功結束；不得新增不同名稱的替代Gate。

- [x] **Step 5: Run workflow contracts and YAML parser**

```bash
python3 -m unittest tools.ci.test_change_classifier tools.ci.test_environment_workflow_matrix_contract -v
ruby -e 'require "yaml"; YAML.load_file(".github/workflows/ci.yml", aliases: true); puts "ci yaml ok"'
```

Expected: PASS。

- [x] **Step 6: Review and commit**

Review required-check semantics、PR/push/manual ranges、fetch depth、permissions與cache behavior。Commit：

```bash
git add .github/workflows/ci.yml tools/ci/test_environment_workflow_matrix_contract.py
git commit -m "ci: 依變更範圍執行品質驗證"
```

---

## Task 3 — Android Workflow Change-aware Execution

**Files:**
- Modify: `.github/workflows/android.yml`
- Modify: `tools/ci/test_environment_workflow_matrix_contract.py`

**Interfaces:**
- Consumes classifier CLI from Task 1。
- Produces `android_build` output and lightweight `Android / Summary` result。

- [x] **Step 1: Add failing Android workflow tests**

Tests must confirm：

```python
self.assertIn("name: Classify Changes", self.android)
self.assertIn("needs.classify-changes.outputs.android_build == 'true'", self.android)
self.assertIn("name: Android Summary", self.android)
```

並確認兩個artifact jobs仍保留原名稱與build scripts。

- [x] **Step 2: Run tests and confirm failure**

```bash
python3 -m unittest tools.ci.test_environment_workflow_matrix_contract -v
```

- [x] **Step 3: Wire classifier into Android workflow**

新增Ubuntu classification job；兩個build jobs以`android_build == 'true'`執行。Documentation-only時只執行summary job，不setup Java／Flutter、不上傳artifact。

- [x] **Step 4: Preserve release/manual behavior**

確認`VERSION`與`workflow_dispatch`均使兩個Android jobs執行；首次push與invalid range fail-safe full build。

- [x] **Step 5: Run tests and YAML validation**

```bash
python3 -m unittest tools.ci.test_change_classifier tools.ci.test_environment_workflow_matrix_contract -v
ruby -e 'require "yaml"; YAML.load_file(".github/workflows/android.yml", aliases: true); puts "android yaml ok"'
```

- [x] **Step 6: Review and commit**

Review artifact SHA naming、retention、secret absence與summary dependency aggregation。Commit：

```bash
git add .github/workflows/android.yml tools/ci/test_environment_workflow_matrix_contract.py
git commit -m "ci(android): 略過純文件編譯"
```

---

## Task 4 — iOS Workflow Change-aware Execution

**Files:**
- Modify: `.github/workflows/ios.yml`
- Modify: `tools/ci/test_environment_workflow_matrix_contract.py`
- Modify: `tools/ci/test_ios_workflow_contract.py`

**Interfaces:**
- Consumes classifier CLI from Task 1。
- Produces `ios_build` output；`iOS / Simulator Build`依輸出動態選擇macOS或Ubuntu runner，Production Release非required job可skipped。

- [x] **Step 1: Add failing iOS workflow tests**

Tests must confirm classifier runs onUbuntu；`Simulator Build`沒有job-level skip，`runs-on`依`ios_build`在`macos-15`與`ubuntu-24.04`間選擇，build/setup steps只在`ios_build=true`執行，docs-only no-op在同一job成功。`Production Release Build`可使用job-level condition。

- [x] **Step 2: Run tests and confirm failure**

```bash
python3 -m unittest tools.ci.test_environment_workflow_matrix_contract tools.ci.test_ios_workflow_contract -v
```

- [x] **Step 3: Wire classifier and conditions**

新增Ubuntu classification job：

- `Simulator Build`永遠建立，使用expression動態選擇runner：`ios_build=true`為`macos-15`，否則為`ubuntu-24.04`。
- Simulator的Flutter setup、cache、diagnostics、contract、build與artifact steps全部使用step-level `if: needs.classify-changes.outputs.ios_build == 'true'`。
- Simulator加入`ios_build != 'true'` no-op step並保留job名稱`Simulator Build`。
- `Production Release Build`使用job-level `if: needs.classify-changes.outputs.ios_build == 'true'`，因它目前不是required check。
- 不新增可吞掉失敗的替代summary gate。

- [x] **Step 4: Preserve artifacts and toolchain evidence**

Build執行時仍上傳development／production `.app`與兩份toolchain evidence；docs-only時完全不上傳。

- [x] **Step 5: Run tests and YAML validation**

```bash
python3 -m unittest tools.ci.test_change_classifier tools.ci.test_environment_workflow_matrix_contract tools.ci.test_ios_workflow_contract -v
ruby -e 'require "yaml"; YAML.load_file(".github/workflows/ios.yml", aliases: true); puts "ios yaml ok"'
```

- [x] **Step 6: Review and commit**

Review dynamic runner expression、macOS runner avoidance、required-check naming、failure propagation、permissions與secret boundary。Commit：

```bash
git add .github/workflows/ios.yml tools/ci/test_environment_workflow_matrix_contract.py tools/ci/test_ios_workflow_contract.py
git commit -m "ci(ios): 略過純文件編譯"
```

---

## Task 5 — Documentation and Architecture Synchronization

**Files:**
- Modify: `docs/adr/adr-023-repository-ci-quality-gates-android-verification-artifact.md`
- Modify: `docs/guides/ci_cd_operations.md`
- Modify: `docs/project_context.md`
- Modify: `docs/README.md` if routing needs an explicit link
- Create: `docs/audits/change_aware_ci_implementation_review.md`
- Modify: `docs/superpowers/specs/2026-07-23-change-aware-ci-execution-design.md`
- Modify: `docs/superpowers/plans/2026-07-23-change-aware-ci-execution.md`

**Interfaces:**
- Documents durable architecture in ADR-023 and operational trigger matrix in CI guide。

- [ ] **Step 1: Write documentation review findings**

在implementation audit記錄至少：

```txt
CA-CI-R01 all main pushes previously triggered full matrix
CA-CI-R02 workflow-level paths-ignore risks required-check absence
CA-CI-R03 evidence-only commits could recursively trigger new evidence
CA-CI-R04 unknown paths must fail safe
```

每項標示severity、fix與re-review disposition。

- [ ] **Step 2: Update ADR-023**

將「每個main push完整重驗」調整為「每個main push建立穩定CI決策，依change classification執行必要gates；release／manual與未知狀態完整重驗」。保留security、artifact與required-check邊界。

- [ ] **Step 3: Update operations guide**

新增trigger matrix：docs-only、source、Android-only、iOS-only、dependency/workflow、VERSION、manual dispatch。說明skipped不是failure、summary/gate判讀方式，以及如何手動完整驗證。

- [ ] **Step 4: Update current snapshot and plan status**

Project context只摘要change-aware能力；spec與plan已由formal review接受，本Task只更新implementation checkbox與current authority，不把path matrix複製進current snapshot。

- [ ] **Step 5: Run docs governance**

```bash
dart run melos run docs_check
python3 -m unittest tools.ci.test_change_classifier tools.ci.test_environment_workflow_matrix_contract tools.ci.test_ios_workflow_contract -v
git diff --check
```

- [ ] **Step 6: Review and commit**

確認single authority、baseline metadata、links與無current-state contradiction。Commit：

```bash
git add docs/ tools/ci/test_environment_workflow_matrix_contract.py tools/ci/test_ios_workflow_contract.py
git commit -m "docs(ci): 說明變更感知執行策略"
```

---

## Task 6 — Full Regression and Remote Acceptance

**Files:**
- Create or Modify: `docs/audits/change_aware_ci_remote_validation.md`
- Modify: implementation plan checkboxes and review evidence as needed。

**Interfaces:**
- Validates local and GitHub-hosted behavior after Tasks 1–5。

- [ ] **Step 1: Run complete local contracts**

```bash
python3 -m unittest discover -s tools -p 'test_*.py'
dart run melos run docs_check
dart run melos run analyze
dart run melos exec -- flutter test
bash tools/ci/verify_generated.sh
find tools -type f -name '*.sh' -print0 | xargs -0 -n1 bash -n
git diff --check
```

Expected: all PASS on clean working tree where required。

- [ ] **Step 2: Simulate change classes locally**

建立temporary commits或test fixtures，證明：

```txt
docs-only → full_ci=false, android_build=false, ios_build=false
Dart source → full_ci=true, android_build=true, ios_build=true
Android native only → full_ci=true, android_build=true, ios_build=false
iOS native only → full_ci=true, android_build=false, ios_build=true
VERSION → all true
unknown path → all true
```

- [ ] **Step 3: Perform remote docs-only acceptance**

Push一個只改managed Markdown evidence的commit。確認：

- `CI / Quality`、`CI / Generated Consistency`、`CI / Tests`三個穩定job均成功；後兩者走no-op而非skipped。
- Android build jobs skipped，Android classification／summary成功。
- `iOS / Simulator Build`以Ubuntu runner執行同名no-op並成功；Production Release job skipped。
- macOS runner未啟動。
- Android／iOS artifacts未建立。

- [ ] **Step 4: Perform remote full-matrix acceptance**

使用`workflow_dispatch`執行完整矩陣，確認CI、Android development／production與iOS development／production全部成功並上傳預期artifacts。

- [ ] **Step 5: Record exact evidence**

在remote validation文件記錄run IDs、SHA、jobs、skipped jobs、runner OS、artifacts與disposition。Open P0／P1 without disposition必須為0。

- [ ] **Step 6: Final review and commit**

確認無required-check drift、無必要job誤跳過、無secret boundary改變。Commit：

```bash
git add docs/audits/change_aware_ci_remote_validation.md docs/superpowers/plans/2026-07-23-change-aware-ci-execution.md
git commit -m "docs(ci): 完成變更感知遠端驗證"
```

除非使用者另行明確授權，不得push後續closure commit。

## Self-Review

- Spec coverage：classifier、event range、docs-only、platform-specific、release override、required checks、documentation、rollback與remote evidence均有Task對應。
- Placeholder scan：沒有TBD、TODO、未定義步驟或「類似前述」引用。
- Type consistency：所有workflow都消費Task 1的五個固定boolean outputs；命名在各Task一致。
- Scope：只處理CI execution policy，不加入deployment、signing、Store或package-level dynamic matrix。

## Formal Review Gate

正式plan review與findings disposition見`docs/audits/change_aware_ci_plan_review.md`。只有該文件維持Open P0／P1 without disposition為0時，Task 1才可開始。
