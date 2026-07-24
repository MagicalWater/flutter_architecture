---
document_type: design-spec
status: proposed
authoritative_for:
  - milestone-31-template-development-workflow-governance-design
last_reviewed_baseline: 1.12.0
---

# Milestone 31 — Template Development Workflow Governance Design

## Requirement Decision

- Decision：Accepted。
- Classification：Level 4 — Architecture／Milestone Governance。
- Problem：Superpowers提供通用執行方法，雙層Task治理提供審查與closure gate，但兩者之間缺少repository-local的需求分類、流程路由與過度治理防線。
- OpenSpec disposition：Reject adoption；只吸收Requirement Intake、Behavioral Requirements與change decision概念。

## Goals

1. 在repository的`.agents/`建立可執行工作治理Skill。
2. 以Skill統一Requirement Decision、Level 0～5分類、artifact routing、Superpowers routing與雙層Task模式。
3. `AGENTS.md`只負責強制入口與最高階policy，不複製完整流程。
4. `docs/governance/development_workflow.md`提供人類總覽、責任邊界與authority map，不成為第二份可執行規則。
5. 將既有兩層Task治理模型正式整合為Skill reference。
6. 修正Milestone 30 closure相關stale authority，並增加自動檢查避免復發。

## Non-goals

- 不安裝OpenSpec。
- 不建立`openspec/`。
- 不以Skill取代ADR、source、tests、CI、VERSION、CHANGELOG或current snapshot。
- 不把Level 0／1小改動強制升級成Spec、Plan或Milestone。
- 不遷移歷史`docs/superpowers/`路徑。

## Responsibility Model

```txt
AGENTS.md
  → 強制入口與不可違反policy

.agents/skills/governing-template-development/
  → executable workflow authority
  → classification、decision、routing、Task governance

Superpowers
  → brainstorming、planning、TDD、debugging、execution、review、verification

Repository artifacts
  → current truth、decision、evidence、release與history
```

## Skill Structure

```txt
.agents/skills/governing-template-development/
  SKILL.md
  references/
    work-classification.md
    artifact-routing.md
    two-layer-task-governance.md
    skill-adoption-governance.md
    pressure-scenarios.md
```

`SKILL.md`保存觸發條件、主決策流程、輸出格式、停止／續跑規則與reference routing。大型矩陣拆至references，避免主Skill過長。

## Requirement Decision Contract

每項工作先輸出：Request、Problem、Current Behavior、Expected Behavior、Value、Classification、Decision、Scope、Non-goals、Behavioral Requirements、Design／Plan／ADR需求、Task governance mode、Regression、Release、Required skills與artifacts。

Decision只允許：Accept、Accept with reduced scope、Defer、Reject。

## Level Model

- Level 0：Trivial Change。
- Level 1：Small Fix。
- Level 2：Standard Feature。
- Level 3：Cross-cutting Change。
- Level 4：Architecture／Milestone。
- Level 5：Release／Migration／Platform Critical。

每級明確定義mandatory、optional與forbidden，並採風險向上升級；不得因流程方便而向下降級。

## Behavioral Requirements

- BR-1：任何新需求、Bug、Refactor、Migration、Architecture、Release或治理工作，必須先完成Requirement Decision。
- BR-2：Level 0／1不得被不必要地要求完整Spec、Plan或Milestone。
- BR-3：Level 2～5依矩陣啟用Superpowers與雙層Task治理。
- BR-4：Design、Plan與Implementation Task都可成為正式Task；其review gate不得被Superpowers預設流程跳過。
- BR-5：Skill不得覆蓋repository authority；衝突時以`AGENTS.md`與current repository artifacts為準。
- BR-6：只有scope／architecture decision、外部阻塞、推翻已核准Spec／Plan的P0／P1或整個Milestone完成時才停下。
- BR-7：Milestone archive／closure必須晚於release、push與post-release validation。

## Documentation and Automation

- 新增`docs/governance/development_workflow.md`作人類入口。
- 更新`docs/README.md`、`AGENTS.md`與相關indexes。
- Docs checker新增Milestone closure一致性檢查：當active milestone為None時，Milestone index不得保留pending active routing或重複同一Milestone狀態。
- 修正`docs/project_context.md`、`docs/milestones/README.md`、`docs/superpowers/README.md`與metadata baseline。

## Validation

- Skill structure與frontmatter檢查。
- Pressure scenarios覆蓋Level 0～5、過度治理、降級、Spec／Plan gate、自動續跑與真正停止條件。
- Python docs checker tests。
- `docs_check`、analyze、Flutter regression與diff check。

## Rollout

本Skill先作repository-local authority，不宣稱通用跨專案Skill。樣板被複製成產品repository時一併帶入，再由產品專案依自身authority調整。
