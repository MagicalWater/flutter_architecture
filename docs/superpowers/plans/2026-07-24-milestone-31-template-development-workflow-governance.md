---
document_type: implementation-plan
status: proposed
authoritative_for:
  - milestone-31-template-development-workflow-governance-plan
last_reviewed_baseline: 1.13.0
---

# Milestone 31 — Template Development Workflow Governance Recovery Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use `superpowers:subagent-driven-development` or `superpowers:executing-plans` task-by-task. Repository雙層Task治理覆蓋Superpowers預設checkpoint；任何validation失敗都必須留在目前Task修正、fresh re-review後才能commit。

**Goal:** 對已發布但治理證據不完整的Milestone 31重新建立Design、Plan、逐Task、holistic與post-release完整證據鏈，不改寫既有1.13.0發布歷史。

**Architecture:** `AGENTS.md`擁有強制入口與不可繞過policy；`.agents/skills/governing-template-development/`擁有可執行分類與routing；`docs/governance/development_workflow.md`只作人類總覽；Superpowers提供方法；audits、Git與validation保存證據。

**Tech Stack:** Markdown Agent Skill、Python standard-library docs checker、Melos／Flutter validation、Git／GitHub CLI。

## Global Constraints

- 不引入OpenSpec或`openspec/`。
- Skill固定位於`.agents/skills/governing-template-development/`。
- Repository policy與current artifacts高於Skill。
- Level 0／1不得被迫建立完整Spec／Plan／Milestone；Level 3～5不得因便利性降級。
- Design與Plan各自完成雙層Task治理、獨立commit與使用者approval後才可進下一層。
- 每個recovery Task必須一對一對應：Task ID、artifact／diff、focused review、findings、fix、focused re-review、whole-task review、authority check、fresh validation、commit disposition。
- 原始不合規commit保留歷史；recovery audit不得宣稱原始執行當時已合規。
- Validation失敗時不得以完成語意commit，也不得由後續Task掩蓋。
- Release identity與governance closure分離；1.13.0已發布，但Milestone 31在post-release recovery完成前維持active。

## File Responsibility Map

- `docs/superpowers/specs/...design.md`：已核准的behavioral與technical design。
- `docs/superpowers/plans/...workflow-governance.md`：本recovery執行順序、Task邊界與validation。
- `.agents/skills/governing-template-development/SKILL.md`：主流程與Requirement Decision輸出。
- `.agents/skills/governing-template-development/references/*.md`：分類、artifact routing、雙層Task、skill adoption與pressure scenarios。
- `AGENTS.md`：強制入口與不可繞過policy。
- `docs/governance/development_workflow.md`：人類總覽，不複製完整矩陣。
- `tools/docs/check_docs.py`與`tools/docs/test_check_docs.py`：可機械化的一致性契約。
- `docs/audits/milestone_31/`：逐Task review、RED／GREEN／REFACTOR、holistic與post-release evidence。
- `docs/project_context.md`、`docs/roadmap/active.md`、`docs/milestones/README.md`、`CHANGELOG.md`：current／release routing。

## Recovery Task Sequence

### Task 31-R0 — Recovery status and authority correction

**Status:** Completed by commit `4557341`.

撤回Completed／Archived宣告，將Milestone 31恢復為active recovery，保留1.13.0已發布事實；Design與Plan降回proposed。Evidence：`31-r0_governance_recovery.md`。

### Task 31-R1 — Design Spec recovery review

**Status:** Completed by commit `36a70c7`; user-approved after commit.

補齊approval、traceability、validation-failure、release／closure分離、RED／GREEN／REFACTOR與retroactive recovery契約。Evidence：`31-r1_design_spec_recovery_review.md`。

### Task 31-R2 — Implementation Plan recovery review

**Files:** Modify本Plan；create `31-r2_implementation_plan_recovery_review.md`。

1. 建立Spec-to-Plan coverage matrix，確保BR-1～BR-13與success criteria都有Task owner。
2. 重切Task邊界，使每個Task可獨立接受或退回，且一對一對應review與commit。
3. 明確定義每個Task的輸入、輸出、validation、authority sync與停止條件。
4. focused review → findings → fix → focused re-review → whole-Plan review → docs validation。
5. 獨立commit後停在使用者Plan approval gate。

### Task 31-R3 — Skill core and classification recovery audit

**Scope:** `SKILL.md`、`work-classification.md`、`artifact-routing.md`。

- 對照核准Spec逐條審查Requirement Decision、Level 0～5、anti-over-governance、upgrade signals、Superpowers ordering與approval gates。
- 對原始commit `79cdea0`建立retroactive disposition；findings在本Task內修正。
- 驗證frontmatter、relative links、required wording與static contract。
- 產出`31-r3_skill_core_recovery_review.md`並獨立commit。

### Task 31-R4 — Two-layer Task and skill adoption recovery audit

**Scope:** `two-layer-task-governance.md`、`skill-adoption-governance.md`。

