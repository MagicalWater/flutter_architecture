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
State: Requirement accepted / Design required
Template Baseline: 1.20.0
```

## Current Scope

Milestone 41處理current Pencil-to-Flutter stable policy與reference production implementation之間的layout architecture drift。Fresh audit已確認：current contract禁止canonical design-space `x/y`機械套成runtime固定座標，但`WritePrecheckProjectedCanvas`仍以whole-screen projected `Stack`／`Positioned`、global design scale與custom `RenderStack`縮放positioned parent data，且現有policy／architecture tests無法攔住。Scope包含constraint／relationship-based layout contract、bounded local overlay boundary、machine enforcement、reference implementation corrective與behavioral pressure；不修改accepted `.pen`或降低visual fidelity gate。

## Current Gate

Requirement Decision已接受。下一個合法階段是formal Design Spec與完整Design Task review；Design取得使用者明確核准前不得建立Implementation Plan或修改production implementation。

## Current Evidence

- Requirement Decision：`docs/audits/milestone_41/41-r_requirement_decision.md`（accepted）。
- Fresh admission / root-cause audit：本Requirement的Problem／Current Behavior保存current read-only findings；Design必須把policy、machine enforcement與reference implementation責任邊界收斂為單一可實作contract。

## Previous Closure

Milestone 40已完成GitHub Repository Landing Page與documentation authority restructure，未升Template Baseline；Milestone 39的1.20.0 publication仍是current release authority。
