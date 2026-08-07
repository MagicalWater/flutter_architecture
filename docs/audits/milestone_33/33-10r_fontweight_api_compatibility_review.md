---
document_type: phase-review
status: accepted
authoritative_for:
  - milestone-33-task-33-10-fontweight-api-compatibility-recovery
last_reviewed_baseline: 1.14.0
---

# Milestone 33 — Task 33-10R FontWeight API Compatibility Recovery Review

## Trigger

Task 33-11 whole-workspace validation執行：

```bash
dart run melos run analyze
```

時，`flutter_architecture`因Task 33-10 canonical renderer使用deprecated `FontWeight.index`產生6個`deprecated_member_use`並exit `1`。

這是Task 33-10 implementation的latent compatibility finding，不屬於Task 33-11文件內容，因此先回到受影響Task完成corrective recovery，再繼續文件Task。

## RED Evidence

受影響位置：

```txt
apps/flutter_architecture/lib/features/pencil_compatibility/
  presentation/pages/write_precheck_canonical_canvas.dart
```

`_pencilRasterWeight()`以`FontWeight.index`比較`w200`、`w500`與`w700`邊界。Flutter 3.44要求使用更精確的`FontWeight.value`。

Whole-workspace analyze結果：

```txt
deprecated_member_use × 6
flutter_architecture analyze exit 1
```

## Corrective Fix

只把三個比較式改為：

```dart
weight.value <= FontWeight.w200.value
weight.value >= FontWeight.w700.value
weight.value >= FontWeight.w500.value
```

Mapping return values、canonical layout、colors、shadows、font variation與visual threshold均未改變。

## Regression Contract

本finding使用兩層fresh verification：

1. `flutter analyze`證明deprecated API已消失。
2. Task 33-10 fixed visual diff證明canonical pixel output仍符合原accepted 8% gate；不得更新reference或放寬threshold。

Fresh results：

```txt
cd apps/flutter_architecture
flutter analyze \
  lib/features/pencil_compatibility/presentation/pages/write_precheck_canonical_canvas.dart
→ No issues found

flutter test \
  test/features/pencil_compatibility/presentation/write_precheck_visual_diff_test.dart
→ 2 tests passed

cd ../..
dart run melos run analyze
→ 5 packages SUCCESS; no issues found
```

## Disposition

```txt
Finding: F-33-10R-01
Severity: P1 validation blocker
Root cause: Flutter 3.44 deprecated FontWeight.index
Scope: one helper comparison API
Visual authority change: none
Threshold change: none
Open P0: 0
Open P1 after recovery: 0
```

Disposition：ACCEPTED。Deprecated API已移除，whole-workspace analyze恢復GREEN，Task 33-10 fixed visual acceptance沒有回歸。
