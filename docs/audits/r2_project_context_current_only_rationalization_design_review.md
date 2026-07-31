---
document_type: planning-review
status: accepted
authoritative_for:
  - r2-project-context-current-only-rationalization-design-review
last_reviewed_baseline: 1.14.0
---

# R2 — Project Context Current-only Rationalization Design Review

## Scope

本Review審查R2 Design是否能在移除Milestone chronology時保全全部current capability、platform、security、CI與persistence facts，並維持current snapshot唯一authority。

## Baseline

```txt
Template Baseline: 1.14.0
Branch: audit/template-baseline-1.14-project-holistic
R1 closure commit: 0acb9f65bd290e1baa24b1b6ca60b5296cf2eb83
Finding owner: F-A7-02
Standing authorization: 2026-08-01
```

## Focused Findings

### F-R2-D01 — Mechanical deletion會遺失仍有效的current facts

- Severity：P1。
- Status：Resolved in Design。
- Observation：Milestone chronology同時承載iOS baseline、CI modes、artifact store、Drift與testing governance current facts。
- Fix：加入逐段preservation matrix及`Delivery and Verification`re-home contract；禁止只依`Milestone`關鍵字刪除。
- Fresh re-review：每個被刪除段落必須有current owner、historical route與verification。

### F-R2-D02 — `Active Work`命名會持續吸引completed journal

- Severity：P1。
- Status：Resolved in Design。
- Observation：目前section包含M26、M30、M31、M32完成歷史，與Active milestone None矛盾。
- Fix：替換為`Current Work and Maintenance State`，只允許active state、latest completed route與maintenance intake rule。
- Fresh re-review：禁止Task／commit／runtime count進入新section。

### F-R2-D03 — Full rewrite難以證明current claim保全

- Severity：P2。
- Status：Resolved in Design。
- Observation：從空白重寫會使reviewer難以追蹤每項security／platform claim去向。
- Fix：採section-by-section bounded rewrite，以matrix、before／after assertions與whole-document capability matrix驗證。
- Fresh re-review：Task R2-1先完成matrix，R2-2才可修改正文。

### F-R2-D04 — Standing authorization不可擴張為integration授權

- Severity：P2。
- Status：Resolved in Design。
- Observation：使用者允許自動推進remaining remediation，但未授權merge、push、remote deletion或release。
- Fix：Design明確限制standing authorization只覆蓋無新decision的R2治理鏈。
- Fresh re-review：integration仍保留獨立Gate。

## Whole-Design Review

- Requirement Decision採Level 3，符合current snapshot semantic architecture範圍。
- Design只處理`F-A7-02`，不吸收R3／R4／R5。
- Preservation matrix先於正文修改，可獨立接受或拒絕。
- Current fact re-home有明確section owner，不建立第二份policy或historical authority。
- Platform classification、security boundaries、current capabilities與CI contract都有semantic invariant。
- No ADR、no release、no runtime regression符合既有ownership未改變的事實。

## Approval Evidence

使用者於2026-08-01指示，除非出現需要其處理的決策，否則核准直接接著完成剩餘tasks。R2 Design沒有新增scope／architecture decision，因此本Review記錄standing authorization為明確approval evidence。

## Disposition

```txt
Focused review: PASSED after F-R2-D01～D04 fixes
Whole-Design review: PASSED
Open P0: 0
Open P1 without disposition: 0
Design status: ACCEPTED
Implementation allowed: NO — accepted Plan仍為必要hard gate
```
