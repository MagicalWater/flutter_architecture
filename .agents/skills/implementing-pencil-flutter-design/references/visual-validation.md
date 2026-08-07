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

Canonical與supported runtime必須render同一個production whole-screen visual tree。若canonical與runtime由breakpoint選擇不同root renderer，即使兩邊各自GREEN，也屬architecture／visual acceptance failure。

## Fixed contract

在candidate產生前，accepted Design／Plan／manifest必須固定：

- Reference與benchmark roles。
- Canonical width、height、DPR。
- Per-channel tolerance。
- Different-pixel與mean-delta thresholds。
- Allowed system-chrome crop。
- Ignore regions；預設none。
- Supported runtime target、derived reference projection algorithm、crop／scroll contract與hash。

Candidate失敗時修正implementation或取得新的Design decision。不得在同一Task放寬threshold、resize不同尺寸images、upscalethumbnail、加入dynamic masks或把semantic P1改成「肉眼可接受」。

Canonical Pencil viewport是design/comparison space，不是Flutter logical breakpoint。Accepted single mobile frame可以在candidate前投影成runtime-sized derived reference；這種projection必須由manifest／Plan事前固定，不得在看到candidate後silent resize。

`scrollable`、`no overflow`、semantics與touch target是**layout health**證據，不是**runtime fidelity**。Supported runtime必須有**visual fidelity evidence**：至少runtime-sized expected reference／golden或等價deterministic comparison、實際runtime screenshot與semantic side-by-side review。

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

使用者或reviewer對supported runtime提出新的semantic P1時，對應visual PASS立即失效；canonical pixel PASS不能維持runtime acceptance。

## Anti-cheat

拒絕：

- Full-screen screenshot embedding。
- Top-level fixed-canvas `FittedBox`／`Transform.scale`。
- Parallel whole-screen visual renderer或whole-screen breakpoint escape hatch。
- Hidden overflow、offstage content或test-only layout branch。
- Historical benchmark作current master。
- 修改accepted golden而不重新review source authority。
