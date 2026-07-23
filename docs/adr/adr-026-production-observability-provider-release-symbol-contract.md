---
document_type: architecture-decision
status: accepted
authoritative_for:
  - adr-026-production-observability-provider-release-symbol-contract
last_reviewed_baseline: 1.8.0
id: ADR-026
title: Production Observability Provider Release and Symbol Contract
supersedes:
superseded_by:
related:
  - ADR-004
  - ADR-014
  - ADR-020
  - ADR-023
  - ADR-024
  - ADR-025
---

# ADR-026 — Production Observability Provider, Release and Symbol Contract

## Status

Accepted。

## Authoritative Scope

本 Decision 定義 production observability 的 provider boundary、App-owned composition、release identity、privacy、collection、provider failure isolation，以及 Android mapping／Flutter symbols與iOS dSYM的release pipeline責任。

Exception／Failure分類、expected operational Failure、unknown error propagation與基本sensitive-data contract仍由ADR-020擁有。

## Context

Baseline 1.8.0已具備App-owned `ErrorReporter`、Flutter／Platform／Bloc／Bootstrap入口、fatal／unexpected／degraded分類、同event-loop identity deduplication、safe context與environment mapping，但目前只有Debug／Noop adapter，沒有production provider、release tagging、symbol upload、privacy adoption或remote acceptance evidence。

若直接在Feature、Package或global handler呼叫特定SDK，未來替換provider會擴散到整個專案；若只建立抽象而不實作reference adapter，則無法驗證native setup、mapping／dSYM、provider outage與release event。

## Decision

### Provider strategy

採用：

```txt
App-owned provider-neutral observability contracts
  ↓
Firebase Crashlytics single reference adapter
```

第一版只導入一個production provider，不同時導入Sentry。Crashlytics是reference implementation，不是reusable package contract。

未來替換provider只應改動：

- App-owned provider initializer。
- `ErrorReporter` adapter與provider SDK seam。
- Android／iOS native configuration。
- CI symbol upload與remote acceptance step。
- Adopter configuration guide。

Feature、Package、Exception／Failure mapping、Bloc及Flutter／Platform capture boundary不得因provider替換而改寫。

### Composition and dependency boundary

- App維持唯一Composition Root。
- Reusable package不得依賴Firebase、Crashlytics、Sentry或其他observability SDK。
- Feature／Package不得直接呼叫provider API。
- Provider SDK只存在於App與native runner integration scope。
- Test使用Recording／Fake／Noop reporter，不需要provider backend。

### Event routing

- `fatal`：Bootstrap fatal與Platform/root-isolate uncaught，映射為provider fatal／crash-compatible event。
- `unexpected`：Flutter framework、Bloc unhandled與unknown programming／system error，映射為non-fatal exception並保留stack。
- `degraded`：僅限ADR-020允許的重要degraded-mode diagnostic，經process-local rate limiting後上報。
- Expected operational `Failure`預設不上報；不得把所有`Failure`當成production error。

現有deduplicator只負責同一event-loop turn內的App entrypoint重複抑制；provider後台grouping不屬於App deduplicator責任。

### Release identity

App建立immutable release identity，至少包含：

```txt
environment
version
buildNumber
platform
nativeConfiguration
commitSha? 
```

- Environment沿用ADR-014／025 authority與native mismatch fail-fast。
- Version／build number必須有單一可驗證來源。
- Commit SHA由CI注入；local build可缺省，不得假造。
- Staging與production資料必須能在provider後台明確區分。

### Privacy and safe context

第一版anonymous-by-default，不設定provider user identifier。

禁止送出：

- password、OTP、PIN、access／refresh token。
- Authorization、Cookie與完整headers。
- Raw request／response body或storage payload。
- Email、phone、name、address、raw user/account/device identifier。
- Search query、cursor值、free-form Bloc state、event或任意Map context。

允許的context必須是封閉typed allowlist，例如source、operation、environment、release identity、HTTP method、sanitized path template、status、backend code、`hasSession`與不可反推出帳號的session generation。

User correlation若未來確有產品需求，必須另行privacy review與ADR adjustment。

