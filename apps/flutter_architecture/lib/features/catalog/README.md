---
document_type: feature-readme
status: accepted
authoritative_for:
  - catalog-feature-local-contract
last_reviewed_baseline: 1.5.1
---

# Catalog Feature

Catalog 是公開讀取型 feature，用來示範 cursor pagination、search debounce、Refresh、Append 與 feature-level Offline Cache。

## Responsibilities

- Catalog query、pagination、refresh、append 與 search presentation。
- Remote／Local data coordination。
- SWR、stale data、background revalidation 與 non-blocking failure UI。
- Catalog cache chain、revision、retention 與 lazy cleanup。

## Non-responsibilities

- 不建立 generic HTTP cache、generic pagination framework 或所有 API 自動 SQLite cache。
- 不清除 Auth credential或 Session。
- 不把 server content 寫入 App localization resources。
- 不直接顯示 diagnostic `Failure.message`。

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
- 第一頁 replacement 遞增持久化 chain revision；append write 使用 revision CAS。
- Expired append predecessor 可保留同 revision 合法 successor；cycle 以 ancestor path 判斷。
- Append：retained cache hit 優先；miss／expired 才走 remote，第一版不背景 revalidate。
- Expired page 在讀取該 identity 時 lazy cleanup，不做每次 request 全表掃描。
- Catalog cache 是 public read model；Logout 不清除它。

## Layer Responsibilities

- RemoteDataSource：呼叫 Catalog API 並映射 transport exception。
- LocalDataSource：SQLite page transaction、chain validation 與 lazy cleanup。
- Repository：協調 Remote、Local、freshness、retention 與 load policy。
- Bloc：管理 SWR emissions、Refresh／Append lifecycle、race protection 與 cursor cycle guard。
- UI：呈現 localized cached／stale／last updated／revalidation／operation failure surface。

`lastUpdatedAt` 只在 Presentation 轉 local time 後依目前 locale 格式化。

## Tests

測試位於 `test/features/catalog/`，應覆蓋 query debounce、cursor pagination、SWR、revision CAS、cycle guard、logout persistence與 localized presentation。

## Related Decisions

以 `docs/adr/README.md` 中的 ADR-016至ADR-020為 authority。
