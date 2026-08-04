---
document_type: knowledge
status: active
authoritative_for:
  - repository-local-design-source-routing
last_reviewed_baseline: 1.14.0
---

# Repository-local Design Sources

本目錄保存已進入repository authority boundary的原始設計來源與直接衍生檔案。它回答「實作必須讀取哪一份source」，不保存Task approval、architecture decision或runtime review結論。

## Authority Rules

- Active source必須位於initiative子目錄，不能依賴外部absolute path。
- `.pen`只可透過approved Pencil MCP讀取或修改，不得以native parser、text editor或direct file mutation作fallback。
- Binary／design files以raw SHA-256鎖定；copy後必須獨立重算destination hash。
- Derived preview、original reference與historical benchmark不得冒充primary `.pen` authority。
- Source ranking、canonical viewport與supersession由對應`docs/visual_authority/<initiative>/manifest.md`擁有。

## Current Initiatives

### Pencil Compatibility Write Pre-check

路徑：`docs/design_sources/pencil-compatibility-write-precheck/`

| File | Role | Current state |
|---|---|---|
| `source.pen` | Primary structural／visual source | Accepted repository-local authority |
| `pencil-preview.png` | Pencil renderer derived evidence | Task 33-4 admission thumbnail `226 × 400`; Task 33-6 must replace with fresh canonical `941 × 1672` export |
| `original-reference.png` | Supplementary original visual reference | `941 × 1672`; not structural authority |
| `historical-flutter-benchmark.png` | Historical blank-project Flutter benchmark | `226 × 400`; comparison baseline only |

Manifest：[`../visual_authority/pencil-compatibility-write-precheck/manifest.md`](../visual_authority/pencil-compatibility-write-precheck/manifest.md)。

## External Admission Boundary

`D:\Developer\ui-agent`只保存本initiative匯入前的external admission inputs。Task 33-4 destination hashes通過後，後續implementation、Pencil與visual validation只可使用本目錄與manifest；external files不再是active authority。
