---
document_type: planning-review
status: completed
authoritative_for:
  - karpathy-guidelines-adoption-design-recovery-review
last_reviewed_baseline: 1.13.0
---

# Karpathy Guidelines Adoption Design Recovery Review

## Recovery reason

原始規劃 commit `c7fed96` 在未取得落檔後 Design Spec 明確核准前，將 Design 標記為 `accepted`，並提前建立 Implementation Plan。這違反 `governing-template-development` 的 Design／Plan approval gate與 Level 3 Full two-layer Task ordering。

本 recovery 不改寫既有 commit；保留錯誤歷史，修正 current artifact status與後續 routing。

## Review scope

- `docs/superpowers/specs/2026-07-25-karpathy-guidelines-adoption-design.md`
- `.agents/skills/governing-template-development/SKILL.md`
- `.agents/skills/governing-template-development/references/work-classification.md`
- `.agents/skills/governing-template-development/references/artifact-routing.md`
- `.agents/skills/governing-template-development/references/two-layer-task-governance.md`
- `.agents/skills/governing-template-development/references/skill-adoption-governance.md`
- `AGENTS.md`
- `docs/governance/development_workflow.md`

## Focused review

### Scope and value

Confirmed gap remains valid：現有治理與 Superpowers 已控制需求、TDD、review與驗證，但 implementation／code review仍可能出現未要求抽象、scope creep與鄰近重構。Pilot companion Skill具有可驗證價值。

### Classification

Level 3維持正確：automatic repository-wide implementation／review routing跨越多 feature／package；但 Skill 不擁有 Level、artifact、approval、Task或release authority，因此不升級為 Level 4。

### Authority boundary

Design 明定 repository authority、中央 Requirement Decision、accepted Design／Plan與必要 safety requirements高於 simplicity heuristics。Skill不能成為使用者入口、不能改變停止條件，也不能自行削減已核准 scope。

### Source and rollback

上游 repository、source path與 pinned commit均已具體記錄；upgrade需重新 adoption review與pressure validation；rollback不影響中央治理與Superpowers。

### Acceptance criteria

Acceptance涵蓋 automatic routing、non-trigger controls、authority conflict、Level 5 safety、provenance與rollback，足以指導後續 Plan。

## Findings and fixes

### P1 — Invalid Design acceptance

- Finding：使用者要求「規劃加入」被錯誤解讀為核准落檔後 Design。
- Fix：Design metadata由`accepted`降為`proposed`；Approval段落改為明示需完整Task gate與使用者明確核准。
- Fresh re-review：current Design不再宣稱已核准，且implementation仍被禁止。

### P1 — Plan created before Design approval

- Finding：Implementation Plan與planning review在Design尚未通過前建立。
- Fix：保留Plan作歷史草稿，標記blocked by Design approval；原planning review標記`superseded`，不得作為有效Plan gate evidence。
- Fresh re-review：current routing明確要求Design核准後重新執行完整Plan Task review。

### P2 — Routing summary stale

- Finding：`docs/superpowers/README.md`將Design描述為可直接路由至Plan approval。
- Fix：同步為Design `proposed`、Plan blocked狀態。
- Fresh re-review：索引與current artifacts一致。

## Whole-Design holistic review

- Requirement Decision欄位完整。
- Scope與Non-goals不互相衝突。
- Pilot trigger與non-trigger boundary明確。
- Authority precedence與repository stop／continue規則相容。
- Source pinning、upgrade、rollback與pressure validation均可追溯。
- 沒有要求修改產品程式碼、VERSION或release state。

## Authority and validation gate

- Design status：使用者於 2026-07-25 明確核准，已轉為`accepted`。
- Plan status：`proposed` draft，進入重新Plan Task review。
- Implementation：forbidden。
- Open P0：0。
- Open P1 without disposition：0。
- Next user-owned gate：Plan Task完成後明確核准或要求修改 Implementation Plan。

## Recovery disposition

Design內容已通過 focused review、findings修正、fresh re-review與whole-Design review，並取得使用者明確核准；Design Task正式完成，可進入Plan Task，但不得開始implementation。
