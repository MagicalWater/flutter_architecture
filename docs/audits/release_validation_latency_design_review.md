---
document_type: final-review
status: accepted
authoritative_for:
  - release-validation-latency-design-review
last_reviewed_baseline: 1.25.1
---

# Release Validation Latency Corrective — Design Review

## Scope

Review proposed Design：

`docs/superpowers/specs/2026-08-19-release-validation-latency-design.md`

Fresh authority：Template Baseline `1.25.1` / `e756933e7912094ade2037719c7ff75dd67f11ce`。

本 review只判定 Design 是否足以進入使用者 approval gate；**不授權 Plan 或 implementation**。

## Evidence reviewed

- `tools/ci/validation_planner.py`
- `tools/ci/change_classifier.py`
- `.github/workflows/ci.yml`
- `.github/workflows/android.yml`
- `.github/workflows/ios.yml`
- 1.25.1 exact-candidate iOS workflow run `32222557269`
- ADR-023與current CI operations semantics

## Findings

### D1 — Latency root cause is correctly separated

**PASS。**

Android與iOS各自的兩個 build jobs已是 sibling jobs；不需要為「平台內parallel」重寫workflow DAG。真正可控的排程浪費是release operator把CI / Android / iOS evidence families依序等待。

### D2 — Fan-out preserves one selection authority

**PASS。**

Design中的orchestrator只consume planner payload、dispatch、wait與assert exact SHA，不重新classify paths、不擁有publication，因此沒有建立第二套release authority。

### D3 — Platform variant reduction is risk-based, not blanket deletion

**PASS。**

Design沒有把Development/Production或Simulator/Production視為等價。Shared native、dependency、platform-shared、invalid-range與直接修改platform workflow本體仍保留both variants。

### D4 — Validation-engine sentinel rule is bounded

**PASS。**

Planner本體變更在沒有native/workflow mutation時使用production sentinel驗證end-to-end platform routing；secondary variant selection由permanent workflow contracts擁有。若candidate同時修改Android/iOS workflow本體，仍升級both，避免以planner標籤遮蔽workflow-owning risk。

### D5 — Failure semantics remain fail closed

**PASS。**

Dispatch failure、workflow failure、head SHA mismatch、missing selected job均阻擋publication；invalid range仍保留full/generated/both platforms/both variants。

### D6 — Scope is not over-engineered

**PASS。**

第一版只需要bounded repository-owned CLI與planner outputs；不建立daemon、queue system、release service或新的classifier。Future self-hosted orchestration不在第一版預先抽象。

### D7 — Test governance remains bounded

**PASS。**

Critical release pipeline值得永久contract tests，但Design要求沿用既有owner並table-drive同類path permutations，不新增大型test project。

## Holistic result

**PASS — Design eligible for user approval.**

Open P0 = 0。

Open P1 = 0。

## Approval boundary

目前合法狀態：

```text
Requirement Decision: accepted for design work
Design: proposed
Design Review: PASS
Implementation Plan: not started
Implementation: forbidden until Design + Plan user approval
```

下一 gate：使用者核准 Design後，建立一份精簡 Implementation Plan；Plan review與使用者核准完成前不得修改planner/workflow production behavior。
