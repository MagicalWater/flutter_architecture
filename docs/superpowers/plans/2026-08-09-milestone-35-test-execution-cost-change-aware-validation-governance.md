---
document_type: implementation-plan
status: proposed
authoritative_for:
  - milestone-35-test-execution-cost-change-aware-validation-governance-implementation-plan
last_reviewed_baseline: 1.15.2
---

# Milestone 35 — Test Execution Cost & Change-Aware Validation Governance Implementation Plan

> **For agentic workers:** Plan acceptance後，使用`subagent-driven-development`或`executing-plans`逐Task執行；production code／script implementation與review另依中央治理載入`karpathy-guidelines`。每個Task必須遵守full two-layer Task governance。

**Goal:** 建立single deterministic Minimum Sufficient Validation planner，讓docs／tooling／test-only／feature／package／shared App／generated／database／native／dependency／validation-engine／release changes依風險執行focused→affected→workspace→full→release驗證，消除沒有新相關mutation時的重複full regression，同時保留coverage與fail-safe。

**Architecture:** `change_classifier.py`只輸出canonical change classes；新的repository-owned validation planner依change classes、workspace reverse dependency graph與stable escalation rules輸出machine-readable validation plan。CI、local operator與Agent都消費同一plan，不在workflow YAML、Guide或prompt維護第二套routing邏輯。ADR-023承接stable authority；Testing Governance承接human semantics；inventory tier只描述test／artifact execution characteristic，不再兼任change-risk level。

**Tech Stack:** Python stdlib／`unittest`、Git changed-path range、Dart／Flutter workspace metadata、Melos、GitHub Actions YAML、Markdown governance、existing CI/local scripts。

## Global Constraints

- Accepted Requirement Decision：`docs/audits/milestone_35/35-r_requirement_decision.md`。
- Accepted Design：`docs/superpowers/specs/2026-08-09-milestone-35-test-execution-cost-change-aware-validation-governance-design.md`。
- Classification：Level 4 — Architecture／Milestone；Full two-layer governance。
- Plan accepted前不得建立managed worktree或修改classifier、planner、tests、CI、ADR、Guides或production source。
- Plan accepted後第一個execution action才建立managed worktree／branch；implementation不得直接在`main`進行。
- 不刪existing deterministic tests作為速度解法；若後續發現真duplicate，需新的replacement/deletion evidence，不得混入本Milestone核心路徑。
- Unknown path、invalid／missing Git range、dependency graph parse failure、classifier／planner exception與unknown plan schema一律full fail-safe。
- Stable required check names與`manual-local`／`self-hosted`／`github-hosted` execution-mode contract不得破壞。
- 每個Task：RED／focused evidence（適用時）→ implementation → focused review → findings fix → fresh re-review → whole-Task review → authority check → required validation → Open P0=0 → Open P1 without disposition=0 → independent commit。
- 同一Task若validation plan identity相同且selected inputs自GREEN後無mutation，可reuse該evidence；修正selected boundary、plan identity改變或failure後fix必須fresh rerun。
- Milestone holistic、release與post-release一律fresh full regression，不適用中間Task evidence reuse。

---

### Task 35-1: Validation Planner Contract RED

**Files:**
- Create: `tools/ci/test_validation_planner.py`
- Modify: `tools/ci/test_change_classifier.py`
- Create: `docs/audits/milestone_35/35-1_validation_planner_contract_red.md`

**Interfaces:**
- Consumes: accepted Design canonical change classes、validation levels、fail-safe與scenario corpus。
- Produces: current baseline會正確失敗的RED contract，鎖定新planner尚不存在以及現有binary classifier過度升級。

- [ ] **Step 1: 建立canonical scenario fixtures**

  至少覆蓋：

  ```txt
  docs_content
  governance
  tooling
  test_only
  app_feature
  app_shared
  package
  generated
  database
  android_native
  ios_native
  dependency
  validation_engine
  unknown
  release
  mixed change set
  ```

