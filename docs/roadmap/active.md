---
document_type: active-milestone
status: active
authoritative_for:
  - current-active-milestone
last_reviewed_baseline: 1.20.0
---

# Active Milestone

```txt
Active Milestone: Milestone 41 — Pencil-to-Flutter Constraint-based Layout Architecture Corrective
State: Design reviewed / user approval pending
Template Baseline: 1.20.0
```

## Current Scope

Milestone 41處理current Pencil-to-Flutter stable policy與reference production implementation之間的layout architecture drift。Fresh audit已確認：current contract禁止canonical design-space `x/y`機械套成runtime固定座標，但`WritePrecheckProjectedCanvas`仍以whole-screen projected `Stack`／`Positioned`、global design scale與custom `RenderStack`縮放positioned parent data，且現有policy／architecture tests無法攔住。Scope包含constraint／relationship-based layout contract、bounded local overlay boundary、machine enforcement、reference implementation corrective與behavioral pressure；不修改accepted `.pen`或降低visual fidelity gate。

## Current Gate

Requirement Decision與formal Design Spec均已接受，Design Task review與使用者核准已完成。下一個合法gate是建立並審查Implementation Plan；Plan取得使用者明確核准前不得修改production implementation。

## Current Evidence

- Requirement Decision：`docs/audits/milestone_41/41-r_requirement_decision.md`（accepted）。
- Design：`docs/superpowers/specs/2026-08-18-milestone-41-pencil-layout-architecture-corrective-design.md`（accepted；review PASS；user approved 2026-08-18）。
- Design Review：`docs/audits/milestone_41/41-0_design_spec_review.md`（completed / PASS）。

## Previous Closure

Milestone 40已完成GitHub Repository Landing Page與documentation authority restructure，未升Template Baseline；Milestone 39的1.20.0 publication仍是current release authority。
