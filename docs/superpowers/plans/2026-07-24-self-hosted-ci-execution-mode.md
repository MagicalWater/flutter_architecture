---
document_type: implementation-plan
status: accepted
authoritative_for:
  - milestone-27-task-27-7-self-hosted-ci-implementation-plan
last_reviewed_baseline: 1.8.0
---

# Self-hosted CI Execution Mode Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 建立`manual-local`、`self-hosted`、`github-hosted`三種CI執行模式，讓private repository在不消耗GitHub-hosted分鐘時，仍可由GitHub自動派送可信`main`與manual jobs到目前Mac執行並回報checks。

**Architecture:** 四份現有workflow保留穩定名稱與既有suite責任，透過一致的mode expression決定job是否建立，以及使用專用Mac self-hosted labels或原本GitHub-hosted runner。所有build與test仍呼叫repository-owned scripts；新增static contracts與secret cleanup腳本，避免routing邏輯與持久workspace造成安全漂移。

**Tech Stack:** GitHub Actions YAML、GitHub self-hosted Actions Runner、Bash、Python `unittest`、Flutter／Melos、GitHub CLI、macOS `launchd` service。

---

## File map

### 建立

- `tools/ci/ci_execution_mode_contract.py`：集中合法mode、manual override與event policy的純Python contract，供tests與人工診斷使用。
- `tools/ci/cleanup_ci_secrets.sh`：移除job materialized Firebase／service-account檔案並驗證清理結果。
- `tools/ci/test_ci_secret_cleanup_contract.py`：secret cleanup的TDD contract。
- `docs/audits/milestone_27/27-7_self_hosted_ci_runtime_evidence.md`：runner註冊、main push、manual dispatch、PR skip、offline queue與mode切換證據。
- `docs/audits/milestone_27/27-7_self_hosted_ci_implementation_review.md`：Task 27-7 focused與holistic implementation review。

### 修改

- `.github/workflows/ci.yml`
- `.github/workflows/android.yml`
- `.github/workflows/ios.yml`
- `.github/workflows/observability-acceptance.yml`
- `tools/ci/test_ci_execution_mode_contract.py`
- `tools/ci/test_environment_workflow_matrix_contract.py`
- `tools/ci/test_ios_workflow_contract.py`
- `tools/ci/test_observability_acceptance_workflow.py`
- `tools/ci/run_local_ci.sh`
- `docs/adr/adr-023-repository-ci-quality-gates-android-verification-artifact.md`
- `docs/guides/ci_cd_operations.md`
- `docs/roadmap/active.md`
- `docs/audits/README.md`
- `docs/superpowers/README.md`
- `docs/audits/milestone_27/27-6_ci_secrets_remote_acceptance_review.md`

---

### Task 1: Task activation與ADR authority同步

**Files:**
- Modify: `docs/adr/adr-023-repository-ci-quality-gates-android-verification-artifact.md`
- Modify: `docs/roadmap/active.md`
- Modify: `docs/superpowers/README.md`

- [ ] **Step 1: 先把active roadmap切換到Task 27-7**

`docs/roadmap/active.md`必須明確記錄：

```txt
Current Task: Task 27-7 — CI Execution Mode and Self-hosted Runner Foundation
Task 27-6: implementation與本機runtime evidence已存在，但iOS Firebase Console symbolication closure仍待確認
```

不得繼續聲稱Firebase secrets尚未配置，也不得提前寫Task 27-7已完成。

- [ ] **Step 2: 更新ADR-023 durable architecture contract**

在任何workflow實作前，ADR-023先加入已核准的：

```txt
manual-local / self-hosted / github-hosted
repository-default manual sentinel
trusted main push / workflow_dispatch boundary
PR不得進入water帳號self-hosted runner
unknown mode fail closed
不得自動fallback產生GitHub-hosted費用
repository-owned scripts為三執行端共用實作
```

