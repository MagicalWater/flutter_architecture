---
document_type: phase-review
status: completed
authoritative_for:
  - adopting-template-product-identity-task-4-routing-registry
last_reviewed_baseline: 1.13.0
---

# Adopting Template Product Identity Task 4 Routing and Registry Review

## Task scope

本Task只加入中央治理的narrow domain route與人類可讀Skill registry。未修改`AGENTS.md`、root entry policy、Design／Plan gate或Skill本體input／safety內容。

## Implementation evidence

- `.agents/skills/governing-template-development/SKILL.md`新增「Template product identity domain route」。
- `docs/governance/development_workflow.md`新增Pilot registry row、完整admission detail block與shortcut說明。

## Focused review findings

### F1 — Routing可能在Requirement Decision前觸發

- Severity：P1。
- Fix：route明定只有accepted Requirement Decision識別full template adoption後才載入domain Skill。
- Fresh re-review：domain Skill無法自行classification或approval。

### F2 — Trigger可能擴張到所有native／configuration工作

- Severity：P1。
- Fix：中央route明確排除API-only、visual-only、bounded single-platform repair、environment contract、signing與Store distribution。
- Fresh re-review：central trigger與domain Skill frontmatter一致。

### F3 — Registry可能缺少完整admission contract

- Severity：P1。
- Fix：除compact row外，新增source、overlaps、mutations、permissions、validation evidence、last review與upgrade triggers。
- Fresh re-review：符合`skill-adoption-governance.md` registry contract。

### F4 — Entry-point關係可能形成循環委派

- Severity：P1。
- Review：root工作仍先進`governing-template-development`；shortcut被直接指定時先委派中央治理；中央治理只在accepted classification後使用domain Skill，不要求domain Skill再次重新分類已接受的同一決定。
- Disposition：沒有循環authority；central governance保持唯一owner。

## Entry-point matrix

```txt
all repository work              → governing-template-development mandatory root entry
feature／screen shortcut         → starting-feature-work → central governance
template identity shortcut       → adopting-template-product-identity → central governance
coding companion                 → karpathy-guidelines after routed approvals only
```

## Whole-Task and authority review

- 未複製domain Skill的input list、manifest-first procedure或safety matrix到中央Skill。
- 未修改Level matrix、approval、Task、validation、release或closure規則。
- Registry status維持`Pilot／Approved with restrictions`，未因machine discovery GREEN升級為fully Approved。
- `AGENTS.md`不新增domain Skill mandatory wiring，避免root policy膨脹。

## Severity gate

- Open P0：0。
- Open P1 without disposition：0。
- Open P2 without disposition：0。
- Task 4 disposition：Passed。
- Next Task：Task 5 — Guide Entry and Authority Review。
