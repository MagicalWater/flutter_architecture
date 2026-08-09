# Milestone 33 Corrective — C3 Single-Renderer Implementation Review

Status: accepted

## Scope

Task C3 replaces the released 1.15.0 whole-screen renderer split with one
production `WritePrecheckView -> WritePrecheckProjectedCanvas` path. This review
is governed by the accepted Corrective Design/Plan and the accepted Runtime
Renderer Calibration Amendment. Gate C direct Pencil/runtime comparison is
diagnostic only; Gate A + Gate B + architecture/layout/source-quality checks own
automation acceptance. Android/user visual acceptance remains C4.

## Admission / Authority Recovery

Fresh cross-conversation admission confirmed before modifying C3:

```txt
managed worktree = C:\Users\crazy\.devspace\worktrees\flutter_architecture-278abc9f
branch = milestone-33-corrective-single-renderer
checkpoint HEAD = bb92ce39287c7a028de230a3a9d7f19647fabb3b
released baseline = 1.15.0
```

All seven checkpoint C3 WIP paths were still present. No reset, clean checkout,
worktree recreation or history rewrite was used.

## Production Architecture Review

Fresh source review confirms:

```txt
WritePrecheckView
  -> one LayoutBuilder
  -> one SingleChildScrollView
  -> one WritePrecheckProjectedCanvas
  -> one accepted whole-screen visual component tree
```

The released split:

```txt
>= 900 -> WritePrecheckCanonicalCanvas
<  900 -> independent responsive Column tree
```

no longer exists. `941 x 1672` is used only as the design/comparison space and
projection basis; it is not a Flutter breakpoint.

Anti-cheat/source review found no production full-screen raster image,
`Image.asset`, `Image.file`, `FittedBox`, test-only renderer, or second
whole-screen renderer. `WritePrecheckCanonicalCanvas` has no remaining
production reference and is deleted by this task.

`_ProjectedComponent` remains a component-local projection/raster-consistency
mechanism inside the same production visual tree. During review an experimental
finding tried to ban every component-local design-space transform. TDD proved
that rule was stricter than the accepted authority: the accepted prohibition is
the top-level/full-canvas shortcut or a parallel whole-screen renderer. Removing
the component-local mechanism caused the live 360x640 renderer to fail Gate B
across nearly every section (`ratio=0.14438368055555556`,
`mean=5.174454210069444`). The experimental policy and implementation change
were therefore reverted; thresholds were not changed.

## Focused Review Findings and Disposition

### C3-F1 — stale second-renderer widget/test ownership

Severity: P1 task-completion finding.

`write_precheck_view_test.dart` still imported and counted the released
parallel-renderer component classes even though production had moved to the
single projected tree. The five old widget files therefore survived only as
test-owned dead production code:

```txt
precheck_actions.dart
precheck_data_row.dart
precheck_progress.dart
precheck_record_tile.dart
precheck_section_card.dart
```

Disposition: fixed. The test now asserts exactly one
`WritePrecheckProjectedCanvas` plus the accepted section/action keys and
semantics. A fresh reference scan shows the old types/files have no production
or test consumer; all five dead widget files are deleted.

### C3-F2 — review drift toward superseded Gate C

Severity: P1 governance finding already recorded by the cross-conversation
checkpoint.

Review re-checked the current glyph/raster WIP against the accepted calibration
amendment. The evidence-supported changes retained in the candidate include the
reviewed Light glyph variants, secondary-label raster weight/horizontal scale,
and separated pencil icon X/Y scaling. Experiments previously recorded as
regressions remain reverted. No new micro-adjustment was added solely to force
the direct Pencil/runtime diagnostic below 8%.

Disposition: accepted. Gate C remains diagnostic and no threshold, crop, ignore
region or derived reference was changed.

### C3-F3 — over-broad component-transform prohibition introduced during review

Severity: review-process finding, not an accepted product defect.

A temporary architecture assertion treated any `OverflowBox` in the projected
canvas as a forbidden fixed-canvas shortcut. The resulting implementation
experiment removed `_ProjectedComponent` design-space raster projection. The
live renderer then produced a 49.04% golden mismatch and fresh Gate B metrics:

```txt
differentPixelRatio = 0.14438368055555556
meanAbsoluteChannelDelta = 5.174454210069444
```

Section diagnostics showed broadly distributed renderer/rasterization delta,
not a localized geometry defect. The temporary assertion, probes and
implementation experiment were removed. This is the required finding
disposition under systematic debugging; it is not part of the final candidate.

## Fresh Acceptance Evidence

### Gate A — Canonical Design Fidelity / hard

Fresh `941 x 1672` golden render and direct Pencil comparison pass the fixed
contract:

```txt
perChannelTolerance = 8
differentPixelRatio = 0.07707811093766684 <= 0.08 PASS
meanAbsoluteChannelDelta = 2.9247655642221195 <= 8.0 PASS
maxChannelDelta = 243
```

The canonical golden stability test also passes from the live production
renderer.

### Gate B — Deterministic Runtime Projection Fidelity / hard

Fresh focused execution:

```txt
target = 360 x 640
perChannelTolerance = 8
differentPixelRatio = 0.09769965277777778 <= 0.10 PASS
meanAbsoluteChannelDelta = 2.495971137152778 <= 4.0 PASS
maxChannelDelta = 215
ignore regions = none
```

The live 360x640 runtime golden stability test passes, so these metrics refer to
the current production candidate rather than a stale renderer.

### Gate C — Pencil-derived Runtime Diagnostic / diagnostic only

```txt
differentPixelRatio = 0.1297222222222222
meanAbsoluteChannelDelta = 3.8164214409722224
maxChannelDelta = 233
```

No hard PASS/FAIL is derived from this metric under the accepted calibration
amendment.

### Architecture / layout / semantics

Fresh focused verification passes:

```txt
single-renderer / anti-raster architecture contract: PASS
941x1672 responsive/layout health: PASS
390x844 responsive/layout health: PASS
226x400 responsive/layout health: PASS
English semantics: PASS
zh_TW semantics: PASS
single projected-tree hierarchy test: PASS
focused Flutter analyze: PASS / no issues
```

## Whole-Task Review

Whole-Task review re-read the production entry point, projected canvas,
architecture contract, runtime/canonical visual tests and stale-widget reference
scan after all findings were dispositioned.

Result:

```txt
Open P0 = 0
Open / undispositioned P1 = 0
single whole-screen production renderer = PASS
canonical Gate A = PASS
runtime Gate B = PASS
Gate C recorded as diagnostic = PASS
layout / semantics = PASS
focused analyze = PASS
test-only / raster / parallel renderer cheat = none found
```

Task C3 is accepted for completion. This does **not** accept Android runtime
visual fidelity. C4 must now perform a fresh development APK build/install,
capture the real BlueStacks `540x960 @ DPR 1.5 -> logical 360x640` runtime,
perform semantic side-by-side review, leave the Write Pre-check screen visible,
and stop for explicit user visual acceptance.
