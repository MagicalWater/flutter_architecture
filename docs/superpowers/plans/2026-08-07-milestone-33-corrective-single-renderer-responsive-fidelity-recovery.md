---
document_type: implementation-plan
status: accepted
authoritative_for:
  - milestone-33-corrective-single-renderer-responsive-fidelity-recovery-plan
last_reviewed_baseline: 1.15.0
---

# Milestone 33 Corrective — Single-Renderer Responsive Fidelity Recovery Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 修正Template Baseline 1.15.0的Pencil-to-Flutter proof，使accepted `941 × 1672`手機`.pen`只驅動一套Flutter visual widget tree，並讓canonical與Android `360 × 640` runtime都具有真正的visual fidelity gate。

**Architecture:** `941 × 1672`只作design/comparison space。`WritePrecheckView`在所有正常portrait widths都建立同一個projected screen tree；visible geometry由`visualScale = availableWidth / 941`投影到真Flutter widgets，不使用top-level `FittedBox`、`Transform.scale`或parallel whole-screen renderer。Canonical與runtime reference／golden／diff都比較同一renderer，narrow tests只擁有layout-health責任。

**Tech Stack:** Flutter 3.44.8、Dart、AutoRoute、generated Localization、Phosphor Icons、Flutter golden/widget/integration tests、repository Python docs/visual checks、Pencil MCP既有authority、BlueStacks Android runtime。

**Approval:** User written approval received on 2026-08-07. Execute C1 → C5 under full two-layer governance; C4 user visual acceptance remains a hard gate before C5 release closure.

## Global Constraints

- Template Baseline 1.15.0歷史不可改寫；禁止force push。
- `docs/design_sources/pencil-compatibility-write-precheck/source.pen`維持唯一手機visual authority，不新增第二份mobile `.pen`。
- `941 × 1672`是design/comparison space，不是Flutter logical breakpoint。
- 一個accepted screen只能有一套whole-screen Flutter visual tree；breakpoint不得替換整頁renderer。
- Projection以真Widget geometry乘算完成；禁止top-level full-canvas `FittedBox`／`Transform.scale`／raster embedding。
- Base theme／semantic color／spacing／radius／asset ownership繼續遵守既有Design System mapping order；沒有第二consumer evidence不得提升global token。
- Runtime `360 × 640` visual gate在candidate implementation前固定reference derivation、target、threshold與hash；不得candidate失敗後再改reference算法或放寬threshold。
- Canonical不同像素比例門檻維持`<= 0.08`，mean absolute channel delta維持`<= 8.0`。
- Runtime `360 × 640`不同像素比例門檻固定`<= 0.08`，mean absolute channel delta固定`<= 8.0`；ignore regions預設none。
- `390 × 844`與`226 × 400`仍測no-overflow／scroll／semantics，但不得冒充runtime fidelity evidence。
- Android runtime visual acceptance必須由實際production route／widget tree產生，並接受使用者人工side-by-side判定；人工P1會撤銷automation PASS。
- Production implementation在managed corrective worktree進行，不在dirty `main` checkout修改。
- 每個Task：RED／implementation／GREEN → focused review → finding修正 → fresh re-review → whole-Task review → independent commit。
- Corrective release預期1.15.1，但只有C4人工runtime驗收與C5 Holistic Final Review通過後才能決定與發布。

---

## Planned File Structure

### Stable governance

- Create: `tools/docs/test_pencil_single_renderer_policy.py` — repository-level policy regression test；只驗證authoritative ADR/Skill/Guide是否包含single-renderer/runtime-fidelity硬規則，不建立平行policy owner。
- Modify: `docs/adr/adr-028-repository-local-pencil-to-flutter-design-implementation-workflow.md` — canonical single-renderer／runtime-fidelity decision。
- Modify: `.agents/skills/implementing-pencil-flutter-design/references/flutter-mapping.md` — design-space projection與single-tree mapping hard rule。
- Modify: `.agents/skills/implementing-pencil-flutter-design/references/visual-validation.md` — canonical／runtime same-renderer gates與semantic P1 rule。
- Modify: `.agents/skills/implementing-pencil-flutter-design/references/pressure-scenarios.md` — parallel renderer與canonical-breakpoint rejection scenarios。
- Modify: `docs/guides/pencil_to_flutter_workflow.md` — human workflow同步。
- Create: `docs/audits/milestone_33/33-c1_governance_contract_review.md`。

