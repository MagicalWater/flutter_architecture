---
document_type: planning-review
status: completed
authoritative_for:
  - ci-artifact-storage-cutover-candidate-handoff
last_reviewed_baseline: 1.13.0
---

# CI產物本機化與GitHub儲存空間切換 Candidate Review and Handoff

## Purpose

本文件保存Proposed Milestone 32在進入新對話前的候選問題、外部runtime盤點、scope邊界與handoff狀態。

它不是Design Spec、Implementation Plan、active Milestone或implementation approval。新對話仍必須先使用`governing-template-development`完成fresh Requirement Decision與repository只讀審查。

## Repository closure state before this candidate

```txt
Template Baseline: 1.13.0
Current active milestone: None
Latest completed initiative: AI Agent日常使用指南與repository-local Skills治理收尾
Pre-handoff main/origin SHA: b33474b99f24884a533524ee623d6844832c8a25
Pre-handoff working tree: clean
```

上一階段已完成：

- `adopting-template-product-identity` behavioral approval closure。
- 四個repository-local Skills繁體中文化、Level 3 governance recovery與mechanical language checker。
- `docs/guides/agent_assisted_development_quick_start.md`與其remote clean-checkout closure。
- `main`與`origin/main`同步，沒有active Milestone或未提交implementation。

## Confirmed current problem

使用者的GitHub私有repository Actions分鐘與storage均已達限制。Repository目前已具備三種execution mode，但execution ownership與artifact storage ownership尚未完全切開：

```txt
manual-local
→ GitHub execution jobs skip；本機執行repository-owned入口

self-hosted
→ 不消耗GitHub-hosted runner分鐘
→ 但workflow中的upload-artifact仍可能占用GitHub Actions storage

github-hosted
→ 消耗GitHub-hosted runner分鐘，並可能使用GitHub cache／artifact storage
```

2026-07-30透過GitHub CLI取得的候選前快照：

```txt
CI_EXECUTION_MODE = self-hosted

Artifacts
  count = 110
  bytes = 7,835,943,504
  approximate size = 7.30 GiB

Caches
  count = 15
  bytes = 10,211,585,781
  approximate size = 9.51 GiB
```

大型storage來源包含多筆Android development APK、Android production verification APK、iOS development／production `.app`，以及單筆約808 MB的Observability iOS evidence。

這些數字會隨GitHub retention、expiration與人工操作變動。新階段開始時必須fresh re-query artifact／cache inventory，不能直接把此快照當作當下數字。

## Candidate classification

候選方向：

```txt
Proposed Milestone 32
CI產物本機化與GitHub儲存空間切換
```

初步風險訊號支持Level 4候選：

- 會修改repository-wide CI workflow與artifact evidence ownership。
- 涉及manual-local、self-hosted、github-hosted三種execution mode的一致語意。
- 會影響Android、iOS、Observability、failure diagnostics與cleanup。
- 需要retention、disk safety、rollback、remote status與operator procedure。
- 最後包含不可逆的GitHub artifact／cache批量刪除。

正式Level仍由新對話的Requirement Decision擁有，不得因本文件先寫Level 4候選就跳過分類。

## Tentative scope for Design discussion

- 盤點四份workflows、local CI entrypoints、upload／cache actions與artifact consumers。
- 定義本機artifact root、SHA identity、metadata schema與驗證摘要。
- 定義一般成功、失敗、Observability與release evidence的retention及容量上限。
- Self-hosted模式停止上傳大型GitHub artifacts；GitHub job只保存必要的summary與狀態。
- Manual-local與self-hosted共用repository-owned build／test入口，避免平行實作。
- 保留`github-hosted`作為人工、偶發、乾淨第三方runner驗證模式。
- 建立cleanup工具、dry-run、deletion manifest與disk safety。
- 完成本機／self-hosted runtime acceptance後，才清理既有GitHub artifacts與caches。

## Decisions that are intentionally not made yet

下列均留給Design，不得由handoff文件直接拍板：

1. `CI_EXECUTION_MODE`長期預設是否改為`manual-local`。
2. 本機artifact root是否使用`/Users/water/Developer/ci-artifacts/flutter_architecture/`。
3. 保留天數、保留成功commit數、最大容量與cleanup優先順序。
4. Self-hosted workflow是否完全禁止任何`upload-artifact`，或只允許極小文字evidence。
5. GitHub-hosted手動run是否保留cache／artifact upload。
6. Required checks在PR、trusted main與manual-local情境的正式政策。
7. Observability secrets、symbol upload、dSYM與controlled acceptance evidence如何在本機安全保存。

