---
document_type: implementation-plan
status: completed
authoritative_for:
  - documentation-usability-hardening-implementation-plan
last_reviewed_baseline: 1.8.0
---

# Documentation Usability Hardening Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 修正已確認的文件導航與 task route 缺口，在不新增 architecture authority 或大型 Guide 的前提下，讓 Feature、App integration、API endpoint 與歷史 evidence 更容易被正確找到與執行。

**Architecture:** 採薄型 operational routing。Canonical ADR 繼續擁有 durable architecture contract；Guide 只提供 task order 與 authority links；App／Package README 只提供 local integration route；Audit index 只負責 evidence routing；Roadmap／Backlog 只保存 initiative disposition。所有 Task 均獨立完成 implement、review、findings、fix、re-review、Open P0／P1 = 0、validation、commit。

**Tech Stack:** Markdown、YAML front matter、repository documentation checker、Git、Conventional Commits。

## Global Constraints

- Template Baseline 維持 `1.8.0`。
- 不建立 Milestone 27。
- 不新增 Architecture Decision。
- 不修改 production runtime source、generated source、CI workflow、native runner或package dependencies。
- 不建立大型 Documentation Knowledge Base、Troubleshooting Guide、Architecture Evolution handbook或Generic Persistence Guide。
- 不搬移、拆分、合併或刪除 historical documents。
- 不批量追平 `last_reviewed_baseline`。
- Guide 不重述 ADR 正文；README 不取得跨 repository architecture authority。
- 每個 Task 固定執行：`implement → review → findings → fix → re-review → Open P0／P1 = 0 → validation → commit`。
- 每個 commit 使用 Conventional Commits，描述文字使用繁體中文。
- 每個 Task 預設建立獨立 review artifact，保存 findings、fix、re-review與final gate。

---

## File Map

### Active documents to modify

| File | Responsibility in this initiative |
|---|---|
| `docs/guides/how-to-add-feature.md` | Feature addition operational checklist |
| `apps/flutter_architecture/README.md` | App-local database與integration routes |
| `packages/api_client/README.md` | API endpoint與external client operational checklist |
| `docs/audits/README.md` | Recent audit與review evidence routing |
| `docs/roadmap/candidates.md` | Candidate disposition |
| `docs/backlog.md` | Deferred／uncommitted idea disposition |

### Historical artifacts to create

| File | Responsibility |
|---|---|
| `docs/audits/documentation_usability_hardening_task_1_review.md` | Feature Guide Task review |
| `docs/audits/documentation_usability_hardening_task_2_review.md` | App routes Task review |
| `docs/audits/documentation_usability_hardening_task_3_review.md` | API route Task review |
| `docs/audits/documentation_usability_hardening_task_4_review.md` | Audit index Task review |
| `docs/audits/documentation_usability_hardening_task_5_review.md` | Roadmap disposition Task review |
| `docs/audits/documentation_usability_hardening_final_review.md` | Whole-initiative holistic final review |

---

### Task 1: Feature Guide Responsibility

**Files:**
- Modify: `docs/guides/how-to-add-feature.md`
- Create: `docs/audits/documentation_usability_hardening_task_1_review.md`

**Consumes:**
- `docs/README.md` task-based reading route。
- `docs/governance/documentation_policy.md` Guide與authority規則。
- `docs/adr/README.md` canonical ADR routing。
- App／Feature／Package README current local contracts。

**Produces:**
- 一份薄型 `feature-addition-operational-procedure`。
- 可供 Task 2、Task 3 與 final review引用的 Feature integration route。

- [ ] **Step 1: Capture the pre-change failure state**

Run:

```bash
python3 - <<'PY'
from pathlib import Path
p = Path('docs/guides/how-to-add-feature.md')
text = p.read_text(encoding='utf-8')
assert '暫不實作' in text
assert 'Feature integration checklist' not in text
print('Pre-change placeholder confirmed.')
PY
```

Expected:

```txt
Pre-change placeholder confirmed.
```

- [ ] **Step 2: Replace the placeholder with managed Guide metadata and scope**

Write front matter:

