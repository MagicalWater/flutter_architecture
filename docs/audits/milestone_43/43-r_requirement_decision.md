---
document_type: planning-review
status: accepted
authoritative_for:
  - milestone-43-presentation-component-architecture-requirement
last_reviewed_baseline: 1.21.0
---

# Milestone 43 — Flutter Presentation Component Architecture & UI Responsibility Governance Requirement Decision

## Requirement Decision

- Request（需求）：建立 repository-wide Flutter Presentation Component Architecture，正式治理 Page／View／Section／Component、Dialog／BottomSheet／Overlay、shell／tab／navigation orchestration、layout／RenderObject／geometry、Bloc／Cubit與 ephemeral UI state、compilation-unit cohesion、feature-local component與Design System promotion，以及對應的 review／machine pressure。
- Problem（問題）：Current repository 已有 Clean Architecture、Feature First、cross-feature Bloc boundary、Design System、Milestone 41 constraint layout architecture與Milestone 42 UI Design Ownership Architecture，但 Presentation layer 內部仍缺少完整 responsibility／ownership／change-reason contract；因此「都屬於 Presentation」仍可能掩蓋多個 independently reviewable responsibilities，反方向也可能用 one-class-one-file、固定folder skeleton或Cubit-everything形式主義過度修正。
- Current behavior（目前行為）：`write_precheck_page.dart`／`write_precheck_view.dart`已保持薄型，但`write_precheck_content.dart`仍集中大量bounded sections；`write_precheck_projection.dart`雖移至`layout/`仍透過`part of`與content形成同一library；`catalog_page.dart`同時包含Bloc binding、ScrollController／connectivity lifecycle、screen-state mapping與status sections；`shell_page.dart`同時負責tabs、shell chrome與surface launch，但surface implementation分屬Theme／Locale／Auth owners；`OtpView`則正確以local timer／setState承擔presentation countdown，證明不能把所有UI state升級Bloc／Cubit。
- Expected behavior（預期行為）：以 responsibility、ownership、lifecycle、change reason與review surface建立通用Presentation架構；明確回答Page/View/Section/Component/Surface/Orchestration/Layout/Controller/State/File的owner與promotion/escalation規則，同時保留小型cohesive implementation的彈性。
- Value（價值）：避免新feature在依賴方向完全正確時仍形成Presentation monolith；也避免為了「架構漂亮」產生大量碎檔、空資料夾、假Bloc/Cubit與generic component framework。規則必須適用一般Flutter feature，不依賴Pencil workflow。
- Classification（分類）：Level 4 — Architecture / Milestone。
- Decision（決策）：Accept。
- Scope（範圍）：Presentation role model、modal surface ownership、shell/navigation orchestration、layout/render owner、state escalation、ephemeral UI state、compilation-unit cohesion、private helper rules、feature-local→Design System promotion、Milestone 42銜接、Skill/Guide/ADR/Agent authority、machine/review pressure與reference adoption。
- Non-goals（非目標）：不制定每widget一檔、每class一檔、固定行數/class數上限；不要求所有畫面Bloc/Cubit；不要求每feature固定建立pages/widgets/components/dialogs/controllers等資料夾；不重做Milestone 41 layout algorithm；不重做Milestone 42 UI Design Ownership；不建立generic Presentation framework；不因本Milestone全面重構所有現有feature。
- Behavioral requirements required（是否需要行為需求）：是；需fresh pressure scenarios覆蓋monolith、over-splitting、Cubit-everything、surface ownership、local state escalation、Design System promotion與`part`假拆分。
- Design Spec required（是否需要 Design Spec）：是。
- Implementation Plan required（是否需要 Implementation Plan）：是；Design accepted後才可建立。
- ADR required（是否需要 ADR）：是；預期新增ADR-032作為repository-wide Presentation responsibility/cohesion stable authority，ADR-003與ADR-018維持各自既有authority並交叉引用。
- Task governance mode（Task 治理模式）：Full two-layer governance。
- Worktree／branch：managed worktree `C:\Users\crazy\.devspace\worktrees\flutter_architecture-19147ec6`；branch `milestone-43-presentation-component-architecture`。
- Regression level（Regression 等級）：Milestone ceiling為Full；中間Task依validation planner執行minimum sufficient validation，holistic／release／post-release fresh full。
- Release required（是否需要發布）：預期需要；exact VERSION disposition由accepted Design／Plan與final review決定。
- Post-release validation（發布後驗證）：需要。
- Required Superpowers skills（必要 Superpowers Skills）：`governing-template-development` → brainstorming／Design governance → Design user approval → writing-plans／Plan governance → implementation時`karpathy-guidelines`＋Test Authoring Decision＋appropriate TDD/review/verification route。
- Required artifacts（必要 artifacts）：Requirement Decision、Design Spec、Design two-layer review、accepted ADR、Implementation Plan、Plan two-layer review、implementation Task reviews、pressure evidence、authority sync、holistic final review、release與post-release evidence。

## Admission evidence

Fresh published authority：

```txt
main = origin/main = 25484a66e56bb5a8248cfc23da1b49c187d90155
VERSION = 1.21.0
working tree = clean
repository_kind = template
active milestone = none（admission前）
Milestone 43 = candidate only（admission前）
```

Current gap不是以line count推導。Evidence顯示同時存在positive與negative examples：

- `OtpView` local countdown使用StatefulWidget/Timer，workflow authority仍在AuthBloc，是local ephemeral state的positive example。
- `ShellPage` launch Theme／Locale／LocalUnlock surfaces，但surface implementation由對應App presentation owner承擔，顯示invocation owner與surface implementation owner可以分離。
- `CatalogPage`把state binding、scroll/reconnect lifecycle、screen mapping與bounded status composition放在同一file，現有authority沒有足夠規則判斷哪些應維持cohesive、哪些已形成independent review surface。
- Pencil reference雖已把`pages/`、`layout/`、`widgets/`物理分開，`layout/write_precheck_projection.dart`仍以`part of`加入`write_precheck_content.dart` library，證明folder placement本身不是責任解耦證據。
- Existing `write_precheck_architecture_contract_test.dart`只能抓Pencil reference的pages/render/section與VisualSpec風險，不能治理一般Feature的surface/state/file cohesion。

## Promotion disposition

Milestone 43由`docs/roadmap/candidates.md`正式promotion為active Architecture Milestone。Requirement acceptance只授權Design工作；Design未經完整Task gate與使用者明確核准前，不得建立accepted Plan或修改production architecture。
