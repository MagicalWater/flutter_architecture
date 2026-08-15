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

若failure root cause是wrong source／asset／icon／representation，不得把它當普通geometry mismatch繼續pixel tuning。Affected local/global PASS先失效，回representation classification／provenance取得replacement mapping，再fresh重跑受影響visual gates。

對accepted Design／Plan標記為critical、且whole-screen metric容易稀釋的local fidelity owner，candidate前還必須固定最小充分local contract。合法owner可包含：

```txt
component golden
predeclared ROI / section diff
asset identity / content hash
icon identity / verified equivalence
runtime geometry assertion
```

不要求每個critical item同時擁有全部證據；選最接近failure source的一個或最小組合。若使用ROI／section diff，region identity、bounds derivation、target dimensions、projection與threshold必須在candidate前固定；candidate失敗後不得移動ROI、縮小region或放寬threshold。

Critical local gate與whole-screen gate採AND semantics：

```txt
whole-screen PASS + critical local FAIL = overall FAIL
```

Whole-screen broad regression仍必須存在；local gate只補micro-fidelity blind spot，不得取代全畫面驗證。

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

## Critical runtime geometry

Source code出現accepted width／height constant不等於runtime geometry已通過。對constraint-sensitive critical CTA、sticky actions、major navigation、AppBar／hero／major card等risk-selected owner，優先以`RenderBox`結果或等價runtime evidence驗證accepted relationship，例如：

```txt
tester.getSize(...)
tester.getTopLeft(...)
tester.getBottomRight(...)
```

Responsive contract可以是exact size、edge inset、alignment、sibling gap、proportion或container relationship；不得把canonical design-space x/y機械套成所有runtime viewport的固定座標，也不得為每個Pencil node機械式新增geometry test。

## Anti-cheat

拒絕：

- Full-screen screenshot embedding。
- Top-level fixed-canvas `FittedBox`／`Transform.scale`。
- Parallel whole-screen visual renderer或whole-screen breakpoint escape hatch。
- Hidden overflow、offstage content或test-only layout branch。
- Historical benchmark作current master。
- 修改accepted golden而不重新review source authority。
