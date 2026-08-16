---
document_type: design-spec
status: accepted
authoritative_for:
  - milestone-40-repository-landing-documentation-authority-design
last_reviewed_baseline: 1.20.0
---

# Milestone 40 — GitHub Repository Landing Page & Documentation Authority Restructure Design

## 1. Design status

```txt
Requirement: accepted
Design: accepted / user approved 2026-08-17
Plan: proposed / review in progress
Implementation: forbidden until Plan is accepted
```

本 Design 只設計 repository human-entry 與 documentation authority restructure。它不修改 Flutter production architecture，也不把 root README、架構圖片或任何 Guide 升格成新的 technical authority。

## 2. Confirmed problem model

Current root `README.md` 約 580 行，實際混合以下責任：

1. template positioning／value proposition；
2. Template Baseline 與 Milestone 1～39 狀態；
3. platform capability；
4. template → product adoption；
5. architecture visual 與架構原則；
6. technology map 與 network／storage／design-system／localization details；
7. repository structure、App／Package responsibilities；
8. demo/runtime flow；
9. dependency install／codegen／test／build procedure；
10. Android runtime/security explanation；
11. Flutter Web operational procedure；
12. documentation navigation；
13. development rules；
14. fresh ChatGPT conversation reading instructions。

這些內容中只有 positioning、必要 current capability summary、quick start 與 documentation deep links 符合 `docs/README.md` 對 Human entry 的正式定義。其餘多數已有更精確 owner。

## 3. Design principles

### 3.1 Product landing page first

GitHub repository 首頁的第一責任是讓第一次進入的開發者在短時間內回答：

```txt
這是什麼？
為什麼值得用？
架構長什麼樣？
包含哪些能力？
支援哪些平台？
怎麼從 template 開始？
怎麼快速跑起來？
深入文件在哪？
有哪些限制？
```

Root README 不再回答完整 implementation contract、歷史 Milestone chronology 或 Agent governance procedure。

### 3.2 One fact, one authority

README 只允許：

- 一句至一小段 current summary；
- 必要 machine-readable baseline projection；
- stable deep link。

若某資訊已有 canonical owner，README 不複製完整正文。

### 3.3 Visual summary is presentation, not authority

以下圖片保留原路徑與 authority：

```txt
docs/assets/architecture/productized-topology.png
docs/assets/architecture/c4-dependency-contract.png
```

Root README 直接 inline preview：

```md
![Flutter Enterprise Architecture Template 產品化拓樸](docs/assets/architecture/productized-topology.png)

![Flutter Enterprise Architecture Template C4-style 依賴契約](docs/assets/architecture/c4-dependency-contract.png)
```

圖片只作 human-readable architecture summary。若與 machine manifest、current snapshot、canonical ADR 或 production source 衝突，後者維持 authority。

### 3.4 Short root, deep documentation

目標不是以硬性行數壓縮 README，而是避免 detailed contract 回流。設計目標為「可在 GitHub 首頁完整掃讀」，大致控制在 current README 的 35%～50% 資訊量；不可為達成行數目標而遺失 newcomer critical information。

## 4. Responsibility matrix

| Artifact | Authoritative responsibility after Milestone 40 | Explicit non-responsibility |
|---|---|---|
| root `README.md` | Human／product entry、positioning、visual overview、short capability/platform summary、template adoption CTA、minimum quick start、deep links、limitations summary | Milestone journal、complete architecture contract、full operational guide、Agent policy、full documentation taxonomy |
| `docs/README.md` | Documentation taxonomy、authority map、task-based reading route | Product marketing／landing copy、current architecture正文 |
| `docs/project_context.md` | Full current-only snapshot、current architecture/capability/platform/security claims | Historical Milestone journal、GitHub landing-page presentation |
| `AGENTS.md` | Mandatory AI operating policy、minimal read set、workflow entry | Human product introduction、duplicate tutorial |
| `docs/conversation_rules.md` | Legacy human-readable collaboration summary only；不得擴張成第二份 Agent／README ownership authority | Mandatory AI policy、README complete-current-state contract |
| `docs/governance/documentation_policy.md` | Documentation types、metadata、single authority、migration safety | Full reading route、README prose layout |
| Guides | Reusable procedures／operator workflows | Stable architecture decision、project current snapshot |
| ADR | Stable architecture／governance decisions | Task sequencing、newcomer prose、release history |
| `docs/roadmap*` | Active/candidate/deferred routing | README capability summary、release chronology |
| `docs/milestones/README.md` | Closed／historical milestone artifact routing | Product landing current status list |
| `CHANGELOG.md` | Release history | Human entry、documentation routing |
| `VERSION` | Current version string | Capability explanation |

