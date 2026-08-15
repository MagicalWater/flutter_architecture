---
document_type: planning-review
status: accepted
authoritative_for:
  - milestone-39-pencil-flutter-fidelity-enforcement-recovery-requirement
last_reviewed_baseline: 1.19.0
---

# Milestone 39 — Pencil-to-Flutter Fidelity Enforcement & Recovery Governance Corrective Requirement Decision

## Request

補強目前 repository-local Pencil → Flutter implementation route，讓 accepted `.pen` 不只在政策層面被視為 visual authority，也能在 critical icon、asset、geometry 與 section-level fidelity 上形成更具體、可機械驗證且具明確 recovery semantics 的 implementation contract。

## Problem

Milestone 33／34 已建立 `.pen` authority、Pencil MCP admission、representation classification、asset／font provenance、single-renderer responsive fidelity、whole-screen visual diff 與 runtime semantic acceptance；但 fresh audit 與較早產品專案的實際 corrective evidence 顯示，仍存在以下可重複的 residual gaps：

1. Current mapping evidence主要是 Task-level prose，沒有 machine-enforced critical-node completeness；Agent仍可能遺漏某個重要 Pencil icon／image／geometry node。
2. `approximate icon`、asset provenance與representation fail-closed contract已存在，但缺少統一、可機械判讀的 mapping disposition vocabulary。
3. Whole-screen visual metrics容易被大面積背景／layout稀釋，對 8–16px icon、1–2dp alignment、local asset identity 等 micro-fidelity failure辨識力不足。
4. Flutter source出現某個 width／height constant不代表 runtime `RenderBox` 真正符合 accepted Pencil geometry；critical CTA／sticky actions／header等仍可能被parent constraints壓縮。
5. 當review已判定「素材／icon／representation本身錯誤」時，current Skill可以推導應回到authority，但沒有正式 recovery state阻止Agent繼續調 padding／scale／offset 來微調已失效的representation。

## Current Behavior

- `.pen` 是唯一primary structural／visual authority；external path、PNG、historical screenshot不得取代。
- Pencil MCP unavailable、hash drift、wrong document與unsupported unresolved construct皆fail closed。
- Flutter mapping前必須完成representation classification與provenance resolution。
- Semantic-equivalent but visually different package icon屬`approximate icon`，不得自動接受。
- Fixed complex visual不得以static `CustomPainter` overbuild或大量magic gradient／shadow近似。
- Raster／vector byte-changing derivation必須記錄transformation與content hash。
- One accepted screen只能有one whole-screen visual tree；canonical viewport不是Flutter breakpoint。
- Visual acceptance包含canonical golden／diff、runtime evidence與human semantic review。
- Existing policy tests主要驗證stable contract wording；current machine enforcement尚未證明critical Pencil nodes全部完成mapping。

## Expected Behavior

1. 每個Pencil-to-Flutter Task在production mapping前，對**critical** design nodes建立可追溯 inventory，至少能關聯Pencil node identity、role、representation class、source／asset identity、critical geometry與Flutter owner／consumer。
2. Mapping disposition使用統一狀態：`Exact`、`Verified equivalent`、`Intentional deviation`、`Unresolved`；`Unresolved`不得進production，`Intentional deviation`不得由implementation Agent自行宣告。
3. Current representation classes保留；不得把本corrective簡化成「所有icon都輸出PNG」。Raster、vector、verified package glyph與其他合法representation依source與runtime需求決定。
4. 對risk-selected critical geometry提供runtime `RenderBox` evidence，而不是只檢查source constants；不得要求每個Pencil node都新增geometry test。
5. Whole-screen metric繼續負責broad regression，但critical component／section／micro-asset failure必須能獨立使visual acceptance失敗。
6. Review一旦判定wrong source identity／wrong representation，current candidate mapping立即失效；在重新完成representation／provenance gate前，禁止繼續以geometry pixel-tuning修補該candidate。
7. Skill、Guide、machine checker、tests與fresh-agent pressure evidence必須對上述規則一致；不能只新增Markdown wording就宣稱完成。
8. 不破壞Milestone 33／34既有visual authority、single-renderer、Feature First、Design System與Localization ownership。

