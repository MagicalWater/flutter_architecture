---
document_type: planning-review
status: accepted
authoritative_for:
  - milestone-40-hero-visual-corrective-design-review
last_reviewed_baseline: 1.20.0
---

# Milestone 40-7R — Hero Visual Corrective Design Review

## Review target

`docs/superpowers/specs/2026-08-17-milestone-40-hero-visual-corrective-design.md`

Requirement：`docs/audits/milestone_40/40-7r_hero_visual_requirement_decision.md`

## Focused review

### F-40-7R-D01 — Generic dark-tech visual must fail

- Severity：P1。
- Check：Design把product recognition設為critical gate，明確禁止只靠graphite／blue glow／3D blocks通過。
- Result：PASS。

### F-40-7R-D02 — Hero 必須從 accepted architecture family 派生

- Severity：P1。
- Check：Design要求兩張 accepted visuals 作 source-image context；prompt-only generic generation不是正常fallback。
- Result：PASS。

### F-40-7R-D03 — Flutter/mobile identity 不得靠仿冒商標

- Severity：P1 legal／identity risk。
- Check：Design已明確切分責任：Markdown H1承擔`Flutter`技術身份，Hero只承擔mobile application foundation與repository-specific architecture-family signal；不得以仿冒Flutter logo或模糊的`Flutter-adjacent`造型作PASS理由。
- Result：PASS。

### F-40-7R-D04 — Hero 不得取代正式 architecture visuals

- Severity：P1 authority risk。
- Check：三張圖 responsibility分離；兩張 architecture visuals仍必須位於README前段且不可被降成link。
- Result：PASS。

### F-40-7R-D05 — 錯誤 candidate 不得靠 pixel tuning 挽救

- Severity：P1 quality-loop risk。
- Check：identity direction wrong要求discard／regenerate；只有direction正確時才允許bounded edit。
- Result：PASS。

### F-40-7R-D06 — Review evidence 必須真的看得到圖

- Severity：P1 acceptance-evidence risk。
- Check：Design要求candidate與兩張authority visuals都在review artifact inline render，明確禁止只展示Markdown source/path。
- Result：PASS。

## Fresh second-pass focused findings

### F-40-7R-D12 — Source diagrams可能污染Hero文字

- Severity：P1。
- Finding：兩張source visuals本身含大量文字；原Design只說Hero預設不含文字，但沒有禁止source-image把偽字／label fragment帶入candidate。
- Fix：Design新增zero generated text contamination gate，任何文字、字母、數字、偽字或label碎片都直接FAIL。
- Fresh re-review：PASS。

### F-40-7R-D13 — Flutter recognition責任定義自相矛盾

- Severity：P1。
- Finding：原Design一方面禁止Flutter logo，一方面允許以`Flutter-adjacent angular blue geometry`建立recognition，容易讓generic blue artwork被主觀宣稱為Flutter-specific。
- Fix：明確切分責任：Markdown H1擁有`Flutter`技術身份；Hero只需證明mobile app foundation與repository-specific architecture family，不得再以模糊的Flutter-adjacent造型作PASS理由。
- Fresh re-review：PASS。

### F-40-7R-D14 — Source context可能退化成拼貼／無字版diagram

- Severity：P1。
- Finding：要求使用兩張accepted source images仍不足以阻止模型直接重製diagram composition。
- Fix：新增`Source-derived, not source-copied` critical gate；Hero只能抽取visual family，不得拼貼、截圖式重製或變成第三張無字diagram。
- Fresh re-review：PASS。

### F-40-7R-D15 — Visual companion邊界未鎖定

- Severity：P1 governance risk。
- Finding：repository registry允許`high-end-visual-design`作restricted critique，但該Skill含大量Web／font／motion絕對規則，若直接套用會污染PNG Hero Design。
- Fix：Design明確限制它只能提供hierarchy／surface／anti-generic critique，不得套用React／Tailwind／font／icon／motion／Double-Bezel execution rules。
- Fresh re-review：PASS。

### F-40-7R-D16 — Required brainstorming沒有artifact-level evidence

- Severity：P1 governance risk。
- Finding：40-7R Requirement Decision明確標記brainstorming required，但原Design只給出單一路線，沒有記錄替代方向與disposition，無法證明composition direction經過比較而非直接拍板。
- Fix：Design新增Brainstorming / alternatives disposition，明確比較no-Hero、generic tech banner、Flutter-logo-led、full architecture diagram與source-derived composition metaphor五個方向，只有最後一項selected。
- Fresh re-review：PASS；selected direction直接對應confirmed failure與non-duplication boundary。

### F-40-7R-D07 — 「source image context」仍不足以保證同一 visual family

- Severity：P1。
- Finding：原Design只要求把兩張accepted visuals餵給generation，但沒有要求先抽出repository-specific geometry／module／connector語彙，也沒有規定review如何判斷family match。模型仍可能只學到「dark + blue」表面風格並產生另一張generic technology visual。
- Fix：Design新增visual-family extraction evidence，並把structural family match加入critical candidate gate。
- Result：FIXED。

### F-40-7R-D08 — Mobile signal 仍可能退化成generic smartphone artwork

