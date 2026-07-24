---
document_type: governance-policy
status: accepted
authoritative_for:
  - template-development-workflow-governance-overview
last_reviewed_baseline: 1.12.0
---

# Template Development Workflow Governance

## Purpose

本文件是人類可讀的治理總覽。可執行工作分類、artifact routing、Superpowers協作與雙層Task流程由repository-local Skill擁有：

- [`.agents/skills/governing-template-development/SKILL.md`](../../.agents/skills/governing-template-development/SKILL.md)

本文件不複製Skill完整矩陣，避免形成第二份executable authority。

## Responsibility model

```txt
AGENTS.md
→ 強制入口與不可違反policy

Workflow Governance Skill
→ Requirement Decision、Level 0～5、流程路由、雙層Task模式

Superpowers
→ brainstorming、planning、TDD、debugging、execution、review、verification

Repository artifacts
→ current truth、architecture decision、evidence、release與history
```

## Standard lifecycle

```txt
Idea／Bug／Request
→ Requirement Decision
→ Work Classification
→ Accept／Reduced／Defer／Reject
→ routed Superpowers workflow
→ routed Task governance
→ authority sync
→ validation／release／post-release as classified
```

Level 0／1使用minimal或simplified治理，禁止因流程本身而建立不必要的Spec、Plan或Milestone。Level 2～5依風險逐步要求Behavioral Requirements、Design、Plan、ADR、完整regression與release closure。

## Authority boundaries

- Skill不能取代`AGENTS.md`、ADR、Guides、source、tests、CI、VERSION或CHANGELOG。
- Design Spec擁有已核准需求行為與technical design；Implementation Plan擁有執行順序與commit boundary。
- Audit保存findings與evidence，不成為current state。
- 最後一個implementation Task通過不等於Milestone完成；release、push與post-release validation必須依分類完成。

## Skill adoption

新增Skill必須先做confirmed gap、overlap、authority、permission、version、rollback與pressure-scenario審查。Approved、Restricted、Pilot、Deprecated與Rejected disposition由Workflow Governance Skill reference定義。

## Change policy

修改工作治理時，必須同時review：

1. `AGENTS.md`強制入口。
2. Workflow Governance Skill與references。
3. 本人類總覽是否仍準確。
4. Docs checker與pressure scenarios是否需要更新。
5. 是否影響既有Design／Plan／Task／release authority。
