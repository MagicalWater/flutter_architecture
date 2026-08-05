---
document_type: runtime-evidence
status: accepted
authoritative_for:
  - milestone-33-task-33-6-flutter-mapping-matrix
last_reviewed_baseline: 1.14.0
---

# Milestone 33 — Task 33-6 Flutter Mapping Matrix

## Mapping Rules

- Every extracted design item has exactly one implementation owner.
- Exact Pencil values are not promoted to global Design System tokens without a second real consumer.
- Visible copy is generated Localization authority; production source must not hardcode the accepted Chinese strings.
- Presentation-only proof creates no Domain、Data、Repository、Use Case、Bloc or DI layer.
- Decorative-only primitives carry no behavior or semantics.

## Authority Matrix

| Extracted item | Pencil evidence | Flutter owner | Disposition |
|---|---|---|---|
| Canonical viewport | root `941 × 1672`, DPR 1 | feature-local `PencilCompatibilityVisualSpec` | canonical golden／runtime comparison constants only; not app-wide fixed size |
| NFC background palette | `nfc-bg`, `nfc-bg-deep` | feature-local `PencilCompatibilityVisualSpec` | preserve exact values; no verified global parity |
| NFC surface palette | `nfc-surface`, `nfc-surface-2` and card gradients | feature-local `PencilCompatibilityVisualSpec` | exact local surfaces and gradient stops |
| Border palette | `nfc-border`, `nfc-border-soft` | feature-local `PencilCompatibilityVisualSpec` | exact local outline values |
| Text palette | `nfc-text`, `nfc-muted`, `nfc-dim` | feature-local `PencilCompatibilityVisualSpec` | exact local canonical colors; semantic accessibility checked later |
| Cyan palette | `nfc-cyan`, `nfc-cyan-bright`, `nfc-cyan-deep` | feature-local `PencilCompatibilityVisualSpec` | proof-specific accent／glow values |
| Gold palette | `nfc-gold`, `nfc-gold-soft` | feature-local `PencilCompatibilityVisualSpec` | proof-specific active／warning accent values |
| Font family and exact type scale | `Noto Sans TC`, sizes 15–34, weights normal／500／600／700 | feature-local `PencilCompatibilityVisualSpec` | preserve exact canonical typography; verify Flutter font availability |
| Spacing 4 | exact extracted values | existing `DsSpace.xxs` | direct reuse |
| Spacing 8 | exact extracted values | existing `DsSpace.xs` | direct reuse |
| Spacing 12 | exact extracted values | existing `DsSpace.sm` | direct reuse |
| Spacing 16 | exact extracted values | existing `DsSpace.md` | direct reuse |
| Spacing 24 | exact extracted values | existing `DsSpace.lg` | direct reuse |
| Spacing 32 | exact extracted values | existing `DsSpace.xl` | direct reuse |
| Other fixed gaps／offsets／heights | screen and component coordinates | feature-local `PencilCompatibilityVisualSpec` | retain only values required by canonical hierarchy; responsive layout may derive others |
| Row radius 12 | `nfc-radius-row` | existing `DsRadius.lg` | direct reuse |
| Card radius 24 | `nfc-radius-card` | feature-local `PencilCompatibilityVisualSpec` | no global exact token |
| Button／pill／record radii | 9, 10, 14, 16, 17, 18, 21 | feature-local `PencilCompatibilityVisualSpec` | exact local values |
| All visible copy | title, subtitle, 4 steps, 5 summary rows, 5 results, 2 records, 3 guidance lines, notice and actions | generated localization key | `pencilPrecheck*` prefix; English meaningful, zh／zh-TW accepted Traditional Chinese |
| Status/header/progress composition | status row, back header, four-step track | feature-local widget | responsive `PrecheckProgress` plus page header composition |
| Hero state card | shield state, title, description, status pill | feature-local widget | dedicated feature-local hero widget／section composition |
| Transaction summary card | 5 Data Row instances | feature-local widget | `PrecheckSectionCard` + `PrecheckDataRow` |
| Pre-check results card | 5 compact Data Row instances + technical bar | feature-local widget | `PrecheckSectionCard` + compact `PrecheckDataRow` |
| Expected records card | 2 Record Tile instances | feature-local widget | `PrecheckRecordTile` |
| Recommended next step card | 3 lines + commitment banner | feature-local widget | feature-local section composition |
| Primary action | confirm-and-write button | feature-local widget | visual fixture action; behavior remains inert/minimal unless Plan later assigns it |
| Secondary actions | technical details, edit content | feature-local widget | shared feature-local secondary action implementation |
| End-flow action | x-circle, label, caret | feature-local widget | semantic button/link, not decorative text only |
| Phosphor icons | all icon nodes, library `phosphor`, weight 300 | Phosphor icon | exact identities; no Material approximation |
| Ambient glows | top, left, shield, hero, guidance and step glows | decorative-only Flutter primitive | gradient-painted non-semantic shapes; ignore pointer and semantics |
| Orbit rings and dots | hero decorative ellipses | decorative-only Flutter primitive | painted circles; no interaction |
| Divider／highlight lines | 1–3 px rectangles and strokes | decorative-only Flutter primitive | borders／DecoratedBox／CustomPainter as locally appropriate |
| Shadows | outer shadows, blur 3–22, spread 1–2 | feature-local `PencilCompatibilityVisualSpec` | exact local shadow recipes |
| Gradient direction | Pencil rotation values | feature-local `PencilCompatibilityVisualSpec` | store Flutter-resolved alignments; do not expose Pencil degree semantics to widgets |
| Static status bar content | time/network/battery fixture | decorative-only Flutter primitive | canonical proof only; not platform status authority |

## Component Mapping

| Pencil reusable component | Flutter target | Promotion decision |
|---|---|---|
| `gY9yA` Data Row | `PrecheckDataRow` | feature-local; 10 instances in one proof are not a second product consumer |
| `H3co21` Step Item | private item inside `PrecheckProgress` | feature-local; states are proof-specific |
| `aZMKq` Record Tile | `PrecheckRecordTile` | feature-local |
| `h6mPw5` Secondary Button | private/shared feature-local action widget | feature-local |

## Responsive Disposition

- Canonical `941 × 1672` layout is implemented at logical hierarchy level, not by wrapping the whole screen in `FittedBox`.
- Narrow viewport uses scrollable vertical flow and may stack or wrap action groups while preserving order, copy and state hierarchy.
- Decorative glows／orbits may scale or clip locally, but content, buttons and text cannot be rasterized.
- Exact canonical comparison and narrow accessibility behavior are separate tests; neither may weaken the other.

## Global Design System Decision

```txt
New global color token: NO
New global spacing token: NO
New global radius token: NO
New global component: NO
Reason: no second real consumer and no exact existing theme parity for the NFC palette.
```