- 對照核准Spec審查minimal／simplified／standard／full／full-critical模式。
- 驗證validation失敗、commit gate、automatic continuation、stop conditions、Spec／Plan approval與Milestone closure。
- 審查skill adoption status、overlap、authority、upgrade／rollback與revalidation規則。
- 產出`31-r4_task_and_skill_adoption_recovery_review.md`並獨立commit。

### Task 31-R5 — Behavioral pressure RED／GREEN／REFACTOR

**Scope:** `pressure-scenarios.md`及必要測試工具／evidence。

- 至少對代表性Level 0、Level 1、Level 4／5、Spec approval gate、validation failure與automatic continuation情境建立baseline behavior（RED）。
- 在載入Skill後對相同情境驗證compliance（GREEN）。
- 根據observed loopholes修改Skill／references並重跑（REFACTOR）。
- 保存prompt、expected decision、observed behavior與disposition，不以static file presence取代behavior evidence。
- 產出`31-r5_pressure_validation.md`並獨立commit。

### Task 31-R6 — Policy wiring and human overview recovery audit

**Scope:** `AGENTS.md`、`docs/governance/development_workflow.md`、`docs/README.md`、`docs/superpowers/README.md`。

- 驗證`AGENTS.md`能在`.agents`未自動發現時提供explicit-load path。
- 確認overview不複製完整executable matrix，不形成平行authority。
- 驗證導覽、metadata與current routing。
- 產出`31-r6_policy_wiring_recovery_review.md`並獨立commit。

### Task 31-R7 — Documentation checker recovery audit

**Scope:** `tools/docs/check_docs.py`、`tools/docs/test_check_docs.py`。

- 重建frontmatter exclusion、stale active routing、duplicate routing與active section parsing的RED／GREEN證據。
- 確認fixtures能失敗於舊實作、通過於現實作；避免只記錄最終green。
- 執行Python tests與實際repository `docs_check`。
- 產出`31-r7_checker_recovery_review.md`並獨立commit。

### Task 31-R8 — Milestone 30 authority repair recovery audit

**Scope:** 原`9e5d314`修正及current authority。

- 核對Milestone 30 final review、post-release evidence、Roadmap、Project Context、Milestone／Spec indexes與testing governance metadata。
- 確認沒有因Milestone 31 recovery重新引入M30 stale state。
- 產出`31-r8_milestone_30_authority_recovery_review.md`並獨立commit；無變更也要記錄evidence與disposition。

### Task 31-R9 — Cross-task traceability and implementation holistic review

- 建立Spec BR／success criteria → Plan Task → artifact → review → commit → validation matrix。
- 檢查Task numbering、audit naming與commit one-to-one。
- 對R3～R8整體做cross-task、authority與anti-duplication review；findings回到owner Task修正並fresh re-review。
- 產出`31-r9_implementation_holistic_review.md`並獨立commit。

### Task 31-R10 — Fresh full regression and release-state synchronization

- Fresh執行Skill validation、Python docs tests、`docs_check`、workspace analyze、全部Flutter tests與`git diff --check`。
- 同步current authority為「local recovery complete, post-release pending」；不得先清空active milestone。
- 產出`31-r10_local_final_review.md`並獨立commit。

### Task 31-R11 — Push, clean-checkout, remote and post-release validation

- Push recovery commits。
- 在fresh clean checkout驗證Skill contract、docs tests與`docs_check`；依change-aware classification執行必要remote CI／platform checks。
- 查核GitHub Actions對release／recovery HEAD的結果與遠端SHA一致性。
- 若post-final有修正，回到受影響Task與R9／R10重跑。
- 產出`31-r11_post_release_validation.md`，同步Milestone 31 Completed／Archived、active None與最終routing，獨立commit並push。

## Spec-to-Plan Coverage Matrix

| Spec contract | Task owner |
|---|---|
| BR-1 Requirement Decision | R3、R5 |
| BR-2 anti-over-governance | R3、R5 |
| BR-3 Level 2～5 routing | R3、R5 |
| BR-4 formal Spec／Plan／Task gates | R3、R4、R5 |
| BR-5 repository authority priority | R3、R6 |
| BR-6 stop／continue | R3、R4、R5 |
| BR-7 post-release before closure | R4、R10、R11 |
| BR-8 user approval gates | R2、R3、R4、R5 |
| BR-9 traceability evidence | R2、R9 |
| BR-10 validation failure blocks acceptance | R4、R5、R7 |
| BR-11 release／closure separation | R0、R10、R11 |
| BR-12 RED／GREEN／REFACTOR | R5、R7 |
| BR-13 honest retroactive recovery | R3～R9 |
| Human overview without parallel authority | R6 |
| Milestone 30 stale authority prevention | R7、R8 |
| Full regression and post-release evidence | R9～R11 |

## Completion Gate

Milestone 31只能在R0～R11全部accepted、Open P0 = 0、Open P1 without disposition = 0、fresh regression、clean-checkout、remote／post-release validation及final authority sync完成後closure。任何final review後的實作修改都會使受影響Task與R9～R11重新開啟。
