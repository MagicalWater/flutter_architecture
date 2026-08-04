---
document_type: implementation-plan
status: accepted
authoritative_for:
  - milestone-33-repository-local-pencil-to-flutter-workflow-foundation-plan
last_reviewed_baseline: 1.14.0
---

# Milestone 33 — Repository-local Pencil-to-Flutter Workflow Foundation Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 在 Flutter Architecture Template 中建立可重複、repository-local、可驗證的 Pencil-to-Flutter 工作流程，並以 `Write Pre-check` 單頁 proof 證明該流程同時符合視覺權威、Flutter 架構與雙層 Task 治理。

**Architecture:** Repository 先以 ownership-aware lock 與 checker 管理第三方 Skills，再以 visual authority manifest 管理 `.pen` 與衍生證據；薄型 `implementing-pencil-flutter-design` Skill 負責在中央治理之下編排 Pencil MCP、Flutter mapping、TDD 與 visual acceptance。Proof 只建立 presentation-only Feature，使用既有 Router、Localization、Design System 與 App-only Composition Root，不建立第二套架構。

**Tech Stack:** Flutter 3.41／Dart 3.12 workspace、Auto Route、Flutter Localization ARB、repository Design System、Python documentation checker、Pencil MCP、DevSpace repository-local Skills、`phosphoricons_flutter`、Flutter widget／golden tests、`dart:ui` PNG comparison、Android debug runtime evidence。

## Global Constraints

- Accepted Design：`docs/superpowers/specs/2026-08-04-milestone-33-repository-local-pencil-to-flutter-workflow-foundation-design.md`。
- Accepted stable decision draft：`docs/superpowers/specs/2026-08-04-adr-028-repository-local-pencil-to-flutter-design-implementation-workflow-draft.md`。
- Template Baseline起點固定為`1.14.0`；release candidate固定為`1.15.0`，只有Task 33-12 Final Review核准release disposition後才可套用。
- 本Plan取得使用者核准前，不得建立managed worktree、copy外部visual source、安裝third-party Skills、操作Pencil canvas或修改Flutter production source。
- Plan核准後，以Plan acceptance closure commit的`git rev-parse HEAD`作為managed worktree `baseRef`，branch固定為`milestone-33-pencil-to-flutter-workflow`；review evidence記錄resolved 40-character SHA，不在文件中留下可變placeholder。
- `.pen`只能透過`pencil-local-mcp`讀取或操作；禁止native JSON／text parser與直接file mutation fallback。
- Third-party unmodified Skill保留上游原始語言與bytes；只有immutable source、license、install path與逐檔SHA-256完全匹配時才豁免中文Skill檢查。
- Repository-authored Skill與repository-maintained fork仍使用繁體中文，並經focused adoption review與pressure validation。
- DevSpace同名Skill collision或loaded path不是managed worktree時fail closed。
- Proof feature只包含presentation；不得新增Domain、Data、Repository、Use Case、Bloc或DI。
- 所有visible strings必須進入`app_en.arb`、`app_zh.arb`與`app_zh_TW.arb`並由generated localization提供。
- Canonical visual viewport固定為`941 × 1672`、device pixel ratio `1.0`；同時必須通過`390 × 844`與`226 × 400`窄畫面scroll／no-overflow驗證。
- 禁止full-screen raster embedding、全畫面fixed-canvas `FittedBox`、事後放寬threshold或動態ignore region。
- 每個Task採Full two-layer cycle：implement → focused review → findings/fix → fresh re-review → whole-Task review → authority check → validation → independent commit。
- Open P0必須為0，所有P1必須有disposition；validation失敗時Task維持open，不得以completion semantics commit。
- 每個source／test／doc變更使用repository工具與`apply_patch`完成；不得以臨時shell rewrite繞過reviewable diff。

## Execution Admission Gate

Plan只有在完成Plan focused review、findings修正、fresh re-review、whole-Plan review、documentation validation、independent commit與使用者明確核准後，才可執行以下步驟：

1. 載入`superpowers:using-git-worktrees`。
2. 在main checkout執行`git status --short --branch`、`git rev-parse HEAD`與`git merge-base --is-ancestor db73068f0334e9ac27134026d37ed1cbb7833f60 HEAD`。
3. 使用剛取得的Plan acceptance closure commit作`baseRef`建立managed worktree與branch `milestone-33-pencil-to-flutter-workflow`。
4. 在新worktree重新讀取`AGENTS.md`、中央治理Skill、accepted Design、accepted ADR draft與accepted Plan。
5. 驗證working tree clean、branch正確、accepted Design commit與Plan acceptance commit皆為ancestor。
6. 建立`docs/audits/milestone_33/33-execution-admission.md`記錄exact worktree path、branch、base SHA、loaded repository instructions與initial validation；此evidence與Task 33-1同commit。

---

### Task 33-1: Generalize ADR Coverage and Canonicalize ADR-028

**Files:**
- Create: `docs/adr/adr-028-repository-local-pencil-to-flutter-design-implementation-workflow.md`
- Create: `docs/audits/milestone_33/33-1_adr_028_canonicalization_review.md`
- Create: `docs/audits/milestone_33/33-execution-admission.md`
- Modify: `tools/docs/check_docs.py`
- Modify: `tools/docs/test_check_docs.py`
- Modify: `docs/adr/README.md`
- Modify: `docs/superpowers/specs/2026-08-04-adr-028-repository-local-pencil-to-flutter-design-implementation-workflow-draft.md`
- Modify: `docs/superpowers/README.md`

**Interfaces:**
- Consumes: accepted ADR draft、current `_check_adrs()`與legacy aggregate cutover contract。
- Produces: contiguous canonical ADR coverage contract、canonical ADR-028、historical draft route與Task 33-1 review evidence。

- [ ] **Step 1: Write RED tests for legal extension and gap detection**

在`tools/docs/test_check_docs.py`新增：

```python
def test_allows_contiguous_adr_after_027_cutover(self) -> None:
    with _fixture() as root:
        _write_complete_adr_series(root, highest=28)
        self.assertNotIn("incomplete-adr-coverage", _codes(root))

def test_reports_gap_before_highest_extracted_adr(self) -> None:
    with _fixture() as root:
        _write_complete_adr_series(root, highest=28, omitted={27})
        issues = check_repository(root)
        self.assertTrue(
            any(
                issue.code == "incomplete-adr-coverage"
                and "ADR-027" in issue.message
                for issue in issues
            )
        )
```

Helper signature固定為：

```python
def _write_complete_adr_series(
    root: Path,
    *,
    highest: int,
    omitted: set[int] | None = None,
) -> None:
```

- [ ] **Step 2: Run RED**

```bash
python -m unittest \
  tools.docs.test_check_docs.DocumentationCheckerTest.test_allows_contiguous_adr_after_027_cutover \
  tools.docs.test_check_docs.DocumentationCheckerTest.test_reports_gap_before_highest_extracted_adr
```

