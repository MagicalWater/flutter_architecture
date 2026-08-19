---
document_type: planning-review
status: accepted
authoritative_for:
  - milestone-44-post-closure-project-code-convergence-corrective
last_reviewed_baseline: 1.25.2
---

# Milestone 44 Post-closure — Project Code Convergence Corrective Requirement Decision

## Request

對 current repository 做 fresh post-closure project-code convergence / architecture gap audit，不能因 Milestone 44 historical closure 已完成就直接視為 current source 無缺口；若存在 material gap，只建立最低充分的 bounded corrective，不自動 reopen Milestone 44。

## Fresh evidence

- Current branch：`corrective/generated-platform-owner-alignment`。
- Current HEAD：`f9ed227544370071d4955789b5e5f9978e557b98`。
- Working tree admission：clean。
- Published Template Baseline：`1.25.2`。
- M44 relationship-layout primary corrective與C1 color ownership corrective historical closure持續有效，沒有 fresh evidence支持整體推翻。

## Problem

Fresh source / authority audit確認四個 material convergence gaps：

1. `write_precheck_content_components.dart`同時擁有Progress Step、Data Row、Record Tile與Secondary Action，已跨越多個可獨立review／replace／change的產品語意與change reasons；問題不是file length，而是primary responsibility不cohesive。
2. Write Precheck仍存在大量exact literals與derived calculations；其中部分可由accepted Pencil fidelity合理解釋，但也存在`40 - iconSize`、`77 + (surfaceWidth - 410) / 2`、state/value-specific ternary measurements與未命名optical tuning等magic-code風險。Current governance允許component-local exact values，但不允許「來源是Pencil」自動取代ownership／rationale。
3. `docs/visual_authority/pencil-compatibility-write-precheck/implementation_mapping.json`的critical Flutter owner名稱已與current production source drift，例如仍記錄`PrecheckDataRow`、`PrecheckProgress`、`PrecheckRecordTile`等舊owner identity。
4. 同一mapping的screen-layout `evidence_ref`仍指向已於Milestone 45 test-by-exception reset退休的`write_precheck_architecture_contract_test.dart`；current validator只檢查`evidence_ref`非空，因此不存在的evidence仍可machine PASS。

## Valid implementation / false alarms

- `WritePrecheckPage -> WritePrecheckView`本身符合ADR-032：Page持有route admission與localization-to-presentation mapping，View持有Scaffold、screen layout、scroll與whole-screen composition。
- `widgets/`資料夾本身不是failure。ADR-032與M43 current authority採role-based responsibility，不要求mandatory `sections/`、`components/`、`dialogs/`、`flow/` folder tree。
- Remaining `Stack/Positioned`不能依數量判FAIL；fresh evidence仍顯示多數用於bounded decoration／artwork／progress track／optical layering。
- Raw `Color(0x...)`、font size、width／height literal本身不是failure；只有owner bypass、cross-responsibility leakage、unexplained derivation或錯誤promotion才是finding。

## Expected behavior

- 每個handwritten Presentation source維持one coherent primary responsibility；不同產品語意／change reason形成真正owner時拆分，但不採one-widget-one-file或固定folder skeleton。
- Risk-selected exact visual values必須可分類為semantic/shared owner、component-local exact measurement、derived relationship measurement或bounded optical adjustment；無法說明owner／derivation的magic code不得靠Pencil名義自動豁免。
- `implementation_mapping.json`必須引用current production owner identity，不得維持已不存在或已改名的owner。
- Resolved mapping evidence必須能證明current authority；stale／missing file path不得只因字串非空取得PASS。
- Milestone 45 test-by-exception持續有效；本corrective不得為一般source-shape重新建立大型永久architecture test portfolio。

## Value

避免future Pencil-to-Flutter implementation在source responsibility drift、unexplained geometry或stale mapping evidence存在時仍取得architecture／mapping acceptance，同時避免以全面token化、folder formalism或test重建製造新的治理成本。

## Classification

**Level 3 — Cross-cutting**。

具體升級訊號：Presentation ownership、initiative-local implementation mapping contract、shared mapping validator與test-retention後evidence lifecycle互相交叉；但stable architecture方向已由ADR-018／028／032定義，因此不需要Level 4 repository-wide architecture redesign。

## Decision

建立一個bounded post-closure corrective；**不reopen Milestone 44**。

## Scope

- Write Precheck Presentation owner cohesion convergence。
- Risk-selected exact literal／derived measurement／magic-code ownership reconciliation。
- Write Precheck implementation mapping current-owner convergence。
- Mapping validator stale／missing evidence rejection contract。
- 必要的current authority與focused validation evidence。

## Non-goals

- 不全面移除hard code／magic number。
- 不把所有exact values提升到Design System。
- 不建立mandatory Presentation folder taxonomy。
- 不重做M44 relationship-layout corrective或C1 color ownership corrective。
- 不修改accepted `.pen`、visual design、golden threshold／crop／ignore region。
- 不重建已由M45退休的低價值permanent test portfolio。
- 不重新處理Generated / Platform Owner Alignment或manual-local release validation backend。
- 不建立或發布新的Template Baseline。

## Artifact / release disposition

- Design：required。
- Implementation Plan：required。
- ADR：目前不需要；只有Design證明stable boundary需改變時才更新existing ADR。
- Release：deferred；本corrective完成後再與目前unpublished corrective形成explicit candidate decision。

