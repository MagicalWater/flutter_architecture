---
document_type: phase-review
status: accepted
authoritative_for:
  - milestone-33-corrective-c2-runtime-visual-contract-review
last_reviewed_baseline: 1.15.0
---

# Milestone 33 Corrective — C2 Runtime Visual Contract Review

## Scope

本Task只鎖定Pencil-derived `360 × 640` runtime comparison contract與1.15.0 defect reproduction；不修改Flutter production renderer。

## Locked Reference Contract

Canonical Pencil preview：

```txt
941 × 1672
SHA-256: f453452316f0e390dbbf435a3f4c2433306fb3aa607287873e9905f00973eee8
```

Derived runtime reference在任何candidate修正前固定為：

```txt
360 × 640
bytes: 131042
SHA-256: 8386e4fa6ad49d108b9887796eb3c02643aaae9ba0161afa10d0662ab4b2c275
projection: Flutter dart:ui instantiateImageCodec(targetWidth: 360, targetHeight: 640)
crop: none
ignore regions: none
per-channel tolerance: 8
different-pixel ratio <= 0.08
mean absolute channel delta <= 8.0
```

Default derivation test fresh投影到temporary file並要求與tracked reference bytes完全一致；只有顯式`UPDATE_PENCIL_RUNTIME_REFERENCE=true`可重建tracked reference。

## TDD Evidence

### Projection helper RED

`visual_diff_test.dart`先新增projection contract；production/test-support尚無`projectPng`時，focused test因`Method not found: 'projectPng'`正確RED。

### Projection helper GREEN

實作最小test-support `projectPng`後，projection／diff utility與reference verification fresh通過：

```txt
visual diff / projection / reference tests: 12 PASS
runtime candidate golden capture: PASS
```

### Corrective architecture RED

Current 1.15.0 source被single-renderer architecture guard正確拒絕：

```txt
WritePrecheckView selects parallel whole-screen renderers by width
```

失敗原因是既有`constraints.maxWidth >= 900` canonical branch與另一套mobile whole-screen tree並存，不是fixture、syntax或environment問題。

### Corrective runtime fidelity RED

Current 1.15.0 `360 × 640` candidate對已鎖Pencil-derived reference：

```txt
differentPixelRatio = 0.6843012152777778
threshold           = 0.08

meanAbsoluteChannelDelta = 25.48889214409722
threshold                = 8.0

maxChannelDelta = 244
```

此RED客觀重現使用者人工P1：canonical fidelity曾通過，但actual supported runtime renderer視覺不忠實。

## Focused Findings

### F-33-C2-01 — Runtime reference不可由candidate反向決定

- Severity：P1。
- Status：Resolved。
- Disposition：reference derivation、target、hash與threshold已在C3 production change前固定於manifest；C3不得為取得GREEN修改這些值。

### F-33-C2-02 — Candidate golden不等於accepted visual authority

- Severity：P1。
- Status：Resolved。
- Disposition：`write_precheck_runtime_windows.png`只保存目前renderer的deterministic candidate bytes；accepted comparison authority仍是Pencil-derived reference。

### F-33-C2-03 — Layout-health test不得冒充fidelity gate

- Severity：P1。
- Status：Resolved。
- Disposition：responsive test明確只擁有scroll／overflow／semantics責任；`360 × 640` fidelity由獨立fixed visual diff test擁有。

## Fresh Re-review

- Projection input為canonical Pencil preview，不讀Flutter candidate。
- Reference target與hash在C3前已固定。
- Architecture RED與runtime RED均由已知1.15.0 defect造成。
- Production source在C2零修改。
- Anti-raster、no top-level fixed scaling與dimension fail-closed規則未削弱。

## Whole-Task Review

```txt
Projection/helper contract: PASS
Reference derivation determinism: PASS
Manifest lock: PASS
1.15.0 single-renderer reproduction: RED AS EXPECTED
1.15.0 runtime fidelity reproduction: RED AS EXPECTED
Open P0: 0
Undispositioned P1: 0
C2 disposition: ACCEPTED INTENTIONAL RED CONTRACT
Next Task: C3 converts the same RED tests to GREEN without changing the locked reference contract
```
