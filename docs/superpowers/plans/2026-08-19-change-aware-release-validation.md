---
document_type: implementation-plan
status: accepted
authoritative_for:
  - change-aware-release-validation-implementation-plan
last_reviewed_baseline: 1.25.0
---

# Change-aware Release Validation Implementation Plan

## Goal

把 explicit `release` 從固定 full＋generated＋Android＋iOS matrix 改成「candidate changed range + release freshness」；保留 exact candidate、fail-safe、native／generated／dependency safety 與 same-SHA post-release identity semantics。

本 Plan 採最低充分 Level 4：一份 accepted Design、一份 Plan、四個 implementation units、one holistic review。

## Global constraints

- `tools/ci/validation_planner.py` 仍是 validation selection 唯一 machine authority。
- `tools/ci/change_classifier.py` 只擁有 changed-path class／platform-impact classification；workflow 不得複製 path matrix。
- Release selected evidence 必須 fresh；scope change-aware 不等於 reuse ordinary GREEN。
- Missing／invalid release range fail closed；不得 empty-path 假裝 docs-only。
- Planner execution failure先用 canonical classifier保留可判定的platform impact；classifier也失敗時才因 impact不可判定升級兩平台。
- 不修改 production signing、Store、deployment、Test Authoring policy或Branch Protection check names。
- 不新增永久 test file；behavior contract併入既有 `tools/ci/test_validation_planner.py` 與既有 workflow contract owner。

## Task 1 — Planner release-range semantics and critical contract

修改 `tools/ci/validation_planner.py`、`tools/ci/test_validation_planner.py`。

Required behavior：release dispatch使用base/head；release intent只疊加freshness metadata；invalid/missing range fail-safe full + generated + both platforms；valid range沿 canonical routing；root dependency/toolchain與planner/classifier本體在release candidate要求 full/generated/both platforms；單平台workflow routing只選自身平台；`gate="release"` evidence reuse維持 false。

Validation：`python -m unittest tools.ci.test_validation_planner -v`。

## Task 2 — Workflow release base and fail-safe routing

修改 `.github/workflows/ci.yml`、`android.yml`、`ios.yml` 與既有 workflow contract owner。

三份 dispatch 增加 optional `release_base`；release mode傳 `BASE_SHA=inputs.release_base`、`HEAD_SHA=github.sha`；三份workflow不得自行把release翻成platform=true；planner process failure先委派 canonical classifier，classifier/range也不可用時才兩平台 fail-safe。

## Task 3 — Stable authority synchronization

同步 ADR-023、`ci_cd_operations.md`、`testing_governance.md`、two-layer governance reference；移除 current authority 中 `explicit release → logical full + Android + iOS` 舊claim，historical artifacts不回寫。

## Task 4 — Holistic implementation review and release disposition

一次性審查 planner authority、range reproducibility、docs/governance cost、native/generated/dependency/validation-engine false-negative、workflow fallback、freshness、same-SHA、current docs一致性與P0/P1 disposition。

本 corrective 自身修改 validation engine + cross-platform workflow routing，因此 final candidate 必須依修正後 planner fresh規劃，預期至少 logical full + generated + Android + iOS primary evidence。平台 evidence來自 changed risk，不是 release 字樣。

## Test Authoring / Retention Decision

Authoring：Required，但只修改既有 critical owners。Implementation完成後逐個新增case做 Retain／Merge；重複 path permutation刪除。

## Rollback

若 remote/manual evidence發現false-negative：停止publication；以 explicit full + required platform modes補 evidence；revert planner/workflow corrective即可恢復1.25.0 behavior。
