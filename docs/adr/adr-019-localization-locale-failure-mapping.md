---
document_type: architecture-decision
status: accepted
authoritative_for:
  - adr-019-localization-locale-failure-mapping
last_reviewed_baseline: 1.5.1
id: ADR-019
title: Localization Locale Preference and Failure Mapping
supersedes:
superseded_by:
related:
  - ADR-009
  - ADR-012
  - ADR-018
  - ADR-020
---

# ADR-019 — Localization, Locale Preference and Failure Mapping

## Status

Accepted。

## Authoritative Scope

本 Decision 定義 localization ownership、supported locale resolution、locale preference persistence、user-facing failure mapping與 locale-aware presentation formatting。

## Context

Localization若下沉到 Domain、Data、Exception或 Design System package，會讓 reusable contract依賴 App generated resources與 `BuildContext`。另一方面，若 UI直接顯示 diagnostic `Failure.message`，會把 technical fallback誤當成 localized UX copy。

## Decision

### Localization ownership

App是 localization owner與唯一 Composition Root，負責 `gen_l10n`、ARB、delegates、supported locales、locale resolution、preference、bootstrap restore、controller、selector與 `MaterialApp.router` wiring。

`packages/design_system`不依賴 App generated `AppLocalizations`。Primitive只接收呼叫方已 localized的 title、message、label、tooltip、Semantics與 action text，不自行建立固定語言 fallback。

Domain、Data、Repository、Exception與 log不依賴 `BuildContext`、`AppLocalizations`或 App locale，也不建立可直接顯示的 localized sentence。Server與 user content不寫入 App ARB。

### Supported locale and resolution

第一版 preference支援：

```txt
system
en
zh_TW
```

`system`不保存 resolved locale；`MaterialApp.router.locale`維持 `null`，由 platform locale list resolver決定。Explicit `en`／`zh_TW`則由 controller提供具體 Locale。

Traditional Chinese variants與 `Hant`解析為 `zh_TW`；Simplified Chinese variants、`Hans`與其他 unsupported locale fallback至 English。Generator需要的 base `zh` ARB只作 generated fallback，不擴張 App公開的 supported locales。

### Locale preference

Locale preference使用 App-local versioned complete snapshot，和 Theme preference保持獨立，不建立 Generic Preference Framework。

Controller採 runtime-first與 serialized write queue：

- 寫入失敗不回滾 runtime locale。
- 較舊 failure不阻止較新 snapshot保存。
- Storage read exception以 system preference啟動並保留 non-blocking diagnostic。
- 不因 read failure自動寫回 fallback。
- Bootstrap在 `runApp`前 restore。

Controller只保存 preference與 persistence state，不保存 resolved system locale，也不自行建立 platform observer。

### User-facing failure mapping

`Failure.message`是 diagnostic／fallback information，不保證可直接顯示。

正式流程：

```txt
AppException / technical diagnostic
  ↓
Repository 建立 stable Failure identity
  ↓
Bloc 保存 Failure + operation context
  ↓
Feature Presentation 映射 AppLocalizations
  ↓
Design System 顯示 localized String
```

Feature Presentation依 stable failure kind／code與 operation context建立 surface-specific copy。只有語意明確的 identity才能映射為特定 UX；不足以判定時使用該 operation的 localized fallback，不從 diagnostic message或模糊 status猜測業務語意。

不建立 Global Error Localization Service、Generic Failure Mapper或 operation × failure class笛卡兒積。

### ARB and formatting

ARB key使用 lowerCamelCase與 feature＋semantic purpose；parameterized sentence使用 placeholder，不在 Dart拼接完整句子。

Timestamp在 Data／Domain／Cache維持 UTC。Presentation轉 local time後，依目前 locale格式化日期與時間，不改寫原始值，也不固定為12或24小時制。

Localization不得改變 cursor、ID、version、HTTP code、SQL schema或 persisted identity。

## Consequences

- App localization resources不穿透 reusable package與 lower layers。
- Design System primitives可被不同 App localization方案重用。
- Failure identity與 localized user copy明確分離。
- System locale變化可由 Flutter resolution自然處理，不需要 controller保存第二份 resolved state。
- Theme、Locale各自保有清楚 persistence contract，避免過早 generic abstraction。

## Supersession

無。

## Related Decisions

- ADR-009：Repository維護語言政策，不等於 App runtime locale。
- ADR-012：App擁有 generated localization與 preference composition。
- ADR-018：Design System只接收 localized presentation properties。
- ADR-020：Typed Failure、unexpected error與 reporting contract。

## Related Evidence

- [App README](../../apps/flutter_architecture/README.md)
- [Design System package README](../../packages/design_system/README.md)
- [Catalog feature README](../../apps/flutter_architecture/lib/features/catalog/README.md)

## Last Reviewed Baseline

1.5.1。