Expected：第一個test因ADR-028被視為extra而FAIL；第二個test維持或補強gap evidence。

- [ ] **Step 3: Implement contiguous ADR coverage**

在`tools/docs/check_docs.py`新增pure helper：

```python
def _expected_adr_coverage(extracted: set[str]) -> set[str]:
    numbers = [int(identifier.removeprefix("ADR-")) for identifier in extracted]
    highest = max([27, *numbers])
    return {f"ADR-{number:03d}" for number in range(1, highest + 1)}
```

legacy aggregate cutover改為以此helper取得expected，message顯示實際highest，不再硬編碼`ADR-027`。

- [ ] **Step 4: Run GREEN and full checker tests**

```bash
python -m unittest tools.docs.test_check_docs
dart run melos run docs_check
```

- [ ] **Step 5: Canonicalize accepted stable decision**

將accepted draft的stable decision內容建立為canonical ADR，frontmatter固定：

```yaml
document_type: architecture-decision
status: accepted
authoritative_for:
  - adr-028-repository-local-pencil-to-flutter-design-implementation-workflow
last_reviewed_baseline: 1.14.0
id: ADR-028
title: Repository-local Pencil-to-Flutter Design Implementation Workflow
supersedes:
superseded_by:
related:
  - ADR-009
  - ADR-011
  - ADR-018
  - ADR-019
```

在`docs/adr/README.md`加入extracted ADR-028 row。Draft改為`status: superseded`並在頂端指向canonical ADR；draft保留書面核准歷史，不再擁有stable authority。

- [ ] **Step 6: Review and validate Task 33-1**

```bash
python -m unittest tools.docs.test_check_docs
dart run melos run docs_check
git diff --check
```

Review必須檢查legal ADR extension、gap／orphan／filename／relation coverage、canonical內容與accepted draft semantic equivalence。

- [ ] **Step 7: Commit Task 33-1**

```bash
git add tools/docs docs/adr docs/superpowers/specs/2026-08-04-adr-028-repository-local-pencil-to-flutter-design-implementation-workflow-draft.md docs/superpowers/README.md docs/audits/milestone_33/33-1_adr_028_canonicalization_review.md docs/audits/milestone_33/33-execution-admission.md
git commit -m "feat(governance): 建立Pencil-to-Flutter架構決策"
```

---

### Task 33-2: Add Ownership-aware Third-party Skill Lock Validation

**Files:**
- Create: `tools/docs/skill_lock.py`
- Create: `tools/docs/test_skill_lock.py`
- Create: `docs/audits/milestone_33/33-2_skill_lock_governance_review.md`
- Modify: `tools/docs/check_docs.py`
- Modify: `tools/docs/test_check_docs.py`
- Modify: `.agents/skills/governing-template-development/references/skill-adoption-governance.md`
- Modify: `docs/governance/development_workflow.md`

**Interfaces:**
- Consumes: root `skills-lock.json` when present and `.agents/skills/**` inventory。
- Produces: `inspect_skill_lock(root: Path) -> SkillLockInspection` and exact Markdown exemption paths for `_check_agent_skill_language()`。

`tools/docs/skill_lock.py` public contract：

```python
@dataclass(frozen=True)
class SkillLockIssue:
    code: str
    path: Path
    message: str

@dataclass(frozen=True)
class SkillLockInspection:
    exempt_markdown_paths: frozenset[Path]
    issues: tuple[SkillLockIssue, ...]

def inspect_skill_lock(root: Path) -> SkillLockInspection:
    ...
```

Root lock schema version固定為1：

```json
{
  "version": 1,
  "skills": {
    "skill-name": {
      "ownership": "third-party-unmodified",
      "status": "Pilot",
      "source": {
        "repository": "https://github.com/owner/repository.git",
        "commit": "40-character-lowercase-hex",
        "path": "upstream/skill/path"
      },
      "license": {
        "identity": "observed-license-identity",
        "sourcePath": "LICENSE",
        "localPath": "third_party/skills/source-repository/LICENSE",
        "sha256": "64-character-lowercase-hex"
      },
      "installPath": ".agents/skills/skill-name",
      "files": [
        {"path": "SKILL.md", "sha256": "64-character-lowercase-hex"}
      ]
    }
  }
}
```

- [ ] **Step 1: Write RED fixture tests**

在`tools/docs/test_skill_lock.py`建立：

```txt
test_locked_unmodified_english_skill_is_exempt
test_unlocked_english_skill_still_fails_language_check
test_missing_locked_file_fails
test_unknown_file_in_locked_install_path_fails
test_hash_drift_fails
test_install_path_escape_fails
test_duplicate_install_path_fails
test_non_immutable_commit_fails
test_modified_third_party_cannot_masquerade_as_unmodified
test_missing_locked_license_fails
test_locked_license_hash_drift_fails
```

- [ ] **Step 2: Run RED**

```bash
python -m unittest tools.docs.test_skill_lock
```

Expected：module不存在或所有new contract tests FAIL。

- [ ] **Step 3: Implement strict parser and hashing**

Implementation requirements：

- JSON decoding errors produce `skill-lock-invalid-json`。
- `commit`必須符合`^[0-9a-f]{40}$`。
- `installPath`與file paths經`resolve()`後必須位於repository root／install root內。
- lock inventory與actual file inventory必須exact set equality。
- SHA-256使用raw bytes，不做newline normalization。
- License local path必須存在於repository內，且raw SHA-256與lock完全一致。
- 只有`ownership == "third-party-unmodified"`且零issues的Markdown files加入`exempt_markdown_paths`。
- Repository-authored Skill與fork永不從lock取得語言豁免。

- [ ] **Step 4: Integrate with docs checker**

`check_repository()`先執行`inspect_skill_lock(root)`，把issues轉成`CheckIssue`，再將exemption傳給：

```python
def _check_agent_skill_language(
    root: Path,
    files: list[Path],
    exempt_markdown_paths: frozenset[Path],
) -> list[CheckIssue]:
```

- [ ] **Step 5: Run GREEN and regression**

```bash
python -m unittest tools.docs.test_skill_lock tools.docs.test_check_docs
dart run melos run docs_check
```

- [ ] **Step 6: Synchronize governance text**

將語言規則改為ownership-aware contract，明確記錄：原樣第三方內容保留原語言；path-only標示無效；修改任何managed bytes即為fork；lock不擁有trigger或workflow authority。

- [ ] **Step 7: Review and commit Task 33-2**

```bash
python -m unittest tools.docs.test_skill_lock tools.docs.test_check_docs
dart run melos run docs_check
git diff --check
git add tools/docs .agents/skills/governing-template-development/references/skill-adoption-governance.md docs/governance/development_workflow.md docs/audits/milestone_33/33-2_skill_lock_governance_review.md
git commit -m "feat(governance): 區分第三方Skill語言與完整性"
```

