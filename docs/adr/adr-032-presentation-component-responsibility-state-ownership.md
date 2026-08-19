---
document_type: architecture-decision
status: accepted
authoritative_for:
  - adr-032-presentation-component-responsibility-state-ownership
last_reviewed_baseline: 1.23.0
id: ADR-032
title: Presentation Component Responsibility and State Ownership
supersedes:
superseded_by:
related:
  - ADR-003
  - ADR-007
  - ADR-018
  - ADR-021
  - ADR-028
---

# ADR-032 — Presentation Component Responsibility and State Ownership

## Status

Accepted。

## Authoritative Scope

本Decision定義Flutter Presentation layer內部的responsibility roles、source/library cohesion、modal surface ownership、shell/navigation orchestration與state escalation。它適用一般Feature與Pencil-driven implementation，不要求固定資料夾樹，也不取代Clean Architecture、Feature First或其他ADR。

## Context

Repository既有規則已能約束Presentation → Domain dependency direction、跨Feature Bloc、Design System ownership與Pencil mapping，但「都在Presentation layer」仍不足以回答：

- Page/View與bounded section/component如何分責；
- Dialog／BottomSheet／Overlay由誰實作、誰負責觸發；
- Shell/Tab/Navigation可持有哪些UI orchestration；
- custom RenderObject、projection、geometry helper應由誰擁有；
- local State/Hook/controller何時需要升成Cubit/Bloc；
- private helper與handwritten Dart library何時已形成不同change reason；
- feature-local component何時才應promotion到Design System。

若只以file length、class count或folder shape治理，會從monolith反彈成one-widget-one-file形式主義；若把所有UI state升成Cubit，也會把lifecycle mechanics誤當workflow state。

## Decision

### Responsibility roles不是mandatory class taxonomy

`Page`、`View`、`Section`、`Component`、`Surface`、`Layout`描述architectural role，不要求每個role一定有獨立class、file或folder。

- 小型screen可以只有一個cohesive `Page`。
- `Page + View`在同一handwritten source file合法，只要primary responsibility一致。
- 緊密服務同一owner、同lifecycle與同change reason的private helpers可共檔。
- 不建立mandatory `pages/`、`widgets/`、`components/`、`dialogs/` skeleton。

### Handwritten source與Dart library cohesion

Repository採：

> **one handwritten source file = one coherent primary responsibility**

這不是one file = one class。需要extract的訊號包括：不同產品語意或change reason、不同state/lifecycle authority、不同navigation/modal/layout authority、可獨立review/test/replace/reuse，或abstraction level明顯不同。

Handwritten `part`／`part of`仍屬同一Dart library。把cross-owner implementation搬到另一個folder但繼續用`part of`綁回原library，不構成ownership separation。Generated `part`不受此條限制。

### Page與View

`Page`通常擁有route/screen admission與screen-level orchestration，可包含自己的Bloc/Cubit binding、screen-level effect/listener、navigation/modal invocation，以及對View/Content傳遞presentation inputs/intents。

`View`通常擁有screen state → visual composition mapping，可包含loading/error/content branches與screen-level composition。

Page/View role不得同時直接擁有獨立custom RenderObject/projection engine或大量具有獨立change reason的bounded section implementation。

### Section與Component

`Section`是screen-bounded、具有清楚產品語意與可能獨立change reason的區域；`Component`是bounded、具有穩定input/output的UI unit。並非每個Widget都是Component，也不是每個Section都要獨立file；只有責任真的分離才extract。

Bounded Section/Component不取得fixed-canvas例外。普通content relationships仍由Flutter constraints與parent-child layout擁有；`Stack/Positioned`只在該owner真正承擔spatial／overlay semantics時合理。把screen切成多個bounded owners後，再由每個owner用canonical `left/top`排列普通Text、row、button或card content，仍是layout responsibility failure，不因責任已拆檔而合法。

### Dialog／BottomSheet／Overlay Surface

Modal UI分成兩個owner：

```txt
Invocation owner
→ 何時打開、由哪個intent觸發、結果如何接回flow

Surface implementation owner
→ Dialog / BottomSheet / Overlay本身UI、local interaction、validation與presentation semantics
```

兩者可以是不同owner。例如Shell可以觸發Appearance Dialog，但Theme presentation仍擁有Dialog implementation。

### Shell／Tab／Navigation orchestration

