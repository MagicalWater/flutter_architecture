---
document_type: planning-review
status: accepted
authoritative_for:
  - milestone-44-post-closure-color-ownership-adoption-corrective-requirement
last_reviewed_baseline: 1.23.0
---

# Milestone 44 Post-closure Corrective C1 — Color Ownership Adoption — Requirement Decision

## Requirement Decision

- **Request（需求）**：針對Milestone 44 closure後發現的Write Precheck production raw color literals做scope-integrity corrective，確認M44既有same-semantic color ownership contract是否完整落實到reference production；若未完整落實，修正production adoption並建立direct regression owner，避免再次只驗證behavioral guidance而漏掉current source。
- **Problem（問題）**：ADR-018與M44 Design已定義same-semantic raw color的representation-noise／semantic-role／contextual-variant／component-decoration裁決順序，且`WritePrecheckPalette`已存在feature-local shared semantic owner；但current reference仍存在明確繞過owner的raw literal，例如`WritePrecheckPalette.dim = Color(0xFF7F94A7)`同時在`WritePrecheckStep`直接重寫`const Color(0xFF7F94A7)`。此外`0xFFF5B941`、`0xFF3DAEFF`、`0xFF244056`、`0xFF74D8FF`等solid values跨多個bounded owners重複出現，尚未逐一取得shared semantic／intentional local decoration disposition。現有machine tests只驗證palette值與generic UI spec anti-catch-all，沒有直接拒絕已存在semantic owner卻在consumer重新hard-code相同raw value的failure mode。
- **Current behavior（目前行為）**：
  - `write_precheck` production目前共有110個`Color(0x...)` occurrences；其中包含合法gradient/glow/artwork alpha stops，也包含需semantic ownership reconciliation的solid colors。
  - `0xFFF5B941`出現16次／5個source files；`0xFF3DAEFF`出現7次／3個source files；`0xFF244056`出現3次／2個source files；`0xFF74D8FF`出現3次／2個source files。
  - `WritePrecheckPalette.dim`已擁有`0xFF7F94A7`，但`WritePrecheckStep.contentColor`仍直接重寫相同raw literal，形成已可直接證明的owner bypass。
  - M44 layout主責的focused tests仍PASS；fresh source scan未發現public normal-content `left/top` API或generic `_positionedText/_localText` helper回歸。本Corrective不重新打開已驗證的layout corrective。
- **Expected behavior（預期行為）**：
  - 對risk-selected repeated／shared solid colors完成production semantic ownership inventory；shared semantic value由最小正確shared owner持有，consumer不得重新hard-code相同semantic raw literal。
  - Intentional single-component decoration、gradient/glow alpha stop、artwork-specific exact color可保留在smallest correct component owner；不得為了「零raw literal」把所有exact values塞進mega palette。
  - Machine regression owner至少能直接捕捉「palette/shared owner已存在，但consumer又以相同raw literal繞過owner」的reference failure mode；不得以raw literal count作architecture oracle。
  - 不修改accepted `.pen`、golden、threshold、crop、ignore regions；production visual identity需維持。
- **Value（價值）**：補齊M44 stable color ownership contract到current reference production的最後一段落差，避免文件／behavioral pressure正確但sample implementation持續示範semantic owner bypass。
- **Classification（分類）**：Level 3 — Cross-cutting corrective。
- **Decision（決策）**：Accept。
- **Scope（範圍）**：Write Precheck feature-local color ownership inventory、必要的窄責任palette/component owner調整、direct architecture/regression test、M44 post-closure evidence與current authority同步。
- **Non-goals（非目標）**：重開Milestone 44主Milestone；重構Theme／Design System production；禁止所有raw `Color(0x...)`；把gradient/glow/artwork stops全部token化；asset hard-code治理；l10n/i18n hard-code治理；general magic-number治理；重新處理M44 layout/Positioned scope；修改accepted Pencil source或visual acceptance門檻。
- **Behavioral requirements required（是否需要行為需求）**：是。
- **Design Spec required（是否需要 Design Spec）**：是。
- **Implementation Plan required（是否需要 Implementation Plan）**：是。
- **ADR required（是否需要 ADR）**：否。ADR-018現有stable decision方向正確；本Corrective修production adoption與direct enforcement，不建立新stable architecture decision。
- **Task governance mode（Task 治理模式）**：Full two-layer Task governance。
- **Worktree／branch**：Design與Plan accepted後建立managed worktree；Requirement／Design／Plan artifacts先在current authority保存。
- **Regression level（Regression 等級）**：Affected workspace；若holistic planner或visual owner要求更高，依machine authority升級。
- **Release required（是否需要發布）**：由holistic review依production／governance change與version policy決定；不得在Requirement階段預先宣稱PATCH/MINOR。
- **Post-release validation（發布後驗證）**：只有實際release時required。
- **Required Superpowers skills（必要 Superpowers Skills）**：brainstorming → writing-plans（Design accepted後）→ TDD／verification → review。
- **Required artifacts（必要 artifacts）**：Requirement Decision、Design Spec、Design review、Implementation Plan、Plan review、implementation review evidence、holistic final review；若release，再加post-release validation。

## Fresh admission evidence

```txt
repository_kind = template
VERSION = 1.23.0
main = origin/main = 561b526919657230e78b87bd7f66b7fcdc61dafd
Milestone 44 = CLOSED
Active Milestone = none
working tree before admission = clean
```

## Read-only scope-integrity audit

### Confirmed P1 — Existing semantic owner bypass

```dart
// write_precheck_palette.dart
static const Color dim = Color(0xFF7F94A7);

// write_precheck_content_components.dart
: const Color(0xFF7F94A7);
```

這不是near-identical-value推測；相同feature shared semantic owner已存在，consumer仍直接持有相同raw value。現有tests沒有拒絕此情況。

### P1 — Repeated solid color ownership unresolved

Fresh inventory：

```txt
0xFFF5B941  16 occurrences / 5 files
0xFF3DAEFF   7 occurrences / 3 files
0xFF244056   3 occurrences / 2 files
0xFF74D8FF   3 occurrences / 2 files
```

這些值不能僅依frequency判定shared token；Design必須依實際semantic/change reason逐類裁決。Count只用來找risk-selected candidates，不作machine failure oracle。

### Preserved M44 primary layout evidence

Fresh focused tests：

```txt
presentation_responsibility_contract_test.dart
write_precheck_architecture_contract_test.dart
write_precheck_copy_test.dart
→ 19 / 19 PASS
```

Fresh scan未發現：

- normal-content public `left/top` API回歸；
- generic `_positionedText`／`_localText`／`_positionedIcon`／`_localIcon` helper回歸。

Remaining `Positioned`仍位於既有bounded glow/orbit/glyph/highlight/artwork owners；本Corrective沒有新的layout failure evidence，因此不得順手重做M44 layout scope。

## Test Authoring Decision

- **Disposition**：Required。
- **Reason**：已存在deterministic reference failure mode「shared semantic owner存在但consumer raw literal bypass」，而current tests沒有direct owner。
- **Primary owner**：`apps/flutter_architecture/test/features/pencil_compatibility/presentation/write_precheck_architecture_contract_test.dart`或同一feature最接近source-ownership boundary的focused architecture test；Design／Plan需確認最小可維護形式。
- **禁止**：建立「所有`Color(0x...)`一律FAIL」或以literal數量/檔案數作oracle的test。

## Requirement disposition

Open P0：0。

Open P1 without disposition：0；兩項P1均納入本Corrective Design／Plan。

Requirement Decision：**ACCEPTED**。