---

### Task 33-3: Pin and Admit the Three Taste Skills

**Files:**
- Create: `skills-lock.json`
- Create: `.agents/skills/brandkit/SKILL.md`
- Create: `.agents/skills/high-end-visual-design/SKILL.md`
- Create: `.agents/skills/imagegen-frontend-mobile/SKILL.md`
- Create: `third_party/skills/taste-skill/LICENSE`
- Create: `docs/audits/milestone_33/33-3_taste_skill_source_admission.md`
- Create: `docs/audits/milestone_33/33-3_taste_skill_discovery_pressure_evidence.md`
- Modify: `docs/governance/development_workflow.md`

**Interfaces:**
- Consumes: `inspect_skill_lock()`、external local candidates and upstream Git repository `Leonxlnx/taste-skill`。
- Produces: immutable root lock、exact vendored bytes、registry disposition與fresh worktree-local discovery evidence。

- [ ] **Step 1: Resolve immutable upstream source**

```bash
git ls-remote https://github.com/Leonxlnx/taste-skill.git HEAD
```

Record the returned 40-character commit. Fetch that exact commit into a temporary read-only checkout and compare：

```txt
skills/brandkit/SKILL.md
skills/soft-skill/SKILL.md
skills/imagegen-frontend-mobile/SKILL.md
LICENSE or repository license source
```

If no immutable commit contains bytes matching the admitted local files, stop Task 33-3 as blocked; do not fabricate a commit identity.

- [ ] **Step 2: Verify admitted raw hashes**

```txt
brandkit/SKILL.md
a250c7b41aecacc412260de2fb429d36ada5f668388aad1770289fa3e5c4f740

high-end-visual-design/SKILL.md
2d11cdcefc8bf319429ee17d94d69a390802e2acf7163662d1eacbcf5be3ff79

imagegen-frontend-mobile/SKILL.md
3cadf1bfbe836d377832d090e5db8479f98903453a4d1342be9636178755f9dd
```

The upstream exact commit must reproduce those raw SHA-256 values. Previous installer `computedHash` values remain historical evidence only。

- [ ] **Step 3: Add exact source bytes and lock**

Use `apply_patch` to add exact upstream Skill text and exact upstream license bytes with original language and LF content. Build `skills-lock.json` from resolved commit, observed license identity, exact source paths, repository-local license path, install paths and raw SHA-256 values.

- [ ] **Step 4: Run machine validation**

```bash
python -m unittest tools.docs.test_skill_lock tools.docs.test_check_docs
dart run melos run docs_check
```

- [ ] **Step 5: Reopen managed worktree and verify discovery**

Reload through DevSpace and record：

- each loaded Skill absolute path starts with the managed worktree root；
- no user-global／DevSpace-local same-name Skill precedes it；
- collision diagnostics count is zero；
- loaded file SHA equals lock SHA；
- `D:\Developer\ui-agent\.agents\skills` is not used as active source。

Pressure evidence includes one temporary same-name collision RED control; after removing it, fresh GREEN proves fail-closed behavior and correct repository-local loading.

- [ ] **Step 6: Record adoption disposition**

Registry rows：

- `brandkit`: `Pilot／Loaded, non-triggered for accepted .pen proof`。
- `high-end-visual-design`: `Pilot／Approved with restrictions`。
- `imagegen-frontend-mobile`: `Pilot／Loaded, non-triggered for accepted .pen proof`。

Each row records source commit、trigger、forbidden responsibility、permissions、rollback and last review date。

- [ ] **Step 7: Review and commit Task 33-3**

```bash
python -m unittest tools.docs.test_skill_lock tools.docs.test_check_docs
dart run melos run docs_check
git diff --check
git add skills-lock.json .agents/skills/brandkit .agents/skills/high-end-visual-design .agents/skills/imagegen-frontend-mobile third_party/skills/taste-skill/LICENSE docs/governance/development_workflow.md docs/audits/milestone_33/33-3_taste_skill_source_admission.md docs/audits/milestone_33/33-3_taste_skill_discovery_pressure_evidence.md
git commit -m "feat(skills): 鎖定Taste設計Skill來源"
```

---

### Task 33-4: Establish Visual Source and Authority Contracts

**Files:**
- Create: `tools/visual/verify_visual_authority.py`
- Create: `tools/visual/test_verify_visual_authority.py`
- Create: `docs/design_sources/README.md`
- Create: `docs/design_sources/pencil-compatibility-write-precheck/source.pen`
- Create: `docs/design_sources/pencil-compatibility-write-precheck/pencil-preview.png`
- Create: `docs/design_sources/pencil-compatibility-write-precheck/original-reference.png`
- Create: `docs/design_sources/pencil-compatibility-write-precheck/historical-flutter-benchmark.png`
- Create: `docs/visual_authority/README.md`
- Create: `docs/visual_authority/pencil-compatibility-write-precheck/manifest.md`
- Create: `docs/audits/milestone_33/33-4_visual_authority_review.md`
- Modify: `tools/docs/check_docs.py`
- Modify: `tools/docs/test_check_docs.py`
- Modify: `docs/README.md`

**Interfaces:**
- Consumes: external admission files and accepted hashes。
- Produces: repository-owned source hierarchy and `verify_visual_authority(root: Path, manifest: Path) -> tuple[VisualAuthorityIssue, ...]`。

Manifest required frontmatter：

```yaml
document_type: runtime-evidence
status: accepted
authoritative_for:
  - pencil-compatibility-write-precheck-visual-authority
last_reviewed_baseline: 1.14.0
initiative: pencil-compatibility-write-precheck
authority_file: ../../design_sources/pencil-compatibility-write-precheck/source.pen
authority_sha256: bd8926711ea28e7f9ae5a83128ed8fbc8d506cb5342c76eb35360c4c13544fdc
canonical_width: 941
canonical_height: 1672
canonical_dpr: 1.0
```

Body table固定欄位：`Role | Path | SHA-256 | Authority status`。

- [ ] **Step 1: Write RED manifest tests**

Cover valid manifest、missing authority、hash drift、path escape、missing derived file、duplicate role、invalid viewport and benchmark incorrectly marked primary。

```bash
python -m unittest tools.visual.test_verify_visual_authority
```

- [ ] **Step 2: Implement verifier and docs integration**

Parse frontmatter and fixed Markdown table, hash raw bytes and reject paths outside repository. `check_docs.py` invokes it for every `docs/visual_authority/**/manifest.md`。

- [ ] **Step 3: Import binaries into the managed worktree**

