---
document_type: knowledge
status: active
authoritative_for:
  - repository-local-visual-authority-routing
last_reviewed_baseline: 1.14.0
---

# Visual Authority Manifests

本目錄保存每個design initiative的source ranking、raw hashes、canonical viewport與derived／benchmark disposition。Manifest是runtime evidence contract，不取代canonical ADR、Milestone Design或Implementation Plan。

## Required Contract

每份`manifest.md`必須：

- 使用`document_type: runtime-evidence`與accepted status。
- 指定唯一initiative、primary authority file與authority SHA-256。
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
