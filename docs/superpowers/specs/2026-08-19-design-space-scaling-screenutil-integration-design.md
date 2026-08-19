---
document_type: design-spec
status: accepted
authoritative_for:
  - design-space-scaling-screenutil-integration-design
last_reviewed_baseline: 1.25.2
---

# Design-space Scaling / flutter_screenutil Integration

## Requirement Decision

- Request：審查並準備接入 `flutter_screenutil`，讓任意設計稿 coordinate space 可一致轉為 Flutter runtime logical measurements，避免 UI 到處依賴 `BuildContext` 做換算。
- Problem：目前 template 同時存在固定 Design System 尺寸與 Write Precheck local projection，缺少 repository-wide、可重用且不綁特定設計工具的 design-space measurement contract。若設計稿本身不是以 runtime logical dimensions 建立，例如 `100×200`，直接把設計稿 `10` 寫成 Flutter `10` 會失真。
- Expected behavior：App 提供產品 design baseline；UI 可直接使用設計稿 measurement 並由 runtime scale 轉換。已 promotion 到 Design System 的 shared measurements 同樣保留 scaling。Scaling 不決定 layout primitive；`Row`、`Column`、`Stack`、`Positioned` 都依真正 UI semantics 使用。
- Value：提高 design fidelity、減少重複 context lookup 與手工換算、讓 Pencil/Figma/手工設計稿等來源共用同一 sizing capability。
- Classification：Level 3 — Cross-cutting。新增 shared dependency，影響 App bootstrap、Design System token semantics 與 repository-wide UI architecture。
- Non-goals：不建立新的 breakpoint framework；不把 `flutter_screenutil` 當 whole-screen fixed-canvas renderer；本階段不強制 migration Write Precheck；不保留普通 responsive/layout 永久測試。

## Package disposition

採用 `flutter_screenutil: 5.9.3` 作為 design-space measurement engine。

審查確認的 relevant semantics：

- `.w`：`screenWidth / designWidth`
- `.h`：`screenHeight / designHeight`
- `.r`：`min(scaleWidth, scaleHeight)`
- `ScreenUtilInit` 會觀察 metrics change 並更新其 runtime data。

套件提供 conversion engine；repository architecture 仍由本 Design、ADR 與 Flutter layout semantics 擁有。

## Ownership

### App ownership

App 是唯一 Composition Root，負責：

- `ScreenUtilInit` lifecycle。
- product-specific `designSize` / design baseline。
- 是否允許 upscale、split-screen mode 等 product-level policy。
- 確保 runtime metrics change 可以重新解析 scale。

Design baseline 不屬於 `packages/design_system`，因為它是產品／設計來源 authority，而不是 reusable semantic token。

### Design System ownership

`packages/design_system` 可以依賴 `flutter_screenutil`，並負責 shared design-derived measurement tokens，例如：

- spacing / inset
- radius
- icon size
- component dimensions
- stroke / visual geometry

Promotion 到 Design System 只改變 semantic ownership，不取消 design-space scaling。

例如設計稿多個 consumer 穩定共用 `16` 作為 large inset，promotion 後 `DsSpace.lg` 仍代表 `16 × current design scale`，而不是固定 runtime `16`。

### Feature / component ownership

尚未 promotion 的 exact measurement 留在 smallest correct owner，直接使用 ScreenUtil design-space conversion，例如 `.w` / `.h` / `.r`。

不因 raw value 相同就 promotion；仍遵守 ADR-018 semantic identity / stable consumer evidence 原則。

## Scaling semantics

Scaling system 只回答：

> design-space measurement 在目前 runtime 等於多少？

它不負責選擇 layout primitive。

以下只要來源是 design-space measurement，原則上都可以 scale：

- width / height
- padding / inset / margin / gap
- radius / stroke / shadow geometry
- icon / artwork / component dimensions
- offset
- x / y
- `left` / `top` / `right` / `bottom`

不建立 `Positioned`、`Stack` 或 coordinate property 禁止名單。

## Layout ownership