ADR不得包含registration token、runner安裝版本、service path或當前run ID。

- [ ] **Step 3: 更新design／plan routing index**

`docs/superpowers/README.md`只加入Plan routing摘要，不複製完整contract。

- [ ] **Step 4: 執行文件治理檢查**

```bash
dart run melos run docs_check
git diff --check
```

Expected: PASS。

- [ ] **Step 5: Task 1 focused與whole-task review**

確認ADR擁有durable architecture、roadmap只擁有current state、Spec／Plan仍只保存設計與執行順序，scope沒有重疊。

- [ ] **Step 6: Task 1 commit gate**

Review通過後才提交：

```bash
git add docs/adr/adr-023-repository-ci-quality-gates-android-verification-artifact.md \
  docs/roadmap/active.md docs/superpowers/README.md
git commit -m "docs(ci): 啟動self-hosted CI Task"
```

---

### Task 2: Execution mode contract與命名遷移

**Files:**
- Create: `tools/ci/ci_execution_mode_contract.py`
- Modify: `tools/ci/test_ci_execution_mode_contract.py`
- Modify: `tools/ci/run_local_ci.sh`

- [ ] **Step 1: 先寫失敗測試，固定三種合法mode與舊`local`拒絕規則**

在`tools/ci/test_ci_execution_mode_contract.py`加入：

```python
from tools.ci.ci_execution_mode_contract import resolve_execution_mode


def test_accepts_only_three_explicit_modes() -> None:
    for value in ("manual-local", "self-hosted", "github-hosted"):
        assert resolve_execution_mode(value, None) == value


def test_rejects_legacy_local_and_unknown_values() -> None:
    for value in ("local", "", "unexpected"):
        with self.assertRaises(ValueError):
            resolve_execution_mode(value, None)


def test_manual_override_wins_without_mutating_repository_value() -> None:
    assert resolve_execution_mode("manual-local", "self-hosted") == "self-hosted"


def test_repository_default_uses_repository_value() -> None:
    assert resolve_execution_mode("self-hosted", "repository-default") == "self-hosted"
```

- [ ] **Step 2: 執行測試確認因module不存在而失敗**

Run:

```bash
python3 -m unittest tools.ci.test_ci_execution_mode_contract -v
```

Expected: FAIL，指出`tools.ci.ci_execution_mode_contract`不存在。

- [ ] **Step 3: 建立最小resolver**

`tools/ci/ci_execution_mode_contract.py`：

```python
VALID_EXECUTION_MODES = frozenset({
    "manual-local",
    "self-hosted",
    "github-hosted",
})


def resolve_execution_mode(repository_value: str | None, override: str | None) -> str:
    candidate = repository_value if override in (None, "repository-default") else override
    candidate = candidate or ""
    if candidate not in VALID_EXECUTION_MODES:
        raise ValueError(f"Unsupported CI execution mode: {candidate!r}")
    return candidate
```

此module是repository-owned validation contract，不是GitHub pre-run runtime resolver。Workflow在runner建立前無法執行Python，因此static tests必須解析四份workflow，確認其中mode literals與`VALID_EXECUTION_MODES`完全一致，避免形成兩套無人檢查的來源。

- [ ] **Step 4: 更新本機入口help，使用`manual-local`正式名稱**

`tools/ci/run_local_ci.sh`的usage與文件輸出不得再把`local`當正式mode；suite名稱維持`quality|android|ios|observability|all`。

- [ ] **Step 5: 執行focused tests**

Run:

```bash
python3 -m unittest \
  tools.ci.test_ci_execution_mode_contract \
  tools.ci.test_local_build_commands -v
```

Expected: PASS。

- [ ] **Step 6: Task 2 focused與whole-task review**

確認resolver不讀GitHub環境、不修改repository variable、未知值fail closed，並記錄在Task 27-7 implementation review草稿。

- [ ] **Step 7: Task 2 commit gate**

