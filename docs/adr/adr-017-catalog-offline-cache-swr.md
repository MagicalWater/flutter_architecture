---
document_type: architecture-decision
status: accepted
authoritative_for:
  - adr-017-catalog-offline-cache-swr
last_reviewed_baseline: 1.5.1
id: ADR-017
title: Catalog Offline Cache and Stale-While-Revalidate
supersedes:
superseded_by:
related:
  - ADR-010
  - ADR-012
  - ADR-013
  - ADR-016
  - ADR-018
  - ADR-020
---

# ADR-017 — Catalog Offline Cache and Stale-While-Revalidate

## Status

Accepted。

## Authoritative Scope

本 Decision 定義 Catalog feature-level Offline Cache、SWR、cache identity、cursor chain persistence、Repository coordination、degraded-mode behavior與 logout policy。

它不定義 exact SQLite DDL、歷史 database version或 migration journal。

## Context

把所有 GET response自動寫入 SQLite會誤快取 Login、Refresh、交易或其他 command API，也會讓 HTTP schema成為 persistence schema，並隱藏 freshness、identity與 invalidation policy。

Catalog因此採明確 opt-in、feature-local cache，而不是 global HTTP cache或 generic cache framework。

## Decision

### Feature-level opt-in

Offline Cache只對 Catalog明確啟用。其他 feature必須先定義資料敏感度、identity、TTL、account scope、logout與 invalidation policy，不能自動繼承 Catalog策略。

### Load policies

Catalog使用三個 feature-specific load policy：

```txt
initial
  cursor null
  cache-first + stale-while-revalidate

refresh
  cursor null
  remote-only replacement

append
  cursor non-null
  retained page cache hit or remote fallback
```

Initial行為：

- cache miss：Remote；成功後寫 Cache，失敗為 blocking failure。
- fresh cache：立即回傳並結束。
- stale cache：先回傳 stale snapshot，再 background revalidate；Remote失敗保留 snapshot並回傳 non-blocking revalidation failure。

Refresh強制 Remote，成功 replacement第一頁並重設 cursor chain；失敗保留既有 data與 Cache。

Append可使用 retained page Cache；miss或 expired才走 Remote。Append第一版不做 background revalidation，避免同一 operation同時產生 stale merge與 replacement語意。

### Freshness and retention

Policy明確區分 `freshFor`與 `retainFor`：Fresh可直接使用、Stale可顯示但需 revalidate、超過 retention視為 miss並可 lazy cleanup。

時間來源使用可注入 Clock／time provider，不在 Repository散落 `DateTime.now()`。

### Cache identity and representation

Cache identity完整包含：

```txt
normalized query
request cursor
limit
```

Query normalization沿用 ADR-016：trim但不 lowercase。Domain第一頁 cursor維持 `null`；LocalDataSource可使用 storage sentinel，但不得穿透 boundary。

Cache以 cursor page儲存，而不是保存畫面合併後的單一 List。每頁至少保留 request identity、next cursor、updated time與 ordered items。

Remote DTO、Local Entity與 Domain Entity保持分離。

### Cursor chain integrity

任一 Remote第一頁成功都會 replacement第一頁並使同 query＋limit的舊後續 chain失效。此操作必須在單一 database transaction完成。

Append只 replacement指定 request cursor page。讀取 chain只能沿目前 response `nextCursor`前進，不能掃描孤立舊 page後自行合併。

Current implementation另使用持久化 chain revision與 compare-and-set保護 stale Append；exact schema與 migration history由 source、Feature README及 historical evidence保存。

### Repository and stream contract

Repository負責 Remote＋Local協調、freshness判定、cursor validation、cache write與 Failure mapping。Bloc、UseCase與 Page不直接依賴 SQLite、DTO、Dio或 LocalDataSource。

Initial SWR需要 feature-specific Stream支援多次結果；不得以 callback讓 Repository直接操作 Bloc。Expected AppException透過 typed Result表示；unknown programming error保留原始 stack trace並使用 Stream error channel。

### Degraded-mode behavior

Catalog Cache是可重建 read model，不等同 Auth credential persistence：

- Cache read failure可 non-fatal report後 fallback Remote。
- Cache write failure不把 Remote success轉成整體失敗。
- Remote failure且有可用 Cache時保留 data並呈現 non-blocking failure。
- Remote failure且無 Cache時才是 blocking failure。
- Cache failure不得清除 Session。

UI不得因單次 timeout、DNS或5xx宣稱裝置確定 Offline；應呈現精確的 cached、stale、last updated與 revalidation狀態。

User Refresh與 background revalidation使用不同 operation state。

### Persistence ownership and cleanup

SQLite database lifecycle與 migration由 App database boundary擁有；App仍是唯一 Composition Root。Catalog LocalDataSource、CachePolicy、Clock、Repository、UseCase與 Bloc lifecycle由 App組裝。

Expired page在讀取該 identity時 lazy cleanup，不在每次 read／write後全表掃描。LRU、quota與 background maintenance不屬於本 contract。

### Logout policy

Catalog是 public read model，因此 Logout不清除 Catalog Cache。未來 authenticated／user-scoped cache必須加入 account identity並另定 account-switch cleanup policy。

### No generic cache framework

不建立 global cache interceptor、`GenericCache<T>`、generic offline repository或 generic paged cache。只有多個 feature證實真正相同的 identity、freshness、storage與 invalidation pattern後才重新評估。

## Consequences

- Catalog可離線顯示、辨識 stale data並背景更新。
- Cursor chain與 query／limit identity不會被單一合併 List破壞。
- Cache failure不會升級為 Auth或 Session failure。
- Persistence implementation可演進，而不改變 feature-level SWR contract。

## Supersession

無。

## Related Decisions

- ADR-010：SQLite platform initialization boundary。
- ADR-012：App-only Composition Root與 package DI boundary。
- ADR-013：Remote transport與 DTO boundary。
- ADR-016：pagination、query與 cursor identity。
- ADR-018：cached／stale／revalidation presentation surfaces。
- ADR-020：typed failure、non-fatal reporting與 unknown error。

## Related Evidence

- [Catalog Feature README](../../apps/flutter_architecture/lib/features/catalog/README.md)
- [App README](../../apps/flutter_architecture/README.md)

## Last Reviewed Baseline

1.5.1。
