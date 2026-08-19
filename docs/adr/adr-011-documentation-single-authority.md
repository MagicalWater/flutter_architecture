---
document_type: architecture-decision
status: accepted
authoritative_for:
  - adr-011-documentation-single-authority
last_reviewed_baseline: 1.25.0
id: ADR-011
title: Documentation as Single Authority
supersedes:
superseded_by:
related:
  - ADR-009
---

# ADR-011 — Documentation as Single Authority

## Status

Accepted；原始固定檔案清單與 aggregate-only 更新流程已由 Milestone 22 documentation governance 正規化。

## Authoritative Scope

本 Decision 定義專案狀態、架構規則與歷史證據必須沉澱到 repository 文件，而不能依賴聊天紀錄或個人記憶。

## Context

對話、臨時筆記與個人記憶無法穩定支援新對話、新維護者或長期演進。另一方面，將同一資訊複製到多份文件又會產生互相衝突的 current state。

## Decision

- Repository 文件是專案 knowledge 與恢復上下文的正式系統。
- 每項 current fact、Decision、plan、evidence、release 或 history 只能有一個 authoritative owner。
- 其他文件只能摘要、連結或保存當時 evidence，不得建立平行 Single Source of Truth。
- 架構規則改變時，先更新對應 Architecture Decision authority，再進行實作與文件同步。
- AI 與維護者依 task-based reading route 載入需要的 authority，不把所有歷史文件當成固定必讀集。

文件 taxonomy、metadata、status、archive 與 migration safety 由 Documentation Hub 及 Governance Policy 擁有，本 ADR 不重複完整治理規則。

## Consequences

- 新對話與新維護者可由 repository 恢復 current contract。
- Historical plan／audit 不會覆蓋 current snapshot 或 Decision。
- 大型搬移與拆分必須保留 stable identity、manifest、semantic review 與 compatibility route。

## Supersession

Milestone 22 沒有取代「文件優於聊天記憶」的核心決策，而是取代原始 ADR 中過時的固定關鍵檔案清單，以及「一律先修改 aggregate architecture file」的單一路由。

目前 fresh admission hard policy 由 `AGENTS.md` 擁有；documentation taxonomy / task-based document routing 由 `docs/README.md`、`docs/governance/documentation_policy.md` 與各 managed index 擁有。

## Related Decisions

- ADR-009：Repository 人類可讀文件的語言政策。

## Related Evidence

- [Documentation Hub](../README.md)
- [Documentation Governance Policy](../governance/documentation_policy.md)

## Last Reviewed Baseline

1.25.0。