### Runtime reference and tests

- Modify: `docs/visual_authority/pencil-compatibility-write-precheck/manifest.md` — 固定runtime projection contract與derived artifact hash。
- Create: `docs/design_sources/pencil-compatibility-write-precheck/pencil-runtime-360x640.png` — canonical Pencil preview的derived runtime reference，不取得authority。
- Modify: `apps/flutter_architecture/test/support/visual_diff.dart` — deterministic `projectPng(...)` helper。
- Modify: `apps/flutter_architecture/test/support/visual_diff_test.dart` — projection dimensions／same-input determinism／dimension guards。
- Create: `apps/flutter_architecture/test/support/runtime_reference_derivation_test.dart` — default驗證tracked runtime reference；只有`--dart-define=UPDATE_PENCIL_RUNTIME_REFERENCE=true`時才由canonical Pencil preview重新生成tracked derived reference。
- Create: `apps/flutter_architecture/test/features/pencil_compatibility/presentation/write_precheck_runtime_golden_test.dart`。
- Create: `apps/flutter_architecture/test/features/pencil_compatibility/presentation/write_precheck_runtime_visual_diff_test.dart`。
- Modify: `apps/flutter_architecture/test/features/pencil_compatibility/presentation/write_precheck_architecture_contract_test.dart` — parallel whole-screen renderer guard。
- Modify: `apps/flutter_architecture/test/features/pencil_compatibility/presentation/write_precheck_responsive_test.dart` — 明確區分fidelity viewport與layout-health viewport。
- Create: `docs/audits/milestone_33/33-c2_runtime_visual_contract_review.md`。

### Single-renderer implementation

- Move: `apps/flutter_architecture/lib/features/pencil_compatibility/presentation/pages/write_precheck_canonical_canvas.dart` → `apps/flutter_architecture/lib/features/pencil_compatibility/presentation/pages/write_precheck_projected_canvas.dart` — 從canonical-only tree改為唯一projected screen tree，公開`WritePrecheckProjectedCanvas`與`WritePrecheckProjection`。
- Modify: `apps/flutter_architecture/lib/features/pencil_compatibility/presentation/pages/write_precheck_view.dart` — 移除`>=900`whole-screen branch與第二套Column tree，所有正常portrait widths都使用同一projected canvas。
- Delete after migration if no references remain:
  - `apps/flutter_architecture/lib/features/pencil_compatibility/presentation/widgets/precheck_actions.dart`
  - `apps/flutter_architecture/lib/features/pencil_compatibility/presentation/widgets/precheck_data_row.dart`
  - `apps/flutter_architecture/lib/features/pencil_compatibility/presentation/widgets/precheck_progress.dart`
  - `apps/flutter_architecture/lib/features/pencil_compatibility/presentation/widgets/precheck_record_tile.dart`
  - `apps/flutter_architecture/lib/features/pencil_compatibility/presentation/widgets/precheck_section_card.dart`
- Modify affected widget／semantics／golden tests to assert one tree, not a second renderer。
- Update canonical golden only after reviewed implementation intentionally changes rendering。
- Create runtime golden only after C2 RED proves current source fails the fixed runtime contract。
- Create: `docs/audits/milestone_33/33-c3_single_renderer_implementation_review.md`。

### Android acceptance and closure

