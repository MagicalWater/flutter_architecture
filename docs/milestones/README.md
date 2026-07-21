---
document_type: milestone-index
status: active
authoritative_for:
  - milestone-artifact-routing
last_reviewed_baseline: 1.5.0
---

# Milestone Routing

本目錄是 Milestone charter、plan、review、runtime evidence 與 release history 的穩定索引入口。

Milestone 22-2 先建立 routing contract，不搬移既有 artifacts；closed milestone 的完整索引會在 22-4 補齊。

## Authority

Milestone routing 只回答：

- Milestone 的正式名稱與狀態。
- Design、plan、review、evidence 與 release 記錄位於何處。
- 哪份文件是 final review。

它不重複 Architecture Decision 內容，也不成為第二份 Roadmap 或 CHANGELOG。

## Status rule

- Active：以 `docs/roadmap.md` 的 active entry 為準。
- Completed / Archived：以 final review、`CHANGELOG.md` 與 `VERSION` 為準。
- Candidate：以 Roadmap candidate 或 `docs/backlog.md` 為準。

## Current routing

- Milestone 18：`docs/audits/milestone_18/` 與 `docs/audits/milestone_18_holistic_audit.md`。
- Milestone 19：`docs/audits/milestone_19/`、root planning／holistic reviews 與相關 `docs/superpowers/plans/`。
- Milestone 20：`docs/audits/milestone_20/`、planning review、implementation plan 與 final review。
- Milestone 21：`docs/audits/milestone_21/`、planning review、implementation plan 與 final review。
- Milestone 22：`docs/audits/milestone_22_planning_review.md`、Milestone 22 spec／plan 與 `docs/audits/milestone_22/`。

早期 Milestone 的歷史目前分散於 `docs/roadmap.md`、`docs/project_context.md`、`CHANGELOG.md` 與 `docs/archive/`。22-3、22-4 會先建立 migration manifest，再收斂 routing。
