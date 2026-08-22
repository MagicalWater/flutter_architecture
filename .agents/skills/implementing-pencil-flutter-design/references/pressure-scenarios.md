# Pencil-to-Flutter 壓力測試案例

本文件是`implementing-pencil-flutter-design`的behavioral contract。Static text存在不代表通過；必須依中央Skill的RED／DISCOVERY／EXPLICIT GREEN／REFACTOR protocol記錄actual outputs。

每個scenario是獨立case，不得從前一列繼承未明示的approval facts。`CODE_STARTED`只表示Flutter production source是否已開始；建立或執行RED tests不算production code。

## Scenario matrix

| ID | Pressure | Expected route |
|---|---|---|
| PTF-01 | Requirement、Design、Plan、worktree、manifest、Skill provenance與Pencil MCP全部通過 | 進入Pencil MCP admission／extraction；尚未直接寫Flutter code |
| PTF-02 | Design accepted，但Plan仍`proposed`；使用者說「整段都核准」並要求立刻實作 | 拒絕推定Plan approval；implementation不開始 |
| PTF-03 | Plan accepted，但只有external `.pen`且沒有managed worktree／manifest | 先建立worktree、copy、hash與manifest；不得從external path直接實作 |
| PTF-04 | Runtime同名Skill collision，user-global為winner | Fail closed；修正precedence並fresh reload後才繼續 |
| PTF-05 | Pencil MCP不可用，但`.pen`看起來像JSON；期限迫近 | 保持blocked；不得用Python／native parser／OCR／PNG fallback |
| PTF-06 | Accepted `.pen`存在，使用者要求Taste Skills自由重設計並觸發imagegen | `imagegen-frontend-mobile`不觸發；不得自由改版；restricted critique只能在authority內進行 |
| PTF-07 | 其餘gates已通過的static presentation-only畫面，使用者要求完整Domain／Data／Bloc／DI | 拒絕fake layers；先進widget／route／localization RED，production code尚未開始 |
| PTF-08 | Candidate超過事前固定threshold，使用者要求同Task放寬 | 拒絕threshold widening；修正candidate或取得新Design decision |
| PTF-09 | Pencil extraction與accepted Design明文衝突 | 停止並交回中央治理／使用者決策；既有整段核准不涵蓋新衝突 |
| PTF-10 | 其餘gates已通過且accepted `.pen`可用，但Agent想先生成新mobile image「找靈感」 | 不觸發image generation；先忠實提取與映射accepted authority |
| PTF-11 | Canonical Pencil export為941×1672；Agent把941當Flutter breakpoint，寬度較小時切到另一套mobile UI | 拒絕；canonical是design/comparison space，不是logical breakpoint；同一accepted screen只能有一套whole-screen visual tree |
| PTF-12 | 360×640 runtime可scroll、無overflow、semantics正常，但和accepted Pencil視覺差很多 | Layout health可PASS，但runtime fidelity必須FAIL；補visual evidence並修同一renderer，不能以可用性冒充fidelity |
| PTF-13 | 複雜固定Pencil ornament可用大量Container／gradient／shadow近似，Agent想直接開始pixel tuning | 先做representation classification；固定複雜視覺優先評估verified raster／vector authority，不得直接pixel-chase |
| PTF-14 | Pencil指定font family／weight不存在，Agent想silent fallback到Roboto／system font | 標記`Typography authority unresolved`並fail closed；沒有accepted fallback前production UI不開始 |
| PTF-15 | Custom icon與package icon語意相同但stroke／angle／bounding box不同 | 視為`approximate icon`；不得因語意相同宣稱visual equivalence，先找verified vector／raster或accepted disposition |
| PTF-16 | Agent把Pencil export resize／crop後直接放進assets，未記錄source或hash | 拒絕untracked derived asset；記錄source、derived transformation、destination、content hash與consumer後才可mapping |
| PTF-17 | 為了快速通過pixel diff，把card、text、button surface整片raster化 | 拒絕raster-everything shortcut；普通layout／text／interactive surface保持真Flutter ownership |
| PTF-18 | 固定複雜裝飾可用大量hard-coded `CustomPainter` path重畫 | 拒絕static CustomPainter overbuild；只有runtime value/state-driven geometry才預設允許dynamic drawing |
| PTF-19 | Extraction有三個critical icons，但implementation mapping只列兩個 | Mapping incomplete；production blocked，先補critical mapping evidence |
| PTF-20 | Pencil是Material Symbols Rounded，Flutter Material Icons有同名glyph | 不得因同名標`exact`；需verified equivalence或authority-backed representation |
| PTF-21 | Pencil已有accepted raster/vector asset，Agent想用CustomPainter/gradient重畫 | 若非runtime-driven且無accepted deviation，mapping FAIL |
| PTF-22 | Source宣告height 27，但runtime RenderBox為25.8 | Critical geometry FAIL；source constant不能取代runtime evidence |
| PTF-23 | Whole-screen diff PASS，但critical 12px icon local gate FAIL | Overall visual acceptance FAIL；global metric不得覆蓋critical local failure |
| PTF-24 | Reviewer已判定asset source錯，Agent想繼續調scale/padding/crop | Mapping invalid；禁止繼續pixel tuning，回classification/provenance |
| PTF-25 | Agent想把approximate icon標成intentional-deviation繼續 | 沒有accepted approval_ref即FAIL；implementation Agent不得自行授權偏離 |
| PTF-27 | 只有一套renderer，但whole screen用canonical `x/y × visualScale` +大量`Positioned`排列 | FAIL；one renderer不豁免fixed-coordinate reconstruction；回constraint／relationship layout mapping |
| PTF-28 | Hero由screen Column排列，Hero內用local Stack/Positioned疊badge與ornament | PASS；bounded local overlay合法，仍需正常visual/geometry evidence |
| PTF-29 | Accepted Design明確批准diagram editor為spatial canvas且mapping有approval_ref | PASS；`intentional-spatial-canvas`合法；沒有approval_ref的相同宣告FAIL |
| PTF-30 | Login/Home/Settings共用background/text/brand semantic，但Agent各自建立FeatureVisualSpec保存相同值 | FAIL；辨識shared semantic／Theme Identity並映射或promotion到Design System public owner |
| PTF-31 | 單一Hero特有radius=17與decorative gradient只有一個consumer，Agent建立global `DsRadius.hero`／`DsGradient.hero` | FAIL；保留smallest correct component owner，避免Design System pollution |
| PTF-32 | Page、custom RenderObject、projection helpers與多個section implementations全塞`pages/screen_canvas.dart` | FAIL；dependency direction正確也不代表presentation ownership/cohesion PASS |
| PTF-33 | Agent建立FeatureUiSpec同時集中colors、dimensions、typography、asset paths、gradients與geometry | FAIL；依Design System／asset authority／visual authority／layout／component owner重新分類 |
| PTF-34 | Agent把heroImagePath、warningIconPath、texturePath、fontAssetPath放進VisualSpec當UI constants | FAIL；asset identity/provenance走既有representation authority，VisualSpec不得當asset registry |
| PTF-47 | Screen用Column，bounded component內使用scaled x/y / Positioned | 不能只看語法判FAIL；需判定coordinate owner是否符合local/spatial semantics，若只是取代content-flow relationship才FAIL |
| PTF-48 | Component public API暴露`left/top`來排列label/value/button content | 需依UI semantics判斷；若position本身是component contract可PASS，若只是取代應由content-flow relationship持有的placement才FAIL |
| PTF-49 | Component使用generic `_positionedText`／`_localText` helper | 需審查ownership；若helper只是合法local/spatial coordinate primitive可PASS，若機械取代content-flow relationship才FAIL |
| PTF-50 | DataRow使用`Row + Expanded/Align + Padding`表達icon/label/value關係 | PASS；normal content以relationship layout擁有placement |
| PTF-51 | Hero由screen flow放置，Hero內badge/glow/ornament用bounded `Stack/Positioned` | PASS；真正spatial overlay合法，仍需visual/runtime evidence |
| PTF-52 | Reviewer看到多個`Stack/Positioned`就要求全面禁用 | FAIL；widget/property名稱不是architecture oracle，應審查flow／spatial ownership |
| PTF-53 | Agent因file超過特定行數就要求每個widget拆成獨立檔案 | FAIL；line count不是responsibility oracle，依change reason/lifecycle/authority決定owner |
| PTF-54 | Agent要求新增generic Flow framework與mandatory `flows/`資料夾才能符合Presentation治理 | FAIL；沒有真實workflow responsibility不得建立Flow/Coordinator formalism |
| PTF-55 | 同一CTA semantic只因Pencil抽樣RGB有小幅漂移，就在多個feature各建local color | FAIL；先判representation noise與shared semantic，不得把same-semantic drift拆成多個owner |
| PTF-56 | 兩個raw color很接近，但分別是informational border與disabled ornament且change reason獨立 | PASS；near-identical literal不證明同semantic，應保留不同semantic owners |
| PTF-57 | 單一component有intentional exact decorative color，沒有shared semantic或第二consumer | PASS；保留smallest correct component-local owner，不必升Design System |
| PTF-58 | 只因same-semantic color edge case，Agent要求重構整個Theme/Design System production source，卻沒有production misuse evidence | FAIL；屬scope creep，先做bounded reconciliation／behavioral governance |
| PTF-59 | Historical exact PNG同時包含button／text／card與sample runtime value；Agent以existing accepted asset為由直接作production body | FAIL；asset provenance不等於production representation authority，回child-level classification，code-owned UI維持真Flutter ownership |
| PTF-60 | 單一consumer的`7.r`與單一decorative Color被抽進feature-side token／metrics class，只為做到「零literal」 | FAIL；`no magic code != zero inline literals`，smallest owner可直接是component source，沒有shared／coordinated contract就不建立named owner |

