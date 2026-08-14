---
document_type: implementation-plan
status: accepted
authoritative_for:
  - milestone-38-implementation-plan
last_reviewed_baseline: 1.18.0
---

# Milestone 38 — Template-to-Product Repository Infrastructure & CI Adoption Governance Corrective Implementation Plan

## 1. Authority

- Requirement Decision：`docs/audits/milestone_38/38-r_requirement_decision.md`
- Accepted Design：`docs/superpowers/specs/2026-08-15-milestone-38-template-product-infrastructure-ci-adoption-design.md`
- Accepted Design Review：`docs/audits/milestone_38/38-0_design_spec_review.md`
- Existing lifecycle authority：ADR-030、`repository_identity.json`、`adopting-template-repository`
- Existing CI authority：ADR-023、`tools/ci/validation_planner.py`、`.github/workflows/*.yml`
- Existing native identity authority：ADR-014、ADR-025、`apps/flutter_architecture/config/environments.json`

本 Plan 只執行 accepted Design 已定義的 repository infrastructure bootstrap corrective。不得擴張為 production signing、Store distribution、credential rotation、產品 Feature 規劃或 template upstream auto-sync。

## 2. Execution Gate

Implementation 開始前必須：

1. 本 Plan 完成 focused review、findings disposition、fresh re-review、whole-Task holistic review、authority check 與 planner-selected validation。
2. 使用者明確核准本 Plan。
3. Plan status 由 `proposed` 轉為 `accepted`。
4. 使用目前 managed worktree `C:\Users\crazy\.devspace\worktrees\flutter_architecture-d0e38710` 與 branch `milestone-38-template-product-infrastructure-ci` 做 execution fresh admission；不得回到使用者有未追蹤 `pratice.dart` 的 source checkout實作。
5. 任一 live GitHub mutation 都必須先 fresh read、確認対象 repository／權限／before state，再依 accepted Task scope 執行；不得從 template source repository設定猜測 product repository desired state。

## 3. Ordered Tasks

### Task 38-1 — Repository Infrastructure Manifest Contract RED

先建立 machine regression owner，鎖定 accepted Design 的 fail-closed contract，不先修改 bootstrap Skill 或 live GitHub設定。

Required scenarios：

- `repository_infrastructure.json` missing／malformed／unknown schema → fail closed；
- unknown `ci_execution_mode`、artifact strategy、capability disposition → fail closed；
- `product_key` 必須是安全、穩定、非空 identifier，不能由folder／remote推導；
- secret-shaped key／payload不得出現在manifest；
- `self-hosted` selected時runner disposition不得為`not-applicable`／未處置；
- product state不能保留selected profile的placeholder／unknown disposition；
- template state必須有合法template infrastructure default；
- manifest不得保存absolute operator path、runner token、GitHub numeric object ID或credential value。

預期 scope：

```txt
tools/docs/test_repository_infrastructure.py
tools/docs/test_template_repository_bootstrap_*.py（只補atomic integration owner）
docs/audits/milestone_38/38-1_infrastructure_contract_red.md
```

Test Authoring Disposition：**Required**。這是repository birth fail-closed與secret-safe direct owner。

Validation：focused Python RED evidence、existing repository identity tests baseline、`git diff --check`。

### Task 38-2 — Canonical Infrastructure Manifest, Verifier and Artifact Product Identity GREEN

新增：

```txt
repository_infrastructure.json
tools/docs/verify_repository_infrastructure.py
```

並把 verifier 接到既有 `docs_check` 相鄰 governance pipeline，不建立另一個獨立日常命令。

同Task修正managed artifact default identity：

```txt
tools/ci/artifact_contract.py
tools/ci/run_local_ci.sh（若projection需要）
tools/ci/test_artifact_contract.py
tools/ci/test_local_build_commands.py
```

規則：

- explicit `CI_ARTIFACT_ROOT`永遠優先；
- self-hosted仍要求explicit external absolute root；
- manual-local default以tracked `product_key`投影，不再硬編`flutter_architecture`；
- template本體的`product_key`保持`flutter_architecture`；
- adopted product由bootstrap寫入已確認的stable product key；
- artifact path不得從folder name／Git remote猜測。

