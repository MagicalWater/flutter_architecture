---
document_type: milestone-index
status: active
authoritative_for:
  - milestone-artifact-routing
last_reviewed_baseline: 1.13.0
---

# Milestone Routing

本目錄是 Milestone charter、plan、review、runtime evidence 與 release history 的穩定索引入口。

本索引不搬移既有 artifacts；它只提供可持續的 routing，避免 current Roadmap 再次累積完整歷史 journal。

## Authority

Milestone routing 只回答：

- Milestone 的正式名稱與狀態。
- Design、plan、review、evidence 與 release 記錄位於何處。
- 哪份文件是 final review。

它不重複 Architecture Decision 內容，也不成為第二份 Roadmap 或 CHANGELOG。

## Status rule

- Active：以 `docs/roadmap/active.md` 為準。
- Completed / Archived：以 final review、`CHANGELOG.md` 與 `VERSION` 為準。
- Candidate：以 `docs/roadmap/candidates.md` 或 `docs/backlog.md` 為準。

## Active routing

```txt
None
```

## Closed milestone routing

| Milestone | Status | Primary routing |
|---|---|---|
| 1–8 | Completed / Archived | `docs/archive/progress_v1.0.0.md`、`CHANGELOG.md`、Git history |
| 9 | Completed / Archived | Decision 013、`CHANGELOG.md`、Git history |
| 10 | Completed / Archived | Decision 014、`CHANGELOG.md`、Git history |
| 11 | Deferred | `docs/roadmap/candidates.md`、`docs/backlog.md` |
| 12 | Completed / Archived | Decision 015、`CHANGELOG.md`、Git history |
| 13 | Completed / Archived | Decision 016、`CHANGELOG.md`、Git history |
| 14 | Completed / Archived | `docs/archive/milestone_14_offline_cache.md`、Decision 017 |
| 15 | Completed / Archived | Decision 018、`docs/superpowers/plans/`、`CHANGELOG.md` |
| 16 | Completed / Archived | Decision 019、`CHANGELOG.md`、Git history |
| 17 | Completed / Archived | Decision 020、`CHANGELOG.md`、Git history |
| 18 | Completed / Archived | `docs/audits/milestone_18_holistic_audit.md`、`docs/audits/milestone_18/` |
| 19 | Completed / Archived | planning review、`docs/audits/milestone_19/`、holistic final review、plans |
| 20 | Completed / Archived | planning review、`docs/audits/milestone_20/`、implementation plan |
| 21 | Completed / Archived | planning review、`docs/audits/milestone_21/`、implementation plan |
| 22 | Completed / Archived | planning review、implementation plan、`docs/audits/milestone_22/22-7_final_review.md` |
| 23 | Completed / Archived | `docs/audits/milestone_23/23-0_planning_review.md`、migration manifest、batch reviews、`docs/audits/milestone_23/23-9_final_review.md` |
| 24 | Completed / Archived | ADR-023、implementation plan、`docs/audits/milestone_24/24-6_final_review.md`、`docs/audits/milestone_24/24-7_post_release_remote_validation.md` |
| 25 | Completed / Archived | ADR-024、implementation plan、`docs/audits/milestone_25/25-10_final_review.md`、`docs/audits/milestone_25/25-11_remote_validation.md` |
| 26 | Completed / Archived | ADR-025、implementation plan、`docs/audits/milestone_26/26-8_final_review.md`、`docs/audits/milestone_26/26-6_remote_validation.md`、`docs/audits/milestone_26/26-9_post_release_remote_validation.md` |
| 27 | Completed / Archived | ADR-026、implementation plan、`docs/audits/milestone_27/27-8_final_review.md`、`docs/audits/milestone_27/27-9_post_release_remote_validation.md`、Task 27-6 remote acceptance、Task 27-7 runtime evidence |
| 28 | Completed / Archived | ADR-027、implementation plan、`docs/audits/milestone_28/28-9_final_review.md`、`docs/audits/milestone_28/28-10_post_release_validation.md`、Task 28-7 platform evidence |
| 29 | Completed / Archived | ADR-010、implementation plan、`docs/audits/milestone_29/29-9_platform_runtime_regression.md`、`docs/audits/milestone_29/29-10_final_review.md`、`docs/audits/milestone_29/29-10_post_release_validation.md` |
| 30 | Completed / Archived | Design Spec、implementation plan、`docs/audits/milestone_30/30-11_final_review.md`、`docs/audits/milestone_30/30-12_post_release_validation.md`、`docs/guides/testing_governance.md` |
| 31 | Completed / Archived | Workflow Governance Skill、approved Design Spec、approved Recovery Plan、`docs/audits/milestone_31/31-r9_implementation_holistic_review.md`、`docs/audits/milestone_31/31-r10_local_final_review.md`、`docs/audits/milestone_31/31-r11_post_release_validation.md` |

完整 disposition 與歷史保存位置記錄於 `docs/migrations/m22_roadmap_manifest.md`。

## Routing rule

Milestone index 只保存名稱、status 與 artifact route。它不得複製 Architecture Decision body、Task checklist、測試 journal、runtime evidence 或 release notes 全文。
