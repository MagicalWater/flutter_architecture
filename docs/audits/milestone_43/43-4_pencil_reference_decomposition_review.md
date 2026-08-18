---
document_type: phase-review
status: accepted
authoritative_for:
  - milestone-43-task-43-4-pencil-reference-decomposition
last_reviewed_baseline: 1.21.0
---

# Milestone 43 — Task 43-4 Pencil Reference Decomposition Review

## Scope

以`pencil_compatibility` Write Pre-check reference驗證ADR-032不是純文件規則：解除layout/content之間的handwritten `part` library coupling，並把真正具有獨立change reason的projection mechanics、bounded content components、visual primitives與typography raster mapping交給明確owner，同時維持Milestone 41/42既有visual authority與runtime fidelity。

## Test Authoring Decision

**no-new-test justified**。

本Task只做responsibility-preserving refactor，沒有新增observable behavior。Primary regression owners已存在：

- Task 43-3 generic Presentation architecture contract；
- existing Write Pre-check architecture contract；
- critical geometry contract；
- canonical/runtime golden；
- runtime visual diff；
- semantics、route與view tests。

若為每個新source owner建立class-level test，只會把source decomposition形狀固化成test density，與Milestone 36 risk-based authoring及ADR-032 anti-formalism衝突。

## Responsibility disposition

### Layout owner

`presentation/layout/write_precheck_projection.dart`由`part of`改為normal Dart library，明確擁有：

- `WritePrecheckProjection`與projection scope/text scaler；
- projected box/padding/icon/component/translate/stack primitives；
- `_RawProjectedStack` / `_RenderProjectedStack`與parent-data snapshot；
- bounded projection pixel conversion。

Content與Page/View若需要layout contract，改用explicit import/public layout API，不再共享private library namespace。

### Content composition owner

`write_precheck_content.dart`保留screen content flow與composition。原本混在同檔的bounded helpers已依change reason移出：

- progress/data/record/action bounded components → `write_precheck_content_components.dart`；
- background/ambient/shield/orbit/glow visual primitives → `write_precheck_visual_primitives.dart`；
- Pencil raster typography mapping → `write_precheck_text_style.dart`。

為降低純搬移造成的visual churn，content暫以narrow typedef aliases維持原call-site naming；aliases不重新建立library coupling，owner implementation已是normal imports。

### Cohesion evidence，不是architecture oracle

Review前`write_precheck_content.dart`約1962行且宣告12個class/enum；本Task後約1356行，只直接宣告`WritePrecheckProjectedCanvas`與`_ProjectedScreen`。此數字只用來佐證independent responsibilities確實已移出，**不**成為line-count/class-count規則；未來是否再拆仍依change reason、lifecycle與review boundary判定。

## Findings during implementation

解除`part`後fresh compile揭露三個原本被同library隱藏的依賴：

1. `WritePrecheckView`使用`WritePrecheckProjection.designWidth`卻沒有explicit import；
2. content使用projection-private `_px`；
3. content透過part間接取得`dart:ui`的`FontVariation`。

Disposition：全部改成explicit ownership/import；`part`沒有加回去。

另有一次component搬移把原本non-const `Positioned`誤標`const`造成compile failure；已恢復原const boundary。Public projection widgets轉成normal library後，analyzer要求標準`key` constructor API，已補齊，不使用lint suppression。

## Visual authority invariants

本Task沒有修改：

- repository-local accepted `.pen`；
- canonical/runtime golden bytes；
- diff threshold；
- crop/ignore regions；
- implementation mapping visual authority；
- copy/semantics expectations；
- Design System theme/token authority。

## Fresh focused validation

```txt
dart format --output=none --set-exit-if-changed <43-4 changed Dart files>
→ PASS / 0 changed

cd apps/flutter_architecture
flutter analyze lib/features/pencil_compatibility/presentation
→ No issues found

flutter test test/features/pencil_compatibility/presentation
→ 22/22 PASS
```

Runtime visual diff仍為：

```txt
RUNTIME_RENDERER_CALIBRATION
differentPixelRatio=0.09769965277777778
meanAbsoluteChannelDelta=2.495971137152778
maxChannelDelta=215

RUNTIME_PENCIL_DIAGNOSTIC
differentPixelRatio=0.1297222222222222
meanAbsoluteChannelDelta=3.8164214409722224
maxChannelDelta=233
```

## Validation Execution Decision

以provisional Task commit `78e858073730b150fccd96b5d001ce3d0558a375`對前一Task `ab040e5`執行canonical planner：

```json
{
  "change_classes": ["docs_content", "app_feature"],
  "validation_level": "affected",
  "docs_check": true,
  "analyze_scopes": ["apps/flutter_architecture"],
  "flutter_test_scopes": ["apps/flutter_architecture/test/features/pencil_compatibility"],
  "android_build": false,
  "ios_build": false,
  "full_regression": false,
  "fail_safe": false
}
```

Planner-selected validation fresh結果：

```txt
dart run melos run docs_check
→ PASS

cd apps/flutter_architecture
flutter analyze
→ No issues found

flutter test test/features/pencil_compatibility
→ 22/22 PASS
```

## Layer 1 — Focused review

- `write_precheck_projection.dart`已是真正normal library；content/page只能透過explicit imports與public layout API使用，不再共享private namespace。
- Public projection API只公開跨library實際需要的bounded presentation mechanics；RenderObject implementation仍保持layout library private。
- Content decomposition按projection mechanics、bounded content component、visual primitive、text rendering responsibility拆分，不以行數或class數作hard rule。
- typedef aliases只維持content call-site continuity，不擁有implementation，也沒有重新形成Dart library coupling。
- 沒有新建Bloc/Cubit、Domain/Data假層或Design System pollution。

Focused review：**PASS**。

## Fresh focused re-review

實作中所有compile/analyze findings均fresh修正後重跑；final formatter、app analyze、full Pencil feature tests與docs checker全GREEN。Accepted `.pen`、golden、threshold與visual authority均未變更。

Fresh focused re-review：**PASS**。

## Layer 2 — Whole-Task review

43-4證明ADR-032可在高fidelity reference中實作，而不需要one-widget-one-file或破壞visual acceptance。Cross-owner handwritten `part`已消失，screen composition、layout mechanics與bounded helpers有正常library boundaries。

```txt
Task 43-4: accepted
Open P0: 0
Open P1 without disposition: 0
Next: Task 43-5 ordinary feature adoption / positive proofs
```