```yaml
---
document_type: guide
status: active
authoritative_for:
  - feature-addition-operational-procedure
last_reviewed_baseline: 1.8.0
---
```

Add sections with these exact responsibilities:

```txt
Purpose and non-authority statement
Pre-reading route
Feature responsibility decision gate
Domain / Data / Presentation sequence
API and persistence integration entry points
DI registration
Route integration
Localization
Tests
Feature README
ADR decision gate
Generated source and verification
```

Every architecture rule must use a short summary plus links to current authority. Do not duplicate full ADR contract.

- [ ] **Step 3: Run focused semantic assertions**

Run:

```bash
python3 - <<'PY'
from pathlib import Path
text = Path('docs/guides/how-to-add-feature.md').read_text(encoding='utf-8')
required = [
    'document_type: guide',
    'feature-addition-operational-procedure',
    'Pre-reading',
    'Domain',
    'Data',
    'Presentation',
    'DI',
    'Route',
    'Localization',
    'Tests',
    'ADR',
    'build_runner',
]
missing = [item for item in required if item not in text]
assert not missing, missing
assert '暫不實作' not in text
print('Feature Guide focused assertions passed.')
PY
```

Expected:

```txt
Feature Guide focused assertions passed.
```

- [ ] **Step 4: Perform formal review and record findings**

Create `docs/audits/documentation_usability_hardening_task_1_review.md` with:

```yaml
document_type: phase-review
status: accepted
authoritative_for:
  - documentation-usability-hardening-task-1-review
last_reviewed_baseline: 1.8.0
```

Review at least:

```txt
Guide scope
ADR duplication
Current authority links
Feature / App / Package boundary
Missing integration steps
Generated and verification route
```

Record every finding with ID、severity、evidence與disposition。若有 finding，先保留 open 狀態。

- [ ] **Step 5: Fix findings and re-review**

Apply only Task 1 fixes. Update the review artifact with the fix evidence and final gate:

```txt
Open P0: 0
Open P1: 0
Open P2: 0
Task 1 re-review: Passed
```

- [ ] **Step 6: Validate Task 1**

Run:

```bash
dart run melos run docs_check
git diff --check
```

Expected:

```txt
Documentation check passed.
git diff --check exits 0.
```

- [ ] **Step 7: Commit Task 1**

Run:

```bash
git add docs/guides/how-to-add-feature.md \
  docs/audits/documentation_usability_hardening_task_1_review.md
git commit -m "docs(guide): 建立新增 Feature 操作路徑"
```

---

### Task 2: App Database and Integration Routes

**Files:**
- Modify: `apps/flutter_architecture/README.md`
- Create: `docs/audits/documentation_usability_hardening_task_2_review.md`

**Consumes:**
- Task 1 Feature Guide route。
- App database、router、DI、localization、persistence source與tests。
- Relevant canonical ADR。

**Produces:**
- App-local Database schema／migration route。
- App-local Router／DI／Localization／Persistence／Tests integration route。

- [ ] **Step 1: Inspect exact App integration entry points**

Read and verify these paths exist:

```txt
apps/flutter_architecture/lib/app/database/app_database_schema.dart
apps/flutter_architecture/lib/app/di/register_module.dart
apps/flutter_architecture/lib/app/router/app_router.dart
apps/flutter_architecture/lib/app/localization/
apps/flutter_architecture/test/app/database/
apps/flutter_architecture/test/app/di/
apps/flutter_architecture/test/app/router/
apps/flutter_architecture/test/app/localization/
```

Run:

```bash
python3 - <<'PY'
from pathlib import Path
paths = [
    'apps/flutter_architecture/lib/app/database/app_database_schema.dart',
    'apps/flutter_architecture/lib/app/di/register_module.dart',
    'apps/flutter_architecture/lib/app/router/app_router.dart',
    'apps/flutter_architecture/lib/app/localization',
    'apps/flutter_architecture/test/app/database',
    'apps/flutter_architecture/test/app/di',
    'apps/flutter_architecture/test/app/router',
    'apps/flutter_architecture/test/app/localization',
]
missing = [p for p in paths if not Path(p).exists()]
assert not missing, missing
print('App integration entry points confirmed.')
PY
```

