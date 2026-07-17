# Catalog Feature

Catalog 是公開讀取型 feature，用來示範 cursor pagination、search debounce、Refresh、Append 與 feature-level Offline Cache。

## Cache contract

- Cache identity：`query + requested cursor + limit`。
- 第一頁與後續頁分開保存，不儲存單一合併 List。
- Initial / Query：Fresh Cache 直接使用；Stale Cache 先顯示，再背景 revalidate。
- Refresh：跳過 Cache、強制 Remote；Cache replacement 成功時重設同 query + limit 的 cursor chain。
- Append：retained Cache hit 優先，miss / expired 才走 Remote；第一版不背景 revalidate。
- Expired page 在讀取該 identity 時 lazy cleanup，不做每次 request 的全表掃描。
- Catalog Cache 是 public read model，Logout 只清除 Auth state，不清除 Catalog Cache。

## Layer responsibility

- RemoteDataSource：呼叫 Catalog API 並映射 transport exception。
- LocalDataSource：SQLite page transaction、chain validation 與 lazy cleanup。
- Repository：協調 Remote、Local、freshness、retention 與 load policy。
- Bloc：管理 SWR emissions、Refresh / Append lifecycle、race protection 與 cursor cycle guard。
- UI：呈現 cached、stale、last updated、background revalidation 與 non-blocking failure。

Catalog package 不使用 DI annotation；所有 composition 由 App Composition Root 完成。
