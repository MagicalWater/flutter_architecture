---
document_type: planning-review
status: accepted
authoritative_for:
  - milestone-36-design-spec-review
last_reviewed_baseline: 1.16.0
---

# Milestone 36 — Design Spec Review

## Task scope

Review target：`docs/superpowers/specs/2026-08-12-milestone-36-test-authoring-cost-risk-based-testing-governance-design.md`。

本Task只review Design，不開始Plan或implementation。

## Focused findings

### F-36-D-01 — 不可把TDD corrective變成「低風險一律不測」

Severity：P1。

Disposition：Resolved。Design明確區分authoring decision與validation decision；`no-new-test justified`只表示不新增test，Milestone 35 planner-selected affected validation仍必須執行。

### F-36-D-02 — `no-new-test justified`可能成為高風險escape hatch

Severity：P1。

Disposition：Resolved。Required risk只有在existing direct owner已完整覆蓋相同failure mode時才能不新增test；persistence／security等沒有existing owner時不得使用此disposition，並加入pressure scenario。

### F-36-D-03 — Foundation vs Product distinction不可造成existing template tests降級

Severity：P1。

Disposition：Resolved。Design明確說明Auth／Catalog等foundation高密度tests可因真實risk保留；本Milestone不預設刪除existing tests，cleanup仍受Milestone 30 deletion governance。

### F-36-D-04 — Layer-for-layer corrective不可錯誤消滅真正跨層failure source

Severity：P1。

Disposition：Resolved。Design保留Milestone 30 primary-owner原則；DAO transaction、Repository policy、Bloc ordering、Widget rendering若具有不同observable failure source仍可各自測，只禁止沒有新增failure source的重複assertion。

### F-36-D-05 — 不應修改Milestone 35 planner來承擔authoring policy

Severity：P1。

Disposition：Resolved。Design預設planner不變；authoring disposition由workflow／Task evidence擁有，planner仍只回答changed range需要跑哪些validation。

## Focused re-review

Design已完整回答Requirement Decision要求的八個問題：Required／Recommended／May omit／Should-not-add、`no-new-test justified` guard、TDD route、reference Feature boundary、雙層Task integration與execution planner separation均有明確contract。

## Whole-Task holistic review

- Scope沒有回頭重做Milestone 35 execution-cost work。
- 沒有coverage percentage quota。
- 沒有test-count KPI。
- 沒有取消TDD或雙層Task治理。
- 沒有要求大規模刪除existing tests。
- Stable ADR與Guide／Skill authority有清楚ownership。
- Design可由pressure scenarios驗證，不只停留在抽象原則。

## Documentation authority check

- Requirement Decision：`36-r_requirement_decision.md`擁有scope／classification／artifact routing。
- Proposed Design：擁有behavioral／technical solution contract；在使用者核准前不得標記accepted。
- Testing Governance：Implementation後仍作human policy authority。
- New ADR：Implementation後擁有stable test-authoring decision。
- Milestone 35 planner：維持validation execution唯一machine authority。

## Required validation

Design Task只包含managed documentation mutation；依Minimum Sufficient Validation執行docs／authority validation，不跑full Flutter regression。

Fresh result：

```txt
python tools\docs\check_docs.py . → PASS
git diff --check                 → PASS
```

`git diff --check`只輸出一則既有tracked test檔案的Windows LF→CRLF提示；該檔不在本Task diff／status中，沒有形成mutation或validation failure。

## Review disposition

```txt
Design focused review: PASS after findings resolved
Whole-Task holistic review: PASS
Open P0: 0
Open P1 without disposition: 0
Design status: PROPOSED / awaiting explicit user approval
Implementation Plan allowed now: NO
```
