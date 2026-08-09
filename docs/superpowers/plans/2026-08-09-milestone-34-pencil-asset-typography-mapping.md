---
document_type: implementation-plan
status: accepted
authoritative_for:
  - milestone-34-pencil-asset-typography-mapping-implementation-plan
last_reviewed_baseline: 1.15.1
---

# Milestone 34 — Pencil Asset / Vector / Typography Mapping & Provenance Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 在既有`implementing-pencil-flutter-design`內加入Flutter production UI開始前必經的asset／vector／typography representation classification與provenance gate，並以RED→GREEN pressure evidence證明silent font fallback、approximate icon、untracked raster、raster-everything與static Painter shortcuts被攔截。

**Architecture:** 維持單一repository-local Pencil-to-Flutter domain Skill；主`SKILL.md`只增加workflow ordering與fail-closed入口，詳細decision matrix集中到新reference `asset-and-typography-mapping.md`，既有`flutter-mapping.md`只接收已resolved representation。人類Guide與Skill registry只摘要route與responsibility，不複製完整matrix；不修改ADR-028 stable authority或Flutter production source。

**Tech Stack:** Markdown repository Skills／references、Python `unittest` policy checks、repository `docs_check`、Git review evidence。

## Global Constraints

- Accepted Design：`docs/superpowers/specs/2026-08-09-milestone-34-pencil-asset-typography-mapping-design.md`。
- Classification：Level 3 — Cross-cutting workflow contract enhancement；Full two-layer governance。
- 不新增獨立`pencil-to-flutter-code`或asset-mapping Skill。
- 不修改`.pen`、Flutter production UI、Design System、ADR-028 stable owner或第三方Skill bytes。
- Representation classes固定為Layout primitive、Typography、Approved package icon、Vector asset、Raster asset、Dynamic drawing。
- Font family／weight unresolved、approximate icon unresolved或asset provenance unresolved時，Flutter production UI必須fail closed。
- 不允許full-raster interactive UI、不允許static CustomPainter overbuild、不允許candidate-driven representation decision。
- 每個Task完成focused review→findings修正→fresh re-review→whole-Task review→authority check→validation→獨立commit。
- Plan已於2026-08-09取得使用者書面核准；Task 34-1開始後仍須依序完成各Task雙層review與required validation，才可進入下一Task。

---

### Task 34-1: Representation Contract RED

**Files:**
- Create: `tools/docs/test_pencil_representation_mapping_policy.py`
- Create: `docs/audits/milestone_34/34-1_representation_contract_red.md`

**Interfaces:**
- Consumes: accepted Milestone 34 Design acceptance criteria與目前尚未補強的Skill／references。
- Produces: 可重現的mechanical RED，證明現況缺少classification-before-Flutter-mapping、font fail-closed、icon equivalence、derived asset provenance、anti-raster與anti-static-Painter contracts。

- [ ] **Step 1: 建立會對current baseline失敗的policy test**

  測試至少讀取：

  ```python
  POLICY_FILES = (
      Path(".agents/skills/implementing-pencil-flutter-design/SKILL.md"),
      Path(".agents/skills/implementing-pencil-flutter-design/references/flutter-mapping.md"),
      Path(".agents/skills/implementing-pencil-flutter-design/references/asset-and-typography-mapping.md"),
      Path("docs/guides/pencil_to_flutter_workflow.md"),
  )
  ```

  並建立至少六個semantic assertions：

  ```python
  self.assertIn("representation classification", all_text)
  self.assertIn("typography authority unresolved", all_text)
  self.assertIn("approximate icon", all_text)
  self.assertIn("derived transformation", all_text)
  self.assertIn("raster-everything", all_text)
  self.assertIn("static custompainter", all_text)
  ```

  對尚不存在的reference，loader必須回傳明確missing-policy failure，而不是test import error。

- [ ] **Step 2: 執行RED並確認失敗原因正確**

  Run:

  ```powershell
  python tools/docs/test_pencil_representation_mapping_policy.py
  ```

  Expected: `FAIL`，且failure源自Milestone 34 contract不存在，不是syntax、encoding或path typo。

- [ ] **Step 3: 記錄RED evidence與focused review**

  `34-1_representation_contract_red.md`記錄exact command、failed assertions、baseline HEAD、Open P0/P1與「尚未修改Skill production artifacts」。

- [ ] **Step 4: 驗證既有single-renderer contract沒有被RED fixture破壞**

  ```powershell
  python tools/docs/test_pencil_single_renderer_policy.py
  dart run melos run docs_check
  git diff --check
  ```

  Expected: existing tests PASS；新representation test保持預期RED。

- [ ] **Step 5: Commit RED evidence**

  ```powershell
  git add tools/docs/test_pencil_representation_mapping_policy.py docs/audits/milestone_34/34-1_representation_contract_red.md
  git commit -m "test(ui): 鎖定Pencil素材映射治理缺口"
  ```

### Task 34-2: Asset / Typography Mapping GREEN