- Reuse: `apps/flutter_architecture/integration_test/pencil_compatibility_runtime_capture_test.dart`。
- Reuse: `apps/flutter_architecture/test_driver/integration_test_driver.dart`。
- Replace/supersede: `docs/audits/milestone_33/visual_validation/android-runtime-screenshot.png` only after fresh capture and explicit review。
- Create: `docs/audits/milestone_33/visual_validation/runtime-reference-360x640.png` as review copy only if identical to the locked derived reference; source-of-truth derived reference remains under `docs/design_sources/...`。
- Create: `docs/audits/milestone_33/33-c4_android_runtime_fidelity_review.md`。
- Create: `docs/audits/milestone_33/33-c5_corrective_holistic_final_review.md`。
- Release/update only after accepted C4: `VERSION`, `CHANGELOG.md`, current roadmap/project-context routing and post-release evidence for expected 1.15.1。

---

### Task C1: Canonicalize the Single-Renderer Governance Contract

**Files:**
- Create: `tools/docs/test_pencil_single_renderer_policy.py`
- Modify: `docs/adr/adr-028-repository-local-pencil-to-flutter-design-implementation-workflow.md`
- Modify: `.agents/skills/implementing-pencil-flutter-design/references/flutter-mapping.md`
- Modify: `.agents/skills/implementing-pencil-flutter-design/references/visual-validation.md`
- Modify: `.agents/skills/implementing-pencil-flutter-design/references/pressure-scenarios.md`
- Modify: `docs/guides/pencil_to_flutter_workflow.md`
- Create: `docs/audits/milestone_33/33-c1_governance_contract_review.md`

**Interfaces:**
- Consumes: accepted Corrective Design and accepted ADR amendment draft。
- Produces: stable rule `one accepted screen → one whole-screen visual tree` and runtime-fidelity execution contract used by C2-C5。

- [ ] **Step 1: Write failing governance pressure assertions**

Create `tools/docs/test_pencil_single_renderer_policy.py` with a small `unittest.TestCase` that reads only the canonical policy files and asserts all of these semantic markers:

```txt
canonical viewport is design/comparison space, not Flutter breakpoint
parallel whole-screen visual renderer is forbidden
runtime no-overflow is layout health, not fidelity
supported runtime requires visual fidelity evidence
top-level FittedBox/Transform.scale remains forbidden
```

The test must inspect these exact files:

```python
POLICY_FILES = (
    Path('docs/adr/adr-028-repository-local-pencil-to-flutter-design-implementation-workflow.md'),
    Path('.agents/skills/implementing-pencil-flutter-design/references/flutter-mapping.md'),
    Path('.agents/skills/implementing-pencil-flutter-design/references/visual-validation.md'),
    Path('docs/guides/pencil_to_flutter_workflow.md'),
)
```

Assertions check normalized text markers rather than implementation code; this is a regression test for the existing owners, not a second policy authority.

- [ ] **Step 2: Run the focused governance test and verify RED**

Run the selected docs/Skill unit test plus:

```txt
python -m unittest tools.docs.test_pencil_single_renderer_policy
dart run melos run docs_check
```

Expected: focused assertion fails because current ADR/Skill references still allow the 1.15.0 ambiguity; existing docs checker itself remains structurally healthy。

- [ ] **Step 3: Canonicalize ADR-028 and Skill/Guide wording**

Apply the accepted amendment exactly:

```txt
one accepted .pen screen
→ one Flutter visual component model
→ canonical/runtime share same whole-screen tree
→ canonical size is design/comparison space
→ runtime projection uses true widget geometry
→ runtime fidelity + semantic review required
```

Supersede the old 33-10/33-12 runtime visual PASS in the new audit without deleting historical evidence。

- [ ] **Step 4: Run focused GREEN and documentation regression**

Run:

```txt
python -m unittest tools.docs.test_skill_lock tools.docs.test_check_docs
python -m unittest tools.docs.test_pencil_single_renderer_policy
dart run melos run docs_check
git diff --check
```

Expected: PASS。

