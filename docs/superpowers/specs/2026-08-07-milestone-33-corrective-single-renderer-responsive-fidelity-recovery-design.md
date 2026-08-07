---
document_type: design-spec
status: accepted
authoritative_for:
  - milestone-33-corrective-single-renderer-responsive-fidelity-recovery-design
last_reviewed_baseline: 1.15.0
---

# Milestone 33 Corrective — Single-Renderer Responsive Fidelity Recovery Design

## Requirement Decision

- Request（需求）：修正Template Baseline 1.15.0已發布的Pencil-to-Flutter workflow，使同一份accepted手機`.pen`只產生一套Flutter visual component tree，並在實際Android viewport維持與Pencil一致的視覺比例與層級。
- Problem（問題）：Milestone 33 proof把Pencil canonical `941 × 1672` export尺寸誤當成Flutter logical breakpoint；`>= 900`走精準`WritePrecheckCanonicalCanvas`，較窄runtime走另一套responsive widget tree。Canonical pixel diff因此PASS，但BlueStacks實際`360 × 640`畫面可與accepted`.pen`明顯不同，且既有narrow tests只驗scroll／no-overflow／semantics，未攔截runtime visual drift。
- Current behavior（目前行為）：一個accepted `.pen` screen實際存在兩條visual renderer。Windows canonical comparison驗證第一條；Android runtime使用第二條。Task 33-10 semantic review把「可讀／可scroll／沒有overflow」錯誤視為runtime visual fidelity PASS。
- Expected behavior（預期行為）：`source.pen`中的`941 × 1672`手機screen維持唯一visual authority；Flutter只存在一套visual component tree與一套design-space geometry model。Canonical、360×640、390×844與其他手機尺寸由同一組widgets投影／調整；不得以breakpoint切換到另一套重設計renderer。實際supported runtime必須具有visual fidelity gate，而不只layout-health gate。
- Value（價值）：讓「Pencil-to-Flutter fidelity PASS」真正代表使用者在runtime看到的畫面，而不是只代表test-only canonical branch。封閉目前Skill／Guide／Plan／review都可能放過parallel renderer的治理漏洞。
- Classification（分類）：Level 4 — Architecture／Milestone corrective。
- Decision（決策）：Accept。
- Scope（範圍）：ADR-028 visual mapping amendment、`implementing-pencil-flutter-design` Skill／references、human Guide、visual validation contract、single-renderer Flutter proof refactor、canonical／runtime goldens與diff、Android runtime screenshot、既有Milestone 33 visual review supersession、full regression與1.15.1 corrective release disposition。
- Non-goals（非目標）：新增第二份mobile `.pen`、修改accepted `source.pen`來迎合Flutter、完整NFC功能、建立通用low-code renderer、全畫面raster／FittedBox／Transform縮放、重做Design System、修改產品identifier。
- Behavioral requirements required（是否需要行為需求）：是。
- Design Spec required（是否需要 Design Spec）：是。
- Implementation Plan required（是否需要 Implementation Plan）：是。
- ADR required（是否需要 ADR）：是；ADR-028 stable visual mapping／acceptance boundary需要amendment。Canonical ADR修改只能在Corrective Plan accepted後的治理Task進行。
- Task governance mode（Task 治理模式）：Full two-layer governance。
- Worktree／branch：Corrective Design與Plan accepted後，從published `main`建立新的managed corrective worktree；production implementation不得在dirty main checkout執行。
- Regression level（Regression 等級）：full repository Skill／Docs checks、affected Flutter workspace tests、canonical＋runtime visual acceptance、Android build/runtime evidence、clean-checkout post-release validation。
- Release required（是否需要發布）：是；1.15.0歷史不改寫，corrective完成後預期patch release `1.15.1`，最終版本由Corrective Final Review決定。
- Post-release validation（發布後驗證）：是；release SHA重新驗證Skill routing、single-renderer guard、Flutter regression、Android artifact、canonical與runtime visual evidence。
- Required Superpowers skills（必要 Superpowers Skills）：`brainstorming`、`writing-plans`、`using-git-worktrees`、`test-driven-development`、`systematic-debugging`、review／verification／finishing Skills；production code階段搭配`karpathy-guidelines`。
- Required artifacts（必要 artifacts）：Corrective Design、ADR-028 amendment、Implementation Plan、逐Task review、superseding visual finding、single-renderer architecture tests、canonical／runtime goldens與diff、Android runtime screenshot／review、Corrective Holistic Final Review、release／post-release evidence。

