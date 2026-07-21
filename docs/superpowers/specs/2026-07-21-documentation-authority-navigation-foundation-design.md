# Milestone 22 — Documentation Authority & Navigation Foundation Design

## 1. 背景

目前 repository 已演進至 Template Baseline `1.5.0`，並完成 Milestone 1 至 21。

隨著架構、功能、security review、runtime evidence、implementation plan 與 release history 持續增加，現有文件系統逐漸形成以下問題：

- Current state、historical progress、architecture decision、implementation plan、review evidence 與 release history 混在相同文件。
- 多份文件同時描述相同責任，但沒有明確標示哪一份是 authoritative source。
- 已完成 Milestone 的詳細歷史仍留在 AI 每次進入專案的必讀文件。
- 部分早期文件仍以現在式描述已被後續 Milestone 取代的架構。
- 文件名稱與內容責任不一致，例如 `docs/adr/` 目前並非真正 ADR。
- App、Feature 與 Package README 的覆蓋與更新品質不一致。
- 文件增加主要依賴人工同步，沒有制度防止重複、過期與連結失效。

目前的風險不是單純「Markdown 檔案太多」，而是：

```txt
同一事實存在多個版本
  ↓
讀者與 AI 無法可靠判斷 authority
  ↓
可能採用 historical 或 superseded 說法
  ↓
修改錯誤邊界、重複討論或執行不安全操作
```

因此本 Milestone 的第一目標不是大量拆檔，而是先建立一套可長期執行的 Documentation Governance。

---

## 2. 核心目標

Milestone 22 要建立一套可讓文件增長保持可控的制度，使任何未來需求都能依固定流程判斷：

1. 這項資訊屬於哪一種文件類型。
2. 哪份文件擁有 authoritative ownership。
3. AI 執行任務時需要讀哪些文件。
4. 哪些內容只能作為 current state。
5. 哪些內容必須保留為 historical evidence。
6. Architecture Decision、Implementation Plan、Review Evidence 與 Release History 如何分離。
7. 文件完成後何時應封存、更新索引或停止出現在 active reading path。
8. 新增文件時如何避免重複建立新的 SSOT。
9. 文件成長超過合理範圍時如何觸發拆分，而不是任意拆檔。
10. 如何以 automated check 防止 version、link、metadata、README coverage 與 active status 漂移。

最終希望達成：

```txt
需求出現
  ↓
依 Documentation Routing Rule 判斷文件類型
  ↓
只更新唯一 authoritative document
  ↓
其他文件只保留摘要與連結
  ↓
Review 驗證 authority、連結與 metadata
  ↓
Milestone 完成後封存歷史，移出 active reading path
```

---

## 3. 非目標

Milestone 22 不直接完成以下工作：

- 不一次搬移全部 `docs/` 文件。
- 不一次拆完 Decision 001 至 022。
- 不刪除大型歷史文件。
- 不重寫所有 audit、plan 與 milestone evidence。
- 不修改 production runtime behavior。
- 不修改 App、Feature 或 Package architecture。
- 不因文件結構調整而改變既有 architecture decision 的語意。
- 不重新編號既有 Decision、Milestone 或 Finding ID。
- 不建立複雜文件生成 framework。
- 不要求所有歷史文件符合最新 current-state 表述。

Milestone 22 的責任是建立治理基礎、修正危險 current-state 衝突，並為後續安全 migration 建立 review gate。

---

## 4. 核心治理原則

### 4.1 一項資訊只能有一個 Authoritative Owner

同一事實可以出現在多份文件，但只有一份文件可以是 authoritative source。

其他位置只能：

- 提供短摘要。
- 明確連結 authoritative source。
- 不重複完整 contract。
- 不獨立維護另一份可能漂移的版本。

例如：

```txt
Current Template Baseline
  Authoritative: VERSION
  README: 顯示摘要並由 automated check 驗證一致
  Project Context: 顯示摘要並由 automated check 驗證一致
  CHANGELOG: 記錄版本發布歷史
```

### 4.2 Current 與 Historical 必須分離

Current 文件只描述現在有效的事實。

已完成 Milestone 的執行過程、當時下一步、測試數、commit hash 與 phase transition 不得繼續留在 current snapshot。

