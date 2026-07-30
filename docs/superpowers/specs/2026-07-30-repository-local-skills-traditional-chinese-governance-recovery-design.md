---
document_type: design-spec
status: accepted
authoritative_for:
  - repository-local-skills-traditional-chinese-governance-recovery-design
last_reviewed_baseline: 1.13.0
---

# Repository-local Skills 繁體中文化治理恢復設計

## 背景

Commit `c8a77a5` 將四個 repository-local Skills 的 12 份 `SKILL.md`／reference 文件改為繁體中文，並新增語言規則與一份總結 review。該變更已完成 focused validation、clean-checkout discovery 與 push，但原 Requirement Decision 將工作分類為 Level 1。

後續審查確認，此分類不正確。此次變更同時修改：

- 中央 `governing-template-development` Skill；
- Level 0～5 工作分類與 artifact routing 說明；
- Design／Plan acceptance gate 與雙層 Task 流程文字；
- 四個 adopted Skills 的 frontmatter `description` trigger wording；
- Skill adoption governance 與人類治理總覽。

依 current work-classification authority，這屬於 repository-wide governance 與多個 shared contracts，應以 Level 3 full two-layer Task governance 審查，而不是 simplified Level 1。

## Requirement Decision

- Request（需求）：補做完整雙層 Task 治理審查，完成後再對全部繁體中文化變更做 holistic final review。
- Problem（問題）：既有 implementation 已先合併與推送，但 review 等級不足，無法證明翻譯沒有改變 trigger、gate、安全邊界或 authority。
- Current behavior（目前行為）：四個 Skills 可 discovery，docs／environment regression 通過；但只有單一 Level 1 review，且沒有逐 Skill full Task evidence。
- Expected behavior（預期行為）：逐 Skill、逐 authority boundary 執行 focused review、finding 修正、fresh re-review、whole-Task review、authority check、validation 與 independent commit，最後再做跨 Task holistic final review與 remote clean-checkout validation。
- Value（價值）：讓中文化結果具備與 repository governance 風險相稱的證據，避免翻譯造成靜默 workflow drift。
- Classification（分類）：Level 3 — Cross-cutting repository governance recovery。
- Decision（決策）：Accept。
- Scope（範圍）：四個 repository-local Skills、所有 references、語言規則、Skill registry、docs checker、既有中文化 review 與新 recovery evidence。
- Non-goals（非目標）：不改 Skill 名稱、核心責任、status、permissions、source pin、runtime product behavior、VERSION、CHANGELOG、roadmap或 Milestone state。
- Behavioral requirements required（是否需要行為需求）：Yes，以既有 approved Skill contracts 與 pressure scenarios 為 expected behavior。
- Design Spec required（是否需要 Design Spec）：Yes，本文件。
- Implementation Plan required（是否需要 Implementation Plan）：Yes，Design Task 通過後建立 review execution plan。
- ADR required（是否需要 ADR）：No；不改 stable architecture ownership。
- Task governance mode（Task 治理模式）：Full two-layer Task governance。
- Worktree／branch：獨立 worktree 與 `docs/repository-local-skills-zh-tw-governance-recovery` branch。
- Regression level（Regression 等級）：affected workspace regression；最終 holistic gate 包含完整 docs checker、environment contracts、workspace analyze／tests、Skill discovery 與 remote clean checkout。
- Release required（是否需要發布）：No；不提升 Template Baseline。
- Post-release validation（發布後驗證）：Push 後以 `origin/main` 建立 clean checkout，驗證四個 Skills discovery、中文 description、docs checker 與核心 contracts。
- Required Superpowers skills（必要 Superpowers Skills）：`writing-skills`、`writing-plans`、`systematic-debugging`（若 finding／test failure）、`test-driven-development`（若 checker需修正）、`verification-before-completion`。
- Required artifacts（必要 artifacts）：Design review、Plan review、逐 Task review、holistic final review、clean-checkout evidence。

