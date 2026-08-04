---
document_type: architecture-decision
status: accepted
authoritative_for:
  - adr-028-repository-local-pencil-to-flutter-design-implementation-workflow
last_reviewed_baseline: 1.14.0
id: ADR-028
title: Repository-local Pencil-to-Flutter Design Implementation Workflow
supersedes:
superseded_by:
related:
  - ADR-009
  - ADR-011
  - ADR-018
  - ADR-019
---

# ADR-028 — Repository-local Pencil-to-Flutter Design Implementation Workflow

## Status

Accepted。

## Authoritative Scope

本Decision定義repository-local `.pen` visual authority、Pencil MCP boundary、third-party Skill identity／integrity、Flutter architecture mapping與visual acceptance contract。

它不擁有Milestone Task sequencing、exact implementation commands、特定畫面的逐像素數值、Taste Skill上游內容或單次review findings。

## Context

Template Baseline 1.14.0已有Feature First、App-only Composition Root、Design System、Localization、testing governance與repository-local Agent workflow，但沒有正式的設計來源到Flutter implementation contract。

外部proof雖已證明單一`.pen`畫面可以還原為Flutter UI，但source、Skills、Flutter app與evidence都位於模板repository外部，無法證明實際使用的`.pen`、Skill載入來源、third-party bytes、visual difference原因與Flutter architecture compliance。

既有docs checker又對`.agents/skills/**/*.md`一律要求中文，會把unmodified third-party Skill誤當成repository-authored policy。直接翻譯上游Skill會破壞provenance、hash與trigger／safety語意，因此需要ownership-aware contract。

## Decision

### Repository-local source authority

每個Pencil-to-Flutter initiative必須把active design source放入：

```txt
docs/design_sources/<initiative>/
docs/visual_authority/<initiative>/manifest.md
```

Manifest必須明確指定primary `.pen`、derived preview、supplementary original reference、historical benchmark、hash、canonical viewport、approval state與supersession。External filesystem path只能作admission input，不能作implementation authority。

### Pencil MCP boundary

`.pen`的結構讀取與修改只透過approved `pencil-local-mcp` integration。Repository code、scripts與agents不得以native JSON／text parser或direct file mutation作fallback。

Pencil unavailable、錯誤document state、source drift或unsupported construct必須形成blocked／finding disposition，不得靜默猜測。

### Third-party Skill identity

Skills分為：

1. Repository-authored：遵守繁體中文policy與repository review。
2. Third-party unmodified：保留上游原始語言、結構與bytes，以immutable source、exact license bytes、install path與逐檔SHA-256鎖定。
3. Repository-maintained fork：任何managed bytes修改後即視為fork，必須使用明確identity、記錄upstream base並遵守repository-authored governance。

Unmodified third-party Skill只有在root `skills-lock.json`完整列出並通過exact hash validation時，才豁免Skill中文檢查。Path-only、name-only或人工宣告不足以取得豁免。

### Skill precedence and collision

Repository必須驗證runtime實際載入managed-worktree local Skill。若user-global、DevSpace-local或configured agent path的同名Skill先行遮蔽，workflow fail closed；不得只因repository存在同名檔案就宣稱載入成功。

### Orchestration ownership

Repository新增薄型`implementing-pencil-flutter-design` Skill，負責委派中央Requirement／approval／Task governance、驗證visual authority與Skill lock、路由Pencil MCP extraction、映射Design System／Localization／Feature First，並路由TDD、visual diff與review evidence。

Taste Skills只作stage-specific companions，不擁有`.pen` authority、Flutter architecture、Task approval、release或closure。

### Flutter mapping

Pencil design不得建立平行Flutter architecture：

- App保持唯一Composition Root。
- Feature使用Feature First。
- Visible strings使用既有Localization authority。
- Base theme與semantic color優先使用既有Design System。
- 只有準確且具穩定共用價值的token／component才提升到Design System；單一畫面特有數值保留feature-local visual specification。
- Presentation-only visual fixture不得建立虛假的Domain、Data、Repository、Use Case、Bloc或DI。

### Visual acceptance

每個initiative以manifest固定canonical viewport與comparison contract，至少產生Pencil derived preview、Flutter canonical golden、supported runtime screenshot、deterministic diff與人工語意visual review。

不得以full-screen raster embedding、全畫面fixed-canvas scaling、事後擴大threshold或任意ignore region取得通過。Pixel evidence與semantic review缺一不可。

## Consequences

- Template取得可重複、可審查的Pencil-to-Flutter workflow，而不是一次性還原成果。
- Third-party Skill可保留上游原文與integrity，同時維持repository fail-closed治理。
- Agent必須證明實際載入worktree-local source，降低user-global collision與版本漂移風險。
- UI implementation必須同時滿足visual authority與既有Flutter architecture。
- Visual validation增加artifact與測試成本，但提供可重現的fidelity evidence與regression protection。

## Supersession

無。

## Related Decisions

- ADR-009：Project language policy；本Decision增加third-party unmodified content的ownership-aware例外。
- ADR-011：Documentation single authority；visual source、manifest、runtime evidence與current state維持分工。
- ADR-018：Design System／Theme boundary；Pencil-specific values只有穩定共用時才提升。
- ADR-019：Localization與user-facing text contract。

## Related Evidence

- [Milestone 33 Design](../superpowers/specs/2026-08-04-milestone-33-repository-local-pencil-to-flutter-workflow-foundation-design.md)
- [Milestone 33 Implementation Plan](../superpowers/plans/2026-08-04-milestone-33-repository-local-pencil-to-flutter-workflow-foundation.md)
- [Milestone 33 Design review](../audits/milestone_33/33-0_design_spec_review.md)

## Last Reviewed Baseline

1.14.0。