- [ ] **Step 2: 建立planner schema RED assertions**

  Expected contract至少包含：

  ```python
  change_classes
  validation_level
  flutter_test_scopes
  python_test_scopes
  analyze_scopes
  docs_check
  generated_check
  android_build
  ios_build
  full_regression
  release_full
  reason
  fail_safe
  ```

  對current baseline，planner import／contract應以明確missing implementation RED失敗，不得因fixture syntax或path錯誤失敗。

- [ ] **Step 3: 鎖定current over-validation evidence**

  新tests須證明current ordinary feature／package source仍會`full_ci=true`，且feature source會雙平台build；這是corrective RED evidence，不改舊assertion冒充GREEN。

- [ ] **Step 4: 鎖定existing fail-safe仍GREEN**

  ```powershell
  python -m unittest tools.ci.test_change_classifier
  ```

  Existing unknown／invalid／manual／VERSION fail-safe tests必須PASS。

- [ ] **Step 5: Review／record／commit RED**

  Audit記錄baseline SHA、expected RED、existing fail-safe GREEN、Open findings與「尚未修改production routing」。

  Commit：

  ```txt
  test(ci): 鎖定最小充分驗證路由缺口
  ```

---

### Task 35-2: Change Classification + Validation Planner GREEN

**Files:**
- Modify: `tools/ci/change_classifier.py`
- Create: `tools/ci/validation_planner.py`
- Test: `tools/ci/test_change_classifier.py`
- Test: `tools/ci/test_validation_planner.py`
- Create: `docs/audits/milestone_35/35-2_validation_planner_review.md`

**Interfaces:**
- Consumes: Task 35-1 RED fixtures。
- Produces: deterministic classification＋plan engine；尚不切換GitHub workflow consumer。

- [ ] **Step 1: 將classifier責任收斂為canonical change classes**

  保留existing range normalization／fail-safe，但加入Design定義classes。Mixed paths輸出deterministic ordered class set；unknown path直接標記`unknown`並觸發fail-safe。

- [ ] **Step 2: 實作workspace reverse dependency resolver**

  從tracked workspace／pubspec metadata解析package依賴，推導reverse dependents。不得維護手寫package→consumer全域表。

  Parse failure：full fail-safe。

- [ ] **Step 3: 實作validation planner pure core**

  Planner將change classes＋affected graph轉為Design schema。先保持pure／stdlib，可由tests直接呼叫；不在core執行tests或build。

- [ ] **Step 4: 實作focused／affected／workspace／full／release mappings**

  必須證明：

  - single leaf feature不自動雙平台build；
  - leaf package只向真實reverse dependents傳播；
  - shared App boundary提升affected App workspace；
  - validation engine／unknown／invalid range提升full；
  - native只提升對應platform；
  - release提升fresh full＋platform flags。

- [ ] **Step 5: 提供legacy compatibility projection（如workflow cutover需要）**

  可暫時由plan導出`docs_only`／`full_ci`／`android_build`／`ios_build`／`release_full`，但這些boolean不得保留獨立decision logic。

- [ ] **Step 6: GREEN validation**

  ```powershell
  python -m unittest tools.ci.test_change_classifier tools.ci.test_validation_planner
  ```

- [ ] **Step 7: Focused + whole-Task review並commit**

  Review特別檢查determinism、unknown enum、graph failure、mixed changes與雙平台false escalation。

  Commit：

  ```txt
  feat(ci): 建立最小充分驗證規劃器
  ```

---

### Task 35-3: Testing Inventory Tier Realignment

**Files:**
- Modify: `tools/testing/inventory.py`
- Modify: `tools/testing/test_test_inventory.py`
- Create: `docs/audits/milestone_35/35-3_testing_inventory_tier_review.md`
- Create or refresh current Milestone 35 inventory evidence under `docs/audits/milestone_35/`（exact filename由implementation保持單一owner）

