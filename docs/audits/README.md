---
document_type: audit-index
status: active
authoritative_for:
  - audit-and-review-evidence-routing
last_reviewed_baseline: 1.26.0
---

# Audits and Review Evidence

`docs/audits/` 只保存具有獨立長期價值的 historical closure / runtime evidence。Intermediate Design review、Plan review、per-task review、checkpoint、handoff、temporary admission 與已被 final review 吸收的過程證據，不再永久保留；需要時由 Git history 追溯。

## Authority

Audit 只擁有「當時觀察到什麼、如何處置、哪些 evidence 通過」。它不擁有 current architecture、roadmap、release identity 或 workflow policy。

Current facts 分別由 current snapshot、canonical ADR、roadmap、machine manifest、source/runtime、`VERSION` / `CHANGELOG.md` 擁有。

## Historical routing

本 index 不再平行維護逐 Milestone evidence 清單。Milestone-level history 統一由：

```txt
docs/milestones/README.md
```

路由到保留的 durable evidence、`CHANGELOG.md` 與 Git history。

若已知 Milestone，可直接進：

```txt
docs/audits/milestone_<N>/
```

Standalone durable evidence 保留原檔名，可由 repository search、owning ADR 或 milestone router 進入。

## Reading rule

- Ordinary development admission 不讀 audits。
- Review task 只讀與 current change / finding 直接相關的 evidence。
- Historical investigation 先從 milestone router 定位，不掃描全部 audits。
- Historical finding 不得覆蓋後來的 current authority。

## Growth rule

不為 implementation subtask 機械建立 audit file。只有 material incident、formal critical boundary、不可逆 migration、platform/runtime acceptance 或 consolidated holistic closure 真正需要 durable evidence 時才建立。Closed artifact 一律先做 retention decision；Archive trigger 不代表 mandatory permanent retention。