- [ ] **Step 2: Add Database schema / migration route**

Add a concise section to App README that routes:

```txt
app_database_schema.dart
→ version increment
→ onCreate fresh path
→ incremental onUpgrade path
→ affected LocalDataSource / store
→ migration / persistence tests
→ relevant Feature README and ADR
→ docs_check and focused tests
```

Do not copy DDL、database version history或historical migration journal。

- [ ] **Step 3: Add App integration route**

Add a concise section that routes:

```txt
Router declaration
→ generated routes
→ App DI registration
→ localization resources / failure mapping
→ persistence adapter
→ App / Feature tests
→ build_runner
→ repository validation
```

Link Task 1 Feature Guide as the general workflow entry. Keep App README local to App responsibilities.

- [ ] **Step 4: Perform formal review and record findings**

Create `docs/audits/documentation_usability_hardening_task_2_review.md` with phase-review metadata and review:

```txt
Local scope
Database migration correctness route
Router / DI / Localization / Persistence ordering
Source and test links
ADR duplication
Feature Guide cross-link
```

- [ ] **Step 5: Fix findings and re-review**

Update the review artifact until:

```txt
Open P0: 0
Open P1: 0
Open P2: 0
Task 2 re-review: Passed
```

- [ ] **Step 6: Validate Task 2**

Run:

```bash
dart run melos run docs_check
git diff --check
```

- [ ] **Step 7: Commit Task 2**

Run:

```bash
git add apps/flutter_architecture/README.md \
  docs/audits/documentation_usability_hardening_task_2_review.md
git commit -m "docs(app): 補強資料庫與整合操作路徑"
```

---

### Task 3: API Endpoint and External Client Route

**Files:**
- Modify: `packages/api_client/README.md`
- Create: `docs/audits/documentation_usability_hardening_task_3_review.md`

**Consumes:**
- ADR-012、ADR-013與App Composition Root contract。
- Existing API Client source、exports、mock與tests。

**Produces:**
- Same-backend endpoint checklist。
- External-system package decision route。

- [ ] **Step 1: Inspect current API Client public and test topology**

Verify:

```txt
packages/api_client/lib/api_client.dart
packages/api_client/lib/src/
packages/api_client/test/
apps/flutter_architecture/lib/app/di/
```

- [ ] **Step 2: Add endpoint checklist**

Add an ordered checklist covering:

```txt
API abstraction / Retrofit declaration
Wire DTO and serialization
Mock / Real parity
Public export
Authentication metadata
Transport exception mapping
Feature DataSource / Repository mapping
App DI selection / registration
Package and Feature tests
build_runner and validation
```

- [ ] **Step 3: Add external client decision route**

State that a new external system must first evaluate independent auth、error format、rate limit、release lifecycle與reuse boundary, then route to canonical package／ADR authority. Do not create a new splitting rule in the README.

- [ ] **Step 4: Perform formal review and record findings**

Create `docs/audits/documentation_usability_hardening_task_3_review.md` and review:

```txt
Retrofit / Dio responsibility
DTO / Domain separation
Mock parity
Auth metadata
DataSource / Repository / DI integration
External system decision authority
Generated source validation
```

- [ ] **Step 5: Fix findings and re-review**

Reach:

```txt
Open P0: 0
Open P1: 0
Open P2: 0
Task 3 re-review: Passed
```

- [ ] **Step 6: Validate Task 3**

Run:

```bash
dart run melos run docs_check
git diff --check
```

- [ ] **Step 7: Commit Task 3**

Run:

```bash
git add packages/api_client/README.md \
  docs/audits/documentation_usability_hardening_task_3_review.md
git commit -m "docs(api): 補強 Endpoint 與外部 Client 路徑"
```

---

### Task 4: Audit Navigation

**Files:**
- Modify: `docs/audits/README.md`
- Create: `docs/audits/documentation_usability_hardening_task_4_review.md`

**Consumes:**
- Existing Milestone 24–26 audit directories。
- Change-aware CI audit artifacts。
- Documentation usability audit、review、design review與Task reviews。