## 5. Root README target information architecture

Final order：

```txt
1. Hero / Purpose
2. Current Baseline & Platform Support
3. Why This Template
4. Architecture Overview
5. Included Capabilities
6. Start a Product from This Template
7. Quick Start
8. Repository Map
9. Documentation
10. Limitations / Support Boundaries
```

### 5.1 Hero / Purpose

保留 project title，但首屏 copy 改成 2～4 行：

- Flutter Enterprise Architecture Template；
- 適用中大型 Flutter project；
- 強調 Clean Architecture、Feature First、monorepo、product adoption 與 governed documentation；
- 不用 Milestone chronology 開場。

Hero 下方可用純 Markdown badges／短 metadata，但不得引入依賴外部 badge service 才能理解的 critical fact。

### 5.2 Current Baseline & Platform Support

必須保留 machine checker 可辨識的 baseline projection：

```txt
Template Baseline Version：1.20.0
```

Platform 只保存 high-level matrix：

```txt
Android = Supported
iOS = Supported
Web / Windows / macOS / Linux = Dependency-ready
```

iOS physical device、signing／distribution 等細節只保留一句 limitation 並 deep link current snapshot／Guide。

### 5.3 Why This Template

用 4～6 個價值點取代「適合遇到哪些問題」的長清單。建議 owner themes：

- Clear boundaries；
- Production-oriented auth/network/persistence；
- App-owned composition；
- Cross-platform verification；
- Governed template → product adoption；
- Documentation／validation system。

不在此 section 展開套件實作細節。

### 5.4 Architecture Overview

第一張 `productized-topology.png` 是 primary visual，必須 inline。

之後用極短 prose 解釋：

```txt
App = Composition Root
Feature First in app
Reusable contracts in packages
External systems behind explicit boundaries
```

第二張 `c4-dependency-contract.png` 接續 inline，說明 allowed dependency contract。

兩圖後提供：

- `docs/project_context.md` current snapshot；
- `docs/adr/README.md` canonical decisions。

### 5.5 Included Capabilities

把 current detailed technology sections 收斂為 capability groups，而不是依 package／library 列百科：

```txt
Architecture & Composition
Authentication & Session
Networking
Persistence
Design System & Localization
Connectivity & Offline
CI / Validation / Governance
```

每組最多數個 bullet，只陳述 current externally useful capability；exact contracts deep link `docs/project_context.md`、App／Package README 或 Guide。

### 5.6 Start a Product from This Template

保留 `Use this template` newcomer path，因它是本 repository 的核心產品使用方式。

Root README 只說：

1. 使用 GitHub `Use this template` 建立新 repository；
2. 新 repository 依 machine manifest 完成一次性 template → product bootstrap；
3. Android／iOS product identity 與 CI profile 有受治理 procedure。

Detailed prompt、manifest fields、live infrastructure procedure 移交：

- `docs/guides/template_repository_adoption.md`；
- `docs/guides/native_environment_adoption.md`。

### 5.7 Quick Start

Root README 只保留 first-run minimum：

```bash
dart pub get
dart run melos run build_runner
dart run melos run analyze
```