```txt
D:\Developer\ui-agent\test-reconstruction.pen
→ source.pen
bd8926711ea28e7f9ae5a83128ed8fbc8d506cb5342c76eb35360c4c13544fdc

D:\Developer\ui-agent\test-reconstruction-preview.png
→ pencil-preview.png
6d1a6553a1b066d0d07ce565aee7f895cddcdc0344e9f9797bab4ca1cfac5be5

D:\Developer\ui-agent\test.png
→ original-reference.png
c7469bcdd8842ad7a0e2f57715756615e07990d0fec33d6016105c5e45e398fc

D:\Developer\ui-agent\flutter_preview\flutter-preview.png
→ historical-flutter-benchmark.png
69edbc35da44288e80b448231de50f9a51d95ba84c9042ea16797267b607731d
```

Calculate destination hashes independently. Any mismatch blocks the Task. After manifest acceptance, external paths cease to be active authority.

- [ ] **Step 4: Run GREEN and docs checks**

```bash
python -m unittest tools.visual.test_verify_visual_authority tools.docs.test_check_docs
dart run melos run docs_check
```

- [ ] **Step 5: Review and commit Task 33-4**

Review source ranking：`.pen` primary、Pencil preview derived、original PNG supplementary、previous Flutter preview benchmark only。

```bash
git diff --check
git add tools/visual tools/docs docs/design_sources docs/visual_authority docs/README.md docs/audits/milestone_33/33-4_visual_authority_review.md
git commit -m "feat(design): 建立Pencil視覺權威契約"
```

---

### Task 33-5: Add the Repository Pencil-to-Flutter Orchestration Skill

**Files:**
- Create: `.agents/skills/implementing-pencil-flutter-design/SKILL.md`
- Create: `.agents/skills/implementing-pencil-flutter-design/references/pencil-admission.md`
- Create: `.agents/skills/implementing-pencil-flutter-design/references/visual-authority-contract.md`
- Create: `.agents/skills/implementing-pencil-flutter-design/references/flutter-mapping.md`
- Create: `.agents/skills/implementing-pencil-flutter-design/references/visual-validation.md`
- Create: `.agents/skills/implementing-pencil-flutter-design/references/pressure-scenarios.md`
- Create: `docs/audits/milestone_33/33-5_orchestration_skill_review.md`
- Create: `docs/audits/milestone_33/33-5_orchestration_pressure_evidence.md`
- Modify: `.agents/skills/governing-template-development/SKILL.md`
- Modify: `.agents/skills/governing-template-development/references/pressure-scenarios.md`
- Modify: `docs/governance/development_workflow.md`

**Interfaces:**
- Consumes: accepted central Requirement Decision、Design、Plan、visual manifest、Skill lock and Pencil MCP availability。
- Produces: thin domain Skill that routes admission → extraction → mapping → TDD → visual validation without owning approval or closure。

- [ ] **Step 1: Add RED pressure scenarios**

Scenarios must demonstrate pre-Skill failure or unsafe ambiguity for：

```txt
accepted .pen normal route
Plan-not-approved denial
external-only source denial
same-name Skill collision denial
native .pen parser fallback denial
Taste Skill free-redesign denial
imagegen non-trigger when accepted .pen exists
presentation-only boundary
visual threshold widening denial
Design conflict stop condition
```

- [ ] **Step 2: Write the thin Skill**

`SKILL.md` flow must be exactly：

```txt
delegate governing-template-development
→ verify accepted Design and Plan
→ verify managed worktree
→ verify visual authority manifest and hashes
→ verify loaded Skill provenance and collision-free paths
→ perform Pencil MCP admission
→ extract structure and variables
→ map to Flutter authority
→ route TDD and visual acceptance
→ stop on authority conflict or drift
```

Forbidden responsibilities include Level classification、Design／Plan acceptance、`.pen` direct parsing、free redesign、fake Domain/Data/DI、release and closure claims。

- [ ] **Step 3: Wire narrow central routing**

Central governance only routes this Skill after an accepted Requirement Decision identifies repository-local Pencil-to-Flutter implementation and all approval gates are satisfied. Figma、image-only concept generation、ordinary Flutter feature and already-coded UI fixes remain non-triggers unless independently classified.

- [ ] **Step 4: Run language, docs and behavioral validation**

```bash
python -m unittest tools.docs.test_skill_lock tools.docs.test_check_docs
dart run melos run docs_check
```

Reload workspace and prove repository-local absolute Skill path. Execute RED／GREEN／REFACTOR pressure protocol and record actual outputs rather than only scenario text presence.

- [ ] **Step 5: Review and commit Task 33-5**

```bash
git diff --check
git add .agents/skills/implementing-pencil-flutter-design .agents/skills/governing-template-development docs/governance/development_workflow.md docs/audits/milestone_33/33-5_orchestration_skill_review.md docs/audits/milestone_33/33-5_orchestration_pressure_evidence.md
git commit -m "feat(skills): 新增Pencil-to-Flutter工作流程"
```

---

### Task 33-6: Perform Pencil MCP Admission and Structural Extraction

**Files:**
- Create: `docs/audits/milestone_33/33-6_pencil_admission_and_extraction.md`
- Create: `docs/audits/milestone_33/33-6_flutter_mapping_matrix.md`
- Create: `docs/audits/milestone_33/33-6_pencil_extraction_review.md`

**Interfaces:**
- Consumes: repository-local `source.pen`、accepted manifest、loaded orchestration Skill、`executor-local-mcp` and `pencil-local-mcp`。
- Produces: exact frame／component／variable inventory and accepted mapping matrix for implementation Tasks。

- [ ] **Step 1: Verify executor and Pencil integration**

Record exact Executor version, available integrations and `pencil-local-mcp` discovery. Expected Executor admission version is`1.5.35`; a different version requires compatibility review, not silent acceptance.

- [ ] **Step 2: Open the worktree-local `.pen` in native Pencil**

Open only：

```txt
docs/design_sources/pencil-compatibility-write-precheck/source.pen
```

Request fresh app state with schema／canvas enabled and scripts／browser disabled. Confirm open document identity and source hash.

- [ ] **Step 3: Load relevant guidelines**

Call guidelines with no arguments, then load only `Code` and `Design System` guidance relevant to the current Task. Do not load unrelated large script or browser state.

- [ ] **Step 4: Extract structure**

Evidence must inventory：

```txt
root frame and canonical dimensions
status/header/progress hierarchy
hero state card
transaction summary fields
precheck result fields
expected record cards
recommended next-step content
primary/secondary/end-flow actions
colors, gradients, typography, spacing, radii, borders and shadows
icon identities and weights
component reuse opportunities
unsupported constructs or renderer ambiguities
```

- [ ] **Step 5: Produce Flutter mapping matrix**

Each extracted item maps to exactly one owner：

```txt
existing ColorScheme or DsSemanticColors
existing DsSpace or DsRadius
feature-local PencilCompatibilityVisualSpec
generated localization key
Phosphor icon
feature-local widget
decorative-only Flutter primitive
```

No item may map to a new global Design System token without second-consumer evidence.

- [ ] **Step 6: Review and commit Task 33-6**

Review checks source identity、no native parsing、complete component inventory、unsupported construct disposition and architecture mapping consistency。

