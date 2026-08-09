---
document_type: design-spec
status: proposed
authoritative_for:
  - milestone-34-pencil-asset-typography-mapping-design
last_reviewed_baseline: 1.15.1
---

# Milestone 34 — Pencil Asset / Vector / Typography Mapping & Provenance Design

## Requirement Decision

- Request（需求）：補強既有Pencil-to-Flutter路線，在Pencil結構提取完成後、Flutter architecture mapping開始前，正式判定raster asset、vector、icon、typography、dynamic drawing與普通Flutter primitive應採用的representation，並保存必要provenance。
- Problem（問題）：現有`implementing-pencil-flutter-design`已嚴格治理visual authority、single renderer、responsive projection、TDD與visual acceptance，但「Pencil視覺元素要以哪種Flutter技術形式重現」仍主要依實作者判斷。複雜固定裝飾可能被誤畫成大量Container／gradient／shadow／magic geometry；普通geometry也可能被過度raster化；字型不存在、icon只是近似、asset經resize或複製後來源不明時，現有contract沒有足夠早的fail-closed gate。
- Current behavior（目前行為）：Pencil extraction後直接進入`flutter-mapping.md`；該reference有Design System／feature-local／localization／approved icon package ownership順序，但沒有完整的asset／vector／typography classification、font availability、representation decision與asset provenance contract。
- Expected behavior（預期行為）：每個非單純layout元素在Flutter mapping前先完成Visual Representation Classification；固定複雜視覺、可無損向量、動態繪製、標準icon、typography與普通geometry各有明確決策規則。任何font、icon、asset或source provenance unresolved都不得以「看起來差不多」直接進production implementation。
- Value（價值）：把「素材／字型／圖示選錯」與真正的layout fidelity問題分離，減少candidate-driven magic numbers、近似icon、silent font fallback、模糊raster與重複asset，提升Pencil-to-Flutter fidelity、維護性與可追溯性。
- Classification（分類）：Level 3 — Cross-cutting workflow contract enhancement。它修改既有repository-local domain Skill的workflow ordering與admission semantics，但不建立新architecture owner、不修改Flutter runtime architecture，也不新增第三方Skill。
- Decision（決策）：Accept。
- Scope（範圍）：`implementing-pencil-flutter-design`主流程、新增`asset-and-typography-mapping.md` reference、`flutter-mapping.md`交界、pressure scenarios、Skill registry／human Guide必要同步、focused behavioral／documentation validation。
- Non-goals（非目標）：建立新的`pencil-to-flutter-code` Skill、實作自動`.pen` parser、重新設計accepted `.pen`、新增通用asset pipeline、重做Design System、修改任何產品UI、為所有asset建立新的repository manifest framework、處理interaction/state mapping。
- Behavioral requirements required（是否需要行為需求）：是。
- Design Spec required（是否需要 Design Spec）：是。
- Implementation Plan required（是否需要 Implementation Plan）：是。
- ADR required（是否需要 ADR）：否。ADR-028的visual authority與single-renderer stable boundary不改變；本工作只補強其既有domain orchestration的representation decision gate。若implementation review發現必須改變stable authority owner，再升級ADR gate。
- Task governance mode（Task 治理模式）：Full two-layer governance。
- Worktree／branch：managed worktree `flutter_architecture-0fc59cf8`；branch `milestone-34-pencil-asset-typography-mapping`。
- Regression level（Regression 等級）：Skill／docs focused RED-GREEN pressure validation、repository docs checks、skill policy tests；不修改Flutter production source，因此不因本Task單獨要求app runtime regression。
- Release required（是否需要發布）：是。此變更修改模板repository的reusable development workflow，完成後預期patch baseline `1.15.2`；最終release identity由Holistic Final Review決定。
- Post-release validation（發布後驗證）：是；若發布，需在published main重驗Skill routing、pressure cases、docs checks與registry一致性。
- Required Superpowers skills（必要 Superpowers Skills）：`brainstorming`、`writing-plans`、`using-git-worktrees`、`writing-skills`、`test-driven-development`、review／verification／finishing Skills。
- Required artifacts（必要 artifacts）：本Design、Design review、Implementation Plan與Plan review、RED／GREEN pressure evidence、Skill／reference changes、focused implementation review、Holistic Final Review、release／post-release evidence（若release）。

## Approval Gate

使用者已於2026-08-09核准「不要新增獨立Skill，而是在既有`implementing-pencil-flutter-design`內補一個Asset / Vector / Typography Mapping & Provenance必經層」的方向。本書面Design仍依repository治理維持`proposed`，直到完成本Design Task的focused／whole-Task review、validation後，再由使用者對這份書面artifact明確核准，才可轉為`accepted`並建立Implementation Plan。

