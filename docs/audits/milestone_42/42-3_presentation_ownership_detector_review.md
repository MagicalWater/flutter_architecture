---
document_type: phase-review
status: accepted
authoritative_for:
  - milestone-42-task-42-3-presentation-ownership-detector
last_reviewed_baseline: 1.21.0
---

# Milestone 42 — Task 42-3 Presentation Ownership Detector Review

## Scope

完成reference presentation ownership detector，使`pages/`責任可以被direct regression owner檢查，而不是只靠human review或file size猜測。

## Detector contract

Reference `write_precheck_projected_canvas.dart`在仍位於`presentation/pages/`時，direct owner會拒絕：

1. custom `MultiChildRenderObjectWidget`／`RenderStack`與create/update RenderObject infrastructure；
2. confirmed bounded section/component implementations仍由page file持有；
3. Milestone 41已存在的whole-screen canonical coordinate shortcut仍由原detector獨立檢查；
4. generic UI Spec catch-all由Milestone 42 Task 42-1 owner獨立檢查。

Detector刻意不使用：

- file line count；
- widget/class count hard limit；
- `Stack`／`Positioned`數量；
- every-private-class禁止規則。

Bounded section detector只鎖current reference已確認的section responsibilities。Repository-wide future recurrence由ADR/Skill/Guide與PTF-32治理，不建立generic Dart AST framework。

## Controls

Synthetic controls：

- orchestration-only `WritePrecheckView → WritePrecheckContent`：PASS；
- page file直接持有`_CanonicalDataRow`／`_CanonicalRecordTile`／`_CanonicalSecondaryAction`：detected；
- bounded local overlay：仍PASS Milestone 41 negative control；
- custom render/projection fixture：detected。

## Current reference state

Production source尚未搬移，因此full architecture owner目前預期仍RED：

```txt
presentation/pages owns custom render/projection infrastructure
presentation/pages owns bounded write-precheck section implementations
PencilCompatibilityVisualSpec mixes UI design ownership domains
```

這不是Task 42-3 failure；Task 42-3的交付是detector本身與controls成立。Task 42-4／42-5完成source migration後，同一direct owner必須轉GREEN。

## Review disposition

```txt
Task 42-3: PASS / ACCEPTED
Detector controls: PASS
Current source architecture owner: intentionally RED
Open P0: 0
Open P1 without disposition: 0
```
