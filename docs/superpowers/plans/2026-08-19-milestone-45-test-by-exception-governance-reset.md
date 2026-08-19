---
document_type: implementation-plan
status: accepted
authoritative_for:
  - milestone-45-test-by-exception-governance-reset-plan
last_reviewed_baseline: 1.23.1
---

# Milestone 45 — Test-by-Exception Portfolio Reset & Development Governance Simplification Implementation Plan

## Execution principle

本Plan刻意維持少量execution units。每個unit完成code/diff review與必要validation，但不為每個刪除bucket建立獨立formal audit file；findings集中於最終holistic review，critical blocker才單獨記錄。

## Unit 45-1 — Governance authority reset

修改：

- `AGENTS.md`
- `.agents/skills/governing-template-development/SKILL.md`
- `.agents/skills/governing-template-development/references/test-authoring.md`
- `.agents/skills/governing-template-development/references/work-classification.md`
- `.agents/skills/governing-template-development/references/artifact-routing.md`
- `.agents/skills/governing-template-development/references/two-layer-task-governance.md`
- `docs/guides/testing_governance.md`
- `docs/governance/development_workflow.md`
- ADR-029與ADR index

完成：test-by-exception、temporary retention decision、replacement=NONE、foundation exemption removal、lowest-sufficient classification與simplified Task governance。

## Unit 45-2 — Validation / release / CI simplification

修改：

- `tools/ci/change_classifier.py`
- `tools/ci/validation_planner.py`
- `tools/ci/validation_runner.py`（若仍需要）
- `.github/workflows/ci.yml`
- `.github/workflows/android.yml`
- `.github/workflows/ios.yml`
- `.github/workflows/observability-acceptance.yml`
- ADR-023
- `docs/guides/ci_cd_operations.md`

完成：VERSION不具release魔法、manual intent顯式化、same-SHA evidence reuse、ordinary change不自動full/platform、observability與native workflow降頻。

## Unit 45-3 — Zero-regret test purge

刪除或收斂：

- widget/page/dialog rendering matrices；
- ordinary theme/localization/copy/style/semantics；
- architecture/static-source contracts；
- docs/Skill wording contracts；
- ordinary golden/visual duplication；
- DI/forwarding/framework behavior；
- Pencil duplicate governance/visual test layers。

目標：先移除至少50% current test LOC，不建立replacement tests。

## Unit 45-4 — Critical owner collapse

逐domain保留最小critical suite：

- Auth security/credential/concurrency/OTP。
- Catalog concurrency/ordering/cache critical invariants。
- CI destructive/fail-safe/security。
- Database migration/rollback/destructive persistence。
- Platform critical build/security contract。
- minimal runtime integration smoke。

合併或刪除exhaustive field matrices與跨layer duplicate invariants。

目標：累積>=80% test files與LOC reduction；若risk matrix支持，繼續至>=90%。

## Unit 45-5 — Tooling / inventory cleanup

依縮小後portfolio決定：

- 簡化或退休`tools/testing/inventory.py`與其self-tests；
- 刪除只為large-portfolio governance存在的metadata與contracts；
- 移除不再被workflow/guide消費的validation helpers。

## Unit 45-6 — Holistic verification and release disposition

Fresh measure：

- files / LOC / static cases before-after；
- retained critical-risk matrix；
- focused ordinary-change wall-clock；
- full logical regression wall-clock；
- CI workflow trigger/execution surface；
- test/tooling/workflow unique LOC。

Validation：

- analyze；
- retained permanent critical tests；
- docs checker；
- validation planner focused contracts；
- one fresh holistic logical regression；
- platform only if final changed boundaries require it。

建立單一holistic final review並判定VERSION／CHANGELOG／publication。Post-release same SHA只做identity/artifact/workflow verification。

## Stop conditions

只有下列情況停止要求使用者決策：

1. critical invariant是否允許完全無automation owner存在實質爭議；
2. 必須改變production behavior才能完成test removal；
3. Design／Plan核心策略被P0/P1 finding推翻；
4. Design或Plan的正式approval gate。