Testing 不在 README 固定宣稱「每次都跑 full workspace」。應使用 current validation governance 的正確入口，例如導向 `AGENTS.md`／testing guide／validation planner；若要提供一個 smoke command，必須與 current planner contract 不衝突。

Environment-specific Android／iOS build commands移出 landing-page正文，改為 deep link native／CI Guide。

### 5.8 Repository Map

保留極簡 tree：

```txt
apps/
packages/
docs/
tools/
AGENTS.md
repository_identity.json
repository_infrastructure.json
VERSION
```

不再在 root README 展開每個 App／Package 的完整 responsibility；細節由 local README 與 current snapshot 擁有。

### 5.9 Documentation

只提供 task-oriented high-value入口：

- Documentation Hub；
- Current Project Context；
- Architecture Decisions；
- Template Adoption；
- Agent-assisted Development Quick Start；
- CI/CD Operations；
- Testing Governance；
- Native Environment Adoption；
- CHANGELOG。

Root README 不複製 AI minimal read set 或完整 docs taxonomy。

### 5.10 Limitations / Support Boundaries

只保存第一次採用 template 前必須知道的 high-level boundary：

- iOS physical-device／Store distribution 不在 baseline claim；
- production signing／store credentials不由 template 預置；
- Web／Desktop為 Dependency-ready，而非 supported runner；
- default identifiers／API domains 是 placeholders；
- exact security limits deep link current snapshot。

## 6. Current README section disposition

Implementation 前必須建立逐 section preservation／migration matrix。Design-level disposition如下：

| Current section | Disposition | Canonical destination／owner |
|---|---|---|
| 專案狀態 | Replace | README保留baseline/platform summary；Milestone chronology由Roadmap／Milestone index／CHANGELOG |
| 從此 Template 開始一個新產品 | Keep + compress | Root README + adoption Guides |
| 專案定位 | Rewrite | Root README human entry |
| 架構視覺總覽 | Promote | Root README inline preview；Project Context保留current summary |
| 技術選型 | Replace with capability summary | Project Context + App/Package README |
| Network detailed flow | Remove from root | Project Context + `packages/api_client/README.md` + relevant ADR |
| Storage details | Remove from root | Project Context + App/Auth/Catalog ownership docs |
| Design System details | Remove from root | Project Context + `packages/design_system/README.md` |
| Localization details | Remove from root | Project Context + relevant README／ADR |
| 專案結構 | Keep + compress | Root README short tree；detailed responsibility in current snapshot/local README |
| Demo Flow | Remove from root | App／Feature READMEs if still useful current fixture documentation |
| Runtime Flow | Replace with tiny architecture summary | Project Context／ADR authority |
| 快速開始 | Keep + reduce to first-run minimum | Root README + Guides／AGENTS for full validation |
| Android runtime/security explanation | Remove from root | Project Context + security ADR／evidence |
| Flutter Web 注意事項 | Remove from root | App README／relevant Guide／current snapshot |
| 文件導覽 | Keep + redesign | Root README deep links only；taxonomy remains `docs/README.md` |
| 開發原則 | Remove duplicate rules | AGENTS／ADR／governance authority |
| 開新對話（給 ChatGPT） | Remove full instructions | AGENTS + `docs/guides/agent_assisted_development_quick_start.md` |

`Remove from root` 不等於刪除資訊。Implementation Task 必須先證明該 current fact 在 canonical owner 已存在；若不存在，先 re-home，再從 README 移除。

## 7. Migration safety contract

因本工作會大幅縮減 root README，Implementation Plan 必須安排一份 section-level preservation matrix，至少記錄：

```txt
source heading
current claim
disposition = keep | compress | re-home | remove-duplicate
target authority
target anchor/path
preservation assertion
```

禁止：

- 先刪 README 再猜哪些資訊需要補回；
- 以「已移到 docs」取代 exact target；
- 把完整 README 舊正文複製到新文件形成 archive-like parallel current authority；
- 為了 preserve 而建立新的 aggregate `docs/readme_details.md`。

