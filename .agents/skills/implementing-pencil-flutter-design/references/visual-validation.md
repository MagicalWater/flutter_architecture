# Visual Validation

## Gate sequence

```txt
widget／route／localization RED
→ minimal Flutter GREEN
→ canonical golden
→ deterministic pixel diff
→ supported runtime screenshot
→ semantic visual review
→ architecture／anti-cheat review
→ fresh affected regression
```

Golden generation不等於visual approval。

## Fixed contract

在candidate產生前，accepted Design／Plan／manifest必須固定：

- Reference與benchmark roles。
- Canonical width、height、DPR。
- Per-channel tolerance。
- Different-pixel與mean-delta thresholds。
- Allowed system-chrome crop。
- Ignore regions；預設none。

Candidate失敗時修正implementation或取得新的Design decision。不得在同一Task放寬threshold、resize不同尺寸images、upscalethumbnail、加入dynamic masks或把semantic P1改成「肉眼可接受」。

## Semantic review

至少逐項檢查：

- hierarchy
- typography
- spacing
- icons
- progress／state clarity
- content completeness
- contrast
- touch targets
- narrow layout
- renderer differences

Pixel metrics不能覆蓋semantic P1；semantic review也不能取代deterministic metrics。

## Anti-cheat

拒絕：

- Full-screen screenshot embedding。
- Top-level fixed-canvas `FittedBox`／scale transform。
- Hidden overflow、offstage content或test-only layout branch。
- Historical benchmark作current master。
- 修改accepted golden而不重新review source authority。
