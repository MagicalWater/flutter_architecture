---
document_type: planning-review
status: superseded
authoritative_for:
  - karpathy-guidelines-adoption-planning-review
last_reviewed_baseline: 1.13.0
---

# Karpathy Guidelines Adoption Planning Review

## Review scope

- `docs/superpowers/specs/2026-07-25-karpathy-guidelines-adoption-design.md`
- `docs/superpowers/plans/2026-07-25-karpathy-guidelines-adoption.md`
- `.agents/skills/governing-template-development/references/skill-adoption-governance.md`
- Current `AGENTS.md`、workflow governance、Skill registry與Superpowers routing。

## Findings

### Resolved — Classification

初步可能歸類 Level 2 或 Level 4。最終採 Level 3：此 Skill 會自動影響 repository-wide implementation／review route，超出 local optional helper；但它不擁有 authority、artifact 或 release policy，因此不構成 Level 4 governance replacement。

### Resolved — User entry ambiguity

Plan 明確禁止要求使用者額外指定 `karpathy-guidelines`。既有入口保持：新功能使用 `starting-feature-work`，其他工作使用 `governing-template-development`。

### Resolved — Upstream copy risk

Plan 不直接複製上游 `CLAUDE.md` 到 `AGENTS.md`，而是固定 commit、保留 provenance，並只採用 RED 證實需要的最小 guidance。

### Resolved — Authority conflict

Design 與 Plan 均明定 accepted Spec／Plan、repository policy、中央治理與 Level 5 safety 高於 simplicity heuristics。

### Resolved — Skill TDD ordering

Plan 要求先完成沒有新 Skill 的 RED baseline；若控制組沒有失敗，必須停止並拒絕不必要的 Skill adoption。Active Skill 只能在 RED audit 完成後建立。

### Resolved — Pilot closure

Plan 將 installation、routing、behavior validation、documentation與clean-checkout拆成獨立 Task；Pilot 只能在 explicit GREEN、discovery GREEN、non-trigger controls 與 authority conflict scenarios通過後接受。

## Gate result

- Open P0：0。
- Open P1 without disposition：0。
- Design Spec：原先誤標為 `accepted`；依 recovery review 已降回 `proposed`，等待完整 Design Task gate與使用者明確核准。
- Implementation Plan：提前建立的 `proposed` 草稿，blocked by Design approval；本 review 不再作為有效 Plan gate evidence。
- Implementation：未開始。

## Supersession

本 review 將「同意進入規劃」錯誤視為 Design approval，且在 Design Task 尚未完整通過前即審查 Plan，因此於 recovery 中標記為 `superseded`。歷史內容保留，不回寫成當時已正確通過。
