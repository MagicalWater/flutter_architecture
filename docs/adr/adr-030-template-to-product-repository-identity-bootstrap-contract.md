---
document_type: architecture-decision
status: accepted
authoritative_for:
  - template-to-product-repository-identity-bootstrap-contract
last_reviewed_baseline: 1.17.0
id: ADR-030
title: Template-to-Product Repository Identity Bootstrap Contract
supersedes: []
superseded_by: []
related:
  - ADR-011
  - ADR-014
  - ADR-023
  - ADR-025
---

# ADR-030 — Template-to-Product Repository Identity Bootstrap Contract

## Status

Accepted。

## Context

`flutter_architecture` 同時是可持續維護的 template repository 與新產品的起始來源。透過 GitHub `Use this template` 建立的新 repository 會取得相同 repository bytes，但它不應長期繼續把自己描述成 template，也不能只靠 Git remote、資料夾名稱或聊天交接推斷「是否已採用成產品」。

既有 `adopting-template-product-identity`、ADR-014、ADR-025 與 `apps/flutter_architecture/config/environments.json` 已擁有 Android／iOS native identity 與 environment mapping。Repository lifecycle、template provenance 與 product version 語意需要獨立且不重疊的 authority。

## Decision

Root `repository_identity.json` 是 repository lifecycle 與 template provenance 的唯一 machine-readable authority。

Persistent lifecycle state 只有：

```txt
template
product
```

`template` state 表示目前 repository 本身仍是 template；root `VERSION` 代表 Template Baseline。`product` state 表示首次 bootstrap 已完成；root `VERSION` 此後只代表 Product Repository Version，而來源 template baseline 永久保存在 `repository_identity.json.template_origin.baseline`。

Template → Product bootstrap 預設將 product version 起點設為 `0.1.0`。若 adopter 有明確既定 version policy，可由該次 accepted Requirement Decision override；Agent 不得猜測。

Fresh Agent admission 必須先讀 `repository_identity.json`。Missing、malformed、unknown state 或 invariant mismatch 一律 fail closed，不得從 remote URL、folder name、README prose、native identifier 或聊天記憶猜測 lifecycle。

首次 bootstrap 的 repository orchestration 使用薄型 `adopting-template-repository` Skill；中央 `governing-template-development` 仍擁有 Requirement Decision、Level、Design／Plan與Task governance。需要 Android／iOS product identity 時，bootstrap Skill 必須委派既有 `adopting-template-product-identity`，不得建立第二份 native mapping authority。

Bootstrap 使用 atomic completion boundary：

```txt
template state
→ confirm product inputs
→ repository docs/version/native projections
→ blocking validations
→ prospective candidate-product identity validation
→ final canonical repository_identity transition
→ canonical fresh verification
```

在 final transition 前，canonical `repository_kind` 必須保持 `template`。不新增持久的 `bootstrapping` 第三狀態。任何 blocking validation 失敗時，Task保持 open／blocked，不能讓 fresh Agent 把半完成 repository 視為已採用 product。

## Consequences

- 新產品 repository 不需要依賴先前 conversation handoff 才知道自己的產品名稱、template origin與current version。
- Template baseline 與 Product version 不再共用同一語意。
- GitHub Template Repository 是 repository birth mechanism；不是長期 upstream merge contract。
- `repository_identity.json` 不保存 Android／iOS bundle identifier、API domain、environment mapping或Feature／roadmap內容。
- Product repository 再次要求「首次 bootstrap」時必須回中央治理重新分類，而不是重跑 lifecycle transition。
- `Use this template` 之後的產品需求、MVP、Feature與產品 roadmap 仍由該 product repository 自行決策，本 ADR 不規定其產品開發內容。

## Related Decisions

- ADR-011：Documentation Single Authority。
- ADR-014：App configuration 與 environment entrypoints。
- ADR-023：Minimum Sufficient Validation／repository CI quality gates。
- ADR-025：Native environment mapping 與 product identity contract。
