---
document_type: planning-review
status: accepted
authoritative_for:
  - milestone-45-design-and-plan-review
last_reviewed_baseline: 1.23.1
---

# Milestone 45 — Combined Design / Plan Review

## Review scope

本review同時審查：

- `45-r_requirement_decision.md`
- `2026-08-19-milestone-45-test-by-exception-governance-reset-design.md`
- `2026-08-19-milestone-45-test-by-exception-governance-reset.md`

目的刻意不是建立兩份平行Design Review與Plan Review，而是在current Level 4 approval gate下提供一份可追溯planning evidence，避免本Milestone還沒開始就再次製造governance inflation。

## Requirement fit

PASS。

Design直接處理使用者要求的三個核心轉向：

1. 永久tests從default-retain反轉為test-by-exception；
2. temporary test在GREEN後仍需Retention Decision，允許closure前主動刪除；
3. governance／validation／CI本身同步瘦身，而不是再增加一個test-selection framework。

沒有把80%～100% reduction誤寫成coverage quota；`>=80%`是本次complexity-correction acceptance，若critical-risk audit支持則繼續至90%+，且沒有minimum retained count。

## Stable authority fit

PASS with required implementation updates。

- Test lifecycle／retention可由ADR-029擴充，不需要先新增第三份testing ADR。
- CI／validation／same-SHA release evidence由ADR-023承接。
- Human operation由`testing_governance.md`與`development_workflow.md`同步。
- Central executable workflow仍由`governing-template-development` Skill擁有，但其Level／Task規則會被本Milestone有意簡化。

## Anti-inflation review

PASS。

Plan只有六個execution units，且明確禁止為每個deletion bucket建立formal audit。這與current Level 4要求的Design／Plan／holistic evidence相容，同時避免把179個test files變成179筆deletion bureaucracy。

Inventory採bucket disposition + critical keep matrix + before/after metrics；低價值protection退休時`replacement = NONE`。這是本Milestone能真正刪除80%+ portfolio的必要條件。

## Critical-risk protection review

PASS。

Design沒有以刪除比例要求移除security、credential migration、database migration／rollback、concurrency／ordering、destructive cleanup、secret leakage與critical platform contract。這些領域只移除duplicate/exhaustive matrices，保留最小direct owner。

## Validation / CI review

PASS as design direction。

以下current inflation points已被明確納入Unit 45-2：

- `VERSION` diff自動release-full；
- `workflow_dispatch`自動manual full/release；
- holistic／release／post-release對same SHA重複full source regression；
- ordinary main/PR path的platform／observability execution duplication。

Implementation必須以focused planner contracts證明critical fail-safe未被靜默移除；但不得為每個舊routing branch建立新的永久test。

## Findings

### F-45-P-01 — Requirement metadata type initially unsupported

Severity：P2。

Initial `docs_check`指出`requirement-decision`不是repository支援的`document_type`。已修正為既有Requirement artifacts使用的`planning-review`；不改Requirement semantics。

### F-45-P-02 — Roadmap index must reflect new active Milestone

Severity：P1。

`docs/roadmap/active.md`已切換M45，但root roadmap index仍是`Active Milestone: none`會形成current authority contradiction。已同步index為M45 approval gate。

## Approval gate

Design與Implementation Plan目前仍為`proposed`。本combined planning review判定兩者可進使用者approval gate；在取得明確核准前不得開始Unit 45-1 mutation。

```txt
Requirement: ACCEPTED
Design review: PASS / awaiting user approval
Plan review: PASS / awaiting user approval
Implementation: NOT STARTED
Open P0: 0
Open P1 without disposition: 0
```
