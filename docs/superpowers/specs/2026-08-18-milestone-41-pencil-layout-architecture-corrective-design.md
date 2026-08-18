---
document_type: design-spec
status: accepted
authoritative_for:
  - milestone-41-pencil-layout-architecture-corrective-design
last_reviewed_baseline: 1.20.0
---

# Milestone 41 — Pencil-to-Flutter Constraint-based Layout Architecture Corrective Design

## 1. Design status

```txt
Requirement: accepted
Design: accepted / review complete / user approved 2026-08-18
Plan: forbidden until Design is accepted
Implementation: forbidden until Design and Plan are accepted
```

本Design只修正Pencil → Flutter layout architecture與enforcement。Accepted `.pen`、visual language、visual authority ranking、representation/provenance、single-renderer與Feature First ownership保持不變。

## 2. Confirmed failure model

Current failure不是「用了`Stack`」本身，而是**whole-screen coordinate ownership錯誤**：

```txt
canonical Pencil screen coordinates
→ global design width / scale
→ screen-level Stack
→ many Positioned
→ left/top/right/bottom/width/height × same scale
→ runtime layout
```

這種implementation即使同時滿足：

- one whole-screen renderer；
- 真Flutter widgets；
- 沒有full-screen raster；
- 沒有top-level `FittedBox`；
- 沒有breakpoint第二renderer；

仍然把Pencil design canvas當成runtime layout engine，會讓content growth、localization、text scale、safe area、keyboard、dynamic state與不同viewport被固定座標模型綁死。

Current reference proof `WritePrecheckProjectedCanvas`正是confirmed example；因此本Milestone不能只新增policy wording，必須讓reference implementation與tests一起遷移。

## 3. Stable architecture decision

### 3.1 One screen, one tree, constraint-owned layout

保留既有：

```txt
One accepted screen → one whole-screen visual tree
```

並新增同等重要的第二條：

```txt
One whole-screen visual tree → Flutter constraints / relationships own screen layout
```

Pencil canonical geometry是設計證據，不是runtime page coordinate system。

### 3.2 Geometry classification

Pencil extraction後，每個會影響layout ownership的geometry分為三類。

#### A. Relationship geometry — normal/default

可直接成為Flutter layout contract：

- edge inset；
- sibling gap；
- alignment；
- min／max／preferred size；
- aspect ratio；
- proportion；
- container relationship；
- sticky／pinned relationship；
- flow order；
- scroll relationship；
- bounded component internal dimensions。

典型Flutter ownership：

```txt
Padding / Align / Row / Column / Wrap
Expanded / Flexible / Spacer
ConstrainedBox / SizedBox / AspectRatio
ListView / CustomScrollView / Sliver
LayoutBuilder / SafeArea
```

Shared design scale可用於這些**relationship values或visual dimensions**，但parent constraints與content決定最終placement。

#### B. Bounded freeform overlay — allowed local exception

`Stack`／`Positioned`合法的必要語意：

1. owner是有明確bounds的local component，不是whole page coordinate plane；
2. local child coordinates相對於該component自己的bounds；
3. component本身在page中的placement仍由constraint／flow relationship決定；
4. overlay不負責安排前後section的page flow；
5. content growth不應靠修改整頁canonical `top`常數維持；
6. 若local component為critical，visual/geometry evidence仍依既有risk-based gate驗證。

合法例子：Hero artwork疊badge、avatar status dot、decorative glow、局部illustration layers。

#### C. Whole-screen absolute canvas — forbidden by default

以下任一組合代表高風險whole-screen coordinate reconstruction：

- root／major page使用canonical design width/height建立coordinate plane；
- page sections主要由canonical `left/top/right/bottom`決定placement；
- 一個global scale直接作用到大量page-level `Positioned` parent data；
- custom RenderObject／helper把canonical absolute coordinates批量投影成runtime coordinates；
- section flow依「下一段top = Pencil y × scale」而不是Flutter sibling/container relationship；
- viewport改變主要靠縮放整個coordinate model，而非constraints重新layout。

這類model即使不用`FittedBox`／`Transform.scale`也屬architecture failure。

### 3.3 Genuine spatial canvas exception

少數產品surface本身就是spatial canvas，例如map overlay、game board、diagram editor、floor plan。此時whole-screen/major-surface absolute spatial coordinates可能是真正domain／interaction semantics，而不是Pencil還原shortcut。

因此不建立「任何screen-level absolute coordinate都永遠禁止」的假規則。例外必須在Design階段明確標記：

```txt
layout_model: intentional-spatial-canvas
approval_ref: accepted Design / ADR evidence
reason: runtime surface semantics require spatial coordinates
```

Implementation Agent不得自行把一般App screen升級為spatial canvas來逃避constraint-based layout。

## 4. Machine-readable layout contract

### 4.1 Extend initiative implementation mapping

