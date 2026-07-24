---
document_type: planning-review
status: accepted
authoritative_for:
  - connectivity-offline-state-plan-review
last_reviewed_baseline: 1.9.0
---

# Connectivity and Offline State Foundation Plan Review

## Review target

- Design Spec：`docs/superpowers/specs/2026-07-24-connectivity-offline-state-foundation-design.md`
- Implementation Plan：`docs/superpowers/plans/2026-07-24-milestone-28-connectivity-offline-state-foundation.md`

## Focused findings and disposition

### F1 — Plan可能在Task 28-2過早引入plugin type

Disposition：adapter mapping tests與file map均要求plugin type只存在`connectivity_plus_adapter.dart`及其focused test；contract、Feature與packages不得引用。

### F2 — Controller startup race缺少可驗證步驟

Disposition：Task 28-3明列可控snapshot completer、stream event與generation tests，並要求subscribe-before-snapshot。

### F3 — App-wide banner可能取代Feature failure

Disposition：Task 28-4只依typed state顯示offline context；Task 28-5仍保留Catalog typed Failure與獨立reconnect failure。

### F4 — Catalog reconnect與manual refresh可能共用錯誤state

Disposition：Plan要求新增獨立`isReconnectRevalidating`與`reconnectFailure`，且manual refresh具最高priority。

### F5 — Runtime evidence可能被build evidence替代

Disposition：Task 28-7分開artifact build與Android／iOS runtime smoke，並要求記錄限制與disposition。

### F6 — Release可能在Task 28-8提前宣稱完成

Disposition：Task 28-8僅為release readiness；VERSION、archive、push與post-release validation保留給Milestone holistic final review。

## Whole-plan review

- Spec每個goal均有對應Task。
- Non-goals沒有被任何Task重新引入。
- Task 28-1～28-8各自具有files、tests、commands、review與commit boundary。
- Generated files只透過build_runner／gen_l10n更新。
- Production source gate明確位於Plan通過之後。
- 沒有`TBD`、`TODO`或未處置核心架構選項。

## Authority check

- Spec擁有設計。
- Plan擁有執行順序。
- ADR-027將擁有穩定architecture contract。
- Task review保存findings與evidence，不取代current authority。

## Result

```txt
Open P0: 0
Open P1 without disposition: 0
Plan status: Accepted
Production implementation gate: Open
```

Implementation Plan通過完整Task審查循環，可直接開始Task 28-1。
