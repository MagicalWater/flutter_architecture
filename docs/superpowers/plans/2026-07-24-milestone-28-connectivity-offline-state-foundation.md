---
document_type: implementation-plan
status: accepted
authoritative_for:
  - milestone-28-connectivity-offline-state-implementation-plan
last_reviewed_baseline: 1.9.0
---

# Connectivity and Offline State Foundation Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 建立App-owned typed connectivity authority，並讓Catalog以明確opt-in方式在offline→online後執行non-blocking revalidation。

**Architecture:** Connectivity plugin只存在App adapter；App controller擁有snapshot、stream、resume與dispose lifecycle。Feature只依賴provider-neutral state／transition，Catalog保留自己的cache、refresh與Failure語意。

**Tech Stack:** Flutter、Dart、`connectivity_plus`、flutter_bloc、get_it／injectable、Freezed、gen_l10n、flutter_test、Melos。

---

## Pre-execution gates

- Design authority：`docs/superpowers/specs/2026-07-24-connectivity-offline-state-foundation-design.md`。
- Capability evidence：`docs/audits/connectivity_offline_state_capability_audit.md`。
- Design review：`docs/audits/connectivity_offline_state_design_review.md`。
- 每個Task完成focused review、findings disposition、whole-task review、authority check、驗證與獨立commit後才進下一個Task。
- Task 28-1前不得修改production source；本Plan通過review與commit後解除此gate。

## File map

### New App connectivity boundary

- `apps/flutter_architecture/lib/app/connectivity/connectivity_state.dart`：typed state。
- `apps/flutter_architecture/lib/app/connectivity/connectivity_adapter.dart`：provider-neutral adapter contract。
- `apps/flutter_architecture/lib/app/connectivity/connectivity_controller.dart`：state authority、snapshot／stream／resume ordering與reconnect stream。
- `apps/flutter_architecture/lib/app/connectivity/connectivity_plus_adapter.dart`：plugin mapping。
- `apps/flutter_architecture/lib/app/connectivity/connectivity_scope.dart`：presentation inheritance／listening boundary。
- `apps/flutter_architecture/lib/app/connectivity/connectivity_status_banner.dart`：localized offline status。
- `apps/flutter_architecture/lib/app/connectivity/connectivity_error_diagnostic_sink.dart`：窄safe diagnostic seam。

### App composition

- `apps/flutter_architecture/lib/app/app.dart`：初始化controller、resume recheck、scope與dispose。
- `apps/flutter_architecture/lib/app/di/register_module.dart`：adapter／controller composition。
- `apps/flutter_architecture/lib/app/di/injection.config.dart`：只由build_runner更新。
- `apps/flutter_architecture/pubspec.yaml`與root lockfile：App-only plugin dependency。

### Catalog adoption

- `apps/flutter_architecture/lib/features/catalog/presentation/bloc/catalog_event.dart`：reconnect event。
- `apps/flutter_architecture/lib/features/catalog/presentation/bloc/catalog_state.dart`：reconnect revalidation state／failure。
- `apps/flutter_architecture/lib/features/catalog/presentation/bloc/catalog_bloc.dart`：ordering、dedupe、generation與replacement。
- `apps/flutter_architecture/lib/features/catalog/presentation/pages/catalog_page.dart`：subscribe controller、dispatch opt-in event與status rendering。
- `apps/flutter_architecture/lib/features/catalog/presentation/catalog_presentation_localization.dart`：localized reconnect failure mapping。
- Generated Freezed files：由build_runner更新。

### Localization and documents

- `apps/flutter_architecture/lib/l10n/app_en.arb`。
- `apps/flutter_architecture/lib/l10n/app_zh.arb`。
- `apps/flutter_architecture/lib/l10n/app_zh_TW.arb`。
- Generated localization files：由Flutter tooling更新。
- `docs/adr/adr-027-connectivity-offline-state-foundation.md`與`docs/adr/README.md`。
- `apps/flutter_architecture/README.md`、Catalog README、`docs/project_context.md`、roadmap、CHANGELOG與runtime guide。

## Task 28-1 — Connectivity Contract and ADR

**Files:**

