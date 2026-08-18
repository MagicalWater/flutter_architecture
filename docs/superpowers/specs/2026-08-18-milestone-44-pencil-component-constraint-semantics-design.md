---
document_type: design-spec
status: proposed
authoritative_for:
  - milestone-44-design
last_reviewed_baseline: 1.22.0
---

# Milestone 44 — Pencil Component Constraint Semantics Corrective — Design

## Status

**Proposed — 等待使用者明確核准。**

## Problem statement

Milestone 41解決了whole-screen page coordinate ownership，Milestone 43解決了Presentation responsibility/state ownership；但 current Pencil reference仍證明兩個contract之間有漏洞：只要 major sections由Column排列，就能在每個bounded region內繼續以大量canonical `left/top`排普通content。這種做法視覺上可以exact，架構上卻仍把Pencil座標當主要 runtime layout semantics。

本Milestone只把這個已有production evidence的layout correctness defect作為主責。Fresh audit另外發現multi-screen `Flow/Coordinator`完整性議題與same-semantic Pencil colors edge case；前者記錄為follow-up candidate，後者只做bounded governance clarification，不擴張為Theme/Design System production refactor。

## Design principles

### 1. Coordinate usage依「角色」治理，不依出現次數或全面禁用

合法：decorative glow / ring / artwork / badge layering；chart/map/game/diagram等accepted spatial surface；bounded icon artwork內部微調；真正需要z-order的local overlay。

不合法作為主要layout semantics：普通label/value row、card內標題/副標/尾端值、button icon + label、progress steps本身的橫向分布、major content card內普通資訊欄位，以及能自然以Padding/Align/Row/Column/Flex/Spacer/Wrap/constraints表達的content。

> **Normal content relationships must remain relationship-owned even inside a bounded component. Spatial coordinates are an implementation detail only where the visual semantics are genuinely spatial/overlay.**

### 2. Bounded component不得成為 fixed-canvas laundering boundary

Screen root使用Column不代表下層可以任意重建fixed canvas。Machine contract新增component-level negative controls：若一般 component API暴露`left/top`作產品內容排列參數、或 generic `_positionedText/_localText` helper大量承擔普通content placement，視為architecture failure target。

不以file line count、Widget count或Positioned count作唯一判定。

### 3. Reference implementation採 relationship-first decomposition

`write_precheck`依真正change reason拆成 bounded owners；screen root只負責flow composition。Header、Progress、Hero、Summary、Results、Records、Guidance、Actions、Footer等是否各自成檔，依owner/change reason決定，不把清單變mandatory taxonomy。

每個owner優先使用constraints/relationship layout；保留的Stack/Positioned必須能說明其spatial rationale。

`WritePrecheckProjection`不得再成為「所有child x/y都乘scale」的通用排版引擎。Measurement projection仍可服務accepted design width下的尺寸、gap、radius、stroke、icon/artwork sizing；normal content placement改由Flutter relationship layout。

### 4. Flow / Coordinator finding disposition

本Milestone不新增`Flow/Coordinator` stable role、framework或folder contract。原因是目前只有governance completeness finding，沒有需要此owner才能修正的current production failure。Requirement evidence保留此finding，後續只有在真實multi-screen/multi-step presentation workflow出現獨立transition semantics時，才以fresh Requirement Decision評估是否補ADR-032。

這個disposition同時禁止兩個極端：不得把Flow當M44順手補齊的預先抽象，也不得把未來真正multi-screen workflow永久塞回Page/Shell；是否升級由未來evidence決定。

### 5. Same-semantic Pencil color bounded clarification

同一accepted design中出現近似但不完全相同raw colors時，依下列順序裁決：

