---
document_type: implementation-plan
status: proposed
authoritative_for:
  - milestone-37-implementation-plan
last_reviewed_baseline: 1.17.0
---

# Milestone 37 — Template-to-Product Repository Bootstrap & Adoption Governance Implementation Plan

## 1. Authority

- Requirement Decision：`docs/audits/milestone_37/37-r_requirement_decision.md`
- Accepted Design：`docs/superpowers/specs/2026-08-14-milestone-37-template-to-product-repository-bootstrap-design.md`
- Design Review：`docs/audits/milestone_37/37-0_design_spec_review.md`

本 Plan 只定義執行順序、file scope、validation、review 與 commit boundary；不得擴張到產品需求、MVP、Feature、產品 roadmap、Store distribution、signing 或 template upstream auto-sync。

## 2. Execution Gate

Implementation 開始前必須：

1. 本 Plan 完成 focused review、findings disposition、fresh re-review、whole-Task review、authority check 與 fresh validation。
2. 使用者明確核准本 Plan。
3. Plan 轉為 `accepted` 後才建立 managed worktree／branch並重新做 execution fresh admission。
4. 既有使用者未追蹤檔案 `apps/flutter_architecture/test/pratice.dart` 不得帶入 worktree、修改、刪除或提交。

## 3. Ordered Tasks

### Task 37-1 — Repository Identity Contract RED

先以 machine tests 鎖定目前不存在的 repository lifecycle authority 與 fail-closed 行為，不先修改中央 routing。

Required scenarios：

- root `repository_identity.json` 缺失 → fail closed；
- malformed JSON／unknown schema version／unknown `repository_kind` → fail closed；
- `template` state 的 `product_name` 必須為 `null`；
- template `template_origin.repository` 必須是 canonical template repository；
- template `template_origin.baseline` 必須與 root `VERSION` 一致；
- `product` state 必須有非空 product name 與合法 template-origin SemVer；
- product current version 只由 `VERSION` 擁有，manifest 不得出現 product-version 欄位；
- lifecycle parser不得從 remote URL、folder name、README prose 或 bundle identifier猜測 state。

預期新增／修改：

```txt
tools/docs/test_repository_identity.py
docs/audits/milestone_37/37-1_repository_identity_contract_red.md
```

Test Authoring Disposition：**Required**。這是 blocking repository admission contract 與 invalid-state fail-closed owner。

Validation：focused Python test RED evidence、existing docs checker unaffected baseline、`git diff --check`。

### Task 37-2 — Canonical Manifest, Verifier and docs_check GREEN

建立 Design 已接受的唯一 machine-readable repository lifecycle authority：

```txt
repository_identity.json
```

模板初始值必須為 `repository_kind = template`、`product_name = null`、canonical template origin，且 origin baseline 與目前 `VERSION` 一致。

新增 narrow verifier：

```txt
tools/docs/verify_repository_identity.py
```

並接入既有 `docs_check` 相鄰 governance pipeline；不得建立第二個獨立必跑入口。

Verifier 責任限於：schema、template/product invariants、SemVer、required projection marker 與 fail-closed。不得成為 native identity verifier、產品 roadmap parser 或 product feature validator。

Test Authoring Disposition：**Required**，由 Task 37-1 RED 轉 GREEN。

Validation：repository identity tests GREEN、`dart run melos run docs_check`、existing environment verifier、`git diff --check`。

### Task 37-3 — Central Admission Routing and Bootstrap Skill

更新中央 admission 讓 fresh Agent 必讀 `repository_identity.json`，並新增薄型：

```txt
.agents/skills/adopting-template-repository/
```

主要 scope：

```txt
AGENTS.md（只在需要時增加固定 admission route）
.agents/skills/governing-template-development/SKILL.md
.agents/skills/governing-template-development/references/**（只修改真正 owning reference）
.agents/skills/adopting-template-repository/SKILL.md
.agents/skills/adopting-template-repository/references/pressure-scenarios.md
docs/governance/development_workflow.md
```

Routing 必須維持：

```txt
fresh request
→ governing-template-development
→ repository_identity admission
→ accepted Requirement Decision
→ adopting-template-repository（只有首次 Template → Product bootstrap）
→ adopting-template-product-identity（native identity subordinate portion）
```

Required negative scenarios：

- `product` repo再次要求首次 bootstrap → 阻止，重新分類 bounded identity change；
- missing／invalid manifest → fail closed，不猜測；
- API-only／visual-only／single-platform repair 不誤觸 bootstrap Skill；
- existing `adopting-template-product-identity` trigger 不被擴張成 repository lifecycle owner；
- discussion-only request 不 mutation。

Test Authoring Disposition：**Required** for routing／pressure behavior；不做 Skill 每句 wording snapshot。

Validation：Skill/governance focused tests、pressure scenarios、machine discovery、docs check。

### Task 37-4 — ADR-030 and Human Adoption Procedure

建立 canonical stable decision：

