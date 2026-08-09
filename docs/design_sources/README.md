---
document_type: knowledge
status: active
authoritative_for:
  - repository-local-design-source-routing
last_reviewed_baseline: 1.16.0
---

# Repository-local Design Sources

本目錄保存已進入repository authority boundary的原始設計來源與直接衍生檔案。它回答「實作必須讀取哪一份source」，不保存Task approval、architecture decision或runtime review結論。Source scope可以是isolated initiative，也可以是整個adopted product。

## Authority Rules

- Active source必須位於repository-governed design source scope，不能依賴外部absolute path。
- `.pen`只可透過approved Pencil MCP讀取或修改，不得以native parser、text editor或direct file mutation作fallback。
- Binary／design files以raw SHA-256鎖定；copy後必須獨立重算destination hash。
- Derived preview、original reference與historical benchmark不得冒充primary `.pen` authority。
- Source ranking、canonical viewport與supersession由對應visual authority manifest擁有；template isolated initiative通常位於`docs/visual_authority/<initiative>/manifest.md`，adopted product預設位於`docs/visual_authority/app/manifest.md`。

## Document Boundary Policy

Pencil document boundary不等於Flutter feature boundary。

- Template isolated proof／compatibility initiative可以在`docs/design_sources/<initiative>/source.pen`保存一份有界`.pen`。
- 模板正式採用為實際App後，預設使用`docs/design_sources/app/app-master.pen`作product-level canonical design authority；整個App的主要screens、states與flows放在同一份master中。
- Flutter feature只引用master裡的對應screen／frame／flow，不因`features/<feature>/`的code ownership而建立另一份`.pen`。
- 只有經Requirement Decision確認檔案規模、Pencil效能、設計ownership或不同產品surface lifecycle等明確理由後，才拆分多份product `.pen`。

因此目前Milestone 33的單頁proof是合法的template-only情境，不代表未來產品採「一feature一pen」。

Feature First只定義Flutter source的feature ownership；不得用它推導Pencil document數量或檔案邊界。

## Current Initiatives

### Pencil Compatibility Write Pre-check

路徑：`docs/design_sources/pencil-compatibility-write-precheck/`

| File | Role | Current state |
|---|---|---|
| `source.pen` | Primary structural／visual source | Accepted repository-local authority |
| `pencil-preview.png` | Pencil renderer derived evidence | Task 33-6 fresh canonical `941 × 1672` export；current pixel-comparison master，exact hash由manifest擁有 |
| `original-reference.png` | Supplementary original visual reference | `941 × 1672`; not structural authority |
| `historical-flutter-benchmark.png` | Historical blank-project Flutter benchmark | `226 × 400`; comparison baseline only |

Manifest：[`../visual_authority/pencil-compatibility-write-precheck/manifest.md`](../visual_authority/pencil-compatibility-write-precheck/manifest.md)。

## External Admission Boundary

`D:\Developer\ui-agent`只保存本initiative匯入前的external admission inputs。Task 33-4 destination hashes通過後，後續implementation、Pencil與visual validation只可使用本目錄與manifest；external files不再是active authority。
