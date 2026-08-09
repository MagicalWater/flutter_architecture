# Milestone 33 Corrective — C3 Cross-Conversation Checkpoint

Status: handoff-ready / C3 implementation candidate, review pending

## Purpose

本文件是Milestone 33 Corrective在Task C3尚未完成正式Task review／commit前的跨對話checkpoint。
它只保存current authority、fresh evidence、working tree與下一個精確執行點；不得被解讀為C3 accepted、C4 started、Milestone completed或release closure。

## Repository State

```txt
Repository: D:\Developer\flutter_architecture
Managed worktree: C:\Users\crazy\.devspace\worktrees\flutter_architecture-278abc9f
Branch: milestone-33-corrective-single-renderer
Checkpoint committed ancestor before this document: 30d732b
Released baseline on main: 1.15.0 / ced0c072db1c9ee5b15a6f2e0af9cb89a54ebe9f
Expected corrective release: 1.15.1 only after C4 user visual acceptance + C5 Final Review
```

Working tree在checkpoint建立前包含下列C3 implementation candidate changes，刻意不隨本checkpoint commit：

```txt
D  apps/flutter_architecture/lib/features/pencil_compatibility/presentation/pages/write_precheck_canonical_canvas.dart
M  apps/flutter_architecture/lib/features/pencil_compatibility/presentation/pages/write_precheck_view.dart
?? apps/flutter_architecture/lib/features/pencil_compatibility/presentation/pages/write_precheck_projected_canvas.dart
M  apps/flutter_architecture/test/features/pencil_compatibility/goldens/write_precheck_runtime_windows.png
M  apps/flutter_architecture/test/features/pencil_compatibility/goldens/write_precheck_windows.png
M  docs/audits/milestone_33/visual_validation/canonical-render.png
M  docs/audits/milestone_33/visual_validation/reference-diff.png
```

不得在新對話以`git reset --hard`、checkout clean copy或重建worktree丟失這些C3 WIP。

## Governance Status

Milestone 33 Corrective本身使用完整雙層Task治理；但**整個Corrective尚未完成**。

已完成並有獨立review／commit evidence：

1. Corrective Requirement／Design／ADR amendment draft：accepted。
2. Corrective Implementation Plan：accepted。
3. Task C1 — Single-Renderer Governance Contract：accepted，commit `413ff5b`。
4. Task C2 — Runtime Visual Contract / intentional RED：accepted，commit `6a2994e`。
5. Runtime Renderer Calibration P1 amendment：accepted；Design／Plan／review commit `e4dfb0a`。
6. Calibration executable gate update：commit `30d732b`。

尚未完成：

1. **Task C3** — production implementation目前只有candidate；尚未完成focused review、Whole-Task review與C3 completion commit。
2. **Task C4** — 尚未以C3 accepted candidate執行fresh Android build/install、runtime screenshot、side-by-side semantic review與使用者人工驗收。
3. **Task C5** — 尚未進行Corrective Holistic Final Review、1.15.1 release disposition、push與post-release validation。

因此不得聲稱「整個大階段已經完成雙層治理」；正確表述是：**已完成部分均依雙層治理執行，C3正在治理流程中，C4／C5未開始。**

## Current Acceptance Authority

2026-08-08 accepted Runtime Renderer Calibration Amendment supersede了原C2的單一runtime hard gate。

### Gate A — Canonical Design Fidelity / hard gate

```txt
Pencil canonical 941 × 1672
↔ Flutter canonical 941 × 1672
perChannelTolerance = 8
differentPixelRatio <= 0.08
meanAbsoluteChannelDelta <= 8.0
```

### Gate B — Deterministic Runtime Projection Fidelity / hard gate

```txt
Flutter canonical golden（必須先通過Gate A）
→ deterministic projectPng 360 × 640
↔ Flutter WritePrecheckView 360 × 640

perChannelTolerance = 8
differentPixelRatio <= 0.10
meanAbsoluteChannelDelta <= 4.0
ignore regions = none
```

### Gate C — Pencil-derived Runtime Diagnostic / diagnostic only

原C2 `pencil-runtime-360x640.png`與SHA必須保留；direct Pencil/runtime diff持續記錄趨勢，但**不再以`<= 0.08`單獨決定runtime PASS**。

### Gate D — Android Supported Runtime / hard human gate

```txt
BlueStacks physical = 540 × 960
DPR = 1.5
logical = 360 × 640
textScale = 1.0
```

必須fresh build/install、fresh runtime screenshot、semantic side-by-side，最後由使用者實際看BlueStacks並明確通過。Automation不得代替此gate。

## Fresh Checkpoint Evidence

2026-08-09跨對話收尾前fresh執行current authoritative C3 gates：

```txt
Gate A canonical visual diff: PASS

Gate B runtime renderer calibration:
differentPixelRatio = 0.09769965277777778   <= 0.10 PASS
meanAbsoluteChannelDelta = 2.495971137152778 <= 4.0 PASS
maxChannelDelta = 215

Gate C direct Pencil diagnostic:
differentPixelRatio = 0.1297222222222222
meanAbsoluteChannelDelta = 3.8164214409722224
maxChannelDelta = 233
diagnostic only; not a hard failure under current authority

single-renderer architecture contract: PASS
responsive layout-health 941×1672 / 390×844 / 226×400: PASS
focused analyze for WritePrecheckView + WritePrecheckProjectedCanvas: PASS
```

