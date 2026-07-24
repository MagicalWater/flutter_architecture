---
document_type: phase-review
status: active
authoritative_for:
  - karpathy-guidelines-primary-workflow-recovery
last_reviewed_baseline: 1.13.0
---

# Karpathy Guidelines Primary Workflow Recovery Review

## Requirement Decision

- Request：修正先前以Ponytail污染的Codex RED結果拒絕Karpathy Skill之治理錯誤。
- Problem：正式工作流是ChatGPT網頁＋`bridge-mac`；先前controls卻在Codex CLI執行並自動載入Ponytail Plugin／hooks。
- Current behavior：repository未安裝Karpathy；current final review錯誤宣告主要工作流已有等價能力。
- Expected behavior：只以主要支援runtime可發現、可攜且repository-local的能力判定adoption。
- Value：避免樣板在ChatGPT、其他電腦或未安裝Ponytail的agent環境失去anti-overengineering guidance。
- Classification：Level 4 — repository-wide workflow governance recovery。
- Decision：Accept。
- Scope：撤銷舊Rejected authority、恢復accepted Plan Task 3～7、加入受限制Karpathy companion、驗證discovery／authority／non-trigger／rollback。
- Non-goals：移植Ponytail hooks、修改產品程式碼、升版、把上游`CLAUDE.md`併入`AGENTS.md`。
- Behavioral requirements required：Yes。
- Design Spec required：沿用accepted Design。
- Implementation Plan required：沿用accepted Plan並記錄recovery disposition。
- ADR required：No；不改變architecture boundary。
- Task governance mode：Full recovery。
- Worktree／branch：isolated managed worktree，`fix/karpathy-primary-workflow-revalidation`。
- Regression level：documentation／Skill discovery／routing focused validation。
- Release required：No。
- Post-release validation：merge後clean discovery validation。
- Required Superpowers skills：writing-skills、requesting／receiving-code-review、verification-before-completion、finishing-a-development-branch。
- Required artifacts：本recovery review、restricted Skill、pressure reference、routing sync、pressure validation、replacement final review。

## Finding

### F-KG-R01 — RED target runtime錯誤

Severity：P1。

Evidence：

- 原RED audit明載Codex CLI runtime。
- Probe輸出明確讀取`~/.codex/plugins/.../ponytail/.../SKILL.md`。
- `bridge-mac.open_workspace`在正式ChatGPT工作流回傳的可用Skills不包含Ponytail。
- Ponytail hooks只由Codex Plugin runtime執行，ChatGPT網頁不會繼承。

Disposition：Resolved by invalidation。舊final review改為`superseded`；舊RED保留為「Codex＋Ponytail環境」歷史證據，不再支配主要工作流adoption。

## Validation boundary

目前工具無法建立全新、無本對話記憶的ChatGPT＋`bridge-mac`子對話，因此不得偽稱已完成fresh ChatGPT RED／GREEN behavior probes。Recovery採以下可重現證據：

1. `bridge-mac.open_workspace` discovery清單證明primary runtime沒有Ponytail。
2. 新Skill加入後重新開啟clean worktree，證明Skill可被primary runtime發現。
3. Static authority review證明Skill不複製Level／approval／Task／release rules。
4. Explicit routing與non-trigger contract由repository docs checker、diff review及pressure reference驗證。
5. 未來若平台提供fresh ChatGPT subagent，必須補做behavioral discovery GREEN；在此之前Status最多為Pilot／Approved with restrictions。

## Gate

- Open P0：0。
- Open P1 without disposition：0。
- 下一步：Task 3建立受限制repository-local Skill。
