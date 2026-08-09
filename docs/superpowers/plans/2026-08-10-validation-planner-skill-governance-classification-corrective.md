---
document_type: implementation-plan
status: accepted
authoritative_for:
  - validation-planner-skill-governance-classification-corrective-plan
last_reviewed_baseline: 1.16.0
---

> User approval: 2026-08-10. Managed implementation worktree may be created only after execution admission.

# Validation Planner — Skill Governance Path Classification Corrective Implementation Plan

> **For agentic workers:** 依accepted Design與中央治理逐Task執行；production classifier修改採TDD，所有Task遵守Level 4 full two-layer governance。

**Goal:** 讓所有repository-managed Skill／lock／provenance paths得到既有`governance` canonical classification，執行Skill docs／lock contracts而不誤觸Flutter／platform full matrix，同時保留真正unknown、invalid range與validation-engine self-change的full fail-safe。

**Architecture:** 只擴充`change_classifier.py`的known governance path predicate，不新增change class、不修改planner selection semantics。先以classifier／planner RED tests鎖定repository-authored Skill、third-party Skill、`skills-lock.json`、vendored provenance、mixed docs與unknown negative controls；再做最小classifier GREEN。最後以Skill lock drift與whole corrective review證明under-validation被修復且fail-safe未弱化。

## Global Constraints

- Accepted Design：`docs/superpowers/specs/2026-08-10-validation-planner-skill-governance-classification-corrective-design.md`。
- Stable validation authority：ADR-023＋Milestone 35 accepted validation governance。
- 不新增`skill_governance`／`skill_lock` change class。
- 不修改Flutter production source、generated source、Android／iOS runner或workspace dependency graph。
- 不把所有`.agents/**`、`third_party/**`、JSON或Markdown泛化為known governance。
- `unknown`、invalid range、classifier／planner failure與validation-engine self-change的full fail-safe不得弱化。
- Planner只選machine validation；Skill semantic change是否需要fresh behavioral pressure evidence仍由中央Skill adoption governance決定。
- Implementation必須在managed worktree進行；Plan accepted前不得建立。

## Task SG-P — Plan Governance

**Files:** Plan、Plan Review、Superpowers／Audit indexes。

- [ ] 確認accepted Design全部acceptance criteria都有implementation／validation owner。
- [ ] 確認RED→GREEN ordering、managed worktree gate與commit boundaries完整。
- [ ] 確認沒有建立第二份path matrix authority或要求無關Flutter/platform validation。
- [ ] 完成focused review、finding disposition、fresh re-review與whole-Plan review。
- [ ] Fresh執行`docs_check`、相關docs policy tests與`git diff --check`。
- [ ] 使用者明確核准後才將Plan標記accepted並進入execution admission。

## Task SG-1 — Classification Contract RED

**Files:**

- Modify: `tools/ci/test_change_classifier.py`
- Modify: `tools/ci/test_validation_planner.py`
- Create: `docs/audits/validation_planner_skill_governance_classification/sg-1_contract_red_review.md`

### RED scenarios

- [ ] Repository-authored Skill `SKILL.md`期望`governance`，current implementation必須RED。
- [ ] Repository-authored Skill `references/*.md`期望`governance`，current implementation必須RED。
- [ ] Third-party locked Skill期望`governance`，current implementation必須RED。
- [ ] `skills-lock.json`期望`governance`且不得`fail_safe`，current implementation必須RED。
- [ ] `third_party/skills/taste-skill/LICENSE`期望`governance`且不得`fail_safe`，current implementation必須RED。
- [ ] Skill＋ordinary docs mixed set期望ordered classes `(docs_content, governance)`。
- [ ] Planner對governance Skill change期望focused＋`tools/docs`、無Flutter／generated／Android／iOS。
- [ ] Negative control `.agent-runtime/new-policy.bin`仍期望`unknown`＋full fail-safe。
- [ ] Invalid range與`tools/ci/change_classifier.py` self-change existing tests保持GREEN。

### Review gate

- [ ] 確認RED只來自Design定義的missing path coverage，不修改production routing。
- [ ] 建立Task review並完成whole-Task review。
- [ ] Commit：`test(ci): 鎖定Skill治理路徑分類契約`。

## Task SG-2 — Minimal Governance Path GREEN

**Files:**

- Modify: `tools/ci/change_classifier.py`
- Test: `tools/ci/test_change_classifier.py`
- Test: `tools/ci/test_validation_planner.py`
- Create: `docs/audits/validation_planner_skill_governance_classification/sg-2_classifier_green_review.md`

### Implementation

- [ ] 只擴充existing `_is_governance_path()`，加入exact/root-scoped rules：

