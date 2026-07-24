---
document_type: final-review
status: accepted
authoritative_for:
  - karpathy-guidelines-primary-workflow-final-review
last_reviewed_baseline: 1.13.0
---

# Karpathy Guidelines Primary Workflow Holistic Final Review

## Scope

本review取代已superseded的Codex＋Ponytail Rejected結論，整體檢查：

- runtime mismatch recovery；
- restricted repository-local Skill；
- central routing與non-trigger exclusions；
- Skill registry與human docs；
- primary ChatGPT＋bridge-mac clean-worktree discovery；
- provenance、rollback與validation boundary。

## Commits

```txt
8339c0b docs(workflow): 重開Karpathy主要工作流審查
46eea30 feat(workflow): 加入受限制Karpathy coding Skill
7075685 feat(workflow): 接線Karpathy coding companion
```

## Findings

### F-KG-R01 — Ponytail污染舊RED

Resolved。舊final review為`superseded`，不再支配current disposition。

### F-KG-R02 — Primary runtime缺少fresh behavioral subagent

Disposition：Accepted restriction。Discovery、static authority、trigger、non-trigger與docs validation已完成；fresh behavioral discovery GREEN延後至平台提供isolated ChatGPT＋bridge-mac context。這項限制禁止fully Approved，但不阻塞Pilot。

### F-KG-R03 — Skill可能形成第二治理入口

Resolved。中央Skill明確規定使用者入口維持`starting-feature-work`或`governing-template-development`；Karpathy只在classification與必要核准後載入。

## Final disposition

```txt
Adoption：Pilot／Approved with restrictions
Primary runtime discovery：Passed
Ponytail dependency：None
Central governance authority：Preserved
Behavioral fresh-context GREEN：Deferred with explicit trigger
VERSION／release：Unchanged
Open P0：0
Open P1 without disposition：0
```

Rollback：移除`.agents/skills/karpathy-guidelines/`、中央routing與registry row；`governing-template-development`及Superpowers流程不受影響。