## Approval Gate

本Corrective Design與ADR-028 amendment draft已完成focused review、findings disposition、fresh documentation validation與Whole-Design review，並於2026-08-07取得使用者書面核准。Design因此轉為`accepted`。此核准授權建立Corrective Implementation Plan；Plan仍須完成獨立雙層治理與書面核准後，才能修改canonical ADR、Skill、Guide、tests或Flutter production source。

## Corrective Finding and Supersession

使用者於2026-08-07直接驗收BlueStacks runtime畫面並判定不通過。該人工finding依ADR-028與Skill既有規則高於先前semantic PASS：pixel metrics不能覆蓋semantic P1。

因此下列舊結論只保留歷史evidence，不再代表current runtime fidelity：

- `docs/audits/milestone_33/visual_validation/review.md`中的`narrow layout: PASS`與`Android renderer differences: PASS`。
- `33-12_holistic_final_review.md`中依賴上述runtime visual acceptance的完整workflow capability disposition。
- 尚未提交的Milestone 33 closed／archived routing。

1.15.0 release與其clean-checkout技術驗證仍是不可改寫的歷史事實，但workflow capability current state必須進入corrective remediation，不能以release identity冒充缺陷已消失。

## Root Cause

Current production source存在整頁renderer分叉：

```txt
constraints.maxWidth >= 900
→ WritePrecheckCanonicalCanvas
→ exact Pencil geometry

constraints.maxWidth < 900
→ separate responsive Column／widgets
→ independently chosen spacing／sizes／layout
```

`941`是Pencil export／design-space width，不是Flutter logical breakpoint。BlueStacks runtime為：

```txt
Flutter logical viewport: 360 × 640
Pencil design viewport: 941 × 1672
aspect ratio: effectively identical
```

因此在這個proof中，runtime本應接近同一手機設計的比例投影，而不是重新排版成第二個visual design。

治理上的共同根因有三個：

1. Design只要求canonical fidelity；narrow requirement降級為scroll／no-overflow／hierarchy。
2. Skill的`Fidelity與responsiveness`沒有禁止parallel whole-screen visual renderer。
3. Visual review把runtime「layout health」與runtime「design fidelity」混為同一PASS。

## Design Alternatives

### A — Single widget tree with design-space geometry projection（採用）

```txt
accepted source.pen
→ one visual component model
→ one Flutter widget tree
→ design-space geometry projection
→ canonical / phone / narrow runtime
```

`941 × 1672`只作design/comparison space。標準手機viewport先以width-derived uniform design scale投影visible geometry；高度不足時允許scroll，不為了塞入viewport而壓縮整體比例。只有內容、localization、text scaling、orientation或極窄width真的要求時，才在同一component tree內啟用明確的responsive adaptation。

優點：runtime與canonical不可分叉逃避fidelity；可保留真Flutter widgets、semantics與asset ownership；最符合目前`.pen`就是手機稿的事實。

### B — Top-level `FittedBox`／`Transform.scale`（拒絕）

把941×1672整張Flutter canvas縮成360×640可以快速接近圖片，但會同時縮小touch targets、semantics geometry與文字，並掩蓋真實layout問題。這等同把UI當成可縮放海報，不符合模板的runtime與accessibility contract。

### C — Canonical renderer + separate runtime renderer（拒絕）

這是目前已失敗的設計。即使兩邊各自有tests，也允許canonical branch專門服務pixel diff、runtime branch自由重設計，造成「測試PASS但產品FAIL」。Corrective workflow明確禁止。

## Single Visual Component Model

一個accepted Pencil screen只能有一組視覺責任元件：

