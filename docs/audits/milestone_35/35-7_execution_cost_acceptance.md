---
document_type: phase-review
status: accepted
authoritative_for:
  - milestone-35-task-35-7-execution-cost-acceptance
last_reviewed_baseline: 1.15.2
---

# Task 35-7 — Before/After Routing and Execution-Cost Acceptance

## Scope

本Task驗證Milestone 35核心claim：低風險變更由deterministic planner選出Minimum Sufficient Validation，而高風險／unknown／release仍維持full fail-safe。

Evidence：

- `35-7_routing_measurements.json`：14個固定routing scenario。
- `35-7_wall_clock_measurements.json`：single feature、single test、representative package、full regression的fresh Windows wall-clock。
- `tools/ci/benchmark_validation_routing.py`：deterministic measurement harness。
- `tools/ci/test_benchmark_validation_routing.py`：corpus／routing acceptance contracts。

## Admission comparison baseline

Milestone 35 admission於Template 1.15.2記錄：

```txt
163 test files
27,781 LOC
961 static cases
full melos Flutter tests ≈ 34.42s
single 6-case widget test ≈ 14.02s
```

Task 35-3 current inventory為164 files／28,048 LOC／981 cases。測試量沒有被刪減以換取速度。

## Routing acceptance

14個固定scenario全部產生deterministic plan。代表結果：

| Scenario | Before | After | Platform escalation |
|---|---|---|---|
| docs-only | full CI | focused docs/governance | none |
| single feature | full CI + Android + iOS | affected feature tests + app analyze | none |
| single test | full CI | changed test only | none |
| leaf package | full CI + Android + iOS | package + true reverse-dependent workspace tests | none |
| app shared | full CI + Android + iOS | app workspace | none |
| tooling | full CI | focused tooling | none |
| database | full CI + Android + iOS | app workspace + generated + both platforms | Android + iOS |
| Android native | full CI + Android | platform contract | Android only |
| iOS native | full CI + iOS | platform contract | iOS only |
| dependency | full CI + both | full | Android + iOS |
| validation engine | full CI | full | Android + iOS |
| unknown | fail-safe full | fail-safe full | Android + iOS |
| release | release full | release full | Android + iOS |

Mixed governance + package changes取union並依最高風險升級；不會因docs path存在而把已知package誤判unknown。

## Fresh wall-clock measurement

同一Windows managed worktree、同一toolchain、fresh command執行：

| Case | Selected command | Wall-clock | Result |
|---|---|---:|---|
| single feature | `flutter test test/features/profile` | 15.835s | PASS, 18 cases |
| single test | `flutter test .../profile_view_test.dart` | 5.836s | PASS, 4 cases |
| design_system affected package | filtered Melos: app + design_system | 55.726s | PASS |
| full regression | `dart run melos exec -- flutter test` | 44.887s | PASS |

Single feature相對同輪full約減少64.7% wall-clock；single test約減少87.0%。這些改善來自scope reduction，不是刪除tests。

### Flutter startup fixed cost

結果再次證明Flutter process啟動／dependency resolution／test loading存在顯著固定成本，因此case count不是wall-clock的線性proxy。Admission的single widget≈14.02s與本輪single test 5.836s也顯示machine load與warm state會造成波動；因此本Milestone同時保存routing command／scope與wall-clock，不以單次秒數作唯一acceptance。

## Focused findings

### F-35-7-01 — Single-test benchmark fixture stale

Severity：P2 harness。

第一輪fixture使用不存在的`profile_page_test.dart`，正確得到exit 1。

Disposition：Resolved。改為tracked `presentation/pages/profile_view_test.dart`，fresh measurement 4 cases PASS／5.836s。

### F-35-7-02 — Sequential affected workspace execution比full regression更慢

Severity：P1 cost。

第一輪`design_system` route依序執行App與package tests，65.455s，慢於同輪full 58.832s。

Disposition：Resolved at execution layer。`validation_runner.py`將多個完整workspace test scopes合併成一次filtered Melos invocation，保留相同selected workspaces並使用Melos concurrency；fresh result降至55.726s。

### F-35-7-03 — Representative package仍不保證Flutter wall-clock低於full

Severity：P2 accepted trade-off。

Fresh filtered package route 55.726s仍高於同輪full 44.887s。原因不是routing hole：`flutter_architecture`確實直接依賴`design_system`，而App 493-case suite本身佔主要成本；full workspace其餘packages可與App並行，額外wall-clock有限。

Disposition：Accepted。Milestone 35保留dependency-graph conservative boundary，不以移除真實reverse-dependent App coverage換速度；該route仍移除不相關package selection與原先Android＋iOS build escalation。進一步source→test impact graph／AST mapping屬accepted Design non-goal，需獨立Requirement Decision。

## Coverage-hole proof

- Canonical change classes均有scenario owner。
- Package route使用tracked workspace reverse dependency graph，不使用手寫consumer table。
- Unknown path與invalid range保持full fail-safe。
- Validation engine自我變更保持full。
- Database／generated／native／dependency／release escalation有positive tests。
- Android native不錯誤要求iOS；iOS native不錯誤要求Android。
- Release仍fresh full＋both platforms。
- 本Task沒有刪除任何existing deterministic test。

## Fresh regression

```txt
python -m unittest tools.ci.test_validation_runner tools.ci.test_benchmark_validation_routing → PASS (11)
python -m unittest discover -s tools/ci -p "test_*.py" → PASS (238)
python tools/docs/check_docs.py . → PASS
git diff --check → PASS
```

## Whole-Task review

Open P0：0。

Open P1 without disposition：0。

結論：Milestone 35已證明最常見small feature／single-test paths有實際wall-clock下降；package path則誠實保留reverse-dependent coverage，即使特定workspace分布使Flutter-only wall-clock不一定下降。這不影響核心acceptance，因原先不必要的full selection與雙平台build已被移除，且高風險fail-safe未弱化。

## Disposition

```txt
Task 35-7: ACCEPTED
Coverage weakened: NO
Tests deleted for speed: NO
Low-risk routing cost reduced: YES
Unknown/release fail-safe retained: YES
Open P0: 0
Open P1 without disposition: 0
Next task: 35-8 Holistic Final Review and Template Baseline Release
```