- [ ] **Step 5: Complete two-layer review and commit C1**

Record focused findings, fresh re-review, whole-Task review and open P0/P1 disposition in `33-c1_governance_contract_review.md`。

Commit:

```txt
docs(pencil): 修正單一渲染視覺治理契約
```

---

### Task C2: Lock the Runtime Projection Reference and Make 1.15.0 Correctly RED

**Files:**
- Modify: `docs/visual_authority/pencil-compatibility-write-precheck/manifest.md`
- Create: `docs/design_sources/pencil-compatibility-write-precheck/pencil-runtime-360x640.png`
- Modify: `apps/flutter_architecture/test/support/visual_diff.dart`
- Modify: `apps/flutter_architecture/test/support/visual_diff_test.dart`
- Create: `apps/flutter_architecture/test/support/runtime_reference_derivation_test.dart`
- Create: `apps/flutter_architecture/test/features/pencil_compatibility/presentation/write_precheck_runtime_golden_test.dart`
- Create: `apps/flutter_architecture/test/features/pencil_compatibility/presentation/write_precheck_runtime_visual_diff_test.dart`
- Modify: `apps/flutter_architecture/test/features/pencil_compatibility/presentation/write_precheck_architecture_contract_test.dart`
- Modify: `apps/flutter_architecture/test/features/pencil_compatibility/presentation/write_precheck_responsive_test.dart`
- Create: `docs/audits/milestone_33/33-c2_runtime_visual_contract_review.md`

**Interfaces:**
- Consumes: canonical Pencil preview `941 × 1672`, fixed target `360 × 640`, tolerance `8`, ratio threshold `0.08`, mean threshold `8.0`。
- Produces:
  - `projectPng({required File source, required File output, required int width, required int height}) → Future<void>` test-support interface。
  - locked derived reference `pencil-runtime-360x640.png` with manifest hash。
  - RED architecture and runtime visual tests that fail against 1.15.0 source for the intended reason。

- [ ] **Step 1: Write projection utility tests before implementation**

Cover:

```txt
941×1672 input → exact 360×640 output
same input bytes + same target → same output SHA on the validation host
invalid zero/negative dimensions → ArgumentError
missing input → FileSystemException
source artifact remains unchanged
```

Projection implementation must use Flutter image decoding/scaling in test support, not production UI and not candidate-dependent resizing。

- [ ] **Step 2: Run projection tests and observe RED**

Run:

```txt
cd apps/flutter_architecture
flutter test test/support/visual_diff_test.dart
```

Expected: fails because `projectPng` does not exist。

- [ ] **Step 3: Implement the deterministic projection helper and generate the reference once**

Implementation contract:

```dart
Future<void> projectPng({
  required File source,
  required File output,
  required int width,
  required int height,
})
```

Use `dart:ui` image codec target dimensions; write PNG bytes to the explicit output path. Generate only from `pencil-preview.png`, record width/height/bytes/SHA-256 in manifest before any runtime candidate comparison。

Create `runtime_reference_derivation_test.dart` so its default path verifies the tracked reference dimensions/hash, while the explicit update path is guarded by:

```dart
const updateReference = bool.fromEnvironment(
  'UPDATE_PENCIL_RUNTIME_REFERENCE',
);
```

Generate the tracked reference exactly once before runtime candidate tests with:

```txt
cd apps/flutter_architecture
flutter test \
  --dart-define=UPDATE_PENCIL_RUNTIME_REFERENCE=true \
  test/support/runtime_reference_derivation_test.dart
```

Immediately rerun without the define and record the resulting SHA-256 in the manifest. Later C2/C3/C5 validation runs use the default verification path and must not regenerate it。

- [ ] **Step 4: Add runtime golden and visual-diff RED tests**

Render `WritePrecheckView` at:

```txt
physicalSize = 360 × 640
DPR = 1.0
locale = zh_TW
```

