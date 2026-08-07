---
document_type: phase-review
status: accepted
authoritative_for:
  - milestone-33-task-33-10-visual-acceptance-review
last_reviewed_baseline: 1.14.0
---

# Milestone 33 — Task 33-10 Visual Acceptance Review

## Scope

本Task完成：

- deterministic PNG diff utility與unit tests；
- `941 × 1672` Windows canonical candidate對Pencil reference的固定門檻驗收；
- historical Flutter proof的relative non-regression gate；
- Android development runtime screenshot capture；
- semantic visual review；
- 執行期間發現的Android flavor integration-test guard corrective fix。

沒有變更`.pen`、visual authority hash、8% threshold、per-channel tolerance、ignore region或canonical viewport。

## Fixed Acceptance Contract

```txt
current reference: docs/design_sources/pencil-compatibility-write-precheck/pencil-preview.png
current candidate: apps/flutter_architecture/test/features/pencil_compatibility/goldens/write_precheck_windows.png
historical benchmark: docs/design_sources/pencil-compatibility-write-precheck/historical-flutter-benchmark.png
per-channel tolerance: 8
ignore regions: none
resizing: forbidden
differentPixelRatio <= 0.08
meanAbsoluteChannelDelta <= 8.0
```

Fresh current result：

```txt
differentPixelRatio: 0.07781856825427495
meanAbsoluteChannelDelta: 2.995617318947063
maxChannelDelta: 243
```

Absolute gate：PASS。

## Visual Convergence Review

Initial implementation diff約`60.31%`。依section／pixel cluster逐步定位後，主要corrective roots包括：

- Pencil centered stroke與Flutter inside border語義不同；
- Phosphor package font family在golden loader未以`packages/<package>/<family>`載入，造成Light／Regular／Thin實際回退到相同glyph；
- Pencil completed steps的content為Unicode `✓`而非數字`1`／`2`；
- Flutter中文字面寬度與Pencil renderer不同，少數fixed authority text需要feature-local raster compensation；
- Pencil shadow blur／spread與Flutter BoxShadow語義不同；
- primary action的Pencil glow向上延伸到`y=1440..1447`，Flutter原本缺少該尾端。

最後一項修正後fresh固定gate由`8.17935%`降至`7.7818568%`，沒有threshold widening或raster shortcut。

## F-33-10-01 — Historical benchmark與current canonical reference尺寸不同

- Severity：P1 execution-contract ambiguity。
- Initial failure：`comparePngs`正確fail closed：`941x1672 != 226x400`。
- Root cause：Task 33-4 admitted historical Flutter proof與當時Pencil admission preview均為`226 × 400`；Task 33-6只依accepted Design把current Pencil preview替換為fresh `941 × 1672` canonical export。Historical Flutter benchmark沒有也不得被upscale。
- Immutable contemporaneous reference：commit `c72501605c78588a10e29c9eab1ece3ac7d4bf8e`的`docs/design_sources/pencil-compatibility-write-precheck/pencil-preview.png`。
- Resolution：current candidate仍對current canonical reference比較；historical benchmark則對其immutable contemporaneous `226 × 400` Pencil preview比較。兩組各自在native dimensions計算normalized metrics，再做relative no-regression comparison。
- Explicitly forbidden／unused：resize、upscale、crop、mask、threshold change、benchmark promotion。

Historical native-size result：

```txt
differentPixelRatio: 0.8696460176991151
meanAbsoluteChannelDelta: 25.03734513274336
```

Current candidate明顯優於historical proof；relative gate PASS。

## F-33-10-02 — Android flavor guard阻擋integration-test target

- Severity：P1 validation blocker。
- Initial failure：development Gradle task拒絕`integration_test/pencil_compatibility_runtime_capture_test.dart`，因既有guard只接受`lib/main_development.dart`。
- Root cause：`tasks.withType<FlutterTask>()`把正常app build entrypoint guard套到integration-test target；任何flavored Android integration test都會被阻擋。
- RED：新增`test_android_flavor_guard_preserves_integration_test_target`，要求integration-test target例外存在，同時普通錯誤target仍受原environment entrypoint restriction。
- Fix：只對`explicitTarget.startsWith("integration_test/")`保留Flutter傳入的`targetPath`；其他target維持原fail-closed guard，`NATIVE_ENVIRONMENT`仍由Gradle注入。
- Fresh GREEN：focused environment contract tests PASS；Android development app build與runtime capture均PASS。

沒有新增production debug menu、initial route override或hidden runtime flag。

## F-33-10-03 — AutoRoute push Future造成capture deadlock

