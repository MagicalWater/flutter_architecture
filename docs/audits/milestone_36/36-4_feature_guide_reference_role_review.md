---
document_type: phase-review
status: accepted
authoritative_for:
  - milestone-36-task-36-4-feature-guide-reference-role
last_reviewed_baseline: 1.16.0
---

# Task 36-4 — Feature Guide and Reference-Role Corrective

## Scope

更新Feature Guide與AI Agent Quick Start，消除「Feature有幾層就每層建立tests」與「參考Auth／Catalog test密度」的制度性誘因。

## Review

- Feature Guide改為risk／failure owner → Test Authoring Disposition，不再列逐層minimum quota。
- Auth／Catalog／Profile等Feature明確是architecture／owner reference，不是test-density reference。
- Quick Start不再無條件寫「必須補測試」，而是要求authoring decision。
- TDD仍保留，但只為direct regression owner建立最小充分evidence。
- `starting-feature-work`維持薄入口，沒有必要複製四種disposition，因此未修改。

Open P0：0。
Open P1 without disposition：0。

## Validation

```txt
python -m unittest tools.docs.test_test_authoring_governance
→ PASS (5/5)

python tools\docs\check_docs.py .
→ PASS

git diff --check
→ PASS
```

Task 36-4：ACCEPTED。