**Produces:**
- A current audit routing index without duplicating findings or evidence body。

- [ ] **Step 1: Inventory exact recent audit paths**

Run:

```bash
find docs/audits -maxdepth 2 -type f | sort
```

Confirm exact paths for:

```txt
Milestone 24 final and remote validation
Milestone 25 final and remote validation
Milestone 26 final and remote validation
Change-aware CI plan / implementation / remote / final reviews
Documentation usability audit and formal review
```

- [ ] **Step 2: Update Audit index routing**

Add concise grouped routes. Each entry must contain only:

```txt
artifact or group
short purpose
stable path
```

Do not copy findings、test counts、commit hashes或final gate details。

- [ ] **Step 3: Perform formal review and record findings**

Create `docs/audits/documentation_usability_hardening_task_4_review.md` and review:

```txt
Coverage of recent artifacts
No duplicate evidence body
Historical / current authority distinction
Stable relative links
Index responsibility
```

- [ ] **Step 4: Fix findings and re-review**

Reach:

```txt
Open P0: 0
Open P1: 0
Open P2: 0
Task 4 re-review: Passed
```

- [ ] **Step 5: Validate Task 4**

Run:

```bash
dart run melos run docs_check
git diff --check
```

- [ ] **Step 6: Commit Task 4**

Run:

```bash
git add docs/audits/README.md \
  docs/audits/documentation_usability_hardening_task_4_review.md
git commit -m "docs(audit): 補齊近期審查導航"
```

---

### Task 5: Roadmap and Backlog Disposition

**Files:**
- Modify: `docs/roadmap/candidates.md`
- Modify: `docs/backlog.md`
- Create: `docs/audits/documentation_usability_hardening_task_5_review.md`

**Consumes:**
- Accepted audit conclusion。
- Accepted design scope。
- Roadmap candidate與backlog responsibility contract。

**Produces:**
- A single current disposition for Documentation Knowledge Expansion。

- [ ] **Step 1: Capture current duplicate listing**

Run:

```bash
grep -n "Documentation Knowledge Expansion\|完整Feature新增指南\|常見錯誤與除錯指南\|架構演進" \
  docs/roadmap/candidates.md docs/backlog.md
```

Expected: matching entries in both files。

- [ ] **Step 2: Update Roadmap candidate disposition**

Replace the large expansion candidate with a concise stable disposition:

```txt
Large Documentation Knowledge Expansion: not justified by the accepted audit.
Confirmed usability gaps are handled by the bounded Documentation Usability Hardening design and plan, not by a Milestone or open-ended candidate.
Future documentation expansion requires new evidence and a new candidate review.
```

Do not add Task journal or implementation status details。

- [ ] **Step 3: Update Backlog disposition**

Remove duplicate active idea entries for full Feature、Troubleshooting與Architecture Evolution guides. Preserve only a concise future-evidence rule if needed. Do not erase unrelated backlog items。

- [ ] **Step 4: Perform formal review and record findings**

Create `docs/audits/documentation_usability_hardening_task_5_review.md` and review:

```txt
Candidate / backlog responsibility
No duplicate active direction
Historical intent preservation
No Task journal
No accidental Milestone promotion
```

- [ ] **Step 5: Fix findings and re-review**

Reach:

```txt
Open P0: 0
Open P1: 0
Open P2: 0
Task 5 re-review: Passed
```

- [ ] **Step 6: Validate Task 5**

Run:

```bash
dart run melos run docs_check
git diff --check
```

- [ ] **Step 7: Commit Task 5**

Run:

```bash
git add docs/roadmap/candidates.md docs/backlog.md \
  docs/audits/documentation_usability_hardening_task_5_review.md
git commit -m "docs(roadmap): 收斂文件強化候選範圍"
```

---

### Task 6: Holistic Documentation Review and Closure

**Files:**
- Modify: `docs/superpowers/specs/2026-07-23-documentation-usability-hardening-design.md`
- Modify: `docs/superpowers/plans/2026-07-23-documentation-usability-hardening.md`
- Modify: `docs/audits/README.md`
- Create: `docs/audits/documentation_usability_hardening_final_review.md`

