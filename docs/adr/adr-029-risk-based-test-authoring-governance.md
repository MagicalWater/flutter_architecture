---
document_type: architecture-decision
status: accepted
authoritative_for:
  - risk-based-test-authoring-governance
last_reviewed_baseline: 1.16.0
id: ADR-029
title: Test-by-Exception Authoring and Retention Governance
supersedes: []
superseded_by: []
related:
  - ADR-001
  - ADR-023
---

# ADR-029 — Test-by-Exception Authoring and Retention Governance

## Status

Accepted。

## Context

Repository早期透過Milestone 30建立coverage-preservation式existing test ownership／rationalization，並透過ADR-023與Milestone 35建立Minimum Sufficient Validation execution routing。後續實務證明，只限制「是否新增test」不足以阻止portfolio膨脹：temporary RED、UI regression、architecture prose與governance contracts會在Task完成後永久累積。

若TDD、Feature reference與雙層Task被機械解讀為每Task／class／layer新增test，template foundation的高密度tests會被複製到普通產品Feature，形成Test Authoring／Maintenance Hell。

## Decision

Test authoring與retention採risk-based、test-by-exception原則：

```txt
risk / invariant / failure mode
→ existing owner coverage
→ Required | Recommended | no-new-test justified | Should-not-add
→ temporary evidence when adding
→ GREEN
→ Retain | Merge | Smoke | Delete temporary
```

TDD可用於建立temporary RED／GREEN evidence，不代表該test取得永久repository ownership。Task closure前必須完成Retention Decision。

`Required`只涵蓋failure cost高、人工難穩定發現且長期automation價值明確的business invariant、security、persistence／migration、concurrency／ordering、idempotency等critical behavior。普通deterministic UI／copy／style／wiring bug可以使用temporary regression test，但fix後預設刪除。

`Recommended`用於有實質observable branch但需比較regression detection value與maintenance cost的情況。

`no-new-test justified`允許0個新test，前提是沒有新的Required risk，且existing owner已充分覆蓋或mutation本身沒有新的可測failure mode。

`Should-not-add`拒絕trivial getter／setter、pure passthrough called-once、framework behavior、layer-for-layer duplication、class-for-class files、mechanical golden與coverage quota testing。

Foundation沒有test-density exemption。Auth／Catalog／Profile可作architecture與owner boundary reference，但每個permanent test仍須獨立證明critical retention價值。

Test Authoring Decision、Retention Decision與ADR-023的Validation Execution Decision保持分離。0 permanent tests甚至0 automated tests都可以合法，只要changed risk有最低充分validation／runtime acceptance且沒有缺失critical owner。

Existing coverage不享有preservation priority。Critical protection仍需要replacement／merged owner evidence；low-value protection intentionally retired時，`replacement = NONE`合法，不要求逐case deletion manifest。Portfolio reset以bucket-level disposition、critical keep matrix與before／after metrics即可。

## Consequences

- 普通低風險Feature可以合法以`no-new-test justified`完成Task，而不被迫增加case count。
- 高風險security／migration／persistence／concurrency behavior仍有最小critical regression owner。
- Test count、LOC與coverage percentage不再能作authoring成功KPI。
- Temporary tests在驗證完成後預設移除，portfolio不再隨Task數單向成長。
- Existing low-value coverage可直接退休；replacement test不是刪除本身的前置條件。

## Related Decisions

- ADR-001：Clean Architecture／Feature First boundary。
- ADR-023：Minimum Sufficient Validation與CI execution selection authority。
