---
document_type: architecture-decision-index
status: active
authoritative_for:
  - architecture-decision-routing
last_reviewed_baseline: 1.14.0
---

# Architecture Decision Records

本文件是 Architecture Decision 的 canonical index，也是ADR-001至ADR-031的正式routing authority。

## Migration State

- `extracted`：canonical ADR file已建立並通過 semantic、relation、link與 checker review。

Authority cutover後所有正式 Decision必須維持 `extracted`，checker強制驗證既有 canonical ADR完整 coverage。

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
| ADR-018 | adr-018-design-system-theme-boundaries.md | extracted |
| ADR-019 | adr-019-localization-locale-failure-mapping.md | extracted |
| ADR-020 | adr-020-exception-failure-reporting.md | extracted |
| ADR-021 | adr-021-auth-startup-navigation-coordination.md | extracted |
| ADR-022 | adr-022-authentication-security-capability-boundaries.md | extracted |
| ADR-023 | adr-023-repository-ci-quality-gates-android-verification-artifact.md | extracted |
| ADR-024 | adr-024-ios-platform-runner-native-dependency-verification-contract.md | extracted |
| ADR-025 | adr-025-native-environment-mapping-product-identity-contract.md | extracted |
| ADR-026 | adr-026-production-observability-provider-release-symbol-contract.md | extracted |
| ADR-027 | adr-027-connectivity-offline-state-foundation.md | extracted |
| ADR-028 | adr-028-repository-local-pencil-to-flutter-design-implementation-workflow.md | extracted |
| ADR-029 | adr-029-risk-based-test-authoring-governance.md | extracted |
| ADR-030 | adr-030-template-to-product-repository-identity-bootstrap-contract.md | extracted |
| ADR-031 | adr-031-template-to-product-repository-infrastructure-adoption-contract.md | extracted |

## Canonical ADR Contract

Canonical records 使用：

```txt
docs/adr/adr-NNN-stable-kebab-title.md
```

每個 record 必須使用 `architecture-decision` metadata、唯一 `ADR-NNN` ID、與 filename 一致的三位數編號，以及可驗證的 `supersedes`／`superseded_by` relation。

## Compatibility

本目錄既有 `000-*` 至 `005-*` 文件已轉為 `legacy` compatibility routes，不是 canonical Decision records，也不會建立 ADR-000。

舊 aggregate路徑 `../architecture_decisions.md`維持 stable compatibility stub，不再承載 Decision正文。

逐 Decision disposition與批次策略：

- `../migrations/m23_adr_extraction_manifest.md`
- `../audits/milestone_23/23-0_planning_review.md`