The runtime golden test captures exactly one `WritePrecheckView`. The runtime visual diff compares that candidate against the locked `pencil-runtime-360x640.png` using:

```txt
perChannelTolerance = 8
differentPixelRatio <= 0.08
meanAbsoluteChannelDelta <= 8.0
ignore regions = none
```

- [ ] **Step 5: Extend architecture guard and observe current-source RED**

The architecture test must reject source patterns equivalent to:

```dart
if (constraints.maxWidth >= 900) {
  return WritePrecheckCanonicalCanvas(...);
}
// separate whole-screen tree
```

It must also continue rejecting full-screen raster and `FittedBox` fixed-canvas cheats。

Run focused tests. Expected current 1.15.0 failures:

```txt
parallel whole-screen renderer guard: FAIL
360×640 runtime visual diff: FAIL
```

The failures must be caused by the known defect, not missing fixtures or syntax errors。

- [ ] **Step 6: Review the locked contract and commit C2 while RED remains intentional**

The C2 commit may contain intentionally failing corrective acceptance tests because they are the executable reproduction for C3; record exact RED metrics and reason in `33-c2_runtime_visual_contract_review.md`。

Commit:

```txt
test(pencil): 鎖定runtime單一渲染視覺契約
```

---

### Task C3: Replace the Parallel Renderers with One Projected Flutter Tree

**Files:**
- Move: `apps/flutter_architecture/lib/features/pencil_compatibility/presentation/pages/write_precheck_canonical_canvas.dart` → `apps/flutter_architecture/lib/features/pencil_compatibility/presentation/pages/write_precheck_projected_canvas.dart`
- Modify: `apps/flutter_architecture/lib/features/pencil_compatibility/presentation/pages/write_precheck_view.dart`
- Delete unused parallel renderer widget files listed in Planned File Structure after reference scan proves zero consumers。
- Modify affected presentation tests/goldens only as required by the single tree。
- Create: `docs/audits/milestone_33/33-c3_single_renderer_implementation_review.md`

**Interfaces:**
- Consumes: C2 RED tests and locked reference contract。
- Produces:
  - `WritePrecheckProjectedCanvas({required WritePrecheckCopy copy, required double availableWidth})` single-tree interface。
  - `WritePrecheckProjection({required double availableWidth})` with `static const double designWidth = 941.0`, `static const double designHeight = 1672.0`, `double get scale`, `double px(double designPixels)`。
  - design width constant `941.0` and `visualScale = projectedWidth / 941.0`。
  - same visual components for canonical and runtime。

- [ ] **Step 1: Verify C2 RED immediately before production changes**

Run the architecture and runtime visual tests and record the same known failures. If they unexpectedly pass before production change, stop and inspect the test rather than weakening it。

- [ ] **Step 2: Introduce one design-space projection helper inside the existing feature**

The helper exposes scalar projection only, for example:

```dart
final class WritePrecheckProjection {
  const WritePrecheckProjection({required this.availableWidth});

  static const double designWidth = 941.0;
  static const double designHeight = 1672.0;

  final double availableWidth;
  double get scale => availableWidth / designWidth;
  double px(double designPixels) => designPixels * scale;
}
```

Do not create a general-purpose design renderer package。

- [ ] **Step 3: Convert the accepted canonical tree to the sole projected tree**

Every visible `Positioned`, size, radius, stroke, shadow extent, icon geometry and feature-local text metric must derive from the projection helper. Root visual size is:

```txt
width  = 941 × visualScale
height = 1672 × visualScale
```

Do not wrap the root in `Transform.scale` or `FittedBox`。

- [ ] **Step 4: Remove the `<900` alternate whole-screen Column renderer**

`WritePrecheckView` always composes the same projected screen for normal portrait widths. Height insufficiency uses scrolling; width-specific adaptation may occur only inside the same components and only when a test proves the need。

After migration, run a source reference scan. Delete the old parallel renderer widget files only when no production/test owner remains。

