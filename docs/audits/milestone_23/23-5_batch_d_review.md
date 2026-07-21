---
document_type: phase-review
status: accepted
authoritative_for:
  - milestone-23-task-23-5-batch-d-review
last_reviewed_baseline: 1.5.1
---

# Milestone 23-5 — Batch D Catalog Data Lifecycle Review

## Scope

本 Task擷取 ADR-016與 ADR-017，更新 migration-aware index與 manifest。Aggregate `docs/architecture_decisions.md`正文保持不變，正式 authority尚未 cutover。

開始本批時另發現 manifest已有兩段重複的 Batch B progress；本 Task移除後段重複內容，不改變任何 Decision disposition。

## ADR-016 Section Disposition

| Aggregate section | Disposition | Canonical result |
|---|---|---|
| Implementation status | route evidence | 不進 ADR body |
| Catalog vertical slice | retain/normalize | 保留 feature-local，不建立 technical/generic feature |
| Cursor pagination | retain | query/cursor/limit、nextCursor authority、non-advancing guard |
| API/DTO/Mapper/Repository | retain | layer ownership與 public endpoint scope |
| UseCase | retain | 單一搜尋行為，operation留在 Presentation |
| Debounce | retain | Bloc pipeline、trim/distinct、injectable duration |
| Search generation | retain | query/generation/cursor stale-response identity |
| Load More guard | retain | state＋in-flight suppression＋response identity |
| Refresh | retain | new generation、preserve items、replacement semantics |
| Merge | retain | stable ID、order、duplicate handling |
| Loading/failure states | retain | Initial／Refresh／Append separation |
| Cancellation | retain | logical cancellation；no Dio token leakage |
| Generic framework | retain | explicit non-goal |
| Test requirements/completion impact | route evidence | 不進 ADR body |

## ADR-017 Section Disposition

| Aggregate section | Disposition | Canonical result |
|---|---|---|
| Implementation status | route evidence | 不進 ADR body |
| Feature opt-in | retain | no global HTTP cache／command cache |
| Initial SWR | retain | miss/fresh/stale contract |
| Refresh/Append policies | retain | remote replacement vs retained page hit |
| Freshness/retention | retain | freshFor/retainFor semantics and injectable clock |
| Cache identity | retain | normalized query＋request cursor＋limit |
| Page storage | retain | page metadata＋ordered items，not merged list |
| First-page chain reset | retain | transaction and old successor invalidation |
| DTO/Local/Domain separation | retain | representation boundaries |
| Repository Stream | retain | multi-emission SWR and fail-fast load policy |
| Cache degradation | retain | non-blocking diagnostics and Remote fallback |
| UI offline semantics | retain | precise metadata，no inferred global offline |
| Revalidation state | retain | user Refresh separate from background work |
| Database ownership | retain/normalize | App database boundary retained；exact versions removed |
| Logout policy | retain | public Cache survives Logout |
| Lazy cleanup/no generic cache | retain | feature-local maintenance policy |
| Suggested DDL/migration/test matrix | route source/evidence | 不進 ADR body |

## Semantic Preservation Review

### ADR-016

Accepted。Canonical ADR完整保留 pagination/search correctness invariants，沒有把 event transformer誤寫成真正 transport cancellation，也沒有將 page-based strategy或 generic framework擴張為 current能力。

### ADR-017

Accepted。Canonical ADR完整保留 SWR、cache identity、cursor chain、degraded-mode、logout與 Composition Root contract。Exact SQL、database version、migration steps與 test journal已路由至 source、Feature README與 archive；chain revision/CAS只以 current invariant摘要保留。

## Relation Review

- ADR-010、012、013、016已存在 canonical targets，SQLite、Composition Root、transport與 pagination relation一致。
- ADR-018、020尚未 extraction，只列 related，不建立 supersession edge。
- ADR-016／017互相 related，沒有 supersession relation。

## Link and Compatibility Review

- Canonical related evidence使用有效 relative links。
- Current README／Documentation Hub仍可指向 aggregate，符合 Batch G前 compatibility contract。
- Published CHANGELOG、historical plans與 audits不重寫。
- Aggregate Decision 016／017正文未刪除、未縮減、未轉 stub。

## Validation

```txt
python -m unittest tools.docs.test_check_docs
→ 11 tests passed

dart run melos run docs_check
→ Documentation check passed

git diff --check
→ Passed

git diff --quiet -- docs/architecture_decisions.md
→ Passed；aggregate未修改

ADR index
→ 18 extracted / 4 aggregate

Canonical journal / DDL scan
→ 無實作狀態、測試要求、CREATE TABLE、database version 2/3或 historical test count
```

## Rollback

若 Batch D需要 rollback，revert本 batch commit即可移除兩個 canonical ADR、index／manifest更新與本 review；aggregate authority仍完整存在。

## Review Decision

Batch D semantic、relation、link與 checker gate通過。Manifest重複段落已修正；Open P0／P1：0。