Historical 文件可以保留當時正確的敘述，不要求回寫成現在狀態，但必須：

- 標示文件類型。
- 標示 Milestone 或 release 時間。
- 不列入 AI 每次必讀。
- 不冒充 current architecture authority。

### 4.3 Decision、Plan、Evidence 與 Release 不得混為同一責任

```txt
Architecture Decision
  回答：為什麼採用這項長期架構規則？

Implementation Plan
  回答：這次要如何安全執行？

Review / Runtime Evidence
  回答：實際檢查了什麼，結果是什麼？

Release History
  回答：哪個正式版本交付了哪些能力？
```

一份文件可以連結其他類型，但不得同時成為所有類型的 authority。

### 4.4 Navigation 優先於複製

文件入口應告訴讀者「去哪裡找」，而不是複製所有內容。

Root README、Docs README、Project Context 與 Roadmap 都應偏向：

- 摘要。
- authority 指引。
- task-based reading route。
- 穩定連結。

### 4.5 文件拆分必須依責任，不依行數

行數與檔案大小只能是警示訊號，不能單獨作為拆分理由。

允許拆分的主要條件：

- 一份文件同時承擔兩種以上 authority。
- 不同區段有不同 update trigger。
- 不同任務只需要其中一部分內容。
- 歷史內容持續污染 current reading path。
- 文件無法在一次 review 中可靠理解。

禁止只因超過固定行數就切成 `part-1`、`part-2`。

### 4.6 Active Reading Path 必須保持小而可信

AI 每次進入 repository 的必讀文件應只包含：

```txt
AGENTS.md
VERSION
docs/README.md
docs/project_context.md
docs/roadmap.md
```

Root README 是人類入口；AI 可依任務或首次接觸情境讀取，但不要求每次全文重讀。

Architecture decisions、Feature README、Package README、plans 與 audits 均採按需讀取。

### 4.7 歷史不可丟失，但不可持續污染 Current State

Migration 採：

```txt
Inventory
  ↓
Classify
  ↓
Copy / Extract
  ↓
Semantic Review
  ↓
Update Index and Links
  ↓
Mark Original as Migrated / Superseded
  ↓
Final Removal only after Review Gate
```

不直接先刪除原文再嘗試補回。

---

## 5. 文件類型與責任

### 5.1 Agent Policy

代表文件：`AGENTS.md`

用途：

- AI coding agent 的操作安全規則。
- 修改流程與禁止事項。
- 文件 routing 規則。
- 最小驗證與 commit 規則。

不得包含：

- 完整 architecture decision。
- 完整 milestone 歷史。
- 大量 implementation details。
- 會快速過時的測試數與 commit hash。

### 5.2 Human Project Entry

代表文件：Root `README.md`

用途：

- 專案定位。
- Current baseline 摘要。
- Capability 與 platform support 摘要。
- Quick Start。
- Repository map。
- 文件入口。

不得成為：

- Architecture Decision SSOT。
- Milestone journal。
- App 細節完整手冊。
- AI 每次恢復流程的唯一 owner。

### 5.3 Documentation Hub

代表文件：`docs/README.md`

用途：

- 文件 taxonomy。
- Authoritative ownership map。
- Task-based reading guide。
- Current、Decision、Plan、Evidence、Archive 的入口。

此文件應是 AI 每次必讀。

### 5.4 Current Project Snapshot

代表文件：`docs/project_context.md`

用途：

- Current baseline。
- Current architecture map。
- Current capability snapshot。
- Current constraints 與 security claim boundaries。
- Active work 狀態。

不得包含：

- 已完成 Milestone 的逐階段日誌。
- 歷史測試數。
- 歷史 commit hash。
- 當時的「下一步」。
- Decision 全文。

### 5.5 Architecture Decision Index

代表文件：`docs/architecture_decisions.md`

最終用途：

- Decision ID、標題、狀態、scope 與連結索引。
- 不再承載所有 Decision 全文。

### 5.6 Architecture Decision Record

目標位置：`docs/decisions/ADR-xxx-*.md`

用途：

- Context。
- Decision。
- Consequences。
- Alternatives。
- Supersedes / superseded by。
- Stable architecture contract。

不得包含：

