---
document_type: implementation-plan
status: accepted
authoritative_for:
  - milestone-41-pencil-layout-architecture-corrective-implementation-plan
last_reviewed_baseline: 1.20.0
---

# Milestone 41 — Pencil-to-Flutter Constraint-based Layout Architecture Corrective Implementation Plan

## 1. Admission

```txt
Requirement: accepted
Design: accepted / user approved 2026-08-18
Plan: accepted / user approved 2026-08-18
Implementation: admitted; execute Tasks 41-1 onward under full Task governance
Managed worktree: C:\Users\crazy\.devspace\worktrees\flutter_architecture-1282d9ed
Branch: milestone-41-pencil-layout-architecture-corrective
Base: main@591a7d638a5e980846cb75d8f05c88b97410bdec
```

本Plan只落實accepted Design，不重新決定layout architecture。Stable decision仍由ADR-028 amendment gate與accepted Design擁有。

## 2. Execution strategy

Task順序固定為：

```txt
41-1 machine RED / policy pressure RED
→ 41-2 mapping layout-model contract GREEN
→ 41-3 reference architecture detector GREEN
→ 41-4 reference production layout migration
→ 41-5 visual/runtime recovery and focused acceptance
→ 41-6 ADR / Skill / Guide / mapping authority sync
→ 41-7 fresh behavioral pressure acceptance
→ 41-8 holistic final review / release candidate
→ 41-9 publication / post-release closure（若release gate決定發布）
```

每個Task皆使用Level 4 full two-layer governance。Task通過才commit；一般finding直接修正與fresh re-review，不跳Task。

## 3. Task 41-1 — Direct RED: absolute-coordinate shortcut must be detectable

### Goal

先建立可重現RED，證明current machine/policy owners抓不到single-renderer whole-screen absolute-coordinate reconstruction。

### Files

- `tools/docs/test_pencil_single_renderer_policy.py`
- `tools/visual/test_pencil_implementation_mapping.py`
- `apps/flutter_architecture/test/features/pencil_compatibility/presentation/write_precheck_architecture_contract_test.dart`
- `.agents/skills/implementing-pencil-flutter-design/references/pressure-scenarios.md`（只在RED fixture需要policy expectation時最小變更；若Task 41-2才應改production policy，41-1維持test-only）
- `docs/audits/milestone_41/41-1_layout_architecture_red.md`

### Test Authoring Decision

**Required**。本次confirmed failure正是現有tests誤PASS；必須建立direct regression owner。

### RED requirements

至少證明：

1. current reference `WritePrecheckProjectedCanvas`的whole-screen projected-coordinate mechanism會被新architecture contract判FAIL；
2. bounded local `Stack`／`Positioned` fixture不被誤判；
3. policy scenario明確涵蓋PTF-27／28／29 semantics；
4. 不以單純`Positioned`數量作唯一oracle。

### Stop condition

若無法在不大量false positive下建立direct owner，回Design，不進後續Task。

## 4. Task 41-2 — Layout model machine contract GREEN

### Goal

擴充initiative-local `implementation_mapping.json`與validator，使screen root layout model成為production mapping gate。

### Files

- `tools/visual/pencil_implementation_mapping.py`
- `tools/visual/test_pencil_implementation_mapping.py`
- `.agents/skills/implementing-pencil-flutter-design/references/asset-and-typography-mapping.md`
- `.agents/skills/implementing-pencil-flutter-design/references/flutter-mapping.md`
- existing proof `docs/visual_authority/pencil-compatibility-write-precheck/implementation_mapping.json`
- `docs/audits/milestone_41/41-2_layout_model_mapping_review.md`

### Contract

Screen-root critical mapping增加resolved layout model vocabulary：

```txt
constraint-flow
bounded-overlay
intentional-spatial-canvas
unresolved
```

要求：

- normal App screen root不得為`bounded-overlay`；
- `intentional-spatial-canvas`必須有accepted `approval_ref`；
- `unresolved` fail closed；
- local component可標`bounded-overlay`，但不能取得page-flow ownership；
- validator不解析`.pen`、不建立global registry。

### Validation

Focused Python mapping tests + representation policy + docs check + planner-selected validation。

## 5. Task 41-3 — Reference production architecture detector GREEN

### Goal

修正current architecture test的delegation blind spot，讓它檢查實際production subtree，而不是只掃top-level `write_precheck_view.dart`。

### Files

- `apps/flutter_architecture/test/features/pencil_compatibility/presentation/write_precheck_architecture_contract_test.dart`
- 必要時新增最小test helper，禁止建立generic repository-wide Dart AST framework
- `docs/audits/milestone_41/41-3_reference_architecture_detector_review.md`

### Detector contract

必須抓到current reference的以下組合語意：

- screen-root design width/height owner；
- whole-screen shared scale；
- screen section placement以canonical page `left/top/right/bottom`投影；
- custom RenderStack／parent-data scaling或等價mechanism。

不得因Hero等bounded local overlay存在就fail。

### Validation

Direct architecture test必須在old mechanism存在時FAIL；完成Task 41-4 migration後同一owner轉GREEN。

## 6. Task 41-4 — Reference production constraint-layout migration

### Goal

把`WritePrecheckProjectedCanvas`從whole-screen coordinate reconstruction遷移為constraint／relationship-owned page flow，同時保留accepted `.pen`visual identity。

### Primary files

- `apps/flutter_architecture/lib/features/pencil_compatibility/presentation/pages/write_precheck_view.dart`
- `apps/flutter_architecture/lib/features/pencil_compatibility/presentation/pages/write_precheck_projected_canvas.dart`
- `apps/flutter_architecture/lib/features/pencil_compatibility/presentation/visual_spec/pencil_compatibility_visual_spec.dart`
- related feature-local widgets/tests as required by actual decomposition
- `docs/audits/milestone_41/41-4_reference_layout_migration_review.md`

