---
document_type: planning-review
status: accepted
authoritative_for:
  - milestone-35-test-execution-cost-admission
  - milestone-35-pre-design-handoff
last_reviewed_baseline: 1.15.2
---

# Milestone 35 — Test Execution Cost & Change-Aware Validation Governance Corrective Admission Audit

## Purpose

本文件保存2026-08-09在Template Baseline 1.15.2完成的read-only測試成本與治理結構審查，作為下一個conversation開始Requirement Decision／Design前的current admission authority。

本階段尚未建立Design Spec、Implementation Plan、worktree或implementation。不得把本Audit直接當成已核准solution。

## Audit Question

使用者觀察到：即使只是小型需求新增或修改，Agent仍常花大量時間反覆執行全量測試，長期可能形成「測試地獄」。本Audit要確認問題是否真的存在，以及成本主要來自測試數量、Clean Architecture、雙層Task治理、CI routing或Agent執行習慣中的哪一層。

## Measured Current Baseline

Milestone 30 / Template Baseline 1.12.0封存基準：

```txt
Test files:   136
Test LOC:     22,943
Static cases: 769
All Flutter package tests: 21.81s / 19.11s
```

2026-08-09在published main / Template Baseline 1.15.2 fresh read-only盤點：

```txt
Test files:   163
Test LOC:     27,781
Static cases: 961

dart run melos exec -- flutter test
→ 34.42s / PASS

flutter test test/features/shell/presentation/pages/shell_scaffold_test.dart
→ 14.02s / 6 cases / PASS
```

相對Milestone 30增加27 files、4,838 LOC、192 cases。新增owners主要來自Pencil visual/runtime/architecture、API/Auth boundary、CI local artifact storage、Skill policy與visual authority contracts；目前沒有證據支持因數量增加就直接刪除這些tests。

## Confirmed Findings

### F-35-0-01 — Change classifier粒度過粗

Severity：P1。

Current `tools/ci/change_classifier.py` fresh probe：

```txt
docs/foo.md
→ docs_only=true / full_ci=false

apps/flutter_architecture/lib/features/profile/...
→ full_ci=true / android_build=true / ios_build=true

packages/core/lib/...
→ full_ci=true / android_build=true / ios_build=true

tools/docs/check_docs.py
→ full_ci=true

apps/flutter_architecture/test/features/profile/...
→ full_ci=true
```

Current classifier主要區分documentation-only與其他source/tooling，沒有把一般feature/package變更細分成focused／affected package／affected app boundaries。普通App `lib/`與package source還會直接升級Android＋iOS build flags。

Disposition：Confirmed corrective target；Design前不得直接修改classifier。

### F-35-0-02 — Testing tier inventory implementation drift

Severity：P1。

`docs/guides/testing_governance.md`定義Tier 1 quick unit／Python／docs／inventory、Tier 2 package／feature Flutter regression、Tier 3 generated／schema／migration、Tier 4 native、Tier 5 device／remote／post-release。

但current dynamic inventory對163個test files分類為：

```txt
Tier 1: 157
Tier 4:   6
```

也就是96%以上tests被歸為Tier 1。`tools/testing/inventory.py`對大多數current Flutter tests直接輸出Tier 1，與governance taxonomy不一致，execution tier已失去足夠routing價值。

Disposition：Confirmed corrective target；Design需重新定義machine-readable tier ownership與routing。

### F-35-0-03 — Human/Agent guides存在unconditional full-validation wording

Severity：P1。

中央治理實際規則：

```txt
L0 → focused
L1 → affected
L2 → feature / integration
L3 → affected workspace
L4 → full
L5 → full + compatibility / platform
```

`two-layer-task-governance.md`亦明文指出Level 2 full workspace regression是否需要應依受影響boundary決定。

但`AGENTS.md` commit checklist與`docs/guides/how-to-add-feature.md`一般Feature流程直接列出`dart run melos exec -- flutter test`，容易讓Agent把commit前必要檢查保守放大成每個小Task都跑full workspace tests。

Disposition：Confirmed governance wording drift；下一Design需決定唯一validation-selection authority與Guide wording。

### F-35-0-04 — 雙層Task治理是成本放大器，不是root cause

Severity：P1 architectural/governance interpretation。

雙層Task governance要求focused review、re-review、whole-Task review與required validation，但沒有要求所有層級都跑full regression。若`required validation`被錯誤解析為full workspace，則同一錯誤selection會在RED／GREEN／review／re-review／commit／holistic／post-release多次被重跑，形成乘數效應。

Disposition：Keep two-layer governance；Corrective target是validation selection與escalation rule，不是移除Task governance。

### F-35-0-05 — Clean Architecture增加test surface，但不是主要root cause

Severity：P2。

Clean Architecture自然形成DAO／Repository／UseCase／Bloc／Widget／DI boundary等多owner tests；跨層不等於duplicate，每層應擁有不同failure source。目前沒有證據支持因架構分層就大量刪除tests。

Disposition：No architecture rollback；保留coverage-first原則。

### F-35-0-06 — Testing Governance與inventory已stale

Severity：P2。

`docs/guides/testing_governance.md`仍為`last_reviewed_baseline: 1.12.0`，tracked Milestone 30 inventory仍是136 files／22,943 LOC／769 cases；current repository已是163／27,781／961。

Disposition：下一階段需重新建立current execution-cost baseline與tier ownership，但不得在Design前直接覆寫Milestone 30 historical evidence。

## Root-cause Disposition

```txt
validation-selection / classifier granularity drift
        +
testing-tier machine model drift
        +
human/agent guide wording drift
        ↓
over-validation
        ×
two-layer Task repeated verification points
        ↓
high perceived implementation latency / test-hell risk
```

Clean Architecture與test-suite成長是成本背景，但不是主要root cause。

## Corrective Direction Guardrails

- 不以降低coverage作為第一解。
- 不因test file大或case多就直接刪除。
- 不移除雙層Task治理。
- 不降低unknown path／invalid range／classifier failure的fail-safe保護。
- 不把full regression改成永遠不跑的nightly-only shortcut。
- 目標是建立「最小充分驗證」：focused → affected → boundary/workspace → full → release。
- Validation selection應盡量machine-readable／deterministic，不能主要依Agent主觀猜測。
- Full escalation必須有明確change classes與authority owners。
- 應量測corrective前後的命令次數、總wall-clock與coverage boundary，而不只比較test count。

## Pre-Design Handoff

下一個conversation必須先重新讀current authority並由`governing-template-development`正式產生Requirement Decision；本Audit建議初步classification為cross-cutting workflow / CI / testing governance corrective，至少Level 3候選，最終Level由fresh Requirement Decision決定。

建議下一階段名稱：

```txt
Milestone 35 — Test Execution Cost & Change-Aware Validation Governance Corrective
```

下一步固定為：

```txt
fresh read-only admission
→ Requirement Decision
→ Design Spec
→ Design雙層Task review
→ 使用者核准
→ Implementation Plan
→ Plan雙層Task review
→ 使用者核准
→ managed worktree / implementation
```

Design／Plan／implementation尚未開始。