**Files:**
- Create: `.agents/skills/implementing-pencil-flutter-design/references/asset-and-typography-mapping.md`
- Modify: `.agents/skills/implementing-pencil-flutter-design/SKILL.md`
- Modify: `.agents/skills/implementing-pencil-flutter-design/references/flutter-mapping.md`
- Test: `tools/docs/test_pencil_representation_mapping_policy.py`
- Create: `docs/audits/milestone_34/34-2_asset_typography_mapping_review.md`

**Interfaces:**
- Consumes: Task 34-1 RED assertions。
- Produces: 唯一representation decision reference與`Pencil extraction → classification/provenance → Flutter mapping`硬順序。

- [ ] **Step 1: 實作最小reference contract**

  `asset-and-typography-mapping.md`必須包含：

  ```txt
  Inventory
  → primary representation class
  → source / availability verification
  → provenance resolution
  → unresolved gap check
  → handoff to Flutter mapping
  ```

  並明確定義六類representation及Design中primitive/vector/raster/dynamic/typography/icon決策規則。

- [ ] **Step 2: 加入font、icon與asset fail-closed規則**

  必須保留exact terms：

  ```txt
  Typography authority unresolved
  approximate icon
  derived transformation
  content hash
  ```

  Font family／weight不存在不得silent fallback；語意相同icon不得自動視為visual equivalence；derived raster/vector必須可追溯source、transformation、destination、hash與consumer。

- [ ] **Step 3: 加入anti-overbuild規則**

  Reference必須明文拒絕：

  ```txt
  raster-everything shortcut
  static CustomPainter overbuild
  candidate-driven pixel chasing
  ```

  普通card／text／button仍由真Flutter ownership負責；只有runtime value/state驅動geometry才預設允許dynamic drawing。

- [ ] **Step 4: 修改主Skill ordering**

  `SKILL.md`必要順序改為：

  ```txt
  perform Pencil MCP admission
  → extract structure and variables
  → classify visual representation and resolve provenance
  → map resolved representation to Flutter authority
  → route TDD and visual acceptance
  ```

  `執行入口`在`Flutter mapping`前顯式路由新reference；unresolved representation成為stop condition。

- [ ] **Step 5: 收斂`flutter-mapping.md`責任**

  增加入口前提：只接受已由`asset-and-typography-mapping.md`resolved的representation；不在此檔重新決定font fallback、vector/raster或static/dynamic ownership。

- [ ] **Step 6: 執行GREEN與既有policy regression**

  ```powershell
  python tools/docs/test_pencil_representation_mapping_policy.py
  python tools/docs/test_pencil_single_renderer_policy.py
  dart run melos run docs_check
  git diff --check
  ```

  Expected: all PASS。

- [ ] **Step 7: Focused + whole-Task review並commit**

  Review需確認沒有第二個Skill、沒有第二renderer、沒有global asset registry、沒有把human Guide變成authority。

  ```powershell
  git add .agents/skills/implementing-pencil-flutter-design tools/docs/test_pencil_representation_mapping_policy.py docs/audits/milestone_34/34-2_asset_typography_mapping_review.md
  git commit -m "feat(ui): 加入Pencil素材與字型映射契約"
  ```

### Task 34-3: Behavioral Pressure Scenarios

**Files:**
- Modify: `.agents/skills/implementing-pencil-flutter-design/references/pressure-scenarios.md`
- Create: `docs/audits/milestone_34/34-3_asset_typography_pressure_evidence.md`
- Test: `tools/docs/test_pencil_representation_mapping_policy.py`

**Interfaces:**
- Consumes: Task 34-2 classification contract。
- Produces: PTF-13～PTF-18 behavioral contract與RED／DISCOVERY／EXPLICIT GREEN／REFACTOR evidence。

- [ ] **Step 1: 新增PTF-13～PTF-18 scenario matrix與combined prompts**

  Exact cases：Complex ornament shortcut、Silent font fallback、Approximate icon substitution、Untracked derived raster、Raster-everything shortcut、Static CustomPainter overbuild。

- [ ] **Step 2: 執行fresh behavioral validation**

  優先沿用Milestone 33相同的independent agent runtime protocol：

  ```txt
  RED: repository外、忽略user config，不載入本repo Skills
  DISCOVERY: repository root，不顯式指定domain Skill
  EXPLICIT GREEN: 明確指定implementing-pencil-flutter-design與必要references
  REFACTOR: 若DISCOVERY/EXPLICIT出現shortcut rationalization，修文字後重跑affected cases
  ```

  每個case記錄actual response與PASS/FAIL，不得以static text存在代替behavioral evidence。

- [ ] **Step 3: Runtime不可提供真正獨立context時fail closed**

  若目前agent runtime無法建立獨立fresh context，`34-3_asset_typography_pressure_evidence.md`必須明確標記blocked，Task 34-3不得completion commit，也不得將Skill registry升級為fully validated。這屬external/runtime blocker，依中央治理停止。

