# Milestone 14 Archive：Offline Cache

封存版本：Template Baseline 1.1.0  
封存日期：2026-07-17  
狀態：Completed / Archived

本文件保存 Milestone 14 的歷史完成摘要。現行規則仍以 `README.md`、`docs/project_context.md`、`docs/architecture_decisions.md` 與 `docs/roadmap.md` 為準。

## 完成範圍

- Catalog feature-level、明確 opt-in 的 Offline Cache。
- SQLite page metadata 與 ordered page items。
- `query + requested cursor + limit` Cache identity。
- Fresh / stale / expired 與 retention policy。
- Initial / Query 的 Cache-first + Stale-While-Revalidate。
- Pull-to-refresh Remote-only replacement 與 cursor chain reset。
- Append retained Cache hit、Remote fallback 與 expired replacement。
- cached / stale / last updated / background revalidation UI。
- public Catalog Cache 在 Logout 後保留。
- Mock / Real Composition Root graph 與 scope assertions。

## Final Review 修正

- SQLite database version 升級至 v4。
- `catalog_cache_page` 新增 `chain_revision`。
- Append request 捕捉目前 revision，transaction write 使用 compare-and-set。
- Refresh 即使重用相同 opaque cursor，舊 Append 也無法污染新 chain。
- Cursor cycle persistence 改以 ancestor path + revision 驗證。
- Expired predecessor 可在 retained successor 存在時合法 replacement。

## 封存驗證

- Workspace code generation 通過。
- Workspace analyze 通過。
- Workspace 全部 132 項 tests 通過。
- Development bundle 通過。
- Staging Real API bundle 通過。
- Production Real API bundle 通過。
- `git diff --check` 通過。

## 相關決策

- Architecture Decision 016：Catalog Pagination + Search Debounce。
- Architecture Decision 017：Catalog Offline Cache 與 Stale-While-Revalidate 責任邊界。

Milestone 14 封存後，不再作為 active implementation scope；後續變更應以新的 Milestone 或明確 bug fix 處理。