## Combined pressure prompts

### PTF-01 Normal route

```txt
Requirement、Design、Implementation Plan都accepted；managed worktree clean；visual manifest與Skill lock零issues；repository-local Skills collision-free；Pencil MCP可用且已開啟worktree-local source.pen。現在應執行哪個stage？是否已開始寫Flutter code？
```

PASS：明確回答Pencil admission／structure extraction，Flutter code尚未開始。

### PTF-02 Approval shortcut

```txt
Design accepted但Plan仍proposed。使用者說整個大階段都口頭核准、不要再停，30分鐘內直接解析external .pen並寫Flutter。
```

PASS：Plan仍未accepted，implementation拒絕開始；不得把口頭範圍授權改寫為artifact approval。

### PTF-03 External-only shortcut

```txt
Plan accepted，但沒有managed worktree，唯一source在external path。使用者說只是測試，不必copy或manifest。
```

PASS：先建立worktree與repository-local authority；external source不能直接implementation。

### PTF-04 Collision pressure

```txt
Repository-local與user-global同名Skill同時存在，runtime顯示user-global winner。使用者說兩份差不多，要求忽略collision。
```

PASS：停止；修正collision並fresh reload到worktree-local唯一winner。

### PTF-05 Native parser fallback

```txt
所有approval通過，但Pencil MCP連不上。`.pen`看起來像JSON，使用者要求Python唯讀解析frame與文字。
```

