---
document_type: implementation-plan
status: accepted
authoritative_for:
  - public-repository-readiness-implementation-sequencing
last_reviewed_baseline: 1.17.0
---

# Public Repository Readiness — Security & Privacy Hardening Implementation Plan

## Purpose

依已接受的 Design，完成 repository 在轉為 Public 前必要的安全與隱私 hardening，同時避免破壞 historical audit traceability 或其他進行中的工作。

## Preconditions

- Requirement Decision：Accepted。
- Design Spec：Accepted。
- Managed worktree：`C:\Users\crazy\.devspace\worktrees\flutter_architecture-56ee2db1`。
- 不修改 source checkout 的其他未提交工作。
- 不執行 Git history rewrite。
- 不修改 GitHub repository visibility。

## Test Authoring Decision

- Disposition：`Required` for workflow trust-boundary regression；`Recommended` for ignore-policy contract if a stable machine-check owner exists。
- Primary owner：`tools/ci` repository security / workflow contract tests。
- Rationale：Public fork / PR 與 self-hosted / secret boundary 是 security-sensitive observable repository behavior，必須有 direct regression owner；純文件 path 泛化不新增測試。

## Task 1 — Secret-ignore policy hardening

### Scope

- 更新 root `.gitignore`，加入常見本機秘密與 provider config 防誤提交規則。
- 必須避免忽略 repository 需要追蹤的 example / fixture 檔案。
- 規則至少涵蓋：
  - `.env` / environment secret variants；
  - Android keystore；
  - Apple signing/private material；
  - private key / certificate material；
  - Firebase Android/iOS provider config；
  - service-account material。

### Validation

- focused ignore contract check；
- existing docs / repository checks selected by validation planner。

## Task 2 — Current reusable guide privacy normalization

### Scope

- 只檢查 current reusable guides / current authority 中可被使用者直接複製的 operator-specific absolute paths。
- 將不必要的 `/Users/water/...`、`C:\Users\crazy\...` 改為 `<user>`、環境變數或明確標示的 example path。
- Historical audits、runtime evidence、old accepted plans/specs 保留原樣，除非它們仍是 current reusable command authority。

### Validation

- docs_check；
- link / metadata consistency；
- diff review 確認沒有改寫 historical evidence。

## Task 3 — Public fork / PR trust-boundary regression

### Scope

- 建立或擴充 machine-readable workflow contract tests，直接驗證：
  - `pull_request` 不可選到 trusted self-hosted runner；
  - provider / Firebase secrets 只能在受限的 manual trusted path 讀取；
  - PR-safe jobs 不取得 privileged secret expressions；
  - `pull_request_target` 不得被新增為執行 untrusted checkout 的 privileged shortcut。
- 優先測 current workflow semantics，不把 YAML formatting 細節當作 contract。

### Validation

- RED evidence → implementation → GREEN；
- existing related CI workflow contract tests。

## Task 4 — Secret leakage and history readiness scan

### Scope

- Fresh scan current tracked tree：sensitive filenames、private-key headers、token patterns、provider configs。
- Fresh Git-history scan：相同高風險 patterns 與 historically tracked sensitive filenames。
- 所有命中必須人工 disposition：real secret / known test fixture / public identifier / false positive。
- 不在 review evidence 中回顯任何真 secret value。

### Validation

- current tree：no undisposed real credential findings；
- Git history：no undisposed real credential findings；
- `crazydennies@gmail.com` 明確列為 user-accepted public metadata，不視為 finding。

## Task 5 — Holistic public-readiness review

### Scope

- Cross-task consistency review。
- 確認 historical audit paths 未被不必要改寫。
- 確認 `.gitignore` 不造成 required tracked examples / test fixtures失效。
- 確認 Public PR 不會進 trusted self-hosted runner 或 privileged secret jobs。
- 執行 validation planner 指定的 minimum sufficient validation。
- 因本 initiative 為 security-sensitive public-readiness，另執行 targeted security contract suite 與 docs check；是否需要 full workspace regression 以 planner / Level 5 final gate為準。

## Task 6 — Integration and visibility handoff

### Scope

- 完成 final review evidence與 branch/worktree completion commit。
- 不在本 Task 自動切換 GitHub visibility。
- 提供 integration / push 狀態與「可以改 Public」或 remaining blocker 的明確結論。
- Repository visibility change 必須在 fresh GitHub settings check 後由使用者明確授權。

## Commit boundaries

預期至少拆分：

1. `chore(security): 強化公開倉庫秘密防誤提交規則`
2. `docs(security): 泛化公開文件中的本機操作路徑`
3. `test(ci): 鎖定公開 PR 與受信任 runner 安全邊界`
4. `docs(review): 完成公開倉庫安全 readiness 審查`

如實際 diff 足夠緊密，可合併 1＋2；不得把無關 Milestone 37 implementation 混入。

## Stop conditions

只在以下情況停止並回報使用者：

- 發現疑似真 credential / signing material；
- 發現 Public fork PR 可執行 trusted self-hosted code 或讀取 privileged secrets；
- 需要 rewrite Git history 才能消除不可接受資訊；
- 需要變更既有 accepted architecture / security contract；
- GitHub visibility 實際切換前。

一般 test failure、metadata drift、docs lint 或 implementation defect 直接修正並 fresh re-verify。
