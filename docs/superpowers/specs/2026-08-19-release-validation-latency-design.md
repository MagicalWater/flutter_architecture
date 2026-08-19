---
document_type: design-spec
status: accepted
authoritative_for:
  - release-validation-latency-corrective-design
last_reviewed_baseline: 1.25.1
---

# Release Validation Latency Corrective — Design

## Requirement Decision

### Request

降低 Template release candidate 從建立 exact SHA 到 publication admission 的 wall-clock latency，特別處理：

1. logical / generated / Android / iOS evidence 被人工串行執行；
2. planner 只有 `android_build` / `ios_build` 粗粒度 flag，導致一旦選到平台，就固定啟動該平台的兩個 build variants。

### Problem

1.25.1 release evidence顯示，單一 workflow 內其實已具備平行性：Android Development Debug 與 Release APK 是 sibling jobs；iOS Simulator 與 Production Release 也是 sibling jobs。iOS exact-candidate run `32222557269` 中 Production Release 約 4m12s、Simulator 約 5m03s，整體 critical path 接近較慢的 5m03s，而不是兩者相加。

真正的額外 wall-clock latency來自release操作把不同 evidence families依序執行：logical/full → generated → Android → remote iOS。上次還額外遇到 Windows `python3` shim、WSL/Git-Bash path與Mac bridge availability摩擦，顯示人工跨環境 orchestration 本身也是不穩定成本。

第二個問題是 platform selection 太粗：`android_build=true` 同時啟動 development-debug與production-release；`ios_build=true` 同時啟動 simulator與production-release。這兩組 configuration 並非完全重複，因此不能全域刪除其中一個，但也不應讓所有 platform-impact risk 都固定等於 `both`。

### Classification

**Level 5 — production release pipeline。**

原因：會改 validation planner public contract、GitHub workflow job selection、release procedure與exact-candidate platform evidence。

### Decision

接受 corrective。採兩層優化：

1. **先消除跨 evidence-family 串行等待**：exact candidate建立後，所有 planner-selected independent gates立即 fan-out；publication只等待 selected gates全部完成。
2. **再把 platform boolean 細分成 build-kind selection**：保留不同 configuration 的真實風險覆蓋，但不再把「需要此平台 evidence」等同「此平台所有 variants 都跑」。

### Non-goals

- 不降低 unknown / invalid-range fail-safe。
- 不因追求速度刪除 production artifact build。
- 不把 Android development 與 production、iOS simulator 與 production宣稱為完全等價。
- 不新增第二套 change classifier。
- 不讓 release automation自行修改 VERSION、merge或push main；publication仍是獨立 gate。
- 不新增大型 release framework 或 daemon。

## Measured current behavior

### 已存在的平行性

`.github/workflows/android.yml`：

- `android-development-debug-apk`
- `android-release-apk`

兩者都只 `needs: classify-changes`，彼此沒有 dependency。

`.github/workflows/ios.yml`：

- `simulator-build`
- `production-release-build`

兩者同樣只 `needs: classify-changes`。

`.github/workflows/ci.yml` 的 quality / generated / tests 亦由 classification 後獨立執行。

因此不需要重寫 workflow DAG 來取得「平台內平行」；主要缺口是 release 操作沒有把 CI / Android / iOS 三條 workflow 同時派送。

## Design A — Release gate fan-out orchestration

### Model

```text
exact candidate SHA + release_base
        ↓
canonical planner
        ↓
selected evidence families
   ├─ logical / docs / generated
   ├─ Android selected build kinds
   └─ iOS selected build kinds
        ↓  (parallel)
all selected evidence GREEN
        ↓
publication admission
```

### Authority

`tools/ci/validation_planner.py` 仍是唯一 selection authority。

新增的 release orchestration 只負責：

1. assert base/head；
2. 讀 planner payload；
3. 同時啟動 selected workflows / local commands；
4. 等待並彙整 exact-SHA result；
5. 任一 selected gate失敗即 non-zero。

它不得重新判斷 changed paths，也不得自行把平台升級或降級。

### First implementation shape

使用一個 bounded repository-owned CLI，例如：

```text
python tools/ci/run_release_validation.py \
  --base <release-base> \
  --head <candidate-sha> \
  --execution-mode github-hosted
```

CLI 本身不建立 candidate、不 bump version、不 publish。

在 `github-hosted` mode 下，selected `ci.yml` / `android.yml` / `ios.yml` workflow dispatch 同時啟動，不再等待前一條結束才派下一條。

若 future/self-hosted mode需要支援，可沿同一 contract擴充；第一版不為尚未需要的多環境 scheduler 建 generic abstraction。

## Design B — Platform build-kind selection

### Planner contract

目前：

```text
android_build: bool
ios_build: bool
```

改為新增明確 outputs：

```text
android_development_build: bool
android_production_build: bool
ios_simulator_build: bool
ios_production_build: bool
```

舊 `android_build` / `ios_build` 在 transitional period 可保留為 aggregate：

```text
android_build = android_development_build || android_production_build
ios_build = ios_simulator_build || ios_production_build
```

workflow job condition只依 build-kind output，不再依 aggregate boolean啟動全部 variants。

### Risk routing

#### Release metadata / docs / governance / ordinary Dart feature

維持 no platform build。

#### Validation engine / planner selection change

目的在驗證「planner → workflow → platform build」端到端 routing，不等同 native configuration mutation。

Release candidate預設要求：

```text
Android production release
iOS production release
```