## Value

- 防止「Pencil已有正確icon／asset，Flutter卻用語意近似物」再次進入candidate。
- 防止whole-screen PASS掩蓋critical icon／section micro-fidelity failure。
- 防止source constant正確但runtime geometry因constraint而失真。
- 防止已證明素材本身錯誤後，Agent仍持續對錯素材做padding／scale／position微調。
- 保持通用模板對vector／raster／package icon／dynamic drawing的技術彈性，不綁死單一輸出格式。

## Classification

**Level 4 — Architecture／Milestone。**

### Evidence

- 變更repository-wide Pencil-to-Flutter workflow governance與Skill behavior。
- 會影響mapping evidence contract、visual acceptance與review recovery semantics。
- 需要machine enforcement、fresh-agent behavioral pressure與cross-Task holistic review。
- 不涉及credential、data migration、production security或irreversible platform state，因此不升級Level 5。

## Decision

**Accept — 建立 Milestone 39。**

## Scope

- 補強既有`implementing-pencil-flutter-design`；**不新增第二個Pencil domain Skill**。
- Critical-node mapping inventory contract與machine-verifiable completeness strategy。
- Mapping disposition：Exact／Verified equivalent／Intentional deviation／Unresolved。
- Critical runtime geometry evidence與risk-based authoring rule。
- Component／section-level fidelity gate與whole-screen metric責任分離。
- Wrong-representation invalidation／rollback-to-mapping recovery state。
- Pressure scenarios與fresh isolated-agent behavioral validation。
- Required Skill／Guide／tests／tooling／audit evidence同步。
- ADR-028 amendment gate與current authority synchronization。

## Non-goals

- 不建立第二個Pencil-to-Flutter orchestration Skill。
- 不建立global asset registry或全repository universal design-node database。
- 不要求每個Pencil node都建立runtime geometry test。
- 不要求所有icon raster化或全部輸出PNG。
- 不重寫Pencil MCP、Milestone 33 visual authority foundation或single-renderer architecture。
- 不重做既有Pencil compatibility proof UI，除非Plan明確需要最小fixture驗證新machine gate。
- 不修改產品visual language或accepted `.pen` design。

## Behavioral requirements required

Required。

## Design Spec required

Required。

## Implementation Plan required

Required。

## ADR required

Gate required。Design必須判斷是否只amend ADR-028或需要新增stable Decision；不得在Requirement階段預先建立第二份authority。

## Task governance mode

Full two-layer Task governance。

## Worktree／branch

Required。Current managed worktree：

```txt
C:\Users\crazy\.devspace\worktrees\flutter_architecture-486bd1f2
branch: milestone-39-pencil-flutter-fidelity-enforcement-recovery
base: origin/main@afd3f6e3f1c75af04e18dafc80c552720c83e0b9
```

## Regression level

Full at Milestone holistic gate；individual Tasks仍由`tools/ci/validation_planner.py`選擇Minimum Sufficient Validation。

## Release required

Required。Milestone完成後發布新的Template Baseline；exact version由accepted Plan／release gate決定。

## Post-release validation

Required。至少包含published-main clean checkout、fresh Skill discovery、machine policy validation與fresh isolated-agent pressure acceptance。

## Required Superpowers skills

- `brainstorming`：Design。
- `writing-plans`：Design accepted後。
- `test-driven-development`：依Test Authoring Decision使用。
- `verification-before-completion`：Task／Milestone gate。
- `finishing-a-development-branch`：integration／release。

Current DevSpace diagnostics仍顯示Superpowers plugin cache path缺失；此environment warning不得降低repository governance。若workflow Skill不可載入，使用repository contract完成等價formal artifacts與review，但不得跳過Design／Plan approval gates。

## Required artifacts

- 本 Requirement Decision。
- Formal Design Spec。
- Design Task focused／whole review evidence與使用者核准。
- Formal Implementation Plan與Plan review／使用者核准。
- ADR gate disposition。
- Per-Task implementation／validation／review evidence。
- Fresh-agent behavioral pressure evidence。
- Holistic final review、release與post-release closure evidence。