Review與focused tests通過後提交本Task，不夾帶workflow routing實作。

---

### Task 3: Workflow routing與trusted event boundary

**Files:**
- Modify: `.github/workflows/ci.yml`
- Modify: `.github/workflows/android.yml`
- Modify: `.github/workflows/ios.yml`
- Modify: `.github/workflows/observability-acceptance.yml`
- Modify: `tools/ci/test_ci_execution_mode_contract.py`
- Modify: `tools/ci/test_environment_workflow_matrix_contract.py`
- Modify: `tools/ci/test_ios_workflow_contract.py`
- Modify: `tools/ci/test_observability_acceptance_workflow.py`

- [ ] **Step 1: 先擴充static tests，要求manual dispatch select input**

四份workflow都必須含：

```yaml
workflow_dispatch:
  inputs:
    execution_mode:
      type: choice
      required: true
      default: repository-default
      options:
        - repository-default
        - manual-local
        - self-hosted
        - github-hosted
```

Tests需確認不再存在`run_hosted` boolean作為主要mode contract，也不再接受`CI_EXECUTION_MODE=local`。`repository-default`只允許存在於manual input與resolver override，不得被列入`VALID_EXECUTION_MODES`。

- [ ] **Step 2: 寫失敗測試，固定self-hosted labels**

Expected labels：

```txt
self-hosted
macOS
ARM64
flutter-architecture
trusted-main
```

Tests需拒絕只有`runs-on: self-hosted`的job。

- [ ] **Step 3: 寫失敗測試，固定event policy**

Static contract必須驗證：

```txt
self-hosted + pull_request      => job-level if false
self-hosted + push main         => allowed
self-hosted + workflow_dispatch => allowed
observability + push main       => denied
observability + manual explicit remote_acceptance => allowed
```

- [ ] **Step 4: 執行測試確認現有workflow不符合新contract**

Run:

```bash
python3 -m unittest discover -s tools/ci -p 'test_*workflow*.py' -v
```

Expected: FAIL，至少指出舊`run_hosted`、舊`local`與缺少self-hosted labels。

- [ ] **Step 5: 實作一致的effective mode expression**

每份workflow使用相同語意：manual input為`repository-default`時讀`vars.CI_EXECUTION_MODE`，否則使用manual choice。Job-level `if`必須先限制event，再限制mode；`manual-local`與unknown mode都不建立execution job。

Self-hosted允許條件必須等價於：

```yaml
if: >-
  (github.event_name == 'push' &&
   github.ref == 'refs/heads/main' &&
   vars.CI_EXECUTION_MODE == 'self-hosted') ||
  (github.event_name == 'workflow_dispatch' &&
   (inputs.execution_mode == 'self-hosted' ||
    (inputs.execution_mode == 'repository-default' &&
     vars.CI_EXECUTION_MODE == 'self-hosted')))
```

GitHub-hosted允許條件使用同一結構但比對`github-hosted`；PR只允許`github-hosted`，不得在self-hosted分支成立。

一般Ubuntu job的runner expression必須等價於：

```yaml
runs-on: >-
  ${{
    ((github.event_name == 'push' && vars.CI_EXECUTION_MODE == 'self-hosted') ||
     (github.event_name == 'workflow_dispatch' &&
      (inputs.execution_mode == 'self-hosted' ||
       (inputs.execution_mode == 'repository-default' &&
        vars.CI_EXECUTION_MODE == 'self-hosted'))))
    && fromJSON('["self-hosted","macOS","ARM64","flutter-architecture","trusted-main"]')
    || 'ubuntu-24.04'
  }}
```

iOS GitHub-hosted分支將fallback runner改為`macos-15`。實作時若GitHub expression parser不接受折行形式，可保持完全相同語意改為單行；不得改變labels或fallback。