```txt
WritePrecheckScreen
├─ Header
├─ Progress
├─ Hero
├─ Summary
├─ Results
├─ Records
├─ Guidance
└─ Actions
```

Canonical與runtime不得各自定義另一組整頁widgets。允許的差異只能由component-level layout policy產生，例如：

- width／height／offset／padding／gap／radius／icon size依design scale投影。
- 高度不足時使用同一screen的scroll contract。
- localizable text超出預期時，由同一text component換行／調整，而不是切到另一套頁面。
- text scale／accessibility需要時，允許同一component tree切換content-aware layout，但必須保留相同visual identity與section order。
- 極窄width需要Row→Column時，轉換發生在該component內，不能替換整頁renderer。

## Design-space Projection

### Coordinate model

Primary design width：

```txt
designWidth = 941
designHeight = 1672
```

標準portrait runtime先由：

```txt
visualScale = availableWidth / designWidth
```

投影Pencil visible geometry。這個scale用於真Flutter primitive的數值計算，不使用top-level `Transform.scale`或`FittedBox`。

例如：

```txt
Pencil horizontal inset 37
→ runtime inset = 37 × visualScale

Pencil card radius 24
→ runtime radius = 24 × visualScale
```

Canonical viewport的`visualScale = 1.0`；BlueStacks 360 logical width約為`0.3826`。

### What scales

在normal text scale與同方向portrait proof中，以下visible geometry以同一design scale為基準：

- frame／card／button visible bounds。
- padding、gap、offset與decorative geometry。
- radius、stroke、shadow extent與glow geometry。
- icon visible size與position。
- feature-local typography size／line-height／letter-spacing，除非平台font metrics需要經reviewed local correction。

### What does not become a blind scale

- Semantics hit region與interactive minimum target可以大於visible bound，不必跟著縮到不可操作。
- 使用者text scale > 1或accessibility mode時，文字不能被鎖死成圖片比例；同一component必須content-aware。
- 高度不足不使用vertical squeeze；保持width-derived比例並scroll。
- Design System token ownership不因projection改變：能準確映射既有owner仍使用既有owner，Pencil-specific exact values仍feature-local。

## Design System / Theme / Asset Ownership

Corrective不改變Milestone 33已建立的owner順序：

```txt
existing ColorScheme／DsSemanticColors
existing DsSpace／DsRadius
feature-local visual specification
generated localization
approved icon／asset owner
feature-local widgets／Flutter primitives
```

要求補強的是：**owner mapping完成後，canonical與runtime必須共享同一owner與同一component。**

- 不得canonical使用Pencil exact cyan、runtime改用另一套「比較適合手機」的任意顏色。
- 不得canonical使用某個card structure、runtime另造不同container hierarchy。
- 真實content image仍走repository asset architecture；design preview／golden／diff不能進production當整頁image。
- 沒有第二consumer evidence，仍不得把單頁數值升成全域Design System token。

## Visual Acceptance Contract

### Two distinct gates, same renderer

```txt
Gate A — Canonical fidelity
941 × 1672 Flutter render
→ Pencil canonical reference
→ deterministic diff

Gate B — Runtime fidelity
same Flutter widget tree at supported runtime viewport
→ Pencil-derived runtime projection reference
→ runtime-sized golden／diff
→ actual Android screenshot
→ semantic side-by-side review
```

Gate B不能只以scroll／no-overflow代替。

### Runtime reference derivation

因accepted `.pen`本身就是手機稿，不建立第二份mobile `.pen`。Runtime expected reference由manifest固定的canonical Pencil preview透過**事先固定、顯式、可重現**的projection產生：

- 目標viewport、scale、resampling algorithm與hash在candidate comparison前固定。
- 這是`derived runtime reference`，不是新的visual authority。
- 禁止在candidate失敗後臨時resize、crop或改algorithm。
- 360×640與941×1672比例近似一致時，reference以width-derived uniform projection為主；若實際viewport aspect ratio不同，Design／Plan必須預先定義letterbox／scroll／crop contract，不得由implementation猜測。

### Required runtime evidence

