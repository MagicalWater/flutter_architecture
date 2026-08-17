---
document_type: design-spec
status: proposed
authoritative_for:
  - milestone-40-hero-visual-corrective-design
last_reviewed_baseline: 1.20.0
---

# Milestone 40-7R — Repository Hero Visual Corrective Design

## 1. Status

```txt
Requirement: accepted
Design: proposed
Plan: forbidden before Design user approval
Implementation: forbidden before Design and Plan acceptance
```

## 2. Product identity objective

Hero 不是「漂亮背景」，而是 repository product identity 的第一個視覺摘要。它必須讓訪客在尚未閱讀下方 technical detail 前，就感受到：

```txt
Flutter / mobile product foundation
+ layered Clean Architecture
+ modular reusable packages
+ App-owned composition
+ governed enterprise template
```

不能只靠 dark graphite、blue glow、3D blocks 等 generic developer-tool style 宣稱達成。

## 3. Source strategy

新的 generation **必須以兩張已 accepted architecture visuals 作為 source-image context**，而不是只靠文字 prompt 從零生成：

- `docs/assets/architecture/productized-topology.png`
- `docs/assets/architecture/c4-dependency-contract.png`

目的不是把兩張圖拼貼或複製，而是讓 Hero 延續其形狀語彙、blue/cyan accent、layer／module relationship 與 repository-specific architecture identity。

在生成前，Plan 必須先對兩張 source visuals 做一份 **visual-family extraction**，至少記錄：

- primary geometry language；
- module／container shape；
- connector language；
- blue／cyan accent 使用方式；
- density／negative-space pattern；
- 哪些 visual cue 屬於 repository-specific architecture family，哪些只是通用 dark-tech decoration。

Candidate review 必須依這份 extraction 判斷 family consistency；不能只因色調同為深色＋藍色就宣稱「同一 visual family」。

若 `chatgpt-web-image` source-image path allowlist 無法接受 repository files，必須停止 generation 並修正合法 routing；不得降級成 generic prompt-only candidate 後自行宣稱等價。

## 4. Composition direction

Hero 採 **wide editorial architecture illustration**，不是 dashboard、不是 phone mockup、不是 UML／C4 diagram。

核心構圖：

- 中央或偏中央有一個清楚的 **mobile app / application shell abstraction**，讓人知道這是 app foundation，而不是 cloud infra。
- application shell 內或周圍以 3～4 個可辨識層級表現 Presentation／Domain／Data／Infrastructure 的「layered system」概念，但不直接生成大量文字標籤。
- 周圍有少量 modular package blocks / reusable modules，以視覺連線回 App Composition Root。
- dependency direction 應具有秩序與單向感，不是隨機 network nodes。
- 保留足夠 negative space，避免整張變成密集 system diagram。

核心 visual metaphor 必須固定為：

```txt
modular reusable foundations
→ ordered architecture layers
→ composed mobile application shell
```

也就是「模板如何組成產品」而不是單純畫一支手機、App UI、晶片、server board或抽象network。若 candidate 只有 mobile signal、沒有 composition／layer／module relationship，仍判 product identity FAIL。

## 5. Visual language

- 深 graphite / near-black 基底可以保留，但只是 supporting surface，不是 identity 本身。
- Accent 以 Flutter-adjacent blue / cyan 為主，避免 neon cyberpunk。
- 形狀語言延續現有 architecture visuals 的 clean rectangular modules、layer hierarchy、structured connectors。
- 可以有 subtle dimensionality，但避免 generic 3D motherboard／server-chip aesthetic。
- 不使用 stock cloud、database cylinder、AI brain、random glowing nodes 作主角。
- 不使用 generic smartphone mockup／floating app screen 作為主要辨識；mobile signal必須服務於「architecture template composed into an app」的核心隱喻。
- Hero是固定PNG，必須在GitHub light與dark appearance都能獨立成立；不得靠頁面本身的near-black背景延伸畫面或隱藏邊界。畫面四周需有完整self-contained framing／edge treatment，light theme下也不能像被硬貼上一塊未完成的黑色canvas。