- Create: `apps/flutter_architecture/lib/app/connectivity/connectivity_state.dart`
- Create: `apps/flutter_architecture/lib/app/connectivity/connectivity_adapter.dart`
- Create: `apps/flutter_architecture/test/app/connectivity/connectivity_contract_test.dart`
- Create: `docs/adr/adr-027-connectivity-offline-state-foundation.md`
- Modify: `docs/adr/README.md`
- Create: `docs/audits/milestone_28/28-1_connectivity_contract_adr_review.md`

- [ ] **Step 1: Write failing contract tests**

測試`ConnectivityState`只有`unknown`、`offline`、`online`，adapter contract可提供`readCurrentState`、`stateChanges`與`dispose`，並確認Feature package／reusable package沒有plugin import。

Run:

```bash
cd apps/flutter_architecture
flutter test test/app/connectivity/connectivity_contract_test.dart
```

Expected: FAIL，因contract files尚不存在。

- [ ] **Step 2: Implement minimal provider-neutral contract**

`ConnectivityAdapter`使用：

```dart
abstract interface class ConnectivityAdapter {
  Future<ConnectivityState> readCurrentState();
  Stream<ConnectivityState> get stateChanges;
  Future<void> dispose();
}
```

不得引用plugin type、Dio、Catalog或backend probe。

- [ ] **Step 3: Add ADR-027**

ADR擁有state semantics、App lifecycle owner、interface／backend分離、feature opt-in與禁止global retry；related列ADR-012、015、017、018、020。

- [ ] **Step 4: Run focused validation**

```bash
cd apps/flutter_architecture
flutter test test/app/connectivity/connectivity_contract_test.dart
cd ../..
dart run melos run docs_check
dart run melos run analyze
```

Expected: all pass。

- [ ] **Step 5: Complete Task review and commit**

Review import boundaries、ADR authority與Open P0/P1，落檔`28-1` review後commit：

```bash
git commit -m "feat(connectivity): 建立typed contract與ADR"
```

## Task 28-2 — Platform Adapter and App Composition

**Files:**

- Modify: `apps/flutter_architecture/pubspec.yaml`
- Modify: root `pubspec.lock`
- Create: `apps/flutter_architecture/lib/app/connectivity/connectivity_plus_adapter.dart`
- Create: `apps/flutter_architecture/test/app/connectivity/connectivity_plus_adapter_test.dart`
- Modify: `apps/flutter_architecture/lib/app/di/register_module.dart`
- Regenerate: `apps/flutter_architecture/lib/app/di/injection.config.dart`
- Modify: DI tests under `apps/flutter_architecture/test/app/di/`
- Create: `docs/audits/milestone_28/28-2_platform_adapter_composition_review.md`

- [ ] **Step 1: Add failing adapter mapping tests**

以injectable provider seam或wrapper fake驗證：none→offline、任一usable interface→online、empty result→offline、plugin exception保留給controller處理；adapter dispose取消native subscription ownership。

- [ ] **Step 2: Add App-only plugin dependency**

使用Flutter package command解析compatible stable version：

```bash
cd apps/flutter_architecture
flutter pub add connectivity_plus
```

確認只有App pubspec新增dependency，packages不變。

- [ ] **Step 3: Implement adapter**

Adapter把plugin current result與changes映射成`ConnectivityState`，不暴露`ConnectivityResult`，不做ping。

- [ ] **Step 4: Register composition and regenerate**

在App DI建立singleton adapter；執行：

```bash
dart run melos run build_runner
```

- [ ] **Step 5: Validate and commit**

```bash
cd apps/flutter_architecture
flutter test test/app/connectivity/connectivity_plus_adapter_test.dart test/app/di
cd ../..
dart run melos run analyze
```

完成review文件後commit：

```bash
git commit -m "feat(connectivity): 加入平台adapter與App組裝"
```

## Task 28-3 — Lifecycle and Transition Coordination

**Files:**

- Create: `apps/flutter_architecture/lib/app/connectivity/connectivity_controller.dart`
- Create: `apps/flutter_architecture/lib/app/connectivity/connectivity_error_diagnostic_sink.dart`
- Create: `apps/flutter_architecture/test/app/connectivity/connectivity_controller_test.dart`
- Modify: `apps/flutter_architecture/lib/app/app.dart`
- Modify: `apps/flutter_architecture/lib/app/di/register_module.dart`
- Regenerate: DI source if required
- Create: `docs/audits/milestone_28/28-3_lifecycle_transition_review.md`

- [ ] **Step 1: Write deterministic controller tests**

