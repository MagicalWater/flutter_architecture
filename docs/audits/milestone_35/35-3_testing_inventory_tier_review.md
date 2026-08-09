---
document_type: phase-review
status: accepted
authoritative_for:
  - milestone-35-task-35-3-testing-inventory-tier-review
last_reviewed_baseline: 1.15.2
---

# Task 35-3 — Testing Inventory Tier Realignment Review

## Scope

本Task只修正machine-readable execution tier classification並建立Milestone 35 current inventory evidence；不刪test、不改test ownership、不覆寫Milestone 30 historical CSV。

## Tier contract

Implementation對齊current Testing Governance：

```txt
Tier 1 → Python／docs／inventory／quick tooling contracts
Tier 2 → feature／package Flutter regression與current integration
Tier 3 → generated／schema／migration／rollback／Web asset consistency
Tier 4 → native scaffold／platform build contracts
Tier 5 → device／remote／post-release evidence，不由一般test-file inventory代表
```

Historical migration／rollback tests保留historical ownership，但execution tier改為Tier 3，不再誤標Tier 4。

## Focused review findings

### F-35-3-01 — Generic Python tooling initially became `Unclassified`

Severity：P1。

First current inventory after realignment：

```txt
Tier 2: 124
Tier 1: 20
Tier 3: 11
Tier 4: 7
Unclassified: 2
```

Unclassified paths：

```txt
tools/testing/test_test_inventory.py
tools/visual/test_verify_visual_authority.py
```

Disposition：Resolved。Design已明確把Python contracts歸Tier 1；因此generic `tools/**/*.py` test在沒有更高Tier signal時歸Tier 1。Fresh inventory無Unclassified。

### F-35-3-02 — Execution tier不得覆蓋taxonomy／owner

Severity：P1 design guard。

Disposition：PASS。`primary_category`、`coverage_owner`、`implementation_classification`維持既有責任；本Task只修`execution_tier`。

## Fresh validation

```powershell
python -m unittest tools.testing.test_test_inventory
```

Result：

```txt
Ran 11 tests
OK
```

Current inventory command：

```powershell
python tools/testing/inventory.py --output docs/audits/milestone_35/35-3_current_test_inventory.csv
```

Fresh output：

```txt
files=164
loc=28048
cases=981

Tier 1: 22
Tier 2: 124
Tier 3: 11
Tier 4: 7
Unclassified: 0
```

相較admission的`Tier 1: 157 / 163`，machine tier現在重新具有routing value。File／LOC／case數增加來自Milestone 35新增planner tests，本Task沒有以減少test數作成功指標。

## Historical evidence boundary

未修改：

`docs/audits/milestone_30/30-2_test_inventory.csv`

Current evidence唯一寫入：

`docs/audits/milestone_35/35-3_current_test_inventory.csv`

## Whole-Task review

- Feature／package Dart tests不再默認Tier 1。
- Migration／schema owners有Tier 3。
- Native／platform owners有Tier 4。
- Generic Python contracts為Tier 1。
- 沒有Unclassified silent fallback。
- Historical／current ownership仍分離。

Open P0：0。

Open P1 without disposition：0。

## Required validation

```txt
python -m unittest tools.testing.test_test_inventory → PASS (11 tests)
python tools/testing/inventory.py --output docs/audits/milestone_35/35-3_current_test_inventory.csv → PASS
python tools/docs/check_docs.py . → required PASS
git diff --check → required PASS
```

## Disposition

```txt
Task 35-3: ACCEPTED after fresh validation
Historical M30 inventory modified: NO
Open P0: 0
Open P1 without disposition: 0
Next task: 35-4 CI and Local Consumer Cutover
```

