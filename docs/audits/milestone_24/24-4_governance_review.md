---
document_type: phase-review
status: accepted
authoritative_for:
  - milestone-24-branch-protection-ci-operations-review
last_reviewed_baseline: 1.5.1
---

# Milestone 24-4 — Branch Protection and CI Operations Review

## Scope

本review驗證`docs/guides/ci_cd_operations.md`與current navigation是否完整覆蓋required checks、Branch Protection建議、rerun、cache degradation、generated failure、quality／test failure、Android artifact failure、artifact contract、workflow rollback與future production extension。

本Task不修改GitHub repository settings、不建立production signing、不新增deployment workflow，也不宣稱Branch Protection已啟用。

## Authority Review

- ADR-023保存durable architecture contract。
- Operations guide保存可重複執行的操作流程。
- Phase review保存本Task evidence與finding disposition。
- Root README只保存human entry與current capability摘要。
- Documentation Hub只增加guide routing，不複製完整操作內容。

未建立平行Architecture Decision authority。

## Required Check Contract

文件使用與workflow一致的穩定名稱：

```txt
CI / Quality
CI / Generated Consistency
CI / Tests
```

`Android / Release APK`明確不是第一版PR required check，因Android workflow未在`pull_request` event執行。

## Branch Protection Boundary

指南只提供建議設定，且明確要求repository administrator人工套用與驗證。Merge Queue在`merge_group` event尚未加入前不得直接啟用required check contract。

## Failure and Rollback Review

- Transient failure可rerun，但同SHA重複失敗必須當成正式defect調查。
- Cache只影響速度，fresh resolution是fallback authority。
- Generated mismatch由開發者本地重建、review與commit，CI不自動修改repository。
- Test failure不得以無限rerun取代root-cause review。
- Android failure不得以上一個commit的APK冒充新SHA artifact。
- Workflow regression採focused fix或revert；Branch Protection settings需管理者同步處理。

## Artifact and Production Boundary

Guide完整記錄SHA naming、14-day retention、metadata、debug-signing warning與下載後SHA核對。

Future production release被定義為獨立workflow與protected Environment；現有workflow不可直接視為Store publishing foundation。

## Findings

| Finding | Severity | Resolution |
|---|---:|---|
| M24-4-01 Required check名稱若與workflow不一致會破壞Branch Protection | P1 | Guide固定使用三個stable check names |
| M24-4-02 文件可能誤稱GitHub settings已修改 | P1 | 明確標示recommendation only與administrator responsibility |
| M24-4-03 Merge Queue可能因缺少`merge_group`產生required check deadlock | P1 | 啟用前先擴充event並驗證 |
| M24-4-04 無限rerun可能掩蓋flaky或真實defect | P2 | 同SHA重複失敗轉root-cause review |
| M24-4-05 Cache被誤當成correctness prerequisite | P1 | Fresh resolution為fallback authority |
| M24-4-06 舊APK可能被錯誤對應到新SHA | P1 | 禁止artifact substitution並要求metadata核對 |
| M24-4-07 Verification workflow可能被誤用為production release | P1 | 獨立workflow／Environment與explicit non-goals |

Open P0／P1：0。

## Validation

- Documentation link checker。
- Managed metadata與authority review。
- Workflow／guide stable check name comparison。
- Production boundary與Branch Protection claim review。
- `git diff --check`。

## Gate Decision

Task 24-4通過。下一步為Task 24-5 Clean-run and Workflow Validation。

