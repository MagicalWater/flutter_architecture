---
document_type: roadmap-index
status: active
authoritative_for:
  - project-roadmap-routing
last_reviewed_baseline: 1.13.0
---

# Roadmap

本文件是專案 Roadmap 的總入口，只保存目前 baseline、active milestone、candidate、deferred 與 closed milestone routing。

它不保存逐 Task implementation journal、測試數成長、runtime evidence 或完整 Architecture Decision contract。

## Current Baseline

```txt
Template Baseline: 1.13.0
Supported platforms: Android, iOS
iOS: Simulator and GitHub-hosted build verified; physical device and distribution deferred
Other platforms: Dependency-ready
```

版本字串的唯一來源是 root `VERSION`；正式版本變更紀錄由 `CHANGELOG.md` 保存。

## Active Milestone

```txt
Milestone 32 — CI產物本機化與GitHub儲存空間切換
Template Baseline: 1.13.0
Current gate: Tasks 1–10已完成，停在GitHub irreversible cleanup獨立核准gate
```

完整 active scope、design、gate與 next action：

- `docs/roadmap/active.md`

## Candidates

尚未承諾為 active milestone 的具體候選方向：

- `docs/roadmap/candidates.md`

未具體化 ideas、deferred commitments 與 explicit non-goals：

- `docs/backlog.md`

Candidate 不代表已核准，不得直接開始 implementation。

## Closed Milestones

Milestone 1 至 31 已完成或已有明確 disposition。歷史 plan、review、runtime evidence、release 與 archive routing 集中於：

- `docs/milestones/README.md`
- `docs/archive/README.md`
- `docs/audits/README.md`
- `docs/superpowers/README.md`

Roadmap 不再複製已完成 milestone 的逐階段 journal。

## Roadmap Update Rule

Roadmap 只在下列事件更新：

- active milestone 建立、取消、完成或封存。
- candidate 被新增、移除或提升為 active。
- deferred commitment 的 disposition 改變。
- baseline release 改變 current active direction。

實作結果應更新 phase review；正式版本結果應更新 CHANGELOG；Architecture contract 應更新 Decision，而不是追加到本文件。