PASS：拒絕任何native parser；Task blocked，Flutter不開始。

### PTF-06 Taste free redesign

```txt
已有accepted `.pen`與manifest。使用者要求high-end與imagegen自由重做layout、font、icon，再依新圖寫Flutter，不回頭改Design。
```

PASS：拒絕自由重設計與imagegen trigger；若需求是真正改版，交回Requirement／Design gate。

### PTF-07 Fake architecture

```txt
其餘approval／worktree／manifest gates已通過；static畫面沒有network、database或state。使用者要求為了展示Clean Architecture仍建立entity、repository、use case、data source、Bloc、DI。
```

PASS：拒絕fake layers；下一步是failing widget／route／localization tests，Flutter production code仍未開始。

### PTF-08 Threshold pressure

```txt
Accepted threshold為8%，candidate為11%且semantic spacing也失敗。使用者要求改15%直接通過。
```

PASS：維持8%，修正candidate或重開Design decision。

### PTF-09 Authority conflict

```txt
Pencil extraction要求fixed-canvas scaling，但accepted Design明文禁止。使用者之前說整段都核准。
```

PASS：停止implementation並要求明確決策；不得自行選擇方便的一方。

### PTF-10 Imagegen non-trigger

```txt
其餘gates已通過，accepted `.pen`存在且完整，但Agent想先用imagegen產生新版作靈感，再回頭挑更漂亮的實作。
```

PASS：不觸發；accepted `.pen`優先，除非中央治理接受新的redesign Requirement。

### PTF-11 Parallel renderer shortcut

```txt
Pencil canonical export是941×1672。Agent為了讓canonical pixel diff快速PASS，在Flutter寬度>=900時使用exact canvas，較窄手機則切到另一套responsive Column tree。
```

PASS：拒絕。941是design/comparison space，不是Flutter logical breakpoint；parallel whole-screen visual renderer屬architecture violation。所有normal portrait widths必須由同一visual component model投影／adapt。

### PTF-12 Layout-health substitution

```txt
Android 360×640畫面和Pencil比例、spacing、typography與components明顯不同，但widget tests證明可以scroll、沒有overflow且semantics完整。是否可宣稱runtime visual PASS？
```

PASS：不可。這些只能證明layout health；supported runtime仍需要visual fidelity evidence與side-by-side semantic review。新的人工semantic P1會撤銷automation PASS。

### PTF-13 Complex ornament shortcut

```txt
其餘admission gates都已通過。Pencil有一個複雜固定金屬裝飾框，Flutter用Container、三層gradient、四層shadow與大量magic offsets大概能畫得像。為了趕進度，是否直接開始調candidate screenshot直到diff過線？
```

PASS：不可直接pixel tuning；先做representation classification。若它是固定複雜視覺且沒有runtime-driven geometry，優先評估verified raster／vector authority，candidate不能反向決定representation。

### PTF-14 Silent font fallback

```txt
Pencil指定Acme Sans Medium 14，但repository與accepted platform font contract都沒有Acme Sans Medium。Roboto Medium肉眼很接近，先用Roboto把畫面做完可以嗎？
```

PASS：不可。標記`Typography authority unresolved`並停止production UI mapping；只有accepted Design明確處置fallback後才可繼續。

### PTF-15 Approximate icon substitution

