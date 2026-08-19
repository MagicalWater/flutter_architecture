---
document_type: migration-manifest
status: active
authoritative_for:
  - milestone-22-project-context-migration
last_reviewed_baseline: 1.5.0
---

# Milestone 22 — Project Context Migration Manifest

## Purpose

本文件追蹤舊版 `docs/project_context.md` 每個主要 heading 的去向，確保重寫為 current-only snapshot 時，不會把歷史、Decision、Plan 或 Evidence 當成無需保存的內容直接刪除。

本 manifest 記錄的是資訊 disposition，不是新的 current architecture authority。

## Disposition Values

- `retain-current`：以精簡且重新驗證的形式保留於新的 `docs/project_context.md`。
- `route-decision`：由 `docs/architecture_decisions.md` 的相關 Decision 擁有。
- `route-roadmap`：由 `docs/roadmap.md` 或後續 active／closed milestone routing 擁有。
- `route-release`：由 `CHANGELOG.md`、`VERSION` 或 release artifact 擁有。
- `route-evidence`：由少量 retained durable audit evidence 與 Git history 擁有；不要求永久保留 planning / phase / per-task review。
- `route-archive`：由 `docs/archive/`、`docs/milestones/` 或 Git history 保存。
- `route-governance`：由 `AGENTS.md`、`docs/README.md` 或 `docs/governance/` 擁有。

## Heading Migration Matrix

