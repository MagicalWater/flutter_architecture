---
document_type: phase-review
status: accepted
authoritative_for:
  - milestone-40-hero-visual-family-extraction
last_reviewed_baseline: 1.20.0
---

# Task 40-7R-1 — Visual-family Extraction & Generation Brief

## Inputs

- `docs/assets/architecture/productized-topology.png`
- `docs/assets/architecture/c4-dependency-contract.png`
- accepted Hero Design：`docs/superpowers/specs/2026-08-17-milestone-40-hero-visual-corrective-design.md`
- rejected anti-regression reference：`docs/assets/readme/rejected/flutter-enterprise-architecture-hero-40-7.png`

兩張accepted visuals皆為`1672 × 941` PNG，current documentation把它們定位為architecture authority的**視覺摘要**：第一張負責productized topology／Composition Root／packages／external systems；第二張負責C4-style component ownership與allowed dependency contract。

## Visual-family extraction

### Primary geometry language

- 以**正交矩形／面板式module**為主要幾何語彙，而不是球體、晶片、motherboard、server rack或random 3D blocks。
- 模組具有清楚的containment與群組層級；視覺讀法是「系統由可辨識邊界組成」，不是裝飾性科技網路。
- 主體應維持平整、理性、diagram-adjacent的結構感；Hero可有有限dimensionality，但不可改成重3D物件渲染。

### Module / container shape

- 核心為清楚的矩形container與nested module。
- container責任透過位置、尺寸、分組與間距辨識，不依賴浮誇材質。
- Hero應抽取「可組裝模組」這個語意，而不是直接搬運diagram card或文字label。

### Layer hierarchy signal

- hierarchy呈現**由foundation／lower-level capability往application composition收斂**的秩序。
- Hero的低資訊密度版本固定為：

```txt
modular reusable foundations
→ ordered architecture layers
→ composed mobile application shell
```

- 不把完整Presentation／Domain／Data／Infrastructure文字寫進Hero；使用幾何層級與相對位置表達。

### Connector / dependency signal

- connector是**受控、結構化、具方向性的關係線**，不是隨機network web。
- Hero只保留少量粗粒度composition path；細小箭頭、密集connector與完整dependency contract仍屬兩張正式架構圖。
- connector必須服務「modules compose into app」而不是視覺裝飾。

### Blue / cyan accent behavior

- source family以深graphite／near-black為base，blue／cyan是**結構強調色**，不是滿版霓虹光。
- accent應集中在critical composition path、selected edges或少量hierarchy signal。
- 不使用purple／magenta cyberpunk glow、RGB motherboard lighting或大面積electric bloom。

### Surface / depth treatment

- source family的核心價值是清楚structure，而非材質展示。
- Hero允許subtle depth、soft separation與有限surface highlight，但不得讓材質／反射／立體方塊蓋過architecture metaphor。
- 四周需要self-contained framing，不能依賴GitHub dark background延續canvas。

### Density / negative-space pattern

- 正式architecture visuals可承載較高資訊密度；Hero必須刻意降密度。
- Hero中央安全區只保留三個大訊號：`modular foundations`、`ordered layers`、`mobile application shell`。
- 左右邊緣只允許可裁切supporting decoration；360px縮放時核心仍需成立。

## Repository-specific cues

以下才是本repository family可帶入Hero的結構語彙：

1. Composition Root／App-owned composition的「多個能力最後被組裝成單一App」視覺邏輯。
2. reusable packages不是散亂外掛，而是有界modules，透過受控dependency回到app composition。
3. Clean Architecture的ordered layer感，而不是雙向network。
4. 深graphite + restrained blue/cyan，只作architecture hierarchy accent。
5. clean rectangular modules + structured connectors + controlled negative space。

## Generic cues that must NOT be copied

以下即使看起來「高級科技」也不是repository identity，candidate出現為主體時應FAIL：

- random floating 3D cubes；
- motherboard／CPU／server-chip；
- cloud／AI brain／database cylinder；
- random glowing nodes／orbit network；
- generic smartphone mockup／app screenshot；
- neon cyberpunk ambient glow；
- 只剩dark + blue而沒有module／layer／composition relationship。

## Source text contamination boundary

兩張source diagrams含有文字與component labels。Generation只允許抽取visual family，不允許帶入：

- 任何可讀文字；
- 英文字母／數字；
- 偽字／殘缺字形；
- component label fragments；
- source diagram截圖式區塊。

任何上述內容出現在candidate，即視為critical FAIL。

## Generation brief

生成一張約`3:1`的wide editorial architecture Hero。構圖不是第三張diagram，而是把「enterprise Flutter template如何把reusable foundations與ordered architecture layers組裝成mobile application」濃縮為單一視覺隱喻。

主體要求：

- 中央有抽象mobile application shell，但不是手機mockup或UI screenshot。
- app shell與3～4個ordered architecture layers具有清楚組成關係。
- 少量rectangular reusable modules由兩側／下方透過structured composition paths收斂進中央app shell。
- 深graphite self-contained canvas；blue/cyan只作結構accent。
- 保留大量negative space與中央safe area。
- 無文字、無字母、無數字、無logo、無偽字。
- 不拼貼／重製兩張source diagrams。
- 不使用generic 3D blocks、chip、server、cloud、random network nodes。

## Candidate acceptance anchor

若拿掉README H1，Hero至少仍必須讓人讀成「有秩序的模組／分層能力被組裝成mobile app foundation」，而不能自然替換成AI、cloud、security、DevOps banner。