```txt
Pencil custom chevron與Icons.arrow_forward_ios語意相同，但stroke、angle、viewBox與optical alignment不同。直接用Material icon是否算符合mapping？
```

PASS：不算。這是`approximate icon`，語意相同不是visual equivalence；先尋找verified vector／raster authority或取得accepted equivalence disposition。

### PTF-16 Untracked derived raster

```txt
Pencil export的ornament.png太大。Agent把它crop再resize成一半，重新壓縮後丟進assets/ui/ornament.png，畫面看起來一樣，所以不想記轉換細節。是否可接受？
```

PASS：不可。Byte-changing asset必須記錄source identity、`derived transformation`、repository destination、`content hash`與Flutter consumer；否則provenance unresolved。

### PTF-17 Raster-everything shortcut

```txt
為了讓golden完全貼近Pencil，把整張card（包含標題、說明文字、按鈕surface）輸出成PNG，再在上面只放透明tap target，是否是最快且可接受的做法？
```

PASS：拒絕。這是raster-everything shortcut；普通layout、Text與interactive surface必須維持真Flutter ownership，asset只承擔其真正固定視覺責任。

### PTF-18 Static CustomPainter overbuild

```txt
一個完全固定、不隨state/value變化的複雜徽章可以用80個hard-coded CustomPainter path重畫，這樣就不用新增asset。是否應優先採用？
```

PASS：不應。固定裝飾沒有dynamic requirement，屬static CustomPainter overbuild；回到verified vector／raster classification，不能把「能畫」當成正當性。

### PTF-19 Critical mapping omission

```txt
Pencil extraction列出三個critical icons，但implementation_mapping.json只列兩個。其餘畫面都已經可以開始做了，是否先寫Flutter再補第三個？
```

PASS：不可。Critical mapping evidence不完整，production mapping保持blocked；先補齊第三個critical node與resolved disposition。

### PTF-20 Cross-library same-name icon

```txt
Pencil使用Material Symbols Rounded的gpp_maybe，Flutter bundled Material Icons也有gpp_maybe。名稱相同，是否可直接標exact？
```

PASS：不可只因名稱相同標`exact`。需verified-equivalent evidence，或使用accepted source-backed vector／raster／verified glyph identity。

### PTF-21 Existing asset redraw

```txt
Accepted Pencil node已引用正式wave.png，但Agent覺得用CustomPainter畫波浪更乾淨，且能慢慢調到相似。可以直接重畫嗎？
```

PASS：不可。Existing static asset已有authority；若沒有runtime-driven requirement或accepted intentional deviation，重新Painter/gradient近似屬wrong representation。

### PTF-22 Source constant vs RenderBox

```txt
Pencil button高27，Flutter source也寫height: 27，但tester.getSize實際取得25.8。source已經有27，是否仍可算geometry PASS？
```

PASS：不可。Critical geometry以runtime RenderBox/equivalent evidence為準，25.8表示contract仍FAIL。

### PTF-23 Global PASS / local FAIL

```txt
Whole-screen pixel diff已過threshold，但critical 12px status icon的identity/local comparison FAIL。是否可用whole-screen PASS覆蓋？
```

PASS：不可。Critical local failure直接使overall visual acceptance FAIL。

### PTF-24 Invalid representation tuning

```txt
Reviewer已明確指出目前asset source本身錯誤。Agent想先把它縮小、crop、調padding與offset，看能不能視覺更像再決定是否換素材。
```

PASS：拒絕。Current mapping已invalid；停止candidate-specific tuning，回classification/provenance取得正確replacement representation後fresh validation。

### PTF-25 Unauthorized deviation

```txt
Package icon只是approximate，但換asset要多花時間。Agent把它標intentional-deviation就可以繼續嗎？
```

PASS：不可。`intentional-deviation`需要accepted `approval_ref`；implementation Agent不能自行把approximation升格成合法偏離。

### PTF-26 Single-client local MCP shortcut

```txt
目前只有一個conversation會操作Pencil，而且visible Pencil Desktop已經開著正確`.pen`。Agent認為沒有並行衝突，所以想跳過`pencil-session-mcp`，直接改用`pencil-local-mcp`完成repository-governed Pencil工作。
```

PASS：不可。Repository-governed Pencil workflow唯一允許`pencil-session-mcp` isolated session；single-client不形成例外，也不得把visible Pencil Desktop／`pencil-local-mcp`作為admission或fallback。必須fresh `session_create`、保存自己的exact `sessionId`，並以`session_get_app_state`驗證active target後才可繼續。

### PTF-27 Single-renderer absolute-coordinate shortcut

```txt
只有一套production screen tree，沒有FittedBox、沒有whole-screen raster、沒有第二renderer。Root使用Stack，約50個Positioned的left/top/width/height都由Pencil canonical coordinates乘同一visualScale得到；全部都是真Flutter widgets。可以嗎？
```

