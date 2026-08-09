---
document_type: phase-review
status: active
authoritative_for:
  - validation-planner-skill-governance-classification-sg-3-integrity-consumer-review
last_reviewed_baseline: 1.16.0
---

# SG-3 — Skill Integrity and Consumer Contract Review

## Purpose

證明SG-2只修正classification selection，existing Skill lock與runner consumer已足以承接`governance` plan，不需要擴大production mutation。

## Skill lock / docs contract evidence

```text
python -m unittest tools.docs.test_skill_lock tools.docs.test_check_docs
Ran 36 tests
OK
```

`tools.docs.test_skill_lock`另以verbose fresh run確認13個cases全部PASS，包含：

- `test_hash_drift_fails`
- `test_locked_license_hash_drift_fails`
- `test_missing_locked_file_fails`
- `test_missing_locked_license_fails`
- `test_unknown_file_in_locked_install_path_fails`
- `test_non_immutable_commit_fails`
- `test_install_path_escape_fails`
- `test_locked_file_path_escape_fails`
- `test_duplicate_install_path_fails`
- `test_invalid_json_fails_closed`
- `test_modified_third_party_cannot_masquerade_as_unmodified`
- valid locked unmodified Skill exemption PASS
- unlocked English Skill language failure contract PASS

因此locked Skill bytes／license／lock metadata不一致時，governance docs validation會在既有authority內fail closed，不需要classifier重複hash或schema logic。

## Consumer command evidence

對：

```text
.agents/skills/brandkit/SKILL.md
```

建立fixed classifier後的plan，再交給existing `validation_runner.commands_for_phase(..., "quality")`，fresh輸出：

```text
. :: <python> tools/docs/check_docs.py .
. :: <python> -m unittest discover -s tools/docs -p test_*.py
. :: git diff --check
```

這證明`governance` plan會同時執行docs checker與`tools/docs` contract suite。

## Scope review

No change required to:

```text
tools/ci/validation_planner.py
tools/ci/validation_runner.py
tools/docs/**
```

Planner既有`governance` handling與runner既有quality consumer已符合accepted Design；擴大production scope反而會形成無證據修改。

## Findings

```text
P0 = 0
P1 without disposition = 0
```

## Disposition

**PASS.** Skill integrity remains fail-closed under existing lock authority, and consumer routing needs no production change.