- 某次 implementation 執行順序。
- 測試數流水帳。
- Release 版本決定。
- 「下一步為某 phase」。

### 5.7 Roadmap Index

代表文件：`docs/roadmap.md`

用途：

- Current active milestone。
- Next candidates。
- Deferred work 入口。
- Closed milestone index。

不得保留每個已完成 Milestone 的完整 plan 與 review journal。

### 5.8 Active Milestone

目標位置：`docs/roadmap/active.md`

用途：

- 當前唯一正式 Milestone。
- Goal、scope、non-goals。
- Current phase 與 gate。
- Next action。
- Related authoritative documents。

同一時間最多只能有一個 active milestone，除非 Decision 明確核准多軌工作。

### 5.9 Candidate Roadmap

目標位置：`docs/roadmap/candidates.md`

用途：

- 已具體化但尚未承諾的候選方向。
- 價值、依賴、風險與預估範圍。

不得放遙遠 idea 或沒有任何範圍定義的想法；這些仍屬 `docs/backlog.md`。

### 5.10 Implementation Plan

代表位置：`docs/superpowers/plans/`

用途：

- 已核准設計的實作步驟。
- 修改範圍。
- Task ordering。
- Tests 與 review gates。

Plan 在 Milestone 完成後變成 historical artifact，不再是 current state authority。

### 5.11 Review / Runtime Evidence

代表位置：`docs/audits/`

用途：

- Planning review。
- Phase review。
- Findings。
- Static、component、artifact、runtime evidence。
- Final review。

Review 文件可以判斷某項 claim 是否有證據，但不得取代 current project snapshot 或 architecture decision。

### 5.12 Milestone Archive

目標位置：`docs/milestones/<milestone>/README.md`

用途：

- Milestone charter 摘要。
- Final status。
- Related decisions。
- Plans、reviews、runtime evidence 與 release 的索引。

初期只建立穩定 manifest，不要求立刻搬動既有 `audits/` 與 `superpowers/plans/`。

### 5.13 App README

目標：`apps/flutter_architecture/README.md`

用途：

- Executable app responsibility。
- Composition Root。
- Entrypoints、environment、router、bootstrap。
- App-owned platform adapters。
- Platform support 與 build commands。

### 5.14 Feature README

用途：

- Feature responsibility。
- Public entrypoints。
- Dependencies。
- Runtime flow。
- State、failure 與 navigation ownership。
- Related decisions 與 tests。

不得複製 package internals 或整個 milestone history。

### 5.15 Package README

用途：

- Package public contract。
- Dependency policy。
- Public exports。
- Lifecycle、concurrency 與 error boundaries。
- Consumers 與 usage。

每個 production package 必須有 README。

---

## 6. Authoritative Scope Rules

下列 scope 必須固定唯一 owner：

| Scope | Authoritative Owner |
|---|---|
| Current Template Baseline | `VERSION` |
| Release changes | `CHANGELOG.md` |
| Current project snapshot | `docs/project_context.md` |
| Current active work | `docs/roadmap/active.md` |
| Candidate priority | `docs/roadmap/candidates.md` |
| Deferred / future ideas | `docs/backlog.md` |
| Architecture decision | 單一 ADR 文件 |
| AI operating rules | `AGENTS.md` |
| Documentation routing | `docs/README.md` |
| App boundary | App README |
| Feature boundary | Feature README |
| Package public contract | Package README |
| Implementation sequence | 已核准 implementation plan |
| Review finding | 對應 audit / findings registry |
| Runtime claim evidence | 對應 runtime evidence 文件 |
| Closed milestone history | Milestone archive manifest |

任何新文件不得宣稱已由其他文件擁有的 authoritative scope。

---

## 7. 文件生命週期

所有 managed documents 必須屬於以下狀態之一：

```txt
Draft
  尚未核准，不得作為實作 authority。

Accepted / Active
  已核准且目前有效。

Completed
  計畫或 review 已完成，但仍可能等待 Milestone 封存。

Archived
  歷史 artifact，不在 active reading path。

Superseded
  已被新文件取代，保留歷史與指向新 authority。

Deprecated
  暫時仍存在，但不應新增依賴。
```

### 7.1 新需求進入流程

