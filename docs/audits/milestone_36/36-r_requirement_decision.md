---
document_type: planning-review
status: accepted
authoritative_for:
  - milestone-36-requirement-decision
last_reviewed_baseline: 1.16.0
---

# Milestone 36 — Test Authoring Cost & Risk-Based Testing Governance Requirement Decision

## Admission conclusion

2026-08-12 read-only audit確認：Milestone 30已處理既有tests的owner／rationalization，Milestone 35已處理既有tests的Minimum Sufficient Validation execution routing；兩者都沒有完整治理「新功能是否需要新增test、應新增多少、在哪一層新增」。

Current governance同時存在以下制度性風險：

- `governing-template-development`把Feature／bug implementation直接route至TDD，但沒有test-authoring risk gate。
- `how-to-add-feature.md`以Domain／Data／Presentation／App integration列出「至少依實際變更覆蓋」的測試矩陣，容易被解讀為layer-for-layer testing。
- Feature Guide要求優先參考Auth／Catalog／Profile；但沒有明確說明這些reference的高test density來自其security、migration、cache、concurrency與session failure modes，而不是一般產品Feature的最低測試模板。
- `testing_governance.md`擅長處理既有test ownership與cleanup，但沒有Required／Recommended／Optional／Should-not-add的authoring decision，也沒有`no-new-test justified` disposition。

## Requirement Decision

- Request（需求）：建立Risk-Based／Minimum Sufficient Test Authoring治理，避免未來採用模板開發產品時，AI因TDD、reference Feature與雙層Task治理而為普通功能持續建立過量tests。
- Problem（問題）：Current authority缺少「新增test是否有足夠failure-detection value」的decision gate；現有規則主要單向防止漏測，沒有對trivial、layer-for-layer、structure-only與duplicate-invariant testing建立反向約束。
- Current behavior（目前行為）：Feature與bug implementation一般route至TDD；Feature Guide列出多層測試boundary；existing reference Features具有高密度tests；雙層Task要求每個Task有validation evidence，但未明確區分「執行既有affected tests」與「本Task必須新增test」。
- Expected behavior（預期行為）：Test authoring由risk／invariant／failure mode驅動，而不是由class／layer／Task數量驅動；TDD不等於mandatory new-test-per-task；允許有evidence的`no-new-test justified`，同時保留affected existing validation。
- Value（價值）：降低產品Feature長期Test Authoring／Maintenance成本，避免template foundation test density被機械複製，又不降低security、migration、persistence、concurrency、state-machine、protocol與critical integration regression protection。
- Classification（分類）：**Level 4 — Architecture／repository-wide governance**。本工作將修改repository-wide Skill routing、testing policy、Feature Guide與Task evidence semantics；不是單一Feature或局部文件clarification。
- Decision（決策）：**Accept**。
- Scope（範圍）：Risk-Based Test Authoring；Minimum Sufficient Test Authoring；TDD authoring gate；Foundation vs Product Feature reference boundary；`no-new-test justified`；Required／Recommended／May omit／Should not add分類；雙層Task的authoring／validation separation；相關pressure scenarios與human／Agent guidance。
- Non-goals（非目標）：重新處理Milestone 35的execution speed；以test count下降作KPI；大規模刪除既有tests；取消TDD；取消雙層Task治理；降低security／migration／persistence／concurrency／platform fail-safe coverage；導入coverage percentage quota。
- Behavioral requirements required（是否需要行為需求）：**YES**。
- Design Spec required（是否需要 Design Spec）：**YES**。
- Implementation Plan required（是否需要 Implementation Plan）：**YES**。
- ADR required（是否需要 ADR）：**YES**。Design需建立或修訂stable testing-authoring governance authority；不得只靠Guide文字形成repository-wide stable decision。
- Task governance mode（Task 治理模式）：**Full two-layer Task governance**。
- Worktree／branch：Design／Plan approval前不得建立；Implementation開始前必須建立managed worktree／branch。
- Regression level（Regression 等級）：Level 4 holistic ceiling為full；Design／Plan文件Task只做focused docs／authority validation。Implementation Tasks仍由Milestone 35 planner決定Minimum Sufficient Validation，不因Level 4而每Task固定full。
- Release required（是否需要發布）：**YES，若accepted Design落實repository-wide Skill／Guide／governance mutation**。
- Post-release validation（發布後驗證）：**YES**，需驗證fresh repository discovery／pressure scenarios、docs authority與full regression closure。
- Required Superpowers skills（必要 Superpowers Skills）：Design使用`brainstorming`；Design accepted後使用`writing-plans`；implementation前`using-git-worktrees`；適用production／tooling mutation使用TDD，但必須受本Milestone新authoring gate約束；failure時`systematic-debugging`；review使用review／verification skills；accepted Plan由execution skill執行。
- Required artifacts（必要 artifacts）：Requirement Decision；Design Spec；Design review；stable ADR decision；Implementation Plan；Plan review；authoring pressure evidence；Skill／Guide／governance review；holistic final review；release與post-release evidence。

## Required design questions

Design至少必須回答：

1. 哪些risk／failure mode為Required tests。
2. 哪些情況為Recommended tests。
3. 哪些情況允許不新增tests。
4. 哪些情況應明確禁止新增structure-only／trivial tests。
5. `no-new-test justified`需要哪些最小evidence，且如何避免成為逃避測試的shortcut。
6. TDD如何保留bug regression與behavior-first價值，同時不要求每個Task／layer／class增加test。
7. Auth／Catalog／Profile等reference Feature如何繼續保有architecture reference role，但不得形成test-density quota。
8. 雙層Task中的authoring decision與Milestone 35 validation planner如何分工。

## Decision disposition

```txt
Classification: Level 4 — Architecture／repository-wide governance
Decision: ACCEPT
Design Spec: REQUIRED
Implementation Plan: REQUIRED AFTER Design approval
ADR: REQUIRED
Managed worktree: NOT YET
Implementation allowed now: NO
Next action: Milestone 36 Design Spec + Design Task review
```
