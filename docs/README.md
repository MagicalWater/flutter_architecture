---
document_type: documentation-hub
status: active
authoritative_for:
  - documentation-taxonomy-and-reading-routing
last_reviewed_baseline: 1.15.2
---

# Documentation Hub

本文件是 repository 文件系統的正式入口。它只負責文件分類、authority 與讀取路由，不重複保存架構正文、Milestone 執行內容或 release history。

目前 Template Baseline 以 root `VERSION` 為唯一版本來源。

## 核心規則

一項資訊只能有一個 authoritative owner。其他文件可以摘要並連結，但不得建立平行 Single Source of Truth。

文件分為以下類型：

| 類型 | Authoritative scope | 主要位置 |
|---|---|---|
| Agent policy | AI 操作規則、禁止事項、讀取路由 | `AGENTS.md` |
| Human entry | 專案定位、能力、快速開始 | root `README.md` |
| Current snapshot | 目前有效架構、能力與限制 | `docs/project_context.md` |
| Architecture decision | 已拍板且仍有效的架構規則 | `docs/adr/README.md` 與 canonical ADR records |
| Roadmap | Active、candidate、deferred 與 closed routing | `docs/roadmap.md` |
| Backlog | 尚未承諾、延後或明確不做的 scope | `docs/backlog.md` |
| Design / implementation plan | 已核准設計與執行步驟 | `docs/superpowers/` |
| Review / runtime evidence | Findings、review 結果與可重現證據 | `docs/audits/` |
| Milestone routing | Milestone charter、plan、review、release 的索引 | `docs/milestones/` |
| Historical archive | 已封存且不再代表 current state 的內容 | `docs/archive/` |
| Governance | 文件類型、metadata、生命週期與增長規則 | `docs/governance/` |
| Reusable guide | 使用者操作、CI、測試、環境採用等可重複程序 | `docs/guides/` |
| Design source | Repository-local `.pen`與直接衍生／參考檔案 | `docs/design_sources/` |
| Visual authority | Source ranking、raw hash、canonical viewport與supersession contract | `docs/visual_authority/` |

完整文件治理規則與 minimal metadata contract 見 `docs/governance/documentation_policy.md`。

## 每次進入 repository 的最小讀取集

```txt
AGENTS.md
VERSION
docs/README.md
docs/project_context.md
docs/roadmap.md
```

這是固定最小集合，不代表所有任務都只能讀這些文件。完成最小讀取後，再依任務類型按需載入局部文件。

`docs/project_context.md` 已於 22-3 收斂為 current-only snapshot；`docs/roadmap.md` 已於 22-4 分離為 index、active 與 candidates。歷史 milestone 細節應改由 Milestone、Audit、Plan、Archive 與 Git history 路由，不再從 current 文件讀取。

## 任務式讀取路由

### Architecture task

```txt
最小讀取集
→ docs/adr/README.md 的相關 ADR
→ 受影響 App／Feature／Package README
→ 相關 source 與 tests
```

只有會改變穩定責任邊界、dependency direction、persistence authority、runtime ownership 或 security contract 的變更，才需要新增或更新 Architecture Decision。

### Feature task

```txt
最小讀取集
→ apps/flutter_architecture/lib/features/<feature>/README.md
→ 相關 Decision
→ 該 Feature source 與 tests
```

### Package task

```txt
最小讀取集
→ packages/<package>/README.md
→ 相關 Decision
→ package public API、source 與 tests
```

所有 production App、Package 與 Feature 都已有 local README。修改前先讀對應 README，再依 task route 載入相關 Decision、source 與 tests。

使用者若需要可直接複製的新功能、畫面、Bug、Refactor、Migration或discussion-only對話起頭，先讀`docs/guides/agent_assisted_development_quick_start.md`；該Guide只提供操作入口，不取代Feature README、Decision或中央治理Skill。

### Active Milestone execution

```txt
最小讀取集
→ active roadmap entry
→ Milestone design spec
→ implementation plan
→ planning review
→ 當前 phase review
```

Plan 只描述「怎麼做」，不代表工作已完成。完成狀態以 current roadmap、phase/final review、CHANGELOG 與 VERSION 判斷。

### Review / runtime evidence task

```txt
最小讀取集
→ 相關 Decision 與 current contract
→ implementation plan
→ phase review / findings
→ source、tests、artifact 或 runtime evidence
```