## 6. Typography / logo boundary

Generated Hero 預設 **不含文字**，repository identity 由 Markdown H1 與 prose 承擔。

不得生成仿冒 Flutter 官方 logo；若需要 Flutter recognition，使用 mobile-app silhouette、Flutter-adjacent angular blue geometry與既有 architecture source language形成聯想，而不是直接複製商標。

## 7. Relationship to existing visuals

三張圖 responsibility：

```txt
Hero
→ product identity / first impression / architecture metaphor

Productized topology
→ ownership / Composition Root / package / external-system overview

C4 dependency contract
→ detailed component ownership and dependency contract
```

Hero 不得含足以取代後兩張圖的完整文字 contract；後兩張圖也不得被移除、縮成連結或推到 README 深處。

## 8. README first-screen composition

Accepted candidate 未出現前，README 維持無 Hero 的安全狀態。

候選通過後才允許：

```txt
H1
→ Hero visual
→ one-paragraph positioning
→ baseline / platform / CTA
→ Architecture Overview image
→ Dependency Contract image
→ remaining text sections
```

Hero 只能作為一個低高度的橫向 first-impression band，不得因自身高度把兩張 architecture visuals推到過深位置。Target ratio為約`3:1`；critical composition集中在中央安全區，左右邊緣只能放可裁切的supporting decoration。

GitHub desktop與窄viewport縮放時都必須成立：Hero縮到約700px寬及約360px寬時，仍應辨識「app shell + ordered layers + modular composition」三個主訊號；不得依靠小字、細小connector或微型module才成立。

## 9. Candidate acceptance contract

每個 candidate 必須逐項判定：

1. **Product recognition**：不是 generic dark-tech banner。
2. **Flutter/mobile recognition**：有 app foundation / mobile product visual signal。
3. **Architecture recognition**：layer / module / composition relationship可感知。
4. **Repository-family consistency**：與兩張 source architecture visuals 同一 visual family。
5. **Non-duplication**：不變成第三張詳細架構圖。
6. **First-screen balance**：不壓過 H1／CTA，也不把兩張正式 architecture visuals推到不可見位置。
7. **Actual preview**：review artifact 必須 inline render candidate + 兩張 authority visuals。
8. **Structural family match**：與source visuals共享geometry／module／connector語彙，而不只是同色系。
9. **Downscale readability**：desktop與窄viewport縮小後，核心產品隱喻仍可辨識。
10. **Crop safety**：中央核心不能靠近左右邊界；responsive縮放／預覽不得切掉產品辨識主體。
11. **Cross-theme framing**：同一PNG置於GitHub light／dark背景都必須有完整邊界與視覺完成度，不依賴外部page color才能成立。

任何一項 critical FAIL，candidate 必須 rejected；不得用「整體很精緻」抵銷。

## 10. Candidate workflow

第一輪只生成 **一張 master candidate**。若不通過，先做 finding classification：

- identity direction wrong → discard and regenerate；
- composition direction right但局部瑕疵 → 才允許 bounded edit／regeneration。

禁止在錯誤 identity candidate 上無限調色、crop、padding、scale。

Rejected candidate若已形成正式visual-review evidence，必須從live README consumer與live asset naming撤出，但可保留在明確的`rejected`／historical evidence path供audit回看。不得讓rejected asset繼續看起來像current landing asset，也不得為了清理live consumer而銷毀已引用的review evidence。

## 11. Validation

Design approval 後的 Plan 必須包含：

- `chatgpt-web-image` fresh Executor admission / discovery；
- source-image allowlist validation；
- actual inline candidate review；
- source visual-family extraction evidence；
- desktop／narrow downscale preview evidence；
- light／dark surrounding-background preview evidence；
- README consumer only after acceptance；
- `git diff --check`；
- `dart run melos run docs_check`；
- user visual acceptance gate before closure。

## 12. Non-goals

- 不建立 brand system／logo project。
- 不重畫 existing architecture diagrams。
- 不新增 external CDN／badge dependency。
- 不因 Hero 而升版。