```bash
dart run melos run docs_check
git diff --check
git add docs/audits/milestone_33/33-6_*.md
git commit -m "docs(pencil): 記錄寫前檢查設計結構"
```

---

### Task 33-7: Establish the Flutter Proof Foundation with TDD

**Files:**
- Create: `apps/flutter_architecture/lib/features/pencil_compatibility/README.md`
- Create: `apps/flutter_architecture/lib/features/pencil_compatibility/presentation/write_precheck_copy.dart`
- Create: `apps/flutter_architecture/lib/features/pencil_compatibility/presentation/visual_spec/pencil_compatibility_visual_spec.dart`
- Create: `apps/flutter_architecture/lib/features/pencil_compatibility/presentation/pages/write_precheck_page.dart`
- Create: `apps/flutter_architecture/lib/features/pencil_compatibility/presentation/pages/write_precheck_view.dart`
- Create: `apps/flutter_architecture/test/features/pencil_compatibility/presentation/write_precheck_copy_test.dart`
- Create: `apps/flutter_architecture/test/features/pencil_compatibility/presentation/write_precheck_route_test.dart`
- Modify: `apps/flutter_architecture/pubspec.yaml`
- Modify: `apps/flutter_architecture/lib/app/router/app_router.dart`
- Modify generated: `apps/flutter_architecture/lib/app/router/app_router.gr.dart`
- Modify: `apps/flutter_architecture/lib/l10n/app_en.arb`
- Modify: `apps/flutter_architecture/lib/l10n/app_zh.arb`
- Modify: `apps/flutter_architecture/lib/l10n/app_zh_TW.arb`
- Modify generated: `apps/flutter_architecture/lib/l10n/generated/app_localizations*.dart`
- Modify: `apps/flutter_architecture/test/app/router/app_router_test.dart`

**Interfaces:**
- Consumes: accepted mapping matrix and existing App Router／Localization／Design System。
- Produces: `WritePrecheckPage`, `WritePrecheckView`, `WritePrecheckCopy.from(AppLocalizations)`, `PencilCompatibilityVisualSpec`, and top-level `WritePrecheckRoute`。

Localization key prefix固定為`pencilPrecheck`。Required visible copy includes：title、flow step、four step labels、hero title／description／status、five transaction labels／values、five check labels／values、technical detail、two records、three guidance lines、notice、three actions and end-flow link。English strings must be meaningful translations; `app_zh.arb` and `app_zh_TW.arb` use the accepted Traditional Chinese copy.

- [ ] **Step 1: Add failing route test**

```dart
test('WritePrecheckRoute is a standalone unguarded non-initial route', () {
  final sessionManager = SessionManager();
  final router = AppRouter(AuthGuard(sessionManager));
  addTearDown(sessionManager.dispose);

  final route = router.routes.singleWhere(
    (candidate) => candidate.page.name == WritePrecheckRoute.name,
  );

  expect(route.initial, isFalse);
  expect(route.guards, isEmpty);
  expect(router.routes.first.page.name, ShellRoute.name);
});
```

- [ ] **Step 2: Add failing localization copy test**

Pump English and Traditional Chinese localization and verify `WritePrecheckCopy.from(l10n)` contains non-empty, locale-correct values and exact counts：4 steps、5 summary rows、5 result rows、2 records、3 guidance lines、2 secondary actions。

- [ ] **Step 3: Run RED**

```bash
cd apps/flutter_architecture
flutter test test/app/router/app_router_test.dart test/features/pencil_compatibility/presentation/write_precheck_copy_test.dart
```

- [ ] **Step 4: Add dependency and minimal page foundation**

Add：

```yaml
phosphoricons_flutter: ^1.0.0
```

Create `@RoutePage()` `WritePrecheckPage` returning `WritePrecheckView(copy: WritePrecheckCopy.from(l10n))`. Add top-level unguarded non-initial route; do not add a Shell tab or DI registration.

- [ ] **Step 5: Generate localization and routes**

```bash
dart pub get
dart run melos run build_runner
```

- [ ] **Step 6: Run GREEN and focused analyze**

```bash
cd apps/flutter_architecture
flutter test test/app/router/app_router_test.dart test/features/pencil_compatibility/presentation/write_precheck_copy_test.dart test/features/pencil_compatibility/presentation/write_precheck_route_test.dart
flutter analyze
```

- [ ] **Step 7: Review and commit Task 33-7**

Review verifies no Domain/Data/Bloc/DI, no hardcoded production strings, no Shell mutation, exact dependency and generated parity。

```bash
git diff --check
git add apps/flutter_architecture/pubspec.yaml apps/flutter_architecture/lib/app/router apps/flutter_architecture/lib/l10n apps/flutter_architecture/lib/features/pencil_compatibility apps/flutter_architecture/test/app/router/app_router_test.dart apps/flutter_architecture/test/features/pencil_compatibility pubspec.lock
git commit -m "feat(ui): 建立Pencil相容性驗證入口"
```

---

### Task 33-8: Implement the Responsive Write Pre-check UI

**Files:**
- Create: `apps/flutter_architecture/lib/features/pencil_compatibility/presentation/widgets/precheck_progress.dart`
- Create: `apps/flutter_architecture/lib/features/pencil_compatibility/presentation/widgets/precheck_section_card.dart`
- Create: `apps/flutter_architecture/lib/features/pencil_compatibility/presentation/widgets/precheck_data_row.dart`
- Create: `apps/flutter_architecture/lib/features/pencil_compatibility/presentation/widgets/precheck_record_tile.dart`
- Create: `apps/flutter_architecture/lib/features/pencil_compatibility/presentation/widgets/precheck_actions.dart`
- Create: `apps/flutter_architecture/test/features/pencil_compatibility/presentation/write_precheck_view_test.dart`
- Create: `apps/flutter_architecture/test/features/pencil_compatibility/presentation/write_precheck_responsive_test.dart`
- Create: `docs/audits/milestone_33/33-8_write_precheck_ui_review.md`
- Modify: `apps/flutter_architecture/lib/features/pencil_compatibility/presentation/pages/write_precheck_view.dart`
- Modify: `apps/flutter_architecture/lib/features/pencil_compatibility/presentation/visual_spec/pencil_compatibility_visual_spec.dart`

**Interfaces:**
- Consumes: `WritePrecheckCopy`, mapping matrix, Design System and Phosphor icons。
- Produces: semantic responsive widget tree with reusable progress/data/record/action widgets。

- [ ] **Step 1: Write RED content and component-count test**

```dart
expect(find.byType(PrecheckStepItem), findsNWidgets(4));
expect(find.byType(PrecheckDataRow), findsNWidgets(10));
expect(find.byType(PrecheckRecordTile), findsNWidgets(2));
expect(find.byType(PrecheckSecondaryAction), findsNWidgets(2));
```