```txt
需求提出
  ↓
判斷是否改變 current state、architecture 或只是 implementation
  ↓
Architecture change?
  ├── 是 → 建立 / 更新 ADR draft
  └── 否 → 不建立 ADR
  ↓
建立 design / planning review
  ↓
核准後建立 implementation plan
  ↓
執行與 phase review
  ↓
final review
  ↓
更新 current SSOT、README、CHANGELOG / VERSION（需要時）
  ↓
建立 milestone archive manifest
  ↓
plan、audit、evidence 轉 Archived
```

### 7.2 Milestone 封存觸發

Milestone final review 通過後必須：

- Active roadmap 移除該 Milestone。
- Roadmap index 將其標為 Closed / Archived。
- 建立或更新 milestone archive manifest。
- Current Project Context 只保留交付後的 current capability。
- Detailed plan、phase result 與測試數移出 active documents。
- CHANGELOG 只保留 release summary。

---

## 8. Controlled Growth Rules

### 8.1 新增文件前必須先回答

1. 這是新的 authority，還是既有 authority 的補充？
2. 哪一種 document type？
3. 誰會在什麼任務中讀取？
4. 它的 update trigger 是什麼？
5. 完成後會變成 current、archived 或 superseded？
6. 是否已經存在相同 scope 的文件？

若無法回答，不應直接新增文件。

### 8.2 Current 文件禁止追加歷史流水帳

Current 文件更新採 replacement，不採永久 append。

例如 Milestone 完成時：

```txt
錯誤：
在 project_context.md 末尾新增完整 Milestone 22 執行歷史。

正確：
更新 Current Capability Snapshot，並連結 Milestone 22 archive。
```

### 8.3 摘要長度限制

非 authoritative 文件引用另一 scope 時：

- 原則上只保留 1 至 5 個 bullet。
- 複雜 contract 直接連結 authoritative document。
- 不複製完整 decision matrix、state machine 或 test matrix。

### 8.4 Growth Budget

下列不是硬性失敗條件，但達到後必須 review 是否責任失控：

| 文件 | Review threshold |
|---|---:|
| `AGENTS.md` | 200 行 |
| `docs/README.md` | 200 行 |
| `docs/project_context.md` | 350 行 |
| `docs/roadmap.md` | 150 行 |
| `docs/roadmap/active.md` | 300 行 |
| Root README | 500 行 |
| 單一 ADR | 800 行 |
| Feature / Package README | 400 行 |

超過 threshold 不代表必須拆檔；必須先進行 responsibility review。

### 8.5 Active Context Budget

AI 每次必讀文件總量的目標：

```txt
不超過約 750 行
不包含 historical phase journal
不包含完整 release history
不包含全部 ADR 正文
```

### 8.6 禁止平行 SSOT

以下行為禁止：

- 在 README 與 Project Context 各自維護完整 package contract。
- 在 Roadmap 與 Implementation Plan 各自維護完整 task checklist。
- 在 ADR 與 Audit 各自維護完整 architecture decision。
- 在 CHANGELOG 與 Milestone Archive 各自維護完整 implementation journal。

---

## 9. Metadata Contract

新建立或完成 migration 的 managed documents 應採 YAML front matter：

```yaml
---
document_type: architecture-decision
id: ADR-022
status: accepted
authoritative_for:
  - authentication-security-capability-boundaries
last_reviewed_baseline: 1.5.0
related_documents:
  - ../milestones/m21-local-session-unlock/README.md
---
```

必要欄位依 document type 不同，但至少應能表達：

- `document_type`
- `status`
- `authoritative_for`
- `last_reviewed_baseline`
- `related_documents`

Decision、Milestone、Finding 另有穩定 ID，不得重新編號。

Historical 文件不必一次全部補 metadata；採 touched-file 與 phased migration 原則。

---

## 10. AI Reading Contract

### 10.1 每次進入 repository

必讀：

```txt
AGENTS.md
VERSION
docs/README.md
docs/project_context.md
docs/roadmap.md
```

### 10.2 Architecture task

再讀：

```txt
docs/architecture_decisions.md
相關 ADR
相關 App / Feature / Package README
```

### 10.3 Feature task

再讀：

```txt
該 Feature README
依賴 Package README
相關 ADR
相關 source 與 tests
```

### 10.4 Package task

再讀：

