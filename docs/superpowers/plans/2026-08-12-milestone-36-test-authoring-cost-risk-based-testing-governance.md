---
document_type: implementation-plan
status: proposed
authoritative_for:
  - milestone-36-implementation-plan
last_reviewed_baseline: 1.16.0
---

# Milestone 36 — Test Authoring Cost & Risk-Based Testing Governance Corrective Implementation Plan

## 1. Authority

- Requirement Decision：`docs/audits/milestone_36/36-r_requirement_decision.md`
- Accepted Design：`docs/superpowers/specs/2026-08-12-milestone-36-test-authoring-cost-risk-based-testing-governance-design.md`

本Plan只定義執行順序、檔案scope、validation與commit boundary，不改寫Design。

## 2. Execution gate

Implementation開始前必須：

1. 本Plan完成focused review、fix、fresh re-review、whole-Task review與authority check。
2. 使用者明確核准本Plan。
3. Plan accepted後才建立managed worktree／branch並重新做fresh execution admission。

## 3. Ordered Tasks

### Task 36-1 — Test Authoring Decision Contract RED

先以repository-owned governance／Skill tests與pressure scenarios鎖定舊治理會失敗的行為：

- trivial passthrough不得因TDD強制新增test；
- business invariant／security／persistence／concurrency必須有direct regression owner；
- existing owner充分覆蓋時允許`no-new-test justified`；
- Auth／Catalog／Profile不得被模仿為test-density quota；
- layer-for-layer、class-for-class testing為anti-pattern；
- `no-new-test justified`不得跳過Milestone 35 validation planner。

主要scope：中央Skill pressure scenarios、對應governance test harness、`docs/audits/milestone_36/36-1_test_authoring_contract_red.md`。

Validation：focused governance contracts、docs check、diff check。

### Task 36-2 — Central Test Authoring Governance GREEN

把唯一可執行authoring policy放入`governing-template-development`：

- 明確區分Test Authoring Decision與Validation Execution Decision；
- 建立`Required`／`Recommended`／`no-new-test justified`／`Should-not-add`；
- TDD改為對新增／改變的observable behavior建立最小充分regression evidence，不等於每Task新增test；
- `no-new-test justified`需保存reason與existing owner／risk rationale；
- 雙層Task接受`0 new tests + planner-selected validation PASS`。

主要scope：`SKILL.md`、`artifact-routing.md`、`two-layer-task-governance.md`、`pressure-scenarios.md`，必要時新增一份narrow authoring reference。

Validation：Task 36-1 RED轉GREEN＋Skill/docs governance checks。

### Task 36-3 — Testing Governance Human Authority Alignment

更新`docs/guides/testing_governance.md`：

- Foundation tests vs Product Feature tests；
- risk/failure mode → owner → authoring disposition；
- Required／Recommended／No-new-test／Should-not-add準則；
- getter/setter、passthrough called-once、framework behavior、duplicate layer tests、mechanical golden、coverage quota等anti-pattern；
- test count／coverage percentage不是authoring KPI；
- 明確與Milestone 35 Minimum Sufficient Validation切開。

Validation：docs checker、authority duplication review。

### Task 36-4 — Feature Guide and Reference-Role Corrective

更新：

- `docs/guides/how-to-add-feature.md`
- `docs/guides/agent_assisted_development_quick_start.md`
- `starting-feature-work`只在需要明確route時做最小修改。

要求：

- 移除Domain／Data／Presentation／Integration逐層最低測試暗示；
- Auth／Catalog／Profile標明為architecture／behavior reference，不是test-density reference；
- Feature checklist改為記錄Test Authoring Disposition；
- Quick Start不再無條件要求「必須補測試」，改為risk-based decision。

Validation：docs checker＋cross-guide wording review＋Skill discovery pressure。

### Task 36-5 — Double-Layer Task Governance and TDD Behavioral Review

以fresh behavioral pressure evidence證明Task數量不會機械轉換成test數量。

至少驗證：

