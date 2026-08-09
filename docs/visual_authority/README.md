---
document_type: knowledge
status: active
authoritative_for:
  - repository-local-visual-authority-routing
last_reviewed_baseline: 1.16.0
---

# Visual Authority Manifests

本目錄保存每個design initiative的source ranking、raw hashes、canonical viewport與derived／benchmark disposition。Manifest是runtime evidence contract，不取代canonical ADR、Milestone Design或Implementation Plan。

這裡的`initiative`代表manifest／authority scope，不等於Flutter feature。模板中的isolated proof可以是一個initiative一份`.pen`；實際產品預設可由`docs/visual_authority/app/manifest.md`鎖定整份`docs/design_sources/app/app-master.pen`，多個Flutter features共同引用其中各自對應的screens／frames／flows。只有中央Requirement Decision明確接受拆分理由時，才建立多份product-level `.pen` authority。

換言之，manifest scope可以是product-level；不得因Flutter feature boundary存在就要求每個feature各自建立manifest與`.pen`。

## Required Contract

每份`manifest.md`必須：

- 使用`document_type: runtime-evidence`與accepted status。
- 指定唯一authority scope（isolated initiative或product app）、primary authority file與authority SHA-256。
- 固定positive canonical width、height與DPR。
- 包含`Role | Path | SHA-256 | Authority status`表格。
- 至少有`primary-source`、`derived-preview`、`supplementary-reference`與`historical-benchmark`四個唯一roles。
- 所有paths必須位於repository內，所有files必須存在且raw hashes一致。
- 只有`primary-source`可標記`primary`；benchmark永遠不能提升為primary。

`tools/visual/verify_visual_authority.py`與repository`docs_check`會fail closed驗證上述contract。

## Current Manifests

- [`pencil-compatibility-write-precheck/manifest.md`](pencil-compatibility-write-precheck/manifest.md)：Milestone 33單頁Write Pre-check compatibility proof。

## Lifecycle

Derived file更新時必須在同一Task更新manifest hash並fresh驗證。Primary source變更需要重新分類source drift、更新approval evidence並依中央治理決定是否重開Design／Plan；不得只修改hash掩蓋authority change。