## Hard stops

在Design、Plan與runtime acceptance完成前：

- 不得批量刪除110筆GitHub artifacts或15筆caches。
- 不得移除GitHub workflows或`github-hosted`選項。
- 不得將secrets、keystore或private key寫入repository或artifact metadata。
- 不得把self-hosted run成功冒充為GitHub-hosted相容性證據。
- 不得把本機檔案路徑冒充成其他協作者可直接下載的遠端artifact。
- 不得建立R2、S3、NAS等額外服務，除非Design證明本機方案不足。

## Candidate-level task sketch

僅供Design拆分參考，不是accepted Implementation Plan：

```txt
1. Current CI／Storage Fresh Inventory
2. Local Artifact Ownership and Metadata Design
3. Workflow Upload／Cache Gating
4. Repository-owned Local Artifact Writer
5. Retention／Cleanup／Disk Safety
6. CI Contract Tests
7. Operator Documentation
8. Manual-local／Self-hosted Runtime Acceptance
9. GitHub Artifact／Cache Cleanup Manifest and Execution
10. Holistic Final Review and Closure
```

## Cross-conversation entry requirements

新對話開始後，先只讀核對：

- `AGENTS.md`
- `VERSION`
- `docs/README.md`
- `docs/project_context.md`
- `docs/roadmap.md`
- `docs/roadmap/active.md`
- `docs/roadmap/candidates.md`
- 本文件
- `docs/guides/ci_cd_operations.md`
- ADR-023與Milestone 27 self-hosted CI相關Design／Plan／runtime evidence
- `.github/workflows/ci.yml`
- `.github/workflows/android.yml`
- `.github/workflows/ios.yml`
- `.github/workflows/observability-acceptance.yml`
- `tools/ci/run_local_ci.sh`

接著fresh核對Git、`CI_EXECUTION_MODE`、GitHub artifacts、GitHub caches與self-hosted runner狀態。在Requirement Decision接受與Design建立前，不得修改workflow、建立Milestone implementation branch或刪除storage。

## Findings and disposition

### F1 — 下一階段只存在聊天中

- Severity：P1。
- Finding：Roadmap沒有CI artifact storage cutover candidate，新對話會依賴口頭摘要。
- Fix：新增`docs/roadmap/candidates.md`候選與本handoff。

### F2 — CI Guide未明確說明self-hosted仍可能使用GitHub storage

- Severity：P1。
- Fix：在`docs/guides/ci_cd_operations.md`新增current quota constraint與candidate route。

### F3 — 外部storage數字會變動

- Severity：P2。
- Disposition：保留查詢日期與exact bytes，並要求新階段fresh re-query。

### F4 — Cleanup具有不可逆風險

- Severity：P1。
- Disposition：將cleanup放在runtime acceptance與approved deletion manifest之後，候選階段禁止執行。

### F5 — Roadmap不應複製可變runtime數字

- Severity：P2。
- Finding：第一版candidate同時保存精確artifact／cache數字，會與本planning review形成重複evidence。
- Fix：Roadmap只保留storage壓力摘要與本文件route；exact count、bytes與查詢日期只由本文件擁有。
- Fresh re-review：Candidate仍能說明問題與價值，但不再成為第二份runtime inventory。

## Current disposition

```txt
Previous initiative closure: Passed
Active Milestone: None
Candidate documentation: Added
Design Spec: Not created
Implementation Plan: Not created
Workflow mutation: Not started
GitHub storage cleanup: Not started
Push／remote clean checkout for candidate content: Passed
Cross-conversation readiness: Passed
Formal candidate handoff closure: Completed
```

## Remote closure evidence

```txt
Validated origin/main SHA: 020bbd4d4ca6a86ff52c5cd28071aec74fc9625e
Candidate／Guide／handoff contract scan: passed
Documentation checker tests: 19 passed
docs_check: passed
git diff --check: passed
Remote clean checkout: clean
```

本文件的completion metadata由後續closure commit保存；新對話應以當下`main`／`origin/main`與本文件內容為準，不需依賴本對話的隱藏或口頭上下文。