1. 五個implementation Tasks但只有兩個新risk owners → 只新增兩組必要regression tests。
2. styling-only Task → `no-new-test justified`，planner validation仍執行。
3. deterministic bug regression → Required。
4. trivial UseCase forwarding → Should-not-add。
5. migration/security → Required，不能用no-new-test逃避。

Evidence：`docs/audits/milestone_36/36-5_tdd_two_layer_governance_review.md`。

### Task 36-6 — Reference Feature Test Density Audit

Read-only-first審查Auth／Catalog／Profile目前tests，並只補必要README reference-role說明：

- 高密度tests來自實際risk/failure owners，不代表新feature需要相同密度；
- 不在README建立逐case清單；
- 預設不刪現有tests；
- 若發現真正duplicate/trivial P1，依既有deletion governance另行disposition；超出accepted scope則停止並重新Requirement Decision。

Evidence：`docs/audits/milestone_36/36-6_reference_feature_test_density_review.md`。

### Task 36-7 — Risk-Based Authoring Acceptance Corpus

建立代表性before/after scenario corpus：

- typo／copy-only；
- trivial getter／passthrough UseCase；
- simple profile-like read feature；
- stateful validation；
- pagination／concurrency；
- auth/security；
- persistence/migration；
- deterministic bug fix；
- styling-only UI；
- existing-owner-covered mutation。

每個scenario記錄risk signals、authoring disposition、預期new-test量級、primary owner、justification與Milestone 35 validation requirement。

成功條件：低風險不被強制新增test；高風險仍Required；`no-new-test justified`永遠不等於no validation。

### Task 36-8 — Holistic Final Review and Release Disposition

跨Task檢查中央Skill、Testing Governance、Feature Guides、reference Feature與TDD／雙層Task沒有平行或矛盾authority。

必要驗證：

- docs checks；
- Skill/governance contract tests；
- Milestone 35 planner-selected validation；
- fresh Level-4 holistic full regression；
- 確認沒有靠刪test降低數量；
- test count不是success KPI。

若治理mutation成立，依Versioning Policy決定新Template Baseline並同步VERSION／CHANGELOG／roadmap／project context／milestone routing。

### Task 36-9 — Published-Main Post-release Validation and Closure

若Task 36-8產生release並取得publication approval：

- integrate/push main；
- published main fresh rerun代表性authoring pressure；
- fresh full regression；
- 必要clean-checkout／remote evidence；
- post-release audit與formal closure。

## 4. Authority guardrails

- Central executable authoring policy只由`governing-template-development`擁有。
- `testing_governance.md`是human-readable policy，不建立第二套routing engine。
- `starting-feature-work`只委派，不自行定義Risk matrix。
- Feature README只描述local reference role。
- `validation_planner.py`繼續只回答「執行哪些validation」，不得成為test-authoring engine。

## 5. Test deletion boundary

本Milestone不以刪除Auth／Catalog／Profile tests作第一解。任何刪除仍需primary owner、replacement evidence與deletion manifest；若形成大規模rationalization，需新的Requirement Decision。

## 6. Two separate correctness gates

Authoring correctness：證明「該不該新增test」判定正確。

Execution correctness：由Milestone 35 planner決定「本Task要跑哪些既有validation」。

`no-new-test justified`仍必須通過Execution correctness。

## 7. Task cycle

每個implementation Task：

```txt
implement
→ focused review
→ findings/fix
→ fresh re-review
→ whole-Task review
→ authority check
→ planner-selected validation
→ Open P0 = 0
→ Open P1 without disposition = 0
→ independent commit
```

## 8. Plan acceptance criteria

1. 先RED contract，再central policy，再Guides/reference，再behavioral/holistic。
2. Plan accepted前不建立worktree或implementation mutation。
3. 不修改Milestone 35 planner responsibility。
4. 不把Auth／Catalog test count當目標密度。
5. 明確允許0 new tests，但不允許0 required validation。
6. Security／migration／persistence／concurrency等Required risks不得用no-new-test逃避。
7. 不以刪test作第一解。

## 9. Current status

本Plan目前為`proposed`。完成Plan Task review並取得使用者明確核准前，不建立managed worktree、不開始Task 36-1、不修改implementation authority。
