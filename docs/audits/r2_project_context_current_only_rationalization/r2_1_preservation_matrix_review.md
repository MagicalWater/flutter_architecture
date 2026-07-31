---
document_type: phase-review
status: accepted
authoritative_for:
  - r2-preservation-matrix-review
last_reviewed_baseline: 1.14.0
---

# R2-1 — Preservation Matrix Review

## Scope

本Task只建立Project Context chronology的preservation matrix，不修改`docs/project_context.md`。

## RED Inventory

```txt
Pre-change blob: 1df9bf60cf0e91a539a7465f1c2b0addee8815dc
Milestone-prefixed paragraphs: 13
Release chronology matches: 8
Exact evidence terms: 12
```

RED成立：current-only snapshot確實含大量Milestone／release／exact evidence history，並非只靠人工印象判定。

## Focused Findings

### F-R2-1-01 — CI chronology同時含current contract與歷史來源

- Severity：P1。
- Status：Resolved in Matrix。
- Fix：P04／P07／P11分別把execution modes、observability boundary與managed artifact store歸位至Delivery and Verification等current owners；只移除Milestone來源與runtime evidence。
- Fresh re-review：三種execution modes與managed store都有explicit verification。

### F-R2-1-02 — iOS paragraph不能整段刪除

- Severity：P1。
- Status：Resolved in Matrix。
- Fix：P05把iOS 15.0、Supported claim與deferred boundary歸位至Platform／Security，歷史build過程移至M25／M27 evidence。
- Fresh re-review：iOS current facts列入Must remain checklist。

### F-R2-1-03 — Active Work的deferred boundary仍是current fact

- Severity：P2。
- Status：Resolved in Matrix。
- Fix：P15標記Re-home至Security；禁止隨M26／M30／M31／M32 journal一起移除。
- Fresh re-review：production signing／Store／Branch Protection仍有current owner。

## Whole-Task Review

- 15個paragraph groups全部有classification、current owner、historical route與verification。
- 所有`Remove`列都不含無替代owner的current fact。
- Matrix沒有修改Roadmap、ADR、CHANGELOG或historical evidence正文。
- R2-2可逐列執行，無需猜測刪除範圍。

## Validation

```txt
Matrix row assertions: PASSED — P01～P15
Current facts without owner: 0
Project Context pre-change blob: 1df9bf60cf0e91a539a7465f1c2b0addee8815dc
Project Context current blob: 1df9bf60cf0e91a539a7465f1c2b0addee8815dc
Documentation unit tests: 19 passed
docs_check: PASSED
git diff --check: PASSED
```

## Disposition

```txt
Focused review: PASSED after three findings
Whole-Task review: PASSED
Open P0: 0
Open P1 without disposition: 0
R2-2 allowed: YES after fresh validation and independent commit
```