Test Authoring Disposition：**Required**，由38-1 RED轉GREEN；artifact projection既有owner按failure mode擴充，不另建重複suite。

Validation：infrastructure verifier tests、artifact contract/local command tests、docs check、repository identity verifier、planner-selected affected validation。

### Task 38-3 — ADR-031 and Central Bootstrap Authority Integration

建立 stable architecture authority：

```txt
docs/adr/adr-031-template-to-product-repository-infrastructure-adoption-contract.md
docs/adr/README.md
```

更新中央治理與bootstrap orchestration：

```txt
.agents/skills/governing-template-development/SKILL.md
.agents/skills/adopting-template-repository/SKILL.md
.agents/skills/adopting-template-repository/references/pressure-scenarios.md
docs/governance/development_workflow.md
```

Milestone 37 lifecycle route正式延伸為：

```txt
template identity admission
→ accepted bootstrap Requirement Decision
→ repository/native candidate mutations
→ infrastructure manifest + CI profile selection
→ tracked contract validation
→ live infrastructure disposition / selected profile acceptance
→ prospective product identity validation
→ final repository_kind=product
→ canonical revalidation
→ fresh no-handoff acceptance
```

Negative routes：

- CI profile未選定 → 不得finalize product；
- live infrastructure缺權限 → 不得宣稱configured；
- optional capability可explicit deferred，但selected CI profile不可defer；
- existing product repo不得重跑首次bootstrap；
- API-only／visual-only／single-platform repair不誤觸repository bootstrap。

Test Authoring Disposition：routing/atomic lifecycle behavior **Required**；Guide wording snapshot **Should-not-add**。

Validation：focused bootstrap routing tests、Skill pressure cases、docs check、ADR authority review。

### Task 38-4 — Human Product Infrastructure Adoption Procedure

把newcomer procedure補成可實際完成，而不是只停在identity：

```txt
docs/guides/template_repository_adoption.md
docs/guides/ci_cd_operations.md
docs/guides/agent_assisted_development_quick_start.md（只有入口需要時）
README.md／docs/README.md（只有navigation需要時）
```

Guide 必須清楚分開：

```txt
tracked bytes copied by Use this template
vs
live GitHub state that must be separately admitted/configured
```

並提供三種profile的decision checklist：

- `manual-local`；
- `self-hosted`；
- `github-hosted`。

同時保存：

- Branch Protection `minimum-safety | team-protected-main | explicit-deferred` disposition；
- Environment／secret-backed capability `configured | deferred | not-applicable`；
- secret values禁止複製；
- live mutation必須read-back；
- required checks不得在沒有fresh workflow evidence時盲目設定。

Test Authoring Disposition：**Should-not-add** prose snapshots；由docs checker、routing與machine verifier保護。

Validation：docs check、link/authority review、stale contradiction search。

### Task 38-5 — GitHub Live Infrastructure Admission / Read-back Tooling Contract

建立或擴充repository-owned tooling，讓Agent／operator能對**指定product repository**做可審查的live admission，而不是靠手工零散 `gh` 命令。

預期 scope依RED evidence最小化，候選：

```txt
tools/ci/repository_infrastructure.py
tools/ci/test_repository_infrastructure.py
```

至少支援read-only snapshot：

- repository visibility／default branch；
- `CI_EXECUTION_MODE` variable；
- Actions policy與default token permissions；
- fork PR approval policy（適用時）；
- main branch protection關鍵安全欄位；
- repository-scoped self-hosted runner labels/status；
- named Environment存在與required **secret names** presence。

Mutation boundary：

- 只允許Plan明確列出的可逆／安全設定；
- mutation前輸出before state；
- mutation後fresh read-back比對expected；
- permission failure／read-back mismatch fail closed；
- 不讀secret value、不刪runner、不刪Environment、不rotate credential。

Test Authoring Disposition：**Required** for parsing、comparison、authorization boundary與read-back mismatch；GitHub API本身不做無語意mock quota tests。

Validation：focused Python tests、controlled fake API fixtures、secret leakage tests、planner-selected tooling validation。

