---
document_type: architecture-decision
status: accepted
authoritative_for:
  - adr-016-catalog-pagination-search
last_reviewed_baseline: 1.27.0
id: ADR-016
title: Catalog Pagination and Search
supersedes:
superseded_by:
related:
  - ADR-003
  - ADR-008
  - ADR-013
  - ADR-017
  - ADR-018
  - ADR-020
---

# ADR-016 — Catalog Pagination and Search

## Status

Accepted。

## Authoritative Scope

本 Decision 定義 Catalog cursor pagination、search debounce、logical cancellation、stale response protection、page merge與 operation state的責任邊界。

## Context

Pagination與搜尋若缺少明確 identity與 layer ownership，容易出現舊 query覆蓋新 state、Refresh與Append交錯、重複 Load More、Page自行管理 Timer或 Repository，以及 transport cancellation detail穿透 Presentation／Domain。

Catalog以 feature-local vertical slice承載此 contract，不建立以技術名稱命名的 generic pagination feature或 framework。

## Decision

### Cursor pagination contract

Catalog使用 cursor-based pagination：

```txt
request = query + cursor + limit
first page / refresh = cursor null
append = previous response nextCursor
```

`nextCursor`是是否可繼續載入的唯一 source of truth。`hasMore`若存在只能由它衍生，不另存可變副本。

Cursor屬於產生它的 query、filter、sort與 search generation；任一搜尋條件改變後不得沿用舊 cursor。空字串 cursor在 mapper boundary正規化為 `null`；response若回傳與 request相同的 cursor，Repository視為 non-advancing protocol failure，禁止形成無限 Append。

### Layer ownership

- API／RemoteDataSource負責 transport request與 typed exception boundary。
- Mapper負責 DTO到 Domain page的純轉換與 cursor正規化。
- Repository負責 cursor progression validation與 Failure mapping；不保存 UI state、不做 debounce、不合併既有 pages。
- Bloc 直接依賴 `CatalogRepository`；Initial、Refresh、Append是 Presentation workflow。由於原 `SearchCatalogUseCase` 只轉發 `watchCatalog`，不擁有額外 business rule，因此不保留 forwarding UseCase。
- Bloc負責 debounce、generation、operation state與 page merge。
- Page只送出 UI intent，不直接操作 Timer、Repository或 Dio cancellation。

### Search debounce and identity

Debounce、distinct與 latest-query-wins位於 Bloc event pipeline。Query normalization使用 `trim`，不隱式 lowercase；空 query表示預設 Catalog listing。

Debounce duration必須可注入，以支援 deterministic test與不同產品需求。

### Stale response protection

Bloc持有 monotonically increasing search generation。新的 debounced query、Refresh、query清空或其他搜尋條件改變都建立新 generation。

Operation至少捕獲：

```txt
Initial / Refresh = generation + query
Append = generation + query + requestedCursor
```

Response只有在 identity仍與目前 state一致時才能 emit。Event transformer的 restart／switch語意不能取代 generation guard，因為底層 Future或 HTTP request不一定真正取消。

### Load More and Refresh

Load More同時使用：

```txt
state guard
+ in-flight suppression
+ generation/query/cursor response validation
```

通過 guard後必須先同步標記 loading，再啟動 async request，避免同一 event loop的重複事件穿透。

Refresh使用目前 query與 `cursor = null`，建立新 generation、保留既有 items並使舊 Initial／Append失效。成功時整批替換 items與 cursor chain；失敗時保留既有 items。

### Merge and operation state

Append由 Bloc依穩定 Domain ID合併：保留既有順序、只加入新 ID、重複 ID保留既有 item。Refresh成功則整批替換。

Initial、Refresh與Append的 loading／failure state必須分離，不以單一 `isLoading`或單一 error欄位混合不同 operation語意。

### Logical cancellation

本 contract保證舊 operation可以完成，但不得更新目前 UI state。Dio `CancelToken`不穿透 Bloc 或 Repository interface；若未來需要節省高成本 transport resource，必須另建 transport-neutral cancellation contract。

### No generic framework

不建立 `GenericPagedBloc`、Pagination strategy hierarchy或跨 feature generic pagination controller。只有多個 feature證實相同 contract後才重新評估共用抽象。

## Consequences

- Query switching、Refresh與Append race具有明確 identity與 stale-result protection。
- Presentation不依賴 Dio cancellation detail。
- Pagination與搜尋保持 Catalog feature-local，可在不過早抽象的前提下延伸 Offline Cache。
- UI可分別呈現 blocking initial failure與 non-blocking refresh／append failure。

## Supersession

無。

## Related Decisions

- ADR-003：Bloc與 Hooks presentation responsibility。
- ADR-008：不為 Repository passthrough 建立 UseCase。
- ADR-013：Retrofit／DTO／DataSource／Repository boundary。
- ADR-017：Catalog Offline Cache與 SWR延伸本 pagination identity。
- ADR-018：Catalog operation state的 presentation surface。
- ADR-020：Failure與 unknown error boundary。

## Related Evidence

- [Catalog Feature README](../../apps/flutter_architecture/lib/features/catalog/README.md)
- [API Client README](../../packages/api_client/README.md)
- [Milestone routing](../milestones/README.md)

## Last Reviewed Baseline

1.27.0。
