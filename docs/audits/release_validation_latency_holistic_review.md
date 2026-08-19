---
document_type: final-review
status: accepted
authoritative_for:
  - release-validation-latency-holistic-implementation-review
last_reviewed_baseline: 1.25.1
---

# Release Validation Latency Corrective — Holistic Implementation Review

## Scope

本 review 覆蓋 accepted Design / Plan 的 local implementation：planner platform build-kind contract、CI／Android／iOS workflow wiring、exact-candidate fan-out orchestrator、fresh-run identity保護、authority同步與 Test Retention Decision。

本 review 不宣稱新baseline已發布，也不把mocked orchestrator contract當成remote fan-out acceptance。正式release仍需建立exact candidate並用新runner取得fresh GitHub run IDs、head SHA、conclusion與timestamps。

## Result

**PASS — implementation complete; release candidate gate pending。**

Branch：`corrective/release-validation-latency`

Implementation checkpoint：`b912ff0eb90df1b0190f2b0545df2116f1c728d7`

Base authority：`e756933e7912094ade2037719c7ff75dd67f11ce` / Template Baseline `1.25.1`

## Review findings

### R1 — Planner remains the only selection authority

**PASS。** `change_classifier.py`未修改。Build-kind specificity由`validation_planner.py`在既有change-class結果與affected paths內決定；workflow與orchestrator沒有第二套path classifier。

新增outputs：

```text
android_development_build
android_production_build
ios_simulator_build
ios_production_build
```

`android_build`／`ios_build`保留aggregate compatibility與summary用途。

### R2 — Build-kind safety

**PASS。** Direct release probe：

```text
paths = tools/ci/validation_planner.py

android_development_build = false
android_production_build  = true
ios_simulator_build       = false
ios_production_build      = true
```

因此validation-engine-only release只用兩個production sentinels驗證planner→workflow→platform routing。

本corrective exact range因同時修改`.github/workflows/android.yml`與`.github/workflows/ios.yml`，release planner仍正確輸出：

```text
android_development_build = true
android_production_build  = true
ios_simulator_build       = true
ios_production_build      = true
```

這證明workflow-owner risk、shared/dependency/invalid-range類型仍可升級both variants，不因latency目標被降級。

### R3 — Workflow job conditions

**PASS。** Android Development／Production jobs分別依自己的build-kind output；iOS Simulator／Production亦同。Aggregate platform flag不再作為variant job的唯一啟動條件。

Planner execution failure若只能由canonical classifier保留aggregate platform impact，fallback對該平台兩個build-kind都設true，維持fail-closed而非猜測specific variant。

### R4 — Fan-out orchestration

**PASS for implementation contract。** `tools/ci/run_release_validation.py`：

1. 驗clean worktree、local HEAD與remote candidate branch同SHA；
2. 呼叫`plan_release_range`取得canonical plan；
3. 先記錄同SHA既有workflow run IDs；
4. 先dispatch全部selected CI／Android／iOS families；
5. 只接受dispatch後新出現的run IDs，避免誤用舊same-SHA evidence；
6. 再以threaded wait並行等待各family；
7. 驗每個run的head SHA與conclusion；
8. 不修改VERSION、不merge、不push main、不publication。

真正remote fan-out timestamps仍由release-candidate acceptance驗證，不在local implementation review冒充完成。

### R5 — Test Retention Decision

**PASS。** 沒有新增test file。既有`tools/ci/test_validation_planner.py`由18個cases增至21個，只新增三個distinct failure families：

- selected evidence family routing；
- all-family dispatch-before-wait；
- exact-SHA mismatch rejection。

Build-kind path cases合併進既有platform／release table，不建立per-path permutation portfolio。

Retention disposition：**Retain 3 / Merge path permutations / New test file = 0。**

## Validation evidence

修正後planner對local implementation diff判定：

```text
change_classes = docs_content + governance + tooling + validation_engine
validation_level = full
generated_check = true
android_build = false
ios_build = false
```

因此local implementation沒有額外執行平台build。

Selected evidence：

- CI critical owners：52/52 PASS。
- Docs critical owners：6/6 PASS。
- 5-package Flutter analyze：PASS。
- retained Flutter suites（flutter_architecture / auth / api_client）：PASS。
- docs checker：PASS。
- workflow YAML parse：PASS。
- `git diff --check`：PASS。
- generated consistency：PASS on clean checkpoint。

Generated consistency本次Windows clean checkpoint wall-clock約171秒。這仍是local較昂貴gate，但新的release fan-out會讓CI/generated與Android/iOS remote families同時進行，因此不再把約3分鐘generated成本串接到平台等待時間之後。

## Latency disposition

Implementation已消除release操作層的結構性串行：selected independent workflows會先全部dispatch，再共同等待。

對validation-engine-only candidate，平台矩陣由4 variants收斂為2 production sentinels；對真正修改Android/iOS workflow或shared platform contract的candidate仍保留4 variants。

因此latency改善來自兩個來源：

1. `CI || Android || iOS` fan-out，wall-clock趨近最慢family；
2. build-kind risk未命中時不再固定啟動secondary variants。

不設定硬SLA；GitHub queue、toolchain下載與network仍是external variance。

## Open findings

- Open P0 = 0
- Open P1 without disposition = 0
- Remote exact-candidate fan-out acceptance = pending release gate，不是implementation defect。

## Release disposition

本變更修改stable release-pipeline behavior與planner contract，建議 Template Baseline **PATCH `1.25.2`**。

下一合法gate：使用者explicit release authorization → 同步`1.25.2` metadata → 建立exact candidate → push candidate branch → 使用`run_release_validation.py`一次fan-out fresh selected evidence → review timestamps / build-kind job selection → publication → same-SHA identity-only closure。