**Consumes:**
- Task 1–5 committed changes與review artifacts。
- Accepted design、plan與original audit evidence。

**Produces:**
- Whole-initiative final disposition。
- Historical plan／design lifecycle closure。

- [ ] **Step 1: Review the complete committed range**

Review all Task 1–5 commits and verify:

```txt
No ADR duplication
No new architecture authority
Feature Guide is operational only
App and API README routes are local only
Audit index contains routing only
Candidates and Backlog have one disposition
No out-of-scope file changes
```

- [ ] **Step 2: Run cross-document focused checks**

Run:

```bash
python3 - <<'PY'
from pathlib import Path

guide = Path('docs/guides/how-to-add-feature.md').read_text(encoding='utf-8')
app = Path('apps/flutter_architecture/README.md').read_text(encoding='utf-8')
api = Path('packages/api_client/README.md').read_text(encoding='utf-8')
audits = Path('docs/audits/README.md').read_text(encoding='utf-8')
candidates = Path('docs/roadmap/candidates.md').read_text(encoding='utf-8')
backlog = Path('docs/backlog.md').read_text(encoding='utf-8')

assert 'feature-addition-operational-procedure' in guide
assert 'app_database_schema.dart' in app
assert 'Retrofit' in api and 'Mock' in api and 'build_runner' in api
for required in ('milestone_24', 'milestone_25', 'milestone_26', 'change_aware_ci'):
    assert required in audits, required
combined = candidates + '\n' + backlog
assert combined.count('Documentation Knowledge Expansion') <= 1
print('Cross-document focused checks passed.')
PY
```

- [ ] **Step 3: Create holistic final review**

Create `docs/audits/documentation_usability_hardening_final_review.md` with:

```yaml
document_type: final-review
status: accepted
authoritative_for:
  - documentation-usability-hardening-final-review
last_reviewed_baseline: 1.8.0
```

Review scope must include design、plan、Task reviews、active documents、authority model、links、metadata與scope discipline。

- [ ] **Step 4: Record findings, fix and re-review**

If findings exist, fix only within approved scope, update the responsible Task review or final review evidence, then reach:

```txt
Open P0: 0
Open P1: 0
Open P2: 0
Holistic re-review: Passed
```

- [ ] **Step 5: Close design and plan lifecycle**

Update design metadata:

```yaml
status: completed
```

Update plan metadata:

```yaml
status: completed
```

Update their final gate sections to state initiative closure and link the holistic final review. Do not rewrite historical task steps as current state。

Update `docs/audits/README.md` once more to route:

```txt
Task 5 review
Documentation Usability Hardening holistic final review
```

Keep the index entry routing-only; do not copy findings or closure evidence body。

- [ ] **Step 6: Run final validation**

Run:

```bash
dart run melos run docs_check
git diff --check
git status --short
```

Expected:

```txt
Documentation check passed.
git diff --check exits 0.
Only Task 6 approved files are uncommitted.
```

- [ ] **Step 7: Commit Task 6**

Run:

```bash
git add \
  docs/superpowers/specs/2026-07-23-documentation-usability-hardening-design.md \
  docs/superpowers/plans/2026-07-23-documentation-usability-hardening.md \
  docs/audits/README.md \
  docs/audits/documentation_usability_hardening_final_review.md
git commit -m "docs(governance): 完成文件可用性強化終審"
```

---

## Plan Task Closure

The implementation plan itself must complete the same closure model before Task 1 begins:

```txt
implement
→ formal plan review
→ findings
→ fix
→ re-review
→ Open P0 / P1 = 0
→ docs_check and git diff validation
→ commit
```

Until the plan review is accepted and committed, documentation implementation is not authorized.

Formal plan review：

- `../../audits/documentation_usability_hardening_plan_review.md`

## Final Gate

```txt
Plan status: Completed
Formal plan review: Accepted
Open P0 / P1: 0
Task 1–6: Completed
Holistic final review: Accepted
```

本 plan 已完成所有 Task closure。Current documentation state 由各 active Guide／README／Roadmap authority 擁有；本文件只保留 implementation sequence 與 historical execution evidence。
