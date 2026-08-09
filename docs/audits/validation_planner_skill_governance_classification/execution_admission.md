---
document_type: planning-review
status: active
authoritative_for:
  - validation-planner-skill-governance-classification-execution-admission
last_reviewed_baseline: 1.16.0
---

# Validation Planner — Skill Governance Path Classification Execution Admission

## Accepted authority

- Requirement Decision：`docs/audits/validation_planner_skill_governance_classification_requirement_decision.md`
- Accepted Design：`docs/superpowers/specs/2026-08-10-validation-planner-skill-governance-classification-corrective-design.md`
- Accepted Plan：`docs/superpowers/plans/2026-08-10-validation-planner-skill-governance-classification-corrective.md`
- User Plan approval：2026-08-10

## Git / worktree admission

```text
Planning base commit: 5aef843aacd8c92a40d378b2775154d7a22df022
Published origin/main at admission: 6ef1b7d6370097920c4281933558684639f970ac
Managed worktree: C:\Users\crazy\.devspace\worktrees\flutter_architecture-skill-gov
Branch: corrective/skill-governance-validation-classification
Worktree initial state: clean
```

`5aef843`是已通過focused validation且含accepted Design／Plan的planning commit；implementation branch以此commit為唯一base。`origin/main`尚未包含planning commit，因此implementation不得假裝published-main已同步，merge／push／release disposition留待SG-4後處理。

## Allowed implementation scope

Primary production mutation：

```text
tools/ci/change_classifier.py
```

Planned tests／evidence：

```text
tools/ci/test_change_classifier.py
tools/ci/test_validation_planner.py
docs/audits/validation_planner_skill_governance_classification/**
```

只有fresh evidence證明consumer contract存在缺口時，才可依accepted Design最小擴至`validation_planner.py`、`validation_runner.py`或`tools/docs/**`，並必須記錄finding與re-review。

## Forbidden scope

- Flutter production source／tests。
- Generated source。
- Android／iOS runner、Gradle、Xcode config。
- 新change class或第二份path-selection engine。
- 放寬真正unknown、invalid range或validation-engine fail-safe。
- 修改任何Skill內容本身。

## Admission disposition

```text
Design accepted: YES
Plan accepted: YES
Managed worktree: YES
Dedicated branch: YES
Initial worktree clean: YES
Production implementation allowed: YES, beginning with SG-1 RED only
```
