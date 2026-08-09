---
document_type: phase-review
status: accepted
authoritative_for:
  - milestone-35-task-35-2-validation-planner
last_reviewed_baseline: 1.15.2
---

# Task 35-2 — Change Classification + Validation Planner Review

## Scope

Task 35-2實作accepted Design定義的pure change classification與Minimum Sufficient Validation planner core，但尚未切換GitHub Actions或local execution consumer。

Files：

- `tools/ci/change_classifier.py`
- `tools/ci/validation_planner.py`
- `tools/ci/test_change_classifier.py`
- `tools/ci/test_validation_planner.py`

## Implementation summary

### Canonical change classes

Classifier新增deterministic classes：

```txt
docs_content
governance
tooling
test_only
app_feature
app_shared
package
generated
database
android_native
ios_native
dependency
validation_engine
release
unknown
```

Mixed change set採deterministic ordered union；只有真的unknown path才進入`unknown` fail-safe。

### Validation planner

新增`tools/ci/validation_planner.py` pure core，輸出：

```txt
change_classes
validation_level
flutter_test_scopes
python_test_scopes
analyze_scopes
docs_check
generated_check
android_build
ios_build
full_regression
release_full
reason
fail_safe
```

Planner不執行test或build，只決定minimum sufficient validation plan。

### Workspace dependency propagation

Planner從root workspace與各member `pubspec.yaml`解析local dependency graph，再推導reverse dependency closure；沒有手寫package→consumer global matrix。Graph parse或unknown package失敗時full fail-safe。

## Focused review findings

### F-35-2-01 — Mixed known paths被舊`_is_full_ci_path`邏輯誤判unknown

Severity：P1。

First GREEN run：39 tests中1 failure。`docs + package` mixed set因docs path不屬legacy `_is_full_ci_path`而回退`_FULL_MATRIX`，雖兩條path其實都可canonical classify。

Disposition：Resolved。Known/unknown判斷改為`classify_change_classes()`；只有class set包含`unknown`才fail-safe。Fresh rerun GREEN。

### F-35-2-02 — Legacy workflow compatibility不能提前被拆掉

Severity：P1 design guard。

Disposition：PASS。`Classification`保留`docs_only/full_ci/android_build/ios_build/release_full` compatibility projection，current workflow在Task 35-4 cutover前不會失去既有heavy-work behavior。Target minimum-sufficient semantics由new planner輸出。

### F-35-2-03 — Ordinary feature/package不得再由target planner自動雙平台build

Severity：P1 acceptance。

Disposition：PASS。Planner tests證明single feature與leaf package均`affected`、`full_regression=false`、`android_build=false`、`ios_build=false`。

## Fresh focused re-review

Fresh command：

```powershell
python -m unittest tools.ci.test_change_classifier tools.ci.test_validation_planner
```

Result：

```txt
Ran 40 tests
OK
```

Coverage包含：

- docs focused；
- feature affected；
- leaf test focused；
- package reverse dependency propagation；
- Android-only／iOS-only native escalation；
- validation engine full；
- release full＋both platforms；
- unknown fail-safe；
- mixed known paths deterministic union；
- existing classifier range／manual／database contracts。

## Whole-Task review

- Classifier責任已能表達「改了什麼」。
- Planner責任表達「因此驗證什麼」。
- Workflow consumer尚未切換，避免同Task同時改decision engine與execution wiring。
- No network dependency。
- No third-party package。
- No Dart AST／coverage graph／global registry overbuild。
- Reverse dependency graph來源為tracked workspace metadata。
- Unknown／invalid range／graph parse failure保持full fail-safe。

Open P0：0。

Open P1 without disposition：0。

## Documentation authority check

Stable authority仍是accepted Design與ADR-023 current version；Task 35-2只建立implementation core，不提前修改ADR／Testing Governance／Guides。Human authority同步留給Task 35-5。

## Required validation

```txt
python -m unittest tools.ci.test_change_classifier tools.ci.test_validation_planner → PASS (40 tests)
python tools/docs/check_docs.py . → required PASS
git diff --check → required PASS
```

## Disposition

```txt
Task 35-2: ACCEPTED after fresh validation
Workflow cutover: NOT YET
Open P0: 0
Open P1 without disposition: 0
Next task: 35-3 Testing Inventory Tier Realignment
```

