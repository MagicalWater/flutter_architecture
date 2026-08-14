---
document_type: architecture-decision
status: accepted
authoritative_for:
  - template-to-product-repository-infrastructure-adoption-contract
last_reviewed_baseline: 1.18.0
id: ADR-031
title: Template-to-Product Repository Infrastructure Adoption Contract
supersedes: []
superseded_by: []
related:
  - ADR-023
  - ADR-030
---
# ADR-031 — Template-to-Product Repository Infrastructure Adoption Contract

## Status

Accepted。

## Context

GitHub `Use this template`只複製tracked repository bytes，不複製Repository Variables、Secrets、Environments、runner registration、Actions settings或Branch Protection。ADR-030已解決repository lifecycle／provenance，但若沒有獨立infrastructure adoption contract，新產品仍可能在CI profile與live state尚未處置時被誤判為bootstrap完成。

## Decision

Root `repository_infrastructure.json` 是repository infrastructure **desired／disposition state**的唯一tracked machine authority。它與`repository_identity.json`分離；前者不擁有template/product lifecycle，後者不擁有CI或GitHub infrastructure。

首次產品採用必須明確選擇一個CI profile：

```txt
manual-local
self-hosted
github-hosted
```

Selected profile不得以missing variable或`deferred`取代。Optional secret-backed capability可使用`configured | deferred | not-applicable` disposition，但不得保存secret value。

`repository_infrastructure.json`不得保存runner token、credential、service-account JSON、signing material、GitHub API token、operator absolute path或GitHub numeric live object ID。

Managed local artifact的implicit default identity由tracked `artifact_store.product_key`投影，不從folder name或Git remote推導。Self-hosted仍必須使用explicit external artifact root並fail closed。

GitHub live state遵守：

```txt
read current state
→ compare selected profile / safety baseline
→ apply only authorized mutations
→ fresh read-back
→ evidence
```

Tracked文件不得宣稱live settings已配置；permission failure或read-back mismatch必須fail closed。

Template → Product atomic completion延伸為：

```txt
template identity admission
→ product/native candidate mutation
→ infrastructure manifest + selected CI profile
→ tracked validation
→ required live infrastructure disposition + selected profile acceptance
→ prospective product identity validation
→ final repository_kind=product
→ canonical identity/infrastructure validation
→ fresh no-handoff acceptance
```

Selected profile required acceptance未完成前，canonical lifecycle不得finalize為`product`。

## Responsibility Boundaries

- ADR-023繼續擁有CI quality gates、execution、runner trust、artifact transport/security runtime contract。
- ADR-030繼續擁有repository lifecycle、template provenance與product VERSION semantics。
- ADR-031只擁有Template → Product infrastructure adoption、CI profile selection、desired/disposition authority、live read-back原則與product artifact identity。
- Production signing與Store distribution仍不在本Decision scope。

## Consequences

- Fresh Agent可分辨「尚未配置」與「明確defer」。
- 新產品不再默默沿用`flutter_architecture` artifact store identity。
- Live GitHub設定不會因workflow files存在就被誤稱為configured。
- Bootstrap增加必要的CI profile決策與runtime evidence，但optional provider capability仍可安全defer。

## Recovery

- Final product transition前任何required infrastructure failure都保持`repository_kind=template`。
- Live mutation保存before／after read-back；可逆設定依operation guide恢復。
- 本Decision不刪runner、不刪Environment、不rotate或刪除credential。
