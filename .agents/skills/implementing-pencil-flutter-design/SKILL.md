---
name: implementing-pencil-flutter-design
description: Use when已接受的Flutter工作要以repository-local `.pen`作visual authority，並需透過Pencil MCP提取設計、映射既有架構及執行視覺驗收時使用。
---

# 實作 Pencil Flutter 設計

## 核心原則

本Skill是`governing-template-development`核准後的薄型domain orchestration。它不分類需求、不接受Design／Plan、不直接解析`.pen`，也不擁有release或closure。

## 必要順序

```txt
delegate governing-template-development
→ verify accepted Design and Plan
→ verify managed worktree
→ verify visual authority manifest and hashes
→ verify loaded Skill provenance and collision-free paths
→ perform Pencil MCP admission
→ extract structure and variables
→ classify visual representation and resolve provenance
→ map resolved representation to Flutter authority
→ route TDD and visual acceptance
→ invalidate wrong representation and return to mapping when review finds source/identity drift
→ stop on authority conflict or drift
```

每一步都是gate；前一步未通過，不得把後一步當成補救手段。

## 啟動條件

只有同時滿足下列條件才使用：

- 中央Requirement Decision已接受repository-local Pencil-to-Flutter工作。
- Design與Implementation Plan均為`accepted`。
- 工作位於approved managed worktree。
- `docs/visual_authority/<initiative>/manifest.md`與primary `.pen`存在。

`<initiative>`是visual authority scope，不等於Flutter feature boundary。對模板中的單頁proof／compatibility initiative，可以使用獨立`.pen`；模板被採用為實際產品後，預設應以product-level canonical master `.pen`涵蓋整個App畫面與流程，各feature只引用其中對應screen／frame／flow。只有經中央Requirement Decision確認檔案規模、效能、設計ownership或其他明確理由時，才拆分多份product `.pen`。Feature First只治理Flutter code ownership，不治理Pencil document切分。

不適用於Figma-only、image-only concept、普通Flutter feature、已寫好的UI bugfix、external-only `.pen`或Plan仍為`proposed`的工作。

## 執行入口

1. 依[Visual authority contract](references/visual-authority-contract.md)驗證source ranking與hash。
2. 依[Pencil admission](references/pencil-admission.md)操作Pencil；MCP不可用時保持blocked。
3. 依[Asset / Vector / Typography mapping](references/asset-and-typography-mapping.md)完成representation classification與provenance resolution；任何required font／icon／asset／static-vs-dynamic representation unresolved時保持blocked。
4. 只把已resolved representation交給[Flutter mapping](references/flutter-mapping.md)，建立最小且真實的presentation boundary。
5. 先建立並執行failing widget／route／localization tests，確認RED後才可寫Flutter production source。
6. 依[Visual validation](references/visual-validation.md)執行TDD、golden、runtime與semantic review。
7. 若review判定wrong source／asset／icon／representation，立即把該mapping視為invalid；依representation/provenance gate重新解決，禁止在錯誤candidate上繼續padding／scale／crop／offset／opacity tuning。
8. 使用[Pressure scenarios](references/pressure-scenarios.md)檢查shortcut rationalization。

## Taste Skill邊界

- Accepted `.pen`存在時，`imagegen-frontend-mobile`不觸發。
- `brandkit`不重設既有brand／layout。
- `high-end-visual-design`只作受限制的hierarchy、spacing、surface與anti-generic critique；其Web／React／Tailwind、font、icon或motion絕對規則不得覆蓋Flutter與repository authority。

## 明確禁止

- 把口頭「整段核准」推定為書面Plan approval。
- 從external path直接implementation。
- 用Python、JSON、text或任何native parser讀取／修改`.pen`。
- Pencil MCP失敗時以image、OCR、猜測或parser fallback繼續。
- 自由重設計accepted `.pen`。
- 為presentation-only畫面虛構Domain、Data、Repository、Use Case、Bloc或DI。
- 尚未觀察到正確RED就開始Flutter production source。
- 看過candidate後擴大threshold、resize thumbnail或加入任意ignore region。
- 在representation classification前直接選font fallback、approximate icon、raster／vector或static CustomPainter shortcut。
- Review已判定wrong source／asset／icon／representation後，仍以padding、scale、crop、offset、opacity或threshold tuning嘗試挽救同一invalid mapping。
- 在Design、`.pen`或repository architecture衝突時自行選邊。

## 停止條件

遇到authority conflict、source/hash drift、Skill collision、錯誤document、Pencil MCP blocker、unsupported construct無accepted disposition、representation／provenance unresolved或需要推翻Design／Plan時，保持Task open／blocked並依中央治理停止。一般implementation或test failure則修正、fresh re-review並繼續。

Wrong representation屬mapping recovery，不是一般pixel-tuning failure：先撤銷受影響mapping／visual PASS，回到classification／provenance取得replacement representation，fresh affected validation後才重進visual acceptance。若真正需要改accepted `.pen`或Design，回中央Requirement／Design gate。
