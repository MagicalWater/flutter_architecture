---
document_type: implementation-plan
status: accepted
authoritative_for:
  - milestone-43-presentation-component-architecture-implementation-plan
last_reviewed_baseline: 1.21.0
---

# Milestone 43 — Flutter Presentation Component Architecture & UI Responsibility Governance Implementation Plan

## 1. Admission

```txt
Requirement: accepted
Design: accepted / user approved 2026-08-18
Plan: accepted / user approved 2026-08-18
Implementation: admitted
Managed worktree: C:\Users\crazy\.devspace\worktrees\flutter_architecture-19147ec6
Branch: milestone-43-presentation-component-architecture
Design approval commit: 538b139 + approval-state corrective 9377848
```

本Plan已於2026-08-18取得使用者明確核准，現在是Milestone 43 implementation的accepted execution authority。Plan approval以前未修改production source、ADR canonical authority、machine detector或Skills；核准後依43-1起按Task順序執行。

## 2. Execution strategy

固定順序：

```txt
43-1 direct RED / representative responsibility fixtures
→ 43-2 ADR-032 + current architecture authority GREEN
→ 43-3 high-confidence machine contract GREEN
→ 43-4 Pencil reference library/cohesion decomposition
→ 43-5 ordinary-feature representative adoption + positive no-refactor proofs
→ 43-6 consumer Skills / human guide / behavioral pressure
→ 43-7 holistic validation + release candidate
→ 43-8 merge / push / published-main / post-release closure
```

每個implementation Task採Level 4 full two-layer governance：focused review → findings → fix → fresh focused re-review → whole-Task review → authority check → planner-selected validation → P0=0 / undisposed P1=0 → independent completion commit。

不得為了方便平行執行而打亂依賴順序。43-2以前不改production；43-3建立穩定enforcement後才開始43-4/43-5 source adoption。

## 3. Task 43-1 — Direct RED：重現兩端Presentation治理盲點

### Goal

用最小focused fixtures證明current repository不能可靠阻止以下兩端錯誤：

1. Page/View owner同時承擔route orchestration、bounded sections與custom RenderObject/layout engine；
2. 以`part`／`part of`物理拆檔但仍把不同owner綁成同一handwritten library；
3. one-widget-one-file／class-count／line-count形式治理；
4. local UI state被無條件升成Cubit；
5. Shell surface launcher與surface implementation owner混淆；
6. single-consumer feature component被無條件promotion Design System。

### Primary files

- `apps/flutter_architecture/test/architecture/`或existing最接近的presentation architecture test owner
- existing Pencil architecture contract tests（只保留Pencil-specific responsibilities，不把generic contract塞回Pencil fixture）
- 必要的fixture source under test-only scope
- `docs/audits/milestone_43/43-1_presentation_architecture_red_review.md`

### Test Authoring Decision

**Required**。Milestone 43新增repository-wide architecture failure modes；只有review prose不足以防止future regression。

### RED contract

- mixed Page/View + RenderObject/layout owner fixture → FAIL；
- cross-responsibility handwritten `part` fixture → FAIL；
- cohesive single-file small feature fixture → PASS；
- cohesive private helper classes fixture → PASS；
- local expand/collapse / controller fixture → PASS，不要求Cubit；
- launcher owner與surface implementation owner分離fixture → PASS；
- 不使用line count、class count、folder existence作判定。

### Stop condition

若RED只能靠高false-positive命名／行數heuristic建立，回Design；不得把semantic problem偽造成mechanical lint。

## 4. Task 43-2 — ADR-032 與 current Presentation authority GREEN

### Goal

建立單一stable repository-wide Presentation architecture authority，讓後續source與machine work有canonical contract。

### Primary files

- 新增 `docs/adr/adr-032-presentation-component-responsibility-state-ownership.md`
- `docs/adr/README.md`
- `AGENTS.md`（只放fresh admission需要的短版contract）
- 建立或更新current human architecture guide
- `docs/project_context.md`
- `docs/audits/milestone_43/43-2_presentation_authority_review.md`

### Required contract

ADR-032必須包含：