Self-hosted job的`runs-on`使用完整label array；GitHub-hosted維持原有Ubuntu／macOS runner。不得新增一個為了顯示錯誤而消耗hosted分鐘的bootstrap job。

- [ ] **Step 6: 保留stable job names與既有change classifier語意**

不得更名：

```txt
CI / Quality
CI / Generated Consistency
CI / Tests
Android / Development Debug APK
Android / Release APK
iOS / Simulator Build
iOS / Production Release Build
```

Self-hosted模式下，這些jobs在同一Mac排隊執行；GitHub-hosted模式維持現有change-aware矩陣。

- [ ] **Step 7: 修正concurrency**

Quality與一般build可取消舊main push；Observability不得`cancel-in-progress: true`。Static tests需固定此差異。

- [ ] **Step 8: 執行workflow contract與actionlint**

Run:

```bash
python3 -m unittest discover -s tools/ci -p 'test_*.py' -v
actionlint
```

Expected: 全部PASS；只允許既有且已書面接受的非功能性ShellCheck warning。

- [ ] **Step 9: Task 3 focused與whole-workflow review**

逐份檢查PR、main push、manual dispatch、三種mode、unknown mode與Observability gate，不能只看tests通過。

- [ ] **Step 10: Task 3 commit gate**

Review、workflow contracts與`actionlint`通過後提交四份workflow與對應tests。

---

### Task 4: Persistent workspace與secret cleanup

**Files:**
- Create: `tools/ci/cleanup_ci_secrets.sh`
- Create: `tools/ci/test_ci_secret_cleanup_contract.py`
- Modify: `.github/workflows/observability-acceptance.yml`

- [ ] **Step 1: 寫失敗測試建立模擬secret檔案**

測試在temporary directory建立：

```txt
firebase-service-account.json
google-services.json
GoogleService-Info.plist
```

呼叫cleanup後斷言全部不存在；對不存在檔案重跑仍成功。

- [ ] **Step 2: 執行測試確認cleanup script不存在**

Run:

```bash
python3 -m unittest tools.ci.test_ci_secret_cleanup_contract -v
```

Expected: FAIL。

- [ ] **Step 3: 實作idempotent cleanup script**

Script接受一個job root參數，只允許清理該root內白名單檔名；拒絕空字串、`/`與home root。刪除後逐檔驗證不存在，否則exit non-zero。

- [ ] **Step 4: Observability加入`if: always()` cleanup step**

Android與iOS symbols jobs都必須在最後執行cleanup，包含build或upload失敗情境。Cleanup不得讀取或刪除日常checkout外的其他檔案。

- [ ] **Step 5: 執行focused tests與shell syntax**

Run:

```bash
python3 -m unittest tools.ci.test_ci_secret_cleanup_contract -v
bash -n tools/ci/cleanup_ci_secrets.sh
```

Expected: PASS。

- [ ] **Step 6: Task 4 focused與whole-task security review**

確認所有materialized secrets都位於`$RUNNER_TEMP`或job workspace，cleanup scope沒有path traversal，失敗時不會把secret內容輸出到log。

- [ ] **Step 7: Task 4 commit gate**

Security review與tests通過後提交cleanup script、tests與workflow cleanup wiring。

---

### Task 5: Mac repository-scoped runner安裝與service

**Files:**
- No repository source changes required before runtime registration.
- Evidence target: `docs/audits/milestone_27/27-7_self_hosted_ci_runtime_evidence.md`

- [ ] **Step 1: 在GitHub repository Settings取得當下官方macOS ARM64安裝指令**

不得把registration token寫進文件、shell history範例或commit。Token只在GitHub產生的有效期內使用。

- [ ] **Step 2: 建立專用runner目錄**

```bash
mkdir -p /Users/water/actions-runner/flutter-architecture
cd /Users/water/actions-runner/flutter-architecture
```

不得安裝在project checkout或其他runner的`_work`內。

- [ ] **Step 3: 驗證下載檔checksum後解壓**