- Severity：P1 test blocker。
- Symptom：runtime capture在Shell與theme／locale preference完成後長時間等待。
- Root cause：`await AppRouter.push(...)`等待route被pop後的result，而capture需要route保持active。
- Fix：使用`unawaited(getIt<AppRouter>().push(...))`，再以finder等待`WritePrecheckPage`。
- Fresh result：route呈現、surface conversion、screenshot與test teardown全部完成。

診斷checkpoint在root cause確認後已移除；final test只保留runtime metrics輸出。

## Android Build and Runtime Evidence

Current CI artifact governance要求platform script使用external`ARTIFACT_DIR`。Windows Git Bash又發現`python3`解析到WindowsApps alias並exit `49`；依script既有`PYTHON_BIN`contract使用`PYTHON_BIN=python`，未修改CI script。

Development build：

```txt
artifact root:
C:/Users/crazy/AppData/Local/flutter_architecture/ci-artifacts/
  milestone-33-task33-10/android/development

artifact: flutter-architecture-development-debug.apk
package_id: com.example.flutterarchitecture.development
api_mode: mock
build_mode: debug
result: PASS
```

Runtime target：

```txt
device id: emulator-5554
model: SM-S908E
Android 9 / API 28
physical: 540 × 960
logical: 360 × 640
DPR: 1.5
font scale: 1.0
```

Final screenshot：

```txt
path: docs/audits/milestone_33/visual_validation/android-runtime-screenshot.png
bytes: 307384
SHA-256: 358d7cbeea737ff8fefeb2629cfffca6ccf214c828c127c587149c2928b96919
```

Driver source與tracked evidence經`fc /b`確認exact equality。

Runtime logs包含BlueStacks Android 9的Window Sidecar class warning與Secure Storage 0-item algorithm migration；migration完成且test GREEN，沒有UI blocker。詳細semantic disposition見`visual_validation/review.md`。

## Evidence Hashes

| Artifact | Dimensions | Bytes | SHA-256 |
|---|---:|---:|---|
| `write_precheck_windows.png` | 941 × 1672 | 450131 | `533cc857149f831046dcce0804c4121d7731118ff8f54915dae103be25d6a020` |
| `canonical-render.png` | 941 × 1672 | 450131 | `533cc857149f831046dcce0804c4121d7731118ff8f54915dae103be25d6a020` |
| `reference-diff.png` | 941 × 1672 | 215570 | `631758e70335447f902305554ba69e7f7d085d2382852b47f2a40ce37ad905ee` |
| `benchmark-diff.png` | 226 × 400 | 8372 | `be98816b0af65a30e410b00f8722180d90ab8af4b31f699e8468e3b636b3d624` |
| `android-runtime-screenshot.png` | 540 × 960 | 307384 | `358d7cbeea737ff8fefeb2629cfffca6ccf214c828c127c587149c2928b96919` |

## Semantic Review

`visual_validation/review.md`結果：

```txt
hierarchy: PASS
typography: PASS
spacing: PASS
icons: PASS
progress states: PASS
content completeness: PASS
contrast: PASS
touch target: PASS
narrow layout: PASS
Android renderer differences: PASS with recorded diagnostics
```

Android screenshot為`360 × 640` logical窄版首屏；完整下方flow依既有responsive scroll contract可達。沒有把Android viewport冒充canonical `941 × 1672` pixel master。

## Task Review Disposition

## Fresh Completion Validation

Task review文件完成後執行：

```txt
cd apps/flutter_architecture
flutter test test/support/visual_diff_test.dart test/features/pencil_compatibility/presentation
→ 19 tests passed

flutter analyze \
  integration_test/pencil_compatibility_runtime_capture_test.dart \
  test_driver/integration_test_driver.dart
→ No issues found

cd ../..
python -m unittest tools.ci.test_environment_contract
→ 10 tests passed

dart run melos run docs_check
→ Documentation check passed

git diff --check
→ passed
```

Android development build與final `flutter drive`另於前述runtime evidence section記錄，兩者均為exit `0`／`All tests passed.`。

Canonical visual diff在final renderer bytes上fresh重跑，current absolute gate與historical relative gate均PASS。

```txt
Focused visual review: PASS after corrective convergence
Historical relative review: PASS
Android runtime capture: PASS
Semantic review: PASS
Open P0: 0
Open P1 without disposition: 0
Task 33-10: ACCEPTED
```

Final validation commands與commit evidence在Task completion commit前fresh執行；若任何final gate失敗，本accepted disposition立即失效並回到open。