**Interfaces:**
- Consumes: Design execution-tier semantics。
- Produces: machine inventory tier與Testing Governance一致，且不覆寫Milestone 30 historical CSV。

- [ ] **Step 1: 先建立tier drift RED**

  Tests至少證明feature／package Flutter regression不能默認Tier 1，generated／migration／native owner需進入對應Tier。

- [ ] **Step 2: 實作deterministic tier classification**

  Tier 1～5依current file ownership／test characteristic分類；無法安全分類時輸出explicit `Unclassified`或equivalent issue，不得默認Tier 1。

- [ ] **Step 3: 保留test taxonomy與execution tier分離**

  `primary_category`／`coverage_owner`與`execution_tier`不得互相覆寫；historical migration／rollback ownership繼續保留。

- [ ] **Step 4: 生成Milestone 35 current inventory evidence**

  使用external／Milestone 35-owned output，不修改`docs/audits/milestone_30/30-2_test_inventory.csv` historical evidence。

- [ ] **Step 5: GREEN validation**

  ```powershell
  python -m unittest tools.testing.test_test_inventory
  python tools/testing/inventory.py --output <milestone-35-current-inventory-path>
  ```

- [ ] **Step 6: Review並commit**

  Commit：

  ```txt
  fix(test): 對齊測試執行層級分類
  ```

---

### Task 35-4: CI and Local Consumer Cutover

**Files:**
- Modify: `.github/workflows/ci.yml`
- Modify as needed: `tools/ci/run_local_ci.sh`
- Modify／Create focused CI contract tests under `tools/ci/test_*.py`
- Create: `docs/audits/milestone_35/35-4_ci_validation_plan_cutover_review.md`

**Interfaces:**
- Consumes: Task 35-2 planner schema。
- Produces: GitHub／self-hosted／manual-local execution消費同一validation plan，workflow不再自行維護binary full-ci routing。

- [ ] **Step 1: 建立workflow contract RED**

  Tests鎖定：stable job names保留、plan output被wiring、docs-only/lightweight job仍存在、unknown／planner failure fallback full、platform flags由plan控制。

- [ ] **Step 2: Classify job輸出machine plan**

  將planner結果安全投影至GitHub outputs；serialization parse failure必須fallback full matrix。

- [ ] **Step 3: Quality job依plan執行**

  Docs／Python／analyze scopes按plan選擇；stable required check名稱不變。不得在YAML重新判斷path class。

- [ ] **Step 4: Tests job支援focused／affected／workspace／full scopes**

  將plan中的Flutter scopes轉成可審查command。空Flutter scope只允許docs／tool-only等明確class；非docs change不得因parse error靜默skip。

- [ ] **Step 5: Generated與platform jobs按plan escalation**

  Ordinary Dart feature不再自動Android＋iOS build；database／dependency／native／release／fail-safe依Design升級。

- [ ] **Step 6: Manual-local／self-hosted parity**

  Local entrypoint需能對同一Git range生成／執行validation plan，或提供exact plan-driven subcommand；不得維護local-only routing分支。

- [ ] **Step 7: Focused contract GREEN**

  至少執行：

  ```powershell
  python -m unittest discover -s tools/ci -p "test_*.py"
  ```

  並執行不會產生外部付費／不可逆side effect的local dry／quality contract驗證。

- [ ] **Step 8: Review並commit**

  Commit：

  ```txt
  feat(ci): 以驗證規劃器驅動變更感知流程
  ```

---

### Task 35-5: ADR-023 and Human/Agent Authority Synchronization

**Files:**
- Modify: `docs/adr/adr-023-repository-ci-quality-gates-android-verification-artifact.md`
- Modify if index metadata requires: `docs/adr/README.md`
- Modify: `docs/guides/testing_governance.md`
- Modify: `AGENTS.md`
- Modify: `docs/guides/how-to-add-feature.md`
- Modify: `docs/guides/agent_assisted_development_quick_start.md`
- Modify: `docs/guides/ci_cd_operations.md`
- Modify if needed: `docs/governance/development_workflow.md`
- Create focused documentation/policy tests as needed
- Create: `docs/audits/milestone_35/35-5_validation_governance_authority_review.md`

