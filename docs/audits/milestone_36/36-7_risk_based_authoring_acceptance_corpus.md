---
document_type: phase-review
status: active
authoritative_for:
  - milestone-36-task-36-7-risk-based-authoring-acceptance-corpus
last_reviewed_baseline: 1.16.0
---

# Task 36-7 — Risk-Based Authoring Acceptance Corpus

## Purpose

建立固定scenario corpus，驗證Test Authoring Decision能同時避免低價值over-authoring與高風險under-testing。這些scenario是acceptance evidence，不是要求產品Feature照表建立相同tests。

## Corpus

| Scenario | Risk signals | Authoring disposition | Expected new-test magnitude | Primary owner | Milestone 35 validation |
|---|---|---|---|---|---|
| Typo／copy-only | 無state、interaction、branch | `no-new-test justified` | 0 | existing presentation/docs owner | Required；planner-selected docs／affected validation |
| Trivial getter | 語言／field access本身 | `Should-not-add` | 0 | none | Required；affected validation仍執行 |
| Passthrough UseCase | 無policy、mapping、branch | `Should-not-add` | 0 | none | Required；不得以called-once test取代validation |
| Simple profile-like read | loading/content/failure，但無新高風險規則 | `Recommended` only for meaningful branches；trivial layers may be no-new-test | 0～少量 | closest observable state／mapping owner | Required；feature affected validation |
| Stateful validation | 非平凡input rule／state transition | `Required` or `Recommended`依規則criticality | 1 direct owner per independent rule family | validator／domain／state owner | Required；affected validation |
| Pagination／cursor | dedupe、cursor order、cycle、idempotency | `Required` | 至少1個direct regression owner per independent invariant family | Repository／Bloc closest failure source | Required；affected feature/workspace validation |
| Concurrency／stale async | race、ordering、stale completion | `Required` | 1 direct owner per independent race contract | generation／state owner | Required；affected validation |
| Auth／security | authorization、credential lifecycle | `Required` | direct security regression owners | auth/security decision owner | Required；security／affected validation |
| Persistence／migration | write compatibility、destructive transform | `Required` | direct migration／persistence owners | DB migration／store owner | Required；database/generated/affected gates |
| Deterministic bug fix | 可穩定重現observable regression | `Required` | 1 regression owner at failure source | closest bug owner | Required；affected validation |
| Styling-only UI | spacing、copy、visual polish | `no-new-test justified` | 0 | existing Widget／visual owner | Required；planner-selected validation，必要時visual acceptance |
| Existing-owner-covered mutation | identical observable behavior已被direct owner捕捉 | `no-new-test justified` | 0 | existing owner | Required；run affected existing owner |
| Framework-generated wiring | generator/framework保證且無新decision | `no-new-test justified` or `Should-not-add` | 0 | existing generated/boundary owner | Required；generated consistency when selected |
| Non-trivial protocol mapping | semantic transform／failure classification | `Required` | direct mapping/failure owner | mapper／adapter | Required；affected validation |

## Negative controls

以下判斷一律FAIL：

1. 「有5個Tasks，所以至少5個new tests」。
2. 「有Domain／Data／Bloc／Widget四層，所以每層至少一個test」。
3. 「新增class，所以一定建立同名`*_test.dart`」。
4. 「TDD要求先RED，所以即使沒有新failure mode也必須捏造一個失敗test」。
5. 「`no-new-test justified`代表不用跑任何tests」。
6. 「Auth有高密度tests，所以新Feature最低也要接近Auth密度」。
7. 「coverage percentage下降，所以即使沒有observable risk也必須新增test」。
8. 「migration/security已有smoke test，所以新的direct risk可以不補owner」。

## Acceptance checks

### Low-risk controls

- Typo／copy-only：0 new tests accepted。
- Trivial getter：Should-not-add。
- Passthrough UseCase：Should-not-add。
- Styling-only：0 new tests accepted。
- Existing-owner-covered mutation：0 new tests accepted。

### High-risk controls

- Pagination／concurrency／security／migration／deterministic bug：不能因Task小或existing broad smoke coverage而降成zero direct owner。

### Authoring vs execution

所有scenario，即使authoring disposition為0 new tests，仍需Milestone 35 `validation_planner.py`選擇execution scope。

因此canonical invariant：

```txt
new-test count may be 0
required validation may not be inferred as 0 from that fact
```

## Evidence chain

- Task 36-1：舊治理對五個canonical contract cases RED 5/5。
- Task 36-2～36-4：static/machine contract GREEN 5/5。
- Task 36-5：provider-neutral fresh ChatGPT behavioral pressure GREEN。
- Task 36-6：Auth／Catalog／Profile density provenance review，existing deletions 0。

## Whole-Task review

- Corpus同時有positive與negative controls。
- 沒有引入case-count或coverage quota。
- 沒有要求每個scenario建立獨立test file。
- `Required`仍由risk／failure owner驅動；`no-new-test justified`仍不跳過validation。

## Disposition

```txt
Task 36-7: ACCEPTED
Open P0: 0
Open P1 without disposition: 0
Low-risk over-authoring controls: PASS
High-risk under-testing controls: PASS
Authoring/execution separation: PASS
Next Task allowed: YES — proceed to Task 36-8
```