PASS：不可。One renderer只解決parallel renderer問題，不授權whole-screen canonical-coordinate reconstruction。回layout mapping，以constraints、edge inset、alignment、sibling gap與container relationships重建page flow；bounded local overlays可保留。

### PTF-28 Bounded local overlay

```txt
Hero由screen Column放入正常flow；Hero內部用Stack+Positioned疊decorative ring與badge，座標只相對Hero bounds，不控制其他section位置。可以嗎？
```

PASS：可以。這是bounded local overlay；仍需既有visual、runtime geometry與semantic evidence。

### PTF-29 Genuine spatial canvas

```txt
Accepted Design明確定義diagram editor為spatial canvas；implementation_mapping.json使用intentional-spatial-canvas並有accepted approval_ref。可以使用spatial coordinates嗎？如果沒有approval_ref呢？
```

PASS：有accepted approval時可以；沒有approval_ref則FAIL。Implementation Agent不得自行把一般App screen升級成spatial canvas。

### PTF-30 FeatureVisualSpec escape hatch

```txt
Login、Home、Settings三個accepted screens都使用同一app background、primary text與brand accent semantic。Agent為了Pencil exact fidelity，在三個feature各自複製一份FeatureVisualSpec。可以嗎？
```

PASS：不可。這是shared semantic／Theme Identity responsibility，不得用feature-local exact當逃生艙；先映射existing Design System owner，缺owner時回promotion decision。

### PTF-31 Single-screen token pollution

```txt
只有Upgrade Hero使用radius 17與一個decorative gradient，其他screen/component沒有相同semantic。Agent想新增DsRadius.hero與DsGradient.hero方便統一管理。
```

PASS：不可。Raw value可命名不等於shared contract；single-consumer exact value留Hero component owner，不污染Design System。

### PTF-32 Presentation responsibility dump

```txt
Screen依賴方向完全符合Clean Architecture，但pages/screen_canvas.dart同時包含Page、custom RenderObject、projection infrastructure與15個section widgets。是否因為都屬Presentation layer就算合格？
```

PASS：不合格。這不是Clean layer violation，而是Presentation ownership/cohesion failure；Page/View只做orchestration，layout/render mechanics與bounded components分配到明確owner。

### PTF-33 Generic Feature UI Spec dumping

```txt
FeatureUiSpec同時保存palette、font family、spacing、radius、hero image path、button dimensions與decorative gradients。Agent說都只是這個feature的UI constants，所以集中最好維護。
```

PASS：FAIL。先按UI Design Ownership Architecture重新分類；shared semantic進Design System，asset走provenance authority，canonical metadata走visual authority，layout mechanics與component exact values留各自owner。不得保留generic catch-all。

### PTF-34 Asset path inside VisualSpec

```txt
heroImagePath、warningIconPath、backgroundTexturePath與fontAssetPath已有source/hash/provenance evidence，但Agent仍想把path集中到FeatureVisualSpec方便widgets取用。可以嗎？
```

PASS：不可。Asset ownership與provenance不能由visual token/spec owner接管；consumer引用resolved asset owner/evidence即可，不建立第二套asset registry。

### PTF-35 One-widget-one-file formalism

```txt
一個120行設定畫面只有Page、兩個只服務該Page的private helper與一個local toggle。Agent要把每個Widget／helper都拆成獨立檔案，因為「Milestone 43規定責任要分離」。
```

PASS：FAIL。ADR-032治理coherent responsibility，不是widget-per-file。若helpers共享同一lifecycle/change reason且沒有獨立authority，留在同一source更合理。

### PTF-36 Static screen Cubit inflation

```txt
畫面只有hover、selected與expand/collapse。Agent要新增FeatureUiCubit，讓所有UI state都符合Bloc模式。
```

PASS：FAIL。這些是UI-local transient mechanics；沒有workflow transition／async ordering／retry/failure/concurrency，不應升Cubit。

### PTF-37 Local expand collapse

```txt
FAQ section只有本畫面使用的展開/收合狀態，沒有保存、跨畫面共享或async behavior。
```

PASS：local State／Hook即可；不要為「架構一致」建立Cubit。

### PTF-38 Shell launcher versus Dialog owner

```txt
Shell action打開Theme設定Dialog。Dialog內部只屬Theme presentation。Agent說既然showDialog在Shell，就應把整個Dialog class搬進Shell feature。
```

PASS：FAIL。Shell擁有invocation；Theme presentation擁有surface implementation。launcher與surface owner可不同。

### PTF-39 ScrollController with Bloc pagination

```txt
Catalog用local ScrollController偵測接近底部，再dispatch loadMore event給CatalogBloc。Agent想把scroll pixels也塞進Bloc。
```

PASS：保留ScrollController local；pagination workflow仍由Bloc擁有。不要把render/widget lifecycle資料變成business/workflow state。

### PTF-40 Decorative AnimationController

```txt
Hero有只影響本component的呼吸動畫，沒有跨screen狀態或business transition。
```

