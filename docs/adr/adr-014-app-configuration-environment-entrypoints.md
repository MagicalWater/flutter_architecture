---
document_type: architecture-decision
status: accepted
authoritative_for:
  - adr-014-app-configuration-environment-entrypoints
last_reviewed_baseline: 1.5.1
id: ADR-014
title: App Configuration and Environment Entrypoints
supersedes:
superseded_by:
related:
  - ADR-004
  - ADR-010
  - ADR-012
  - ADR-013
---

# ADR-014 — App Configuration and Environment Entrypoints

## Status

Accepted。

## Authoritative Scope

本 Decision 定義 Dart-level deployment environment、API implementation mode、entrypoint 與 typed App configuration ownership。

## Context

Deployment environment 與 API implementation selection 是不同概念。若同時由 entrypoint、`APP_ENV` dart-define 與 DI module 自行解析，會產生多個互相衝突的 source of truth；若 reusable package 直接讀取 environment，也會分散 Composition Root。

## Decision

Environment model 分為：

```txt
AppEnvironment
  development
  staging
  production

ApiMode
  mock
  real
```

Dart entrypoint 是 `AppEnvironment` 的唯一來源：

```txt
main.dart
main_development.dart
main_staging.dart
main_production.dart
```

各 entrypoint 只指定 environment 並進入共用 bootstrap；不另外使用 `APP_ENV` dart-define。

Native flavor／scheme負責選到正確Dart entrypoint，但不得再透過`NATIVE_ENVIRONMENT`或其他dart-define把同一environment注入Dart runtime形成第二份authority。Android／iOS可以保留native-only environment metadata供平台build projection或provider wiring使用；該值不得參與`AppConfig` runtime environment判定。

`--dart-define` 只提供環境內可變設定，例如 `API_MODE` 與 `API_BASE_URL`。Parsing 與 validation 集中於 App bootstrap，建立 typed configuration 後明確傳入 Composition Root：

```txt
AppConfig
  environment: AppEnvironment
  api: ApiConfig

ApiConfig
  mode: ApiMode
  baseUri: Uri
```

合法組合：

```txt
development + mock  allowed
development + real  allowed
staging + mock       rejected
staging + real       allowed
production + mock    rejected
production + real    allowed
```

Real API 必須明確提供 `API_BASE_URL`；只允許 HTTP／HTTPS。Production 必須 HTTPS，並拒絕 placeholder、localhost、loopback 與 `.invalid` URL。未知 mode 或不合法設定 fail fast，不得靜默 fallback。

Native product flavor、bundle identity、signing、Firebase 與 CI/CD 是獨立決策範圍，不由本 ADR 推導。

## Consequences

- Environment 只有一個 Dart-level authority。
- Native environment mapping由platform build configuration與repository verifier保證，不由Dart runtime sentinel重複驗證。
- Configuration 在 runApp 與 DI graph 建立前完成 validation。
- Reusable package 不讀取 `String.fromEnvironment`。
- Mock／Real API 選擇由 App Composition Root 管理。
- Platform dependency 或 Web preparation asset 不代表完整 runner 或 runtime support；平台能力以 current snapshot 與 runtime evidence 判定。

## Supersession

無。

Aggregate 中的 Milestone 9 背景、Milestone 18 evidence clarification 與「後續調整」措辭屬歷史／implementation evidence，已改由 review、current snapshot 與 source 保存，不進 canonical ADR 正文。

## Related Decisions

- ADR-004：App DI tool 與 registration owner。
- ADR-010：Database platform initialization 由 bootstrap 隔離。
- ADR-012：Reusable package 不解析 App environment 或宣告 lifecycle。
- ADR-013：Environment 決定 Mock／Real API implementation。

## Related Evidence

- [Current Project Context](../project_context.md)
- [App README](../../apps/flutter_architecture/README.md)
- [Milestone 18 holistic audit](../audits/milestone_18_holistic_audit.md)
- [CHANGELOG](../../CHANGELOG.md)

## Last Reviewed Baseline

1.5.1。
