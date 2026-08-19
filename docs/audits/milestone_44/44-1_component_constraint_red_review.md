---
document_type: phase-review
status: accepted
authoritative_for:
  - milestone-44-task-44-1-component-constraint-red
last_reviewed_baseline: 1.22.0
---

# Milestone 44 — Task 44-1 Component Constraint RED Review

## Scope

本Task只建立component-local fixed-canvas laundering的direct regression owner與互斥controls；不修改production source、stable ADR、consumer Skill或visual authority。

## Test Authoring Decision

**Required**。Current repository已證明screen root可以relationship-owned，但bounded normal-content component仍透過canonical `left/top`與generic positioned text helper重建local canvas。這是M44新增的直接failure mode，必須有machine owner。

## Machine boundary

Machine contract採risk-selected normal-content owner／helper清單加結構檢測，不採全域`Positioned` ban，也不採Positioned count、file line count、class/widget count或folder existence。

Negative controls：

- normal-content component public API暴露`left/top`且以`Positioned`承擔普通content placement → detected；
- generic `_positionedText`／`_localText` helper接受canonical coordinate並回傳`Positioned` → detected；
- current `WritePrecheckStep`、`WritePrecheckDataRow`、`WritePrecheckRecordTile`、`WritePrecheckSecondaryAction`為risk-selected direct owners。

Positive controls：

- `Padding + Row + Expanded + Align` normal data row → allowed；
- bounded Hero badge/glow overlay → allowed；
- accepted intentional spatial canvas仍由既有ADR-028 `approval_ref` contract負責，本Task不另建重複spatial framework。

## Expected RED

Focused owner：

```txt
cd apps/flutter_architecture
flutter test test/architecture/presentation_responsibility_contract_test.dart \
  test/features/pencil_compatibility/presentation/write_precheck_architecture_contract_test.dart
```

Expected current result：generic synthetic controls PASS，但current `write_precheck` architecture contract因risk-selected normal-content canonical coordinate placement而FAIL。此RED由44-2 stable authority hardening與44-3 production relationship-layout corrective依序轉GREEN。

## Fresh RED evidence

2026-08-19 fresh執行：

```txt
cd apps/flutter_architecture
flutter test test/architecture/presentation_responsibility_contract_test.dart \
  test/features/pencil_compatibility/presentation/write_precheck_architecture_contract_test.dart
```

實際結果：synthetic/generic controls全部PASS；current `write_precheck` contract只因下列M44預期failure而RED：

```txt
WritePrecheckStep exposes canonical left/top for normal content
WritePrecheckDataRow exposes canonical left/top for normal content
WritePrecheckRecordTile exposes canonical left/top for normal content
WritePrecheckSecondaryAction exposes canonical left/top for normal content
_localText positions normal content with canonical coordinates
_positionedText positions normal content with canonical coordinates
```

另外單獨fresh執行generic owner：

```txt
cd apps/flutter_architecture
flutter test test/architecture/presentation_responsibility_contract_test.dart
```

結果：`10 tests passed`。因此RED不是compile error、不是generic detector false positive，而是current production reference確實命中已核准M44 failure mode。

## Layer 1 — Focused review

- Detector沒有以Positioned count、file length、class/widget count或folder existence作oracle。
- Risk-selected normal-content owners由test明確指定，machine helper只檢查其public coordinate API與normal-content placement結構，不自行猜測所有component semantics。
- `_localText`與`_positionedText`以definition-level declaration檢測，避免因call-site名稱出現造成誤判。
- `Padding + Row + Expanded + Align` positive control PASS。
- bounded Hero `Stack/Positioned` badge/glow positive control PASS。
- accepted intentional spatial canvas仍由ADR-028既有approval_ref contract負責，沒有建立重複framework。

Focused review：**PASS**。

## Fresh focused re-review

初次helper implementation只抓到`_localText`，原因是以最後一次symbol occurrence定位definition時會被後續delegating call干擾。已改為只匹配`Positioned|Widget <helper>(...)` declaration，再fresh執行；`_localText`與`_positionedText`現在都被正確捕捉，synthetic controls仍全部PASS。

Fresh focused re-review：**PASS**。

## Layer 2 — Whole-Task review

44-1只建立direct RED與positive/negative controls；沒有修改production source、ADR、Skill、visual authority、`.pen`或golden contract。Scope與accepted Plan一致，且RED精準證明M41 screen-root relationship rule仍不足以阻止bounded component local canvas laundering。

```txt
Task 44-1 = accepted RED
Expected current write_precheck owner = intentionally FAIL until 44-3
Generic machine controls = PASS
Open P0 = 0
Open P1 without disposition = 0
```

下一個合法步驟：Task 44-2 stable ADR + consumer governance GREEN。

## Validation planner

Validation snapshot：`76530eef220c8ef99c2e432eb48eda16886540b4`，base：`843113b8fd7a8fe0c47de6dd880dc58c23925b5a`。

Planner result：

```txt
change_classes = docs_content, test_only
validation_level = focused
docs_check = true
flutter_test_scopes =
  apps/flutter_architecture/test/architecture/presentation_responsibility_contract_test.dart
  apps/flutter_architecture/test/features/pencil_compatibility/presentation/write_precheck_architecture_contract_test.dart
full_regression = false
fail_safe = false
```

Fresh validation disposition：

- `dart run melos run docs_check` → PASS；
- `git diff --check` → PASS；
- generic Presentation contract owner → PASS（10/10）；
- current Pencil architecture owner → intentional RED，且只剩本Task列出的六個component-local canonical-coordinate findings。

由於44-1本身是TDD RED Task，最後一項預期FAIL就是本Task的成功證據；它不是completion validation regression。44-2/44-3必須在後續GREEN階段fresh重跑同一owner並消除此RED，否則Milestone不得完成。