## Design Alternatives

### A — Existing domain Skill + dedicated reference（採用）

在`implementing-pencil-flutter-design`內新增一個必經classification gate，詳細規則放在：

```txt
.agents/skills/implementing-pencil-flutter-design/references/
  asset-and-typography-mapping.md
```

主Skill只保留順序與fail-closed要求，重規則放reference。這維持domain Skill薄型、避免Skill數量膨脹，也讓representation decision與既有visual authority／Flutter mapping直接相鄰。

### B — New standalone asset-mapping Skill（拒絕）

優點是trigger可獨立搜尋；缺點是沒有獨立lifecycle，所有有效使用都依賴accepted `.pen`與同一Pencil-to-Flutter route，會造成重複trigger、authority overlap與更多Skill collision面。Confirmed gap不足以支持新Skill。

### C — Human Guide only（拒絕）

只更新`docs/guides/pencil_to_flutter_workflow.md`容易讓agent在實際execution跳過classification，且會把可執行procedure放到human Guide形成平行authority。Guide只能摘要，不擁有decision matrix。

## Required Workflow Ordering

Current route：

```txt
Pencil MCP extraction
→ Flutter authority mapping
→ TDD / visual acceptance
```

Target route：

```txt
Pencil MCP extraction
→ visual asset / vector / typography inventory
→ representation classification + provenance resolution
→ Flutter authority mapping
→ TDD / visual acceptance
```

Classification不是implementation後補文件；沒有通過不得開始Flutter production UI source。

## Visual Representation Classes

每個需要視覺實作決策的Pencil元素至少歸入一個primary class：

| Class | Default Flutter representation | Typical examples |
|---|---|---|
| Layout primitive | Flutter widget／decoration | solid fill、radius、divider、普通border、可表達的shadow |
| Typography | verified font + TextStyle authority | body、title、label、numeric readout |
| Approved package icon | repository-approved icon package exact match | standard navigation／status icon |
| Vector asset | approved SVG／vector asset | custom static icon、logo-like geometric mark |
| Raster asset | repository-local raster asset | texture、illustration、complex fixed ornament |
| Dynamic drawing | CustomPainter／equivalent dynamic primitive | progress geometry、chart、waveform、value-driven path |

Classification必須以「設計內容是否固定、是否需要無損縮放、是否由runtime state驅動、是否存在exact approved representation」判斷，不以「哪個做法最快通過screenshot」判斷。

## Decision Rules

### 1. Primitive vs asset

- 普通layout geometry使用Flutter primitive，不把card、divider、普通button surface整張切成raster。
- 複雜固定紋理、插畫、品牌裝飾若用Flutter primitives只能靠大量近似gradient／shadow／magic path模仿，優先保留為approved asset。
- 不得因為「native code比較高級」而重畫固定美術，也不得因為「圖片比較準」把整個可互動UI raster化。

### 2. Vector vs raster

- 需要多尺寸清晰縮放且source本質是static geometric shape時，優先verified vector。
- source只有raster authority時，不得自行trace成vector後宣稱等價；轉換需要accepted disposition與provenance。
- raster resize／crop／compression若改變source bytes，必須記錄derived transformation與output hash。

### 3. Dynamic drawing

- 只有當visual geometry確實由runtime value／state參數化時，才以`CustomPainter`或同等dynamic drawing表示。
- 固定裝飾不得只因為「可以畫」就轉成大量CustomPainter path。
- Painter geometry仍必須來自accepted design／mapping contract，不得由candidate pixel chasing反推。

### 4. Typography

在production implementation前必須確認：

- Pencil要求的font family是否在repository或accepted platform font contract中存在。
- 使用到的weight／style是否真的有對應font face或明確允許synthetic behavior。
- font size、line height、letter spacing與weight mapping是否可由Flutter表示。
- 若指定font不存在，必須標記`Typography authority unresolved`並回到accepted Design disposition；不得silent fallback後仍宣稱fidelity PASS。
- 文字本質若是logo／decorative lettering asset，不得假裝成普通Text以近似font替代。

### 5. Icons

- repository-approved icon package只有在exact-enough visual identity符合accepted design時可用。
- 「語意相同」不等於「視覺相同」；stroke、viewBox、angle、bounding box明顯不同時，不得以近似Material icon取代custom authority。
- package沒有exact match時，優先使用accepted vector／asset；新增custom drawing需有明確理由。

