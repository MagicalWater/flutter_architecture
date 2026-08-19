---
document_type: implementation-plan
status: accepted
authoritative_for:
  - milestone-44-post-closure-project-code-convergence-corrective-plan
last_reviewed_baseline: 1.25.2
---

# Milestone 44 Post-closure — Project Code Convergence Corrective — Implementation Plan

## Status

**Accepted — 2026-08-19 使用者明確核准。**

Accepted Design：`docs/superpowers/specs/2026-08-19-milestone-44-post-closure-project-code-convergence-corrective-design.md`。

## Execution boundary

本Plan只處理fresh audit已證明的四個current convergence gaps：

1. Write Precheck Presentation source responsibility cohesion；
2. risk-selected hard-code／magic-code ownership reconciliation；
3. current `implementation_mapping.json` owner/evidence同步；
4. mapping validator對stale／unsafe evidence reference fail closed。

不reopen M44 primary relationship-layout closure；不改`WritePrecheckPage -> WritePrecheckView`；不建立mandatory `sections/components/dialogs/flow` folder tree；不全面token化exact visual values；不恢復被Milestone 45淘汰的大量architecture/widget tests；不修改VERSION、CHANGELOG或執行release publication。

## Test Authoring Decision

### Presentation / magic-code source convergence

- Disposition：**Should-not-add permanent tests**。
- 理由：責任cohesion、literal rationale與source decomposition主要是review concern；以source-shape test或magic-number scanner永久鎖定會退化成M45已移除的低價值architecture prose test。
- Validation：affected Dart analyze、focused source review、existing runtime/visual evidence只在visual/layout behavior實際改動時執行。

### Mapping validator failure mode

- Disposition：**Required critical automated evidence**，但先以最小temporary/synthetic fixture實作，再做Retention Decision。
- Failure modes：missing evidence path、repository escape、stale deleted evidence仍PASS。
- Positive control：合法repository-relative live evidence維持PASS。
- Retention criteria：若fixture可直接覆蓋shared validator contract且成本低，保留最小permanent test；若CLI synthetic probe已提供同等deterministic coverage且建立test harness成本較高，保留machine fixture/command而不新增獨立test portfolio。

## Ordered Tasks

### PC-1 — Presentation owner cohesion inventory與最小source split

**Goal**：消除已證明的catch-all owner，不把整理退化成一class一檔或folder形式主義。

Actions：

1. Focused review `write_precheck_content_components.dart`：
   - `WritePrecheckStep`
   - `WritePrecheckDataRow`
   - `WritePrecheckRecordTile`
   - `WritePrecheckSecondaryAction`
2. 依product semantics／change reason拆到coherent source owner；若任兩者有fresh cohesive evidence可同檔，review中記錄理由，不為檔案對稱強拆。
3. Focused review `write_precheck_actions_section.dart`、`write_precheck_information_cards.dart`；只有實際出現cross-responsibility owner才拆，不因class數量處理。
4. 更新imports，保持Page/View、layout owner與public behavior不變。

Focused validation：

- affected `dart format`；
- affected package `flutter analyze`／repository既有等價focused analyze；
- `git diff --check`。

### PC-2 — Risk-selected hard-code／magic-code ownership reconciliation

**Goal**：保留合法Pencil exact measurements，同時消除無語意formula與散落state/optical magic code。

Risk signals至少review：

- arithmetic formula，如`40 - iconSize`、`77 + (surfaceWidth - 410) / 2`；
- 重複state-dependent ternary measurements；
- unexplained optical scale／offset；
- 同一bounded component內其實具有derived relationship的獨立literal；
- shared semantic value繞過既有palette/typography owner。

Allowed fixes：

- narrow private constant；
- component-local semantic config/record；
- named derived helper/formula；
- 只有code無法self-explain時才加最小rationale comment/mapping evidence。

禁止：

