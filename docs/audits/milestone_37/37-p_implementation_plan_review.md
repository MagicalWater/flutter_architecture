---
document_type: planning-review
status: completed
authoritative_for:
  - milestone-37-implementation-plan-review
last_reviewed_baseline: 1.17.0
---

# Milestone 37 — Implementation Plan Review

## Review Target

`docs/superpowers/plans/2026-08-14-milestone-37-template-to-product-repository-bootstrap.md`

Authorities：

- Requirement Decision：`docs/audits/milestone_37/37-r_requirement_decision.md`
- Accepted Design：`docs/superpowers/specs/2026-08-14-milestone-37-template-to-product-repository-bootstrap-design.md`
- Design Review：`docs/audits/milestone_37/37-0_design_spec_review.md`

本 Review 只審查 Implementation Plan；不開始 implementation、不建立 implementation worktree。

## Focused Review Findings

### M37-P01 — Atomic transition verification ordering ambiguity

- Severity：P1。
- Finding：原 Plan 直接要求先完成 product `VERSION`／docs/native mutation、全部 blocking validation PASS，再把 canonical manifest切成 `product`。但 canonical manifest仍為`template`時，template invariant要求`template_origin.baseline == VERSION`且current docs仍是Template；產品projection已寫入後，canonical verifier必然暫時失敗。
- Risk：implementation可能為了讓validation通過而提前切`repository_kind = product`，重新引入Design已修正的partial-bootstrap corruption；或把中間不一致誤當成正式第三狀態。
- Fix：Plan加入prospective candidate-state validation。Canonical manifest保持`template`，candidate product manifest只作temporary validation input；native/docs/component validation與candidate product validation通過後，才將同一candidate寫回canonical manifest，並立即重跑canonical verifier。
- Fresh re-review：PASS。沒有新增persistent `bootstrapping`狀態，且intermediate mismatch fresh admission明確fail closed。

### M37-P02 — Acceptance fixture使用template placeholder namespace

- Severity：P1 evidence quality。
- Finding：原fixture使用`com.example.pickupbasketballacceptance`，容易與template placeholder semantics混淆，也可能讓native identity evidence無法證明placeholder已被正式替換。
- Fix：改為`com.magicalwater.pickupbasketballacceptance`代表性non-template identity。
- Fresh re-review：PASS。

### M37-P03 — Current roadmap仍宣稱沒有active milestone

- Severity：P1 current authority。
- Finding：Requirement與Design已accepted且Plan已建立，但`docs/project_context.md`、`docs/roadmap.md`、`docs/roadmap/active.md`仍宣稱`Active Milestone: None`，fresh admission會取得錯誤current state。
- Fix：在planning scope內同步current authority為Milestone 37 active、Design accepted、Plan proposed；未開始implementation也未宣稱Plan accepted。
- Fresh re-review：PASS。

### M37-P04 — Automated bootstrap framework scope creep

- Severity：P1 architecture guardrail。
- Result：PASS。
- Evidence：Plan明確禁止在Task 37-6因方便而自行新增automated bootstrap runtime/script；若實作證明需要新bootstrap engine，必須回Design／Requirement Decision。既有預設仍是Agent Skill orchestration + repository mutation tools。

### M37-P05 — Native product identity authority duplication

- Severity：P0 architecture。
- Result：PASS。
- Evidence：Plan只delegates既有`adopting-template-product-identity`與ADR-014／025／`environments.json`，不把bundle identifier、environment mapping、API domain寫入repository identity manifest。

### M37-P06 — Test authoring over-expansion

- Severity：P1 sustainability。
- Result：PASS。
- Evidence：Required tests只鎖repository parser／verifier、routing、atomic lifecycle fixture；Guide／ADR／README不做逐檔snapshot tests，也不複製existing native environment test matrix。

### M37-P07 — Product planning scope contamination

- Severity：P1 scope。
- Result：PASS。
- Evidence：Plan明確排除產品需求、MVP、Feature、UI／UX、Backend與產品roadmap；product roadmap bootstrap只建立空current authority，不替新產品規劃內容。

### M37-P08 — Published-main / external GitHub setting boundary

- Severity：P1 operations。
- Result：PASS。
- Evidence：GitHub Template Repository setting只在post-release作external setting evidence，不成為repository lifecycle machine authority；manifest與current repository bytes仍是Agent admission authority。

## Task Ordering Review

順序：

```txt
37-1 machine RED
→ 37-2 manifest/verifier GREEN
→ 37-3 central routing/Skill
→ 37-4 ADR/Guide
→ 37-5 template current authority integration
→ 37-6 isolated bootstrap acceptance
→ 37-7 fresh no-handoff behavioral acceptance
→ 37-8 holistic/release disposition
→ 37-9 published-main post-release closure
```

Result：PASS。

此順序確保machine invariant先存在，再讓Agent routing依賴它；behavioral acceptance在static contract與human authority完成後執行；release最後才決定。

## Artifact / Authority Review

- Requirement Decision owns accepted scope：PASS。
- Accepted Design owns lifecycle/schema/version/boundary decisions：PASS。
- ADR-030將擁有發布後stable architecture decision：PASS。
- Plan只擁有task order/file scope/validation：PASS。
- Guide不成為machine authority：PASS。
- `repository_identity.json`與`VERSION`沒有product-version duplication：PASS。
- Native identity仍由existing authority擁有：PASS。

## Validation

- `dart run melos run docs_check`：PASS。
- `git diff --check`：PASS（只有line-ending warning，無whitespace error）。
- Design status：`accepted`。
- Plan status：`proposed`。
- Implementation worktree：尚未建立。
- Production Flutter runtime mutation：0。

## Whole-Task Review

- Requirement alignment：PASS。
- Accepted Design alignment：PASS after M37-P01 fix。
- Task completeness：PASS。
- Failure-mode / rollback coverage：PASS。
- Authority duplication：PASS。
- Test Authoring governance：PASS。
- Scope containment：PASS。
- Fresh behavioral acceptance：explicitly required。
- Open P0：0。
- Open P1 without disposition：0。

## Final Disposition

**Implementation Plan review PASS。**

Plan artifact必須維持`proposed`直到使用者明確核准。核准後才可轉為`accepted`、建立managed implementation worktree並執行Task 37-1。
