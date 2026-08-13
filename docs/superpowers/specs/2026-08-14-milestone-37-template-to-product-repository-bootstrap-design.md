---
document_type: design-spec
status: accepted
authoritative_for:
  - milestone-37-template-to-product-repository-bootstrap-design
last_reviewed_baseline: 1.17.0
---

# Milestone 37 — Template-to-Product Repository Bootstrap & Adoption Governance Design

## 1. Goal

讓 `flutter_architecture` 作為 GitHub Template Repository 建立出的新產品 repository，能以最少人工提示完成一次性的 Template → Product bootstrap，並在完成後由 repository current authority 自行表達「我是什麼產品、源自哪個 template baseline、目前產品版本是多少」，使任何 fresh Agent conversation 都不依賴聊天記憶即可正確 admission。

本 Design 只處理「新產品 repository 怎麼出生」。它不規劃產品需求、MVP、Feature、UI、Backend、產品 roadmap 或後續 feature workflow。

## 2. Design Principles

### 2.1 GitHub Template，不使用長期 Fork 關係

正式 newcomer flow：

```txt
flutter_architecture
→ GitHub Use this template
→ 建立新的 product repository
→ clone product repository
→ 首次 Agent bootstrap
```

產品 repository 應擁有獨立 Git history、release history、issues、PR、permissions 與 lifecycle。Template origin 由 repository metadata 保存，不以 Git fork parent relationship 作為 product identity authority。

### 2.2 Repository current authority 必須自足

首次 bootstrap 完成後，fresh conversation 只讀 repository current authority 就必須能知道：

- concrete product name；
- repository lifecycle 已是 product；
- adopted template baseline；
- current product version；
- 首次 bootstrap 已完成。

不得依賴：

- previous chat memory；
- handoff prompt；
- GitHub repository description；
- repository folder name；
- remote repository name；
- package／bundle identifier 的猜測。

### 2.3 不建立第二份 native identity authority

Android／iOS identity、environment display-name mapping 與 manifest-first replacement 仍由現有：

```txt
adopting-template-product-identity
docs/guides/native_environment_adoption.md
apps/flutter_architecture/config/environments.json
ADR-014 / ADR-025
```

擁有。

Milestone 37 只新增 repository bootstrap orchestration 與 repository identity／provenance authority。

### 2.4 不讓 human-readable prose 單獨承擔 machine lifecycle state

Agent admission 是 repository-wide blocking decision。若只從 README 或 `docs/project_context.md` 的自然語言推斷 `template | product`，容易因 wording drift、翻譯或段落重寫而誤判。

因此 lifecycle state 必須有穩定的 machine-readable authority；human-readable current docs 應投影該 authority，而不是反過來由 prose 隱式推導。

## 3. Repository Lifecycle Model

定義兩個正式狀態，不建立永久的第三種「fresh product」狀態：

```txt
template
product
```

理由：

- `Use this template` 建立的新 repository 在 bytes 層面仍是 `template`；
- 「fresh product 尚未 bootstrap」是使用者 intent + template state 的暫時 admission 情境，不應成為長期 repository state；
- bootstrap 完成後單向轉為 `product`。

狀態轉換：

```txt
template
  │
  │ accepted Template → Product bootstrap
  ▼
product
```

本 Milestone 不設計 `product → template` 回轉，也不設計 product 間 clone identity reset。

## 4. Canonical Repository Identity Manifest

### 4.1 Decision

新增一個極小、App-independent、repository-root machine-readable manifest：

```txt
repository_identity.json
```

理由：

- `docs/project_context.md` 是 human-readable current snapshot，不適合作為 blocking lifecycle parser contract。
- `VERSION` 只應表示 current repository release version，不應同時承擔 template provenance。
- `apps/flutter_architecture/config/environments.json` 是 App native environment authority，不應升格成 repository identity authority。
- 另建 manifest 可清楚避免 ownership 混淆，欄位極少且穩定。

### 4.2 Template State Schema

模板本體：

```json
{
  "schema_version": 1,
  "repository_kind": "template",
  "product_name": null,
  "template_origin": {
    "repository": "MagicalWater/flutter_architecture",
    "baseline": "1.17.0"
  }
}
```

`template_origin.baseline` 在模板本體中必須與 `VERSION` 一致。

### 4.3 Product State Schema

產品 repository bootstrap 完成後：

