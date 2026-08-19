---
document_type: phase-review
status: accepted
authoritative_for:
  - milestone-44-task-44-3-write-precheck-relationship-layout
last_reviewed_baseline: 1.22.0
---

# Milestone 44 — Task 44-3 Write Precheck Relationship Layout Review

## Scope

本Task把current Pencil compatibility reference從component-local fixed-canvas laundering遷移為relationship-owned normal content，並依真實change reason拆出bounded Presentation owners。Accepted `.pen`、visual manifest、golden threshold/crop/ignore region均未修改。

## Test Authoring Decision

**no-new-test justified**。44-1已建立本次新增failure mode的direct machine owner；current widget/responsive/semantics tests已覆蓋runtime hierarchy、scrollability與surface semantics。本Task沒有新增新的observable product behavior，只把44-1 RED轉GREEN並保留既有runtime contract。

## Production corrective

### Normal content relationship ownership

- `WritePrecheckStep`移除public `left/top`；step distribution由`Row + fixed sibling widths/gaps`擁有，step內只有glow/circle等bounded artwork使用Stack layering。
- `WritePrecheckDataRow`移除`top`；icon/label/value/divider改由`Padding + Row + Expanded + Column`擁有。
- `WritePrecheckRecordTile`移除`top`與`_localText`；icon、title/value、badge、caret改為Row/Column relationships。
- `WritePrecheckSecondaryAction`移除`left/iconLeft/labelLeft`等canonical placement API；bounded surface只暴露component measurement `surfaceWidth`，button內icon/label改為Padding/Row relationships。
- generic `_positionedText`、`_localText`、`_positionedIcon`、`_localIcon` helpers全部移除。
- Header/status、Hero文字、Guidance內容、Primary/Secondary/Footer action normal content皆改用relationship layout；不把座標從child偷搬回parent。
- screen root major sections由`Column + _flowRegion + Align`組成；不再用section wrapper `Positioned(left/top/width/height)`。

### Responsibility decomposition by change reason

`write_precheck_content.dart`現在只負責screen composition、flow gaps/regions與background/ambient overlay orchestration。Bounded owners依產品語意拆為：

- `write_precheck_top_area.dart`：status/header/progress；
- `write_precheck_hero_section.dart`：Hero content + artwork；
- `write_precheck_information_cards.dart`：Summary/Results/Records與共同information-card frame；
- `write_precheck_guidance_section.dart`：guidance/commitment surface；
- `write_precheck_actions_section.dart`：primary/secondary/footer actions與相鄰action glow；
- `write_precheck_content_components.dart`：step/data-row/record-tile/secondary-action bounded primitives。

此拆分依change reason，不依行數、class/widget count或mandatory folder taxonomy。

## Remaining Positioned rationale

Fresh source scan後，remaining `Positioned`只存在下列spatial/decorative responsibilities：

- Top progress track：z-order track under relationship-distributed steps；
- Hero：radial glow、orbits、decorative dots、shield artwork；
- Guidance：radial glow與bottom glow overlay；
- Primary action：top highlight hairline；
- screen-level primary supplemental glow：accepted 889×17 action glow overlay，沒有承擔content placement；
- visual primitives：ambient background glows與shield internal artwork。

沒有remaining normal Text/DataRow/Button/Card content以canonical `left/top`作主要layout semantics。

## Fresh focused evidence

```txt
flutter analyze
  write_precheck widget owners + write_precheck_projection.dart
→ PASS

flutter test
  write_precheck_view_test.dart
  write_precheck_responsive_test.dart
  write_precheck_semantics_test.dart
  write_precheck_architecture_contract_test.dart
→ 12 tests PASS

flutter test
  write_precheck_golden_test.dart
  write_precheck_runtime_golden_test.dart
→ canonical Windows + 360×640 runtime PASS
```

途中focused runtime tests曾抓到Header、RecordTile、SecondaryAction的Flex overflow；修正方式是調整alignment/flex/available constraints，沒有恢復canonical coordinate placement。Fresh re-run後全部PASS。

Visual recovery期間沒有更新golden、threshold、crop或ignore region。最终root causes均以accepted source authority重建：

- Primary action下方不是兩段近似shadow，而是原authority的screen-level 889×17 supplemental decorative glow；
- progress projection owner必須保留941×220 transform bounds；step本身仍由131px vertical relationship slot + Row + sibling widths/gaps排列；
- Results technical row與Guidance commitment保留既有nested measurement projection semantics；只投影sibling gaps，不恢復normal-content canonical x/y；
- Footer恢復direct screen projection measurement，而非額外包一層ProjectedComponent；
- Secondary surface與relationship-owned content保留同一bounded ProjectedComponent，避免runtime double-raster path drift。

上述修正後canonical與360×640 runtime golden均fresh PASS。

## Layer 1 — Focused review

- 44-1六個direct RED findings全部轉GREEN。
- normal content relationship ownership已涵蓋child component與parent section composition。
- section wrapper不再以local `Positioned`洗白fixed canvas。
- projection machinery仍只服務measurement與真正spatial overlay；本Task未為了架構純化移除必要visual projection。
- source decomposition依change reason形成normal Dart library boundaries，沒有使用`part/part of`假拆分。

Focused review：**PASS**。

## Fresh focused re-review

Fresh source scan重新檢查remaining `Positioned`，沒有normal-content placement；all remaining cases都有spatial/decorative rationale。Runtime focused suite fresh PASS。

Fresh focused re-review：**PASS**。

## Layer 2 — Whole-Task review

Task 44-3符合accepted Design與Plan：direct RED已GREEN、reference root relationship-owned、bounded owners依change reason拆分、legal overlay未被全面禁止、accepted visual authority未改寫。

```txt
Task 44-3 = accepted
Open P0 = 0
Open P1 without disposition = 0
Next after acceptance = Task 44-4 visual/runtime fidelity + legal overlay preservation
```

Whole-source scan逐一檢查remaining `Positioned`：Top只保留progress glow/track，Hero只保留artwork/glow/orbit/dots，Step只保留circle/glyph/glow bounded layering，Guidance只保留radial/trailing glow，Actions只保留primary highlight，screen root只保留background/ambient與accepted primary supplemental glow。沒有normal Text/DataRow/Card/Button重新以canonical `left/top`取得主要layout ownership。

Layer 2 whole-Task review：**PASS**。

## Validation planner

Validation snapshot：`9619afab00726acaf2e37fbbbf5c5c83b1c9cb5a`，base：`5a64789ab0c3f21d9ceb6246ccabe8804bf93a0e`。

Planner result：

```txt
change_classes = docs_content, app_feature
validation_level = affected
analyze_scopes = apps/flutter_architecture
flutter_test_scopes = apps/flutter_architecture/test/features/pencil_compatibility
docs_check = true
full_regression = false
fail_safe = false
```

Planner-selected fresh validation：

- `cd apps/flutter_architecture && flutter analyze` → PASS；
- `cd apps/flutter_architecture && flutter test test/features/pencil_compatibility` → 22 tests PASS，包含canonical/runtime golden、critical geometry、route、semantics、responsive、architecture owner；
- `dart run melos run docs_check` → PASS；
- `git diff --check` → PASS。

Additional independent architecture re-review：

- `flutter test test/architecture/presentation_responsibility_contract_test.dart` → 10 tests PASS；
- direct normal-content canonical `left/top` synthetic rejection、relationship data row legal control與bounded decorative overlay legal control均維持GREEN。
