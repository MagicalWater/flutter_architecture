# Asset Runtime Ownership & Theme-aware Representation Integration — Design Review

## Review target

`docs/superpowers/specs/2026-08-19-asset-runtime-theme-integration-design.md`

## Requirement fit

PASS。Design直接處理 confirmed gap：runtime typed asset access + theme-aware representation selection；沒有重做 Color/Theme system、沒有建立 global provenance registry。

## Material findings

### F-ART-D01 — Theme-aware 不等於 Design-System-owned

Risk：若把 image variant直接塞進 `DsThemeDefinition`，App/Feature artwork會因 selection key是 Theme而被錯誤 promotion。

Resolution：Design明確把 Theme Identity / Brightness定義為 selection axis，ownership仍依 App/Product/Feature/Component responsibility。`DsThemeDefinition`不作default image owner。

Disposition：resolved。

### F-ART-D02 — Typed owner可能退化成 wrapper-class形式主義

Risk：每個 FlutterGen accessor再包一層 `FooAssets`，只增加 indirection。

Resolution：generated directory accessor若已清楚表達 local owner，可直接 consumer；只有 theme/semantic selection或多 physical representations需要 bounded resolver才新增 wrapper。

Disposition：resolved。

### F-ART-D03 — Runtime typed constants可能複製 provenance authority

Risk：把 source/hash/transformation放進 runtime registry形成第二 authority。

Resolution：Design嚴格分離 generated access、semantic runtime ownership、representation/provenance三責任；runtime只能consume destination。

Disposition：resolved。

### F-ART-D04 — Feature可能為 theme ID 直接依賴 persistence/controller internals

Risk：theme-aware feature resolver若直接讀 preference store，破壞Presentation/App composition boundary。

Resolution：Design要求 App提供 stable presentation-level Theme Identity exposure；不得feature依賴 persistence，也不得新建 global singleton。

Disposition：resolved。

### F-ART-D05 — FlutterGen可能被誤當 architecture authority

Risk：generator directory structure被當成 ownership oracle。

Resolution：Design只把 FlutterGen定義為 path-safe generated accessor。Ownership仍由 ADR-018 responsibility/change reason決定；directory nesting只是可直接消費的 representation方式之一。

Disposition：resolved。

## Scope review

- No Color system redesign：PASS。
- No global asset registry：PASS。
- No Pencil source mutation：PASS。
- No new remote theme framework：PASS。
- No mandatory wrapper per asset：PASS。
- Minimal reference only：PASS。

## ADR review

PASS。Stable boundary可由 ADR-018延伸承擔；目前沒有證據需要新增獨立 ADR。ADR-028 representation/provenance owner保持不變。

## Validation design review

PASS。採最低充分 generation/compile/resolver evidence與 planner-selected validation，不因 architecture label自動 full regression；永久 test需另作 Test Authoring / Retention Decision。

## Final design review disposition

**PASS / accepted.** User explicitly approved the Design on 2026-08-19.

Open P0：0。

Open P1 without disposition：0。
