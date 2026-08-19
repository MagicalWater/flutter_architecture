---
document_type: audit-index
status: active
authoritative_for:
  - audit-and-review-evidence-routing
last_reviewed_baseline: 1.25.0
---

# Audits and Review Evidence

`docs/audits/` 保存 planning review、implementation / holistic review、runtime evidence、findings 與 post-release evidence。

## Authority

Audit 只擁有「當時觀察到什麼、如何處置、哪些 evidence 通過」。它不擁有 current architecture、roadmap、release identity 或 workflow policy。

Current facts 分別由 current snapshot、canonical ADR、roadmap、machine manifest、source/runtime、`VERSION` / `CHANGELOG.md` 擁有。

## Historical routing

本 index 不再平行維護逐 Milestone evidence 清單。Milestone-level history 統一由：

```txt
docs/milestones/README.md
```

路由到對應 audit / Design / Plan / release evidence。

若已知 Milestone，可直接進：

```txt
docs/audits/milestone_<N>/
```

Standalone audit / corrective evidence 保留原檔名，可由 repository search 或其 owning Design / Plan / ADR link 進入。

## Reading rule

- Ordinary development admission 不讀 audits。
- Review task 只讀與 current change / finding 直接相關的 evidence。
- Historical investigation 先從 milestone router 定位，不掃描全部 audits。
- Historical finding 不得覆蓋後來的 current authority。

## Growth rule

M45 後不為每個 implementation subtask 機械建立 audit file。只有 material finding、formal critical boundary、runtime evidence 或 Milestone holistic / post-release closure 真正需要 durable evidence 時才建立。
