---
document_type: runtime-evidence
status: accepted
authoritative_for:
  - pencil-compatibility-write-precheck-visual-authority
last_reviewed_baseline: 1.14.0
initiative: pencil-compatibility-write-precheck
authority_file: ../../design_sources/pencil-compatibility-write-precheck/source.pen
authority_sha256: bd8926711ea28e7f9ae5a83128ed8fbc8d506cb5342c76eb35360c4c13544fdc
canonical_width: 941
canonical_height: 1672
canonical_dpr: 1.0
---

# Pencil Compatibility Write Pre-check Visual Authority

## Source Ranking

1. `source.pen`是唯一primary structural／visual authority。
2. `pencil-preview.png`是Task 33-6直接由accepted root frame透過Pencil MCP、`scale: 1`匯出的canonical renderer preview，作後續canonical pixel comparison master。
3. `original-reference.png`是產生／審查`.pen`時的supplementary original PNG，不可覆蓋`.pen`結構。
4. `historical-flutter-benchmark.png`只代表先前blank Flutter proof的historical comparison，不是current implementation authority。

| Role | Path | SHA-256 | Authority status |
|---|---|---|---|
| primary-source | ../../design_sources/pencil-compatibility-write-precheck/source.pen | bd8926711ea28e7f9ae5a83128ed8fbc8d506cb5342c76eb35360c4c13544fdc | primary |
| derived-preview | ../../design_sources/pencil-compatibility-write-precheck/pencil-preview.png | f453452316f0e390dbbf435a3f4c2433306fb3aa607287873e9905f00973eee8 | derived |
| supplementary-reference | ../../design_sources/pencil-compatibility-write-precheck/original-reference.png | c7469bcdd8842ad7a0e2f57715756615e07990d0fec33d6016105c5e45e398fc | supplementary |
| historical-benchmark | ../../design_sources/pencil-compatibility-write-precheck/historical-flutter-benchmark.png | 69edbc35da44288e80b448231de50f9a51d95ba84c9042ea16797267b607731d | benchmark |

## Canonical Viewport

```txt
Width: 941
Height: 1672
Device pixel ratio: 1.0
```

此viewport定義後續canonical Flutter golden／runtime screenshot／diff尺寸，不代表App只支援此尺寸。

## Canonical Preview Export Evidence

```txt
Pencil tool: pencil.user.desktop.export_nodes
Accepted root frame: lAOay (Screen / Write Pre-check Reconstruction)
Requested format: PNG
Requested scale: 1
Exported dimensions: 941 × 1672
Exported raw SHA-256: f453452316f0e390dbbf435a3f4c2433306fb3aa607287873e9905f00973eee8
Exported bytes: 676527
Canonical comparison readiness: READY
```

此檔案不是Task 33-4 admission thumbnail的upscale。它是Pencil MCP直接對accepted `941 × 1672` root frame執行fresh renderer export後的原始PNG bytes。Task 33-10可依本manifest使用它作canonical Pencil reference；任何後續重新匯出仍須更新hash並fresh通過verifier。

## Allowed Interpretation

- 可從`.pen`透過Pencil MCP提取frame、components、variables、layout、typography、colors、effects與unsupported constructs。
- 可使用original reference協助理解decorative intent，但衝突時`.pen`優先。
- 可使用historical benchmark衡量新template implementation是否退化，但不能複製其fixed-canvas／full-screen scaling捷徑。

## Forbidden Substitution

- PNG不得取代`.pen`成為structure authority。
- Historical Flutter screenshot不得成為golden master。
- 不得以full-screen raster embedding、native `.pen` parser、thumbnail upscale或dynamic ignore region取得通過。
- External`D:\Developer\ui-agent`files不得在Task 33-4後作active implementation input。

## Supersession

Primary `.pen`只有在新的accepted Design／authority review明確指定replacement、hash、migration與rollback後才能被supersede。Derived preview可由對應Task重新匯出，但必須同步更新本manifest並fresh通過verifier。