## 設計原則

### 1. 翻譯不得改變行為

繁體中文化只能改變自然語言表達。下列 machine-facing 或 workflow-facing contract 必須保持：

- Skill `name`、路徑與 external source identity；
- frontmatter description 的正負 trigger 範圍；
- Requirement Decision 欄位與 decision states；
- Level 0～5 的風險門檻；
- Design／Plan `proposed → accepted` gate；
- Task stop／continue、commit、release 與 closure gate；
- `governing-template-development` 的中央 authority；
- `starting-feature-work` 與 `adopting-template-product-identity` 的薄型委派責任；
- `karpathy-guidelines` 的 subordinate、restricted companion 邊界；
- secret、signing、Store、migration、rollback、accessibility 與 validation safety wording。

### 2. 歷史證據不回寫

既有 `repository_local_skills_traditional_chinese_review.md` 保存當時實際發生的 Level 1 review，但必須明確標記其 classification 已被本 recovery supersede。不得把後續 recovery evidence 冒充成 commit `c8a77a5` 前就已存在。

### 3. Current authority 必須一致

若 review 發現 changed files 中存在過期 status、trigger、evidence 或 registry routing，即使不是翻譯直接造成，也必須在本 recovery 中修正並 fresh re-verify。

### 4. 可機械執行的規則應由 checker 承擔

如果 current docs checker 只忽略 Skill frontmatter metadata、卻不驗證 repository-local Skill 的中文 contract，則應以 TDD 加入最小 checker rule：

- `SKILL.md` description 必須包含 CJK；
- repository-local Skill Markdown 正文必須包含 CJK；
- Skill `name` 與 frontmatter structure 仍可被 discovery 解析；
- 技術識別、code fence 與外部名稱不要求翻譯。

Checker 不判斷翻譯品質，也不禁止必要英文技術名詞。

## Review Task 邊界

### Task 1 — Central Governance Skill

審查中央 Skill 與五份 references：classification、artifact routing、two-layer Task governance、Skill adoption 與 pressure protocol。

### Task 2 — Product Identity Skill

審查 trigger／non-trigger、input gate、manifest-first、secret／signing hard stop、evidence states 與 pressure scenarios。

### Task 3 — Starting Feature Work Skill

審查短 brief contract、中央委派、discussion-only 與 implementation pressure。

### Task 4 — Karpathy Guidelines Skill

審查 source pin、subordinate routing、anti-overengineering heuristics、non-trigger 與 restricted status。

### Task 5 — Language Governance and Mechanical Enforcement

審查人類治理總覽、Skill registry、既有 review、audit navigation 與 docs checker；以 TDD 修正 mechanically enforceable gap。

### Task 6 — Holistic Final Review

跨 Task 檢查所有 15 個原始變更檔與 recovery 修正，執行 full regression、push、remote clean-checkout discovery 與 formal closure。

## Acceptance criteria

1. 原 Level 1 classification 被正式 supersede，current recovery 為 Level 3。
2. 每個 Task 都有 focused finding、fix、fresh re-review、whole-Task coverage、authority check、exact validation 與 independent commit。
3. 四個 Skill 名稱、trigger 範圍、responsibility、forbidden responsibility 與 status 不因翻譯而靜默改變。
4. 所有 current status／evidence wording 與 registry 一致。
5. Repository-local Skill 中文規則具備最小 mechanical enforcement 與 tests。
6. Open P0 = 0；Open P1 without disposition = 0；Open P2 without disposition = 0。
7. 最終 `main`、`origin/main` 與 remote clean checkout 一致且乾淨。

## 使用者核准

使用者於 2026-07-30 明確要求：「先做完整的審查，就有雙層 Task 治理流程；等完畢後，再對所有變動內容做總審查。」此指示核准本 recovery 的 scope、Full Task mode 與「逐 Task review → holistic final review」順序。