```text
.agents/skills/**
skills-lock.json
third_party/skills/**
```

- [ ] 不修改`_CHANGE_CLASS_ORDER`、planner class handling或runner commands。
- [ ] 不新增semantic file-content parsing。
- [ ] 不把`.agents`其他root或generic`third_party`納入known scope。

### GREEN / regression

- [ ] SG-1新增tests全部GREEN。
- [ ] Existing classifier/planner suite全部GREEN。
- [ ] Fresh direct probes確認Skill→focused governance、unknown→full fail-safe。
- [ ] Review diff確認production mutation保持classifier predicate narrowly scoped。
- [ ] Commit：`fix(ci): 補齊Skill治理路徑分類`。

## Task SG-3 — Skill Integrity and Consumer Contract Review

**Files:**

- Test/Review: `tools/docs/skill_lock.py`
- Test/Review: `tools/docs/test_skill_lock.py`
- Test/Review: `tools/docs/test_check_docs.py`
- Test/Review: `tools/ci/validation_runner.py`
- Create: `docs/audits/validation_planner_skill_governance_classification/sg-3_integrity_consumer_review.md`

- [ ] 使用temporary fixture證明locked Skill byte drift在governance plan下由docs/lock contractFAIL。
- [ ] 證明valid third-party lock／license仍PASS。
- [ ] 證明governance plan的quality commands包含`check_docs.py`＋`tools/docs` unittest scope。
- [ ] 證明不需要修改`validation_planner.py`、`validation_runner.py`或`tools/docs/**`；若發現真實consumer gap，保持Task open並只做Design允許的最小擴展＋fresh re-review。
- [ ] Commit只有在production／test mutation存在時建立；純review evidence可與本Task audit獨立提交。

## Task SG-4 — Holistic Corrective Review and Authority Closure

**Files:**

- Create: `docs/audits/validation_planner_skill_governance_classification/sg-4_holistic_final_review.md`
- Modify if needed: `docs/audits/README.md`
- Modify if needed: `docs/superpowers/README.md`
- Review only unless stale: `docs/adr/adr-023-repository-ci-quality-gates-android-verification-artifact.md`
- Review only unless stale: `docs/governance/development_workflow.md`
- Review only unless stale: `docs/guides/testing_governance.md`

- [ ] Cross-Task確認所有accepted Design acceptance criteria均有fresh evidence。
- [ ] Fresh執行planner-selected validation for implementation range；classifier self-change預期會因`validation_engine`要求full verification，這是本corrective自身的高風險gate，不代表未來Skill change仍full。
- [ ] Fresh執行classifier/planner/runner/docs Skill lock contracts。
- [ ] 確認unknown／invalid／validation-engine fail-safe沒有弱化。
- [ ] 確認ordinary Skill path在fixed classifier下為focused governance且沒有Flutter/platform build。
- [ ] Review ADR-023／governance／testing Guide；只有current文字不準確時做最小同步，禁止複製exact path matrix。
- [ ] 決定release disposition。預設不建立新baseline；只有版本政策或current authority要求publication時才另走release gate。
- [ ] Open P0=0、Open P1 without disposition=0後完成holistic review。

## Execution Admission after Plan Approval

Plan取得使用者核准後：

1. 從fresh `main/origin/main` identity建立managed worktree與corrective branch。
2. 確認Plan／Design均為accepted且implementation worktree clean。
3. 記錄base SHA、branch、worktree path與禁止scope。
4. 才允許Task SG-1開始。

## Commit Boundaries

```text
SG-P  docs(validation): 核准Skill治理分類修正計畫
SG-1  test(ci): 鎖定Skill治理路徑分類契約
SG-2  fix(ci): 補齊Skill治理路徑分類
SG-3  test/docs or docs(audit): 驗證Skill完整性與consumer contract
SG-4  docs(audit): 完成Skill治理分類修正總審查
```

Exact commit只在對應Task完整gate通過後建立；不得把failed Task回寫為已通過。

## Plan Acceptance Criteria

1. Design acceptance criteria 1～7全部對應至少一個Task與fresh validation。
2. Production mutation預設只限`tools/ci/change_classifier.py`。
3. RED先於production GREEN。
4. Third-party integrity由existing docs/lock authority驗證，不複製hash/schema logic。
5. Unknown negative control與validation-engine full gate都有明確regression owner。
6. Plan不要求一般Skill change跑Flutter／platform regression。
7. Plan execution前有明確managed worktree gate。

## Status

**ACCEPTED — 2026-08-10使用者已明確核准。**

Implementation只允許在通過execution admission的managed worktree內依SG-1～SG-4執行。