- Page/View/Section/Component/Surface/Layout為responsibility roles，不是mandatory class tree；
- one handwritten source file = one coherent primary responsibility；
- same library中的`part`不可掩蓋cross-owner coupling；
- modal invocation owner與surface implementation owner分離；
- Shell/Tab/Navigation orchestration boundary；
- local State/Hook/controller → lifted presentation owner → Cubit/Bloc → cross-feature/domain escalation sequence；
- private helper合法條件與extract signals；
- feature-local → Design System promotion沿用ADR-018；
- explicit anti-formalism：無fixed folder tree、無widget/class/line oracle、無Bloc-everywhere。

### Test Authoring Decision

Policy/ADR文字本身`Should-not-add` class-level tests；由43-1/43-3 machine contract與43-6 behavioral pressure作direct owner。

## 5. Task 43-3 — High-confidence machine contract GREEN

### Goal

只把可可靠機械判定的Presentation invariants轉成repository-owned detector/test；semantic cohesion仍交給review pressure。

### Primary files

- 43-1 test owner與fixture
- 必要時新增最小presentation architecture checker/helper
- existing docs/policy tests（若需authority routing consistency）
- `docs/audits/milestone_43/43-3_machine_contract_review.md`

### Machine-enforced invariants

允許hard fail：

- 已宣告Page/View orchestration owner直接宣告custom RenderObject/MultiChildRenderObjectWidget infrastructure；
- representative source以handwritten `part`掩蓋已分離responsibility owner；
- current authority/consumer routing遺失ADR-032；
- existing Milestone 42 anti-catch-all contract回歸。

不得hard fail：

- 檔案超過N行；
- class/widget超過N個；
- feature沒有固定`pages/widgets/components`目錄；
- 使用`setState`、Hook、Controller；
- 沒有Bloc/Cubit；
- private helper未拆檔。

### Test Authoring Decision

**Required**，43-1 RED轉GREEN並保留positive controls防false positive。

## 6. Task 43-4 — Pencil reference library / cohesion decomposition

### Goal

以已知最嚴重reference證明responsibility contract可實際改善source，而不是只增加文件。

### Primary scope

- `apps/flutter_architecture/lib/features/pencil_compatibility/presentation/widgets/write_precheck/write_precheck_content.dart`
- `apps/flutter_architecture/lib/features/pencil_compatibility/presentation/layout/write_precheck_projection.dart`
- 依focused review需要建立的bounded section/component/layout files
- existing Pencil architecture/golden/runtime tests
- `docs/audits/milestone_43/43-4_pencil_reference_decomposition_review.md`

### Required changes

- 移出真正independently reviewable sections/components；
- 若projection是獨立layout owner，解除cross-owner handwritten `part of`並形成normal Dart library boundary；
- Page/View保持orchestration；
- bounded projection/layout mechanics保持Milestone 41 invariants；
- 不為file count而拆private helpers；
- 不新增fake Domain/Data/Bloc；
- 不修改accepted `.pen`、golden、threshold或visual authority來迎合refactor。

### Test Authoring Decision

預設`no-new-test justified`，以43-3 architecture owner + existing Pencil visual/runtime owners為primary；若decomposition揭露新的observable failure mode，再新增最小direct regression。

## 7. Task 43-5 — Ordinary feature adoption + positive no-refactor proofs

### Goal

證明ADR-032適用一般Flutter feature，而且不會把所有UI變成碎檔與Cubit。

### Reference A — Catalog

- `CatalogPage`保留自己的Bloc binding、screen-level effects、ScrollController；
- focused review cache/reconnect presentation semantics是否已形成獨立bounded owner；只有確實獨立change reason才extract；
- 不改Catalog domain/data/state-machine behavior；
- 禁止新增`CatalogScrollCubit`之類形式抽象。

### Reference B — OTP positive no-refactor

- 保留countdown Timer + local `setState`／widget lifecycle ownership；
- 明確記錄為符合ADR-032的positive result，除非fresh review發現observable bug。

### Reference C — Shell positive ownership

- 保留Shell作Appearance/Locale/Local Unlock surface launcher；
- surface implementation維持各app presentation owner；
- `ShellPage + ShellScaffold`只有在fresh review找到不同lifecycle/change reason P1時才拆，不能為class/file對稱硬拆。

### Primary evidence

- source changes只限fresh review判定真正需要的owner extraction
- representative architecture tests/fixtures
- `docs/audits/milestone_43/43-5_generic_feature_adoption_review.md`