```txt
docs/adr/adr-030-template-to-product-repository-identity-bootstrap-contract.md
```

同步 ADR index，並新增窄 Guide：

```txt
docs/guides/template_repository_adoption.md
```

Guide 只回答：

1. GitHub `Use this template` 建立新 independent repository；
2. clone 新 repo；
3. 第一次 Agent prompt 最少需要提供什麼；
4. repository-level bootstrap 會改什麼；
5. 哪些值需要 adopter 明確確認；
6. completion 如何判定；
7. native identity exact procedure 導向既有 `native_environment_adoption.md`。

Quick Start 只新增入口與可複製 prompt，不複製完整 procedure。

不得加入 MVP、Feature、產品 roadmap 或一般產品規劃。

Test Authoring Disposition：Guide/ADR prose 本身 **Should-not-add** snapshot tests；authority/link/checker coverage 走既有 docs checks。

Validation：docs check、ADR index consistency、authority duplication review、stale-route search。

### Task 37-5 — Template Repository Current-Authority Integration

把模板本體 current authority 與新 lifecycle contract 對齊，但仍維持它是 template：

```txt
README.md
docs/project_context.md
docs/roadmap.md
docs/roadmap/active.md
docs/README.md（若 navigation 需要）
```

要求：

- 明確指出 GitHub Template Repository / `Use this template` 是正式 newcomer path；
- current template repository 仍自稱 Template，不提前轉成 product；
- current admission 文檔導向 repository identity manifest；
- Milestone 37 active planning／implementation state與 current authority同步；
- 不把 bootstrap Guide 膨脹成產品開發手冊。

Test Authoring Disposition：一般 prose **no-new-test justified / Should-not-add**；由 docs checker、identity verifier與routing contract覆蓋。

Validation：docs check、repository identity verifier、cross-document authority review。

### Task 37-6 — Isolated Template → Product Bootstrap Acceptance Fixture

從 Milestone implementation branch 建立 disposable isolated copy／fixture，模擬 GitHub `Use this template` 得到的 bytes；不得把真實產品資料寫回 template main。

以代表性假資料執行完整 accepted bootstrap，例如：

```txt
Product name: Pickup Basketball Acceptance
Base identifier: com.magicalwater.pickupbasketballacceptance
Development display name: Pickup Basketball Acceptance Dev
Staging display name: Pickup Basketball Acceptance Staging
Production display name: Pickup Basketball Acceptance
Initial product version: 0.1.0
```

必須驗證：

- 初始 isolated repo仍為 `template`；
- native identity 由既有 manifest-first contract處理；
- README／project_context／roadmap／CHANGELOG轉成產品 current authority；
- template provenance保留原 baseline；
- product `VERSION = 0.1.0`；
- blocking validations通過前 `repository_kind` 不得切到 `product`；
- final lifecycle transition 是 closure 最後一步；
- 完成後 verifier PASS。

由於 product `VERSION`／docs projection在 final lifecycle transition 前會暫時與 canonical `template` manifest不一致，verifier 必須支援**prospective candidate-state validation**：以尚未寫回 canonical path 的 candidate product manifest驗證即將完成的 product state。這不是第三個 persistent lifecycle state；candidate只存在於 validation input／temporary fixture。Prospective validation PASS後才把同一 candidate內容寫入 canonical `repository_identity.json`，然後立即重跑 canonical verifier。

若 implementation 需要新的 automated bootstrap script 才能達成此契約，**不得在本 Task 自行新增**；先回到 Design／Requirement Decision 判斷是否為 scope change。預設 orchestration authority 是 Agent Skill + existing repository mutation tools，不新增產品 bootstrap runtime framework。

Test Authoring Disposition：fixture lifecycle invariants **Required**；不複製 existing native environment tests。

Evidence：`docs/audits/milestone_37/37-6_isolated_bootstrap_acceptance.md`。

### Task 37-7 — Fresh No-Handoff Agent Behavioral Acceptance

以 fresh isolated Agent sessions 驗證真正的 usability goal，不以本 conversation memory 取代 evidence。

至少三類：

1. **Fresh template product intent**：只給 repo path +「剛從 template 建立」+最小 identity，必須正確 route首次 bootstrap並遵守 input gates。
2. **Fresh adopted product**：只給已完成 isolated product repo path，不提供 handoff；Agent必須自行得知 product name、template origin、current product version，且不得再次 bootstrap。
3. **Negative admission**：missing／invalid manifest或 product repo要求首次 bootstrap，必須 fail closed／重新分類，不猜測。

Behavioral acceptance若受 runtime/tool capability阻塞，必須明確標記 `Blocked`／`Pending`，不得用static test冒充 fresh-agent evidence。

Evidence：`docs/audits/milestone_37/37-7_fresh_agent_behavioral_acceptance.md`。

### Task 37-8 — Holistic Final Review and Release Disposition

跨 Task 審查：

