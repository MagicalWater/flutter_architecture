---
document_type: governance-policy
status: accepted
authoritative_for:
  - template-development-workflow-governance-overview
last_reviewed_baseline: 1.13.0
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

新增Skill必須先做confirmed gap、overlap、authority、permission、version、rollback與pressure-scenario審查。Approved、Approved with restrictions、Pilot、Deprecated與Rejected disposition由Workflow Governance Skill reference定義。

### Adopted Skill registry

| Skill | Status | Trigger | Responsibility | Forbidden responsibility | Companion | Rollback |
|---|---|---|---|---|---|---|
| `governing-template-development` | Approved | 所有新需求、Bug、Refactor、Migration、Architecture、Release與治理工作 | Requirement Decision、Level 0～5、artifact／Superpowers／Task routing | 取代repository authority、source、tests、CI或release evidence | Superpowers | 移除`AGENTS.md` wiring前須先完成替代治理與pressure validation |
| `starting-feature-work` | Approved | 新功能、新畫面、user flow或Figma-driven implementation | 接收短feature brief並強制委派中央治理 | Level、approval、branch、Task、validation、release與closure policy | `governing-template-development` | 移除Skill與本registry row；中央治理入口不受影響 |
| `karpathy-guidelines` | Pilot／Approved with restrictions | 已完成分類與必要核准後的production code implementation、refactor與code review | simplicity、surgical changes、explicit assumptions與verifiable goals | Level、scope approval、branch、Task acceptance、release／closure；不得移除安全、migration、accessibility或validation evidence | `governing-template-development`＋routed Superpowers | 移除中央routing與`.agents/skills/karpathy-guidelines/`；中央治理不受影響 |

### Feature shortcut

新功能或新畫面可只指定：

```txt
使用 repository-local starting-feature-work Skill。

[功能需求]
Figma：[網址，如有]
```

該Skill只是快捷入口；使用者不需要再同時指定`governing-template-development`，因為委派中央治理是快捷Skill的強制責任。其他工作仍可直接指定中央治理Skill並提供簡短自然語言需求。

`karpathy-guidelines`不是使用者入口。中央治理在進入production code implementation／refactor／review後自動載入；純需求討論、Design／Plan核准、Level 0文件修正、roadmap與release closure不觸發。

## Change policy

修改工作治理時，必須同時review：

1. `AGENTS.md`強制入口。
2. Workflow Governance Skill與references。
3. 本人類總覽是否仍準確。
4. Docs checker與pressure scenarios是否需要更新。
5. 是否影響既有Design／Plan／Task／release authority。