```txt
該 Package README
相關 ADR
Consumers
Package tests
```

### 10.5 Active Milestone execution

再讀：

```txt
docs/roadmap/active.md
Milestone charter / design
核准的 implementation plan
目前 phase review
```

### 10.6 Review / release task

再讀：

```txt
Milestone findings
Phase reviews
Runtime evidence
Final review
CHANGELOG
VERSION
```

禁止在一般任務中無條件載入全部 audits、全部 plans 或全部 ADR 正文。

---

## 11. README Contract

### 11.1 Root README 固定章節

```txt
Purpose
Current Baseline
Capabilities
Platform Support
Quick Start
Repository Map
Documentation
Limitations
```

### 11.2 App README 固定章節

```txt
Purpose
Owned Responsibilities
Composition Root
Entrypoints and Environments
Bootstrap and Navigation
Platform Adapters
Persistence Ownership
Run / Build / Test
Related Decisions
```

### 11.3 Feature README 固定章節

```txt
Purpose
Owned Responsibilities
Non-responsibilities
Public Entrypoints
Dependencies
Runtime Flow
State / Failure / Navigation Ownership
Tests
Related Decisions
Last Reviewed Baseline
```

### 11.4 Package README 固定章節

```txt
Purpose
Public Contract
Owned Responsibilities
Non-responsibilities
Dependency Policy
Public Exports
Lifecycle / Concurrency / Error Rules
Consumers
Tests
Related Decisions
Last Reviewed Baseline
```

每個 production App、Feature 與 Package 都必須有 README，除非該目錄只包含 generated 或純 private implementation，且其 parent README 已明確涵蓋。

---

## 12. Automation Foundation

Milestone 22 應建立低風險文件檢查，不建立複雜生成系統。

第一版至少檢查：

- Markdown relative links 存在。
- `VERSION` 與 Root README current baseline 一致。
- `VERSION` 與 CHANGELOG 最新正式版本一致。
- production App、Feature、Package README coverage。
- Decision ID uniqueness。
- Finding ID uniqueness。
- active milestone 最多一個。
- Archived milestone 不得同時標記 Active。
- `docs/adr/` placeholder 不得被視為 accepted ADR。
- `docs/README.md` 的主要索引連結存在。

後續可增加：

- metadata schema。
- authority scope uniqueness。
- superseded link validity。
- Open P0 / P1 final review gate。
- stale phrase denylist。

Automation 的責任是發現 inconsistency，不是自動重寫自然語言內容。

---

## 13. Migration Safety Contract

### 13.1 Migration Manifest

大型文件拆分前，必須建立 manifest：

```txt
Source file
Source heading
Original responsibility
Target document
Target document type
Disposition
Migration status
Review status
```

### 13.2 Stable IDs

必須保留：

- Decision 001 至 022。
- Milestone 1 至 22。
- Finding ID。
- Release version。

### 13.3 Semantic Review

Migration review 不只比較文字是否存在，還要確認：

- Stable architecture contract 沒有被誤移至 historical-only 文件。
- Historical result 沒有被誤升格為 architecture rule。
- Current capability 沒有因拆分而遺失。
- Link 指向正確 authority。
- Superseded relationship 清楚。

### 13.4 Transitional Stub

舊路徑如有大量 inbound links，先保留 moved / superseded stub，至少跨一個正式 baseline 再評估刪除。

---

## 14. Milestone 22 建議階段

### 22-0 Documentation Governance Planning Review

- 對本設計進行正式 review。
- 建立完整 finding registry。
- 驗證所有主要文件、README、目錄與引用關係。
- 拍板 document types、authority、metadata 與 migration gate。
- 本階段不修改 production code，不大規模搬檔。

### 22-1 Current-State Contradiction Remediation

- 修正會誤導 AI 的 P0 / P1 current-state 衝突。
- `docs/adr/` 與早期 `docs/architecture/` 加入明確 Historical / Placeholder 標示。
- 修正 Root README、Auth README、Shell README 的已知錯誤 current claim。
- 不進行完整拆分。

### 22-2 Documentation Index & AI Reading Contract

- 重寫 `docs/README.md`。
- 精簡 `AGENTS.md` 的 reading route。
- 建立 audit、decision、milestone index。
- 明確區分每次必讀與按需讀取。

