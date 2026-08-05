---
document_type: phase-review
status: accepted
authoritative_for:
  - milestone-33-task-33-9-flutter-validation-review
last_reviewed_baseline: 1.14.0
---

# Milestone 33 — Task 33-9 Flutter Validation Review

## Scope

本review涵蓋：

- Presentation-only architecture and anti-raster contract。
- English／Traditional Chinese localization key parity。
- English／zh_TW semantics and action accessibility。
- Canonical `941 × 1672` Windows golden baseline and deterministic font loading。
- Canonical complete-flow visibility、mobile／extreme-narrow regression and responsive density correction。
- App analyze and development bundle build evidence。

本Task不產生runtime screenshot、不執行Pencil-versus-Flutter deterministic diff，也不宣稱Milestone 33 visual acceptance；這些責任屬於Task 33-10。

## TDD Evidence

### Architecture、localization and semantics contracts

Production correction前新增：

```txt
write_precheck_architecture_contract_test.dart
write_precheck_semantics_test.dart
app_localizations_test.dart pencilPrecheck parity case
```

The architecture contract rejects：

- `domain/` or `data/` layers。
- Bloc、Repository、UseCase、`getIt` or `injectable` dependencies。
- `Image.asset`／`Image.file` authority embedding。
- `FittedBox` fixed-canvas scaling in `WritePrecheckView`。

The localization contract compares every `pencilPrecheck*` key across `app_en.arb`、`app_zh.arb` and `app_zh_TW.arb`。

The semantics contract validates English and zh_TW section labels、all four numbered steps、primary action and end-flow action at `390 × 844`。

### Golden RED

The first golden test run did not reach the intended baseline RED because the current Flutter `testWidgets` API accepts `bool? skip`, while the initial conditional produced `Object` from `bool`／`String` branches。

Focused investigation read the installed Flutter test API and corrected the platform gate to：

```dart
skip: !Platform.isWindows
```

The fresh rerun then produced the intended RED：

```txt
Golden file does not exist:
write_precheck_windows.png
```

Only after this missing-baseline RED was observed was `--update-goldens` used。

## Deterministic Font Review

`load_pencil_compatibility_test_fonts.dart` loads：

- Flutter SDK `Roboto-Regular.ttf` as `Roboto`。
- Flutter SDK Material Icons font as `MaterialIcons`。
- Windows `NotoSansTC-VF.ttf` as `Noto Sans TC`。
- Every declared `phosphoricons_flutter 1.0.0` font family and asset resolved from `.dart_tool/package_config.json` and the package pubspec。

All required files are fail-closed. The test does not silently substitute a missing authority or icon font。

## Initial Canonical Golden Finding

The initial `941 × 1672` golden was successfully generated：

```txt
width: 941
height: 1672
bytes: 500353
SHA-256: 677631985c10a0a9488c9365839b57f1b745703343d5a7a71ebd8dc307646a10
```

Manual whole-screen thumbnail review found a P1 visual defect：the canonical viewport showed content only through the records section; guidance and all actions were below the visible frame。

### F-33-9-01 — Canonical flow was incomplete at the accepted viewport

- Severity：P1 visual authority violation。
- Reproduction：add a canonical viewport assertion that the `precheckEndFlowAction` rectangle bottom is less than or equal to `1672`。
- RED result：actual bottom `2256.0`。
- A temporary layout probe identified the main expansion：

```txt
header:     80 px
progress:   55 px
hero:      191 px
summary:   428 px
results:   440 px
records:   331 px
guidance:  327 px
actions ended at 2256 px
```

- Comparison with the canonical Pencil preview confirmed that the accepted screen uses a higher-density canonical composition while still containing the complete flow。
- Fix：introduce a normal responsive `dense` presentation contract only when viewport width is at least `800`。It reduces canonical section gaps、card／row／record／guidance／action padding and typography while preserving normal Flutter layout, exact palette, Phosphor identities and content hierarchy。
- Explicitly not used：`FittedBox`、transform scaling、raster embedding、viewport clipping or removed content。
- Mobile and extreme-narrow modes retain the original readable spacing and remain scrollable。
- Fresh canonical result：end-flow is inside the accepted `1672` height。

The temporary layout probe was deleted after root-cause analysis。