### Collection, consent and retention

- Template提供App-owned collection switch與adopter hook。
- Development remote collection預設關閉。
- Staging可啟用remote verification。
- Production是否預設collection由adopter privacy policy決定，不由Feature決定。
- Adopter必須揭露provider、資料類型、retention、deletion／opt-out方式與適用法規責任。
- 本Decision不宣稱符合特定司法管轄區。

### Provider initialization and failure isolation

Provider採兩階段composition：

1. 先建立永不拋出的local fallback reporter。
2. Best effort初始化production provider，再切換或組合remote adapter。

Provider initialization、report、callback、queue或outage失敗不得：

- 阻止App啟動。
- 取代原始error propagation。
- 造成recursive reporting。
- 在report path直接執行network request、database write或無界重試。

Flutter mobile process沒有可靠通用shutdown保證，因此不宣稱所有事件都能flush；offline buffering與delivery queue第一版依provider SDK contract。

### Rate limiting and breadcrumbs

- Fatal與unexpected第一版不做App-side random sampling。
- Degraded事件依source＋operation做process-local burst limiting。
- 不以error message、payload或stack string作rate key。
- 第一版只允許typed system breadcrumbs；不得提供Feature任意文字breadcrumb API。
- Connectivity breadcrumbs等候未來Connectivity and Offline State Foundation提供typed authority後再接入。

### Android and iOS release integration

Android：

- Provider Gradle plugin與config只存在App Android runner。
- 建立environment mapping與R8／ProGuard mapping upload contract。
- 若採Flutter obfuscation／`--split-debug-info`，必須同步建立Flutter symbol upload contract；未採用不得宣稱已支援。
- Debug verification signing可驗證wiring與mapping，但不代表Play Store distribution。

iOS：

- Provider config與upload script只存在Runner／CI integration。
- 建立dSYM生成、存在性與upload contract。
- Unsigned generic device build可驗證dSYM tooling，但不代表IPA、TestFlight或App Store distribution。

### CI and secrets

- Provider credential不得提交repository。
- Fork Pull Request不得取得secret；可安全skip remote upload，但build與static contract validation仍須完成。
- Main push或manual workflow可在secret存在時執行remote event與symbol acceptance。
- Provider outage不得讓一般quality與unit test失敗。
- Remote upload未執行時必須明確標示not executed，不得偽裝verified。

### Analytics separation

Observability與Analytics維持獨立：

- Crash／exception reporting不建立business event taxonomy。
- 不因Crashlytics breadcrumb選項而自動把Firebase Analytics納入Milestone。
- Analytics adapter與event governance另由未來獨立scope決定。

## Consequences

- Production provider dependency被限制在App與native integration，未來替換不需要改寫Feature與Package。
- Foundation可透過單一reference adapter驗證真實native、symbol與remote behavior。
- 第一版不會同時維護兩套provider，降低CI、privacy與operational complexity。
- Crashlytics-specific native與CI wiring仍有替換成本，但被控制在明確integration boundary。
- Analytics、APM、session replay與Connectivity不會被錯誤綁入本Milestone。

## Non-goals

- 同時導入Firebase Crashlytics與Sentry。
- Analytics、business event tracking與Google Analytics integration。
- Performance APM、distributed tracing、session replay。
- Generic remote logging backend或完整SRE平台。
- Production signing、Store distribution與release promotion。
- App-owned persistent crash queue或connectivity orchestration。

## Supersession

無。

## Related Decisions

- ADR-004：App Composition Root與DI ownership。
- ADR-014／025：Dart與native environment mapping。
- ADR-020：Exception／Failure／reporting基本分類與敏感資料。
- ADR-023：Repository CI quality gate與verification artifact。
- ADR-024：iOS runner與native build verification boundary。

## Related Evidence

- [Production Observability Capability Audit](../audits/production_observability_capability_audit.md)
- [Production Observability Foundation Design](../superpowers/specs/2026-07-23-production-observability-foundation-design.md)
- [Production Observability Design Review](../audits/production_observability_design_review.md)

## Last Reviewed Baseline

1.8.0。
