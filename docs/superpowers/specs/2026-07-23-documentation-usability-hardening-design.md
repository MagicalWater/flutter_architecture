---
document_type: design-spec
status: accepted
authoritative_for:
  - documentation-usability-hardening-design
last_reviewed_baseline: 1.8.0
---

# Documentation Usability Hardening Design

## Purpose

本 design 定義一個小型、非大型 Milestone 的 Documentation Usability Hardening initiative。

它回應 `docs/audits/documentation_usability_coverage_audit.md` 與 `docs/audits/documentation_usability_coverage_audit_review.md` 已確認的 navigation、task routing 與少量 stale／duplication 問題。

本 initiative 的目標不是擴張文件數量，也不是建立新的 architecture authority，而是讓開發者在新增 Feature、API endpoint、SQLite schema／migration 與 App integration 時，可以更快找到正確 authority、修改入口與驗證路徑。

## Baseline

```txt
Template Baseline: 1.8.0
Active Milestone: None
Audit status: Accepted
Audit review status: Accepted
Runtime scope: None
Architecture contract change: None
```

## Design Principles

本 initiative 必須遵守：

- 文件是 Single Source of Truth。
- ADR 繼續擁有 durable architecture contract。
- Guide 只擁有 operational procedure，不重述 ADR 正文。
- App／Feature／Package README 只保存 local current contract 與 task route。
- Historical Audit、Plan 與 runtime evidence 不成為 current instruction。
- 不為了文件數量、目錄整齊或 metadata coverage 而增加文件。
- 不建立 generic framework 或跨情境的模糊 handbook。
- 所有 cross-link 與 summary 必須服從既有 authority。

## Chosen Approach

採用小型正式 initiative，而不是：

- 建立 Milestone 27。
- 直接以未經設計的 maintenance commit 修改多份文件。
- 啟動大型 Documentation Knowledge Expansion。

此 approach 保留 design、review、plan、逐 Task review 與 closure gate，但不要求新版本發布、ADR、runtime regression 或大型 archive transition。

## Scope

### Task 1 — Feature Guide Responsibility

處理：

```txt
docs/guides/how-to-add-feature.md
```

將目前的早期「暫不實作」占位內容收斂為薄型 Feature integration checklist。

Checklist 只提供：

- 任務開始前的 reading route。
- Feature responsibility 判斷。
- Domain／Data／Presentation integration sequence。
- API／Persistence integration entry points。
- DI registration。
- Route integration。
- Localization。
- Tests。
- Feature README。
- ADR decision gate。
- Generated source 與 verification commands。

Checklist 不重新定義：

- Clean Architecture。
- Feature First。
- Bloc boundary。
- Composition Root。
- Route Guard authority。
- Localization ownership。
- Persistence authority。
- Failure architecture。

上述規則只允許摘要並連結 canonical ADR、App README、Feature README 或 Package README。

### Task 2 — App Integration Routes

更新：

```txt
apps/flutter_architecture/README.md
```

新增兩條短型 task route：

#### Database schema / migration route

串接：

```txt
App database schema source
→ fresh-create path
→ incremental upgrade path
→ affected local data source
→ migration / persistence tests
→ relevant Feature README and ADR
→ verification
```

README 不複製 exact DDL、database version journal 或 historical migration evidence。

#### App integration route

串接：

```txt
Router
→ DI registration
→ Localization
→ Persistence adapter
→ Feature / App tests
→ build_runner
→ repository verification
```

此 route 只指出 integration points 與 authority links，不建立新的 cross-feature contract。

### Task 3 — API Endpoint Route

更新：

```txt
packages/api_client/README.md
```

新增短型 endpoint checklist，涵蓋：

- API abstraction／Retrofit declaration。
- Wire DTO 與 serialization。
- Mock／Real parity。
- Public export。
- Authentication metadata 與 transport boundary。
- Feature DataSource／Repository mapping。
- App DI selection／registration。
- Package與Feature tests。
- Generated source 與 verification。

新增 external system 是否拆成獨立 package，仍由相關 ADR 與 package boundary 原則決定；README 不建立新的拆分規則。

### Task 4 — Audit Navigation

更新：

```txt
docs/audits/README.md
```

補足近期 evidence routing，至少包含：

- Milestone 24。
- Milestone 25。
- Milestone 26。
- Change-aware CI reviews／remote validation／holistic final review。
- Documentation Usability & Coverage Audit 與 formal review。

Audit index 只保存 artifact route 與簡短用途，不複製 findings、test evidence 或 final conclusion。

### Task 5 — Roadmap Disposition

更新：

```txt
docs/roadmap/candidates.md
docs/backlog.md
```

收斂重複的 Documentation Knowledge Expansion 項目，使其只有一個正式 disposition。

預期方向：

- 大型 Documentation Knowledge Expansion：不成立。
- 大型 Feature／Troubleshooting／Architecture Evolution guides：不成立。
- 小型 Documentation Usability Hardening：作為本 initiative 執行。
- 未來若出現新的 confirmed gap，再以獨立 evidence 重新進入 candidate review。

Roadmap 與 Backlog 不保存本 initiative 的逐 Task journal。

### Task 6 — Holistic Documentation Review

完成所有修改後，重新審查：

- 是否存在 ADR 內容複製。
- 是否出現新的 duplicate authority。
- Guide、README、Audit index、Roadmap與Backlog責任是否清楚。
- Task route 是否真的能從入口走到 source、tests與verification。
- Relative links、metadata、scope與status是否一致。
- 是否仍存在 stale placeholder 或 navigation dead end。
- 是否有超出本 design 的文件擴張。

## Document Authority Model

### Existing authority retained