## 8. Documentation routing changes

### 8.1 `docs/README.md`

只需在 semantic contract 有變時同步：

- Human entry owner描述應明確為「產品定位、視覺摘要、template adoption、minimum quick start」；
- 不把 root README 列為 release／architecture complete current authority；
- Release route 若仍要求 `Root README current capability`，應改成「README public capability summary consistency」，避免誤解為 complete capability owner。

### 8.2 `docs/project_context.md`

不因 README 重構而複製 landing page prose。只有當 README 移除的 current fact在 Project Context 缺失時才補齊。

Documentation Routing 中的 release wording若需要同步，僅調整 owner語意，不搬入 README section list。

### 8.3 `AGENTS.md`

預設不改。它已擁有 AI minimal read set 與 task route。只有 implementation audit證明 root README removal 使其某條 route失去 target時才修改。

### 8.4 `docs/conversation_rules.md`

Focused audit 已確認 current Rule 5 仍寫：

> README 永遠保持最新；新增啟動方式、驗證方式、平台限制、重要依賴、文件導覽時必須同步更新 README。

這個 wording 會在 Milestone 40 後持續把 detailed current contract 推回 root README，與 Human entry boundary 衝突。

因此 implementation 必須把 Rule 5 收斂為 summary contract：

- README 只同步 public／newcomer-visible summary、baseline、platform high-level claim、first-run entry 與 navigation；
- detailed procedure／dependency／architecture contract更新其 canonical owner，不要求同步複製到 README；
- `AGENTS.md` 與 `docs/README.md` 仍是 executable reading／routing authority。

不得讓 `docs/conversation_rules.md` 反過來重新定義 README section schema。

### 8.5 Guides

預設不新增 Guide。既有：

```txt
template_repository_adoption.md
native_environment_adoption.md
agent_assisted_development_quick_start.md
ci_cd_operations.md
testing_governance.md
```

已涵蓋主要 reusable procedure。禁止為了把 README 變短而新建「README 詳細操作指南」。

### 8.6 Template → Product bootstrap compatibility

`docs/guides/template_repository_adoption.md` 明確把 root `README.md` 列為首次 bootstrap 必須從 template current authority 轉成 product current authority 的檔案之一。

Milestone 40 不改變這個責任：

- template README 的 Hero／Baseline／Start-a-Product wording 必須保持可由 bootstrap procedure安全投影成 product repository human entry；
- product repository完成 bootstrap 後不得仍把自己描述為 template 本體；
- `Template Baseline Version` 與 `Product Repository Version` 的 checker compatibility必須保留；
- 不把 template-only Milestone chronology或 template internal governance prose設計成 bootstrap 必須逐段重寫的固定依賴。

Implementation holistic review 必須把「由 template 建立 product repository 時，README 仍可被 bounded transition」列為 compatibility assertion。

## 9. Docs checker contract

Current `tools/docs/check_docs.py` 會從 root README 解析：

```regex
(?:Template Baseline Version|Product Repository Version)[：:] ... x.y.z
```

Milestone 40 保留此 compatibility contract，README 仍必須含 machine-readable baseline phrase，因此 **預設不修改 checker regex**。

只有 Plan 實作時發現新的 landing-page syntax 無法在不降低可讀性的情況下符合既有 regex，才允許以 TDD 修改 checker；不能為了 cosmetic wording 無必要改 machine contract。

`tools/docs/test_check_docs.py` 同理預設不改。

## 10. ADR gate

Current ADR-011 已擁有 Documentation Single Authority stable principle。本 Design 不建立新的 stable principle，而是讓 root README implementation 回到既有 owner contract。

Disposition：

```txt
New ADR: not required by default
ADR-011 amendment: only if current wording explicitly conflicts with new human-entry boundary
Documentation Policy update: only if owner taxonomy truly changes
```

若 implementation 只重寫 presentation、summary 與 routing，不能因 Level 4 就機械新增 ADR。

## 11. Test authoring / validation design

