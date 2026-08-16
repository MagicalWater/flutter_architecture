---
document_type: phase-review
status: active
authoritative_for:
  - milestone-40-repository-hero-visual-corrective-review
last_reviewed_baseline: 1.20.0
---

# Milestone 40-7 — Repository Hero Visual & Landing First-Screen Acceptance

## Fresh corrective admission

Milestone 40 local closure後，使用者在publication前指出root `README.md`雖已完成product landing restructure，但首屏仍只有H1與文字，缺少與後續architecture visuals同等完成度的品牌Hero視覺。

本corrective重新進入Requirement Decision並判定：

```txt
Decision: Accept
Classification: Level 2 — bounded documentation / presentation corrective
Design: reuse accepted Milestone 40 information architecture
New Design Spec: not required
New Implementation Plan: not required
Architecture Decision: not required
Release bump: not required
```

理由：本變更只新增一個decorative／brand-oriented README visual asset與一行Markdown consumer，不改變documentation authority、technical architecture、Template → Product bootstrap machine contract、checker contract或Flutter production behavior。

## Implementation

新增：

```txt
docs/assets/readme/flutter-enterprise-architecture-hero.png
```

生成route：repository-approved `chatgpt-web-image` integration，透過Executor fresh discovery取得：

```txt
chatgpt-web-image.org.default.generate_chatgpt_web_image
```

Generation result：

```txt
PNG
2172 × 724
3:1
1,410,485 bytes
```

root `README.md`在H1後直接inline：

```md
![Flutter Enterprise Architecture Template hero](docs/assets/readme/flutter-enterprise-architecture-hero.png)
```

### Review artifact actual preview

本review本身必須直接render被驗收的視覺，不能只展示Markdown source。由於本檔位於`docs/audits/milestone_40/`，以下使用相對於本review檔案的實際asset path。

#### Hero visual

![Flutter Enterprise Architecture Template hero preview](../../assets/readme/flutter-enterprise-architecture-hero.png)

#### Productized topology

![Flutter Enterprise Architecture Template productized topology preview](../../assets/architecture/productized-topology.png)

#### C4 dependency contract

![Flutter Enterprise Architecture Template C4 dependency contract preview](../../assets/architecture/c4-dependency-contract.png)

## Focused visual review

### F-40-7-01 — Hero不能成為第三張架構圖

- Severity：P1 if violated。
- Review：畫面使用抽象layer／module／path language，而不是具名component、流程框、UML或C4式contract。
- Result：PASS。

### F-40-7-02 — 不得依賴generated文字承擔repository identity

- Severity：P1 accessibility／identity risk。
- Review：Hero本身沒有文字、數字、logo或字母；repository title仍由Markdown H1承擔。
- Result：PASS。

### F-40-7-03 — 首屏視覺需符合enterprise developer-tool定位

- Severity：P1 visual-quality risk。
- Review：深色graphite主體、克制的blue／teal accent、layered composition與精緻低亮度surface符合enterprise／architecture tooling語言；沒有neon cyberpunk、dashboard UI或phone mockup。
- Result：PASS。

### F-40-7-04 — Hero不得搶走後續architecture authority

- Severity：P1 authority／communication risk。
- Review：Hero只提供品牌第一印象；`productized-topology.png`與`c4-dependency-contract.png`仍位於Architecture sections並承擔architecture summary／contract視覺責任。
- Result：PASS。

### F-40-7-05 — GitHub README consumer path需穩定

- Severity：P1 rendering risk。
- Review：asset為tracked repository-relative PNG，README使用相對路徑；不依賴external CDN或badge service。
- Result：PASS。

## First-screen holistic review

新的README首屏閱讀順序為：

```txt
H1 repository identity
→ branded Hero visual
→ one-paragraph positioning
→ Template Baseline / platform summary
→ Use this template CTA
→ Why this template
```

此順序補足原Milestone 40 landing page在「產品級第一視覺」上的缺口，同時保持H1文字、baseline marker與newcomer CTA可搜尋、可複製、可由screen reader理解。

## Validation

Required closure checks：

```txt
git diff --check
dart run melos run docs_check
README relative asset path exists
```

## Review conclusion

```txt
Focused review: PASS after user-identified layout corrective
Review artifact actual previews: FIXED after user rejection
First-screen holistic review: pending user visual acceptance
Open P0: 0
Open P1 without disposition: 0
Corrective status: active / user visual acceptance pending
Template Baseline: remains 1.20.0
```

## User visual rejection and corrective

2026-08-17使用者明確否決先前first-screen判定：雖然兩張accepted architecture images仍存在於README source與tracked assets，`Why this template`六條文字內容位於Hero與architecture visuals之間，實際閱讀節奏使正式架構圖被文字區塊壓到後方，形成近似「Hero之後又回到全文字」的第一視覺。

先前`First-screen holistic review: PASS`因此撤銷，不保留為有效acceptance evidence。

另外，使用者後續直接檢視本`40-7` review時再次發現：review artifact只把README image syntax放在fenced code block內，**本review頁面本身完全沒有render任何被驗收圖片**。因此先前宣稱已完成「視覺驗收」的evidence presentation不成立；只有asset存在與README source path正確，不能等同review artifact已實際提供visual preview。

本finding以actual inline image previews修正：Hero、productized topology與C4 dependency contract三張圖現在都在本review內直接render，reviewer不需要跳到filesystem或自行解讀Markdown syntax才看得到驗收目標。

Corrective disposition：

```txt
H1
→ Hero visual
→ positioning / baseline / platform / Use this template CTA
→ Architecture Overview image
→ Dependency Contract image
→ Why this template
→ capability / adoption / documentation content
```

Fresh review確認：

- Hero只新增brand／first-impression responsibility，不取代兩張architecture visual。
- `productized-topology.png`與`c4-dependency-contract.png`現在直接跟在Hero metadata後方，不再被長文字block隔開。
- 兩張圖的source path、tracked bytes與authority均未改變。
- README由「Hero → 長文字 → architecture」修正為「Hero → architecture visuals → explanatory text」。
