---
document_type: phase-review
status: accepted
authoritative_for:
  - milestone-31-governance-recovery-entry
last_reviewed_baseline: 1.13.0
---

# Milestone 31 — Governance Recovery Entry

## Trigger

原Milestone 31雖已產生Design、Plan、實作、review摘要、1.13.0 release與push，但無法證明每個正式工作單位都完成雙層Task治理；final review後仍有實作修正，且缺少clean-checkout與remote／post-release evidence。

## Recovery decision

- 保留1.13.0已發布事實，不重寫Git歷史。
- 撤回Milestone 31 Completed／Archived與active `None`宣告。
- Design Spec與Implementation Plan降回`proposed`。
- 先重做Design Spec focused review、findings、fix、re-review與whole-Spec review。
- Design由使用者重新拍板後，才可進Plan recovery。
- 後續逐Task採retroactive implementation audit；不得把recovery evidence偽裝成原始執行已合規。

## Focused review findings

- P0：Current authority把Milestone 31標成Completed，與實際治理證據衝突。
- P0：Spec與Plan標成accepted，但缺少使用者approval gate與完整review chain。
- P1：1.13.0 release事實與Milestone治理closure被混為同一狀態。

## Fixes

- `docs/roadmap/active.md`恢復Milestone 31 Recovery為active。
- `docs/project_context.md`與Milestone index改為recovery狀態。
- Spec／Plan metadata降回`proposed`。
- `CHANGELOG.md`在Unreleased記錄治理恢復，不撤銷1.13.0歷史release。

## Re-review

狀態模型已分離：`1.13.0 published`不再推導`Milestone 31 governance closed`。Current authority、artifact lifecycle與routing一致。

## Validation

- `python3 -m unittest tools.docs.test_check_docs`
- `dart run melos run docs_check`
- `git diff --check`

## Disposition

Open P0 = 0。Open P1 without disposition = 0。Recovery Task 31-R0完成後只允許進入Design Spec recovery，不允許進Plan或implementation recovery。