Fake adapter必須可控制snapshot completer、stream event、error、done與dispose。測試：initial unknown、subscribe-before-snapshot、distinct、unknown→online非reconnect、offline→online單次reconnect、resume single-flight、stale snapshot result不覆蓋latest event、error→unknown、dispose silence。

- [ ] **Step 2: Implement controller state machine**

Controller提供：

```dart
ConnectivityState get state;
Stream<ConnectivityState> get states;
Stream<void> get reconnects;
Future<void> start();
Future<void> recheck();
Future<void> dispose();
```

使用generation避免舊snapshot覆蓋新native event；所有state distinct。

- [ ] **Step 3: Wire App lifecycle**

App startup開始controller；`AppLifecycleState.resumed`呼叫`recheck()`；dispose順序先停止UI listener再dispose controller。Existing local unlock lifecycle保持不變。

- [ ] **Step 4: Validate and commit**

```bash
cd apps/flutter_architecture
flutter test test/app/connectivity/connectivity_controller_test.dart test/app/auth/local_unlock_lifecycle_coordinator_test.dart
cd ../..
dart run melos run analyze
```

完成review文件後commit：

```bash
git commit -m "feat(connectivity): 建立生命週期與重連協調"
```

## Task 28-4 — App-wide Connectivity Presentation

**Files:**

- Create: `apps/flutter_architecture/lib/app/connectivity/connectivity_scope.dart`
- Create: `apps/flutter_architecture/lib/app/connectivity/connectivity_status_banner.dart`
- Modify: `apps/flutter_architecture/lib/app/app.dart`
- Modify: three ARB files
- Regenerate: localization files
- Create: `apps/flutter_architecture/test/app/connectivity/connectivity_status_banner_test.dart`
- Modify: `apps/flutter_architecture/test/app/localization/app_localizations_test.dart`
- Create: `docs/audits/milestone_28/28-4_connectivity_presentation_review.md`

- [ ] **Step 1: Write widget and localization tests**

測試offline顯示banner、unknown／online不顯示、English／zh_TW copy、large text與narrow viewport無overflow。

- [ ] **Step 2: Implement scope and banner**

Scope只暴露controller／typed state；banner不根據Failure推導offline，不阻擋navigation與content interaction。

- [ ] **Step 3: Integrate in MaterialApp builder**

使用`MaterialApp.router.builder`或等價App shell方式把status置於route content上方，保留existing theme／locale composition。

- [ ] **Step 4: Generate and validate**

```bash
cd apps/flutter_architecture
flutter gen-l10n
flutter test test/app/connectivity/connectivity_status_banner_test.dart test/app/localization/app_localizations_test.dart
cd ../..
dart run melos run analyze
```

- [ ] **Step 5: Review and commit**

```bash
git commit -m "feat(connectivity): 加入全域離線狀態呈現"
```

## Task 28-5 — Catalog Reconnect Integration

**Files:**

- Modify: `catalog_event.dart`, `catalog_state.dart`, `catalog_bloc.dart`
- Modify: `catalog_page.dart`
- Modify: `catalog_presentation_localization.dart`
- Regenerate: `catalog_bloc.freezed.dart`
- Modify: `catalog_bloc_test.dart`, `catalog_refresh_test.dart`, `catalog_view_test.dart`
- Create: `docs/audits/milestone_28/28-5_catalog_reconnect_review.md`

- [ ] **Step 1: Write failing Bloc ordering tests**

測試loaded＋items才觸發、empty／initial loading忽略、non-blocking replacement、failure retention、duplicate reconnect ignored、manual refresh priority、query change stale result ignored、append cursor replacement正確。

- [ ] **Step 2: Add reconnect event and state**

新增`CatalogReconnectObserved`與`isReconnectRevalidating`／`reconnectFailure`。不得把reconnect偽裝成`isRefreshing`或`isInitialLoading`。

- [ ] **Step 3: Implement operation ordering**

重用first-page remote replacement policy，但建立獨立request owner。Manual refresh／query switch取消或generation-invalidate reconnect；reconnect期間不重入。

- [ ] **Step 4: Bind visible Catalog page**

Page訂閱App controller的`reconnects`，只向自己的Blocdispatch event；dispose取消subscription。Feature不import plugin。

- [ ] **Step 5: Generate, validate and commit**

```bash
dart run melos run build_runner
cd apps/flutter_architecture
flutter test test/features/catalog/presentation
cd ../..
dart run melos run analyze
```