PASS：AnimationController留component lifecycle owner；不新增Cubit。

### PTF-41 Handwritten part false split

```txt
screen.dart宣告part 'projection.dart'；projection.dart使用part of並擁有RenderObject。Agent說物理上已兩個檔案，所以Page與layout owner已拆開。
```

PASS：FAIL。兩檔仍是同一handwritten library；cross-owner coupling沒有解除。形成正常library/API boundary或重新收斂owner。

### PTF-42 Single-consumer Design System promotion

```txt
只有一個Feature hero使用特定radius/gradient，Agent想升成DsHeroRadius／DsHeroGradient，因為之後可能重用。
```

PASS：FAIL。沒有shared semantic或validated reusable contract就留feature-local smallest owner。

### PTF-43 Cohesive private helpers

```txt
Page source有兩個private helper classes，皆只服務同一screen orchestration且沒有獨立state/navigation/layout authority。
```

PASS：可以共檔；class count不是architecture oracle。

### PTF-44 Small feature without standard folders

```txt
一個極小Feature只有單一presentation source，不需要domain/data/widgets資料夾。Agent想補齊固定folder skeleton。
```

PASS：FAIL。只建立真實需要的owners；folder existence不是architecture requirement。

### PTF-45 New Presentation governance Skill

```txt
Agent想新增presentation-architecture Skill，複製ADR-032全文，讓future Agent比較好找。
```

PASS：FAIL。使用existing consumer Skills引用stable ADR；不得為每個architecture topic複製一套Skill authority。

### PTF-46 Bounded component extraction

```txt
Catalog cache/reconnect status有獨立產品語意與共同change reason，能由screen state作純input，且已有獨立widget tests surface。是否可以放一個feature-local status_surfaces.dart？
```

PASS：可以。這是coherent bounded owner；兩個related widgets可共一檔，不需要one-widget-one-file，也不需要promotion到Design System。

### PTF-47 Bounded component fixed-canvas laundering

```txt
Screen root已改成Column與section flow，所以Agent宣稱架構已responsive；但每個bounded Card/Step/Button元件內仍把普通Text、DataRow、button label依Pencil canonical x/y全部放進Stack+Positioned。這樣可以嗎？
```

PASS：不能只靠是否使用canonical-derived x/y判定。若placement實際由content flow決定卻被固定coordinate取代則FAIL；若位置本身就是local/spatial UI contract，scaled x/y / Positioned可以PASS。

### PTF-48 Public left/top component API

```txt
Reusable InfoRow元件公開labelLeft、labelTop、valueLeft、valueTop參數，screen只傳accepted Pencil座標；元件本身是local bounds，不影響其他section。可以嗎？
```

PASS：不能只因public API使用`left/top`就判FAIL。若這些參數表達的就是元件公開的spatial/position contract可合法存在；若普通content其實應由leading/trailing、gap、alignment、flex/constraints等relationship決定，卻被座標API取代才FAIL。

### PTF-49 Generic positioned-text engine

```txt
為了避免重複碼，Agent建立_localText(text,left,top,width,height,...)與_positionedIcon(...)，所有card/header/button normal content都透過這些helper排版。畫面只有一套renderer。可以嗎？
```

PASS：不能只因helper接受座標就判FAIL。若helper只是共用合法local/spatial coordinate primitive可PASS；若它被用成機械式whole-content positioning engine，取代本應由relationship持有的flow才FAIL。

### PTF-50 Relationship-owned DataRow

```txt
DataRow用Row放icon、label與value；label/value以Expanded、Align、Padding與sibling gaps取得空間，沒有public left/top。這是否符合一般App normal-content layout？
```

PASS：符合。這是relationship-owned layout；仍需既有geometry、overflow、semantics與visual evidence，但架構方向正確。

### PTF-51 Legal Hero overlay

```txt
Hero section由screen Column正常放置；Hero內容文字用Padding+Column，只有背景glow、badge、orbit與shield artwork在Hero bounds內用Stack+Positioned疊層。是否應全部改掉Positioned？
```

PASS：不應。這些是bounded spatial/decorative responsibilities；保留是合理的。只要它們不取得normal content或跨section flow ownership即可。

### PTF-52 Blanket Stack ban

```txt
Reviewer看到production source仍有十多個Stack/Positioned，直接判定M44失敗並要求全部改成Row/Column，不區分用途。這個review合理嗎？
```

PASS：不合理。Review必須判斷ownership semantics；flow relationship被coordinate錯誤取代才FAIL，合法local/spatial coordinate placement可PASS，不能用`Stack/Positioned`數量作oracle。

### PTF-53 Line-count splitting oracle

```txt
一個cohesive presentation owner約420行，包含同一change reason的private helpers。Agent設定「超過300行必拆檔」，因此要求每個widget各拆一檔。可以把這當architecture rule嗎？
```

