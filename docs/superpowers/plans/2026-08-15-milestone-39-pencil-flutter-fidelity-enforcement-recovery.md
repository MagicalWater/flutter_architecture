---
document_type: implementation-plan
status: accepted
authoritative_for:
  - milestone-39-pencil-flutter-fidelity-enforcement-recovery-implementation-plan
last_reviewed_baseline: 1.19.0
---

# Milestone 39 — Pencil-to-Flutter Fidelity Enforcement & Recovery Governance Corrective Implementation Plan

**Goal:** 在不新增第二個Pencil domain Skill、不建立global asset registry、不要求every-node tests的前提下，把Milestone 33／34既有Pencil-to-Flutter contract補成可機械驗證的critical-node mapping、runtime geometry、local fidelity與wrong-representation recovery流程。

**Architecture:** 維持`governing-template-development → implementing-pencil-flutter-design`唯一route；initiative-local `implementation_mapping.json`保存critical implementation evidence，`tools/visual/**`擁有schema/checker runtime truth，Skill references擁有decision/recovery rules，ADR-028只保存stable principles。

**Release target:** Template Baseline `1.20.0`，若Milestone holistic/release gate發現版本契約衝突則以release authority重新處置，不在Task中自行變更版本語意。

## Global Constraints

- Accepted Requirement：`docs/audits/milestone_39/39-r_requirement_decision.md`。
- Accepted Design：`docs/superpowers/specs/2026-08-15-milestone-39-pencil-flutter-fidelity-enforcement-recovery-design.md`。
- Classification：Level 4；Full two-layer Task governance。
- 不新增第二個Pencil-to-Flutter Skill。
- 不解析`.pen`；critical inventory來源必須仍由Pencil MCP extraction evidence提供。
- 不建立global asset registry或全node database。
- 不要求所有icon raster化，不限制合法vector／raster／verified package glyph／dynamic drawing representation。
- 不要求每個node／icon／section新增test或golden。
- Existing single-renderer、visual authority、Feature First、Design System、Localization與Minimum Sufficient Validation不得退化。
- 每個Task：implement/create → focused review → findings fix → fresh re-review → whole-Task review → authority check → planner-selected validation → independent commit。
- Plan已於2026-08-15取得使用者明確核准；Task 39-1起依Full雙層Task治理順序執行。

---

## Task 39-1 — Critical Mapping Contract RED

**Files:**
- Create: `tools/visual/test_pencil_implementation_mapping.py`
- Create: `docs/audits/milestone_39/39-1_mapping_contract_red.md`

**Purpose:** 先用可重現RED鎖定current baseline缺少machine-readable critical mapping disposition與fail-closed validator，而不是先改Skill文字。

- [ ] 建立fixture-driven RED，至少覆蓋：missing artifact、duplicate node ID、unknown representation class、unknown disposition、`unresolved`、`verified-equivalent`缺`evidence_ref`、`intentional-deviation`缺`approval_ref`、asset provenance欄位缺失。
- [ ] RED不得解析`.pen`；fixture只模擬Pencil MCP已產生的critical extraction handoff。
- [ ] 執行RED並記錄exact failing assertions與baseline commit。
- [ ] Fresh review確認RED不是path/encoding/schema typo造成。
- [ ] Existing Pencil representation/single-renderer policy保持GREEN。
- [ ] Commit：`test(ui): 鎖定Pencil critical mapping治理缺口`。

## Task 39-2 — Mapping Schema & Validator GREEN

**Files:**
- Create: `tools/visual/pencil_implementation_mapping.py`
- Create: `tools/visual/schemas/pencil_implementation_mapping.schema.json`（若實作評估JSON Schema有實質價值；否則由Python module單一擁有schema）
- Modify: `tools/visual/test_pencil_implementation_mapping.py`
- Modify: `.agents/skills/implementing-pencil-flutter-design/references/asset-and-typography-mapping.md`
- Modify: `.agents/skills/implementing-pencil-flutter-design/references/flutter-mapping.md`
- Create: `docs/audits/milestone_39/39-2_mapping_validator_review.md`

**Purpose:** 建立initiative-local critical mapping machine contract與四態disposition。

