---
document_type: feature-readme
status: accepted
authoritative_for:
  - catalog-feature-local-contract
last_reviewed_baseline: 1.27.0
---

# Catalog Feature

Catalog 是公開讀取型 feature，用來示範 cursor pagination、search debounce、Refresh、Append 與 feature-level Offline Cache。

## Responsibilities

- Catalog query、pagination、refresh、append 與 search presentation。
- Remote／Local data coordination。
- SWR、stale data、background revalidation 與 non-blocking failure UI。
- App-owned reconnect signal的feature opt-in非阻塞revalidation。
- Catalog cache chain、revision、retention 與 lazy cleanup。

## Non-responsibilities

- 不建立 generic HTTP cache、generic pagination framework 或所有 API 自動 SQLite cache。
- 不清除 Auth credential或 Session。
- 不把 server content 寫入 App localization resources。
- 不直接顯示 diagnostic `Failure.message`。
- 不直接依賴或監聽`connectivity_plus`；只消費App提供的provider-neutral reconnect signal。

## Dependencies

```txt
CatalogPage
→ CatalogBloc
→ CatalogRepository
→ RemoteDataSource + LocalDataSource
→ Catalog API + SQLite cache
```

Composition 由 App 完成；feature 不使用 DI annotation。

## Cache Contract

- Cache identity：`query + requested cursor + limit`。
- 第一頁與後續頁分開保存，不儲存單一合併 List。
- Initial／Query：fresh cache 直接使用；stale cache 先顯示，再背景 revalidate。
- Refresh：跳過 cache、強制 remote；成功 replacement 重設同 query＋limit cursor chain。
- Reconnect：只在頁面已進入、initial load完成且已有資料時觸發；使用獨立operation state，失敗保留既有資料。
- 第一頁 replacement 遞增持久化 chain revision；append write 使用 revision CAS。
- Expired append predecessor 可保留同 revision 合法 successor；cycle 以 ancestor path 判斷。
- Append：retained cache hit 優先；miss／expired 才走 remote，第一版不背景 revalidate。
- Expired page 在讀取該 identity 時 lazy cleanup，不做每次 request 全表掃描。
- Catalog cache 是 public read model；Logout 不清除它。

## Layer Responsibilities

- RemoteDataSource：呼叫 Catalog API 並映射 transport exception。
- LocalDataSource：SQLite page transaction、chain validation 與 lazy cleanup。
- Repository：協調 Remote、Local、freshness、retention 與 load policy。
- Bloc：管理 SWR emissions、Refresh／Append／Reconnect lifecycle、ordering、dedupe、generation protection與cursor cycle guard。
- UI：呈現 localized cached／stale／last updated／revalidation／operation failure surface。

`lastUpdatedAt` 只在 Presentation 轉 local time 後依目前 locale 格式化。

## Tests

目前沒有 feature-local retained test folder。Catalog persistence／migration 的長期 regression owner 位於 `test/app/database/`；query、pagination、SWR、reconnect、revision CAS、cycle guard 與 presentation case 只有在 changed risk 需要且既有 owner 不足時才新增。

Catalog現有test density主要來自pagination、cache、revision CAS、cycle、reconnect與concurrency failure modes；它是architecture／behavior reference，**不是一般Product Feature的test-density quota**。新Feature只為自身新增的risk／invariant／failure mode建立最小充分owner。

## Related Decisions

Offline Cache以 `docs/adr/README.md` 中的 ADR-016至ADR-020為authority；Connectivity與Reconnect boundary以ADR-027為authority。
