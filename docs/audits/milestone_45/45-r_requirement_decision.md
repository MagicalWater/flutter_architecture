---
document_type: planning-review
status: accepted
authoritative_for:
  - milestone-45-test-by-exception-governance-reset-requirement
last_reviewed_baseline: 1.23.1
---

# Milestone 45 — Test-by-Exception Portfolio Reset & Development Governance Simplification

## Requirement Decision

- Request（需求）：將repository從「既有tests預設保留」改為「永久tests只作少數關鍵failure protection」，大幅刪除現有test portfolio，目標刪除80%以上，若證據支持可達90%～100%；同時大幅簡化會持續放大tests、validation、CI與Task artifacts的治理規則。
- Problem（問題）：current repository已有179 tracked test files／30,749 test LOC／1,127 static cases，test LOC約為handwritten production Dart的160%。既有Milestone 30 replacement-preservation、Milestone 35 validation infrastructure、Milestone 36 future-authoring policy與Level 3～4 formal Task cycle共同形成coverage conservation、governance inflation與CI duplication，使tests／tooling本身成為主要維護負擔。
- Current behavior（目前行為）：existing tests刪除需要replacement evidence與deletion manifest；foundation允許較高test density；deterministic regression容易成為永久test；TDD只決定是否新增test，沒有closure retention decision；ambiguous classification偏向升級；holistic／release／post-release fresh evidence及VERSION／manual dispatch可重複提升full＋platform validation。
- Expected behavior（預期行為）：permanent test採test-by-exception；temporary validation tests可在Task完成後主動刪除；只有critical、高失敗代價、難以人工快速發現且值得長期維護的invariant保留永久owner。普通UI／copy／style／framework wiring／architecture prose／source-shape／documentation wording／低價值golden不建立永久tests。刪除低價值protection可明確以replacement = NONE完成。治理、validation與CI同步減量。
- Value（價值）：恢復repository可理解性、開發速度與CI信號品質，避免tests與治理成為第二個產品；保留真正critical security／migration／concurrency／ordering／destructive／platform failure protection。
- Classification（分類）：Level 4 — Architecture／Repository Governance。
- Decision（決策）：Accept。
- Scope（範圍）：test retention lifecycle、existing portfolio purge、Testing Governance、central governing Skill、work classification／Task governance、ADR-029與ADR-023相關stable policy、validation planner／runner與GitHub workflows、inventory tooling與current documentation authority。
- Non-goals（非目標）：不以coverage percentage為KPI；不為達成刪除比例而移除已證明必要的critical invariant；不改production business behavior；不建立新的test framework、impact-analysis engine或另一套治理層。
- Behavioral requirements required（是否需要行為需求）：是。
- Design Spec required（是否需要 Design Spec）：是。
- Implementation Plan required（是否需要 Implementation Plan）：是。
- ADR required（是否需要 ADR）：更新ADR-029與ADR-023；只有stable boundary無法由既有ADR承接時才新增ADR。
- Task governance mode（Task 治理模式）：本Milestone先依current Level 4 admission完成Design／Plan gate；Design本身要求把後續治理改成最小充分Task evidence，避免以舊規則產生大量per-subtask audit artifacts。
- Worktree／branch：managed worktree `C:\Users\crazy\.devspace\worktrees\flutter_architecture-d4c3ab18`；branch `milestone-45-test-by-exception-governance-reset`；base `dev@ff45162df04db652c670e4611b3b51acd52c5ad8`。
- Regression level（Regression 等級）：治理切換期間使用risk-selected focused validation；portfolio purge完成前後各保留一次可比對baseline；不因刪除本身反覆執行full。
- Release required（是否需要發布）：最終依stable governance capability變更判定；預期MINOR。
- Post-release validation（發布後驗證）：只驗published SHA／workflow／artifact identity與必要smoke；不得在same SHA重跑完整source regression。
- Required Superpowers skills（必要 Superpowers Skills）：依central governance既有Level 4 route；implementation／refactor review搭配`karpathy-guidelines`。
- Required artifacts（必要 artifacts）：本Requirement、單一Design Spec、單一Implementation Plan、最終holistic review；禁止為每個刪除bucket建立獨立formal audit檔，除非critical finding需要可追溯evidence。

## Success criteria

1. Test files至少刪除80%；若critical-invariant audit支持，目標90%以上，無最低保留test count。
2. Test LOC至少刪除80%；若剩餘owner仍可合併，繼續縮減，不為數字保留低價值tests。
3. Permanent tests只有critical invariant，普通Task可合法以0 permanent tests完成。
4. Temporary RED／regression／acceptance tests在closure執行Retention Decision；沒有長期價值時主動刪除。
5. Foundation不再享有test-density exemption。
6. Retired protection允許`replacement = NONE`，不要求用另一個test換掉被刪test。
7. Ordinary change不自動full regression；VERSION metadata與manual dispatch不自動等價release full matrix。
8. Same SHA不重複holistic／release／post-release full source regression。
9. GitHub CI execution量與workflow duplication明顯下降。
10. Governance artifacts、per-Task formal review與evidence overhead下降，而critical security／migration／concurrency／destructive／platform protection仍有清楚owner。

