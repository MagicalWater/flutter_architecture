---
document_type: implementation-plan
status: accepted
authoritative_for:
  - karpathy-guidelines-skill-adoption-implementation
last_reviewed_baseline: 1.13.0
---

# Karpathy Guidelines Skill Adoption Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 以 Pilot 方式加入受限制的 repository-local `karpathy-guidelines` companion Skill，讓 implementation／refactor／code review 自動獲得 anti-overengineering 與 surgical-change guidance，同時不建立平行治理 authority。

**Architecture:** 保留 `governing-template-development` 作為唯一治理引擎；新增的 Skill 僅在中央 routing 已決定進入 coding／code review 後載入。採用上游固定 commit 的內容，但加入 provenance、authority precedence、trigger restrictions 與 repository-specific conflict rules，並以 RED／GREEN／REFACTOR pressure scenarios 驗證。

**Tech Stack:** Agent Skills Markdown、repository-local `.agents/skills`、Codex CLI behavior probes、Python docs checker、Melos docs_check、Git worktree。

## Global Constraints

- Source repository：`https://github.com/multica-ai/andrej-karpathy-skills`。
- Source path：`skills/karpathy-guidelines/SKILL.md`。
- Pinned commit：`2c606141936f1eeef17fa3043a72095b4765b9c2`。
- Adoption status：Pilot / Approved with restrictions。
- `governing-template-development` remains the only Level／artifact／approval／Task／release authority。
- 使用者不需要手動指定 `karpathy-guidelines`。
- 不修改 `AGENTS.md` 成為上游 `CLAUDE.md` mirror。
- 不因 simplicity 移除已核准的安全、migration、accessibility、error handling、rollback 或 validation requirements。

---

### Task 1: Establish Isolated Execution and Capture Upstream Evidence

**Files:**
- Create: `docs/audits/milestone_31/31-followup-karpathy-guidelines-source-review.md`
- Reference: `docs/superpowers/specs/2026-07-25-karpathy-guidelines-adoption-design.md`

**Interfaces:**
- Consumes: accepted adoption Design Spec and upstream commit `2c606141936f1eeef17fa3043a72095b4765b9c2`.
- Produces: reproducible source snapshot, provenance, license observation, and execution worktree evidence for later Tasks.

- [ ] **Step 1: Create isolated worktree**

Use `superpowers:using-git-worktrees` and create a worktree based on `main`. Record worktree path, base SHA and clean status in the audit.

- [ ] **Step 2: Fetch exact upstream files without installing them**

Retrieve the pinned versions of:

```txt
skills/karpathy-guidelines/SKILL.md
README.md
CLAUDE.md
```

Record SHA-256 hashes and confirm the fetched commit equals the pinned commit.

- [ ] **Step 3: Review source and license evidence**

Record frontmatter, line count, external-tool requirements, repository mutation behavior, license statements and any mismatch between README claims and repository license files. Do not infer a stronger license conclusion than the evidence supports.

- [ ] **Step 4: Focused review and validation**

Run:

```bash
git diff --check
```

Expected: exit `0`.

- [ ] **Step 5: Commit Task 1**

```bash
git add docs/audits/milestone_31/31-followup-karpathy-guidelines-source-review.md
git commit -m "docs(workflow): 記錄Karpathy Skill來源審查"
```

### Task 2: RED Baseline Pressure Scenarios

**Files:**
- Create: `docs/audits/milestone_31/31-followup-karpathy-guidelines-red-validation.md`
- Create: `.agents/skills/karpathy-guidelines/references/pressure-scenarios.md` only after RED evidence is captured; during RED keep it outside the active Skill path or untracked in `/tmp`.

**Interfaces:**
- Consumes: current repository without active Karpathy Skill.
- Produces: exact baseline failures and rationalizations that the minimal Skill must address.

- [ ] **Step 1: Define five baseline scenarios**

Use fresh Codex contexts for:

```txt
1. Single-use formatter tempts a generic framework.
2. Bounded Bloc bug tempts unrelated cleanup and renaming.
3. Approved offline recovery scope is challenged as too complex.
4. Local implementation ambiguity can be resolved from source/tests.
5. Critical database migration tempts removal of rollback and failure injection.
```

- [ ] **Step 2: Run scenarios without the new Skill**

Prompts must not name `karpathy-guidelines`. Preserve outputs and classify each as pass, failure or inconclusive.

- [ ] **Step 3: Confirm a real gap**

At least one scenario must demonstrate overengineering, unrelated change, improper scope reduction or wrong stop behavior. If all controls already comply, stop and reject Skill creation as unnecessary.

- [ ] **Step 4: Write RED audit**

Record exact prompts, observed behavior, rationalizations and the minimal guidance needed. Do not write the active Skill before this audit is complete.

- [ ] **Step 5: Commit Task 2**

```bash
git add docs/audits/milestone_31/31-followup-karpathy-guidelines-red-validation.md
git commit -m "test(workflow): 建立Karpathy Skill RED基線"
```

### Task 3: Add the Restricted Repository-local Skill