Also assert all major sections and primary action are present via keys/semantics, not only text duplication.

- [ ] **Step 2: Write RED responsive tests**

Pump at：

```dart
const Size(941, 1672)
const Size(390, 844)
const Size(226, 400)
```

For each size, expect no exception, a `Scrollable`, and no full-screen `FittedBox`. At narrow sizes, scroll until end-flow action becomes visible.

- [ ] **Step 3: Run RED**

```bash
cd apps/flutter_architecture
flutter test test/features/pencil_compatibility/presentation/write_precheck_view_test.dart test/features/pencil_compatibility/presentation/write_precheck_responsive_test.dart
```

- [ ] **Step 4: Implement feature-local visual specification**

Keep exact admitted palette in `PencilCompatibilityVisualSpec`：

```dart
static const background = Color(0xFF020B14);
static const backgroundDeep = Color(0xFF01070D);
static const surface = Color(0xFF071522);
static const surfaceRaised = Color(0xFF0B1B2B);
static const border = Color(0xFF536B7E);
static const borderSoft = Color(0xFF244056);
static const text = Color(0xFFEAF2F8);
static const muted = Color(0xFFB8C4CF);
static const dim = Color(0xFF7F94A7);
static const cyan = Color(0xFF3DAEFF);
static const cyanBright = Color(0xFF74D8FF);
static const gold = Color(0xFFF5B941);
static const goldSoft = Color(0xFF9A6A25);
```

Reuse existing `DsSpace`／`DsRadius` only where mapping matrix marks exact equivalence. Do not alter Default/Ocean global themes.

- [ ] **Step 5: Implement responsive hierarchy**

Use `CustomScrollView` or `SingleChildScrollView` with constrained centered content. Canonical viewport reproduces accepted hierarchy and proportions; narrow viewport wraps action rows, converts dense rows when necessary and remains scrollable. Decorative glows may use `Stack`, but content remains in normal responsive layout.

- [ ] **Step 6: Implement semantics and inert proof actions**

Buttons may use no-op callbacks in this presentation fixture, but expose stable keys and semantic labels. No NFC behavior or product navigation flow is invented.

- [ ] **Step 7: Run GREEN and focused regression**

```bash
cd apps/flutter_architecture
flutter test test/features/pencil_compatibility/presentation
flutter analyze
```

- [ ] **Step 8: Review and commit Task 33-8**

Review against `.pen` mapping matrix, responsive constraints, no raster／fixed-canvas cheat and Design System boundary。

```bash
git diff --check
git add apps/flutter_architecture/lib/features/pencil_compatibility apps/flutter_architecture/test/features/pencil_compatibility docs/audits/milestone_33/33-8_write_precheck_ui_review.md
git commit -m "feat(ui): 還原寫前檢查響應式畫面"
```

---

### Task 33-9: Add Architecture, Localization, Semantics and Golden Validation

**Files:**
- Create: `apps/flutter_architecture/test/support/load_pencil_compatibility_test_fonts.dart`
- Create: `apps/flutter_architecture/test/features/pencil_compatibility/presentation/write_precheck_semantics_test.dart`
- Create: `apps/flutter_architecture/test/features/pencil_compatibility/presentation/write_precheck_architecture_contract_test.dart`
- Create: `apps/flutter_architecture/test/features/pencil_compatibility/presentation/write_precheck_golden_test.dart`
- Create: `apps/flutter_architecture/test/features/pencil_compatibility/goldens/write_precheck_windows.png`
- Create: `docs/audits/milestone_33/33-9_flutter_validation_review.md`
- Modify: `apps/flutter_architecture/test/app/localization/app_localizations_test.dart`

**Interfaces:**
- Consumes: completed proof UI and generated localization。
- Produces: deterministic Windows-host canonical golden、semantic contract and architecture guard tests。

- [ ] **Step 1: Write architecture guard test**

Test scans `lib/features/pencil_compatibility` and fails if paths or imports introduce：

```txt
/domain/
/data/
Bloc
Repository
UseCase
getIt
injectable
```

It also fails if `Image.asset`／`Image.file` references the full-screen authority PNG or if a top-level `FittedBox` wraps the complete page.

- [ ] **Step 2: Write semantics and locale tests**

Verify English and Traditional Chinese page titles/actions, all section semantics, 4 progress steps and primary action. Extend localization parity test so every locale contains the entire `pencilPrecheck` key set.

- [ ] **Step 3: Add deterministic font loader**

Load Roboto and Material Icons from `FLUTTER_ROOT`, then resolve `phosphoricons_flutter` from `.dart_tool/package_config.json` and load every font declared by that package's `pubspec.yaml`. Missing font files fail with an explicit path message; do not silently use Ahem for canonical golden.

- [ ] **Step 4: Write and run RED golden test**

Golden fixture uses：

```dart
tester.view.physicalSize = const Size(941, 1672);
tester.view.devicePixelRatio = 1;
```

Pump the page with `DefaultThemeDefinition().createDarkTheme()` and Traditional Chinese locale, then compare to `goldens/write_precheck_windows.png`。

```bash
cd apps/flutter_architecture
flutter test test/features/pencil_compatibility/presentation/write_precheck_golden_test.dart
```

Expected：FAIL because baseline is absent。

- [ ] **Step 5: Generate and inspect the golden**

```bash
cd apps/flutter_architecture
flutter test --update-goldens test/features/pencil_compatibility/presentation/write_precheck_golden_test.dart
```

Inspect the generated image against the Pencil preview before accepting it. Golden generation alone is not visual approval.

- [ ] **Step 6: Run focused and affected validation**

```bash
cd apps/flutter_architecture
flutter test test/features/pencil_compatibility test/app/router/app_router_test.dart test/app/localization/app_localizations_test.dart
flutter analyze
flutter build bundle --target lib/main_development.dart --dart-define=NATIVE_ENVIRONMENT=development
```

- [ ] **Step 7: Review and commit Task 33-9**

```bash
git diff --check
git add apps/flutter_architecture/test apps/flutter_architecture/lib/l10n/generated docs/audits/milestone_33/33-9_flutter_validation_review.md
git commit -m "test(ui): 驗證寫前檢查架構與視覺基線"
```

---

### Task 33-10: Produce Deterministic Visual Diff and Android Runtime Evidence

**Files:**
- Create: `apps/flutter_architecture/test/support/visual_diff.dart`
- Create: `apps/flutter_architecture/test/support/visual_diff_test.dart`
- Create: `apps/flutter_architecture/test/features/pencil_compatibility/presentation/write_precheck_visual_diff_test.dart`
- Create: `apps/flutter_architecture/integration_test/pencil_compatibility_runtime_capture_test.dart`
- Create: `apps/flutter_architecture/test_driver/integration_test_driver.dart`
- Create: `docs/audits/milestone_33/visual_validation/canonical-render.png`
- Create: `docs/audits/milestone_33/visual_validation/reference-diff.png`
- Create: `docs/audits/milestone_33/visual_validation/benchmark-diff.png`
- Create: `docs/audits/milestone_33/visual_validation/android-runtime-screenshot.png`
- Create: `docs/audits/milestone_33/visual_validation/review.md`
- Create: `docs/audits/milestone_33/33-10_visual_acceptance_review.md`

