---
document_type: design-spec
status: accepted
authoritative_for:
  - karpathy-guidelines-skill-adoption-design
last_reviewed_baseline: 1.13.0
---

# Karpathy Guidelines Skill Adoption Design

## Requirement Decision

- Request：評估並規劃將 `multica-ai/andrej-karpathy-skills` 的 `karpathy-guidelines` 納入 Flutter 樣板專案。
- Problem：現有治理與 Superpowers 已涵蓋需求釐清、TDD、review 與驗證，但 implementation／code review 階段仍缺少明確的 anti-overengineering 與 surgical-change companion guidance。
- Current behavior：agent 會依治理與 Plan 執行，但仍可能建立未要求的抽象、順手重構鄰近程式碼，或把局部 Task 擴張成 framework work。
- Expected behavior：在不改變既有 authority、approval、Task 與 release 流程的前提下，於 production code implementation、refactor 與 code review 階段自動載入局部性、簡潔性、假設揭露與可驗證目標 guidance。
- Value：降低 AI 過度設計、scope creep、非必要 churn 與難以 review 的 commit。
- Classification：Level 3 — Cross-cutting。
- Classification evidence：Skill 將被 repository-wide routing 自動帶入 implementation／code review，影響多 feature／package 的工作方式；但不擁有 repository authority、artifact routing、approval 或 release policy，因此不升級為 Level 4。
- Decision：Accept with restrictions，先以 Pilot 採用。
- Scope：固定上游來源與 commit、加入 repository-local companion Skill、明確 authority precedence、加入 pressure scenarios、更新 Skill registry 與 routing 文件。
- Non-goals：不把上游 `CLAUDE.md` 直接併入 `AGENTS.md`；不讓 Skill 成為使用者入口；不讓它修改 Requirement Decision、Design、Plan、branch、Task acceptance 或 release closure。
- Behavioral requirements required：Yes。
- Design Spec required：Yes。
- Implementation Plan required：Yes。
- ADR required：No；未改變 stable architecture ownership。
- Task governance mode：Full。
- Worktree／branch：Required at execution time，因為會修改 repository-wide workflow routing。
- Regression level：Skill RED／GREEN／REFACTOR、docs checker、docs_check、discovery probe、authority conflict pressure scenarios。
- Release required：No immediate version bump；保留於 1.13.0 baseline，待後續正式 release 一併發布。
- Post-release validation：不適用於本次採用；需完成 clean checkout discovery／behavior validation 後才能將 Pilot 升為 Approved。
- Required Superpowers skills：writing-skills、test-driven-development、using-git-worktrees、verification-before-completion、requesting-code-review。

## Source and pinning

- Source repository：`https://github.com/multica-ai/andrej-karpathy-skills`
- Source path：`skills/karpathy-guidelines/SKILL.md`
- Pinned commit：`2c606141936f1eeef17fa3043a72095b4765b9c2`
- Adoption method：repository-local adapted copy with provenance header and explicit restrictions。
- Upgrade method：重新執行 adoption review、diff upstream、RED／GREEN pressure scenarios 與 docs validation；不得自動追蹤 `main`。
- Rollback：移除 Skill、routing wiring 與 registry row；中央治理與 Superpowers 流程維持不變。

## Responsibility boundary

```txt
starting-feature-work（feature shortcut）
→ governing-template-development（唯一治理引擎）
→ approved Design／Plan and routed Superpowers
→ karpathy-guidelines（implementation／code review companion）
→ repository Task review／validation／commit gates
```

`karpathy-guidelines` 可以：

- 要求在 coding 前揭露局部假設與完成條件。
- 避免未要求的 framework、configuration、abstraction 與 generalized solution。
- 限制修改範圍至 Task 需求與本次修改直接造成的必要 cleanup。
- 在 code review 中指出可刪除的非必要複雜度與 scope creep。

`karpathy-guidelines` 不可以：

- 取代或重新分類 Requirement Decision。
- 自行削減已核准 Design／Plan 的必要 scope。
- 以 simplicity 為由略過安全、資料遷移、無障礙、error handling、rollback 或 Level 5 evidence。
- 改變停止條件、approval gate、branch／worktree、Task acceptance、release 或 closure policy。
- 對純需求討論、文件索引、roadmap 或 release metadata 工作強制載入。

## Authority precedence

```txt
User instruction
→ AGENTS.md／current repository authority
→ governing-template-development Requirement Decision
→ accepted Design Spec／Implementation Plan／ADR
→ routed Superpowers workflow
→ karpathy-guidelines implementation heuristics
```

若 `karpathy-guidelines` 與較高 authority 衝突，必須服從較高 authority，並將疑慮記錄成 finding，而不是自行縮減工作。

## Acceptance criteria

1. 使用者只需照既有入口下指令，不需要手動指定 `karpathy-guidelines`。
2. Implementation／refactor／code review routes 會自動選用 Skill；需求討論、Design approval、Plan approval 與 release closure 不會誤觸發。
3. Agent 面對「順手重構」「建立通用 framework」「跳過必要 migration safety」壓力時做出正確判斷。
4. Skill 不複製中央 Level、approval、Task 或 release 規則。
5. 上游來源、path、pinned commit、限制、rollback 與驗證證據可追溯。

## Approval

前置採用審查與 Design recovery Task gate 已完成。使用者於 2026-07-25 明確核准本 Design Spec，因此本文件轉為 `accepted`，可進入 Implementation Plan Task；Plan 仍須獨立完成完整治理與使用者明確核准後才能實作。