```json
{
  "schema_version": 1,
  "repository_kind": "product",
  "product_name": "找團體打籃球",
  "template_origin": {
    "repository": "MagicalWater/flutter_architecture",
    "baseline": "1.17.0"
  }
}
```

Product current version **不重複存入 manifest**，由 root `VERSION` 單獨擁有。

這避免：

```txt
repository_identity.json product_version
VERSION
```

形成雙 authority。

### 4.4 Manifest Non-Goals

不得放入：

- bundle identifier；
- API domain；
- environment mapping；
- signing metadata；
- Store metadata；
- roadmap；
- feature list；
- current milestone；
- product description；
- template update channel。

## 5. Version Semantics

### 5.1 Template

在 `repository_kind = template` 時：

```txt
VERSION = Template Baseline Version
```

例如：

```txt
1.17.0
```

### 5.2 Product

Template → Product bootstrap 完成時，root `VERSION` 重設為：

```txt
0.1.0
```

此後：

```txt
VERSION = Product Repository Version
```

採用來源則永久保存在：

```txt
repository_identity.json
→ template_origin.baseline
```

選擇 `0.1.0` 而非 `0.0.1`：

- 表示已形成正式 product repository baseline，但尚未達 1.0 product release；
- 與模板 `1.x` baseline 清楚分離；
- 不要求產品第一個正式市場版本一定是 `1.0.0`。

若 adopter 有既定 version policy，可在首次 bootstrap Requirement Decision 明確 override；不得由 Agent猜測。

## 6. First-Agent Admission Contract

### 6.1 Minimal User Input

第一次開啟新 product repository，使用者不需要知道 Skill 名稱或 internal files。

最小 prompt：

```txt
@bridge-win 請開啟：
D:\Developer\pickup-basketball

這是剛從 flutter_architecture template 建立的新產品 repository。

產品名稱：找團體打籃球
Base identifier：com.mgwater.pickupbasketball
```

若 development／staging／production 顯示名稱未提供，Agent 可以提出候選值，但在 mutation 前必須取得使用者確認；既有 `adopting-template-product-identity` 的 input gate 不變。

### 6.2 Admission Decision

中央 `governing-template-development` fresh admission 必須讀取 `repository_identity.json`。

情境：

| Manifest | User intent | Routing |
|---|---|---|
| `template` | 維護模板 | 正常 template governance |
| `template` | 明確表示由模板建立新產品 | Template → Product bootstrap |
| `product` | 一般產品工作 | 正常 product repository governance |
| `product` | 要再次做首次 adoption | 阻止重複 bootstrap，重新分類為 bounded identity change |
| missing／invalid | 任意 | fail closed；先修復 repository identity authority |

不得只因 remote URL 不再是 `MagicalWater/flutter_architecture` 就自動判定為 product；GitHub template clone 的 origin 會自然變成新 repo，但 repository bytes 在 bootstrap 前仍是 template state。

## 7. Bootstrap Orchestration Skill

新增薄型 repository-local Skill：

```txt
adopting-template-repository
```

### 7.1 Responsibility

只處理：

- accepted Template → Product bootstrap routing；
- required input gate；
- repository identity manifest transition；
- repository current docs transition；
- VERSION reset；
- delegation to `adopting-template-product-identity`；
- final fresh-admission evidence。

### 7.2 Mandatory Delegation

```txt
adopting-template-repository
→ governing-template-development
→ accepted Requirement Decision
→ repository bootstrap orchestration
→ adopting-template-product-identity（native identity portion）
```

Skill 不得自行核准 Design／Plan、不自行修改 environment contract、不承擔 signing／Store responsibility。

### 7.3 Why Not Expand Existing Product Identity Skill

`adopting-template-product-identity` 已有窄且 Approved 的 trigger：cross-platform native product identity adoption。

將 repository lifecycle、VERSION、README、project context、provenance 全塞入該 Skill 會：

- 改變既有 trigger 語意；
- 混淆 repository identity 與 native app identity；
- 增加 regression surface；
- 使 API-only / bounded native repair routing 更難維持。

因此新增薄型 orchestration Skill，既有 Skill 保持 subordinate domain authority。

## 8. Repository Identity Transition

Bootstrap implementation 至少處置以下 current authority：

### 8.0 Atomic Completion Boundary