- repository identity authority唯一；
- template provenance與product VERSION語意不重疊；
- central governance、bootstrap Skill、product-identity Skill沒有parallel routing；
- GitHub Template newcomer flow與Guide一致；
- template current docs仍是 template；
- isolated adopted product current docs不再冒充 template；
- atomic completion boundary成立；
- 未引入產品規劃／Feature／upstream auto-sync。

Minimum required validation：

- Milestone 37 focused Python／Skill／docs governance suites；
- environment contract verifier；
- `docs_check`；
- validation planner fresh classification；
- Level 4 holistic full workspace regression；
- clean-checkout verification；
- fresh-agent behavioral evidence disposition。

若 capability成立，依 Versioning Policy決定 Template MINOR release候選（預期 `1.18.0`，但 final review前不得先發布），同步：

```txt
VERSION
CHANGELOG.md
docs/project_context.md
docs/roadmap.md
docs/roadmap/active.md
docs/milestones/**
docs/audits/README.md
```

### Task 37-9 — Published-Main Post-release Validation and Closure

只有 Task 37-8 完成、release disposition通過且取得 publication approval後執行：

- integrate／push main；
- 確認 GitHub repository仍為 Template Repository（external setting evidence）；
- published-main identity verifier、docs checks、Skill routing與fresh full regression；
- published baseline的 isolated template bootstrap acceptance；
- 必要 clean checkout／remote evidence；
- post-release audit與formal closure。

不得對任何既有 product repository自動套用 Milestone 37；product adoption一律由各自 repository Requirement Decision控制。

## 4. Atomic Bootstrap Ordering Guardrail

任何 isolated／真實產品 bootstrap implementation 必須維持以下順序：

```txt
read template repository_identity + VERSION
→ collect/confirm product inputs
→ repository docs/version/native identity mutations while repository_kind stays template
→ native/docs/component validation
→ prospective candidate-product identity validation（canonical manifest仍是template）
→ final canonical repository_identity transition to product
→ re-run final identity/docs validation
→ fresh admission acceptance
```

禁止先寫 `repository_kind = product` 再補 blocking validation。Intermediate working state若因 canonical template manifest與candidate product projections不一致而被fresh admission讀取，必須 fail closed；不得猜測為product，也不得把此暫態持久化為第三種 lifecycle state。

## 5. Authority Guardrails

- `repository_identity.json`：repository lifecycle + template provenance唯一 machine authority。
- `VERSION`：current repository version唯一 authority；template state表示template baseline，product state表示product version。
- `environments.json` + ADR-014／025：native environment／bundle identity authority，不被 repository manifest取代。
- `governing-template-development`：中央 classification／approval authority。
- `adopting-template-repository`：薄型首次 bootstrap orchestration。
- `adopting-template-product-identity`：既有 native product identity subordinate authority。
- ADR-030：stable repository lifecycle decision。
- Guide：human procedure，不成為 machine state engine。

## 6. Test Authoring vs Validation Execution

本 Milestone 的新增 tests 只鎖定新的 failure owners：repository identity parser／verifier、routing、lifecycle／atomic transition fixture。

不因新增 README、ADR、Guide、Skill file數量逐檔建立 tests；亦不複製 Android／iOS environment contract tests。

每個 Task 仍由 `tools/ci/validation_planner.py` 決定 Minimum Sufficient Validation；`no-new-test justified` 不等於 no validation。

## 7. Per-Task Governance Cycle

每個 implementation Task：

```txt
implement
→ focused review
→ findings / fix
→ fresh re-review
→ whole-Task review
→ authority check
→ planner-selected validation
→ Open P0 = 0
→ Open P1 without disposition = 0
→ independent commit
→ automatically continue unless a formal stop condition is met
```

## 8. Stop Conditions

只在以下情況停止等待使用者：

1. scope／architecture需要新的使用者決策；
2. external GitHub setting、credential或manual action阻塞；
3. P0／P1 finding推翻 accepted Design／Plan；
4. Plan approval gate；
5. release／publication approval gate；
6. 整個 Milestone正式完成。

一般 test failure、docs drift、tooling bug與review finding應修正並繼續。

## 9. Plan Acceptance Criteria

1. 先 machine RED，再 manifest/verifier GREEN，再 central routing，再 human authority，再 isolated behavioral acceptance。
2. Repository lifecycle state不得由 human prose或Git remote猜測。
3. Existing native product identity authority不得被複製或取代。
4. Product version與template-origin baseline不得形成雙 authority。
5. Atomic lifecycle transition必須在 blocking validation之後。
6. Fresh product repo不得繼承 template roadmap／CHANGELOG作為自己的 current product history。
7. 不建立產品需求／MVP／Feature規劃流程。
8. 不建立 automatic upstream template sync。
9. Plan accepted前不得開始 implementation或建立 implementation worktree。

## 10. Current Status

本 Plan 為 `proposed`，等待完整 Plan Task review與使用者明確核准；在此之前不得開始 implementation。