使用GitHub安裝頁當下提供的runner版本與checksum；checksum不一致立即停止。

- [ ] **Step 4: 註冊repository-scoped runner與custom labels**

Runner name固定可辨識名稱，例如：

```txt
water-mac-flutter-architecture
```

Custom labels至少：

```txt
flutter-architecture,trusted-main
```

Default labels應顯示`self-hosted`、`macOS`、`ARM64`。

- [ ] **Step 5: 安裝並啟動macOS service**

使用runner package內官方`svc.sh install`與`svc.sh start`，再確認service status為running。若官方當下命令不同，以GitHub頁面為準並在runtime evidence記錄實際命令類型，不記錄token。

- [ ] **Step 6: 以GitHub API確認runner online與labels**

Run:

```bash
gh api repos/MagicalWater/flutter_architecture/actions/runners
```

Expected: 指定runner`status=online`、`busy=false`，labels完整。

- [ ] **Step 7: Task 5 focused與whole-task operational review**

確認runner使用`water`帳號、workspace為runner `_work`、沒有指向日常checkout、service重啟後可恢復online。

- [ ] **Step 8: Task 5 evidence commit gate**

Runner token不得進入Git。只在runtime evidence加入不含secret的runner name、labels、status與service驗證結果，review通過後提交evidence。

---

### Task 6: Runtime routing acceptance

**Files:**
- Create/Update: `docs/audits/milestone_27/27-7_self_hosted_ci_runtime_evidence.md`

- [ ] **Step 1: 先將repository variable設為`manual-local`確認零runner行為**

```bash
gh variable set CI_EXECUTION_MODE --body manual-local
```

Manual dispatch不提供override，Expected: execution jobs全部skipped，runner保持idle。

- [ ] **Step 2: Manual self-hosted smoke**

對`CI` workflow手動選`execution_mode=self-hosted`。Expected：job派到指定Mac、checkout精確SHA、checks回傳成功。

- [ ] **Step 3: Main push self-hosted acceptance**

```bash
gh variable set CI_EXECUTION_MODE --body self-hosted
```

推送一個受控文件／contract commit後確認main push自動派送；若change classifier判定某平台需build，對應job在同一Mac排隊而非平行搶占。

- [ ] **Step 4: PR denial acceptance**

建立同repository測試PR，Expected：沒有任何job派到Mac；checks顯示skipped，review evidence明確記錄`skipped ≠ verified`。完成後關閉測試PR。

- [ ] **Step 5: Runner offline fail-safe**

暫停service後手動觸發self-hosted smoke，Expected：job queued，不自動轉GitHub-hosted。確認後取消job並恢復service；不需真的等待24小時。

- [ ] **Step 6: GitHub-hosted mode只做static驗證**

本月額度已滿，不實際啟動付費job。只驗證manual select、runner expression與contract tests；不得為了驗收耗費額外分鐘。

- [ ] **Step 7: Observability manual gate**

確認main push不會自動執行Observability symbols jobs。只有manual `execution_mode=self-hosted`加`remote_acceptance=true`才允許；本Task若不需要再次污染Firebase事件，可只做secret-safe dry gate，真正runtime沿用Task 27-6既有本機證據。

- [ ] **Step 8: Task 6 focused與whole-task runtime review**

核對GitHub run IDs、commit SHA、runner name、labels、event、mode與結果；不得只以console截圖代替文字證據。

- [ ] **Step 9: Task 6 evidence commit gate**

Runtime findings全部closed後提交更新的runtime evidence；測試PR與queued smoke必須已清理或取消。

---

### Task 7: Operations、current authority與Task 27-6同步

**Files:**
- Modify: `docs/guides/ci_cd_operations.md`
- Modify: `docs/roadmap/active.md`
- Modify: `docs/audits/milestone_27/27-6_ci_secrets_remote_acceptance_review.md`
- Modify: `docs/audits/README.md`
- Modify: `docs/superpowers/README.md`