Bootstrap 可以在受治理的 branch／worktree 內逐步修改 repository identity、native identity 與 current docs，但 persistent lifecycle state 必須保持原本的 `template`，直到所有本次 Requirement Decision 所要求的 repository identity、native identity、docs 與 blocking verification 都通過。

只有在 closure 的最後一步，才允許：

```txt
repository_kind: template → product
```

如果任何 required validation 失敗：

- `repository_kind` 必須仍是 `template`；
- 工作維持 open／blocked；
- 不得讓 fresh Agent 把半完成 repository 視為已採用產品；
- 不新增持久的 `bootstrapping` 第三狀態。

Implementation Plan 必須把 final lifecycle transition 放在所有 required bootstrap mutation 與 blocking validation之後。

### 8.1 `repository_identity.json`

```txt
repository_kind: template → product
product_name: null → confirmed product name
template_origin: 保留 template repository + adopted baseline
```

### 8.2 `VERSION`

```txt
Template baseline → Product version 0.1.0
```

或使用 accepted Requirement Decision 的 explicit initial product version。

### 8.3 Root `README.md`

不得再宣稱 current repository 本身是 Flutter Enterprise Architecture Template。

產品 repository README 至少應表達：

- product name；
- current repository 是由 Flutter Enterprise Architecture Template 衍生；
- adopted template baseline；
- architecture／governance docs仍可從現有 docs hub進入。

Milestone 37 不產生產品功能說明或產品 roadmap內容。

### 8.4 `docs/project_context.md`

從 template current snapshot 轉為 product repository current snapshot：

- Repository purpose 改為 concrete product repository；
- 保存 template origin；
- current product version 使用 `VERSION`；
- 不再把 template Milestone 1～37 當成產品 active roadmap；
- template capabilities 可保留為 inherited foundation summary，但必須清楚標記是 adopted foundation，而不是產品 milestone history。

### 8.5 Roadmap

`docs/roadmap.md` 與 `docs/roadmap/active.md` 在 product bootstrap 時重設為 product-owned current roadmap authority。

Bootstrap 只建立最小空狀態：

```txt
Active milestone: None
Product roadmap: Not yet defined
```

不得自動替產品規劃 MVP／Milestone／Feature。

Template歷史 roadmap 仍存在於 Git history，不需要複製到 product current roadmap。

### 8.6 CHANGELOG

重設為產品 changelog，第一筆只記錄 repository bootstrap：

```txt
0.1.0 — Product repository bootstrap from Flutter Enterprise Architecture Template 1.17.0
```

不得把 template 1.x release history 冒充產品 release history。

## 9. Documentation Authority

新增一份窄 Guide：

```txt
docs/guides/template_repository_adoption.md
```

只回答：

1. 在 GitHub 使用 `Use this template` 建立新 repository；
2. clone；
3. 第一次如何對 Agent 提供最小資訊；
4. Agent bootstrap 會做哪些 repository-level transition；
5. 哪些資訊需要 adopter 確認；
6. 完成後如何判定 repository 已是 product；
7. native identity exact procedure 導向既有 `native_environment_adoption.md`。

不得加入產品規劃、feature開發、MVP模板或 roadmap 教學。

Quick Start 只新增此場景的入口與可複製 prompt，不複製完整 procedure。

## 10. Machine Verification

新增 repository identity verifier，位置建議：

```txt
tools/docs/verify_repository_identity.py
```

由 `docs_check` 或相鄰 repository governance check 執行。

### 10.1 Template Invariants

當 `repository_kind = template`：

- `product_name == null`；
- `template_origin.repository` 等於 canonical template repository；
- `template_origin.baseline == VERSION`；
- current project context 明確為 Template；
- native environment default identifiers仍可依既有 verifier獨立檢查。

### 10.2 Product Invariants

當 `repository_kind = product`：

- `product_name` 非空；
- `template_origin.repository` 非空；
- `template_origin.baseline` 是合法 SemVer；
- `VERSION` 是合法 Product SemVer；
- root README / project context 不得把 current repository 宣稱為 template；
- product current roadmap 不得把 inherited template milestone ledger 當 current product roadmap。

Verifier 不解析自然語言來推導 product name；machine fields仍以 manifest為準，docs checker只驗證 required marker／projection presence。

## 11. Test Authoring Strategy

本 Milestone 不以「新增一個檔就新增一個 test」方式執行。