### Task 38-6 — CI Profile Runtime Contract & Public/Trusted Runner Safety

把三種profile與current workflows的machine contract鎖定，修正任何由Milestone 38 manifest/profile引入的routing mismatch。

Scope候選：

```txt
.github/workflows/ci.yml
.github/workflows/android.yml
.github/workflows/ios.yml
.github/workflows/observability-acceptance.yml
tools/ci/test_ci_execution_mode_contract.py
tools/ci/test_environment_workflow_matrix_contract.py
tools/ci/test_public_repository_security_contract.py
tools/ci/test_artifact_workflow_contract.py
```

Required invariants：

- missing／unknown live CI execution mode不得被當合法repository default；
- public/untrusted PR永遠不能選trusted self-hosted runner；
- self-hosted offline不fallback github-hosted；
- github-hosted profile不讀production signing secret即可完成verification；
- remote artifact transport仍default `none`；
- secret-backed observability只在explicit trusted manual path；
- direct third-party Actions refs維持full SHA machine contract。

Test Authoring Disposition：**Required** for新failure modes；已有owner可直接覆蓋者優先擴充，不按workflow一檔一test。

Validation：CI focused Python suites、workflow contract regression、planner-selected affected/full boundary。

### Task 38-7 — Isolated Product Bootstrap Acceptance: manual-local

建立disposable isolated product repository，模擬`Use this template`後完整bootstrap，使用代表性產品identity且選：

```txt
ci_execution_mode = manual-local
```

Acceptance：

- infrastructure manifest product key已產品化；
- `CI_EXECUTION_MODE` live disposition明確；
- managed artifact default path使用product key；
- `run_local_ci.sh plan-range` PASS；
- representative quality route PASS並產生合法managed manifest/checksum；
- selected profile acceptance未通過前不得finalize `repository_kind=product`；
- final transition後identity＋infrastructure verifiers PASS。

Test Authoring Disposition：isolated bootstrap lifecycle **Required**；不新增產品Feature test。

Evidence：`docs/audits/milestone_38/38-7_manual_local_acceptance.md`。

### Task 38-8 — Isolated Product Bootstrap Acceptance: self-hosted

以受控product repository／runner fixture或實際可管理的測試repository驗證：

```txt
ci_execution_mode = self-hosted
```

必須有fresh evidence：

- product repository runner存在且labels符合contract；
- `CI_ARTIFACT_ROOT`為checkout外安全absolute root；
- trusted main/manual route可執行；
- PR不能選trusted runner；
- runner offline時queued/blocked且不fallback；
- live state read-back與manifest/profile一致。

任何runner registration token都不得進tracked evidence或log。不得刪除／重配置其他repository的runner。

Test Authoring Disposition：profile safety/runtime **Required**；runtime evidence與contract test互補，不以mock取代live route。

Evidence：`docs/audits/milestone_38/38-8_self_hosted_acceptance.md`。

### Task 38-9 — Isolated Product Bootstrap Acceptance: github-hosted + GitHub Settings

建立或使用隔離product repository驗證：

```txt
ci_execution_mode = github-hosted
```

至少完成：

- PR representative CI建立預期GitHub-hosted jobs；
- main representative route建立預期jobs；
- default `GITHUB_TOKEN` read-only；
- direct Actions refs security contract PASS；
- selected Branch Protection disposition fresh read-back；
- artifact transport default `none`；
- optional observability若deferred，secret可不存在且workflow安全skip；
- selected profile acceptance未完成前不得finalize product。

若GitHub plan／permission限制某設定，必須記錄blocked/deferred disposition，不得把API 403解讀為configured。

Test Authoring Disposition：live read-back / atomic completion **Required**。

Evidence：`docs/audits/milestone_38/38-9_github_hosted_acceptance.md`。

### Task 38-10 — Fresh No-Handoff Product Admission & Negative Corpus

使用fresh isolated Agent context驗證產品bootstrap完成後不依賴本conversation handoff。

至少驗證：