- Severity：P1。
- Finding：原Design要求mobile app/application shell，但未固定「template如何組成product」的核心隱喻；candidate可能只畫一支精緻手機＋周圍modules，仍缺乏Flutter architecture template identity。
- Fix：核心metaphor固定為`modular reusable foundations → ordered architecture layers → composed mobile application shell`，generic smartphone mockup明確不得作主辨識。
- Result：FIXED。

### F-40-7R-D09 — 缺少GitHub縮放／窄viewport可讀性契約

- Severity：P1。
- Finding：Hero在README會依viewport縮放；原Design沒有要求700px／360px下仍保留產品辨識，也沒有crop-safe central composition。高解析candidate可能desktop看似精緻，實際GitHub縮圖後只剩一團細節。
- Fix：新增3:1低高度band、central safe area、desktop／narrow downscale readability與crop safety gates。
- Result：FIXED。

### F-40-7R-D10 — 固定PNG不能依賴GitHub dark theme才成立

- Severity：P1。
- Finding：原Design採near-black／graphite方向，但沒有要求light theme contextual acceptance；如果Hero靠頁面黑底融合，GitHub light appearance會暴露突兀canvas邊界，不能稱為repository landing visual完成。
- Fix：新增self-contained edge treatment與light／dark surrounding-background preview evidence，列為critical candidate gate。
- Result：FIXED。

### F-40-7R-D11 — Rejected candidate 不能污染live asset，也不能讓audit evidence斷鏈

- Severity：P1 evidence／authority risk。
- Finding：原40-7 candidate已被使用者否決。若仍留在live `docs/assets/readme/`名稱，容易被誤認為current Hero；若直接刪除，又會讓rejected review失去actual visual evidence。
- Fix：Design明確要求rejected visual從live consumer撤除，但已形成formal review evidence時移至rejected／historical evidence path，保留可視追溯。
- Result：FIXED。

## Whole-Design review

### Fresh focused re-review

逐項重新對修正版Design檢查D01～D16：

- D01 generic dark-tech rejection：PASS。
- D02 source-family derivation：PASS，且現在有visual-family extraction而非只餵source image。
- D03 Flutter/mobile recognition without trademark imitation：PASS。
- D04 Hero／topology／C4 responsibility separation：PASS。
- D05 wrong-identity candidate discard semantics：PASS。
- D06 actual inline review evidence：PASS as Design contract；implementation尚未開始。
- D07 structural family match：PASS。
- D08 template→product composition metaphor：PASS。
- D09 downscale／crop safety：PASS。
- D10 GitHub light／dark framing：PASS。
- D11 rejected evidence preservation without live authority pollution：PASS。
- D12 zero generated text contamination：PASS；source diagram文字不得污染Hero。
- D13 Flutter technical identity／Hero visual identity responsibility split：PASS。
- D14 source-derived but not source-copied：PASS。
- D15 restricted visual companion boundary：PASS；Web-specific execution rules不得污染PNG Hero。
- D16 brainstorming alternatives／selected direction evidence：PASS。

Fresh focused re-review沒有新增P0／P1 finding。

### Whole-Design holistic review

Design在本輪focused findings修正後，完整覆蓋confirmed failure：錯誤Level 2 shortcut、缺少brainstorming evidence、generic product identity、source-family disconnect、source diagram文字污染、source直接重製／拼貼、generic smartphone fallback、Flutter identity責任模糊、GitHub downscale unreadability、light/dark framing、false visual preview、restricted visual companion污染、self-PASS、rejected-evidence斷鏈與錯誤candidate tuning風險。

沒有改變documentation authority、Template → Product lifecycle、Flutter production architecture或兩張existing architecture visual authority，因此Level 2仍足夠，不需升Level 3／4。

Cross-artifact一致性：

- Requirement Decision要求Flutter/mobile foundation、layer/module/composition、same visual family、actual preview；Design逐項有critical gate，並以Brainstorming alternatives明確證明selected direction不是implementation階段臨時拍板。
- Milestone 40 accepted landing architecture仍保留H1、baseline、CTA與兩張正式architecture visuals；Hero只在candidate accepted後加入。
- 原40-7 rejected candidate已從root README consumer撤除，並移至`docs/assets/readme/rejected/`作historical visual evidence，不再具有current landing authority。
- ADR-011 Single Authority不需修改；Hero是presentation asset，不是architecture／current-state authority。

### Documentation authority check

```txt
README current Hero consumer: absent until accepted candidate
Productized topology consumer: retained
C4 dependency contract consumer: retained
Rejected candidate: historical evidence only
New stable ADR: not required
Template → Product machine contract: unchanged
```

### Test Authoring Decision

Design Task本身不新增production runtime behavior，也沒有適合的unit/widget test owner；本Task採`Should-not-add`。Future Plan仍必須把visual-family extraction、actual inline preview、downscale、light/dark framing與user visual acceptance列為Required validation evidence。

### Validation evidence

```txt
git diff --check = PASS
dart run melos run docs_check = PASS
root README rejected Hero consumer = absent
root README productized-topology.png = present
root README c4-dependency-contract.png = present
```

## Current findings

```txt
Open P0: 0
Open P1 without disposition: 0
Focused review: PASS after D07-D16 fixes
Fresh focused re-review: PASS
Whole-Design holistic review: PASS
Documentation authority check: PASS
Design status: accepted
User approval: accepted on 2026-08-17
Plan: may be created; implementation remains forbidden until Plan acceptance
Implementation: forbidden
```
