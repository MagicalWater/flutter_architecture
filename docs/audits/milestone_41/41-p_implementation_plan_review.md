---
document_type: planning-review
status: completed
authoritative_for:
  - milestone-41-implementation-plan-review
last_reviewed_baseline: 1.20.0
---

# Milestone 41 — Implementation Plan Review

## Review target

`docs/superpowers/plans/2026-08-18-milestone-41-pencil-layout-architecture-corrective.md`

Requirement：accepted。

Design：accepted / user approved 2026-08-18。

## Focused findings

### F-41-P-01 — 必須先有direct RED，不能先重構reference UI

- Severity：P1 if violated。
- Review：Task 41-1先證明current blind spot；Task 41-4才允許production migration。
- Result：PASS。

### F-41-P-02 — Detector不得退化成Positioned數量lint

- Severity：P1 false-positive／governance risk。
- Review：41-3要求偵測screen-level coordinate ownership組合語意，並明確保留bounded local overlay。
- Result：PASS。

### F-41-P-03 — Machine mapping不能建立第二visual authority

- Severity：P1 authority risk。
- Review：41-2只擴充initiative-local implementation evidence；`.pen`與visual manifest authority不變。
- Result：PASS。

### F-41-P-04 — Reference migration不能以降低fidelity換architecture GREEN

- Severity：P1 acceptance risk。
- Review：41-5固定既有threshold／projection／crop／ignore contract，失敗需修implementation或回Design。
- Result：PASS。

### F-41-P-05 — 不得全面禁止Stack / Positioned

- Severity：P1 overcorrection risk。
- Review：Plan保留bounded local overlay與approved spatial canvas；screen flow ownership才是禁止邊界。
- Result：PASS。

### F-41-P-06 — Authority sync必須晚於runtime truth

- Severity：P1 documentation-truth risk。
- Review：41-6排在reference migration與visual/runtime recovery後，不會先寫文件宣稱完成。
- Result：PASS。

### F-41-P-07 — Test scope不得重新走向test hell

- Severity：P1 governance cost risk。
- Review：direct owners聚焦mapping schema、architecture detector、existing visual owners與少量relationship fixture；明確禁止every-section/every-Positioned tests。
- Result：PASS。

### F-41-P-08 — Release不得預設跳過或預設強制

- Severity：P2 lifecycle risk。
- Review：41-8保留formal release decision；stable template behavior改變時預設發布，但允許有證據的no-release disposition。
- Result：PASS。

## Whole-Task review

Plan順序符合accepted Design：先讓blind spot形成direct RED，再建立layout-model machine contract與source detector，之後才遷移reference implementation；visual fidelity recovery早於authority synchronization，避免「文件先綠、runtime後補」。Pressure acceptance與holistic gate均保留，沒有把Milestone縮成local refactor。

沒有新增第二Pencil domain Skill、global node registry、generic Dart AST framework或every-node test expansion。`intentional-spatial-canvas`仍要求accepted approval，不形成implementation escape hatch。

## Current disposition

```txt
Plan artifact status: accepted
Plan review: PASS
User approval: REQUIRED / pending
Open P0: 0
Open P1 without disposition: 0
User approval: accepted on 2026-08-18
Implementation: admitted; Task 41-1 is next
```

下一個合法gate是使用者明確核准Plan；核准前不得開始Task 41-1或修改production source/tests作implementation。
