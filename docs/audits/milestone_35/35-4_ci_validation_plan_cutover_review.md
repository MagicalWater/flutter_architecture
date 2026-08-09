---
document_type: phase-review
status: accepted
authoritative_for:
  - milestone-35-task-35-4-ci-validation-plan-cutover
last_reviewed_baseline: 1.15.2
---

# Task 35-4 — CI and Local Consumer Cutover Review

## Scope

本Task把CI與local planning consumer從legacy binary `full_ci` selection切換為Task 35-2的single validation planner；stable job names、execution modes、artifact ownership與platform workflow boundaries保留。

主要files：

- `.github/workflows/ci.yml`
- `.github/workflows/android.yml`
- `.github/workflows/ios.yml`
- `tools/ci/validation_planner.py`
- `tools/ci/validation_runner.py`
- `tools/ci/run_local_ci.sh`
- affected `tools/ci/test_*.py`

## Cutover contract

### Single machine plan

`validation_planner.py`現在可由CLI對Git range輸出serialized plan與GitHub outputs：

```txt
plan_b64
validation_level
requires_flutter
has_flutter_tests
docs_check
generated_check
android_build
ios_build
release_full
fail_safe
reason
```

Workflow只消費上述plan，不再在YAML判斷path class。

### CI jobs

- `CI / Quality`：使用`validation_runner.py --phase quality`執行docs／Python／analyze scopes。
- `CI / Generated Consistency`：只在`generated_check=true`執行。
- `CI / Tests`：依`has_flutter_tests`執行planned Flutter scopes。
- Android／iOS workflows：改由validation planner輸出的platform flags決定build。
- Stable job names保持不變；docs／no-test情境仍建立required job並明確skip/no-op。

### Local parity

`tools/ci/run_local_ci.sh plan-range <base> <head>`直接呼叫同一`validation_planner.py`，沒有local-only path routing table。

## Focused review findings

### F-35-4-01 — Existing workflow tests仍要求YAML硬編碼unittest module list

Severity：P1 authority drift。

Initial Task 35-4 RED：25 focused workflow tests中9 failures；cutover後剩餘failures主要來自舊tests要求`ci.yml`直接保存`python3 -m unittest ...`與特定module名稱。

Disposition：Resolved。Tests改驗證single planner／runner wiring、stable job names、fail-safe與platform flags；不把parallel module list塞回YAML。

### F-35-4-02 — Planner direct-script execution無repository import root

Severity：P1 runtime blocker。

First local parity command：

```powershell
python tools/ci/validation_planner.py --event push --base c5d6127 --head 5af03e0 --repository . --stdout-json
```

Observed：`ModuleNotFoundError: No module named 'tools'`。

這代表unit-test import雖GREEN，但GitHub workflow的direct script invocation會失敗並永遠走full fail-safe。

Disposition：Resolved。Planner與runner在direct-script mode顯式加入repository root至`sys.path`；新增subprocess CLI tests。Fresh direct invocation PASS。

### F-35-4-03 — Python executable portability

Severity：P2。

`validation_runner.py`初版生成literal `python`命令，可能與啟動runner的Python不一致。

Disposition：Resolved。Python commands使用`sys.executable`；workflow仍可使用已存在的`python3`入口啟動runner。

### F-35-4-04 — Artifact／iOS／Observability contracts仍綁定舊YAML command strings

Severity：P2。

Fresh full CI Python discovery第一次有3 failures，皆為tests要求Quality YAML直接列出舊unittest commands。

Disposition：Resolved。Contracts改驗證validation runner full-plan discovery與各專屬workflow自身仍保有必要module／security contract；fresh full CI contracts全GREEN。

## Fresh local parity evidence

Direct planner：

```powershell
python tools/ci/validation_planner.py --event push --base c5d6127 --head 5af03e0 --repository . --stdout-json
```

PASS；真實range輸出：

```txt
change_classes = docs_content, tooling, test_only
validation_level = focused
full_regression = false
android_build = false
ios_build = false
fail_safe = false
```

Windows Git Bash local entrypoint：

```powershell
"C:\Program Files\Git\bin\bash.exe" tools/ci/run_local_ci.sh plan-range c5d6127 5af03e0
```

PASS，輸出與direct planner一致。

`test_validation_runner.py`另以direct subprocess `--dry-run`驗證plan transport與runner command generation；feature scope會轉為：

```txt
cwd: apps/flutter_architecture
flutter test test/features/profile
```

不是full workspace Flutter regression。

## Fresh focused / whole-Task validation

```powershell
python -m unittest discover -s tools/ci -p "test_*.py"
```

Result：

```txt
Ran 227 tests
OK
```

另外：

```txt
python tools/docs/check_docs.py . → PASS
git diff --check → PASS
```

## Whole-Task review

- Planner是path→validation decision唯一machine authority。
- Runner只把plan轉為commands，不重新判斷path class。
- CI YAML只消費plan outputs。
- Local `plan-range`使用同一planner。
- Ordinary feature／package plan不再自動雙平台build。
- Planner／serialization／direct-script failure會fail closed或使job失敗，不會靜默skip。
- Unknown／invalid range仍full fail-safe。
- Stable required check names未改。
- Artifact store與execution-mode contracts仍由既有tests保護。

Open P0：0。

Open P1 without disposition：0。

## Documentation authority check

本Task只切machine consumer。ADR-023、Testing Governance、AGENTS與Guides尚未宣稱新contract；其current authority同步由Task 35-5負責。

## Disposition

```txt
Task 35-4: ACCEPTED
CI planner cutover: PASS
Windows local plan-range parity: PASS
CI Python contracts: 227/227 PASS
Open P0: 0
Open P1 without disposition: 0
Next task: 35-5 ADR-023 and Human/Agent Authority Synchronization
```

