---
document_type: planning-review
status: completed
authoritative_for:
  - milestone-37-design-spec-review
last_reviewed_baseline: 1.17.0
---

# Milestone 37 — Design Spec Review

## Review Target

`docs/superpowers/specs/2026-08-14-milestone-37-template-to-product-repository-bootstrap-design.md`

Requirement authority：`docs/audits/milestone_37/37-r_requirement_decision.md`。

本 Review 只審查 Template → Product repository bootstrap Design；不開始 Plan 或 implementation。

## Focused Review

### M37-D01 — Scope alignment

- Severity：P1。
- Result：PASS。
- Evidence：產品需求、MVP、Feature、UI／UX、Backend、產品 roadmap、Store／signing與upstream auto-sync均明確排除；product roadmap只重設為空狀態，不替產品做規劃。

### M37-D02 — Repository lifecycle authority

- Severity：P0 architecture。
- Result：PASS。
- Evidence：blocking lifecycle不從README／project_context prose、folder name、remote URL或bundle identifier猜測；Design使用極小machine-readable manifest擁有`template | product` state。

### M37-D03 — Native identity parallel authority

- Severity：P0 architecture。
- Result：PASS。
- Evidence：repository identity manifest禁止保存bundle identifier、API domain與environment mapping；native identity仍由既有`adopting-template-product-identity`、ADR-014／025與`environments.json`擁有。

### M37-D04 — Version authority

- Severity：P1。
- Result：PASS。
- Evidence：Product current version只由root `VERSION`擁有；template provenance baseline只保存在`template_origin.baseline`，沒有第二份product-version authority。

### M37-D05 — Partial bootstrap lifecycle corruption

- Severity：P1。
- Finding：原Design若在native identity／docs validation完成前就寫入`repository_kind = product`，中途失敗後fresh Agent可能誤認bootstrap已完成。
- Fix：Design已加入Atomic Completion Boundary；lifecycle transition必須是closure最後一步。Required validation失敗時persistent state保持`template`，且不新增`bootstrapping`第三狀態。
- Fresh re-review：PASS。

### M37-D06 — Repeated bootstrap

- Severity：P1。
- Result：PASS。
- Evidence：`product` repository再次要求首次adoption時必須阻止並重新分類為bounded identity change，不得reset VERSION／roadmap／CHANGELOG。

### M37-D07 — Invalid authority fail-closed

- Severity：P0 governance。
- Result：PASS。
- Evidence：manifest missing／invalid時先修復repository identity authority，不從remote或human prose猜測。

### M37-D08 — Existing Skill trigger preservation

- Severity：P1。
- Result：PASS。
- Evidence：新增薄型`adopting-template-repository` orchestration Skill；不把repository lifecycle責任塞進既有Approved `adopting-template-product-identity`。

### M37-D09 — Current product authority reset

- Severity：P1。
- Result：PASS。
- Evidence：README／project_context／roadmap／CHANGELOG只做repository identity transition；template milestone history不成為product roadmap，且不自動產生產品Milestone。

### M37-D10 — Fresh-conversation acceptance

- Severity：P0 usability。
- Result：PASS。
- Evidence：bootstrap完成後，fresh Agent session只提供repository path即可從current authority辨識product name、template origin、current product version與禁止重複bootstrap。

## ADR Gate

PASS。Repository lifecycle、identity manifest、template provenance、VERSION semantics與first-admission fail-closed屬stable repository-wide boundary，Design正確要求新增ADR-030，而不是把決策只留在Guide或Skill。

## Validation

- `dart run melos run docs_check`：PASS。
- `git diff --check`：PASS。

## Whole-Task Review

- Requirement alignment：PASS。
- Authority duplication：PASS。
- Scope containment：PASS。
- Failure-mode coverage：PASS after M37-D05 fix。
- Open P0：0。
- Open P1 without disposition：0。

## Final Disposition

**Design review PASS。**

Design artifact目前仍為`proposed`；必須取得使用者明確核准後才能轉為`accepted`並開始Implementation Plan。