- [ ] 實作schema version、initiative、authority hash與critical node uniqueness檢查。
- [ ] 支援`exact`／`verified-equivalent`／`intentional-deviation`／`unresolved`。
- [ ] `unresolved`在production acceptance mode fail closed。
- [ ] `verified-equivalent`必須有`evidence_ref`；`intentional-deviation`必須有`approval_ref`。
- [ ] Asset-derived mapping驗source/transformation/destination/content hash必要欄位。
- [ ] Checker不得以檔名或語意相同自動推導equivalence。
- [ ] Reference只描述ownership與decision rules；完整schema不重複貼進多份Markdown。
- [ ] RED全部轉GREEN；fresh review確認沒有global registry／all-icons-raster regression。
- [ ] Commit：`feat(ui): 加入Pencil critical mapping驗證契約`。

## Task 39-3 — Critical Geometry & Local Fidelity Enforcement

**Files:**
- Create/Modify: `tools/visual/**` 最小local fidelity support
- Create/Modify: `apps/flutter_architecture/test/features/pencil_compatibility/**` 最小fixture tests（若重用既有proof比新fixture更小）
- Modify: `.agents/skills/implementing-pencil-flutter-design/references/visual-validation.md`
- Create: `docs/audits/milestone_39/39-3_geometry_local_fidelity_review.md`

**Purpose:** 證明source constant不能取代runtime geometry evidence，並讓critical local failure可覆蓋whole-screen PASS。

- [ ] Test Authoring Decision：只對constraint-sensitive critical geometry與local gate engine新增owner，不建立every-node geometry tests。
- [ ] 建立至少一個fixture證明source宣告尺寸與actual `RenderBox`尺寸可不同，並以`tester.getSize/getTopLeft/getBottomRight`或等價runtime evidence攔截。
- [ ] Local fidelity evidence支援最小充分owner：component golden、predeclared ROI/section crop、asset hash、icon identity/equivalence或geometry assertion；不強迫全部同時存在。
- [ ] 若採ROI/crop，candidate前固定region identity、bounds derivation、dimensions、projection與threshold；失敗後不得移動ROI或放寬threshold。
- [ ] 建立contract test證明`whole-screen PASS + critical local FAIL = overall FAIL`。
- [ ] Fresh review確認沒有把canonical design-space x/y當所有runtime viewport固定座標。
- [ ] Commit：`feat(ui): 加入Pencil critical geometry與local fidelity gate`。

## Task 39-4 — Wrong-Representation Recovery & Skill Orchestration

**Files:**
- Modify: `.agents/skills/implementing-pencil-flutter-design/SKILL.md`
- Modify: `.agents/skills/implementing-pencil-flutter-design/references/asset-and-typography-mapping.md`
- Modify: `.agents/skills/implementing-pencil-flutter-design/references/visual-validation.md`
- Modify: `.agents/skills/implementing-pencil-flutter-design/references/pressure-scenarios.md`
- Create: `docs/audits/milestone_39/39-4_recovery_skill_review.md`

**Purpose:** 把wrong source/asset/icon/representation從「建議回頭」提升成正式invalid mapping recovery state。

- [ ] Main Skill加入最小ordering/hard-stop，不把schema/checker細節塞進Skill body。
- [ ] 正式規則：review判定wrong representation → mapping invalid → 禁止candidate-specific padding/scale/crop/offset/opacity tuning → 回classification/provenance → replacement mapping → fresh affected validation。
- [ ] Source authority若需改變，回Requirement/Design；implementation不得修改accepted `.pen`迎合Flutter。
- [ ] 新增pressure scenarios：critical omission、cross-library same-name icon、existing asset redraw、runtime geometry mismatch、global PASS/local FAIL、invalid representation tuning、unauthorized deviation。
- [ ] Policy tests必須驗證recovery wording/route存在，但不得把keyword test當behavioral acceptance。
- [ ] Commit：`feat(ui): 加入Pencil錯誤representation recovery`。

## Task 39-5 — Fresh Behavioral Pressure Validation

**Files:**
- Create: `docs/audits/milestone_39/39-5_fidelity_pressure_evidence.md`
- Modify: Skill/references only if RED/DISCOVERY reveals real wording gap

**Purpose:** 以fresh independent context證明Agent真的會拒絕shortcut與錯誤candidate持續微調。