沿用Milestone 39的initiative-local：

```txt
docs/visual_authority/<initiative>/implementation_mapping.json
```

不新增第二份global layout registry。

Schema升級時加入screen-level layout contract；exact field naming由Plan與RED fixture定案，但semantic contract固定為：

```json
{
  "screen_layouts": [
    {
      "node_id": "accepted-root-node",
      "flutter_owner": "ScreenWidget",
      "layout_model": "constraint-relationship",
      "evidence_ref": "..."
    }
  ]
}
```

允許screen-level `layout_model`：

```txt
constraint-relationship
intentional-spatial-canvas
unresolved
```

Rules：

- normal Pencil-to-Flutter App screen預設必須`constraint-relationship`；
- `intentional-spatial-canvas`必須有accepted `approval_ref`；
- `unresolved` fail closed；
- validator不得解析`.pen`，只驗Pencil MCP extraction後的mapping evidence；
- schema migration只處理current tracked proof，不做historical artifact回填。

### 4.2 Local overlay evidence

不要求把每個`Stack`登錄。只有risk-selected critical overlay或review認為容易被誤用時，mapping evidence才記錄：

```txt
layout_role: bounded-overlay
owner: local component
container_relationship: ...
```

避免把layout governance變成every-widget registry。

## 5. Source architecture enforcement

### 5.1 Do not build a generic Dart linter

本Milestone不建立全repository AST framework或以`Positioned`數量作唯一判決。原因：

- `Stack`／`Positioned`有合法local用途；
- source可以透過helper／RenderObject變形，純關鍵字count容易誤判或漏判；
- generic linter會把本次confirmed gap擴張成長期maintenance framework。

### 5.2 Two complementary owners

Machine enforcement採兩層：

**Owner A — generic mapping validator**

- 每個Pencil screen root必須有resolved screen layout model；
- normal screen不得缺失layout disposition；
- intentional spatial canvas必須有approval evidence。

**Owner B — reference source architecture contract**

對template current Pencil compatibility proof建立direct source regression owner，明確拒絕已確認的mechanism：

- whole-screen global projection scale作page coordinate owner；
- custom RenderStack批量scale page-level `StackParentData.left/top/right/bottom`；
- root sections全部由canonical page `Positioned`排列；
- top-level delegated helper藏入fixed-coordinate reconstruction而view-level scan看不到。

Reference direct test應掃完整production owner set，不得只掃`write_precheck_view.dart`。

Generic mapping validator防未來initiative漏做layout decision；reference source test證明模板自己沒有示範錯誤pattern。兩者不可互相取代。

## 6. Reference implementation migration

### 6.1 Preserve visual authority

不修改：

- `source.pen`；
- canonical Pencil preview；
- visual authority source ranking；
- accepted text／icons／assets／colors；
- Gate thresholds／crop／ignore policy，除非Design被重新打開並取得獨立核准。

因此migration不是「改成比較responsive所以長得不一樣也沒關係」。Visual fidelity仍是hard acceptance owner。

### 6.2 Target page composition

`WritePrecheckView`仍可保持：

```txt
Scaffold
→ LayoutBuilder
→ scrollable content
```

但whole-screen implementation應從page coordinate plane改成flow/container composition，例如：

```txt
Screen
→ TopChrome
→ Progress
→ Hero
→ Summary
→ Results
→ Records
→ Guidance
→ Primary action
→ Secondary actions
→ Footer
```

Section placement由vertical flow、edge inset、sibling gap、alignment與container relationships決定。

每個section內如果accepted visual本身是freeform composition，可以保留bounded local `Stack`／`Positioned`。這些local coordinates不得使用canonical page origin，也不得決定下一個section的top。

### 6.3 Component geometry strategy

Canonical 941 design-space仍可作numerical source，用於推導：

- horizontal inset ratio／scaled inset；
- section preferred height／aspect ratio；
- component-internal icon／ornament offset；
- radius／stroke／shadow／font size；
- sibling gaps。

但runtime page geometry必須透過actual constraints組合，不建立`designHeight = 1672`的whole-screen canvas owner。

## 7. Responsive and accessibility contract

同一component tree必須同時處理：

- canonical comparison viewport；
- normal phone widths；
- narrow supported viewport；
- system safe areas；
- localization expansion；
- text scaling；
- scrollability／content growth。

Content-aware adaptation仍允許Row→Column、wrap、min interactive target、flex sizing等。不得因為canonical diff較容易而回到absolute page geometry。

## 8. Visual acceptance and migration gates

Migration必須維持既有AND semantics：

```txt
architecture gate
+ canonical fidelity
+ supported runtime fidelity
+ critical local fidelity
+ semantic review
= acceptance
```

也就是：

```txt
pixel PASS + architecture FAIL = overall FAIL
architecture PASS + visual P1 = overall FAIL
```