預期 Required owners：

- repository identity manifest parser／verifier invalid-state fail-closed；
- template/product lifecycle invariants；
- Skill routing pressure scenarios，尤其重複 bootstrap、missing manifest、product repo誤觸首次 adoption；
- bootstrap transition 的 focused fixture／isolated repository evidence。

預期 Should-not-add：

- README 每一句文字的 snapshot test；
- 每個 JSON field 的 getter test；
- 重複既有 native environment verifier 的 Android／iOS contract tests。

## 12. Acceptance Contract

### A. Template Repository Acceptance

在 current template repository fresh checkout：

- `repository_identity.json` = `template`；
- identity verifier PASS；
- current template docs仍正確；
- native environment verifier PASS。

### B. Fresh Product Bootstrap Acceptance

建立 isolated copy 模擬 GitHub `Use this template` 產生的新 repo：

1. 初始 manifest仍為 `template`；
2. 提供最小產品 identity input；
3. 執行 governed bootstrap；
4. repository manifest轉為 `product`；
5. `VERSION` 轉為 product version；
6. native product identity由既有 Skill／Guide contract完成；
7. README／project_context／roadmap／CHANGELOG不再把 product 當 template本體；
8. verifier PASS。

### C. Fresh Conversation Acceptance

在 bootstrap 完成的 isolated product repository，以 fresh Agent session：

```txt
只提供 repository path，不提供 template adoption handoff。
```

Agent fresh admission 必須從 current authority得到：

- `repository_kind = product`；
- product name；
- template origin baseline；
- current product version；
- 不再次啟動首次 bootstrap。

### D. Negative Acceptance

- product repo再次要求「首次 template adoption」→ 必須阻止並重新分類；
- manifest missing／invalid → fail closed；
- template manifest baseline 與 VERSION drift → fail；
- product manifest把 template baseline當 current product VERSION → verifier可辨識 docs／state inconsistency；
- native identity input不足 → repository bootstrap不得以 placeholder冒充完成 evidence。

## 13. ADR Decision

新增 canonical ADR：

```txt
ADR-030 — Template-to-Product Repository Identity and Bootstrap Contract
```

ADR 擁有 stable decisions：

- GitHub Template Repository 而非長期 Fork；
- repository lifecycle `template | product`；
- `repository_identity.json` ownership；
- template provenance；
- product `VERSION` semantics；
- first-admission fail-closed rule；
- repository bootstrap與native product identity boundary。

Guide 保存操作 procedure；Skill 保存 agent routing；Design／Plan保存 Milestone 37 implementation細節。

## 14. Implementation Boundaries

預期 mutation 範圍：

```txt
repository_identity.json
AGENTS.md（必要時只增加 identity admission route）
.agents/skills/governing-template-development/**
.agents/skills/adopting-template-repository/**
.agents/skills/adopting-template-product-identity/**（只做 delegation-compatible narrow update，如必要）
docs/adr/README.md
docs/adr/adr-030-*.md
docs/guides/template_repository_adoption.md
docs/guides/agent_assisted_development_quick_start.md
docs/governance/development_workflow.md
docs/project_context.md
docs/roadmap.md
docs/roadmap/active.md
README.md
CHANGELOG.md
tools/docs/**
相關 focused tests / fixtures
```

不應修改 production Flutter runtime source，除非 implementation evidence 發現 repository identity transition 無法在不改 runtime 的情況下完成；此時必須回到 Requirement Decision 升級 scope，不得靜默擴張。

## 15. Rollback

Milestone 37尚未發布前，可以 revert整個 branch回到 1.17.0。

發布後若新 bootstrap workflow 有缺陷：

- Template repository 可修正 Skill／Guide／verifier並發布 corrective baseline；
- 已建立的 product repository 不自動回滾或同步；由各 product repository依自身 Requirement Decision採用 corrective；
- 不建立中央 remote updater。

## 16. Design Completion Criteria

- repository lifecycle authority唯一且 machine-readable；
- repository identity與native product identity ownership不重疊；
- template baseline與product version不混淆；
- current docs可在 bootstrap後轉為產品 current authority，不帶入 template milestone history作為產品 roadmap；
- newcomer prompt維持最小輸入；
- fresh conversation acceptance可操作、可驗證；
- 不引入產品規劃、Feature規劃或upstream auto-sync scope。