### 22-3 Current Project Snapshot Rewrite

- 重寫 `docs/project_context.md` 為 current snapshot。
- 將 historical milestone journal 建立 migration manifest。
- 不直接刪除尚未完成語意搬移的原始內容。

### 22-4 Roadmap Active / Candidate Separation

- 將 `docs/roadmap.md` 收斂為總入口。
- 建立 `docs/roadmap/active.md` 與 `docs/roadmap/candidates.md`。
- Completed milestone 只保留 archive link。

### 22-5 README Coverage Baseline

- 新增 App README。
- 新增 `packages/core`、`packages/api_client`、`packages/auth` README。
- Review 所有 Feature README 與 Design System README。
- 建立 fixed templates 與 coverage check。

### 22-6 Documentation Lint Foundation

- 建立 link、version、README coverage、ID uniqueness 與 active status check。
- 提供單一 workspace command。
- 不建立過度嚴格 prose formatting lint。

### 22-7 Final Review & Decision Extraction Gate

- 執行完整 consistency review。
- 確認沒有 Open P0 / P1。
- 確認 active reading path 已顯著縮小。
- 建立 Decision 001 至 022 extraction manifest。
- 決定下一個 Milestone 是否進入 ADR extraction 與 milestone archive normalization。

---

## 15. Milestone 22 完成定義

- 文件類型與 authoritative ownership 已正式拍板。
- AI 每次必讀文件不再包含大量 historical journal。
- Current Project Context 只描述現在有效狀態。
- Roadmap 明確區分 active、candidate、backlog 與 archived milestone。
- P0 / P1 current-state contradiction 已消除。
- Root、Docs、Archive、App、Feature、Package README 都有明確 contract。
- 所有 production App、Feature、Package README coverage 完整。
- Migration manifest 可追蹤大型文件每個 section 的 disposition。
- 基本 documentation check 可在本地執行。
- 不遺失 Decision、Milestone、Finding 與 Release history。
- 沒有修改 production runtime behavior。
- Decision 001 至 022 尚未被粗暴拆分；下一階段 extraction 有完整 review gate。

---

## 16. 成功判準

完成後，一個新的 AI agent 應能在不讀取全部歷史文件的情況下，可靠回答：

```txt
目前版本是什麼？
目前有沒有 active milestone？
目前架構與 package 邊界是什麼？
某項架構規則由哪份 Decision 擁有？
修改某個 Feature 前需要讀哪些文件？
某個已完成 Milestone 的 plan、review 與 runtime evidence 在哪裡？
新增需求時應更新 current、decision、plan、evidence 還是 changelog？
```

文件增長應從「每次同步多份大文件」改為：

```txt
更新唯一 authority
  +
更新必要索引與摘要
  +
完成 review / automation check
```

這是後續所有需求都必須遵循的 Documentation Governance 基線。

---

## 17. 固定小階段執行與 Review Protocol

Milestone 22 自 22-0 起，各小階段固定使用以下流程：

```txt
執行該階段 Task 1
  ↓
立即 review Task 1
  ↓
有問題就修正並再次 review
  ↓
通過後直接進入 Task 2
  ↓
重複直到該階段所有 Tasks 完成
  ↓
針對整個小階段進行一次 implementation review
  ↓
修正 finding 並重新 review
  ↓
通過後提交
```

執行期間不需要逐 Task 等待使用者確認，也不需要逐 Task 回報；只有在整個小階段完成、整體 review 通過並提交後，才統一回報結果。

每個 Task review 至少確認：

- Task scope 沒有越界。
- 沒有提前執行後續小階段工作。
- 新增或修改內容具有單一 authoritative owner。
- Current、Decision、Plan、Evidence、Release 與 Archive 沒有重新混合。
- 連結、metadata、baseline、status 與 terminology 一致。
- 沒有遺失原始資訊或改寫歷史事實。

小階段 implementation review 需重新跨 Task 檢查：

- Task 之間是否存在責任衝突或重複 SSOT。
- 是否引入新的 stale current statement。
- 是否符合本設計的 growth budget、reading contract 與 migration safety contract。
- 是否仍有 Open P0／P1 finding。
- 是否具備提交所需的 verification evidence。
