# Milestone 25-7 — macOS Golden Authority Review

日期：2026-07-22

## 結論

**通過。** Design System gallery已建立reviewed macOS host baseline；測試繼續使用exact pixel comparison，沒有放寬tolerance、跳過macOS或共用其他host的圖片。

## Authority

```text
packages/design_system/test/goldens/design_system_gallery_macos.png
```

Golden selector維持既有契約：

```dart
goldens/design_system_gallery_${Platform.operatingSystem}.png
```

因此Windows、Linux與macOS各自解析到獨立reviewed baseline。

## RED evidence

執行：

```bash
cd packages/design_system
FLUTTER_ROOT=/Users/water/Developer/flutter \
  flutter test test/design_system_gallery_golden_test.dart
```

結果精確失敗於：

```text
Could not be compared against non-existent file:
goldens/design_system_gallery_macos.png
```

沒有其他widget、layout、font loading或test harness failure。

## Candidate generation

使用相同Flutter SDK與repository-owned deterministic font loader：

```bash
FLUTTER_ROOT=/Users/water/Developer/flutter \
  flutter test test/design_system_gallery_golden_test.dart --update-goldens
```

固定載入：

- `Roboto-Regular.ttf`
- `MaterialIcons-Regular.otf`
- Flutter SDK：3.41.6
- physical size：800 × 1200
- device pixel ratio：1.0

## Cross-host review

三個baseline尺寸皆為800 × 1200 RGBA PNG。

| Comparison | Changed pixels | Mean absolute channel delta | Maximum channel delta | Difference bounds |
| --- | ---: | ---: | ---: | --- |
| macOS vs Linux | 10,098 / 960,000（1.0519%） | 0.312768 | 226 | `(17,18)–(536,668)` |
| macOS vs Windows | 9,756 / 960,000（1.0163%） | 0.389036 | 255 | `(17,18)–(536,668)` |

差異集中在gallery實際文字、icon與元件內容區；沒有全畫布尺寸改變、裁切、viewport漂移或背景整體變色。約1%的差異量級也符合Milestone 24建立Linux authority時已review的host renderer差異。

Gallery fixture語意保持一致：

- App bar title。
- info與warning status banners。
- empty state title、message與Refresh action。
- disabled loading button。

## Review findings

| Finding | Severity | Disposition |
| --- | --- | --- |
| macOS baseline原本不存在，造成完整workspace test失敗 | P1 | 新增reviewed macOS authority |
| 兩個DI persistence tests並行共用host SQLite path，第二輪互相覆蓋user資料 | P1 | 每個test file改用獨立temporary database directory並刪除 |
| 不同host rasterization約有1% pixel差異 | P2 | 使用獨立host baseline；不放寬tolerance |
| Golden path已由`Platform.operatingSystem`明確選擇 | Pass | 不增加重複resolver abstraction |

## Verification gates

- Focused macOS golden test連續通過。
- Design System完整tests連續通過。
- Workspace完整Flutter tests連續通過兩次。
- `melos analyze`通過。
- `docs_check`通過。
- `git diff --check`通過。
- Open P0／P1 without disposition：0。

## Scope boundary

本Task只建立macOS host visual authority；沒有修改production widget、theme token、layout、font fallback或golden comparison tolerance。
