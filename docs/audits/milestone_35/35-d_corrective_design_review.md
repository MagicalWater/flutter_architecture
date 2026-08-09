---
document_type: planning-review
status: accepted
authoritative_for:
  - milestone-35-corrective-design-review
last_reviewed_baseline: 1.15.2
---

# Milestone 35 — Corrective Design Review

## Scope

Reviewed artifact：

- `docs/superpowers/specs/2026-08-09-milestone-35-test-execution-cost-change-aware-validation-governance-design.md`

Requirement authority：

- `docs/audits/milestone_35/35-r_requirement_decision.md`

## Focused review

### F-35-D-01 — 避免建立第二份CI stable authority

Severity：P1。

初始設計問題：Requirement Decision要求ADR，但若新增獨立「validation ADR」，會與已擁有change classification／quality gate scope的ADR-023形成平行authority。

Disposition：Resolved in Design。採**修訂ADR-023**，不新增平行ADR。

### F-35-D-02 — Execution tier與validation level不可混為同一概念

Severity：P1。

若直接用Tier 1～5當每次change的selection level，會重現current inventory drift：test artifact屬性與change risk被混在一起。

Disposition：Resolved in Design。Inventory tier描述test／artifact execution characteristic；planner level描述本次change需要的validation escalation。

### F-35-D-03 — 「避免重跑」不能變成跨gate永久cache

Severity：P1。

Evidence reuse若沒有freshness boundary，可能弱化holistic／release confidence。

Disposition：Resolved in Design。Reuse只限同一formal Task、同plan identity且selected inputs無mutation；Milestone holistic、release與post-release一律fresh full regression。

### F-35-D-04 — Package routing不能以手寫全域清單取代真實dependency graph

Severity：P2。

Disposition：Resolved in Design。Package affected scope由workspace pubspec reverse dependency graph推導；解析失敗fail-safe full。

## Focused re-review

Fresh re-review確認：

- validation selection authority只有一個machine planner；
- classifier與planner責任切開；
- workflow只消費plan；
- unknown／invalid／engine failure維持full fail-safe；
- ordinary Dart change不再自動等於雙平台build；
- no duplicate full suite rule有嚴格reuse boundary；
- Release／post-release仍保留fresh full；
- 沒有以test deletion或coverage reduction作解法。

Open P0：0。

Open P1 without disposition：0。

## Whole-Design review

本Design覆蓋Requirement Decision要求的十二個核心問題：

1. selection authority：ADR-023＋single machine planner。
2. focused／affected／workspace／full／release語意：已定義。
3. classifier granularity：canonical change classes。
4. package／feature／test-only／tooling／docs／generated／database／native routing：已定義。
5. inventory tier alignment：tier與validation level分離並對齊治理。
6. AGENTS／Guides／CI一致性：single planner reference model。
7. evidence reuse／fresh rerun：明確identity與invalidation規則。
8. duplicate full suite：同Task未變更inputs不得因review階段重跑。
9. unknown／ambiguous：full fail-safe。
10. holistic／release／post-release：fresh full regression保留。
11. before／after：wall-clock、command count、Flutter process count與scope corpus。
12. no coverage hole：change-class owner、reverse dependency、positive／negative routing、fresh full regression與release evidence。

Design沒有引入動態coverage graph、第三方impact service、nightly-only或sharding等超出目前成本所需的複雜度。

## Documentation authority check

- Requirement Decision仍由`35-r_requirement_decision.md`擁有。
- Stable CI／classification decision將由ADR-023在implementation Task修訂；Design本身不提前修改ADR。
- Testing semantics仍由`docs/guides/testing_governance.md`擁有；Design只定義待實作target state。
- Historical Milestone 30 runtime evidence保持不變。
- Current roadmap只標記Design proposed／approval gate，不宣稱implementation已開始。

## Required validation

Design Task只允許documentation-focused validation；不得以本Task為理由執行full Flutter regression。

Required：

```txt
python tools/docs/check_docs.py .
git diff --check
```

Fresh validation：

```txt
python tools/docs/check_docs.py . → PASS
git diff --check → PASS
```

Review期間另發現`docs/roadmap/active.md`同時出現「Design proposed」與「Design未開始」的P2 wording contradiction；已修正為「Design已建立但尚未accepted；Plan／worktree／implementation未開始」，並在修正後重新執行上述validation。

## Review disposition

```txt
Classification: Level 4 / Full two-layer Task governance
Design status: PROPOSED
Focused review: PASS after findings disposition
Whole-Design review: PASS
Documentation authority: PASS
Open P0: 0
Open P1 without disposition: 0
Implementation allowed: NO
Next gate: USER DESIGN APPROVAL
```

