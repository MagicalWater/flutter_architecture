---
document_type: implementation-plan
status: accepted
authoritative_for:
  - milestone-44-post-closure-color-ownership-adoption-corrective-plan
last_reviewed_baseline: 1.23.0
---

# Milestone 44 Post-closure Corrective C1 — Color Ownership Adoption — Implementation Plan

## Status

**Accepted — 2026-08-19 使用者明確核准。**

Accepted Design：`docs/superpowers/specs/2026-08-19-milestone-44-post-closure-color-ownership-adoption-corrective-design.md`。

## Execution boundary

本Plan只修正M44 color ownership production adoption omission。它不重開M44 layout corrective，也不處理asset／l10n／general magic code，不修改Theme／Design System、accepted `.pen`、golden、threshold、crop或ignore regions。

所有production implementation在Plan取得使用者明確核准後，於managed worktree執行。Main只保存已核准planning authority與最終promotion／closure。

## Test Authoring Decision

- Disposition：**Required**。
- Primary owner：`apps/flutter_architecture/test/features/pencil_compatibility/presentation/write_precheck_architecture_contract_test.dart`。
- Direct failure：`WritePrecheckPalette`已宣告shared color value，但Write Precheck consumer仍直接`Color(<same value>)`。
- Positive control：consumer使用未被palette宣告的component-local exact color必須保持合法。
- 禁止：all-raw-color ban、literal-count oracle、near-RGB heuristic、snapshot-only regression。

## Ordered Tasks

### C1-1 — Direct palette-bypass RED

**Goal**：先用current production重現deterministic owner-bypass failure，避免先修production再補test。

Implementation：

1. 在Write Precheck focused architecture test加入最小source policy helper：
   - 解析`write_precheck_palette.dart`的`static const Color <name> = Color(<value>)`；
   - 掃描Write Precheck consumer sources；
   - 排除palette owner source；
   - 若consumer直接出現palette已宣告的exact ARGB literal，回報`shared palette literal bypass`。
2. 建立positive control，證明未在palette宣告的local exact color不會被拒絕。
3. RED必須由current `0xFF7F94A7` bypass觸發；不得先新增新palette entries造成混雜RED。

Focused validation：

- `flutter test test/features/pencil_compatibility/presentation/write_precheck_architecture_contract_test.dart`
- 預期：新增direct case RED，其餘existing controls維持GREEN。

Completion evidence：`docs/audits/milestone_44/44-c1_1_palette_bypass_red_review.md`。

### C1-2 — Semantic inventory and palette ownership adoption

**Goal**：依accepted Design把risk-selected shared solid roles收斂到既有`WritePrecheckPalette`，同時保留local decoration。

Production changes：

1. `WritePrecheckPalette`新增exact-value roles：
   - `goldAccent = 0xFFF5B941`
   - `blueAccent = 0xFF3DAEFF`
   - `cyanAccent = 0xFF74D8FF`
   - `subtleOutline = 0xFF244056`
2. `dim = 0xFF7F94A7`維持既有owner。
3. 對上述shared solid values逐consumer review並改用palette reference。
4. `0xFF0C1A2A`等single-component surface、gradient stop、glow/shadow alpha、artwork exact values維持local，除非實際usage證據證明其shared role。
5. 不改ARGB bytes、不改component geometry、不改copy／asset／l10n。

Required inventory evidence至少記錄：

- value；
- consumer owners；
- shared/local disposition；
- rationale；
- final production owner。

Focused validation：

- `write_precheck_copy_test.dart`
- `write_precheck_architecture_contract_test.dart`（此時可能仍RED，直到C1-3完成consumer收斂）
- `git diff --check`

Completion evidence：`docs/audits/milestone_44/44-c1_2_color_ownership_adoption_review.md`。

### C1-3 — Machine GREEN and anti-formalism proof

**Goal**：讓direct regression owner對production GREEN，同時證明沒有退化成raw-color blanket ban。

Actions：

1. 完成所有已宣告palette value的consumer bypass清理。
2. 跑direct architecture contract，確認zero bypass finding。
3. 保留positive fixture：local exact color未宣告於palette時PASS。
4. 加入或保留negative fixture：palette已宣告value被consumer直接literal重寫時FAIL。
5. 不新增global color scanner或repository-wide all-literal policy。

Focused validation：

- Write Precheck architecture contract PASS。
- Presentation responsibility architecture contract PASS。
- Write Precheck copy/palette contract PASS。

Completion evidence：`docs/audits/milestone_44/44-c1_3_machine_green_review.md`。

### C1-4 — Visual identity and affected regression

**Goal**：證明ownership migration不改visual bytes或M44 layout主責。

Validation：

1. Pencil canonical golden。
2. Pencil 360×640 runtime golden／diagnostic owner。
3. Write Precheck responsive／semantics／copy相關suite。
4. Presentation architecture contract。
5. Fresh scan確認：
   - no public normal-content `left/top` regression；
   - no generic positioned content helper regression；
   - accepted `.pen`／manifest／mapping／golden authority沒有被修改。
6. `tools/ci/validation_planner.py`對implementation range取得exact affected validation並完整執行。

若visual diff出現，必須修production ownership migration；禁止改golden、threshold、crop、ignore regions取得PASS。

Completion evidence：`docs/audits/milestone_44/44-c1_4_visual_regression_review.md`。

### C1-5 — Holistic post-closure corrective review and release decision

**Goal**：完整回答「M44哪些claim維持、哪個closure overclaim被C1更正、是否需要新Template Baseline」。

Whole-corrective review至少確認：

- ADR-018 stable authority unchanged且production adoption現在一致；
- shared palette沒有變成mega visual spec；
- intentional local/decorative colors仍被保留；
- machine rule能抓owner bypass且不抓合法local literal；
- M44 layout closure仍有效；
- asset／l10n／general magic code沒有被偷渡；
- current authority與audit routing同步；
- Open P0=0；Open P1 without disposition=0。

Release decision：依`CHANGELOG.md` version policy、planner classification與production/governance impact fresh決定。若不release，記錄bounded post-closure corrective closure；若release，建立獨立release/post-release Task，不得在C1-5冒充published evidence。

Completion evidence：`docs/audits/milestone_44/44-c1_5_holistic_final_review.md`。

## Commit boundaries

每個Task完成focused review、fresh re-review、whole-Task review與required validation後獨立commit。建議：

```txt
C1-1 test(m44): 建立共享色票繞過RED
C1-2 refactor(ui): 收斂Write Precheck共享色彩所有權
C1-3 test(m44): 封鎖共享色票literal繞過
C1-4 test(ui): 驗證Write Precheck色彩遷移視覺一致
C1-5 docs(m44): 完成色彩所有權採用修正審查
```

實際subject可依Task diff微調，但不得把多個未review Task壓成單一completion commit。

## Stop conditions

只有以下情況停止並要求使用者決策：

- inventory證明accepted Design的shared/local classification需要實質改寫；
- 必須修改ADR-018 stable decision才能修正；
- 發現Theme/Design System production misuse使scope需升級；
- 發現M44 primary layout closure本身被新的P0/P1 evidence推翻；
- external/manual blocker。

一般test failure、golden implementation regression、stale docs或consumer漏改直接修正並fresh re-verify，不停下詢問。

## Final validation principle

Plan不預先要求full workspace regression。Exact matrix由implementation range的`tools/ci/validation_planner.py`決定；visual authority與direct architecture owners屬Design明確required，即使planner最小集合較小仍須執行。

## Approval gate

本Plan需完成focused review、fresh re-review與whole-Plan review，並取得使用者明確核准後才可建立managed implementation worktree與修改production source。