禁止為了新layout architecture：

- 放寬threshold；
- 改runtime projection reference迎合candidate；
- 加ignore region；
- 修改accepted `.pen`；
- 刪掉難以通過的critical local owner。

若current reference visual gate因cross-renderer historical calibration本身已不再合理，必須形成獨立P0/P1 finding並回Design，不得在implementation Task靜默修改比較契約。

## 9. Behavioral pressure contract

新增至少以下direct scenario：

```txt
PTF-27 — Single-renderer absolute-coordinate shortcut

Agent使用一套production whole-screen tree，沒有FittedBox、沒有whole-screen raster、
沒有第二renderer。Screen root是Stack；約50個Positioned的left/top/width/height
由Pencil canonical coordinates乘同一visualScale得到。所有widget都是真Flutter。

Expected: FAIL。
Reason: one renderer不代表constraint-based layout；whole-screen canonical coordinate
reconstruction仍是fixed-canvas architecture。回layout mapping，以relationship/container
semantics重建page flow。Bounded local overlays可保留。
```

另加反向scenario避免過度禁止：

```txt
PTF-28 — Bounded overlay is valid

Hero由Column放入screen flow，Hero內部用Stack+Positioned疊decorative ring與badge；
local coordinates相對Hero bounds，不控制其他section placement。

Expected: PASS，仍需normal visual/geometry evidence。
```

以及exception scenario：

```txt
PTF-29 — Genuine spatial canvas

Accepted Design明確定義diagram editor為spatial canvas，mapping使用
intentional-spatial-canvas且有approval_ref。

Expected: allowed；不得把一般settings/login page套用此exception。
```

## 10. Test Authoring strategy

### Required

- mapping validator schema／disposition RED → GREEN；
- reference architecture contract RED證明current projected whole-screen mechanism被抓到；
- replacement implementation的architecture GREEN；
- existing canonical/runtime visual owners保持或fresh恢復GREEN；
- pressure policy tests與fresh-agent behavioral acceptance。

### Recommended

- 一個layout relationship widget fixture，證明content growth／narrow width不依canonical page top constants；
- risk-selected critical section runtime geometry owner，如migration中發現constraint regression風險。

### Should-not-add

- every `Positioned` test；
- every section一個獨立golden；
- generic AST parser只為count Stack／Positioned；
- duplicate tests重複whole-screen visual owner。

## 11. ADR disposition

**Amend ADR-028，不新增第二ADR。**

理由：本corrective不是新的architecture domain，而是釐清ADR-028既有single-renderer responsive fidelity中「geometry projection」的合法邊界，並要求reference implementation與machine evidence符合該stable contract。

ADR-028 amendment至少固定：

- canonical page coordinates不是runtime page coordinate system；
- constraint／relationship-owned screen layout；
- bounded local overlay exception；
- intentional spatial canvas需accepted approval；
- whole-screen mechanical coordinate projection即使single renderer仍禁止。

## 12. Authority synchronization

Accepted implementation完成時必須同步：

```txt
ADR-028
implementing-pencil-flutter-design references
pressure scenarios
human Pencil-to-Flutter Guide
implementation mapping schema/tooling
current Pencil compatibility mapping evidence
reference production source/tests
roadmap/project context/audit routing
```

不在多份文件複製完整decision matrix；ADR擁有stable rule、Skill reference擁有Agent procedure、tool擁有machine schema、Guide只做人類routing。

## 13. Rollback and stop conditions

Implementation前的rollback boundary是accepted Milestone 40 / Template Baseline 1.20.0 main。

Implementation期間若出現以下任一項，停止並回Design／使用者決策：

- 維持visual fidelity被證明只能靠whole-screen absolute projection達成；
- `.pen`本身明確要求與normal App constraint layout不可兼容的spatial semantics；
- machine layout schema需要建立新的global authority；
- reference migration需要改accepted `.pen`／threshold／visual contract；
- proposed detector無法在不大量false positive的前提下提供有價值enforcement。

一般test failure、layout mismatch或source refactor finding直接在Task內修正並fresh re-review，不停下詢問。

## 14. Success criteria

Milestone 41只有同時滿足以下條件才可closure：

1. ADR／Skill／Guide一致定義constraint-based screen layout與bounded overlay boundary。
2. Mapping machine contract要求每個accepted Pencil screen root有resolved layout model。
3. Current reference proof不再使用whole-screen canonical coordinate reconstruction。
4. Reference architecture direct test能抓到原本projected `StackParentData` scaling mechanism。
5. Existing visual authority與canonical/runtime fidelity未被silent放寬。
6. PTF-27／28／29 policy與fresh isolated-agent behavioral pressure通過。
7. Full repository regression與required platform/build gates通過。
8. Open P0 = 0；undisposed P1 = 0。
9. Release／published-main／post-release evidence完成後才正式closure。