### 11.1 Test Authoring Decision

預期 disposition：

- README prose／link／inline image：`Should-not-add` new unit tests；由 docs checker + semantic review owner。
- 若修改 baseline parser／link checker：`Required` focused regression fixture before implementation。
- 若修改 change classifier：不在 current scope；需新的 Requirement Decision 或 Design finding證明必要。

### 11.2 Validation Execution

每個 implementation Task exact validation 由 `tools/ci/validation_planner.py` 決定，不在 Design 硬編 full workspace tests。

Design／Plan document Tasks至少需要：

```txt
git diff --check
docs semantic authority review
relevant metadata/link validation
```

Implementation holistic 至少必須覆蓋：

- `dart run melos run docs_check`；
- README relative image/link targets；
- `VERSION`／README／CHANGELOG baseline一致；
- preservation matrix zero unresolved rows；
- current authority contradiction scan；
- `git diff --check`；
- planner-selected validation。

## 12. GitHub rendering acceptance

Markdown syntax correctness不足以代表 landing page acceptance。Holistic review 必須對 source structure 進行 GitHub-rendering-oriented semantic inspection：

1. 頂部 1～2 個 viewport 不再被 Milestone journal淹沒；
2. 第一張 architecture visual 在 architecture section直接可見；
3. 第二張 dependency visual 不透過 click 才能看；
4. heading hierarchy可掃讀；
5. image alt text有資訊性；
6. mobile/narrow GitHub閱讀時不依賴 HTML fixed width；
7. critical links使用repository-relative path；
8. README 不嵌入會造成 authority ambiguity 的 generated status table。

若可用工具無法直接渲染 GitHub，final review 必須明確標示限制，以 source semantic acceptance + relative path verification 作為本地 evidence；不得偽稱已看過 GitHub production render。

## 13. Non-goals and forbidden shortcuts

禁止：

- 重新生成、重畫或替換兩張正式架構圖；
- 使用 image generation；
- 建立 GitHub Pages／docs website；
- 以大量 HTML/CSS 模擬 landing page；
- 使用 collapsible `<details>` 把原本 500+ 行內容全部藏起來假裝精簡；
- 建立新的 aggregate current document承接 README 全部舊內容；
- 把 CHANGELOG／Roadmap／Milestone status 複製成第二份表格；
- 在 Plan acceptance 前修改 root README；
- 因為是 documentation-only 就跳過 Level 4 full review。

## 14. Acceptance criteria

Design implementation最終必須同時滿足：

1. Root README 是清楚的 GitHub product/template landing page，而不是 project journal。
2. `productized-topology.png` 與 `c4-dependency-contract.png` 均直接 inline preview。
3. Baseline machine projection保留且與 `VERSION`／CHANGELOG 一致。
4. Milestone 1～39 詳細清單不再由 root README 維護。
5. Detailed current architecture／capability contract由 Project Context、ADR、App／Package／Feature README或 Guide擁有。
6. Template adoption仍是 prominent newcomer CTA。
7. Quick Start只保留 first-run minimum，不重新引入「每次跑 full tests」的過度驗證敘述。
8. AI continuation／governance rules不再在 README重複完整正文。
9. Preservation matrix每個移除／濃縮 section都有明確 destination／assertion。
10. `docs_check`、links、metadata與planner-selected validation全部PASS。
11. Open P0 = 0；Open P1 without disposition = 0。
12. README 不建立任何 parallel authority。

## 15. Proposed implementation task boundaries

此節只定義 Design boundary，不等同 Implementation Plan：

```txt
M40-1 Preservation / migration matrix
M40-2 Root README product landing rewrite
M40-3 Documentation authority / routing synchronization
M40-4 Docs checker / validation compatibility only if required
M40-5 Holistic documentation + landing-page review
M40-6 Integration / release / post-change closure according to Plan disposition
```

Plan 必須在 Design accepted 後再決定 exact files、commands、commit boundaries與是否需要 release。
