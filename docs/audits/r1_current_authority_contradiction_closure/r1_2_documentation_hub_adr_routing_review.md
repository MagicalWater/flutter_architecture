---
document_type: phase-review
status: accepted
authoritative_for:
  - r1-2-documentation-hub-adr-routing-review
last_reviewed_baseline: 1.14.0
---

# R1-2 — Documentation Hub and ADR Routing Review

## Task Scope

本Task只修復`F-A1-02`：Documentation Hub前段把`docs/adr/README.md`與canonical ADR records列為Architecture Decision authority，Legacy段落卻把整個`docs/adr/`降級為placeholder。

Central finding仍維持Open，直到R1-4完成cross-document closure。

## Before Evidence

- Authority table：Architecture Decision由`docs/adr/README.md`與canonical ADR records擁有。
- Architecture task route：要求讀取`docs/adr/README.md`的相關ADR。
- Legacy段落：把整個`docs/adr/`稱為placeholder，與前述current contract直接矛盾。

## Implementation

- 移除把canonical ADR directory降級為placeholder的錯誤敘述。
- Legacy route只保留`docs/architecture/`與舊aggregate／明確標記legacy的相容路徑。
- 明確重申current Architecture Decision authority由`docs/adr/README.md`與canonical ADR records擁有。

## Focused Review

- Authority table與Legacy段落現在一致。
- Task-based Architecture route未變。
- ADR index、canonical ADR records與supersession graph未修改。
- 沒有建立平行ADR authority，也沒有批量採納legacy metadata。

## Validation Evidence

2026-08-01於R1隔離worktree fresh執行：

```txt
Canonical ADR authority assertion: PASSED
Canonical ADR directory not degraded: PASSED
Historical architecture route assertion: PASSED
Documentation unit tests: 19 passed
docs_check: PASSED
git diff --check: PASSED
```

## Whole-Task Review

- Documentation Hub仍只負責taxonomy與reading route，不保存Architecture Decision正文。
- 本Task沒有修改ADR records、Project Context、Roadmap、VERSION、CHANGELOG、source、tests、workflow或platform configuration。

## Current Disposition

```txt
Task status: ACCEPTED
Open Task P0: 0
Open Task P1 without disposition: 0
F-A1-02 implementation evidence: completed
Central finding status: Open
```
