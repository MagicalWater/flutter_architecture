---
document_type: implementation-plan
status: accepted
authoritative_for:
  - milestone-44-pencil-component-constraint-semantics-implementation-plan
last_reviewed_baseline: 1.22.0
---

# Milestone 44 — Pencil Component Constraint Semantics Corrective Implementation Plan

## 1. Admission

```txt
Requirement: accepted / Level 4
Design: accepted / user approved 2026-08-19
Plan: accepted / review PASS / user approved 2026-08-19
Implementation: ADMITTED
Repository: template
Branch: main
Fresh main == origin/main == a7ffeb9ac6d9f5bd0c224dcfa004d77370772be0
VERSION: 1.22.0
Working tree at admission: clean
Managed worktree: create after this acceptance-state sync
```

本 Plan 只執行已核准 Design 的主責：**component-local fixed-canvas laundering corrective**。本 Plan 已於2026-08-19取得使用者明確核准；implementation正式admitted，後續只可依本 Plan 的Task順序修改production source、stable ADR authority、consumer Skill contract與machine enforcement。

## 2. Execution strategy

固定順序：

```txt
44-1 direct RED / machine contract boundary
→ 44-2 stable ADR + consumer governance GREEN
→ 44-3 write_precheck responsibility decomposition + relationship-layout corrective
→ 44-4 legal spatial overlay preservation + visual/runtime fidelity
→ 44-5 behavioral pressure + same-semantic color bounded hardening
→ 44-6 holistic final review + release disposition
→ 44-7 publication / published-main / post-release closure（若44-6決定release）
```

每個 implementation Task 都採 Level 4 full two-layer governance：

```txt
implement/create
→ focused review
→ findings
→ fix
→ fresh focused re-review
→ whole-Task review
→ documentation authority check
→ validation planner
→ planner-selected validation
→ Open P0 = 0
→ Open P1 without disposition = 0
→ independent completion commit
→ next Task
```

若 Task 修改 observable behavior，先記錄 Test Authoring Decision；`0 new tests` 不等於 `0 validation`。不得把 visual fidelity failure、ordinary test failure或 stale docs當成停下詢問的理由；除非出現需使用者決定的scope/architecture decision、external/manual blocker或會推翻accepted Design的P0/P1。

## 3. Task 44-1 — Direct RED：component-local fixed-canvas laundering machine boundary

### Goal

在任何 production corrective 前，以最小 direct contract 重現 current loophole，並同時建立合法 bounded overlay positive control，避免把 M44 寫成 `Stack/Positioned` 全禁規則。

### Pre-execution admission

Plan accepted 後才建立 managed worktree／branch，並 fresh 驗證：

- base SHA仍與 Plan acceptance authority一致；
- worktree clean；
- accepted Design、Plan、visual manifest與repository-local Skill route可讀；
- production source尚未因其他工作漂移；若已漂移，先做fresh impact disposition，不直接套舊RED。

### Primary files

- `apps/flutter_architecture/test/architecture/presentation_responsibility_contract_test.dart`
- `apps/flutter_architecture/test/architecture/support/presentation_architecture_policy.dart`
- `apps/flutter_architecture/test/features/pencil_compatibility/presentation/write_precheck_architecture_contract_test.dart`
- 必要的 test-only representative fixture
- `docs/audits/milestone_44/44-1_component_constraint_red_review.md`

### Test Authoring Decision

**Required**。M44新增一個current machine blind spot：screen root 已 relationship-owned，但 bounded component 仍可把 normal content 轉成local canonical canvas。這個failure mode需要直接 regression owner。

### RED contract

至少建立以下互斥 controls：

1. screen `Column` + bounded component public API以`left/top`排列普通 Text/DataRow/Button → **FAIL**；
2. generic `_positionedText`／`_localText` helper承擔普通content placement → **FAIL target**；
3. normal data row以`Row + Expanded/Align + Padding`表達 → **PASS**；
4. Hero由screen flow放置，Hero內badge/glow/ornament使用bounded `Stack/Positioned` → **PASS**；
5. accepted spatial canvas具approval reference →沿既有ADR-028 contract **PASS**；
6. 不使用Positioned count、file line count、widget/class count或folder existence作oracle。

