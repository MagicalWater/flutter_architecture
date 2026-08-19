---
name: governing-template-development
description: 當此 Flutter 模板 repository 中的工作需要評估、規劃、實作、審查、遷移、發布或治理時使用。
---

# 治理模板開發

本 Skill 是 repository 開發工作的中央 router，不是治理手冊。Repository policy、machine authority、canonical ADR、accepted artifacts、source/tests/runtime truth 高於本 Skill。

## 1. Admission

先讀 root `repository_identity.json`；missing、malformed 或 unknown lifecycle state 一律 fail closed，不從資料夾名、README prose、remote URL 或 bundle identifier 猜測。

## 2. Classification

只在需要判定工作等級時讀 `references/work-classification.md`，採 **lowest sufficient level by evidence**。

產生 Requirement Decision，至少記錄：Request、Problem、Expected behavior、Value、Classification、Decision、Scope、Non-goals，以及是否需要 Design／Plan／ADR／release。

Level 0／1 不得虛構 formal artifacts；模糊本身不是升級理由。

## 3. Conditional routing

- 需要 Design／Plan／approval／release artifact 判定 → `references/artifact-routing.md`。
- 需要 Task review / closure semantics → `references/two-layer-task-governance.md`。
- observable behavior、test authoring、retention 或 test deletion in scope → `references/test-authoring.md`。
- 新增／修改／升級 Skill → `references/skill-adoption-governance.md`；只有 behavioral/adoption validation 時再讀 `references/pressure-scenarios.md`。
- production code implementation／refactor／review → 完成分類與必要核准後按需載入 `karpathy-guidelines`。

不要為 ordinary task 預先讀完所有 references。

## 4. Domain routes

- 首次 Template → Product repository bootstrap → `adopting-template-repository`。
- Cross-platform native product identity adoption → `adopting-template-product-identity`。
- Accepted repository-local `.pen` → Flutter，且 Design／Plan／managed worktree／visual authority gates 全部通過 → `implementing-pencil-flutter-design`。

Domain Skill 只擁有其 domain orchestration，不得重新分類 Requirement、接受 Design／Plan 或宣稱 release／closure。

## 5. Validation

Validation Execution Decision 的 machine authority 是 `tools/ci/validation_planner.py`。不得因 Milestone、holistic、manual 或「保守」名稱自行擴張成 full regression。

Test Authoring、Test Retention 與 Validation Execution 是三個不同決策；`0 permanent tests` 可以合法。

## 6. Approval / stop conditions

- Design / Plan 只有完成 routed review 並取得使用者明確核准後才可 `accepted`。
- Plan 未 accepted 前不得 implementation。
- 必要 validation 失敗時保持 open / blocked，fresh re-verify 後才能 completion。
- Release identity 不等於 Milestone closure；若 scope 需要 release，仍須完成 push 與 relevant post-release identity/artifact evidence。

一般 finding、test failure、implementation defect 或 stale documentation 直接修正並繼續。只有使用者擁有的 scope/architecture decision、external/manual blocker、推翻 accepted artifact 的 P0/P1，或完整 Milestone closure 才停止。
