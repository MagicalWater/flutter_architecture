---
document_type: phase-review
status: accepted
authoritative_for:
  - milestone-35-task-35-5-validation-governance-authority
last_reviewed_baseline: 1.15.2
---

# Task 35-5 — ADR-023 and Human/Agent Authority Synchronization Review

## Scope

本Task把Tasks 35-2～35-4已驗證的machine behavior同步至stable ADR與human／Agent current authority；不再修改planner routing semantics。

Modified authority：

- `docs/adr/adr-023-repository-ci-quality-gates-android-verification-artifact.md`
- `docs/guides/testing_governance.md`
- `AGENTS.md`
- `docs/guides/how-to-add-feature.md`
- `docs/guides/agent_assisted_development_quick_start.md`
- `docs/guides/ci_cd_operations.md`
- `docs/governance/development_workflow.md`

Policy regression：

- `tools/docs/test_validation_selection_policy.py`

## Stable authority amendment

ADR-023現在正式擁有：

- Minimum Sufficient Validation stable principle。
- classifier負責change classes、planner負責validation selection的ownership split。
- workspace dependency graph reverse propagation。
- ordinary feature／leaf package不自動雙平台build。
- unknown／invalid／graph／planner failure full fail-safe。
- holistic／manual full／release／post-release fresh full regression。
- same-Task evidence reuse只在plan identity與selected inputs未變時成立。

沒有新增平行ADR；ADR-023仍是CI quality gate與change-aware validation stable decision owner。

## Testing Governance current alignment

`docs/guides/testing_governance.md`：

- `last_reviewed_baseline`更新至1.15.2。
- 明確區分execution tier與validation level。
- current inventory指向Milestone 35 `35-3_current_test_inventory.csv`。
- Milestone 30 inventory明確標記historical，不覆寫。
- documented route為focused → affected → workspace → full → release。

## Agent / Feature guide correction

`AGENTS.md`原本commit checklist固定要求：

```txt
dart run melos run analyze
dart run melos exec -- flutter test
```

不論change boundary都執行。Current wording改為先取得planner plan並執行returned scopes；full suite只在planner／holistic／manual full／release／post-release要求時執行。

`how-to-add-feature.md`同步移除一般Feature固定full workspace command block，改用planner affected routing。

## Focused review findings

### F-35-5-01 — Current policy沒有mechanical guard防止full-test wording回歸

Severity：P1。

Disposition：Resolved。新增`tools/docs/test_validation_selection_policy.py`，鎖定single planner authority、AGENTS不得回復每commit full test、Feature Guide affected routing、Testing Governance current baseline／inventory與tier-level separation。

### F-35-5-02 — Guide不得複製完整path routing matrix

Severity：P1 authority guard。

Disposition：PASS。Guides只描述planner入口、levels與fail-safe；canonical change-class routing仍由machine planner與accepted Design／ADR stable semantics擁有。

### F-35-5-03 — ADR gate應修訂ADR-023而非新增Decision

Severity：P1。

Disposition：PASS。ADR index不新增ID；ADR-023 amendment完成，避免parallel stable authority。

## Fresh focused re-review

```powershell
python -m unittest tools.docs.test_validation_selection_policy
```

Result：4 tests PASS。

Full docs policy regression：

```powershell
python -m unittest discover -s tools/docs -p "test_*.py"
```

Result：52 tests PASS。

Repository docs gate：

```powershell
dart run melos run docs_check
```

Result：PASS。

## Whole-Task review

- Stable ADR、Testing Governance、AGENTS、Feature Guide、Quick Start與CI Operations全部指向single planner。
- Double-layer Task governance仍決定「何時需要validation」，planner決定「validation scope」。
- Full regression仍存在且在holistic／release boundaries fresh執行。
- 沒有把test deletion、coverage reduction或nightly-only寫入current authority。
- Historical Milestone 30 evidence保持不變。

Open P0：0。

Open P1 without disposition：0。

## Required validation

```txt
python -m unittest tools.docs.test_validation_selection_policy → PASS (4)
python -m unittest discover -s tools/docs -p "test_*.py" → PASS (52)
python tools/docs/check_docs.py . → PASS
dart run melos run docs_check → PASS
git diff --check → required PASS before commit
```

## Disposition

```txt
Task 35-5: ACCEPTED after fresh validation
Stable authority owner: ADR-023
Single machine selection owner: tools/ci/validation_planner.py
Open P0: 0
Open P1 without disposition: 0
Next task: 35-6 Evidence Reuse and Duplicate Full-Run Guard
```

