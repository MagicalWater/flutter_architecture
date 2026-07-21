---
document_type: architecture-decision-index
status: active
authoritative_for:
  - architecture-decision-routing
last_reviewed_baseline: 1.5.1
---

# Architecture Decision Records

本文件是 Architecture Decision 的 migration-aware index。Milestone 23 authority cutover 完成前，`docs/architecture_decisions.md` 仍是 Decision 001–022 的唯一正式正文 authority。

## Migration State

- `aggregate`：Decision 正文仍只存在 aggregate authority；index 不要求 canonical ADR file。
- `extracted`：canonical ADR file 已建立並通過 semantic review；aggregate 正文仍保留到最終 cutover。

只有完成逐 Decision semantic preservation review、relation review 與 checker validation後，才能把該列從 `aggregate` 改成 `extracted`。

## Decision Index

| ID | File | Migration state |
|---|---|---|
| ADR-001 | adr-001-clean-architecture-feature-first.md | extracted |
| ADR-002 | adr-002-monorepo-melos.md | extracted |
| ADR-003 | adr-003-presentation-state-and-hooks.md | extracted |
| ADR-004 | adr-004-app-dependency-injection.md | extracted |
| ADR-005 | adr-005-auth-package-boundary.md | extracted |
| ADR-006 | adr-006-auth-guard-session-authority.md | extracted |
| ADR-007 | adr-007-cross-feature-state-boundaries.md | extracted |
| ADR-008 | adr-008-use-case-granularity.md | extracted |
| ADR-009 | adr-009-project-language-policy.md | extracted |
| ADR-010 | adr-010-cross-platform-sqlite-initialization.md | extracted |
| ADR-011 | adr-011-documentation-single-authority.md | extracted |
| ADR-012 | adr-012-reusable-package-di-boundary.md | extracted |
| ADR-013 | adr-013-retrofit-http-api-boundary.md | extracted |
| ADR-014 | adr-014-app-configuration-environment-entrypoints.md | extracted |
| ADR-015 | adr-015-refresh-token-concurrent-401.md | extracted |
| ADR-016 | adr-016-catalog-pagination-search.md | extracted |
| ADR-017 | adr-017-catalog-offline-cache-swr.md | extracted |
| ADR-018 | - | aggregate |
| ADR-019 | - | aggregate |
| ADR-020 | - | aggregate |
| ADR-021 | adr-021-auth-startup-navigation-coordination.md | extracted |
| ADR-022 | - | aggregate |

## Canonical ADR Contract

Canonical records 使用：

```txt
docs/adr/adr-NNN-stable-kebab-title.md
```

每個 record 必須使用 `architecture-decision` metadata、唯一 `ADR-NNN` ID、與 filename 一致的三位數編號，以及可驗證的 `supersedes`／`superseded_by` relation。

## Compatibility

本目錄既有 `000-*` 至 `005-*` 文件仍是 legacy placeholders，不是 canonical Decision records。它們會保留到 Milestone 23 authority cutover，再依 migration manifest轉為明確的 compatibility routing。

逐 Decision disposition與批次策略：

- `../migrations/m23_adr_extraction_manifest.md`
- `../audits/milestone_23/23-0_planning_review.md`