**Interfaces:**
- Consumes: working machine planner behavior from Tasks 35-2～35-4。
- Produces: stable ADR＋human/Agent guidance與runtime truth一致，不建立平行path matrix。

- [ ] **Step 1: ADR-023 stable decision amendment**

  加入Minimum Sufficient Validation、single planner authority、fail-safe、full／release escalation與local／CI共用planner contract。

- [ ] **Step 2: 更新Testing Governance current baseline與semantics**

  對齊Tier模型、current inventory evidence、validation levels與cleanup guardrails；Milestone 30 historical evidence只連結、不改寫。

- [ ] **Step 3: 移除unconditional full-regression wording drift**

  `AGENTS.md`與Feature Guide改為：由planner決定minimum sufficient validation；full command保留作holistic／manual／release入口。

- [ ] **Step 4: Quick Start／CI Operations同步使用方式**

  User／Agent只需執行planner入口與returned plan；Guide不得複製完整path routing table。

- [ ] **Step 5: Policy regression**

  建立或更新tests，防止未來重新把「每個commit必跑full workspace」寫回中央Guide，並防止workflow／Guide形成第二selection authority。

- [ ] **Step 6: Required validation**

  ```powershell
  python tools/docs/check_docs.py .
  dart run melos run docs_check
  git diff --check
  ```

- [ ] **Step 7: Review並commit**

  Commit：

  ```txt
  docs(test): 統一最小充分驗證治理權威
  ```

---

### Task 35-6: Evidence Reuse and Duplicate Full-Run Guard

**Files:**
- Modify／Create validation planner support code only if Design-required identity is not yet represented
- Modify: `tools/ci/test_validation_planner.py`
- Create focused governance tests as needed
- Create: `docs/audits/milestone_35/35-6_validation_evidence_reuse_review.md`

**Interfaces:**
- Consumes: planner plan identity與Task validation semantics。
- Produces: deterministic evidence-invalidation contract；不實作跨Task persistent test cache。

- [ ] **Step 1: 定義plan identity**

  Identity至少綁定changed range／normalized path set、planner contract version、selected scopes與relevant dependency metadata。不得只用human Task ID。

- [ ] **Step 2: 建立reuse／invalidate contract tests**

  必須證明：

  - review-only audit文字變更不使已選Flutter scope自動失效；
  - selected source／test／dependency mutation使evidence失效；
  - failure後fix必須fresh；
  - plan schema／engine change必須fresh；
  -跨Task／holistic／release不可reuse。

- [ ] **Step 3: 保持implementation最小**

  若現有Task audit即可保存plan identity與command evidence，不新增daemon／database／global cache。只有machine-enforced invalidation確有必要才新增narrow helper。

- [ ] **Step 4: Review並commit**

  Commit：

  ```txt
  feat(test): 鎖定驗證證據重用邊界
  ```

---

### Task 35-7: Before/After Routing and Execution-Cost Acceptance

**Files:**
- Create: `tools/ci/benchmark_validation_routing.py` or equivalent narrow deterministic measurement entrypoint only if needed
- Create／Modify focused tests for measurement output
- Create: `docs/audits/milestone_35/35-7_execution_cost_acceptance.md`

**Interfaces:**
- Consumes: final planner＋CI/local consumer behavior。
- Produces:固定scenario corpus的before／aftercommand count、Flutter process count、scope、wall-clock與platform escalation evidence。

- [ ] **Step 1: 固定scenario corpus**

  使用Design列出的至少13類scenario；不可只挑改善最大的case。

- [ ] **Step 2: 記錄routing acceptance**

  每個scenario保存change classes、validation level、commands、Flutter process count、selected scopes、platform flags、fail-safe與reason。

