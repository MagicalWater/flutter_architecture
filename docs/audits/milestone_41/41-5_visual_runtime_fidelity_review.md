---
document_type: phase-review
status: accepted
authoritative_for:
  - milestone-41-task-41-5-visual-runtime-fidelity
last_reviewed_baseline: 1.20.0
---

# Milestone 41 — Task 41-5 Visual / Runtime Fidelity Review

## Scope

證明 Task 41-4 architecture corrective 沒有用降低 accepted Pencil fidelity 換取 architecture GREEN。

## Recovery evidence

Initial migration candidate：

```txt
canonical golden drift: 0.42% / 6670 px
runtime golden drift: 33.70% / 77650 px
```

定位後確認 runtime 大差異來自 renderer calibration strategy，不是 accepted design 或 threshold 問題。恢復 bounded local projected geometry後，runtime drift縮到單一 glow row；再依原 z-order 把 guidance trailing glow 與 primary leading glow放回各自 bounded flow relationship，沒有更新 golden。

## Immutable contract check

本 Task **沒有**：

- 放寬 canonical/runtime threshold；
- 修改 crop 或 ignore regions；
- 更新 accepted `.pen`；
- 更新 accepted golden；
- 改 runtime projection algorithm迎合candidate；
- 刪除 critical local owner。

## Fresh full Pencil presentation validation

```txt
flutter test test/features/pencil_compatibility/presentation
19 tests PASS
```

Fresh runtime fidelity diagnostic仍為既有固定 contract：

```txt
RUNTIME_RENDERER_CALIBRATION
differentPixelRatio = 0.09769965277777778
meanAbsoluteChannelDelta = 2.495971137152778
maxChannelDelta = 215

RUNTIME_PENCIL_DIAGNOSTIC
differentPixelRatio = 0.1297222222222222
meanAbsoluteChannelDelta = 3.8164214409722224
maxChannelDelta = 233
```

Canonical golden、runtime golden、critical geometry、responsive、semantics、route/copy與view hierarchy owners全部 fresh PASS。

## Review disposition

```txt
Architecture gate: PASS
Canonical golden: PASS
Runtime golden: PASS
Runtime visual diff: PASS
Critical geometry: PASS
Responsive/layout health: PASS
Semantics: PASS
Open P0: 0
Open P1 without disposition: 0
Task 41-5: PASS
```