Scaling legality 與 layout ownership 分開判斷。

- Flow semantics：當 sibling placement 本質上由前一個 content size + gap 決定時，應由 `Row` / `Column` / `Flex` / `Wrap` / constraints / scroll 等 relationship layout 持有。
- Spatial semantics：當位置本身就是 UI contract，`Stack` / `Positioned` / custom layout 可以直接持有 scaled x/y/offset。
- Bounded component 的 local `Positioned(top: 8.r, right: 8.r)` 完全合法，只要 local coordinate 本身就是 intended UI semantics。
- Whole-page fixed coordinates 的問題不是「用了 Positioned」，而是 coordinate owner 是否錯誤取代本應由 content relationship 持有的 flow。

因此 architecture review 應檢查 ownership / semantics，不以 widget 名稱或是否使用 x/y 作 oracle。

## Default scale strategy

Repository 需要同時保留不同 conversion semantics，而不是強迫所有 measurement 使用同一公式：

- `.w`：width-derived design measurement。
- `.h`：height-derived design measurement。
- `.r`：uniform / contain-like measurement，對應既有 `min(widthScale, heightScale)` 模型。

不把 `.r` 宣告為所有 shared token 的唯一公式，因為同寬但不同可用高度的 scroll page 可能不應整體縮小。每類 Design System token 的 default conversion strategy 應在 implementation plan 中依其 design semantics 明確定義；不得靠 caller 任意選擇導致同一 token 在不同地方語意漂移。

## Typography / accessibility

Phase 1 不把 `.sp` 當 repository typography default。

- 不關閉 system text scaling。
- `TextScaler` / Dynamic Type 類 accessibility contract 保持有效。
- 若未來需要 design-space font projection，必須獨立設計 design projection 與 user text scaling 的 composition semantics。
- Design System 不以固定高度承載可換行文字，既有 ADR-018 accessibility contract 保持有效。

## Touch targets

Visual measurement 可以 scale，但 interaction hit target 仍受 accessibility / platform minimum constraint 約束。若 design projection 讓 visible control 變小，hit region 可以與 visual geometry 分離。

## Write Precheck disposition

本次不強制把 `WritePrecheckProjection` 改成 ScreenUtil。

原因：它目前除 measurement conversion 外還包含 local projection / transform machinery。先建立通用 repository scaling contract，再另行審查可否簡化或局部 migration，避免 dependency adoption 夾帶不必要 refactor。

## Test Authoring / Retention

本次 compatibility / scaling probes 全部是 temporary evidence：

- 可暫時驗證設計稿 `100×200`、runtime `300×700` 時 `.w/.h/.r` 行為。
- 可暫時驗證 metrics change 後 scale 更新。
- 可暫時驗證接入沒有覆蓋 system text scaling。

GREEN 後一律 `Delete temporary evidence`，不新增永久 responsive/layout regression test。必要 repository validation 仍由 `validation_planner.py` 決定。

## ADR impact

ADR-018 需要補充：shared design-derived measurement token promotion 不取消 runtime design-space scaling。

ADR-028 需要精準化 coordinate rule：禁止的是錯誤的 layout ownership / whole-page coordinate laundering，不是 `Positioned` / x/y / left/top 本身；legitimate local or spatial coordinates 可以使用 scaled design-space measurements。

## Acceptance criteria

Design implementation 完成時需滿足：

1. `flutter_screenutil 5.9.3` 在 Flutter 3.44.8 / Dart 3.12.2 dependency resolution 與 selected validation 下可用。
2. App 有單一 design baseline initialization owner。
3. Design System shared design-derived measurements 可按明確 strategy scale。
4. Feature 可使用 design-space measurement，無需到處 `.of(context)`。
5. 不禁止 `Positioned` / coordinate scaling；只治理錯誤 layout ownership。
6. system text scaling 不被禁用或固定為 1。
7. temporary scaling tests / probes 在驗證後刪除。
8. ADR-018 / ADR-028 與 package README / relevant guide 同步到新的 stable rule。
