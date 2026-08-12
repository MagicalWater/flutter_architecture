---
document_type: planning-review
status: proposed
authoritative_for:
  - milestone-36-implementation-plan-review
last_reviewed_baseline: 1.16.0
---

# Milestone 36 — Implementation Plan Review

## Focused findings

### F-36-P-01 — Authoring policy與validation planner責任不可混合

Severity：P1。

Disposition：Resolved。Plan將Authoring correctness與Execution correctness分離，並禁止把`validation_planner.py`擴張成authoring engine。

### F-36-P-02 — Reference feature audit不可變成未核准大規模test cleanup

Severity：P1。

Disposition：Resolved。Task 36-6預設不刪test；真正duplicate仍需既有deletion governance，超出scope則重新Requirement Decision。

### F-36-P-03 — no-new-test不得成為critical-risk逃生門

Severity：P1。

Disposition：Resolved。Security、migration、persistence、concurrency與deterministic bug regression等Design-defined Required risk不得以`no-new-test justified`取代direct regression owner。

## Focused re-review

三項P1已由Plan文字直接封閉，沒有open P1。

## Whole-Task review

- Task sequence：RED → central policy → human Guides → Feature reference → behavioral acceptance → holistic/release，符合Design。
- 每個implementation Task維持雙層Task cycle與independent commit。
- Worktree只在Plan accepted後建立。
- 沒有新增第三套test selection authority。
- Test count／coverage percentage不是success KPI。

## Required validation

```txt
python tools\docs\check_docs.py .
git diff --check
```

## Disposition

```txt
Plan status: PROPOSED
Focused review: PASS after dispositions
Whole-Task review: PASS
Open P0: 0
Open P1 without disposition: 0
Implementation allowed: NO
Next gate: User approval of Implementation Plan
```
