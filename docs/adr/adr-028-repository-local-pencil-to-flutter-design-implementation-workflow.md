---
document_type: architecture-decision
status: accepted
authoritative_for:
  - adr-028-repository-local-pencil-to-flutter-design-implementation-workflow
last_reviewed_baseline: 1.19.0
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

`.pen`的結構讀取與修改只透過approved Pencil MCP integration。Repository-governed Pencil workflow唯一允許`pencil-session-mcp` isolated session；每個conversation／client必須持有自己的exact `sessionId`，fresh建立session後先驗證active document identity，並只關閉自己持有的session。Visible Pencil Desktop／`pencil-local-mcp`不得作為repository-governed Pencil workflow的admission、fallback或single-client替代route。Repository code、scripts與agents不得以native JSON／text parser或direct file mutation作fallback。

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

Critical implementation items必須在Flutter production mapping前形成initiative-local、machine-readable implementation mapping evidence。此evidence不取代`.pen`或visual manifest，也不建立global asset registry；只對risk-selected critical nodes保存representation identity、Flutter owner／consumer與resolution state。

Critical mapping disposition固定為：

```txt
exact
verified-equivalent
intentional-deviation
unresolved
```

`verified-equivalent`必須有可追溯equivalence evidence；`intentional-deviation`必須有accepted approval reference；`unresolved` fail closed。名稱相同、語意相同或candidate肉眼接近不能自行升級為`exact`或accepted deviation。

### Single-renderer responsive fidelity

一個accepted `.pen` screen只能映射到一套Flutter whole-screen visual component model。**One accepted screen → one whole-screen visual tree**；canonical、phone與narrow viewport可以在同一組components內使用不同layout policy，但不得依whole-screen breakpoint替換成另一套renderer。

Manifest的canonical viewport是**design/comparison space**，不是**Flutter logical breakpoint**。例如Pencil export寬度`941`不能被解讀成`constraints.maxWidth >= 900`才啟用精準renderer；runtime geometry必須由accepted design-space與明確responsive contract導出。

Visible geometry可以由shared design scale計算真Flutter widget的width、height、offset、padding、gap、radius、icon size與feature-local typography。這是widget geometry projection，不是把整張UI當海報縮放；**top-level `FittedBox`或`Transform.scale`仍禁止**，full-screen raster embedding同樣禁止。

極窄width、localization、orientation或accessibility text scale真的需要調整時，只能在同一component tree內做content-aware adaptation，例如Row→Column、文字換行或扩大interactive hit region，不得建立parallel whole-screen visual renderer。

### Visual acceptance

每個initiative以manifest固定canonical viewport與comparison contract，至少產生Pencil derived preview、Flutter canonical golden、supported runtime screenshot、deterministic diff與人工語意visual review。

Canonical fidelity與supported runtime fidelity必須驗證**同一production whole-screen tree**。Scrollability、no-overflow、semantics與touch target只證明**layout health**，不能代表**runtime fidelity**。Supported runtime必須有可重現的**visual fidelity evidence**，並接受side-by-side semantic review。

Accepted `.pen`只有單一手機frame時，可以在candidate implementation前由canonical Pencil preview依manifest固定的target、projection algorithm、crop／scroll contract產生derived runtime reference。Derived reference只作comparison evidence，不取得`.pen` authority；不得在candidate失敗後更換projection、resize策略、threshold或ignore regions。

不得以full-screen raster embedding、全畫面fixed-canvas scaling、事後擴大threshold或任意ignore region取得通過。Pixel evidence與semantic review缺一不可。

Whole-screen visual metrics是broad regression owner，不是micro-fidelity唯一authority。Risk-selected critical icon、asset、component或geometry可以有更小的local owner，例如component golden、事前固定ROI、asset identity/hash、icon equivalence evidence或runtime geometry assertion。Acceptance採AND semantics：**whole-screen PASS + critical local FAIL = overall FAIL**。

Critical runtime geometry驗收實際render result，而不是source literal。當accepted geometry與Flutter source constant一致、但runtime`RenderBox`或等價runtime evidence不一致時，geometry gate仍FAIL；corrective implementation可繼續，但不得宣稱fidelity／production acceptance PASS。

Reviewer一旦判定wrong source／wrong asset／wrong icon／wrong representation，受影響mapping立即invalid。不得繼續以padding、scale、crop、offset、opacity或threshold tuning挽救該candidate；必須回representation classification／provenance，resolve replacement representation、更新mapping evidence、fresh affected validation，再重新進affected visual acceptance。若真正需要改accepted`.pen`或Design authority，回中央Requirement／Design gate。

## Consequences

- Template取得可重複、可審查的Pencil-to-Flutter workflow，而不是一次性還原成果。
- Third-party Skill可保留上游原文與integrity，同時維持repository fail-closed治理。
- Agent必須證明實際載入worktree-local source，降低user-global collision與版本漂移風險。
- UI implementation必須同時滿足visual authority與既有Flutter architecture。
- Visual validation增加artifact與測試成本，但提供可重現的fidelity evidence與regression protection。
- Single-renderer contract讓canonical與runtime visual gates互相約束，不能再由test-only canonical renderer替runtime重設計分支取得PASS。

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

1.19.0；Milestone 39補入critical mapping disposition、runtime geometry、local fidelity override與wrong-representation recovery stable contract。