### Machine rule design constraint

Machine owner只hard-fail能高confidence判定的結構。若實作只能靠「一檔超過N個Positioned」或「任何left/top字樣」才能RED，Task維持open並回Design review；不得用false-positive heuristic冒充semantic governance。

## 4. Task 44-2 — Stable ADR + consumer governance GREEN

### Goal

先把M44已核准的stable semantics同步到唯一current authority，再讓44-1 RED轉為可持續GREEN contract。此Task不修改`write_precheck` production layout。

### Primary files

- `docs/adr/adr-028-repository-local-pencil-to-flutter-design-implementation-workflow.md`
- `docs/adr/adr-032-presentation-component-responsibility-state-ownership.md`（只補normal-content relationship ownership review question／bounded laundering prohibition所需最小內容）
- `docs/adr/adr-018-design-system-theme-boundaries.md`（只做same-semantic color bounded reconciliation clarification；若無必要可保持source不變並記no-change disposition）
- `.agents/skills/implementing-pencil-flutter-design/SKILL.md`
- `.agents/skills/implementing-pencil-flutter-design/references/flutter-mapping.md`
- `tools/docs/test_pencil_single_renderer_policy.py`與必要policy owner
- 44-1 machine test owner
- `docs/project_context.md`／必要current authority summary
- `docs/audits/milestone_44/44-2_constraint_authority_review.md`

### Required stable contract

- bounded component不是fixed-canvas laundering boundary；
- normal content relationships即使在bounded component內仍由constraints/parent-child relationships擁有；
- `Stack/Positioned`只對genuinely spatial/overlay semantics合法；
- `WritePrecheckProjection`類measurement projection可保留size/gap/radius/stroke/icon/artwork sizing，但不得授權normal content的canonical x/y placement；
- ADR-032仍以change reason/responsibility治理，不加入line-count或mandatory folder taxonomy；
- Flow/Coordinator維持future candidate，不建立role/framework/folder/machine contract；
- same-semantic color只補representation-noise → semantic-role → intentional contextual variant → decoration的裁決順序，不藉機改Theme/Design System production source。

### Test Authoring Decision

Policy文字本身 **Should-not-add class-level tests**；44-1 direct architecture owner與既有docs policy tests負責machine evidence。若ADR/Skill routing新增可直接機械驗證的stable phrase/route，僅補最小policy test。

## 5. Task 44-3 — write_precheck responsibility decomposition + relationship-layout corrective

### Goal

修正current production evidence：major section雖已由screen flow排列，但section/component內普通UI仍以canonical `Positioned(left/top/width/height)`為主。以**change reason**拆出bounded owners，再逐owner改成relationship-first layout。

### Primary scope

- `apps/flutter_architecture/lib/features/pencil_compatibility/presentation/widgets/write_precheck/write_precheck_content.dart`
- `apps/flutter_architecture/lib/features/pencil_compatibility/presentation/widgets/write_precheck/write_precheck_content_components.dart`
- `apps/flutter_architecture/lib/features/pencil_compatibility/presentation/layout/write_precheck_projection.dart`
- 依責任真正形成的section/component files（不預先規定固定folder/class清單）
- existing write-precheck widget/geometry/architecture tests
- `docs/audits/milestone_44/44-3_write_precheck_relationship_layout_review.md`

### Responsibility decomposition rule

以獨立產品語意與change reason判斷owner，例如Header、Progress、Hero、Summary、Results、Records、Guidance、Actions、Footer可成為候選，但**不是mandatory taxonomy**。同lifecycle、同change reason、沒有獨立authority的private helpers可共檔；不以1354行或任意行數作拆檔理由。

### Required production changes