Shell可擁有tab/destination route composition、shell-level AppBar/NavigationBar、shell-owned navigation identity與route/surface invocation mapping。Child feature不得反向依賴Shell tab index、Shell Bloc或具體route stack identity；跨Feature authority繼續遵守ADR-007與ADR-021。

### Layout／RenderObject／Geometry mechanics

Custom RenderObject、projection與geometry helper本身不是反模式，但必須有明確layout responsibility、invariants與focused validation owner。不允許Page/View orchestration同時承擔獨立render engine。`layout/`也不是geometry dumping ground；screen-local placement、bounded projection與component-local geometry仍由最小正確owner持有。

### Presentation state escalation

State owner依responsibility與lifecycle逐級判斷：

```txt
Widget/render lifecycle mechanics
→ local State / Hook / Controller

同screen多個bounded owners共享的presentation mechanics
→ lifted presentation state / narrow presentation-local controller

Workflow transition、async ordering、retry、failure、concurrency、business-facing screen state
→ Cubit / Bloc

跨Feature或超出Presentation lifecycle的authority
→ App coordinator / Domain / Repository / Session authority
```

TextEditingController、FocusNode、ScrollController、AnimationController、local TabController、hover/pressed/focused、expand/collapse、presentation-only countdown ticker與transient selection預設屬local UI mechanics，除非它們實際承擔workflow authority。

因此`setState`、Hook、Controller存在本身不是architecture failure；沒有Bloc/Cubit也不是failure。

### Private helpers

Private helper可留在primary owner同檔，只要只服務該owner、lifecycle相同、change reason高度一致、沒有獨立public API、沒有獨立state/navigation/layout authority，且extract只會增加跳檔成本而沒有形成真正boundary。

### Feature-local → Design System promotion

沿用ADR-018與Milestone 42 UI Design Ownership Architecture：

```txt
single-screen exact component
→ feature-local smallest correct owner

同Feature內具穩定語意與真實reuse
→ feature-local reusable component

shared semantic / Theme Identity / validated reusable component
→ Design System
```

Raw value相同、只有一個consumer、或只因「未來可能重用」都不足以promotion。

## Explicit Non-Rules

Repository明確不採用widget-per-file、class-per-file、file line-count hard limit、class/widget count hard limit、fixed Presentation folder tree、`setState` ban、Bloc/Cubit-everywhere，或為每個architecture topic新增獨立governance Skill。

## Review Questions

Review一個Presentation source時優先問：

1. Primary responsibility是什麼？
2. 它因哪些change reason改變？
3. 它擁有哪些state/lifecycle/navigation/layout authority？
4. 其中是否有部分已形成可獨立review/test/replace/reuse的boundary？
5. 若拆分，是否真的降低責任耦合，而不是只增加file count？
6. 若升Bloc/Cubit或Design System，是否有真實workflow/shared-semantic evidence？
7. Layout owner是否符合實際UI semantics？Content flow若由前一個content size + gap決定，是否由relationships擁有；位置本身若是local/spatial contract，`Stack/Positioned`與scaled coordinates是否由正確owner持有？不得只以widget/property名稱判定fixed canvas。

## Consequences

- Presentation architecture以責任與change reason治理，不靠目錄與行數。
- local UI mechanics可以保持local，避免state-management ceremony。
- Modal launcher與surface implementation可由不同owner持有。
- custom rendering有合法位置，但不得隱藏在Page/View orchestration owner。
- handwritten `part`不能當作跨owner假拆檔工具。
- Future feature可以使用最小必要結構，不為template symmetry製造空folder或碎檔。

## Supersession

無。

## Related Decisions

- ADR-003：Bloc與Hooks的Presentation state tool boundary。
- ADR-007：跨Feature state boundary。
- ADR-018：Design System與Feature-local UI ownership。
- ADR-021：App-owned navigation coordination。
- ADR-028：Pencil-to-Flutter mapping workflow。

## Related Evidence

- `docs/audits/milestone_43/43-r_requirement_decision.md`
- `docs/superpowers/specs/2026-08-18-milestone-43-presentation-component-architecture-design.md`
- `docs/superpowers/plans/2026-08-18-milestone-43-presentation-component-architecture.md`
- `docs/audits/milestone_43/43-1_presentation_architecture_red_review.md`

## Last Reviewed Baseline

1.25.2；Design-space scaling integration把review contract精準化為layout ownership／UI semantics，不再以`Stack/Positioned`或coordinate property作architecture oracle；Milestone 44原本的fixed-canvas laundering防護仍保留在錯誤owner判斷。