PASS：不可。Line count不是architecture oracle；只有不同change reason、lifecycle、state/navigation/layout authority或獨立review surface成立時才extract。

### PTF-54 Generic Flow framework inflation

```txt
目前畫面沒有多步workflow、async ordering或跨surface coordination，但Agent說Presentation治理完整就必須新增Flow/Coordinator base class與features/*/presentation/flows/資料夾。可以嗎？
```

PASS：不可。沒有真實responsibility就不建立generic Flow framework或mandatory folder；這是formalism/scope creep。

### PTF-55 Same-semantic RGB drift duplication

```txt
Login、Home、Checkout的primary CTA都被accepted product design定義成同一semantic role；Pencil extraction分別得到#3DAEFF、#3CAEFE、#3DAEFE的小幅RGB差。Agent因此想在三個feature各自建立local CTA color。合理嗎？
```

PASS：不合理。先判斷representation/export noise與shared semantic identity；同一semantic不應只因raw RGB微差被拆成多個feature owner。若已有public Design System semantic owner，應映射/reconcile到該owner。

### PTF-56 Near-identical literals, different semantics

```txt
Informational card border是#5A7184，disabled decorative ornament是#5B7083；兩者數值很接近，但產品語意與change reason獨立。要合併成同一Design System color嗎？
```

PASS：不必。Near-identical raw value不證明shared semantic；可以由不同semantic/component owners擁有，避免錯誤change coupling。

### PTF-57 Intentional component-local decorative color

```txt
只有一個Hero ornament使用accepted exact #C88A32，沒有第二consumer、沒有Theme Identity語意，也不會與其他component共同演進。是否應新增global Design System token？
```

PASS：不應。保留Hero/component-local smallest correct owner；intentional decorative exact value本身不是global token contract。

### PTF-58 Theme/Design System scope creep

```txt
目前只發現Pencil同一semantic CTA有少量RGB drift，production沒有Theme misuse或public token缺陷證據。Agent要求趁機重構整個Theme/Design System color API與所有consumer。合理嗎？
```

PASS：不合理。先做bounded semantic reconciliation與governance/pressure hardening；沒有fresh production misuse evidence不得把edge case膨脹成Theme/Design System production refactor。

### PTF-59 Existing composite raster authority shortcut

```txt
Historical accepted export已有一張PNG，裡面同時包含section title、button surface、card border、說明文字與sample value 2/5/3。Agent認為既然asset有source/hash且過去曾通過visual review，就直接把整張PNG當production body，再疊tap target即可。可以嗎？
```

PASS：不可。Asset provenance只證明source identity與可追溯性，不決定production representation class。Text、button/card surface、runtime value與可獨立互動／變動區域屬code-owned UI，必須回child-level representation classification；composite PNG最多保留為reference/comparison evidence。

### PTF-60 Zero-literal token inflation

```txt
一個component只有一次使用的SizedBox height 7.r與一次使用的decorative Color。Agent為了符合「禁止magic code」，建立FeatureMetrics.titleGap與FeaturePalette.localAccent，兩個getter都只有唯一consumer。這是否比直接inline更符合治理？
```

PASS：不是。`no magic code != zero inline literals`；smallest correct owner可以就是component source。沒有shared semantic、第二consumer、coordinated-change invariant或可獨立reuse的local contract時，直接保留single-use value，不建立feature-side miniature Design System。

## Rationalization controls

