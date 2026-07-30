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

Repository-local Skill 的`SKILL.md`、references、範例與pressure scenarios預設使用繁體中文；Skill名稱、檔名、路徑、status values與必要技術識別保留英文。翻譯trigger或gate wording後必須重新執行focused adoption review，不能把語言修正當成不需驗證的純排版變更。

`docs_check`會對`.agents/skills/**/*.md`執行最小語言contract：每個`SKILL.md`的frontmatter description與每份Skill Markdown正文都必須包含中文文字。Checker只防止英文-only回歸；繁體用字、trigger語意、gate與safety wording仍必須由focused adoption review與pressure validation審查。

### Adopted Skill registry

| Skill | Status | Trigger | Responsibility | Forbidden responsibility | Companion | Rollback |
|---|---|---|---|---|---|---|
| `governing-template-development` | Approved | 所有新需求、Bug、Refactor、Migration、Architecture、Release與治理工作 | Requirement Decision、Level 0～5、artifact／Superpowers／Task routing | 取代repository authority、source、tests、CI或release evidence | Superpowers | 移除`AGENTS.md` wiring前須先完成替代治理與pressure validation |
| `starting-feature-work` | Approved | 新功能、新畫面、user flow或Figma-driven implementation | 接收短feature brief並強制委派中央治理 | Level、approval、branch、Task、validation、release與closure policy | `governing-template-development` | 移除Skill與本registry row；中央治理入口不受影響 |
| `karpathy-guidelines` | Pilot／Approved with restrictions | 已完成分類與必要核准後的production code implementation、refactor與code review | simplicity、surgical changes、explicit assumptions與verifiable goals | Level、scope approval、branch、Task acceptance、release／closure；不得移除安全、migration、accessibility或validation evidence | `governing-template-development`＋routed Superpowers | 移除中央routing與`.agents/skills/karpathy-guidelines/`；中央治理不受影響 |
| `adopting-template-product-identity` | Approved | 已接受的跨Android／iOS模板產品identity或三環境display-name mapping採用 | 接收短input、authority routing、pre-inventory、manifest-first與evidence boundary | Level、approval、environment contract、signing、Store、release與closure | `governing-template-development`；只有實際進入production code／script implementation時才搭配`karpathy-guidelines` | 移除Skill、中央route、registry row與Guide entry；既有authority不受影響 |

#### 2026-07-30 repository-local Skill language revalidation

- `governing-template-development`：Level 0～5、artifact routing、Design／Plan gate、雙層Task、stop／continue、Skill adoption與pressure protocol完成逐檔semantic review。
- `adopting-template-product-identity`：trigger／non-trigger、input gate、manifest-first、secret／signing hard stop與R1～R10完成review；過期restricted Pilot固定文字已修正為保留current registry status。
- `starting-feature-work`：short brief、central delegation、discussion-only與skip-governance pressure完成review。
- `karpathy-guidelines`：pinned source、subordinate routing、anti-overengineering、non-trigger與restricted Pilot boundary完成review。
- Mechanical evidence：`tools/docs/check_docs.py`加入`agent-skill-language`；英文-only description與reference body的RED tests已轉GREEN。
- Full evidence：`docs/audits/repository_local_skills_zh_tw_task_1_central_governance_review.md`至`repository_local_skills_zh_tw_task_5_language_governance_review.md`。

#### `adopting-template-product-identity` admission details

- Source：repository-original；無外部version pin。
- Overlaps：`governing-template-development`、`starting-feature-work`、`karpathy-guidelines`、`native_environment_adoption.md`；責任以中央治理與Guide authority切分。
- Repository mutations：Skill path、narrow central route、registry row、Guide entry與audit evidence。
- Permissions：不需要network、external credential、MCP或signing access。
- Validation evidence：Task 1 RED、Task 3 pressure validation、Task 5 authority review、Task 6 final review、remote clean-checkout discovery與2026-07-30 fresh isolated behavioral approval closure。
- Approval basis：未指定Skill名稱的discovery／discussion-only、明確跳過治理＋secret pressure，以及API-only non-trigger三個獨立新對話均通過。
- Last review：2026-07-30。
- Upgrade triggers：trigger wording、managed paths、permissions、workflow order、automatic loading或supported runtime變更。

### Feature shortcut

新功能或新畫面可只指定：

```txt
使用 repository-local starting-feature-work Skill。

[功能需求]
Figma：[網址，如有]
```

該Skill只是快捷入口；使用者不需要再同時指定`governing-template-development`，因為委派中央治理是快捷Skill的強制責任。其他工作仍可直接指定中央治理Skill並提供簡短自然語言需求。

完整跨Android／iOS模板產品identity採用也可只指定`adopting-template-product-identity`並提供簡短產品brief；該Skill必須先委派中央治理。API-only、visual-only、單一平台bounded repair、environment architecture、signing與Store工作仍由中央治理直接分類，不由此shortcut自動接管。

`karpathy-guidelines`不是使用者入口。中央治理在進入production code implementation／refactor／review後自動載入；純需求討論、Design／Plan核准、Level 0文件修正、roadmap與release closure不觸發。

完整日常使用情境、入口選擇與可直接複製的功能／畫面／除錯／測試失敗／Refactor／Migration Prompt，見[AI Agent協作開發快速使用指南](../guides/agent_assisted_development_quick_start.md)。該Guide只提供使用者操作範例，不複製或取代本文件與中央Skill的治理authority。

## Change policy

修改工作治理時，必須同時review：

1. `AGENTS.md`強制入口。
2. Workflow Governance Skill與references。
3. 本人類總覽是否仍準確。
4. Docs checker與pressure scenarios是否需要更新。
5. 是否影響既有Design／Plan／Task／release authority。