- [ ] **Step 5: Make architecture and runtime visual tests GREEN without relaxing thresholds**

Run:

```txt
cd apps/flutter_architecture
flutter test test/features/pencil_compatibility/presentation/write_precheck_architecture_contract_test.dart
flutter test test/features/pencil_compatibility/presentation/write_precheck_runtime_golden_test.dart
flutter test test/features/pencil_compatibility/presentation/write_precheck_runtime_visual_diff_test.dart
flutter test test/features/pencil_compatibility/presentation/write_precheck_golden_test.dart
flutter test test/features/pencil_compatibility/presentation/write_precheck_visual_diff_test.dart
flutter test test/features/pencil_compatibility/presentation/write_precheck_responsive_test.dart
flutter test test/features/pencil_compatibility/presentation/write_precheck_semantics_test.dart
```

Expected:

```txt
single-renderer guard: PASS
canonical fixed visual gate: PASS
360×640 runtime fixed visual gate: PASS
390×844 layout-health: PASS
226×400 layout-health: PASS
semantics: PASS
```

If canonical rendering changes intentionally because the same tree replaces canonical-only code, regenerate canonical golden only after direct Pencil comparison proves no fidelity regression; never update a failing golden merely to make the test green。

- [ ] **Step 6: Run focused analyze and anti-cheat review**

Run source scans for `FittedBox`, top-level `Transform.scale`, `Image.asset/file`, duplicate root renderer and dead widget files. Run `flutter analyze` and affected tests。

- [ ] **Step 7: Complete two-layer review and commit C3**

Record before/after runtime metrics, canonical metrics, deleted parallel files and all findings in `33-c3_single_renderer_implementation_review.md`。

Commit:

```txt
fix(ui): 統一Pencil手機畫面渲染模型
```

---

### Task C4: Capture and Obtain Actual Android Runtime Fidelity Acceptance

**Files:**
- Reuse/Modify if necessary: `apps/flutter_architecture/integration_test/pencil_compatibility_runtime_capture_test.dart`
- Reuse: `apps/flutter_architecture/test_driver/integration_test_driver.dart`
- Update: `docs/audits/milestone_33/visual_validation/android-runtime-screenshot.png`
- Create: `docs/audits/milestone_33/33-c4_android_runtime_fidelity_review.md`

**Interfaces:**
- Consumes: C3 single renderer and locked 360×640 derived Pencil reference。
- Produces: fresh BlueStacks screenshot, hash, runtime metrics, side-by-side semantic disposition and explicit user visual acceptance gate。

- [ ] **Step 1: Build the current corrective APK with repository-owned environment governance**

Use the repository development build route and an external `ARTIFACT_DIR`; verify package id remains `com.example.flutterarchitecture.development`。

- [ ] **Step 2: Run the Android runtime capture on the explicit BlueStacks device**

Require an online explicit device id. Capture through the production route/widget tree and record:

```txt
physical size
logical size
DPR
textScale
APK package id
screenshot SHA-256
```

- [ ] **Step 3: Verify runtime image against the locked visual contract**

Compare the actual runtime content with the locked 360×640 Pencil-derived reference. System/device-pixel differences must use a predeclared normalization/crop contract; do not invent masks after seeing the candidate。

- [ ] **Step 4: Perform semantic side-by-side review**

Explicitly review:

```txt
hierarchy
proportion
typography hierarchy
spacing rhythm
icons
progress state
hero
summary/results/records/guidance
primary/secondary/end actions
content completeness
theme/color ownership
```

- [ ] **Step 5: Put the real App on screen and stop at the user acceptance gate**

Install the freshly built APK, navigate to Write Pre-check, keep BlueStacks in the foreground, and ask the user to inspect the actual runtime. **Do not mark C4 accepted before the user says the runtime visual is accepted.**

- [ ] **Step 6: After user acceptance, finalize review and commit C4**