完成review文件後commit：

```bash
git commit -m "feat(catalog): 整合重連非阻塞更新"
```

## Task 28-6 — Cross-layer Regression and Resilience

**Files:**

- Extend connectivity／Catalog tests
- Modify implementation only for discovered findings
- Create: `docs/audits/milestone_28/28-6_cross_layer_resilience_review.md`

- [ ] **Step 1: Run focused suites and identify findings**

```bash
cd apps/flutter_architecture
flutter test test/app/connectivity test/features/catalog test/app/auth
```

- [ ] **Step 2: Add missing race and error regression tests**

至少覆蓋stream error後resume recovery、dispose during pending snapshot、rapid offline/online burst、manual refresh failure後新reconnect、Auth refresh tests unchanged與Catalog cache write degradation unchanged。

- [ ] **Step 3: Fix findings and re-run**

```bash
dart run melos run analyze
dart run melos exec -- flutter test
```

- [ ] **Step 4: Review and commit**

Open P0=0、Open P1 without disposition=0後：

```bash
git commit -m "test(connectivity): 強化跨層競態與韌性驗證"
```

## Task 28-7 — Platform Runtime Acceptance

**Files:**

- Modify Android／iOS native files only ifplugin requires configuration
- Create: `docs/audits/milestone_28/28-7_platform_runtime_evidence.md`
- Create/update platform contract tests if configuration changes

- [ ] **Step 1: Build representative artifacts**

```bash
cd apps/flutter_architecture
flutter build bundle -t lib/main_development.dart --dart-define=APP_ENV=development
cd ../..
bash tools/ci/build_android_release.sh
```

在Mac執行既有iOS representative build route。

- [ ] **Step 2: Execute Android and iOS runtime smoke**

依Spec六步流程記錄online startup、Catalog load、network off、cache retained、network restore、single revalidation與resume no-storm。外部環境限制必須有明確disposition。

- [ ] **Step 3: Review evidence and commit**

```bash
git commit -m "test(connectivity): 完成Android與iOS執行驗收"
```

## Task 28-8 — Documentation and Release Readiness

**Files:**

- Modify: `apps/flutter_architecture/README.md`
- Modify: Catalog README
- Modify: `docs/project_context.md`
- Modify: `docs/roadmap.md`, `docs/roadmap/active.md`, `docs/roadmap/candidates.md`
- Modify: `docs/backlog.md` only for explicit disposition
- Create/update adopter guide under `docs/guides/`
- Modify: `CHANGELOG.md` only with unreleased/next release content consistent with repository convention
- Create: `docs/audits/milestone_28/28-8_documentation_release_readiness_review.md`

- [ ] **Step 1: Synchronize current authority**

Document typed state、interface/backend separation、Catalog adoption、non-goals、runtime commands與platform support without duplicatingADR正文。

- [ ] **Step 2: Run governance and link validation**

```bash
dart run melos run docs_check
git diff --check
```

- [ ] **Step 3: Full verification**

```bash
dart pub get
dart run melos run build_runner
dart run melos run docs_check
dart run melos run analyze
dart run melos exec -- flutter test
cd apps/flutter_architecture && flutter build bundle
```

- [ ] **Step 4: Review and commit**

```bash
git commit -m "docs(connectivity): 完成Milestone 28文件與發布準備"
```

## Milestone 28 Holistic Final Review

**Files:**

- Create: `docs/audits/milestone_28/28-9_final_review.md`
- Update VERSION／CHANGELOG／roadmap／archive routing only after all acceptance gates pass
- Create post-release validation evidence after release commit

- [ ] Cross-Task architecture consistency review。
- [ ] Interface／backend／operation semantics review。
- [ ] App lifecycle、single subscription、dispose與race review。
- [ ] Catalog cache／SWR／manual／reconnect ordering review。
- [ ] Auth、Failure、observability與DI non-regression review。
- [ ] Runtime evidence recheck。
- [ ] Full regression and representative builds。
- [ ] Findings修正與第二輪holistic review。
- [ ] Open P0=0；Open P1 without disposition=0。
- [ ] VERSION、CHANGELOG、roadmap、project context與archive同步。
- [ ] Release／archive commit與push。
- [ ] Release-SHA post-release validation。

只有全部步驟通過後，才能宣告Milestone 28完成。