- [ ] **Step 4: Fresh policy validation**

  ```powershell
  python tools/docs/test_pencil_representation_mapping_policy.py
  python tools/docs/test_pencil_single_renderer_policy.py
  dart run melos run docs_check
  git diff --check
  ```

- [ ] **Step 5: Commit pressure contract/evidence**

  ```powershell
  git add .agents/skills/implementing-pencil-flutter-design/references/pressure-scenarios.md docs/audits/milestone_34/34-3_asset_typography_pressure_evidence.md
  git commit -m "test(ui): 驗證Pencil素材映射壓力案例"
  ```

### Task 34-4: Human Workflow and Skill Registry Synchronization

**Files:**
- Modify: `docs/guides/pencil_to_flutter_workflow.md`
- Modify: `docs/governance/development_workflow.md`
- Modify: `docs/audits/README.md`
- Modify: `docs/superpowers/README.md`
- Create: `docs/audits/milestone_34/34-4_workflow_documentation_review.md`

**Interfaces:**
- Consumes: verified Task 34-2/34-3 contract。
- Produces: 不重複decision matrix的人類route摘要與registry responsibility同步。

- [ ] **Step 1: Guide只新增一層route摘要**

  `Extraction and Flutter mapping`調整為：

  ```txt
  extraction inventory
  → visual representation classification / provenance
  → resolved Flutter owner mapping
  ```

  Guide只列六類與fail-closed例子，完整決策規則連到domain Skill reference。

- [ ] **Step 2: Registry責任同步**

  `development_workflow.md`中的`implementing-pencil-flutter-design` responsibility增加representation classification／asset-font provenance orchestration；trigger、central approval owner、release owner保持不變。

- [ ] **Step 3: Routing index同步**

  Audits與Superpowers indexes新增34-1～34-4 evidence route；不得在多份current docs複製完整matrix。

- [ ] **Step 4: Documentation review與validation**

  ```powershell
  python tools/docs/test_pencil_representation_mapping_policy.py
  python tools/docs/test_pencil_single_renderer_policy.py
  dart run melos run docs_check
  git diff --check
  ```

  Review需確認Skill/reference是machine-execution authority，Guide只是human summary，registry沒有新增第二owner。

- [ ] **Step 5: Commit documentation synchronization**

  ```powershell
  git add docs/guides/pencil_to_flutter_workflow.md docs/governance/development_workflow.md docs/audits docs/superpowers/README.md
  git commit -m "docs(ui): 同步Pencil素材映射工作流程"
  ```

### Task 34-5: Holistic Final Review and 1.15.2 Release Disposition

**Files:**
- Create: `docs/audits/milestone_34/34-5_holistic_final_review.md`
- Modify as required by accepted release disposition: `VERSION`, `CHANGELOG.md`, `docs/project_context.md`, `docs/roadmap.md`, `docs/roadmap/active.md`, `docs/milestones/README.md`, `docs/audits/README.md`, `docs/superpowers/README.md`

**Interfaces:**
- Consumes: Tasks 34-1～34-4 independent commits與fresh evidence。
- Produces: cross-Task closure、release/no-release decision與current authority synchronization。

- [ ] **Step 1: Cross-Task holistic review**

  必查：Design acceptance criteria 1～8、Skill薄型責任、reference ownership、single-renderer continuity、no global asset registry、no Flutter runtime mutation、pressure evidence完整性、Open P0/P1 disposition。

- [ ] **Step 2: Fresh full affected regression**

  ```powershell
  python tools/docs/test_pencil_representation_mapping_policy.py
  python tools/docs/test_pencil_single_renderer_policy.py
  dart run melos run docs_check
  git diff --check
  ```

  因無Flutter production mutation，不強制執行725+ Flutter runtime tests或bundle；若diff意外包含Dart/runtime source，立即升級validation而不得沿用本豁免。

- [ ] **Step 3: Release disposition**

  若Holistic Review確認reusable workflow contract已改變且無blocker，採Design預期patch baseline `1.15.2`；同步VERSION／CHANGELOG/current docs。若review證明只需documentation-only且不值得版本發布，必須在Final Review明確記錄理由，不得靜默跳過Design中的release expectation。

- [ ] **Step 4: Final review gate**

  `34-5_holistic_final_review.md`記錄exact HEAD、Task commits、validation、P0/P1、release disposition與merge/push boundary。完成後依中央治理進入integration／publication；若發布1.15.2，published main還要建立post-release validation evidence後才能formal closure。

- [ ] **Step 5: Commit final review / release metadata**

  Commit message依實際disposition使用：

  ```txt
  docs(ui): 完成Pencil素材映射總審查
  ```

  或若同Task正式切換release identity：

  ```txt
  chore(release): 發布模板基線1.15.2
  ```

## Plan Completion Gate

本Plan建立後必須先完成focused review、finding disposition、fresh re-review、whole-Plan coverage與documentation validation。只有使用者明確核准本書面Plan後，`status`才能由`proposed`轉為`accepted`並開始Task 34-1。