## Provenance Contract

對repository-local raster／vector／font asset，mapping evidence至少能追溯：

```txt
accepted Pencil node / visual source
→ source identity or export identity
→ allowed transformation, if any
→ repository destination
→ content hash
→ Flutter owner / consumer
```

必要欄位依asset類型縮減，但不得只留下`warning_final_2.png`之類無來源名稱。相同內容若已有repository authority，優先重用；不得無理由新增duplicate bytes。

本Milestone不建立新的全域asset manifest framework。Provenance先由Pencil-to-Flutter Task mapping evidence與既有visual manifest／Git hash鏈保存；只有未來多個consumer證明需要機械化registry時才另開需求。

## Mapping Output Contract

每個Pencil-to-Flutter implementation Task在Flutter mapping前，review evidence應能回答：

1. 哪些元素是ordinary Flutter primitives？
2. 哪些是typography，font／weight來源是否resolved？
3. 哪些icon使用approved package exact match？
4. 哪些使用vector／raster asset，來源與hash是什麼？
5. 哪些必須dynamic drawing，為何不是static asset？
6. 是否存在unresolved／approximate representation？

第6項只要存在未取得accepted disposition的P1 representation gap，production UI implementation保持blocked。

## Pressure Scenarios Required by the Plan

Implementation Plan至少建立以下RED→GREEN cases：

- **PTF-13 Complex ornament shortcut**：複雜固定Pencil ornament被agent用大量Container／gradient／shadow近似。GREEN必須先分類為fixed visual asset候選，不得直接pixel-chase。
- **PTF-14 Silent font fallback**：Pencil指定font不存在，agent想直接用Roboto／system font。GREEN必須標記Typography unresolved並停止production mapping。
- **PTF-15 Approximate icon substitution**：custom icon與`Icons.arrow_forward_ios`語意相同但視覺不同。GREEN不得以語意相同當作visual equivalence。
- **PTF-16 Untracked derived raster**：agent把Pencil export resize／crop後直接丟入assets。GREEN必須要求derived transformation與hash provenance。
- **PTF-17 Raster-everything shortcut**：為了pixel fidelity把普通card、text、button surface整片raster化。GREEN必須保留真Flutter primitive／text／interactive ownership。
- **PTF-18 Static CustomPainter overbuild**：固定複雜裝飾用大量hard-coded Painter path重畫。GREEN必須證明dynamic requirement，否則回到vector／raster authority classification。

## Documentation and Authority Ownership

- `implementing-pencil-flutter-design/SKILL.md`：只擁有必經順序、trigger、stop semantics。
- `asset-and-typography-mapping.md`：擁有classification、representation與provenance decision rules。
- `flutter-mapping.md`：繼續擁有已resolved representation如何落到Design System／feature-local Flutter ownership。
- `visual-validation.md`：繼續擁有candidate fidelity acceptance；不得反向用candidate結果改寫representation decision。
- `docs/guides/pencil_to_flutter_workflow.md`：只提供人類可理解摘要與route，不複製完整decision matrix。
- `docs/governance/development_workflow.md`：Skill registry同步responsibility與revalidation trigger，不複製reference內容。

## Failure and Stop Rules

下列任一情況必須在production UI implementation前fail closed：

- Required font family／weight不存在且沒有accepted fallback。
- Custom icon只能找到近似package icon，沒有accepted equivalence decision。
- Raster／vector source來源不明或derived bytes無法追溯。
- Static vs dynamic representation無法判定且會影響architecture／fidelity。
- Proposal需要改accepted `.pen`來迎合Flutter implementation。
- Agent試圖以candidate screenshot反推新的asset／Painter geometry。

一般檔名整理、hash補登、duplicate cleanup或mapping文件缺漏不是使用者decision blocker；Task內直接修正並fresh re-review。

## Acceptance Criteria

Design implementation完成後必須證明：

1. `implementing-pencil-flutter-design`在Flutter mapping前明確要求representation classification。
2. 新reference可獨立回答primitive／typography／icon／vector／raster／dynamic drawing的選擇規則。
3. font不存在與近似icon不能silent pass。
4. derived raster／vector至少具備來源、transformation與hash provenance要求。
5. 規則不鼓勵全raster UI、不鼓勵static CustomPainter overbuild，也不建立第二個renderer。
6. PTF-13～PTF-18具備observed RED與fresh GREEN evidence。
7. Skill registry、human Guide與docs routing沒有形成平行authority或內容重複。
8. Repository docs／Skill policy validations全數通過，Open P0 = 0，Open P1 without disposition = 0。

