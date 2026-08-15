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

以上都表示gate尚未通過或正在合理化scope drift。