```txt
Step 1 — Representation noise?
alpha blending / anti-alias / raster sampling / gradient sample / export difference
→ 不建立新token；回source/representation authority確認

Step 2 — Different semantic role?
background vs elevated-surface / primary vs warning / enabled vs disabled
→ 映射不同semantic tokens

Step 3 — Same semantic role + intentional contextual variant?
→ 若有stable cross-consumer semantics，建立semantic/component variant
→ 若只屬單一component且有明確visual rationale，留component owner

Step 4 — Pure decoration/artwork exact value?
→ smallest correct component owner
```

禁止因hex不同少量RGB就自動建立`HomeColors/SettingsColors/...`；也禁止因「Theme要一致」就無視accepted source中的intentional semantic/context variant。此Milestone最多更新ADR-018/ADR-028 wording與pressure scenario；沒有production misuse evidence時不修改Theme/Design System production source。

### 6. Machine + behavioral governance一起補

新增/擴充 direct architecture tests與policy tests，至少覆蓋：screen Column + local component fixed-canvas laundering FAIL；Hero local badge/glow overlay PASS；DataRow以Row/Align/Expanded呈現 PASS；component public API以`left/top`排列normal content FAIL；same semantic CTA只因small RGB drift拆feature colors FAIL；different semantic roles即使hex接近仍可不同token PASS；intentional single-component decorative exact color PASS。Flow不建立新的machine/production contract，只保留Requirement disposition evidence。

Fresh behavioral pressure延續既有`implementing-pencil-flutter-design` consumer Skill，不新增 `flow-governance` 或 `color-governance` Skill。

## Architecture ownership changes

- **ADR-032**：只在必要時加入component-local fixed-canvas laundering prohibition／normal content relationship ownership review question；不新增Flow/Coordinator stable role。
- **ADR-018**：最多加入semantic-color bounded reconciliation clarification，不觸發Theme/Design System production refactor。
- **ADR-028**：把bounded overlay permission收斂為genuinely spatial/overlay semantics，禁止普通content拆成bounded canvas後繼續canonical x/y reconstruction。
- **Pencil consumer Skill / mapping**：對risk-selected components記relationship-layout / bounded-spatial-overlay rationale；generic `left/top` APIs與positioned text helpers成為review pressure target。

## Reference migration strategy

1. 先建立direct RED，證明current `write_precheck`會被新contract抓到。
2. 將screen composition與major section owners拆開。
3. 逐 section 把normal content從Positioned改為Padding/Align/Row/Column/Flex/Spacer等relationship layout。
4. 保留並文件化真正decorative/spatial overlay。
5. 不改`.pen`、accepted source hash、golden threshold/crop/ignore regions。
6. 每個區塊先做geometry/widget tests，再跑visual/runtime acceptance，避免「架構修正」以視覺退化為代價。

## Success criteria

- current reference不再以generic coordinate helpers排普通文字、rows、buttons/cards。
- major section與section-internal normal content都由relationships擁有。
- remaining `Positioned`都有bounded spatial rationale，且machine/behavioral tests能區分合法與違法。
- Flow/Coordinator finding有明確defer/follow-up disposition，不被M44錯誤升級成預先抽象。
- same-semantic color drift不會生成feature-local token proliferation，且此clarification不無證據擴張成Theme/Design System refactor。
- Pencil accepted visual authority維持；任何visual regression必須修implementation，不得放寬threshold掩蓋。
- full two-layer review P0=0、undisposed P1=0。

## Non-goals

- 不禁止Flutter `Stack` / `Positioned`。
- 不強迫所有component改成Material標準外觀。
- 不要求one-widget-one-file。
- 不要求每個feature有Flow/Cubit/Bloc。
- 不在本Milestone導入Flow/Coordinator stable role或generic orchestration framework。
- 不重構Theme/Design System production implementation，除非implementation前新增fresh production misuse evidence並重新做Requirement Decision。
- 不重設計Pencil source。
- 不建立新的Design System mega token layer。

## Approval gate

本Design完成repository review前保持`proposed`；取得使用者明確核准後才可標記`accepted`並建立Implementation Plan。Plan未核准前不得修改production implementation。