## Golden Regression Proof

The existing pre-correction baseline was rerun after the validated density correction and correctly failed：

```txt
Pixel test failed, 80.19%, 1261695px diff detected.
```

This proves the golden is behaviorally sensitive rather than a test that passes regardless of rendering changes。

The baseline was then regenerated for the reviewed corrected output and rerun without `--update-goldens`。

Final canonical artifact：

```txt
path: test/features/pencil_compatibility/goldens/write_precheck_windows.png
width: 941
height: 1672
bytes: 468911
SHA-256: 57cad4b37c6182f6722b923fdffaed736cd4e5647b9e8ece8d2b241e2d6d3185
```

Fresh golden test：PASS。

## Manual Semantic Visual Review

Manual whole-screen and bottom-region inspection of temporary downscaled review images confirmed：

- Header、progress、hero and all four content sections are visible within the canonical frame。
- The gold primary action is visually dominant and not clipped。
- Both secondary outline actions are present below the primary action。
- The end-flow action remains visible below the secondary actions。
- Dark background、cyan／gold hierarchy、card grouping and shield focal point remain consistent with the accepted Pencil direction。
- Traditional Chinese glyphs and Phosphor icons render as glyphs rather than missing-font boxes。

The temporary review thumbnails were not added to repository authority. Flutter golden failure feedback files were removed after diagnosis; the committed golden is the only Task 33-9 raster baseline。

## Semantics Finding

### F-33-9-02 — Progress step semantics duplicated visible labels

- Severity：P1 accessibility clarity。
- Initial semantics tree labels contained duplicates, for example：

```txt
1. Prepared content
Prepared content
```

- Root cause：`PrecheckStepItem` supplied a semantic label while its visible number／text descendants were also merged into the same node。
- Fix：the step owns one localized numbered `Semantics` label and wraps its internal visual content with `ExcludeSemantics`。The progress parent keeps `explicitChildNodes: true`。
- Fresh English and zh_TW semantics tests：PASS。

The current Flutter test binding also requires the explicit semantics handle to be disposed before end-of-test verification; the test lifecycle now disposes it after all assertions rather than through delayed teardown。

## Architecture Review

Fresh architecture test confirms：

- Feature remains presentation-only。
- No Domain、Data、Bloc、Repository、Use Case or DI abstraction was introduced。
- No full-screen raster authority or fixed-canvas scaling exists。
- Canonical density is a responsive widget property, not a parallel renderer。
- Existing router and Shell contracts remain unchanged in this Task。

## Localization Review

- English、zh and zh_TW contain identical `pencilPrecheck*` key sets。
- Existing locale resolution regressions remain green。
- English and zh_TW semantics consume generated localized copy。
- The known 16 untranslated `app_zh` OTP keys are pre-existing and unrelated to the Pencil prefix。

## Responsive Review

Fresh tested viewports remain：

```txt
941 × 1672 — complete flow visible in canonical density
390 × 844  — readable and scrollable
226 × 400  — readable and scrollable
```

All retain normal layout, no `FittedBox`, no Flutter exception and no overflow assertion。

## Validation

Fresh complete Task command：

```txt
cd apps/flutter_architecture
flutter test \
  test/features/pencil_compatibility \
  test/app/router/app_router_test.dart \
  test/app/localization/app_localizations_test.dart
flutter analyze
flutter build bundle \
  --target lib/main_development.dart \
  --dart-define=NATIVE_ENVIRONMENT=development
```

Fresh results：

```txt
tests: 23 passed
golden: passed without update
analyze: No issues found
development bundle build: exit 0
bundle directory: build/flutter_assets
bundle files: 18
bundle bytes: 107364344
```

Formatting result before the complete validation：

```txt
Formatted 18 files (0 changed)
```

Final repository validation after this review file was created：

```txt
dart run melos run docs_check
→ Documentation check passed

git diff --check
→ passed
```

## Disposition

```txt
Focused review: PASSED after F-33-9-01 and F-33-9-02 fixes
Fresh focused re-review: PASSED
Whole-Task review: PASSED
Open P0: 0
Open P1 without disposition: 0
Task 33-9: ACCEPTED
Next Task after commit: 33-10 Runtime Screenshot and Deterministic Visual Diff
```
