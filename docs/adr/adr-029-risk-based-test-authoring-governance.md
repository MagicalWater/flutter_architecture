---
document_type: architecture-decision
status: accepted
authoritative_for:
  - risk-based-test-authoring-governance
last_reviewed_baseline: 1.16.0
id: ADR-029
title: Risk-Based Test Authoring Governance
supersedes: []
superseded_by: []
related:
  - ADR-001
  - ADR-023
---

# ADR-029 — Risk-Based Test Authoring Governance

## Status

Accepted。

## Context

Repository已透過Milestone 30建立existing test ownership／rationalization，並透過ADR-023與Milestone 35建立Minimum Sufficient Validation execution routing。但「一個新Task是否值得新增test」缺少stable authority。

若TDD、Feature reference與雙層Task被機械解讀為每Task／class／layer新增test，template foundation的高密度tests會被複製到普通產品Feature，形成Test Authoring／Maintenance Hell。

## Decision

Test authoring採risk-based、minimum-sufficient原則：

```txt
risk / invariant / failure mode
→ existing owner coverage
→ Required | Recommended | no-new-test justified | Should-not-add
→ nearest primary owner when adding
```

TDD用於建立最小充分regression evidence，不代表每Task、每class或每architecture layer都必須新增test。

`Required`涵蓋business invariant、security、persistence／migration、concurrency／ordering、idempotency、複雜state machine與可靠bug regression等高風險行為。這些風險必須有direct regression owner。

`Recommended`用於有實質observable branch但需比較regression detection value與maintenance cost的情況。

`no-new-test justified`允許0個新test，前提是沒有新的Required risk，且existing owner已充分覆蓋或mutation本身沒有新的可測failure mode。

`Should-not-add`拒絕trivial getter／setter、pure passthrough called-once、framework behavior、layer-for-layer duplication、class-for-class files、mechanical golden與coverage quota testing。

Template foundation test density不得成為產品Feature的test quota。Auth／Catalog／Profile可作architecture與owner boundary reference，但不是test-density reference。

Test Authoring Decision與ADR-023的Validation Execution Decision保持分離。0 new tests永遠不等於0 validation；`tools/ci/validation_planner.py`仍是execution selection唯一machine authority。

## Consequences

- 普通低風險Feature可以合法以`no-new-test justified`完成Task，而不被迫增加case count。
- 高風險security／migration／persistence／concurrency behavior仍有強制regression owner。
- Test count、LOC與coverage percentage不再能作authoring成功KPI。
- 雙層Task保留完整review與validation，但Task數不再自然轉換成test數。
- Existing test deletion仍受既有replacement evidence與deletion manifest治理，本ADR不授權以「風險較低」直接刪除existing coverage。

## Related Decisions

- ADR-001：Clean Architecture／Feature First boundary。
- ADR-023：Minimum Sufficient Validation與CI execution selection authority。
