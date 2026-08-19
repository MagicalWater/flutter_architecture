---
document_type: migration-manifest
status: accepted
authoritative_for:
  - milestone-22-roadmap-migration-disposition
last_reviewed_baseline: 1.5.0
---

# Milestone 22 Roadmap Migration Manifest

本文件記錄舊版 `docs/roadmap.md` 各區段在 Milestone 22-4 的 disposition。舊版完整內容仍可由 Git history 取得；本階段不搬移既有 audit、plan 或 archive artifact。

## Disposition 類型

- `roadmap-index`：保留為精簡 Roadmap 總入口。
- `active`：移至 `docs/roadmap/active.md`。
- `candidate`：移至 `docs/roadmap/candidates.md` 或由 `docs/backlog.md` 持有。
- `closed-routing`：只在 `docs/milestones/README.md` 建立歷史路由。
- `historical-source`：保留於既有 archive、audit、plan、CHANGELOG、Decision 或 Git history。

## Milestone disposition

| Milestone | Final status | New roadmap disposition | Existing historical routing |
|---|---|---|---|
| 1 | Completed / Archived | `closed-routing` | `docs/archive/progress_v1.0.0.md`、Git history |
| 2A | Completed / Archived | `closed-routing` | `docs/archive/progress_v1.0.0.md`、Decision aggregate |
| 2B | Completed / Archived | `closed-routing` | `docs/archive/progress_v1.0.0.md`、Decision aggregate |
| 2C | Completed / Archived | `closed-routing` | `docs/archive/progress_v1.0.0.md`、Decision aggregate |
| 3 | Completed / Archived | `closed-routing` | `docs/archive/progress_v1.0.0.md`、Git history |
| 4 | Completed / Archived | `closed-routing` | `docs/archive/progress_v1.0.0.md`、Git history |
| 5 | Completed / Archived | `closed-routing` | `docs/archive/progress_v1.0.0.md`、Git history |
| 6 | Completed / Archived | `closed-routing` | `docs/archive/progress_v1.0.0.md` |
| 7 | Completed / Archived | `closed-routing` | `docs/archive/progress_v1.0.0.md`、CHANGELOG |
| 8 | Completed / Archived | `closed-routing` | `docs/archive/progress_v1.0.0.md`、CHANGELOG |
| 9 | Completed / Archived | `closed-routing` | Decision 013、CHANGELOG、Git history |
| 10 | Completed / Archived | `closed-routing` | Decision 014、CHANGELOG、Git history |
| 11 | Deferred | `candidate` | `docs/backlog.md`、`docs/roadmap/candidates.md` |
| 12 | Completed / Archived | `closed-routing` | Decision 015、CHANGELOG、Git history |
| 13 | Completed / Archived | `closed-routing` | Decision 016、CHANGELOG、Git history |
| 14 | Completed / Archived | `closed-routing` | `docs/archive/milestone_14_offline_cache.md`、Decision 017 |
| 15 | Completed / Archived | `closed-routing` | Decision 018、CHANGELOG、Git history |
| 16 | Completed / Archived | `closed-routing` | Decision 019、CHANGELOG、Git history |
| 17 | Completed / Archived | `closed-routing` | Decision 020、CHANGELOG、Git history |
| 18 | Completed / Archived | `closed-routing` | `docs/audits/milestone_18/`、holistic audit、CHANGELOG |
| 19 | Completed / Archived | `closed-routing` | planning review、plans、phase reviews、holistic final review、CHANGELOG |
| 20 | Completed / Archived | `closed-routing` | planning review、implementation plan、phase reviews、final review、CHANGELOG |
| 21 | Completed / Archived | `closed-routing` | planning review、implementation plan、phase reviews、final review、CHANGELOG |
| 22 | Active | `active` | `docs/roadmap/active.md`、Milestone 22 spec、plan、reviews |

## Removed roadmap responsibilities

舊 Roadmap 中以下內容不再由 current roadmap 保存：

- 每個子階段的逐 Task checklist。
- 每次 implementation review 的測試數與結果流水帳。
- Commit hash timeline。
- Architecture Decision 的完整 contract 摘要。
- Runtime evidence 詳情。
- 已完成 milestone 的逐階段 next-step 敘述。

上述內容仍由對應 Decision、plan、audit、final review、CHANGELOG、archive 與 Git history保存。

## Preservation rule

本階段只改變 current navigation，不刪除歷史 artifact。若後續需要物理搬移，必須另建 migration manifest、檢查 link target，並保留 transitional routing。