- Flutter golden至少涵蓋canonical與primary supported mobile viewport。
- Android runtime screenshot必須使用同一production widget tree。
- Android screenshot semantic review必須做reference／candidate side-by-side，不得只記錄「無overflow」。
- 自動化必須有single-renderer architecture guard，發現whole-screen breakpoint替換renderer時fail。
- Pixel PASS不能覆蓋使用者或reviewer提出的semantic P1；新的P1立即撤銷對應visual acceptance直到fresh review。

## Testing Strategy

Implementation必須先以TDD讓current 1.15.0 source正確RED：

1. Architecture test：拒絕`WritePrecheckView`依整頁breakpoint替換`WritePrecheckCanonicalCanvas`／另一套root renderer。
2. Component identity test：canonical與runtime都包含同一組section／visual component types。
3. Runtime visual golden：在primary Android logical viewport重現同一screen visual geometry。
4. Runtime projection diff：固定runtime derived reference與threshold後比較。
5. Existing canonical diff：不得因corrective而退化。
6. Existing 390×844／226×400 no-overflow與semantics tests保持GREEN，但降回layout-health responsibility，不再冒充visual fidelity。
7. Android integration screenshot：使用production route／widgets，side-by-side semantic review必須明確判斷hierarchy、proportion、typography、icons、spacing、states與content completeness。

## Skill and Guide Correction

`implementing-pencil-flutter-design`必須新增hard rules：

- Pencil canonical size是design/comparison space，不得直接當Flutter logical breakpoint。
- 一個accepted screen不得以breakpoint切換到parallel whole-screen visual renderer。
- Fidelity要求同時涵蓋canonical與supported runtime；runtime no-overflow只是layout-health gate。
- Design-space projection必須使用真widgets的geometry mapping，不是top-level fixed-canvas scaling。
- Runtime reference derivation必須在candidate前固定並記錄，不得silent resize。

`docs/guides/pencil_to_flutter_workflow.md`同步同一規則，但Guide只負責human usage，不取代Skill／ADR authority。

## ADR-028 Amendment Boundary

ADR-028需要amend以下stable decisions：

1. Visual acceptance必須涵蓋same-renderer canonical與supported runtime fidelity。
2. Canonical Pencil viewport是design/comparison space，不是Flutter logical breakpoint。
3. Parallel whole-screen visual renderer屬architecture violation。
4. Explicit derived runtime projection reference可以作evidence，但不得升格為`.pen` authority或在candidate後改變。

Canonical ADR修改在Corrective Plan accepted後執行，避免Design階段直接改accepted stable authority。

## Release and Rollback

- `1.15.0`已發布，不rewrite、不force push、不刪除歷史evidence。
- Corrective implementation完成前，Milestone 33 capability維持`corrective active`，不得提交目前dirty的`Completed / Archived` closure routing。
- Corrective成功且人工runtime驗收通過後，Final Review決定patch release；預期`1.15.1`。
- 若single-renderer proof無法同時達成canonical與runtime fidelity，workflow capability不得重新宣稱completed；可回退proof implementation，但保留corrective governance evidence。

## Success Criteria

- Production source不存在canonical／mobile整頁雙renderer。
- 同一accepted `.pen`、同一component tree、同一visual owner model驅動941×1672與360×640。
- 360×640 runtime在視覺上是同一手機稿的比例／responsive投影，不是重新設計版。
- Canonical fixed diff仍通過，runtime visual gate新增並通過。
- Android實際畫面由使用者重新驗收通過；未通過時自動化PASS不能closure。
- Skill／Guide／ADR明確禁止本次漏洞再次發生。
- Full repository regression、Android build/runtime、clean-checkout與post-release validation全部通過後才能重新封存Milestone 33。

## Approval Gate

本Corrective Design已完成Design focused review、fresh re-review、whole-Design review與documentation validation，並於2026-08-07取得使用者對書面Corrective Design與ADR-028 amendment draft的明確核准，狀態為`accepted`。Corrective Implementation Plan仍須獨立完成雙層治理與使用者核准後，才能開始implementation。