- `WritePrecheckDimensions`／`VisualSpec`／`MagicNumbers` mega owner；
- repository-wide magic-number lint；
- 為了清literal把ordinary content重新改回`left/top` fixed canvas；
- 把所有component-local colors/dimensions提升Design System。

Focused validation：PC-1 checks + fresh scan確認沒有新增catch-all token/spec owner與normal-content coordinate API。

### PC-3 — Current implementation mapping owner convergence

**Goal**：讓current mapping描述current production identity，而不是M44 refactor前的historical owner names。

Actions：

1. 對`implementation_mapping.json` critical nodes逐一對照current source owner。
2. 修正stale `PrecheckDataRow`／`PrecheckProgress`／`PrecheckRecordTile`／generic secondary action owner等identity。
3. 修正screen layout `evidence_ref`，不得再指向已被M45刪除的`write_precheck_architecture_contract_test.dart`。
4. 優先使用現有schema；若current truth無法表達，停止並回ADR/schema gate，不在Task內偷改stable semantics。

Focused validation：current mapping validator PASS + manual current-owner cross-check。

### PC-4 — Evidence reference fail-closed validator corrective

**Goal**：`pencil_implementation_mapping.py`不得只因`evidence_ref`非空就接受stale reference。

Implementation：

1. 對需要live evidence的resolved mapping加入repository-bound reference resolution。
2. Reject：
   - missing path；
   - path escape repository root；
   - directory/unsupported shape若current contract要求file；
   - deleted stale artifact。
3. Accept：current live repository-relative evidence path。
4. 不建立全repository backlink/reference graph。

RED/GREEN evidence：

- 先建立最小synthetic fixture/probe證明current validator對stale evidence錯誤PASS；
- implementation後同一probe FAIL；
- positive live-reference fixture PASS；
- Retention Decision決定最小critical coverage是否永久保留。

### PC-5 — Whole-scope holistic review與authority sync

**Goal**：證明corrective只修fresh gaps，沒有推翻合法歷史closure或M45 test-by-exception。

Review至少回答：

- source owners是否依responsibility收斂，而非folder/file-count形式主義；
- hard-code是否被分類，不是被機械清零；
- relationship layout是否未退化；
- Page/View split是否保持合法；
- mapping owner/evidence是否與current source一致；
- stale evidence是否machine fail closed；
- 新增test/fixture的Retention Decision；
- ADR-018／028／032是否仍足夠，無需修改stable authority；
- unrelated Generated / Platform Owner Alignment + manual-local release validation corrective未被重做；
- Open P0 = 0；Open P1 without disposition = 0。

Validation：

1. fresh `tools/ci/validation_planner.py`針對實際implementation range取得affected critical validation；
2. 執行planner-selected checks，加上本Plan明確要求的mapping validator synthetic failure/positive evidence；
3. `docs_check`；
4. `git diff --check`；
5. clean authority review。

## Commit boundary

本Level 3 corrective不要求每個PC Task獨立commit。Implementation可在accepted Plan後連續完成，最後經whole-scope holistic review與required validation後形成一個coherent corrective commit；若中途有自然可獨立review/revert的validator boundary，可拆成至多兩個commits，但不得為治理形式增加commit數。

## Stop conditions

只有以下情況停止要求使用者決策：

- 必須修改ADR-018／028／032 stable semantics；
- current mapping schema確實無法表示current owner truth；
- fresh evidence推翻M44 primary relationship-layout closure；
- scope必須升級到repository-wide magic-number／Presentation framework；
- external/manual blocker。

一般compile/test/docs failure、漏改import、stale mapping、review finding直接修正並重驗，不停下詢問。

## Release disposition

本Plan不發布、不升VERSION。完成後保持unpublished corrective，等待後續explicit release candidate與其他已完成unpublished corrective一起處理。

## Approval gate

本Plan完成一次Level 3 Plan review並取得使用者明確核准前，不得修改production source或validator implementation。

