# Milestone 33 Corrective Runtime Renderer Calibration Amendment Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this amendment inside the already-approved corrective managed worktree. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 用renderer-calibrated deterministic runtime gate取代自相矛盾的direct Pencil 8% runtime hard gate，同時保留canonical 8%與Android人工P1 gate。

**Architecture:** Gate A先證明Flutter canonical對Pencil authority的忠實度；Gate B再由該canonical golden fresh投影出360×640 same-renderer temporary reference，檢查production `WritePrecheckView`在runtime尺寸沒有額外重大drift。Pencil-derived 360 reference保留為diagnostic；BlueStacks screenshot與使用者人工驗收仍是supported runtime hard gate。

**Tech Stack:** Flutter golden/widget/integration tests、`dart:ui` `instantiateImageCodec`、existing `projectPng`／`comparePngs`、BlueStacks Android runtime、repository docs checks。

## Global Constraints

- Gate A保持`perChannelTolerance=8`、`differentPixelRatio<=0.08`、`meanAbsoluteChannelDelta<=8.0`。
- Gate B固定`360×640`、`perChannelTolerance=8`、`differentPixelRatio<=0.10`、`meanAbsoluteChannelDelta<=4.0`、no ignore regions。
- Gate B reference必須fresh由tracked canonical Flutter golden用existing `projectPng`投影；不得tracked成第二份authority。
- 原C2 Pencil-derived runtime reference與SHA不得因candidate變更。
- Direct Pencil runtime diff保留為diagnostic evidence，不作單獨PASS來源。
- Android `540×960 @ DPR1.5` screenshot與使用者人工visual acceptance維持hard gate。
- 禁止第二套whole-screen renderer、test-only visual branch、production raster screenshot、whole-screen `FittedBox` shortcut。

---

### Task CP2-1: Supersede Runtime Hard Gate Without Rewriting C2 History

**Files:**
- Modify: `apps/flutter_architecture/test/features/pencil_compatibility/presentation/write_precheck_runtime_visual_diff_test.dart`
- Reuse: `apps/flutter_architecture/test/support/visual_diff.dart`
- Reuse: `apps/flutter_architecture/test/features/pencil_compatibility/goldens/write_precheck_windows.png`
- Reuse: `apps/flutter_architecture/test/features/pencil_compatibility/goldens/write_precheck_runtime_windows.png`
- Reuse unchanged: `docs/design_sources/pencil-compatibility-write-precheck/pencil-runtime-360x640.png`
- Create: `docs/audits/milestone_33/33-cp2_runtime_renderer_calibration_review.md`

**Interfaces:**
- Consumes: `projectPng({source, output, width, height})` and `comparePngs(...)` from `visual_diff.dart`.
- Produces: executable Gate B and recorded Gate C diagnostics.

- [ ] **Step 1: Update the runtime visual test to derive the same-renderer reference**

The test must create a temporary projected canonical file from:

```txt
test/features/pencil_compatibility/goldens/write_precheck_windows.png
```

using:

```dart
await projectPng(
  source: canonicalGolden,
  output: projectedCanonical,
  width: 360,
  height: 640,
);
```

Then compare the tracked runtime candidate against that temporary file using tolerance`8`、ratio`0.10`、mean`4.0`。

- [ ] **Step 2: Preserve direct Pencil runtime comparison as diagnostics**

In the same test, compare runtime candidate against the unchanged tracked`pencil-runtime-360x640.png`and print／record the ratio, mean and max. Do not assert`<=0.08`on this diagnostic result。

- [ ] **Step 3: Verify the amended runtime gate**

Run:

```bash
cd apps/flutter_architecture
flutter test test/features/pencil_compatibility/presentation/write_precheck_golden_test.dart
flutter test test/features/pencil_compatibility/presentation/write_precheck_visual_diff_test.dart
flutter test test/features/pencil_compatibility/presentation/write_precheck_runtime_golden_test.dart
flutter test test/features/pencil_compatibility/presentation/write_precheck_runtime_visual_diff_test.dart
flutter test test/features/pencil_compatibility/presentation/write_precheck_single_renderer_architecture_test.dart
```

Expected:

```txt
Gate A canonical fidelity: PASS
Gate B deterministic runtime projection: PASS only if ratio <= 0.10 and mean <= 4.0
Gate C direct Pencil runtime metric: recorded, not promoted to authority
single-renderer architecture: PASS
```

- [ ] **Step 4: Review and commit CP2-1**

Record:

- original C2 direct runtime baseline`0.6843...`;
- accepted 1.15.0 projected-canonical floor`~0.0890842`;
- C3 calibration floor`0.08782552083333334`;
- fresh Gate A/B/C values;
- no threshold/crop/ignore-region changes after CP2 acceptance。

Commit only the test andreview artifactwith:

```txt
test(pencil): 校準runtime單一渲染視覺門檻
```

### Task CP2-2: Resume C3 and C4 Under the Amended Contract

**Files:**
- Continue existing C3 production files and reviews from theaccepted corrective Plan。
- Update existing Skill／Guide wording only where it still claims that a cross-renderer direct pixel threshold is the sole runtime PASS source。
- Continue C4 Android screenshot and user review artifacts。

**Interfaces:**
- Consumes: CP2-1 Gate A/B/C/D contract。
- Produces: C3 single-renderer completion and C4 actual Android visual acceptance。

- [ ] **Step 1: Finish C3 without visual-test overfitting**

Keep only changes supported by Pencil extraction、same-tree architecture or measured canonical improvement. Remove throwaway probes. Do not continue micro-adjusting production UI solely to reduce Gate C diagnostic ratio once Gate A and Gate B pass。

- [ ] **Step 2: Run C3 focused and whole-task validation**

Run the original C3 validation set plus the amended Gate B test. Canonical Gate A and single-renderer architecture remain mandatory。

- [ ] **Step 3: Execute C4 on BlueStacks**

Build/install the fresh development APK, capture`540×960 @ DPR1.5`, store screenshot/hash and perform semantic side-by-side review. Keep the actual Write Pre-check screen visible for the user。

- [ ] **Step 4: Stop only at user visual acceptance**

Automation cannot mark C4 accepted. If the user rejects the visible runtime, return to C3 with the specific semantic finding. If accepted, record explicit acceptance and proceed to the original C5 holistic final review/release flow。

## Self-Review

- Spec coverage：Gate A/B/C/D、anti-cheat、Android manual gate全部有對應execution step。
- Placeholder scan：無未決placeholder。
- Type consistency：只重用existing `projectPng`／`comparePngs`，不新增production abstraction。
- Scope：只修acceptance calibration與其直接測試／文件；不重設`.pen`或產品UI。

## Approval

2026-08-08：P1 evidence與calibrated gate方向呈現後，使用者明確回覆「已批准」。本Plan amendment為`accepted`，可在現有managed corrective worktree直接執行。
