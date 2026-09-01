---
document_type: architecture-decision
status: accepted
authoritative_for:
  - adr-008-use-case-granularity
last_reviewed_baseline: 1.27.0
id: ADR-008
title: UseCase Granularity
supersedes:
superseded_by:
related:
  - ADR-001
  - ADR-005
---

# ADR-008 — UseCase Granularity

## Status

Accepted。

## Authoritative Scope

本 Decision 定義何時需要 UseCase，以及存在時的責任粒度。

## Context

UseCase 同時存在兩種常見失敗模式：

- 以功能分類建立大型 `AuthUseCase` 或 `UserUseCase`，逐漸演變成 service façade。
- 為每個 Repository method 機械式建立一層 forwarding UseCase，只增加型別、DI 與測試噪音，卻沒有新增任何 policy、validation 或 orchestration。

## Decision

UseCase 不是 mandatory layer。只有當 application/domain boundary 需要擁有可命名的 business behavior 時才建立，例如：

- non-trivial validation／normalization；
- 多個 Repository／policy 的 orchestration；
- 跨多個 data operation 的 ordering、compensation 或 transaction-like rule；
- 與單一 Repository method 不等價、且可獨立演化的 application policy。

若 Presentation 只需呼叫一個 Repository contract，且 UseCase 只會原樣轉發參數與結果，Presentation 可直接依賴該 Repository interface。

存在的 UseCase 應對應一個清楚 business behavior；不得以功能名稱收納多個不相關 commands，也不得為了維持層數、命名對稱或測試「repository called once」而建立 forwarding class。

## Consequences

- UseCase 數量由實際 behavior ownership 決定，不由 feature 數量或 Repository method 數量決定。
- Presentation 可依需要直接注入 Repository，或注入真正擁有 business behavior 的 UseCase。
- Orchestration 由最接近該 workflow 的真實 behavior owner 擁有；依責任可落在 UseCase、Repository 或 Coordinator，但不得為了維持固定層級而建立 forwarding class 或巨型 façade。

## Supersession

無。

## Related Decisions

- ADR-001：Clean Architecture dependency direction。
- ADR-005：Auth domain 與 data package boundary。

## Related Evidence

- [Aggregate Decision authority during migration](../architecture_decisions.md)

## Last Reviewed Baseline

1.27.0。