Audit 文件保存當時的 review 與 evidence，不取代 current snapshot 或 Architecture Decision。

### Pencil-to-Flutter design implementation

```txt
最小讀取集
→ Accepted Requirement／Design／Plan
→ docs/visual_authority/<initiative>/manifest.md
→ docs/design_sources/<initiative>/ primary source
→ ADR-028
→ loaded repository-local Skill provenance
→ Pencil MCP admission／Flutter mapping／visual validation evidence
```

`.pen`只透過Pencil MCP讀取或修改；external absolute path、PNG或historical Flutter screenshot不得取代repository-local source authority。

可直接重用的人類操作順序、third-party Skill pin／discovery、Pencil admission、Flutter mapping、visual acceptance與copyable prompt見[`docs/guides/pencil_to_flutter_workflow.md`](guides/pencil_to_flutter_workflow.md)。Skill需要fresh behavioral pressure evidence而automated harness不可用時，使用[`docs/guides/skill_behavioral_validation.md`](guides/skill_behavioral_validation.md)的provider-neutral fresh-chat protocol。這些Guide都不取代ADR、accepted artifacts或domain Skill。

### Release task

```txt
VERSION
CHANGELOG.md
Milestone final review
Root README current capability
相關 current snapshot / Decision
```

### Historical investigation

```txt
docs/milestones/README.md
→ 對應 audits / plans / final review
→ docs/archive/（如已有封存摘要）
```

Historical 文件可以解釋「當時為什麼這樣做」，但不得直接覆蓋 current authority。

## 類型索引

- `docs/audits/README.md`：Planning Review、phase review、final review、findings 與 runtime evidence。
- `docs/superpowers/README.md`：Design specs 與 implementation plans。
- `docs/milestones/README.md`：Milestone routing 與 archive manifest 入口。
- `docs/archive/README.md`：已明確封存的歷史內容。
- `docs/governance/documentation_policy.md`：文件治理與 metadata contract。
- `docs/governance/development_workflow.md`：需求分類、Superpowers、雙層Task、Skill registry與repository-local workflow／feature shortcut的治理總覽。
- `docs/design_sources/README.md`：Repository-local design source與external admission boundary。
- `docs/visual_authority/README.md`：Visual manifest contract、source ranking、hash與canonical viewport routing。
- `docs/guides/`：可重複使用的操作指南；AI Agent日常入口與可複製Prompt請讀`docs/guides/agent_assisted_development_quick_start.md`，accepted `.pen`到Flutter請讀`docs/guides/pencil_to_flutter_workflow.md`，fresh isolated-agent Skill behavioral validation請讀`docs/guides/skill_behavioral_validation.md`，CI／Branch Protection操作請讀`docs/guides/ci_cd_operations.md`，測試owner、historical boundary與cleanup規則請讀`docs/guides/testing_governance.md`，native environment與產品識別採用請讀`docs/guides/native_environment_adoption.md`。
- `docs/mistakes/`：已知反模式與錯誤案例。
- `docs/evolution/`：架構演進知識入口。

## Legacy 路徑

- `docs/architecture/` 是第一階段 historical／partially superseded guidance。
- 舊aggregate decision與已標記legacy的相容路徑只供歷史追溯；current Architecture Decision authority仍由`docs/adr/README.md`與canonical ADR records擁有。

Historical／legacy文件保留路徑與必要warning，避免歷史遺失與連結立即失效；它們不得覆蓋canonical ADR records或其他current authority。

## 摘要規則

索引或入口文件只允許保存足以導航的摘要：

- 說明 authority 在哪裡。
- 說明何時需要讀取。
- 說明文件目前 status。
- 提供穩定連結。

禁止在索引中複製完整架構 contract、逐 Task implementation journal、測試流水帳或 release evidence。

## Metadata adoption

Milestone 22 之後新增或正式採納的 managed document 使用 `document_type`、`status`、`authoritative_for` 與 `last_reviewed_baseline`。既有文件不批量補標；只有重寫、搬移、成為 managed index 或重大修改時，才經 semantic review 後採納。

## 語言

文件、README、註解與 commit message 預設使用繁體中文；套件名稱、架構名詞、Layer、類別與 API 名稱保留英文。