**Files:**
- Create: `.agents/skills/karpathy-guidelines/SKILL.md`
- Create: `.agents/skills/karpathy-guidelines/references/pressure-scenarios.md`

**Interfaces:**
- Consumes: upstream pinned source and Task 2 baseline failures.
- Produces: discoverable companion Skill with no independent governance authority.

- [ ] **Step 1: Write frontmatter for precise discovery**

Use:

```yaml
---
name: karpathy-guidelines
description: Use when implementing, refactoring, or reviewing production code where unnecessary abstraction, unrelated changes, scope creep, or unverifiable work may occur.
---
```

- [ ] **Step 2: Add provenance and required authority relationship**

The Skill body must identify source repository, source path and pinned commit, then state:

```md
**REQUIRED GOVERNANCE:** The current Requirement Decision, accepted Design／Plan／ADR, repository policy and routed Superpowers workflow override these heuristics.
```

- [ ] **Step 3: Adapt only the minimal four principles**

Include concise sections for:

```txt
Think before coding
Simplicity first
Surgical changes
Goal-driven execution
```

Address only rationalizations proven in RED. Keep the active `SKILL.md` under 500 words.

- [ ] **Step 4: Add explicit restrictions**

Require that the Skill must not:

```txt
reclassify work
change approval or stop gates
shrink accepted scope
remove required safety/accessibility/migration/error-handling evidence
trigger on pure requirement discussion, Design/Plan approval, roadmap or release metadata
```

- [ ] **Step 5: Add pressure scenario reference**

Move the five Task 2 scenarios into the Skill reference and define expected outcomes for RED, explicit GREEN, discovery GREEN and REFACTOR.

- [ ] **Step 6: Validate Skill shape**

Run:

```bash
wc -w .agents/skills/karpathy-guidelines/SKILL.md
python3 -m unittest tools.docs.test_check_docs
dart run melos run docs_check
git diff --check
```

Expected: Skill under 500 words; 17 checker tests pass; docs_check passes; diff check exits `0`.

- [ ] **Step 7: Commit Task 3**

```bash
git add .agents/skills/karpathy-guidelines
git commit -m "feat(workflow): 加入受限制Karpathy coding Skill"
```

### Task 4: Wire Automatic Routing Without Creating a New Entry Point

**Files:**
- Modify: `.agents/skills/governing-template-development/SKILL.md`
- Modify: `.agents/skills/governing-template-development/references/artifact-routing.md`
- Modify: `.agents/skills/starting-feature-work/SKILL.md` only if a reference clarification is required; do not add duplicated routing logic.

**Interfaces:**
- Consumes: active restricted Skill from Task 3.
- Produces: automatic companion routing for implementation／refactor／code review only.

- [ ] **Step 1: Add companion relationship to central governance**

State that implementation, refactor and code review routes should load `karpathy-guidelines` after Requirement Decision and approved artifacts, alongside the already-routed Superpowers method.

- [ ] **Step 2: Preserve existing user entry points**

Verify:

```txt
Feature work user entry → starting-feature-work only
Other work user entry → governing-template-development only
karpathy-guidelines → never a required user-facing entry
```

- [ ] **Step 3: Add routing exclusions**

Explicitly exclude pure discussion, Requirement Decision generation, Design／Plan approval, documentation-only Level 0 work, roadmap disposition and release closure unless production code is also being reviewed.

- [ ] **Step 4: Focused authority review**

Confirm no Level matrix, approval rule, Task cycle, validation matrix or release rule is copied into the new Skill.

- [ ] **Step 5: Run documentation validation**

```bash
python3 -m unittest tools.docs.test_check_docs
dart run melos run docs_check
git diff --check
```

Expected: all pass.

- [ ] **Step 6: Commit Task 4**

```bash
git add .agents/skills/governing-template-development .agents/skills/starting-feature-work
git commit -m "feat(workflow): 接線Karpathy coding companion"
```

### Task 5: GREEN, Discovery and Conflict Validation

**Files:**
- Create: `docs/audits/milestone_31/31-followup-karpathy-guidelines-pressure-validation.md`
- Modify: `.agents/skills/karpathy-guidelines/SKILL.md` only during REFACTOR when a proven loophole exists.
- Modify: `.agents/skills/karpathy-guidelines/references/pressure-scenarios.md` when recording final protocol.

**Interfaces:**
- Consumes: routed Skill and Task 2 baseline scenarios.
- Produces: behavior evidence proving value and authority safety.

- [ ] **Step 1: Run explicit GREEN**

Run all five scenarios while explicitly naming the new Skill. Expected:

```txt
minimal local implementation
no unrelated refactor
accepted scope preserved
evidence-resolvable ambiguity handled without unnecessary stop
critical safety requirements retained
```

- [ ] **Step 2: Run discovery GREEN**

At repository root, run implementation／review prompts without naming the Skill. Agent must independently select central governance and then `karpathy-guidelines`.

- [ ] **Step 3: Run non-trigger controls**

Run pure requirement discussion, Design approval, Level 0 typo and release metadata prompts. Agent must not load or apply the companion Skill as a workflow authority.

- [ ] **Step 4: REFACTOR only proven loopholes**