**Interfaces:**
- Consumes: Pencil preview、historical benchmark、canonical Flutter golden and Android debug runtime。
- Produces: `VisualDiffResult` metrics, diff images and semantic visual disposition。

Public utility：

```dart
final class VisualDiffResult {
  const VisualDiffResult({
    required this.differentPixelRatio,
    required this.meanAbsoluteChannelDelta,
    required this.maxChannelDelta,
  });

  final double differentPixelRatio;
  final double meanAbsoluteChannelDelta;
  final int maxChannelDelta;
}

Future<VisualDiffResult> comparePngs({
  required File reference,
  required File actual,
  required File diffOutput,
  required int perChannelTolerance,
});
```

- [ ] **Step 1: Write RED unit tests for the diff utility**

Cover identical pixels、single-pixel delta、dimension mismatch、tolerance boundary and diff image output. Dimension mismatch throws`StateError` and never resizes silently.

- [ ] **Step 2: Implement PNG decode／compare／encode with `dart:ui`**

Use raw RGBA bytes. A pixel is different when any channel delta exceeds`perChannelTolerance`; diff output uses opaque red for different pixels and grayscale for matching pixels.

- [ ] **Step 3: Fix primary acceptance contract before candidate comparison**

```txt
reference: pencil-preview.png
benchmark: historical-flutter-benchmark.png
candidate: write_precheck_windows.png
per-channel tolerance: 8
ignore regions: none
resizing: forbidden
```

Candidate must be no worse than the historical benchmark for both`differentPixelRatio`and`meanAbsoluteChannelDelta`, and also meet：

```txt
differentPixelRatio <= 0.08
meanAbsoluteChannelDelta <= 8.0
```

Thresholds may only change through a new Design decision; a failing candidate is fixed or explicitly rejected/deferred.

- [ ] **Step 4: Run visual diff RED／GREEN cycle**

```bash
cd apps/flutter_architecture
flutter test test/support/visual_diff_test.dart test/features/pencil_compatibility/presentation/write_precheck_visual_diff_test.dart
```

On failure, inspect diff by section and correct hierarchy、typography、spacing、icons、borders or colors. Re-render fresh golden after each accepted fix; never widen thresholds in the same Task.

- [ ] **Step 5: Capture Android runtime evidence**

Add an integration test that：

```dart
final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();
await bootstrap(AppEnvironment.development);
await _pumpUntil(tester, find.byType(ShellPage));

final shellContext = tester.element(find.byType(ShellPage));
final themeController = ThemeControllerScope.of(shellContext);
final localeController = LocaleControllerScope.of(shellContext);
themeController.selectMode(AppThemeMode.dark);
localeController.select(AppLocalePreference.traditionalChinese);
await themeController.waitForPendingWrites();
await localeController.waitForPendingWrites();

await getIt<AppRouter>().push(const WritePrecheckRoute());
await _pumpUntil(tester, find.byType(WritePrecheckPage));
await binding.convertFlutterSurfaceToImage();
await tester.pumpAndSettle();
await binding.takeScreenshot('write_precheck_android');
```

`test_driver/integration_test_driver.dart` uses `integrationDriver(onScreenshot: ...)` and writes exact bytes to`build/runtime-screenshots/write_precheck_android.png`。Do not add a production debug menu、initial route change or hidden runtime flag。

From repository root：

```bash
bash tools/ci/build_android_development.sh
cd apps/flutter_architecture
flutter devices --machine
flutter drive --driver=test_driver/integration_test_driver.dart --target=integration_test/pencil_compatibility_runtime_capture_test.dart --flavor development --dart-define=NATIVE_ENVIRONMENT=development
```

Before `flutter drive`, require exactly one selected Android target or record the resolved device ID and rerun the command with that exact ID. Copy the driver output to the tracked evidence path and verify its SHA-256. Record emulator/device model、Android version、logical／physical size、DPR、font scale and exact command. System chrome may be removed only by one predeclared rectangular crop recorded before comparison; dynamic masks are forbidden.

- [ ] **Step 6: Perform semantic visual review**

`review.md` records PASS/FAIL per：hierarchy、typography、spacing、icons、progress states、content completeness、contrast、touch target、narrow layout and Android renderer differences. Pixel metrics cannot override a semantic P1 finding.

- [ ] **Step 7: Review and commit Task 33-10**

```bash
cd apps/flutter_architecture
flutter test test/support/visual_diff_test.dart test/features/pencil_compatibility/presentation
cd ../..
dart run melos run docs_check
git diff --check
git add apps/flutter_architecture/test/support apps/flutter_architecture/test/features/pencil_compatibility docs/audits/milestone_33/visual_validation docs/audits/milestone_33/33-10_visual_acceptance_review.md
git commit -m "test(ui): 建立Pencil視覺差異驗收"
```

---

### Task 33-11: Synchronize Workflow Guides, Routing and Current Authority

**Files:**
- Create: `docs/guides/pencil_to_flutter_workflow.md`
- Create: `docs/audits/milestone_33/33-11_workflow_documentation_review.md`
- Modify: `AGENTS.md`
- Modify: `docs/guides/agent_assisted_development_quick_start.md`
- Modify: `docs/governance/development_workflow.md`
- Modify: `docs/governance/documentation_policy.md`
- Modify: `docs/README.md`
- Modify: `docs/project_context.md`
- Modify: `docs/roadmap/active.md`
- Modify: `docs/roadmap.md`
- Modify: `docs/milestones/README.md`
- Modify: `docs/audits/README.md`
- Modify: `docs/superpowers/README.md`

**Interfaces:**
- Consumes: implemented workflow, accepted registry, ADR-028 and visual evidence paths。
- Produces: reusable human entry, short prompt route, current-state synchronization and no parallel authority。

- [ ] **Step 1: Write the reusable Guide**

Guide sections fixed：

```txt
when to use and non-triggers
required accepted inputs
repository source and manifest layout
third-party Skill pin/update/remove
worktree-local discovery proof
Pencil MCP admission
extraction and Flutter mapping
Feature First and localization rules
golden/diff/runtime acceptance
double-layer Task review
failure/rollback/stop conditions
copyable short prompt
```

- [ ] **Step 2: Add narrow repository routing**

`AGENTS.md` only points to central governance and the domain Skill when Pencil-to-Flutter work is classified; it must not duplicate the full Guide or Skill procedure.

- [ ] **Step 3: Update Skill registry and language policy**

Registry includes orchestration Skill and the three Taste companions with exact status, trigger, forbidden responsibility, permissions, source, rollback and upgrade gates. Documentation policy distinguishes repository-authored/fork content from locked third-party unmodified content.