這些結果只證明目前C3 candidate已滿足current automated gates；C3仍需正式雙層Task review後才能accepted。

## Implementation Candidate Summary

目前C3已移除原本：

```txt
>= 900 → canonical exact renderer
< 900  → separate responsive renderer
```

並改為單一`WritePrecheckProjectedCanvas`／single whole-screen visual tree。

主要candidate方向：

- `941 × 1672`只作design/comparison space，不作Flutter breakpoint。
- 同一份Flutter visual tree投影至runtime width。
- canonical與runtime都由`WritePrecheckView`進入同一production path。
- 保留Semantics／scrollability；禁止第二份whole-screen renderer、runtime raster screenshot asset或test-only renderer。
- 過程中曾加入component／paint metric projection、Phosphor glyph與局部字寬校準；這些仍需C3 review判斷哪些是必要fidelity修正、哪些只是為已superseded Gate C過度擬合。

## Important Execution Drift Finding

跨對話收尾時發現：Runtime Renderer Calibration Amendment已於2026-08-08 accepted，但後續長對話有一段又把Gate C direct Pencil/runtime `<= 8%`當成C3主要完成目標，持續追逐`12% → 8%`。

這與current accepted authority不一致，因為該amendment已明確指出這會混入cross-renderer/downsample rasterization差異並誘導visual-test overfitting。

Disposition：

1. 不改寫歷史；保留該段診斷與微調結果。
2. 新對話**不得繼續以Gate C <= 8%為目標**。
3. C3正式review必須先審查目前WIP diff，找出只為superseded Gate C做的局部校準；若沒有Design／Pencil／semantic evidence支持，應回退該微調。
4. C3 acceptance以Gate A + Gate B + single-renderer architecture + responsive health + source quality review為automation owner；C4 Android／使用者人工視覺驗收仍是最終runtime P1 owner。

## Known Diagnostics / Do Not Misread

- 舊1.15.0 dual-renderer direct Pencil baseline約`68.43%`，仍是有效historical regression evidence。
- C3過程曾把direct Pencil diagnostic降到約13%；這不是current hard gate，也不能單獨證明或否定C3。
- 真實BlueStacks曾fresh確認runtime metrics為`540×960 @ DPR1.5 → logical 360×640`；當次diagnostic direct Pencil comparison約15%，不同renderer不能取代C4 semantic/user gate。
- 一次runtime DPR probe因`RenderRepaintBoundary.toImage()`掛住而中止，未產生authority evidence；probe檔未出現在Git working tree。
- 一次cache timing probe只屬診斷，不是accepted test contract；交接時Git working tree沒有該probe檔。

## Exact Next Execution Point

新對話第一個實作動作不是繼續調pixel，也不是進C4。

應依序：

1. Admission：確認exact worktree、branch、HEAD及上列dirty files仍存在。
2. 重讀accepted Corrective Plan與2026-08-08 Runtime Renderer Calibration Amendment。
3. Review目前C3 production diff：
   - 確認確實只有一個whole-screen production tree；
   - 檢查`WritePrecheckProjectedCanvas`是否含不必要的overfitting／test-specific behavior；
   - 特別審查在amendment accepted後、為追Gate C <=8%加入的glyph／scale／raster微調；只有有Pencil/semantic evidence者保留。
4. Fresh rerun Gate A、Gate B、architecture、responsive、affected analyze/tests。
5. 完成C3 focused review → findings fix/re-review → Whole-Task review。
6. 只有C3 review accepted後才建立C3 completion commit。
7. 自動進C4：fresh APK build/install → BlueStacks foreground → runtime screenshot／hash／semantic side-by-side → **停在使用者人工視覺驗收gate**。
8. 使用者通過後才可進C5 holistic/release/post-release closure。

## Cross-Conversation Read Set

新對話除repository固定最小文件集外，至少讀：

```txt
docs/superpowers/specs/2026-08-07-milestone-33-corrective-single-renderer-responsive-fidelity-recovery-design.md
docs/superpowers/plans/2026-08-07-milestone-33-corrective-single-renderer-responsive-fidelity-recovery.md
docs/audits/milestone_33/33-c1_governance_contract_review.md
docs/audits/milestone_33/33-c2_runtime_visual_contract_review.md
docs/superpowers/specs/2026-08-08-milestone-33-corrective-runtime-renderer-calibration-amendment-design.md
docs/superpowers/plans/2026-08-08-milestone-33-corrective-runtime-renderer-calibration-amendment.md
docs/audits/milestone_33/33-cp2_runtime_renderer_calibration_amendment_review.md
docs/audits/milestone_33/33-c3_cross_conversation_checkpoint.md
apps/flutter_architecture/lib/features/pencil_compatibility/presentation/pages/write_precheck_view.dart
apps/flutter_architecture/lib/features/pencil_compatibility/presentation/pages/write_precheck_projected_canvas.dart
apps/flutter_architecture/test/features/pencil_compatibility/presentation/write_precheck_runtime_visual_diff_test.dart
```

## Closure Statement for This Conversation

本對話可以在此安全切換，但不是因為Corrective大階段完成，而是因為：

- accepted authority與supersession已明確；
- exact worktree／branch／dirty C3 candidate已記錄；
- current authoritative gates已有fresh evidence；
- C3／C4／C5未完成狀態已明確；
- 執行偏航已被書面化並給出回復current authority的具體下一步；
- 不需要依賴未記錄的聊天推理才能接續。
