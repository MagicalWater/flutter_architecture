---
document_type: phase-review
status: active
authoritative_for:
  - validation-planner-skill-governance-classification-sg-1-red-review
last_reviewed_baseline: 1.16.0
---

# SG-1 — Skill Governance Classification Contract RED Review

## Scope

Task SG-1只新增classifier／planner contract tests與review evidence，不修改production routing。

Modified tests：

```text
tools/ci/test_change_classifier.py
tools/ci/test_validation_planner.py
```

## RED execution

Command：

```text
python -m unittest tools.ci.test_change_classifier tools.ci.test_validation_planner
```

Observed：

```text
Ran 56 tests
FAILED (failures=7)
```

Expected missing-contract failures：

1. repository-authored `SKILL.md`：observed `docs_content`，expected `governance`。
2. repository-authored Skill reference：observed `docs_content`，expected `governance`。
3. third-party locked Skill：observed `docs_content`，expected `governance`。
4. `skills-lock.json`：observed `unknown`，expected `governance`。
5. `third_party/skills/taste-skill/LICENSE`：observed `unknown`，expected `governance`。
6. Skill＋ordinary docs mixed set：observed只有`docs_content`，expected `(docs_content, governance)`。
7. planner Skill route：observed`docs_content` plan，expectedfocused governance＋`tools/docs`。

## Negative controls

同一56-test run中既有unknown path、invalid range與classifier self-change tests沒有新增failure；新增`.agent-runtime/new-policy.bin` negative control亦保持`unknown`＋full fail-safe。

## Focused review

- RED failures全部直接對應accepted Design的known path coverage gap。
- 沒有透過修改expected值讓current behavior假裝GREEN。
- 沒有修改`change_classifier.py`、planner或runner production routing。
- Tests沒有把所有`.agents/**`或generic`third_party/**`泛化成known。

## Whole-Task review

SG-1已涵蓋repository-authored Skill、references、third-party locked Skill、lock、vendored provenance、mixed union、planner intent與unknown negative control。Existing invalid range／validation-engine tests保留原contract。

## Findings

```text
P0 = 0
P1 without disposition = 0
```

## Disposition

**PASS as expected RED.** Production routing仍未修改；下一Task SG-2才允許最小classifier GREEN。