- [ ] **Step 1: 更新operations guide**

文件化mode切換、manual override、runner service status、offline queue、24小時上限、PR skipped語意、secret cleanup、rollback與移除runner流程。

- [ ] **Step 2: 同步active roadmap closure狀態**

Task 27-7在implementation與runtime evidence通過前保持active；通過後更新為completed並將next action導回Task 27-6 console symbolication closure或Milestone 27 final review，不得仍寫「尚未配置Firebase secrets」。

- [ ] **Step 3: 補正Task 27-6 evidence**

記錄GitHub Environment已配置、Android ingestion／symbolication、iOS同build dSYM upload與HTTP 200，以及舊UUID無法由新build補救。仍未由Firebase Console人工確認的新iOS stack不得標成verified。

- [ ] **Step 4: 更新indexes，不複製完整findings**

`docs/audits/README.md`與`docs/superpowers/README.md`只新增一句routing摘要。

- [ ] **Step 5: 執行文件治理檢查**

Run:

```bash
dart run melos run docs_check
git diff --check
```

Expected: PASS。

- [ ] **Step 6: Task 7 focused與whole-task documentation review**

逐一檢查authority scope、status、current tense與Task 27-6／27-7責任，不能只依docs checker。

- [ ] **Step 7: Task 7 commit gate**

文件治理與semantic review通過後提交guide、roadmap、Task 27-6 evidence與indexes。

---

### Task 8: Full regression與Task 27-7 holistic closure

**Files:**
- Create/Update: `docs/audits/milestone_27/27-7_self_hosted_ci_implementation_review.md`
- Update: `docs/audits/milestone_27/27-7_self_hosted_ci_runtime_evidence.md`

- [ ] **Step 1: 執行完整static regression**

```bash
python3 -m unittest discover -s tools/ci -p 'test_*.py' -v
bash -n tools/ci/run_local_ci.sh
bash -n tools/ci/cleanup_ci_secrets.sh
actionlint
dart run melos run docs_check
git diff --check
```

Expected: 全部PASS。

- [ ] **Step 2: 執行repository quality suite**

```bash
bash tools/ci/run_local_ci.sh quality
```

Expected: dependency resolution、docs、contracts、analyze、generated consistency、Flutter tests與whitespace全部PASS。

- [ ] **Step 3: 視變更影響重跑Android／iOS代表build**

```bash
bash tools/ci/run_local_ci.sh android
bash tools/ci/run_local_ci.sh ios
```

Expected: development與production代表artifact建立成功。若只改workflow且先前同commit本機build證據仍有效，review必須明確說明是否重用；不得默認略過。

- [ ] **Step 4: Focused implementation review**

按Task 1～6逐項檢查source、tests、runtime與docs，列出findings severity與disposition。

- [ ] **Step 5: Whole-task holistic review**

重新檢查：

```txt
mode semantics
event security
runner routing
offline behavior
secret cleanup
concurrency
artifact cost
ADR ownership
roadmap truthfulness
Task 27-6 handoff
```

Open P0／P1必須為0才能通過。

- [ ] **Step 6: 驗證工作區與repository variable**

```bash
git status --short
gh variable get CI_EXECUTION_MODE
gh api repos/MagicalWater/flutter_architecture/actions/runners
```

Expected: 工作區只含預期closure變更；mode為`self-hosted`；runner online且labels正確。

- [ ] **Step 7: Commit與push closure**

只在review通過後提交；commit message使用繁體中文Conventional Commit。Push後確認新commit由self-hosted runner驗證，而不是GitHub-hosted分鐘。

---

## Plan completion gate

Implementation開始前，本Plan本身必須完成：

```txt
focused plan review
finding disposition
whole-plan holistic review
documentation governance check
status proposed → accepted
獨立commit
```

Plan通過不代表Task 27-7 implementation已完成。