- screen root只負責screen content composition與major section flow；
- normal labels/values/rows/buttons/card content改由`Padding`、`Align`、`Row`、`Column`、`Flex`、`Expanded`、`Spacer`、`Wrap`、constraints與parent-child relationships表達；
- `WritePrecheckStep`不得再以public `left/top`決定step placement；step序列應由relationship layout分布；step內真正glow/circle/glyph layering可保留bounded overlay；
- `WritePrecheckDataRow`不得再以`top`與多個absolute columns排列label/value；row owner改用relationship layout；
- `WritePrecheckRecordTile`的title/value/badge/chevron以row/column/alignment relationship擁有；只有真正ornament/spatial layer保留Positioned；
- `WritePrecheckSecondaryAction`不得以`left/iconLeft/labelLeft`作normal button composition API；icon/label使用Row/Align/Padding；
- generic `_positionedText`／`_localText`不得再作普通content通用排版引擎；
- `ProjectedComponent`／`ProjectedStack`／custom RenderStack若仍存在，必須收斂到有明確spatial/layout responsibility的smallest owner，不得成為normal component universal canvas。

### Test Authoring Decision

預設 **Required + no-new-test justified mixed disposition**：

- 44-1 direct contract的GREEN是Required；
- 已有widget/geometry/visual owners能充分覆蓋純refactor區塊時，不為每個新file/class新增test；
- 若migration揭露新的observable failure mode（overflow、wrong semantics、wrong touch target、runtime geometry drift等），新增最小direct regression owner。

### Stop condition

若relationship migration必須改accepted `.pen`、改accepted visual identity或推翻M44 Design才能完成，停止並回中央Design gate。不得用visual threshold調整取代implementation修正。

## 6. Task 44-4 — Legal spatial overlay preservation + visual/runtime fidelity

### Goal

證明M44不是「把Positioned全部刪掉」，同時確保architecture GREEN沒有以visual/runtime regression換得。

### Legal overlay review

逐一對remaining `Stack/Positioned`記錄spatial rationale，至少區分：

- ambient glow／ring／ornament；
- badge或需要z-order的local overlay；
- bounded icon/artwork optical adjustment；
- 非spatial normal content（必須回44-3修正）。

沒有可解釋spatial rationale的remaining normal-content coordinate usage → P1，Task不得PASS。

### Visual authority guardrails

嚴格保持：

- accepted `.pen`不修改；
- source hash／visual manifest authority不修改，除非只是recomputed verification證明bytes未變；
- golden threshold、crop、resize/projection algorithm、ignore regions不得為candidate放寬；
- whole-screen visual PASS不能覆蓋critical local FAIL；
- wrong representation一旦被review判定，回representation/provenance，而不是調padding/scale/crop。

### Validation owners

- existing write-precheck widget/geometry tests；
- canonical golden/deterministic diff；
- supported runtime screenshot/fidelity evidence；
- narrow viewport/text scale/no-overflow/semantics作layout-health evidence；
- critical local geometry/representation owners依current visual manifest/mapping執行。

### Test Authoring Decision

若existing visual/runtime owners已完整覆蓋，採 **no-new-test justified**；只有新failure mode或existing owner缺口才新增最小test。Visual evidence仍是必做validation，不因0 new tests省略。

## 7. Task 44-5 — Behavioral pressure + same-semantic color bounded hardening

### Goal

讓future consumer Agent能辨識component-local fixed canvas與合法overlay，並驗證color clarification不膨脹成Theme/Design System refactor。

### Primary files

- `.agents/skills/implementing-pencil-flutter-design/references/pressure-scenarios.md`
- `.agents/skills/implementing-pencil-flutter-design/references/flutter-mapping.md`（若44-2後仍需最小補強）
- `docs/guides/pencil_to_flutter_workflow.md`（只在current human route缺少M44 stable contract時補）
- existing Skill/policy behavioral validation evidence
- `docs/audits/milestone_44/44-5_behavioral_pressure_review.md`

### Required fresh pressure cases

至少新增/驗證：

