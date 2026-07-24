---
document_type: phase-review
status: accepted
authoritative_for:
  - milestone-28-task-28-5-review
last_reviewed_baseline: 1.9.0
---

# Task 28-5 — Catalog Reconnect Integration Review

## Scope

- Catalog reconnect event、operation state與failure。
- Page-visible opt-in subscription。
- Manual refresh、query generation與append ordering。

## Findings and disposition

### F1 — Reconnect若共用`isRefreshing`會誤顯示user operation

Disposition：新增獨立`isReconnectRevalidating`與`reconnectFailure`，不觸發pull-to-refresh lifecycle。

### F2 — Reconnect結果可能覆蓋新query

Disposition：沿用`_searchGeneration`與query equality；query change會取消reconnect request。

### F3 — Manual refresh與reconnect可能同時replacement第一頁

Disposition：manual refresh開始前取消reconnect，manual進行中忽略reconnect；reconnect期間阻擋append與重入。

### F4 — Feature可能直接依賴plugin

Disposition：Catalog Page只依`ConnectivityScope`與provider-neutral reconnect stream，沒有plugin import。

### F5 — 第一輪落檔未同步既有`CatalogState`測試建構器

Disposition：補齊widget test helper的新欄位，並在focused suite中確認所有既有Catalog presentation tests可編譯與通過。

### F6 — 第一輪review文件早於實際測試證據

Disposition：補入Bloc ordering與non-blocking widget tests後重新執行完整focused suite；本文件的accepted狀態以重新驗證結果為準。

## Holistic result

- Repository仍擁有refresh policy、cache write、TTL與Remote／Local coordination。
- Reconnect failure保留既有items並使用non-blocking localized surface。
- Success replacement重設append cursor consumption。

## Validation

```txt
Catalog presentation focused suite: 57 tests pass
Reconnect ordering/dedupe/generation tests: pass
Reconnect non-blocking widget tests: pass
Build runner consistency: pass
Analyze: pass
Open P0: 0
Open P1 without disposition: 0
```

Task 28-5 accepted，可進入Task 28-6。
