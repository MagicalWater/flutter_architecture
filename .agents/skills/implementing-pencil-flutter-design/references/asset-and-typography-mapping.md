# Asset / Vector / Typography Mapping & Provenance

## Purpose

本reference擁有Pencil extraction完成後、Flutter authority mapping開始前的**representation classification**與provenance決策。它不擁有Requirement／Design／Plan核准、不解析`.pen`、不改visual authority，也不決定Flutter feature architecture。

必要順序：

```txt
extracted visual inventory
→ primary representation class
→ source / availability verification
→ provenance resolution
→ unresolved representation gap check
→ handoff to Flutter mapping
```

只要required representation仍unresolved，就不得開始Flutter production UI source。

## Representation Classes

每個需要實作決策的Pencil元素指定一個primary class：

| Class | Default Flutter representation | Examples |
|---|---|---|
| Layout primitive | Flutter widget／decoration | fill、radius、divider、普通border／shadow |
| Typography | verified font authority + `TextStyle` | body、title、label、numeric readout |
| Approved package icon | repository-approved exact-enough icon | standard navigation／status icon |
| Vector asset | verified SVG／vector authority | custom static icon、geometric mark |
| Raster asset | repository-local raster authority | texture、illustration、complex fixed ornament |
| Dynamic drawing | `CustomPainter`或等價dynamic primitive | value-driven progress、chart、waveform、runtime path |

分類依據是visual是否固定、是否需要無損縮放、是否由runtime state/value驅動，以及是否已有exact approved representation。不得以「哪種最快通過screenshot」作決策。

## Primitive vs Asset

- 普通card、divider、button surface、solid fill、radius與可正常表達的shadow使用真Flutter primitive。
- 複雜固定紋理、插畫、品牌裝飾若只能靠大量gradient／shadow／magic path近似，優先保留verified raster／vector authority。
- 不得因為「native code比較高級」重畫固定美術。
- 不得使用**raster-everything shortcut**把text、button或普通interactive surface整片轉成圖片來追求pixel diff。
- Full-screen raster仍受single-renderer與visual-validation禁止事項約束。

## Vector vs Raster

- Static geometric source需要多尺寸清晰縮放，且verified source本質可無損向量表示時，優先vector。
- Source只有raster authority時，不得自行trace成vector後宣稱等價；任何representation conversion需要accepted disposition。
- Raster/vector若經resize、crop、compression、format conversion或其他byte-changing處理，必須記錄**derived transformation**與output **content hash**。
- 不得因為candidate pixel diff不好看，事後改trace／resize／crop規則來迎合candidate。

## Dynamic Drawing

- 只有visual geometry真的由runtime value／state參數化時，才預設使用`CustomPainter`或等價dynamic drawing。
- 固定複雜裝飾不得以**static CustomPainter overbuild**取代既有vector／raster authority。
- Painter geometry必須來自accepted design／mapping contract；不得用candidate-driven pixel chasing反推hard-coded path。
- 如果static/dynamic性質無法判定且會影響architecture或fidelity，保持blocked並回Design disposition。

## Typography

Production implementation前必須確認：

1. Pencil要求的font family是否存在於repository或accepted platform font contract。
2. 使用的weight／style是否有對應font face，或accepted contract明確允許synthetic behavior。
3. Font size、line height、letter spacing、weight與text decoration是否可由Flutter忠實表示。
4. Decorative lettering／logo是否其實是visual asset，而不是普通Text。

指定font family／weight不存在、來源不明或fallback未被accepted Design處置時，狀態必須標記：

```txt
Typography authority unresolved
```

此狀態是production UI hard stop。不得silent fallback成Roboto、system font或「最接近」字型後仍宣稱fidelity PASS。

## Icons

- Approved package icon只有在visual identity exact-enough時可直接使用。
- 「語意相同」不代表「視覺相同」。Stroke、angle、viewBox、bounding box、optical alignment明顯不同時，屬**approximate icon**，不得自動視為visual equivalence。
- Package沒有exact-enough match時，優先使用verified vector／raster authority。
- 自建Painter icon必須有dynamic或其他明確技術理由；不能只是因為package icon不夠像。

## Provenance Contract

Repository-local raster、vector與font mapping evidence至少可追溯：

```txt
accepted Pencil node / visual source
→ source or export identity
→ derived transformation, if any
→ repository destination
→ content hash
→ Flutter owner / consumer
```

- 未改bytes的原始asset可標記`derived transformation: none`。
- 相同content hash已有authority時優先重用，不新增無理由duplicate bytes。
- 檔名不得成為唯一provenance，例如`warning_final_2.png`不能取代source/hash evidence。
- 本contract不建立global asset registry；證據留在對應Pencil-to-Flutter Task mapping evidence、既有visual manifest與Git history。

## Mapping Output Gate

對accepted Design／Plan判定為critical的node／region，Task需建立initiative-local machine-readable implementation mapping evidence。預設位置：

```txt
docs/visual_authority/<initiative>/implementation_mapping.json
```

此artifact只保存critical implementation mapping，不取代`.pen`或visual authority manifest，也不建立global asset registry。Machine validator由`tools/visual/pencil_implementation_mapping.py`擁有。

Critical mapping disposition固定為：

```txt
exact
verified-equivalent
intentional-deviation
unresolved
```

- `verified-equivalent`必須有可追溯`evidence_ref`；語意或glyph名稱相同不是證據。
- `intentional-deviation`必須有accepted `approval_ref`；implementation Agent不得自行宣告。
- `unresolved`在production acceptance時fail closed。
- Raster／Vector critical mapping必須保存source identity、derived transformation、destination與content hash。
- Validator只檢查Pencil MCP extraction後的mapping evidence，不得解析`.pen`。

進入`flutter-mapping.md`前，Task evidence必須能回答：

1. 哪些元素是Layout primitive？
2. 哪些是Typography，family／weight authority是否resolved？
3. 哪些是Approved package icon，是否為exact-enough match？
4. 哪些是Vector asset／Raster asset，source、transformation、destination與content hash是什麼？
5. 哪些是Dynamic drawing，runtime-driven理由是什麼？
6. 是否仍有unresolved或approximate representation？

第6項若存在未取得accepted disposition的P1 gap，Flutter mapping與production UI保持blocked。

## Invalid Mapping Recovery

Review若判定wrong source identity、wrong asset、wrong icon或wrong representation，current mapping立即失效：

```txt
wrong representation identified
→ mark affected mapping invalid
→ stop candidate-specific pixel tuning
→ return to representation classification / provenance
→ resolve replacement representation
→ update mapping evidence
→ fresh affected validation
→ restart affected visual acceptance
```

Invalid mapping不得靠padding、scale、crop、offset、opacity或threshold調整恢復成accepted。若原mapping其實可被證明為`verified-equivalent`，先補事前可追溯equivalence evidence再重新candidate；不能用「調完看起來更像」取代identity evidence。

若source authority本身要改，implementation不得修改accepted `.pen`迎合Flutter；回中央Requirement／Design disposition。

## Forbidden Shortcuts

- Silent font fallback。
- Approximate icon substitution冒充visual equivalence。
- Untracked derived raster／vector。
- Raster-everything shortcut。
- Static CustomPainter overbuild。
- Candidate-driven pixel chasing決定asset／Painter／font／icon representation。
- 修改accepted `.pen`來迎合Flutter implementation。

