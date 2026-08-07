---
document_type: runtime-evidence
status: accepted
authoritative_for:
  - milestone-33-task-33-10-semantic-visual-review
last_reviewed_baseline: 1.14.0
---

# Task 33-10 Semantic Visual Review

## Evidence Set

| Evidence | Dimensions | SHA-256 |
|---|---:|---|
| Pencil canonical reference `pencil-preview.png` | 941 × 1672 | `f453452316f0e390dbbf435a3f4c2433306fb3aa607287873e9905f00973eee8` |
| Flutter canonical render `canonical-render.png` | 941 × 1672 | `533cc857149f831046dcce0804c4121d7731118ff8f54915dae103be25d6a020` |
| Reference diff `reference-diff.png` | 941 × 1672 | `631758e70335447f902305554ba69e7f7d085d2382852b47f2a40ce37ad905ee` |
| Historical benchmark diff `benchmark-diff.png` | 226 × 400 | `be98816b0af65a30e410b00f8722180d90ab8af4b31f699e8468e3b636b3d624` |
| Android runtime screenshot `android-runtime-screenshot.png` | 540 × 960 | `358d7cbeea737ff8fefeb2629cfffca6ccf214c828c127c587149c2928b96919` |

Android runtime screenshot為driver輸出的exact PNG bytes；source與tracked evidence做binary compare，結果相同，沒有resize、re-encode、crop或mask。

## Canonical Pixel Disposition

固定contract：

```txt
per-channel tolerance: 8
ignore regions: none
resizing: forbidden
differentPixelRatio ceiling: 0.08
meanAbsoluteChannelDelta ceiling: 8.0
```

Fresh result：

```txt
differentPixelRatio = 0.07781856825427495
meanAbsoluteChannelDelta = 2.995617318947063
maxChannelDelta = 243
different pixels = 122436 / 1573352
```

Disposition：PASS。沒有為candidate放寬threshold、增加ignore region或改變reference。

## Semantic Checklist

| Area | Result | Evidence／review |
|---|---|---|
| hierarchy | PASS | Header → progress → gold hero → grouped cards → guidance → primary／secondary／end-flow hierarchy符合accepted Pencil direction。Android首屏仍保留相同優先順序。 |
| typography | PASS | Traditional Chinese glyphs在Windows canonical與Android runtime均正常渲染；沒有tofu、截斷標題或錯誤fallback。Canonical字寬差異已由feature-local renderer mapping收斂，不改production localization authority。 |
| spacing | PASS | Canonical `941 × 1672` complete-flow仍在固定viewport內；`390 × 844`、`226 × 400`既有narrow tests維持scrollable且無overflow。Android `360 × 640`首屏間距可讀。 |
| icons | PASS | Phosphor identities保留；Windows golden loader使用正確package font family。Android runtime shield、back、progress與status glyph無missing icon。 |
| progress states | PASS | Step 1／2為Pencil authority的Unicode `✓`；Step 3 active gold；Step 4 pending。Android runtime呈現相同狀態。 |
| content completeness | PASS | Canonical完整flow包含summary、results、records、guidance、primary、secondary與end-flow。Android為narrow viewport screenshot，只顯示首屏；完整內容由scrollability／semantics tests證明可達，沒有以crop隱藏內容。 |
| contrast | PASS | Dark background、cyan completion、gold active／primary emphasis與muted secondary text保持清楚；Android runtime沒有因renderer造成主層級消失。 |
| touch targets | PASS | 既有responsive widget／semantics tests通過；Android capture沒有縮放整張canvas或raster-only overlay。 |
| narrow layout | PASS | Android runtime：`360 × 640` logical、DPR `1.5`；畫面無overflow，hero與progress可讀，下方內容依既有scroll contract可達。 |
| Android renderer differences | PASS with recorded diagnostics | Runtime screenshot保留設計層級。Debug build右上角`DEBUG` banner屬runtime build marker，不是產品內容且沒有遮擋關鍵UI；BlueStacks的Window Sidecar與Secure Storage migration log沒有造成test／render失敗。 |

## Android Runtime Evidence

```txt
device id: emulator-5554
reported model: SM-S908E
manufacturer: samsung
Android: 9
API: 28
physical size: 540 × 960
physical density: 240 dpi
Flutter DPR: 1.5
Flutter logical size: 360 × 640
font scale: 1.0
screenshot bytes: 307384
screenshot SHA-256: 358d7cbeea737ff8fefeb2629cfffca6ccf214c828c127c587149c2928b96919
```

Capture command：

```bash
flutter drive --device-timeout 20 \
  -d emulator-5554 \
  --driver=test_driver/integration_test_driver.dart \
  --target=integration_test/pencil_compatibility_runtime_capture_test.dart \
  --flavor development \
  --dart-define=NATIVE_ENVIRONMENT=development
```

Result：`All tests passed.`

## Final Semantic Disposition

```txt
Semantic P0: 0
Semantic P1 without disposition: 0
Pixel gate: PASS
Android runtime evidence: PASS
Semantic visual review: PASS
```
