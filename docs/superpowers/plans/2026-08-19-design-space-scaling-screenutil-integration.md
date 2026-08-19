---
document_type: implementation-plan
status: accepted
authoritative_for:
  - design-space-scaling-screenutil-integration-plan
last_reviewed_baseline: 1.25.2
---

# Implementation Plan — Design-space Scaling / flutter_screenutil Integration

## Goal

以 `flutter_screenutil 5.9.3` 建立 repository-wide design-space measurement capability，讓 App 擁有 design baseline、Design System shared measurements 保留 scaling、feature/local exact measurements 可直接使用 `.w/.h/.r`，同時保留 Flutter layout ownership 與 accessibility contract。

## Task 1 — Dependency + App-root initialization

### Files

- Modify: `apps/flutter_architecture/pubspec.yaml`
- Modify: `packages/design_system/pubspec.yaml`
- Modify: `apps/flutter_architecture/lib/app/app.dart`
- Add: `apps/flutter_architecture/lib/app/ui/app_ui_design.dart`（名稱可在 implementation 中保持最小責任調整）

### Change

1. App 與 Design System 都加入 `flutter_screenutil: 5.9.3`。
2. 建立 App-owned design baseline config；template 只提供一個明確可替換 baseline，不把 Pencil `941×1672` 當 repository-wide authority。
3. `ArchitectureApp` root 以 `ScreenUtilInit` 包住 `LocaleControllerScope / ThemeControllerScope / ArchitectureThemeBuilder`，確保任何 scaled Design System token 在 ThemeData 建立前已初始化。
4. 不把 initialization 放進 feature/page 或 `MaterialApp.builder`。
5. `splitScreenMode` 不自行開啟；沒有 accepted requirement 不增加 package-specific heuristic。

### Temporary probe

可暫時建立最小 probe 驗證：
- `100×200 -> 300×700`
- `10.w == 30`
- `10.h == 35`
- `10.r == 30`
- metrics update 後重新解析。

Probe GREEN 後立即刪除，不保留永久 test。

## Task 2 — Design System scaled measurement tokens

### Files

- Modify: `packages/design_system/lib/src/tokens/ds_space.dart`
- Modify: `packages/design_system/lib/src/tokens/ds_radius.dart`
- Modify: `packages/design_system/lib/src/tokens/ds_icon_size.dart`
- Modify affected Design System components/theme factory as compile requires
- Modify affected app feature call sites that currently require `const`

### Strategy

1. `DsSpace` shared spacing / inset 採 uniform design-space scaling (`.r`) 作為第一版 stable semantic，對應已接受的 repository uniform measurement model。
2. `DsRadius` 採 `.r`。
3. `DsIconSize` 採 `.r`。
4. 其他 token 不機械 migration；只有本次 affected shared design-derived measurements 納入。
5. token public API 仍回傳 `double`，caller 不自行再套 `.r/.w/.h`，避免 double scaling。
6. 既有 `const SizedBox / EdgeInsets / Icon` 等因 runtime token 失去 const 時只移除必要 `const`，不做無關 refactor。

### Property neutrality

scaled token 可被用於 padding、gap、size、radius、offset、Positioned coordinate 等任何正確 UI semantics；不建立 widget/property blacklist。

## Task 3 — Feature/local exact measurement contract

### Files

- Modify relevant Design System README / app README or UI guide
- Do not mechanically rewrite all existing raw numbers

### Change

記錄：
- shared stable semantic measurement -> Design System token；
- single-consumer / exact local measurement -> local `.w/.h/.r`；
- `.r` = uniform `min(widthScale,heightScale)`；
- `.w/.h` 只在 measurement 本身具有 axis-specific design semantics 時使用；
- scaling system 不決定使用 `Row/Column/Stack/Positioned`；
- layout review 檢查 ownership / content relationship / spatial semantics。

## Task 4 — Typography + accessibility guard

### Files

- Modify docs only unless compatibility probe 暴露 implementation issue

### Change

1. Phase 1 不把 `.sp` promotion 為 repository typography default。
2. 不設定 `textScaleFactor: 1`、不覆蓋 system `TextScaler`。
3. Theme typography 保持 Flutter / Design System existing accessibility semantics。
4. touch target minimum 與 visual size scaling 分離。

### Temporary probe

可暫時驗證 system text scaling 接入前後保持有效；驗證後刪除。

## Task 5 — Stable architecture authority sync

### Files

- Modify: `docs/adr/adr-018-design-system-theme-boundaries.md`
- Modify: `docs/adr/adr-028-repository-local-pencil-to-flutter-design-implementation-workflow.md`
- Modify: `packages/design_system/README.md`
- Modify relevant current UI/design guide only if it owns reusable procedure

### ADR-018

補充：
- shared design-derived measurement promotion 不取消 scaling；
- Design System 可依賴 sizing engine，但 product design baseline 由 App composition root 擁有；
- runtime-scaled token 不再要求 compile-time const。

### ADR-028

精準化：
- coordinate projection 本身不違規；
- `Stack` / `Positioned` / x/y / left/top 可以使用 scaled design measurements；
- finding 應針對錯誤 layout ownership，例如 whole-page coordinate owner 取代應由 content relationships 持有的 flow；
- legitimate local/spatial coordinate 不得被 static detector 以 widget 名稱誤殺。

## Task 6 — Focused compatibility + validation + temporary test deletion

### Validation

1. `flutter pub get` / workspace dependency resolution。
2. `dart analyze` / planner-selected affected validation。
3. focused runtime/source verification：
   - App root initialization order；
   - scaled Design System token compile；
   - representative auth/catalog/profile pages compile；
   - system text scaling 未被禁用。
4. 若 temporary probes/tests 曾建立，在 final diff 前刪除並確認 `git status` 沒有殘留 test artifact。
5. 執行 `validation_planner.py`，只跑 planner-selected scope，不自行 full regression。

### Test retention

本計畫新增的 responsive / scaling / integration probe：
`Delete temporary evidence`。

永久 test 新增數：0（除非 implementation 出現 Design 未預見且符合 current test-authoring `Required` 的 critical invariant；此情況需另行 disposition，不默認保留）。

## Task 7 — Holistic review

Review checks：

- `flutter_screenutil` 只負責 conversion，不取代 Flutter layout architecture。
- Design baseline owner 唯一。
- Design System shared design-derived measurement 真的 scale。
- caller 不 double-scale token。
- 不存在 property blacklist / `Positioned` ban。
- ADR-028 wording 不再誤殺 legitimate coordinates。
- system text scaling intact。
- temporary tests = 0 remaining。
- 沒有夾帶 Write Precheck migration。
- Open P0 = 0；Open P1 without disposition = 0。

## Commit boundary

Level 3 不要求 per-task commit。Implementation + docs + focused validation + holistic review 完成後，使用一個 coherent conventional commit 即可。
