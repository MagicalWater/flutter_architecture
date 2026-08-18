---
document_type: phase-review
status: accepted
authoritative_for:
  - milestone-41-task-41-4-reference-layout-migration
last_reviewed_baseline: 1.20.0
---

# Milestone 41 — Task 41-4 Reference Layout Migration Review

## Scope

將 current Pencil compatibility proof 從 whole-screen canonical coordinate reconstruction 遷移為 constraint／relationship-owned page flow，同時保留 section-local bounded visual composition。

## Production architecture after migration

```txt
WritePrecheckView
→ SingleChildScrollView
→ WritePrecheckProjectedCanvas
→ Column / sibling flow regions
   → bounded header/progress region
   → Hero
   → Summary
   → Results
   → Records
   → Guidance
   → Primary action
   → Secondary actions
   → Footer
```

Screen-level section placement現在由 region height + sibling gap + horizontal relationship 決定；不再存在 whole-page `designHeight = 1672` owner，也不再以 canonical page `top` 排列 major sections。

## Bounded overlay boundary

`_ProjectedStack`／component-local projection仍保留於 bounded region，因 current renderer calibration 已證明它對 runtime raster fidelity 有直接責任。它只縮放 local `StackParentData`，不再擁有 whole-screen page origin 或 section-to-section placement。

Page-level ambient／supplemental glows只屬 decoration layer；不參與 Column content flow。

## Findings and fixes

### F-41-4-01 — Ambient glow lacked finite height

第一輪 migration 將 ambient glow 作為 root Stack 的 non-positioned child，在 scrollable infinite-height constraint 下觸發 unbounded Stack assertion。

Disposition：fixed。改為 root `Positioned.fill` decoration layer；Column仍是唯一content-flow owner。

### F-41-4-02 — Whole-section Transform changed runtime rasterization

第一輪 `_flowRegion` 以 whole-section `_ProjectedComponent` Transform scaling，雖 architecture GREEN，但 runtime golden 出現大幅 rasterization drift。

Disposition：fixed。恢復 bounded region 內既有 projected-geometry calibration；screen flow仍維持 Column。沒有回復 whole-screen projected canvas。

## Fresh validation

```txt
write_precheck_architecture_contract_test.dart: PASS
write_precheck_responsive_test.dart: PASS at 941×1672 / 390×844 / 226×400
dart format: PASS
```

## Review disposition

```txt
Whole-screen canonical coordinate owner: removed
Constraint/sibling page flow: present
Bounded local overlay: retained intentionally
Parallel whole-screen renderer: absent
Open P0: 0
Open P1 without disposition: 0
Task 41-4: PASS
```