### Required architecture

Screen-level composition改為：

```txt
scroll/container constraints
→ vertical flow
→ TopChrome
→ Progress
→ Hero
→ Summary
→ Results
→ Records
→ Guidance
→ Primary action
→ Secondary actions
→ Footer
```

Section position由edge inset、alignment、preferred/min size、sibling gap、aspect/container relationship決定。

允許每個section內保留bounded local overlay；local coordinates只能相對local bounds，不得以canonical page origin決定section placement。

### Explicit removals

移除或失效：

- screen-level `designHeight = 1672` layout owner；
- whole-screen `_RenderProjectedStack` parent-data coordinate scaling；
- page section `top/left` canonical placement；
-為screen flow服務的global `visualScale` coordinate reconstruction。

若`WritePrecheckProjection`仍保留，只能用於合法local visual measurements，不得再次擁有whole-screen coordinates。

### Test Authoring Decision

Existing direct RED owner為primary。若migration揭露content growth／narrow layout缺口，新增一個relationship widget test為**Recommended**；不得every-section test expansion。

## 7. Task 41-5 — Visual/runtime fidelity recovery

### Goal

證明architecture修正沒有以犧牲accepted visual fidelity換取GREEN。

### Required validation

- canonical Pencil/Flutter golden/diff；
- tracked runtime projection consistency；
- supported runtime visual diff；
- critical local fidelity owners；
- responsive/layout-health tests；
- semantics/touch-target owners；
- human semantic side-by-side review；
- focused analyze/build if planner selects them。

### Immutable rules

不得：

- 放寬threshold；
- 改crop／ignore regions；
- 更新accepted `.pen`迎合candidate；
- 修改runtime expected projection algorithm迎合candidate；
- 刪除critical owner。

若既有visual contract被證明與constraint architecture不可兼容，Task BLOCKED並回Design。

## 8. Task 41-6 — Stable authority synchronization

### Goal

在runtime truth成立後同步stable/current authority，不先用文件宣稱尚未成立的architecture。

### Files

- `docs/adr/adr-028-repository-local-pencil-to-flutter-design-implementation-workflow.md`
- `.agents/skills/implementing-pencil-flutter-design/SKILL.md`（只在routing wording需要時）
- `.agents/skills/implementing-pencil-flutter-design/references/flutter-mapping.md`
- `.agents/skills/implementing-pencil-flutter-design/references/visual-validation.md`
- `.agents/skills/implementing-pencil-flutter-design/references/pressure-scenarios.md`
- `docs/guides/pencil_to_flutter_workflow.md`
- `docs/governance/development_workflow.md`（registry responsibility若需同步）
- `docs/project_context.md`
- `docs/audits/milestone_41/41-6_authority_sync_review.md`

### Stable wording

至少固定：

- canonical page coordinates不是runtime page coordinate system；
- screen layout以constraints／relationships為owner；
- bounded local overlay合法但不得控制page flow；
- intentional spatial canvas需要accepted Design approval；
- one renderer不構成whole-screen coordinate reconstruction豁免。

## 9. Task 41-7 — Behavioral pressure acceptance

### Goal

驗證fresh Agent不能再用「single renderer + true Flutter widgets」合理化absolute-coordinate shortcut。

### Required scenarios

- PTF-27 absolute-coordinate shortcut → FAIL；
- PTF-28 bounded local overlay → PASS；
- PTF-29 accepted genuine spatial canvas → PASS with approval evidence；
- 至少一個negative variant：沒有approval卻宣稱spatial canvas → FAIL。

### Evidence

依`docs/guides/skill_behavioral_validation.md`保存provider-neutral fresh isolated-agent evidence。

## 10. Task 41-8 — Holistic final review / release decision

### Review matrix

- Requirement / Design / Plan consistency；
- ADR / Skill / Guide / tool / source / tests authority consistency；
- source-quality review，確認沒有把fixed canvas藏到custom RenderObject、helper或另一個檔案；
- full repository regression；
- Flutter analyze；
- runtime/build gates由validation planner與changed scope決定；
- existing Pencil visual authority hashes unchanged unless an explicitly governed derived evidence update is required；
- Open P0=0、undisposed P1=0。

### Release disposition

Level 4預設進release decision。若stable template behavior／governance改變，發布新Template Baseline並進Task 41-9；若final review有充分理由判定不需version bump，必須明確記錄no-release disposition，不得默認。

## 11. Task 41-9 — Publication / post-release closure

只在41-8決定release後執行：

- VERSION / CHANGELOG / roadmap / project context sync；
- merge/push authorization gate；
- published-main clean checkout；
- fresh full regression；
- required Android / macOS-iOS evidence；
- fresh Skill discovery與PTF-27～29 acceptance；
- final archive routing。

若41-8明確no-release，此Task改為formal no-release closure，不執行虛假的published-main gate。

## 12. Commit boundaries

每個41-1～41-8均為獨立completion commit。41-9依release steps可拆release metadata與post-release evidence commits，但不得把failed gate commit成completed semantics。

## 13. Global stop conditions

只有下列情況停止等待使用者：

1. 需要改accepted Design的architecture/scope decision；
2. visual fidelity被證明只能靠forbidden whole-screen coordinate projection達成；
3. external/manual platform blocker；
4. release/merge/push需要明確授權；
5. Milestone完成。

一般source/test/layout finding直接修正、fresh re-review並繼續。

## 14. Plan acceptance gate

本Plan完成focused review、whole-Task review、docs validation、diff check與planner classification後，仍維持`proposed`。只有使用者明確核准後才轉`accepted`並允許Task 41-1開始。
