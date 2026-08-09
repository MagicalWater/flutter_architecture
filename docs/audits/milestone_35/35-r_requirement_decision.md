---
document_type: planning-review
status: accepted
authoritative_for:
  - milestone-35-requirement-decision
last_reviewed_baseline: 1.15.2
---

# Milestone 35 — Requirement Decision

## Fresh admission reconciliation

2026-08-09 fresh fetch / read-only reconciliation結果：

```txt
branch: main
HEAD: c4b687d3570708deb044016f0627d97065f5f20c
origin/main: c4b687d3570708deb044016f0627d97065f5f20c
VERSION: 1.15.2
working tree: clean
```

`docs/audits/milestone_35/35-0_test_execution_cost_admission_audit.md`與current roadmap、project snapshot、testing governance、change classifier、CI workflow及current Guides沒有發現會推翻admission findings的新drift。

## Requirement Decision

- Request（需求）：修正repository test execution cost與change-aware validation governance，使每次需求變更只執行與風險相匹配的最小充分驗證，同時保留coverage、fail-safe、Clean Architecture與雙層Task治理。
- Problem（問題）：目前change classifier接近`docs-only`對`everything else → full CI`二分；testing inventory的machine-readable execution tier與治理taxonomy失配；AGENTS／Feature Guide仍存在一般Task無條件full Flutter regression wording。這些selection drift被雙層Task的多個verification points放大，造成重複full-validation成本。
- Current behavior（目前行為）：一般App／package／tooling／test-only變更容易直接進入full CI；普通App／package source還會提升Android與iOS build flags；163個current test files中157個被machine inventory標為Tier 1；一般feature操作文件仍可被Agent解讀為每個commit都必須`dart run melos exec -- flutter test`。
- Expected behavior（預期行為）：建立deterministic、machine-readable、reviewable且fail-safe的Minimum Sufficient Validation routing，正式區分focused、affected、boundary／affected workspace、full與release；只有風險boundary、holistic、release或fail-safe情境才升級full regression。
- Value（價值）：降低小型需求、修正與Task review的重複validation wall-clock與command count，同時不降低failure ownership、coverage boundary、unknown-path fail-safe或release confidence。
- Classification（分類）：**Level 4 — Architecture／Milestone**。理由不是test數量，而是本工作會改變repository-wide validation governance、CI routing、machine-readable classification與Agent／human execution authority。Level 3亦曾考慮，但不足以表達repository-wide governance ownership變更；沒有Level 5的credential／database migration／security／supported-platform或production release-pipeline criticality。
- Decision（決策）：**Accept**。
- Scope（範圍）：validation-selection authority；change classes與escalation；test execution tier machine model；package／feature／test-only／tooling／docs／generated／database／native routing；evidence reuse與fresh-rerun規則；CI／AGENTS／Guides authority alignment；corrective前後execution-cost與coverage-boundary measurement；fail-safe behavior；Milestone holistic／release／post-release full-regression rules。
- Non-goals（非目標）：以刪測試或降低coverage作第一解；移除雙層Task治理；回退Clean Architecture；nightly-only取代必要full regression；讓Agent自行猜tests；降低unknown path／invalid range／classifier failure fail-safe；本階段直接進行production feature重構。
- Behavioral requirements required（是否需要行為需求）：**YES**。Minimum Sufficient Validation routing、evidence reuse、escalation與fail-safe都必須有可驗證行為契約。
- Design Spec required（是否需要 Design Spec）：**YES**。
- Implementation Plan required（是否需要 Implementation Plan）：**YES**。
- ADR required（是否需要 ADR）：**YES**。本Milestone會改變repository-wide stable validation-selection／routing authority；Design必須決定新增canonical ADR或修訂既有相關ADR，不得以Guide取代stable decision authority。
- Task governance mode（Task 治理模式）：**Full two-layer Task governance**。
- Worktree／branch：Requirement Decision與Design／Plan approval artifacts可在current main上完成；**Implementation開始前必須建立managed worktree／branch**，且只能在Design與Plan皆accepted後建立。
- Regression level（Regression 等級）：**Full**為Milestone classification ceiling；Design／Plan文件Task只執行其必要focused／docs authority validation，implementation Tasks依新舊authority交界採affected workspace或full escalation；Milestone holistic／release gate必須fresh full regression。不得把Level 4解讀為每個中間Task都無條件full regression。
- Release required（是否需要發布）：**YES**。若Corrective實作改變current repository governance／CI behavior，必須以新的Template Baseline發布；若Implementation Plan最終證明沒有任何runtime／governance mutation，才可由新的Requirement Decision修訂此結論。
- Post-release validation（發布後驗證）：**YES**。需在published main／release SHA重新驗證classifier／routing fail-safe、focused／affected selection evidence與fresh full regression closure。
- Required Superpowers skills（必要 Superpowers Skills）：`brainstorming`（Design）；Design核准後`writing-plans`；Plan核准後`using-git-worktrees`；implementation依變更使用`test-driven-development`，遇failure／unexpected behavior使用`systematic-debugging`；review gates使用`requesting-code-review`／`receiving-code-review`與`verification-before-completion`；accepted Plan execution使用`subagent-driven-development`或`executing-plans`；release closure使用`finishing-a-development-branch`。Production code／script implementation與code review另依中央治理載入`karpathy-guidelines`。
- Required artifacts（必要 artifacts）：本Requirement Decision；Milestone 35 Corrective Design Spec；Design review evidence；stable validation-governance ADR；Implementation Plan；Plan review evidence；implementation Task reviews；before／after execution-cost evidence；coverage-boundary／fail-safe evidence；holistic final review；VERSION／CHANGELOG／roadmap／current authority同步；post-release validation evidence。

## Required stop conditions

只有下列情況停止自動推進：

1. Design完成完整雙層review，等待使用者Design approval。
2. Design核准後，Plan完成完整雙層review，等待使用者Plan approval。
3. 需要使用者決定scope或stable architecture authority。
4. External service、credential、manual action或environment blocker。
5. P0／P1 finding推翻已核准Design或Plan。
6. 整個Milestone完成並進入正式closure。

## Decision disposition

```txt
Classification: Level 4 — Architecture／Milestone
Decision: ACCEPT
Design Spec: REQUIRED
Implementation Plan: REQUIRED
ADR: REQUIRED
Managed worktree: REQUIRED AFTER Design + Plan acceptance
Regression ceiling: FULL
Release: REQUIRED
Post-release: REQUIRED
Implementation allowed now: NO
Next action: Milestone 35 Corrective Design Spec
```