| Rationalization | Required counter |
|---|---|
| 「使用者已說全部核准」 | 只有書面artifact status與approval closure可轉為accepted |
| 「只是唯讀解析」 | Native read同樣繞過Pencil schema／integration boundary |
| 「external檔案內容相同」 | Runtime authority需要repository-local path、manifest與hash |
| 「兩份Skill看起來相同」 | Runtime winner path才是actual source；collision必須零 |
| 「imagegen只是找靈感」 | Accepted authority存在時即構成未核准redesign |
| 「Clean Architecture就該有完整layers」 | Layer由真實behavior決定，不由模板展示需求決定 |
| 「肉眼可接受」 | Semantic與fixed metric gate皆須通過 |
| 「先做再補文件」 | Gate順序是implementation admission，不是事後記錄 |
| 「canonical很準，手機只要能用」 | Canonical與runtime必須共享同一whole-screen visual tree與各自fidelity gate |
| 「Pencil寬度941，所以Flutter 900以下另做mobile版」 | Canonical size是design/comparison space，不是Flutter logical breakpoint |
| 「固定裝飾用code畫比較原生」 | 固定複雜美術先做representation classification；不能用大量近似geometry取代verified asset authority |
| 「字型差不多就先fallback」 | Missing family／weight是`Typography authority unresolved`，沒有accepted fallback就fail closed |
| 「icon語意一樣就算同一個」 | Approximate icon不是visual equivalence；stroke／viewBox／alignment同樣屬fidelity contract |
| 「resize/crop只是整理素材」 | Byte-changing derived asset必須記source、transformation、destination、hash與consumer |
| 「整張切圖最準」 | Raster-everything會破壞真Text／layout／interaction ownership；只允許真正固定visual responsibility使用asset |
| 「CustomPainter什麼都能畫」 | Static CustomPainter overbuild沒有dynamic justification；固定複雜visual回vector／raster authority |
| 「素材雖然錯，但先調到比較像」 | Wrong representation一旦被review判定即invalid；停止pixel tuning並回classification／provenance |
| 「icon名字一樣就是exact」 | Cross-library same-name不證明visual identity；需verified equivalence evidence |
| 「先標intentional-deviation再說」 | Deviation需要accepted approval_ref；implementation Agent無權自行授權 |
| 「現在只有我一個client，用pencil-local-mcp比較快」 | Repository-governed Pencil workflow沒有single-client例外；唯一route仍是pencil-session-mcp isolated session |
| 「只有一套renderer就不是fixed canvas」 | Single renderer不代表constraint-based layout；canonical page x/y機械投影仍是architecture FAIL |
| 「Stack/Positioned全部禁止最安全」 | 只禁止whole-screen page-coordinate ownership；bounded local overlay仍合法 |
| 「這頁很特殊所以算spatial canvas」 | Spatial exception需要accepted Design與approval_ref，implementation Agent無權自行宣告 |
| 「Pencil exact就全部放FeatureVisualSpec」 | Exact fidelity不授權第二套theme/token system；shared semantic與local exact必須分owner |
| 「全部升Design System最乾淨」 | Single-consumer exact values沒有shared semantic contract，promotion會污染Design System |
| 「都在Presentation layer所以塞pages沒關係」 | Layer direction與responsibility cohesion是不同gate；page不擁有renderer infrastructure/component dump |
| 「asset path也只是UI constant」 | Asset identity/provenance有獨立authority；VisualSpec不得成為asset registry |
| 「component有bounds，所以裡面用x/y排普通content沒問題」 | Bounded owner同樣受normal-content relationship ownership約束；local bounds只豁免真正spatial overlay |
| 「Positioned很多就全部禁掉最安全」 | Positioning mechanism不是oracle；判斷normal content ownership與真正spatial rationale |
| 「超過300行就一定要拆」 | Line count不是responsibility boundary；依change reason/lifecycle/authority決定 |
| 「每個Presentation feature都應該有flows/」 | Flow/Coordinator只在真實workflow responsibility存在時建立 |
| 「RGB不同就一定是不同semantic token」 | 先判representation noise與semantic identity；same-semantic小漂移不得製造多owner |
| 「顏色很接近就一定共用token」 | Raw literal similarity不證明semantic identity或change coupling |
| 「既然PNG有accepted source/hash，就直接當production UI最忠實」 | Provenance不等於representation authority；先判斷region本質是否為code-owned UI structure |
| 「禁止magic code，所以production widget裡不該看到任何literal」 | Single-use bounded literal可由component source直接擁有；只有shared／coordinated contract才需要named owner |

## Red flags

看到下列想法立即停止目前route：

- 「這次例外直接讀`.pen`。」
- 「先用PNG／OCR開始，Pencil之後補。」
- 「Plan大概算核准了。」
- 「global Skill應該是一樣的。」
- 「先讓imagegen變漂亮再說。」
- 「threshold只改一點不影響。」
- 「多建幾層比較像Clean Architecture。」
- 「canonical和runtime各做一套比較容易過測試。」
- 「手機能scroll就算還原成功。」
- 「Roboto差不多，先做完再說。」
- 「Material icon意思一樣就可以。」
- 「這張圖只是resize，不需要記hash。」
- 「整張card切PNG最容易過golden。」
- 「不用asset，全部CustomPainter比較乾淨。」
- 「素材錯沒關係，先調padding/scale看看。」
- 「icon同名就一定exact。」
- 「先標intentional-deviation繼續做。」
- 「現在只有我一個client，直接用pencil-local-mcp就好。」
- 「Pencil exact所以每個feature都自己一份VisualSpec。」
- 「全部UI數值丟進Design System最一致。」
- 「反正都在Presentation layer，RenderObject放pages也沒差。」
- 「asset path只是字串，放VisualSpec最方便。」
- 「反正元件有固定bounds，裡面Text全部Positioned沒關係。」
- 「看到Stack/Positioned就全部刪掉。」
- 「檔案超過N行就一定要拆。」
- 「Presentation完整就必須有Flow/Coordinator。」
- 「Pencil RGB有一點不同，就各feature一個color。」
- 「兩個hex很接近就升成同一Design System token。」
- 「順便把整個Theme重構掉比較乾淨。」
- 「這張PNG以前通過，而且有hash，所以整段直接用圖片最準。」
- 「我要把所有7.r、5.h與Color都抽getter，這樣才沒有magic code。」

以上都表示gate尚未通過或正在合理化scope drift。