development/simulator job selection由 permanent workflow contract tests覆蓋，不因 planner本體改變而固定再跑兩個 secondary variants。

若同一 candidate也包含實際 native/dependency/platform-shared risk，依該風險再升級到對應 additional variants。

#### Validation workflow file itself

- `.github/workflows/android.yml` changed → Android **both variants**，因同一 workflow直接擁有兩個 build jobs與其conditions/steps。
- `.github/workflows/ios.yml` changed → iOS **both variants**。
- `.github/workflows/ci.yml` changed → 依 logical/generated risk驗證；不因CI workflow檔名本身啟動平台，除非 candidate同時命中 planner/native/platform risk。

因此1.25.1這種同時修改 planner + Android/iOS workflow本體的 corrective仍合法要求四個 platform variants；本 corrective的主要 wall-clock收益會來自cross-workflow fan-out，而不是錯誤地刪掉 workflow-owning jobs。

#### Android native

- development-specific path / development build script → Development Debug。
- production-specific path / production build script → Production Release。
- shared Android native / Gradle / manifest / plugin configuration → **both**，因兩個 flavor/build-mode契約不同。

#### iOS native

- development/simulator-specific config / development build script → Simulator。
- production/device-specific config / production build script → Production Release。
- shared Xcode/project/Pod/native configuration → **both**，因 simulator SDK/architecture 與 iphoneos release是不同 failure family。

#### Root dependency / toolchain / platform-shared

維持 both variants on affected platforms。Dependency/toolchain change可能影響 debug/release、simulator/device resolution，不以 latency理由降級。

#### Unknown / invalid range

維持 fail-safe logical full + generated + both platforms + both variants。

## Why not simply delete Development / Simulator builds

拒絕。

- Android Debug 與 Release有不同 compiler/optimizer/obfuscation、flavor與artifact contract。
- iOS Simulator 與 iphoneos production有不同 SDK、architecture與native linking surface。
- Template本身宣稱 development / production capability，不能只驗 production 就宣稱所有 platform configuration安全。

真正應刪的是「沒有對應 changed risk仍固定執行的 variant」，不是合法 failure family。

## Expected latency effect

對像 1.25.1 corrective 這類 `validation_engine + workflow` candidate：

Current effective release operation：

```text
logical/generated
→ Android dev + prod
→ iOS sim + prod
```

Target：

```text
CI logical/generated ─────────────┐
Android production ──────────────┼─ parallel
iOS production ──────────────────┘
```

Wall-clock趨近最慢 selected branch，而不是各 family duration相加。以1.25.1 remote iOS約5分鐘為量級，正常 exact-candidate publication admission應以約5～7分鐘級為目標，而不是把各平台時間串接。

這是 latency target，不是硬 SLA；runner queue與network/toolchain setup不在 repository可完全控制範圍。

## Failure semantics

- orchestration dispatch失敗：整體 release gate FAIL，不偷偷跳過該 family。
- selected workflow conclusion不是 success：FAIL。
- returned workflow head SHA與candidate SHA不一致：FAIL。
- planner payload invalid：沿 canonical planner fail-safe；orchestrator不得自行猜。
- selected platform kind沒有對應 workflow job：FAIL。
- publication不得由 orchestration成功自動觸發。

## Test Authoring Decision

Validation engine / release pipeline屬 safety-critical owner，因此允許少量 permanent contract tests，但必須合併進既有 `tools/ci/test_validation_planner.py` / relevant workflow owner；**不得新增 permutation-heavy test file**。

需要覆蓋的 distinct failure families：

1. validation-engine release只選 production sentinels，除非另有 native risk；
2. Android development-specific / production-specific / shared path selection；
3. iOS simulator-specific / production-specific / shared path selection；
4. dependency / platform-shared / invalid-range仍選 both；
5. workflows job conditions使用 build-kind outputs；
6. release orchestrator同時 dispatch selected independent workflows，並拒絕 SHA mismatch / failed conclusion。

Retention：若多個path permutation只證明同一 risk family，merge成 table-driven representative cases。

## Stable authority impact

若 implementation accepted，需同步：

- ADR-023：release validation selection與platform evidence granularity；
- `docs/guides/ci_cd_operations.md`：single-command fan-out procedure；
- `docs/guides/testing_governance.md`：只在其 release validation wording需要時同步，禁止複製 orchestration細節；
- planner/workflows 為 machine truth。

## Rollback

若新 build-kind selection出現 false-negative：

1. 停止 publication；
2. explicit full + both platform variants補 evidence；
3. revert build-kind routing至1.25.1 aggregate semantics；
4. 修正 planner contracts後重新 fresh release review。

Fan-out orchestration可獨立回退為手動 dispatch，不影響 planner changed-risk semantics。

## Acceptance criteria

1. exact candidate一建立，selected CI / Android / iOS families可同時啟動，不再人工串行等待。
2. validation-engine-only release不固定執行 Android Development與iOS Simulator secondary variants。
3. shared native / dependency / platform-shared / invalid-range仍保留 both variants。
4. workflow job selection完全由 planner build-kind outputs控制。
5. orchestrator不擁有 classifier或publication authority。
6. exact-SHA mismatch / dispatch failure / workflow failure均 fail closed。
7. no new permutation-heavy test file；Retention Decision完成。
8. durable docs與machine contract一致，Open P0/P1 = 0。

本 Design 已於 2026-08-19 取得使用者明確核准並轉為 `accepted`。Implementation 仍須依 accepted Implementation Plan 執行。