1. screen Column + component內普通Text/DataRow/Button全部以canonical x/y Position → **FAIL**；
2. component public API以`left/top`排列normal content → **FAIL**；
3. generic positioned-text helper作普通content engine → **FAIL**；
4. DataRow使用Row/Expanded/Align → **PASS**；
5. Hero內badge/glow local Stack/Positioned → **PASS**；
6. 看到大量Positioned就一律禁用 → **FAIL**（合法overlay必須保留）；
7. 因file超長就把每個widget拆檔 → **FAIL**；
8. 要求建立generic Flow framework／mandatory `flows/` → **FAIL / out of scope**；
9. same-semantic CTA只因small RGB drift各建feature color → **FAIL**；
10. near-identical raw colors其實是different semantic roles → **PASS to distinct semantic owners**；
11. intentional single-component decorative exact color → **PASS component-local**；
12. 要求因此重構Theme/Design System production source但無production misuse evidence → **FAIL / scope creep**。

### Skill governance

只更新既有`implementing-pencil-flutter-design` consumer authority；不得新增Flow、Presentation或Color專用governance Skill。若Skill bytes改變，依existing Skill adoption governance做fresh behavioral validation。

## 8. Task 44-6 — Holistic final review / release disposition

### Goal

以Milestone-wide fresh evidence確認M44真正關閉fixed-canvas laundering loophole，且沒有引入formalism、visual regression或scope creep。

### Required holistic review

- Requirement → accepted Design → accepted Plan → Tasks traceability；
- ADR-018/028/032一致且無互相覆蓋authority；
- machine contract能FAIL normal-content local canvas並PASS legal overlay；
- write_precheck major sections與normal content均relationship-owned；
- remaining Stack/Positioned皆有bounded spatial rationale；
- no line-count/folder/widget-count oracle；
- no Flow/Coordinator framework；
- no Theme/Design System production refactor；
- accepted `.pen`與visual comparison contract未漂移；
- visual/runtime/behavioral pressure全部fresh PASS；
- current docs/index/roadmap一致；
- Open P0=0 / Open P1 without disposition=0。

### Validation

先以`tools/ci/validation_planner.py`針對milestone range產生machine plan；執行planner-selected focused/affected/workspace validations。Level 4 holistic另執行fresh full regression ceiling與current release governance要求的平台gate。不得由Agent自行以「應該需要」取代planner output。

### Release disposition

由44-6依actual stable ADR/Skill/machine/production changes決定Template Baseline是否升版與版本號；本Plan不預先冒充release identity。若stable repository-wide architecture contract與production reference均變更，預期需要新Template Baseline，但exact version必須在holistic review依current authority正式決定。

## 9. Task 44-7 — Publication / published-main / post-release closure

### Applicability

只有44-6正式決定release才執行；若44-6明確判定不release，則建立等價final disposition evidence並不得偽造post-release Task。

### Required actions（release時）

- 更新`VERSION`／`CHANGELOG.md`／roadmap／project context與必要milestone indexes；
- branch finishing、merge與push依repository governance；
- fresh fetch確認`main == origin/main == published SHA`；
- clean published-main重跑release-required/full validation；
- fresh Android/iOS或planner/release governance要求的平台verification；
- fresh behavioral acceptance重新驗證local fixed-canvas FAIL與legal overlay PASS；
- 建立`docs/audits/milestone_44/44-7_post_release_validation.md`；
- post-release PASS後才把M44移入closed routing。

Release identity不等於closure；published-main/post-release evidence未PASS前不得宣稱Milestone完成。

## 10. Cross-Task scope ceiling

整個Plan明確禁止：

- generic Flow framework；
- mandatory `flows/` folder；
- 本Milestone新增Flow/Coordinator production responsibility；
- Theme/Design System production refactor；
- 因same-semantic color edge case建立新的mega token system；
- 全面重構歷史Pencil screens；
- 以file length作全面拆檔oracle；
- 禁止所有`Stack/Positioned`；
- 修改accepted `.pen`；
- 放寬golden threshold/crop/ignore region取得PASS；
- 重做Milestone 41～43；
- 為了「有改code」而改本來已符合contract的區域；
- 新增重複的Presentation/Flow/Color governance Skill。

## 11. Plan approval disposition

本Plan已完成focused Plan review、findings disposition、fresh focused re-review與whole-Plan review，review結果PASS，並於2026-08-19取得使用者明確核准。Plan正式轉為`accepted`；44-1 direct RED implementation與managed worktree execution現在admitted，但每個後續Task仍須完成Level 4完整雙層Task governance。

