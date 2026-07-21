---
document_type: phase-review
status: accepted
authoritative_for:
  - milestone-23-task-23-8-authority-cutover-review
last_reviewed_baseline: 1.5.1
---

# Milestone 23-8 — Authority Cutover and Legacy Compatibility Review

## Scope

本 Task在22個 canonical ADR皆完成 semantic、relation、link與 checker review後，切換正式 Architecture Decision authority，並保留舊 aggregate、placeholder與 historical guide路徑的 compatibility。

## Cutover Decision

- `docs/adr/README.md`成為 canonical Decision index與正式 routing authority。
- ADR-001至ADR-022全部維持 `extracted`，target存在且無 orphan。
- `docs/architecture_decisions.md`轉為 `legacy` stable-ID stub，不刪除路徑。
- 舊 `docs/adr/000-*`至`005-*`轉為 managed legacy routes；不建立 ADR-000，也不偷換原 placeholder identity。
- `docs/architecture/*`保留 historical正文，只更新 current authority links。

## Checker Activation

Authority cutover後，checker新增：

- legacy aggregate啟用時強制ADR-001至ADR-022完整 extracted coverage。
- managed legacy ADR paths必須宣告 `status: legacy`並連至 canonical index。
- 既有 ID、filename、index target、orphan、reciprocal edge、self edge與cycle validation持續有效。

## Current Routing Review

AGENTS、Documentation Hub、root README、Project Context、active roadmap，以及 current App／Package／Feature README已改指向 `docs/adr/README.md`。

Historical audits、plans、archives、migration evidence與 published CHANGELOG不全面改寫；舊 aggregate路徑仍可抵達 canonical index。

## Rollback Rehearsal

本 Task可由單一 commit revert：恢復 aggregate正文與舊 routing，同時撤銷 full-coverage activation。Canonical ADR files仍存在，因此 rollback不會丟失已完成 extraction。

## Validation

```txt
python -m unittest tools.docs.test_check_docs
→ 13 tests passed

dart run melos run docs_check
→ Documentation check passed

git diff --check
→ Passed

ADR index coverage
→ 22 extracted / 0 aggregate

Current route inventory
→ current authority routes point to docs/adr/README.md
→ root README retains one explicit legacy compatibility reference

git diff | git apply --check -R -
→ Passed；single-commit rollback patch is mechanically applicable
```

## Review Decision

Authority、compatibility、routing與 checker gate通過。Open P0／P1：0。
