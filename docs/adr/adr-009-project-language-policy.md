---
document_type: architecture-decision
status: accepted
authoritative_for:
  - adr-009-project-language-policy
last_reviewed_baseline: 1.5.1
id: ADR-009
title: Project Language Policy
supersedes:
superseded_by:
related:
  - ADR-011
---

# ADR-009 — Project Language Policy

## Status

Accepted。

## Authoritative Scope

本 Decision 記錄專案採用繁體中文作為人類可讀文件與維護溝通的預設語言。

## Context

本模板主要面向繁體中文使用者。若文件、README、註解與 commit message 任意混用語言，會增加理解成本並造成術語不一致；但強制翻譯技術名稱又會降低與 Flutter／Dart ecosystem 的對應性。

## Decision

- 文件、README、維護性註解與 commit message 描述預設使用繁體中文。
- 不使用簡體中文作為 repository 維護語言。
- 套件、framework、API、類別、Layer 與既有業界技術名詞保留英文。
- 不為翻譯而改變 code identifier、protocol value、storage key 或 external contract。

實際 agent 操作與 commit 格式的 enforcement 由 `AGENTS.md` 擁有；本 ADR 只保存 durable language choice，不複製完整操作規則。

## Consequences

- Repository 的維護語言一致。
- 技術名詞仍能與官方文件、程式碼與 tooling 直接對照。
- 語言規則變更需要同步更新本 Decision 與 governance／agent policy owner。

## Supersession

無。

## Related Decisions

- ADR-011：Project documentation 是可恢復上下文與 authoritative knowledge system。

## Related Evidence

- [AGENTS language and commit rules](../../AGENTS.md)
- [Documentation Governance Policy](../governance/documentation_policy.md)

## Last Reviewed Baseline

1.5.1。