If an agent still overbuilds, shrinks accepted scope, stops unnecessarily or applies the Skill outside its triggers, make the smallest wording change and rerun the affected control plus full GREEN set.

- [ ] **Step 5: Record exact evidence**

Audit must contain prompts, observed results, pass criteria, any inconclusive cases and final Skill word count.

- [ ] **Step 6: Commit Task 5**

```bash
git add .agents/skills/karpathy-guidelines docs/audits/milestone_31/31-followup-karpathy-guidelines-pressure-validation.md
git commit -m "test(workflow): 完成Karpathy Skill壓力驗證"
```

### Task 6: Synchronize Human Documentation and Skill Registry

**Files:**
- Modify: `docs/governance/development_workflow.md`
- Modify: `docs/README.md`
- Modify: `docs/superpowers/README.md`
- Create or modify: `docs/audits/README.md` routing entry only if current index policy requires it.

**Interfaces:**
- Consumes: validated Pilot behavior from Task 5.
- Produces: current human-readable adoption status, trigger, restrictions, provenance, rollback and evidence routing.

- [ ] **Step 1: Add registry row**

Record:

```txt
Skill: karpathy-guidelines
Status: Pilot / Approved with restrictions
Trigger: production code implementation, refactor, code review
Responsibility: simplicity, surgical changes, explicit assumptions, verifiable goals
Forbidden responsibility: Level, scope approval, branch, Task acceptance, release/closure
Companions: governing-template-development and routed Superpowers skills
Source/pin: upstream repository, path and commit
Rollback: remove routing and Skill; central governance unchanged
```

- [ ] **Step 2: Document user-facing usage**

Clarify that users continue to invoke only `starting-feature-work` or `governing-template-development`; the companion Skill is automatic.

- [ ] **Step 3: Add Design／Plan and audit routing**

Update `docs/superpowers/README.md` and applicable audit index with links to this Spec, Plan and final behavior evidence. Keep summaries navigational; do not duplicate full rules.

- [ ] **Step 4: Run documentation checks**

```bash
python3 -m unittest tools.docs.test_check_docs
dart run melos run docs_check
git diff --check
```

Expected: all pass.

- [ ] **Step 5: Commit Task 6**

```bash
git add docs/governance/development_workflow.md docs/README.md docs/superpowers/README.md docs/audits/README.md
git commit -m "docs(workflow): 同步Karpathy Skill採用狀態"
```

### Task 7: Holistic Review, Clean-checkout Validation and Pilot Closure

**Files:**
- Create: `docs/audits/milestone_31/31-followup-karpathy-guidelines-final-review.md`
- Modify: `docs/governance/development_workflow.md` only if final findings require a corrected registry disposition.

**Interfaces:**
- Consumes: Tasks 1–6 commits and validation evidence.
- Produces: final Pilot acceptance or rejection decision, clean-checkout proof and merge-ready branch.

- [ ] **Step 1: Cross-Task review**

Verify source pin, Skill content, routing, authority precedence, pressure scenarios, registry, docs links and rollback are mutually consistent. Open P0 must be `0`; every P1 must have disposition.

- [ ] **Step 2: Fresh full workflow validation**

Run:

```bash
python3 -m unittest tools.docs.test_check_docs
dart run melos run docs_check
git diff --check
```

Expected: all pass.

- [ ] **Step 3: Clean-checkout validation**

Clone or create a clean worktree at final branch HEAD and rerun checker tests, docs_check, one discovery GREEN implementation prompt and one non-trigger control.

- [ ] **Step 4: Decide Pilot disposition**

Use one of:

```txt
Pilot accepted
Pilot accepted with additional restriction
Pilot rejected and rolled back
```

Do not promote to fully Approved unless discovery, conflict and non-trigger tests are all conclusive.

- [ ] **Step 5: Write final review and commit**

```bash
git add docs/audits/milestone_31/31-followup-karpathy-guidelines-final-review.md docs/governance/development_workflow.md
git commit -m "docs(workflow): 完成Karpathy Skill Pilot審查"
```

- [ ] **Step 6: Finish branch**

Use `superpowers:finishing-a-development-branch` only after all Task gates pass. Present merge／push options; do not declare repository release or Milestone closure because this follow-up does not change VERSION or create a new Milestone.

## Plan Self-Review

- Spec coverage：source pinning、restrictions、automatic routing、authority precedence、pressure scenarios、docs sync、rollback與 clean-checkout 均有對應 Task。
- Placeholder scan：無 TBD／TODO／模糊「適當處理」步驟。
- Task boundaries：source evidence、RED、Skill creation、routing、GREEN、docs、final review 可被獨立 review 與 commit。
- Scope control：不包含產品程式碼、VERSION bump、release 或將上游 CLAUDE.md 合併進 AGENTS.md。

## Approval Gate

本 Plan 已於 2026-07-25 取得使用者明確核准並轉為 `accepted`。下一步依本 Plan 建立隔離 worktree，從 Task 1 開始執行；任何 Task 驗證失敗時維持 open／blocked，修正並 fresh re-verify 後才可進入下一 Task。