| Document type | Retained responsibility |
|---|---|
| Canonical ADR | Durable architecture contract |
| Documentation Hub | Taxonomy and reading route |
| Governance Policy | Metadata, lifecycle and growth rules |
| App README | App-local current responsibilities and integration routes |
| Feature README | Feature-local current contract |
| Package README | Package-local current contract and public usage route |
| Guide | Repeatable operational procedure |
| Audit index | Review and evidence routing |
| Roadmap / Backlog | Initiative state and disposition |

### New or changed authority

本 initiative 不新增 architecture authority。

`docs/guides/how-to-add-feature.md` 若通過 review，最多擁有：

```txt
feature-addition-operational-procedure
```

它不得擁有：

```txt
clean-architecture-feature-first
app-dependency-injection
localization-boundary
persistence-authority
failure-architecture
```

## Verification Strategy

每個 Task 至少執行：

```bash
dart run melos run docs_check
git diff --check
```

並進行 focused semantic review：

- Links 是否指向 current authority。
- 摘要是否與 ADR／README 衝突。
- Checklist 是否缺少必要 integration point。
- 是否把 historical evidence 寫成 current instruction。
- 是否新增未被 design 授權的文件或 scope。

本 initiative 不修改 production source，因此不要求 Flutter analyze、test、build runner 或 native build 作為每一 Task 的固定 gate。

若文件變更意外觸及 generated source、configuration 或 runtime contract，必須停止並重新做 scope review，不能自行擴張驗證或 implementation。

## Review and Execution Model

```txt
Design spec task
→ implement
→ review
→ findings
→ fix
→ re-review
→ Open P0 / P1 = 0
→ validation
→ commit

Implementation plan task
→ implement
→ review
→ findings
→ fix
→ re-review
→ Open P0 / P1 = 0
→ validation
→ commit

Task 1 through Task 6
→ each Task follows the same complete closure loop
→ each Task commits independently after validation
→ next Task starts only after the current Task commit succeeds
```

每個 Task，包括 design spec 與 implementation plan，都必須完整遵循：

```txt
implement
→ review
→ findings
→ fix
→ re-review
→ Open P0 / P1 = 0
→ validation
→ commit
```

Review 未通過時，只能修正該 Task finding，不能提前執行後續 Task。不得在 Task 尚未完成 commit 前切換到下一個 Task。

Commit message 使用 Conventional Commits，描述文字使用繁體中文。

## Deliverables

預期修改文件：

```txt
docs/guides/how-to-add-feature.md
apps/flutter_architecture/README.md
packages/api_client/README.md
docs/audits/README.md
docs/roadmap/candidates.md
docs/backlog.md
```

預期新增 historical artifacts：

```txt
本 design spec
formal design review
implementation plan
逐 Task review artifacts
holistic final review
```

每個 Task 必須保留可追溯的 formal review、findings、fix 與 re-review evidence。預設以獨立 review artifact 保存；只有 implementation plan 能證明同一 artifact 仍可清楚區分各 Task closure，且不降低可追溯性時，才可使用合併形式。

## Non-goals

- 不新增 ADR。
- 不修改 production runtime source。
- 不建立大型 Documentation Knowledge Base。
- 不建立重述 Clean Architecture 的 Feature handbook。
- 不建立大型通用 Troubleshooting Guide。
- 不建立 Architecture Evolution handbook。
- 不建立 Generic Persistence、Repository、DataSource、Pagination或Cache guide。
- 不搬移、拆分、合併或刪除 historical documents。
- 不批量更新所有 README metadata baseline。
- 不補齊所有 legacy metadata。
- 不把 Audit／Plan 變成 current authority。
- 不新增 checker architecture或新的 document type。
- 不發布新的 Template Baseline。
- 不建立 Milestone 27。
- 不修改 CI workflow、native runner、generated source或package dependencies。

## Risks and Controls

### Risk 1 — Guide duplicates ADR

Control：Checklist 只保存 task order、integration point與authority link；formal review逐段檢查是否重述 durable contract。

### Risk 2 — README becomes generic handbook

Control：App與Package README只新增local route，不加入跨repository教學或historical journal。

### Risk 3 — Initiative expands into documentation rewrite

Control：修改檔案白名單固定；新增文件僅限design、plan與review evidence。超出白名單必須重新review design。

### Risk 4 — Roadmap and Backlog lose historical intent

Control：只收斂current disposition，不刪除必要歷史語意；若需要保留過去候選狀態，以短摘要連結本audit與design，而不是保留雙重active listing。

### Risk 5 — Metadata is updated without semantic review

Control：只在實際修改且完成semantic review的managed document上更新metadata；不得批量追平baseline。

## Acceptance Criteria

本 initiative 只有在以下條件全部成立時才可 closure：

1. Feature Guide不再是失效placeholder。
2. Feature Guide沒有重述或取代ADR authority。
3. App README提供可操作的Database與App integration routes。
4. API Client README提供endpoint integration checklist。
5. Audit index可找到近期Milestone、change-aware CI與本次audit evidence。
6. Candidate與Backlog不再雙重列出同一Documentation Knowledge Expansion direction。
7. 沒有新增大型Guide、generic framework或architecture authority。
8. 所有relative links與managed metadata通過checker。
9. `git diff --check`通過。
10. Holistic review沒有open P0／P1 finding。

## Proposed Gate

```txt
Design status: Accepted
Formal design review: Accepted
Open P0 / P1: 0
Implementation plan authorized: Yes
Documentation implementation authorized: No
Milestone promotion authorized: No
Runtime source modification authorized: No
```

下一步進入 implementation plan task。Plan 必須完成相同的 review、fix、re-review、validation與commit閉環後，才可開始 scope內的active documentation implementation。