- [ ] **Step 4: Add Guide pressure review**

Use a fresh read-only scenario with no oral context: an agent receives only repository files and a short request to implement an accepted `.pen`. It must route to Requirement Decision／approval checks, identify correct source paths and refuse external source or premature Pencil operations.

- [ ] **Step 5: Run documentation and affected regression**

```bash
python -m unittest tools.docs.test_skill_lock tools.docs.test_check_docs tools.visual.test_verify_visual_authority
dart run melos run docs_check
dart run melos run analyze
git diff --check
```

- [ ] **Step 6: Review and commit Task 33-11**

```bash
git add AGENTS.md .agents/skills docs/guides docs/governance docs/README.md docs/project_context.md docs/roadmap.md docs/roadmap docs/milestones/README.md docs/audits/README.md docs/superpowers/README.md docs/audits/milestone_33/33-11_workflow_documentation_review.md
git commit -m "docs(workflow): 說明Pencil-to-Flutter樣板流程"
```

---

### Task 33-12: Run Holistic Final Review and Freeze Release Disposition

**Files:**
- Create: `docs/audits/milestone_33/33-12_holistic_final_review.md`
- Modify only if findings require fixes: files owned by Tasks 33-1 through 33-11

**Interfaces:**
- Consumes: all Task commits/reviews, source lock, ADR, Skills, visual authority, Flutter proof, Guide and runtime evidence。
- Produces: local branch completion disposition and explicit release/rollback decision; does not merge or push。

- [ ] **Step 1: Review cross-Task consistency**

Verify：

- accepted Design and canonical ADR are implemented without scope drift；
- third-party bytes／lock／loaded path agree；
- `.pen` authority and runtime evidence routing agree；
- orchestration Skill does not duplicate central governance；
- Flutter proof has no fake architecture or visual cheat；
- Guide can reproduce the workflow；
- every Task has one-to-one review, validation and commit evidence。

- [ ] **Step 2: Run full local regression**

```bash
dart pub get
dart run melos run build_runner
python -m unittest tools.docs.test_skill_lock tools.docs.test_check_docs tools.visual.test_verify_visual_authority
dart run melos run docs_check
dart run melos run analyze
dart run melos exec -- flutter test
cd apps/flutter_architecture
flutter build bundle --target lib/main_development.dart --dart-define=NATIVE_ENVIRONMENT=development
cd ../..
bash tools/ci/build_android_development.sh
git diff --check
```

- [ ] **Step 3: Re-run fresh visual acceptance**

Regenerate the canonical screenshot without updating accepted golden, rerun visual diff and verify Android runtime evidence path remains valid. Any code or visual change made during final review requires fresh affected Task re-review and a separate recovery commit before final review can pass.

- [ ] **Step 4: Freeze disposition**

Allowed conclusions：

```txt
A — Complete workflow capability; approve 1.15.0 release candidate
B — Governance capability accepted, visual proof deferred; no workflow-complete claim
C — Roll back proof-specific implementation, retain accepted governance subset
D — Reject milestone closure and keep active
```

Only A permits Task 33-13. Open P0 must be 0 and undispositioned P1 must be 0.

- [ ] **Step 5: Commit local Final Review**

```bash
git add docs/audits/milestone_33/33-12_holistic_final_review.md
git commit -m "docs(milestone-33): 完成本機整體總審查"
```

- [ ] **Step 6: Stop at user authorization gate**

Report exact branch HEAD、worktree status、review disposition、validation results and proposed merge/release actions. Do not merge, change VERSION, tag, push or delete worktree until explicit user authorization.

---

### Task 33-13: Integrate, Release 1.15.0 and Perform Post-release Validation

**Files:**
- Create: `docs/audits/milestone_33/33-13_post_release_validation.md`
- Modify: `VERSION`
- Modify: `README.md`
- Modify: `CHANGELOG.md`
- Modify: `docs/project_context.md`
- Modify: `docs/roadmap.md`
- Modify: `docs/roadmap/active.md`
- Modify: `docs/milestones/README.md`
- Modify: `docs/audits/README.md`
- Modify: `docs/superpowers/README.md`

**Interfaces:**
- Consumes: user-authorized Task 33-12 disposition A and clean feature branch。
- Produces: Template Baseline `1.15.0`, integrated main, remote equality and fresh release-SHA evidence。

- [ ] **Step 1: Reverify integration admission**

Verify feature branch clean, main clean, feature HEAD descends from accepted Plan and all Task commits. Re-run full regression if main advanced; resolve by approved merge/rebase strategy without rewriting accepted evidence.

- [ ] **Step 2: Apply release identity**

Set root `VERSION` to`1.15.0`, add matching top CHANGELOG entry and update current capability claims. Active milestone remains open until push and post-release validation complete.

- [ ] **Step 3: Review and commit release synchronization**

```bash
dart run melos run docs_check
git diff --check
git add VERSION README.md CHANGELOG.md docs
git commit -m "chore(release): 發布模板1.15.0"
```

- [ ] **Step 4: Integrate and push after explicit authorization**

Use fast-forward when ancestry permits. Push main normally; no force push. Record local main SHA, remote main SHA and equality.

- [ ] **Step 5: Fresh clean-checkout post-release validation**

From a new clean workspace at the release SHA：

```bash
dart pub get
dart run melos run build_runner
python -m unittest tools.docs.test_skill_lock tools.docs.test_check_docs tools.visual.test_verify_visual_authority
dart run melos run docs_check
dart run melos run analyze
dart run melos exec -- flutter test
cd apps/flutter_architecture
flutter build bundle --target lib/main_development.dart --dart-define=NATIVE_ENVIRONMENT=development
cd ../..
bash tools/ci/build_android_development.sh
```

Reload DevSpace and prove all four repository Skills resolve to clean-checkout absolute paths with zero collision. Rerun canonical visual diff without updating golden.

- [ ] **Step 6: Close milestone and clean worktree**

Only after release-SHA validation and remote equality pass：mark active milestone`None`, archive Milestone 33 routing, commit closure evidence, push, then remove managed worktree/local feature branch. Remote feature branch disposition must be explicit.

Final closure commit message：

```bash
git add docs/audits/milestone_33/33-13_post_release_validation.md docs/project_context.md docs/roadmap.md docs/roadmap/active.md docs/milestones/README.md docs/audits/README.md docs/superpowers/README.md
git commit -m "docs(milestone-33): 完成發布後驗證"
git push origin main
```

## Plan Acceptance Gate

本Plan已於2026-08-04取得使用者書面核准並轉為`accepted`，可進入Execution Admission Gate。此核准只允許依Plan建立managed worktree並執行Tasks 33-1至33-12；不等於預先核准Task 33-12之後的merge、release、push或worktree cleanup，這些仍依各自明確gate執行。