1. manual-local product fresh admission能讀出product identity、CI profile、artifact strategy與optional capability disposition；
2. self-hosted product fresh admission能指出runner是required live dependency，且不重跑首次bootstrap；
3. github-hosted product fresh admission能讀出profile與GitHub settings disposition；
4. missing infrastructure manifest、unknown mode、self-hosted without runner、read-back mismatch、secret-shaped manifest content均fail closed；
5. product repo再次要求首次Template adoption時回中央治理重新分類。

Test Authoring Disposition：fresh behavioral acceptance為**Required evidence**；automated machine owners先行，fresh-agent evidence不取代tests。

Evidence：`docs/audits/milestone_38/38-10_fresh_agent_acceptance.md`。

### Task 38-11 — Holistic Review, Release, Main Integration and Post-release Validation

完成Level 5 closure：

```txt
cross-Task holistic review
→ ADR-023 / ADR-030 / ADR-031 authority consistency
→ security / secret / runner / artifact rollback review
→ planner-selected fresh full validation
→ Android + iOS required representative platform evidence
→ three-profile acceptance evidence review
→ VERSION / CHANGELOG / roadmap / current authority sync
→ release decision
→ merge / push
→ fresh clean-checkout post-release validation
→ formal milestone closure
```

Release version由implementation完成時依SemVer與actual scope決定；Plan不提前硬編版本號。

Final acceptance必須：

- Open P0 = 0；
- every P1有明確disposition；
- selected-profile bootstrap不再可能在missing live CI disposition下錯誤完成；
- secrets從未被複製／輸出；
- rollback/recovery procedure已驗證；
-三種profile均有accepted evidence或有Design-authorized external blocker disposition；
- post-release fresh checkout與remote authority一致。

## 4. Commit Boundaries

每個Task獨立completion commit；不得把多個未review Task混成單一commit。建議subject：

```txt
test(governance): 鎖定產品基礎設施採用契約
feat(governance): 建立產品基礎設施manifest
docs(adr): 定義產品repository基礎設施採用契約
docs(guide): 補齊產品CI起步流程
feat(ci): 建立repository基礎設施live admission
fix(ci): 對齊產品CI profile與信任邊界
test(ci): 驗證manual-local產品採用
test(ci): 驗證self-hosted產品採用
test(ci): 驗證github-hosted產品採用
test(governance): 完成fresh產品admission驗收
docs(review): 完成Milestone 38治理收尾
```

實際subject可依Task最終scope微調，但必須繁體中文與Conventional Commits。

## 5. Validation Strategy

每個Task先以：

```txt
tools/ci/validation_planner.py
```

產生Minimum Sufficient Validation，不手工把每個Task固定升級full。

但以下必須fresh full／release級別：

- validation engine／workflow routing本身的holistic gate；
- Task 38-11 final holistic；
- release；
- post-release clean checkout。

Level 5額外必須有：

- failure injection：missing variable、permission denial、read-back mismatch、runner offline、unsafe artifact root、secret-shaped payload；
- compatibility：Windows manual-local、macOS self-hosted、GitHub-hosted Ubuntu/macOS；
- rollback：live setting before/after、可逆setting recovery、runner non-destructive boundary；
- secret leakage scan；
- platform verification依planner/release boundary執行Android／iOS。

## 6. Explicit Non-goals During Execution

- 不自動配置production signing。
- 不建立Play Console／App Store Connect發布pipeline。
- 不搬運template任何secret value。
- 不建立全域runner管理器。
- 不把GitHub repository settings全部mirror成tracked JSON。
- 不讓`repository_infrastructure.json`取代GitHub live state。
- 不替既有product repository做自動遠端migration。
- 不改產品MVP／Feature roadmap。

## 7. Stop Conditions

只有以下情況停止並交回使用者決策：

1. 需要改變accepted Design的CI profile模型／manifest ownership／security boundary；
2. GitHub live mutation需要新的不可逆或credential操作；
3. 外部GitHub plan／permission／runner ownership造成無法以既定Design完成blocking acceptance；
4. review發現推翻Design／Plan的P0/P1；
5. Milestone 38完整closure。

一般test failure、implementation bug、docs drift與可修正GitHub setting mismatch不停止；依雙層Task治理修正並fresh re-verify。