- [ ] **Step 3: 執行representative wall-clock measurement**

  至少fresh量測：single feature／single test／leaf package／full regression。Flutter startup fixed cost需獨立呈現，不用test count下降冒充改善。

- [ ] **Step 4: Coverage-hole pressure review**

  Positive／negative routing tests、package reverse propagation、unknown fail-safe、database／native／release escalation全部PASS。

- [ ] **Step 5: Review並commit**

  Commit：

  ```txt
  test(ci): 驗收變更感知驗證成本與覆蓋
  ```

---

### Task 35-8: Holistic Final Review and Template Baseline Release

**Files:**
- Create: `docs/audits/milestone_35/35-8_holistic_final_review.md`
- Modify: `VERSION`
- Modify: `CHANGELOG.md`
- Modify: `docs/project_context.md`
- Modify: `docs/roadmap.md`
- Modify: `docs/roadmap/active.md`
- Modify: `docs/audits/README.md`
- Modify: `docs/superpowers/README.md`
- Modify milestone indexes／README only where authority requires

**Interfaces:**
- Consumes: Tasks 35-1～35-7 accepted commits。
- Produces: cross-Task closure、fresh full regression、release disposition與published-baseline candidate。

- [ ] **Step 1: Cross-Task consistency review**

  確認classifier、planner、inventory、CI、ADR、Guides與measurement使用同一語意；無parallel routing engine。

- [ ] **Step 2: Fresh full local regression**

  依final planner／Level 4 holistic gate執行至少：

  ```powershell
  dart pub get
  python -m unittest discover -s tools/ci -p "test_*.py"
  python -m unittest tools.testing.test_test_inventory
  dart run melos run docs_check
  dart run melos run analyze
  dart run melos exec -- flutter test
  ```

  Generated／database／platform verification依final release plan要求fresh執行；不得用35-7 focused evidence替代。

- [ ] **Step 3: Release identity sync**

  只有Open P0=0、Open P1 without disposition=0且full regression GREEN後才更新VERSION／CHANGELOG／roadmap／current authority。

- [ ] **Step 4: Final review and release commit**

  Final review需明確比較admission baseline與after metrics，並證明coverage／fail-safe未弱化。

  Release commit subject依實際baseline決定，使用繁體中文Conventional Commit。

- [ ] **Step 5: Push authorization boundary**

  若repository policy／使用者standing authorization不足以允許push，停在正式release publication gate；不得擅自宣稱post-release completed。

---

### Task 35-9: Published-Main Post-release Validation and Closure

**Files:**
- Create: `docs/audits/milestone_35/35-9_post_release_validation.md`
- Modify closure routing/current authority only as needed

**Interfaces:**
- Consumes: published main／release SHA。
- Produces: formal Milestone 35 closure。

- [ ] **Step 1: Reconcile published identity**

  Fresh fetch；確認`main == origin/main == release SHA`與working tree clean。

- [ ] **Step 2: Fresh post-release routing matrix**

  重跑low-risk／high-risk／unknown／release代表scenario，確認published bytes仍符合planner contract。

- [ ] **Step 3: Fresh full regression**

  Published SHA執行fresh full regression；不可reuse35-8 local pre-push evidence。

- [ ] **Step 4: Platform／execution-mode evidence**

  按release plan驗證stable checks、manual-local／self-hosted／github-hosted contract與必要Android／iOS escalation。若external runner離線，明確標記environment blocker，不降級closure標準。

- [ ] **Step 5: Formal closure**

  更新post-release audit與current roadmap：Milestone 35只有在published identity、routing matrix與fresh full regression都PASS後才closed。

  Commit：

  ```txt
  docs(test): 完成 Milestone 35 發布後驗證
  ```

## Plan Acceptance Gate

本Plan目前為`proposed`。

在完成Plan focused review、findings修正、fresh re-review、whole-Plan review、documentation authority check與required validation，並取得使用者書面核准前：

- 不建立managed worktree；
- 不開始Task 35-1；
- 不修改production source、tests、CI、ADR或governance implementation artifacts。

