---
document_type: phase-review
status: accepted
authoritative_for:
  - milestone-28-task-28-3-review
last_reviewed_baseline: 1.9.0
---

# Task 28-3 — Lifecycle and Transition Coordination Review

## Scope

- App-owned ConnectivityController。
- Subscribe-before-snapshot、distinct、reconnect與resume recheck。
- App lifecycle與dispose wiring。

## Findings and disposition

### F1 — 啟動snapshot可能覆蓋較新的stream event

Disposition：controller使用observation revision；snapshot只在等待期間沒有較新event時套用。

### F2 — `unknown → online`可能誤觸發reconnect

Disposition：reconnect只由明確`offline → online`發布，contract tests覆蓋initial resolution。

### F3 — Resume短時間多次觸發可能形成重複snapshot

Disposition：`recheck()`使用single-flight；相同state再由distinct抑制。

### F4 — Provider exception可能被誤標為offline

Disposition：snapshot／stream error與stream done均降級為`unknown`，不清Session、不產生reconnect。

## Holistic result

- Controller不依賴Feature、Dio、Router或backend probe。
- ArchitectureApp仍是唯一WidgetsBindingObserver owner。
- Existing local unlock resume流程保持獨立。
- Dispose取消subscription並dispose adapter。

## Validation

```txt
Controller focused tests: pass
Local unlock lifecycle regression: pass
Analyze: pass
Open P0: 0
Open P1 without disposition: 0
```

Task 28-3 accepted，可進入Task 28-4。