- [ ] 依`docs/guides/skill_behavioral_validation.md`執行RED／DISCOVERY／EXPLICIT GREEN／REFACTOR。
- [ ] Actual prompt、actual response、model/runtime identity可取得時完整保存。
- [ ] DISCOVERY必須從repository root自行找到中央governance與Pencil Skill，不靠本對話口頭指定。
- [ ] 至少驗證Task 39-4新增七類pressure cases。
- [ ] 若fresh context仍合理化approximation或pixel tuning，先記錄FAIL、修Skill/reference、只重跑affected cases；不得回寫原FAIL為PASS。
- [ ] 無approved isolated-agent harness時Task blocked，不以本對話自審代替。
- [ ] Commit：`test(ui): 驗證Pencil fidelity recovery壓力案例`。

## Task 39-6 — ADR-028 / Guide / Proof Adoption Synchronization

**Files:**
- Modify: `docs/adr/adr-028-repository-local-pencil-to-flutter-design-implementation-workflow.md`
- Modify: `docs/guides/pencil_to_flutter_workflow.md`
- Modify: `docs/governance/development_workflow.md` only if registry wording requires
- Modify: `docs/audits/README.md`
- Modify: `docs/superpowers/README.md`
- Create: `docs/visual_authority/pencil-compatibility-write-precheck/implementation_mapping.json`
- Create: `docs/audits/milestone_39/39-6_authority_sync_review.md`

**Purpose:** 用既有Pencil compatibility proof做最小真實adoption，避免只驗synthetic fixture，同時不重做既有proof UI。

- [ ] ADR-028只加入stable principles：critical implementation mapping evidence、local fidelity override、runtime geometry與wrong-representation recovery；不貼完整schema/Task sequencing。
- [ ] Human Guide摘要新增mapping/recovery route與stop conditions。
- [ ] Existing proof建立最小`implementation_mapping.json`，只列歷史上已具mapping evidence且risk-selected的critical items，不做全node backfill。
- [ ] Validator對proof artifact PASS，authority SHA/provenance與既有manifest一致。
- [ ] Fresh review確認proof Flutter source沒有為Milestone 39被不必要重寫。
- [ ] Commit：`docs(ui): 同步Pencil fidelity authority與proof mapping`。

## Task 39-7 — Holistic Review, Release & Post-release Closure

**Files:**
- Modify: `VERSION`
- Modify: `CHANGELOG.md`
- Modify: `docs/project_context.md`
- Modify: `docs/roadmap.md`
- Modify: `docs/roadmap/active.md`
- Create: `docs/audits/milestone_39/39-7_holistic_final_review.md`
- Create: `docs/audits/milestone_39/39-8_post_release_validation.md`

**Purpose:** cross-Task closure、Template Baseline publication與published-main fresh acceptance。

- [ ] Holistic review：Open P0=0、Open P1 without disposition=0；Skill/docs/checker/tests/runtime evidence一致。
- [ ] Fresh full regression依planner release/full route執行；包含docs、Python tools、Flutter affected/full、analyze、generated/platform gates依release plan要求。
- [ ] Fresh Skill discovery確認只有一個Pencil-to-Flutter domain Skill owner。
- [ ] Fresh behavioral acceptance在published/main authority下重跑代表性cases。
- [ ] VERSION預期升級`1.20.0`、CHANGELOG／project_context／roadmap同步。
- [ ] Fast-forward integration與push後，以clean checkout／fresh worktree重新驗證published authority與mapping checker。
- [ ] Post-release evidence PASS後Milestone 39才可archive。

## Plan Completion Gate

Plan只有在下列條件全部成立後才能轉`accepted`：

- Design acceptance criteria都有明確Task owner。
- 每個新增test owner符合risk-based Test Authoring Decision，無every-node test expansion。
- ADR amendment、Skill、Guide、machine tooling、proof adoption、behavioral validation與release都有owner。
- Task boundaries允許獨立review／commit，沒有把所有治理修改塞成單一mega Task。
- Planner-selected Minimum Sufficient Validation可在每Task執行；Milestone holistic另跑full。
- Open P0=0；Open P1 without disposition=0。
- 使用者明確核准本Plan。