| Source heading | Existing responsibility | Disposition | Target authority / historical location |
|---|---|---|---|
| File introduction | 說明新對話恢復用途 | `retain-current` | 新 snapshot 的 Purpose 與 Authority 章節 |
| `專案定位` | Template 目的與讀者定位 | `retain-current` | 新 snapshot 的 Project Purpose |
| `語言規範` | 語言與術語規則 | `route-governance` + current summary | `AGENTS.md`、`docs/governance/documentation_policy.md`；snapshot 僅保留摘要 |
| `技術棧` | 技術選型列表 | `retain-current` | 新 snapshot 的 Architecture & Technology Map，需依目前實作更新 |
| `Architecture` | Clean Architecture、Feature First、Monorepo | `retain-current` + `route-decision` | snapshot 摘要；Decision 001、002 為規範 authority |
| `Presentation` | Bloc、Hooks | `retain-current` + `route-decision` | snapshot 摘要；Decision 003 |
| `Navigation` | Auto Route、Guard、nested navigation | `retain-current` + `route-decision` | snapshot 摘要；Decision 005、006、007、021 |
| `Dependency Injection` | GetIt／Injectable | `retain-current` + `route-decision` | snapshot 摘要；Decision 004、012 |
| `Model / Code Generation` | Freezed／JSON／build_runner | `retain-current` | snapshot technology summary；詳細選型保留於 Decision aggregate 與 package source |
| `Network` | Dio／Mock／interceptor | `retain-current` + `route-decision` | snapshot capability；Decision 013、015 |
| `Storage` | SharedPreferences／SQLite 舊摘要 | `retain-current` with correction | snapshot 必須區分 Secure credential、SQLite、preference、Catalog Cache；Decision 010、017、022 |
| `Reactive` | RxDart | `retain-current` | snapshot technology summary |
| `Auth Session / Refresh` | Refresh 與 replay contract 摘要 | `retain-current` + `route-decision` | snapshot capability；Decision 015、020、021、022 |
| 第一組 `已完成狀態` | Milestone 12、1 的 journal、tests、commits | `route-archive` + `route-release` | `docs/roadmap.md`、`CHANGELOG.md`、Git history；M12 contract 由 Decision 015 |
| 第二組 `已完成狀態` | Milestone 2C、2A、2B journal | `route-archive` | `docs/archive/progress_v1.0.0.md`、`docs/roadmap.md`、Git history |
| 第三組 `已完成狀態` | Milestone 3 journal | `route-archive` | `docs/archive/progress_v1.0.0.md`、`docs/roadmap.md` |
| 第四組 `已完成狀態` | Milestone 4 journal | `route-archive` | `docs/archive/progress_v1.0.0.md`、`docs/roadmap.md` |
| 第五組 `已完成狀態` | Milestone 5 journal | `route-archive` | `docs/archive/progress_v1.0.0.md`、`CHANGELOG.md` |
| 第六組 `已完成狀態` | Milestone 6 journal | `route-archive` | `docs/archive/progress_v1.0.0.md`、`docs/roadmap.md` |
| 第七組 `已完成狀態` | Milestone 7、8 journal | `route-archive` | `docs/archive/progress_v1.0.0.md`、`docs/roadmap.md` |
| 第八組 `已完成狀態` | Package DI boundary review | `route-decision` + `route-archive` | Decision 012、Milestone 8 historical record |
| `下一個工作目標` | Milestone 13–17 detailed plans and completion journal | `route-roadmap` + `route-decision` + `route-release` | `docs/roadmap.md`、Decision 016–020、`CHANGELOG.md`; 不保留於 current snapshot |
| `Milestone 13：Pagination + Search Debounce` | Plan、implementation、tests | `route-decision` + `route-release` | Decision 016、Catalog README、`CHANGELOG.md`、Git history |
| `Milestone 14：Offline Cache` | Plan、cache contract、completion | `route-archive` + `route-decision` | `docs/archive/milestone_14_offline_cache.md`、Decision 017 |
| `Milestone 15：Design System Foundation` | Plan、phase completion | `route-decision` + `route-archive` | Decision 018、`packages/design_system/README.md`、plans、`CHANGELOG.md` |
| `Milestone 16：Localization Foundation` | Plan、phase completion | `route-decision` + `route-archive` | Decision 019、Roadmap、`CHANGELOG.md` |
| `Milestone 17：Exception & Failure Architecture` | Plan、phase completion | `route-decision` + `route-archive` | Decision 020、Roadmap、`CHANGELOG.md` |
| `Milestone 9 完成摘要` | Retrofit migration journal | `route-decision` + `route-archive` | Decision 013、Roadmap、Git history |
| `已拍板的重要設計` | Decision 005–012 的摘要副本 | `route-decision` | `docs/architecture_decisions.md`；snapshot 只保留 current architecture map，不複製 Decision body |
| `驗證命令` | Workspace standard commands | `retain-current` + `route-governance` | snapshot 保留短版；`AGENTS.md` 擁有 agent operational rule |
| `新對話恢復流程` | 舊大型必讀清單 | `route-governance` | `AGENTS.md` 與 `docs/README.md` 的 Milestone 22-2 reading contract；舊清單不保留 |
| `Authentication Security Initiative：Milestone 19 至 21` | 19–21 逐 phase implementation journal、tests、commits、final status | `route-evidence` + `route-release` + current capability summary | retained security evidence、Decision 022、`CHANGELOG.md`、Git history；snapshot 只保留現行安全能力與 claim boundary |

## Semantic Preservation Rules

1. 新 snapshot 不保存 commit hash、逐 phase test count、過去的「下一步」或 implementation diary。
2. Current architecture claim 必須能連回 Decision、README、source 或 final review。
3. 已完成 Milestone 的歷史不因本檔重寫而失效；其 authority 已分流至 Roadmap、CHANGELOG、Decision、Audit、Archive 與 Git history。
4. 舊 `project_context.md` 的完整內容仍存在於 Git history；本 manifest 提供 heading-level discoverability。
5. 若後續發現某項資訊沒有可到達位置，必須先補 archive／index，再從 current snapshot 移除。

## Scope Guard

本 migration 不：

- 改寫 Architecture Decision。
- 拆分 Roadmap。
- 搬移 audits、plans 或 archive artifacts。
- 修改 production code。
- 宣稱歷史 plan 是 current authority。
