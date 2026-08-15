---
document_type: phase-review
status: accepted
authoritative_for:
  - milestone-39-task-39-4-wrong-representation-recovery
last_reviewed_baseline: 1.19.0
---

# Milestone 39 — Task 39-4 Wrong-Representation Recovery & Skill Review

## Scope

本Task把wrong source／asset／icon／representation從「應回頭處理」升級成正式invalid mapping recovery route，並新增PTF-19～PTF-25 pressure scenarios。

## Test Authoring Decision

Policy wording regression owner：**Required**，因Skill routing增加新的hard-stop/recovery invariant；只在既有policy test增加一個semantic contract，不建立新的大型static test suite。Behavioral effectiveness由Task 39-5 fresh independent contexts擁有，keyword GREEN不能取代behavioral acceptance。

## Focused review

### F-39-4-01 — Main Skill必須保持thin orchestration
- Severity：P1。
- Review：Skill只增加一個ordering/recovery step與禁止事項；schema/checker細節仍留references/tools。
- Result：PASS。

### F-39-4-02 — Invalid mapping不得繼續pixel tuning
- Severity：P1 confirmed failure。
- Review：padding／scale／crop／offset／opacity／threshold tuning全部明文禁止作為invalid mapping recovery。
- Result：PASS。

### F-39-4-03 — Authority change必須回中央gate
- Severity：P1。
- Review：若accepted `.pen`／Design需改，route回Requirement／Design；implementation不可修改authority迎合candidate。
- Result：PASS。

### F-39-4-04 — Pressure scenarios需涵蓋七類residual failure
- Severity：P1 behavioral coverage。
- Review：PTF-19～25涵蓋critical omission、same-name cross-library icon、existing asset redraw、runtime geometry mismatch、global/local conflict、invalid tuning、unauthorized deviation。
- Result：PASS。

## Current disposition

```txt
Task: implementation complete / validation pending
Representation/recovery policy: 8/8 PASS
Single-renderer policy: 5/5 PASS
Mapping/fidelity machine tests: 14/14 PASS
docs_check: PASS
git diff --check: PASS
Open P0: 0
Open P1 without disposition: 0
Behavioral acceptance: deferred to Task 39-5 by Plan ownership
```

## Whole-Task review

Recovery contract只撤銷受影響mapping與visual acceptance，不要求無關Task重做；Main Skill仍維持thin orchestration。PTF-19～25只是behavioral contract，尚未以本對話自審宣稱behavioral PASS，Task 39-5仍必須使用fresh independent context。