### Test Authoring Decision

Source refactor若不改observable behavior採`no-new-test justified`；positive no-refactor案例不新增無價值class tests。Existing Catalog/Auth/Shell tests + 43-3 architecture tests為primary validation owners。

## 8. Task 43-6 — Consumer Skills / human guide / fresh behavioral pressure

### Goal

讓future Agent從既有入口能使用ADR-032，且同時拒絕monolith與formalism。

### Primary files

- `.agents/skills/starting-feature-work/SKILL.md`
- `.agents/skills/implementing-pencil-flutter-design/SKILL.md`及必要reference
- current human architecture/feature guide
- `AGENTS.md`如43-2後fresh discovery證明摘要仍不足才做最小補強
- `governing-template-development`僅在fresh discovery evidence證明中央routing找不到authority時做最小routing amendment；否則不改
- `docs/audits/milestone_43/43-6_behavioral_pressure_review.md`

### Behavioral pressure

至少fresh驗證Design列出的12種scenario，包含：

- Page monolith → FAIL；
- one-widget-one-file → FAIL；
- static screen強建Cubit → FAIL；
- local expand/collapse → local；
- Shell launcher / Theme Dialog implementation分owner → PASS；
- ScrollController local + Bloc load-more transition → PASS；
- decorative AnimationController local → PASS；
- `part of`假拆owner → FAIL；
- single-consumer DS promotion → FAIL；
- cohesive private helpers → PASS；
- single-file small feature → PASS；
- 新增專用Presentation governance Skill並複製ADR → FAIL。

### Skill governance

若修改Skills，套用existing Skill adoption governance與fresh behavioral validation；不得建立新的Presentation domain Skill。

## 9. Task 43-7 — Holistic validation / release candidate

### Goal

確認Milestone 43跨ADR、source、machine enforcement、Skills與docs形成同一authority，且沒有以visual/behavior regression換architecture GREEN。

### Required review

- Requirement → Design → Plan → Task evidence traceability；
- ADR-003/007/018/021/028/032無authority衝突；
- Pencil + Catalog + OTP + Shell representative adoption一致；
- no fixed-folder / line-count / Bloc-everywhere formalism；
- visual authority與Design System ownership不回歸；
- repository current docs/roadmap/index一致；
- Open P0=0 / undisposed P1=0。

### Validation

- `tools/ci/validation_planner.py`針對milestone range產生plan；
- planner-selected affected/workspace validations；
- Level 4 holistic fresh full regression ceiling；
- Android/iOS等release-required platform gates依current release governance執行。

### Release decision

預期為Template Baseline **1.22.0**，因新增stable repository-wide architecture capability；actual release identity在43-7 holistic review依current authority與validation結果正式拍板，不在Plan階段冒充已發布。

## 10. Task 43-8 — Publication / published-main / post-release closure

### Goal

只有43-7 accepted後才執行branch finishing、merge、push、published-main fresh verification與closure。

### Required actions

- 更新`VERSION`／`CHANGELOG.md`／current roadmap與project context；
- merge/push依repository release governance執行；
- fresh fetch確認`main == origin/main == published SHA`；
- published-main重跑required regression / platform verification；
- fresh behavioral acceptance證明published authority仍能拒絕monolith與formalism；
- 建立`docs/audits/milestone_43/43-8_post_release_validation.md`；
- closure後把Milestone 43移入closed routing。

Release identity不等於closure；post-release evidence PASS前不得宣稱Milestone完成。

## 11. Cross-Task guardrails

整個Plan禁止：

- fixed Presentation folder template；
- widget-per-file／class-per-file規則；
- line-count/class-count architecture oracle；
- 所有screen強制Bloc/Cubit；
- 所有ephemeral UI state提升Cubit；
- 為了Milestone 43全面重構所有features；
- 建立generic Presentation framework package；
- 新增專用Presentation governance Skill；
- 重做Milestone 41/42 accepted visual/design ownership；
- 以更新golden/threshold/accepted `.pen`掩蓋source refactor regression。

## 12. Plan approval gate

此Plan目前為`proposed`。完成Plan focused review、findings修正、fresh re-review、whole-Plan review並取得使用者明確核准前，不得開始Task 43-1 implementation。

