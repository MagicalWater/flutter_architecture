---
document_type: phase-review
status: active
authoritative_for:
  - milestone-38-task-38-4-human-product-infrastructure-adoption-procedure
last_reviewed_baseline: 1.18.0
---

# Task 38-4 — Human Product Infrastructure Adoption Procedure Review

## Scope

補齊new product repository從`Use this template`後的human-operable infrastructure adoption procedure，明確區分tracked bytes與GitHub live state，並提供`manual-local`、`self-hosted`、`github-hosted`三種CI profile的decision／acceptance checklist。

## Test Authoring Disposition

**Should-not-add**：本Task只改Guide/navigation wording，沒有新增machine failure mode；不新增prose snapshot tests。Existing `docs_check`、bootstrap routing tests與`repository_infrastructure.json` verifier仍是machine owners。

## Review

- `Use this template`只複製tracked bytes；GitHub variable、policy、Branch Protection、runner、Environment與secret presence都必須另外admit/configure/read-back。
- Selected CI profile為blocking bootstrap input；optional provider capability可以`deferred`，CI profile本身不能defer。
- Branch Protection disposition固定為`minimum-safety | team-protected-main | explicit-deferred`。
- Environment／secret-backed optional capability disposition固定為`configured | deferred | not-applicable`。
- Secret value、runner registration token、signing material與provider credential禁止複製或寫入tracked evidence。
- Live mutation必須before-state → mutation → fresh read-back → expected comparison；permission failure／403／mismatch不得宣稱configured。
- Required checks不得只從workflow bytes推測，必須先有new product repository/ref的fresh workflow evidence。
- README與docs routing只做navigation sync，不建立第二套procedure authority。
- Open P0：0。
- Undisposed P1：0。

## Validation

- `dart run melos run docs_check`：PASS。
- Link／authority review：README、docs index、quick start與兩份Guide routing一致；ADR-030仍擁有lifecycle，ADR-031擁有infrastructure adoption boundary。
- Stale contradiction search：發現並修正`manual-local` external-blocker wording；required live read-back被阻塞時必須保持`repository_kind=template`，不得冒充selected-profile acceptance。
- `git diff --check`：PASS。
- Task candidate的Minimum Sufficient Validation plan需在completion commit前fresh確認。
