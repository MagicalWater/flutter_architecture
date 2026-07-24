---
document_type: phase-review
status: accepted
authoritative_for:
  - milestone-31-checker-recovery-review
last_reviewed_baseline: 1.13.0
---

# Task 31-R7 — Documentation Checker Recovery Review

## Scope

- `tools/docs/check_docs.py`
- `tools/docs/test_check_docs.py`
- Historical checker from commit `3eeff5d`

## RED evidence

The historical checker was loaded from Git without modifying the working tree and executed against two isolated fixtures.

### Agent Skill frontmatter fixture

```txt
OLD_SKILL_CODES = ['invalid-metadata']
```

The old checker treated standard Agent Skill `name`／`description` frontmatter as incomplete managed-document metadata.

### Stale active routing fixture

```txt
OLD_ROUTING_CODES = []
```

The old checker failed to detect an active routing row marked `Local release complete; post-release pending` while `active.md` declared `None`.

## GREEN evidence

The current checker was run against the same fixture shapes.

```txt
CURRENT_SKILL_CODES = []
CURRENT_ROUTING_CODES = ['stale-milestone-routing']
```

Current behavior therefore preserves Agent Skill frontmatter and catches stale milestone routing.

## Focused review findings

- P1：原始Task只有最終17 tests pass摘要，沒有證明fixtures在舊實作上真的失敗。Resolved：使用Git歷史checker執行相同fixture並保存actual codes。
- P1：active routing parsing曾誤把closed milestone rows納入檢查。Resolved by commit `471d9c1`; current repository integration check passes while isolated stale fixture remains detected。

## Whole-task review

- Agent Skill exclusion only applies to `.agents/skills/**/SKILL.md` and does not disable managed-document metadata checks elsewhere.
- Stale routing detection is scoped to `## Active routing` and does not treat closed history as active state.
- Duplicate routing detection remains covered by unit tests.
- Checker still uses Python standard library only.

## Fresh validation

```txt
python3 -m unittest tools.docs.test_check_docs
→ 17 passed

dart run melos run docs_check
→ passed

git diff --check
→ passed
```

Open P0 = 0；Open P1 without disposition = 0。Task 31-R7 accepted。