If rejected, C4 remains open and returns to C3 with a new visual finding. If accepted, record the explicit acceptance in `33-c4_android_runtime_fidelity_review.md` and commit:

```txt
test(ui): 驗證Android單一渲染視覺忠實度
```

---

### Task C5: Corrective Holistic Final Review, 1.15.1 Release, and Post-release Closure

**Files:**
- Create: `docs/audits/milestone_33/33-c5_corrective_holistic_final_review.md`
- Modify after review: `VERSION`, `CHANGELOG.md`, current roadmap/project-context/readme routing。
- Create post-release corrective evidence under `docs/audits/milestone_33/`。

**Interfaces:**
- Consumes: C1-C4 accepted, including explicit user runtime visual acceptance。
- Produces: final corrective disposition and, only if accepted, expected Template Baseline 1.15.1 release/closure。

- [ ] **Step 1: Cross-task authority review**

Verify ADR, Skill, Guide, manifest, production source, tests and visual evidence all describe the same single-renderer contract. Confirm old `Completed / Archived` dirty closure state was not used to bypass corrective work。

- [ ] **Step 2: Run full fresh repository regression**

At minimum:

```txt
dart pub get
dart run melos run build_runner
python -m unittest tools.docs.test_skill_lock tools.docs.test_check_docs tools.visual.test_verify_visual_authority
dart run melos run docs_check
dart run melos run analyze
dart run melos exec -- flutter test
flutter build bundle --target lib/main_development.dart --dart-define=NATIVE_ENVIRONMENT=development
repository-governed Android development artifact build
canonical visual diff
runtime visual diff
```

- [ ] **Step 3: Freeze Corrective Final Review disposition**

Required for release candidate:

```txt
Open P0 = 0
Undispositioned P1 = 0
canonical visual PASS
runtime visual PASS
user runtime acceptance PASS
single-renderer architecture PASS
```

- [ ] **Step 4: If disposition approves release, publish 1.15.1 without rewriting 1.15.0**

Update release identity/current docs, independently review/commit, fast-forward merge, ordinary push, then create a fresh clean-checkout from the release SHA and rerun Skill discovery, docs/analyze/tests/builds and both visual gates。

- [ ] **Step 5: Close only after post-release evidence**

Milestone 33 returns to`Completed / Archived`only when remote equality and clean-checkout post-release evidence are complete. Otherwise it remains corrective active。

---

## Plan Self-review

### Spec coverage

- Single whole-screen tree: C1 architecture rule + C2 RED guard + C3 implementation。
- Design-space projection, not breakpoint: C1/C3。
- No top-level scaling/raster cheat: global constraints + C2/C3 anti-cheat tests。
- Theme/Design System/asset ownership preserved: global constraints + C1/C3 review。
- Runtime derived reference fixed before candidate: C2。
- Runtime visual gate beyond no-overflow: C2/C4。
- Existing canonical fidelity protected: C3/C5。
- Android actual runtime + user acceptance: C4 hard gate。
- Skill/Guide/ADR correction: C1。
- Full two-layer governance and 1.15.1 release/post-release: all Tasks + C5。

### Placeholder scan

Placeholder scan結果為零；所有code steps、test commands、targets、thresholds與candidate-independent reference規則都已具體化。

### Type/interface consistency

- Runtime target is consistently `360 × 640` logical at DPR 1.0 for Flutter reference/golden comparison; physical Android capture records actual DPR separately。
- `projectPng` always consumes a source PNG and explicit output/width/height; derived reference never consumes a Flutter candidate。
- Canonical and runtime gates both consume `WritePrecheckView`, guaranteeing same production route/tree rather than a test-only renderer。

## Approval Gate

本Plan已完成focused review、fresh re-review、whole-Plan review與documentation validation，並於2026-08-07取得使用者書面核准；狀態為`accepted`。Managed corrective worktree已可建立並依C1 → C5執行；C4使用者runtime visual acceptance仍是C5 release closure前不可繞過的hard gate。
