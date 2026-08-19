---
document_type: planning-review
status: completed
authoritative_for:
  - milestone-44-post-closure-project-code-convergence-corrective-review
last_reviewed_baseline: 1.25.2
---

# Milestone 44 Post-closure — Project Code Convergence Corrective — Holistic Review

## Scope

本review只驗證已accepted Requirement / Design / Plan所界定的四個current convergence gaps：Presentation source responsibility cohesion、risk-selected hard-code／magic-code ownership、current implementation mapping identity、stale evidence validator fail-closed。

Milestone 44 primary relationship-layout closure、Milestone 45 test-by-exception、`WritePrecheckPage -> WritePrecheckView`與目前未發布的Generated / Platform Owner Alignment + manual-local release validation corrective均不在重做範圍。

## Whole-scope findings

### F-PC-01 — Catch-all component source已收斂

原`write_precheck_content_components.dart`同時擁有Progress Step、Data Row、Record Tile、Secondary Action四個不同產品語意。Current implementation已拆成：

- `write_precheck_step.dart`
- `write_precheck_data_row.dart`
- `write_precheck_record_tile.dart`
- `write_precheck_secondary_action.dart`

拆分理由是change reason / product semantics，不是line count或one-class-one-file規則。`write_precheck_actions_section.dart`仍保留Primary / Secondary action-area相關owner；`write_precheck_information_cards.dart`仍保留同一information-card family與frame responsibility，fresh review未證明需要再拆。

Disposition：**PASS**。

### F-PC-02 — Hard-code沒有被機械清零，risk-selected magic code已命名

Current Pencil reference仍保留大量component-local exact geometry / decoration。這些literal本身依ADR-018／028屬合法implementation detail，不建立global dimensions/token owner。

本corrective只處理已證明的opaque formula / optical tuning：

- Data Row compact-row state measurement收斂為`compact`、`textTop`、`textHeight`與`_iconColumnWidth` relationship；
- Secondary Action的`77 + (surfaceWidth - 410) / 2`改為有語意的reference width / leading inset與`_centeredLeadingInset`；
- Record Tile caret optical scale命名；
- Hero / Guidance / TopArea optical text/icon scales命名；
- Step的第四步glyph特殊geometry改以`isFourthStepGlyph`描述。

沒有建立`WritePrecheckDimensions`、`VisualSpec`、`MagicNumbers`等catch-all owner；沒有把普通content改回canonical `left/top`。

Disposition：**PASS**。

### F-PC-03 — Page/View split維持合法

`WritePrecheckPage`仍持有route admission與localization-to-copy mapping；`WritePrecheckView`仍持有Scaffold / viewport / scrolling / screen composition。未因Page薄而合併，也未新增Flow/Controller形式物。

Disposition：**PASS / valid implementation**。

### F-PC-04 — Mapping已描述current source identity

`implementation_mapping.json`已同步current owners：

- `WritePrecheckDataRow`
- `WritePrecheckStep`
- `WritePrecheckRecordTile`
- `WritePrecheckSecondaryAction`

consumer也同步至current bounded owner。Screen layout evidence已由Milestone 45退休test改為current production `write_precheck_content.dart` live source。

Current schema足以表達truth，因此**不需要ADR/schema gate**。

Disposition：**PASS**。

### F-PC-05 — Stale evidence現在machine fail closed

`tools/visual/pencil_implementation_mapping.py`現在對resolved screen-layout evidence執行：

1. repository root resolution；
2. evidence必須為repository-relative；
3. path不得escape repository；
4. resolved target必須為live file。

沒有建立repository-wide backlink graph，也沒有要求evidence一定是test。

Focused machine evidence：

- live repository-relative evidence：PASS；
- missing evidence：`mapping-evidence-missing`；
- `../` repository escape：`mapping-evidence-outside-repository`。

Disposition：**PASS**。

## Test Retention Decision

新增`tools/visual/tests/test_pencil_implementation_mapping.py`保留3個小型contract cases。

Disposition：**Retain**。

理由：這是shared mapping acceptance validator的deterministic fail-closed boundary；3個case直接覆蓋live / missing / escape三種contract，執行成本低，沒有重新建立Presentation/source-shape/widget test portfolio。

`python -m unittest discover tools -p "test*.py"`因current tooling test layout不是discoverable package而回報0 tests；這不改變direct primary owner的結果，且不為了test discovery形式主義擴張repository test structure。

## Validation evidence

Fresh planner使用working-tree synthetic commit identity（不移動branch HEAD）取得：

```text
validation_level = affected
change_classes = docs_content, tooling, test_only, app_feature
analyze_scopes = apps/flutter_architecture
docs_check = true
python_test_scopes = tools, tools/visual/pencil_implementation_mapping.py,
  tools/visual/tests/test_pencil_implementation_mapping.py
flutter_test_scopes = []
full_regression = false
android_build = false
ios_build = false
release_full = false
```

Executed relevant evidence：

- `flutter analyze` at `apps/flutter_architecture`：PASS；
- `python -m unittest tools.visual.tests.test_pencil_implementation_mapping`：3/3 PASS；
- current `pencil_implementation_mapping.py` mapping validation：PASS；
- `dart run tools/docs/run_check.dart .`：PASS；
- `git diff --check`：PASS。

沒有layout/visual behavior change，因此依Plan不執行golden/runtime visual suite；planner亦未選取Flutter tests或platform builds。

## Authority / regression review

- ADR-018／028／032仍足夠，不修改stable semantics。
- Milestone 44 primary relationship-layout closure沒有被fresh evidence推翻。
- Milestone 45 test-by-exception維持有效。
- 不建立mandatory `sections/components/dialogs/flow` folder tree。
- 不建立global magic-number lint。
- 不修改VERSION / CHANGELOG / release identity。
- unrelated Generated / Platform Owner Alignment + manual-local release validation corrective未被重做。

## Final disposition

- Open P0：0
- Open P1 without disposition：0
- Corrective implementation：**PASS / locally complete**
- Publication：**Not performed**
- Template Baseline：仍為`1.25.2`

