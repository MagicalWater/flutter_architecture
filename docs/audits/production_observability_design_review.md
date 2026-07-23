---
document_type: planning-review
status: proposed
authoritative_for:
  - production-observability-design-review
last_reviewed_baseline: 1.8.0
---

# Production Observability Capability Audit & Architecture Design Review

## Review scope

本review針對以下artifact做formal cross-check：

- `docs/audits/production_observability_capability_audit.md`。
- `docs/superpowers/specs/2026-07-23-production-observability-foundation-design.md`。
- ADR-020、ADR-023、ADR-025。
- App error-reporting source與focused tests。
- Current roadmap、candidate、backlog、App README與documentation routing。

本review不評估尚未存在的provider implementation，也不把design acceptance誤寫成runtime capability完成。

## Review criteria

1. Audit evidence是否足以支持Milestone promotion。
2. Provider策略是否有替代方案與trade-off。
3. Architecture boundary是否維持App-only Composition Root。
4. Expected Failure、unknown error與fatal routing是否一致。
5. Privacy、PII、consent、retention是否有明確scope。
6. Android mapping、iOS dSYM、CI secrets與distribution boundary是否完整。
7. Goals、non-goals、acceptance criteria與deferred scope是否可執行。
8. Current authority與navigation是否同步。

## Findings

### P0

無。

### P1-1 — Roadmap candidate scope仍過度狹窄

`docs/roadmap/candidates.md`目前仍以「Production Error Reporting Adapter」描述候選，只提到加入例如Firebase Crashlytics的adapter。

這無法承載已核准設計中的release identity、privacy、symbol pipeline、adapter resilience、CI secrets與remote acceptance。若不修正，後續agent可能把Milestone誤解為單一dependency integration。

Disposition：更新candidate名稱、scope、recommended provider strategy、non-goals與audit/design routing；仍不直接把Milestone標為active implementation。

### P1-2 — App README存在production composition overclaim

`apps/flutter_architecture/README.md`將「Debug／production error reporter composition」列為現有App-owned adapter，但source目前所有environment均建立`DebugErrorReporter`，沒有production remote adapter。

Disposition：修正為「ErrorReporter composition seam與Debug adapter；production remote adapter仍待Milestone 27」。

### P1-3 — Current next-action routing未指向已完成的audit/design

`docs/roadmap/active.md`只保留generic candidate review流程，沒有指出Production Observability已完成capability audit與architecture design，下一步是implementation plan／planning promotion，而不是重新做同一份scope discovery。

Disposition：補充latest approved candidate與artifact links；維持active milestone為None，避免在尚無implementation plan時誤宣稱已進入執行。

### P2-1 — Audit index缺少design review route

Audit index已指向capability audit，但尚未指向本formal design review。

Disposition：re-review closure時加入routing。

## Architecture review result

### Accepted decisions

- Production Observability是目前最合理的下一個Milestone。
- 使用provider-neutral App-owned contract與單一Firebase Crashlytics reference adapter。
- 不同時導入Sentry。
- 新增獨立Production Observability ADR；ADR-020維持Exception／Failure分類authority。
- App仍是唯一Composition Root；Package／Feature不得直接依賴provider SDK。
- Analytics與Observability分離。
- Anonymous-by-default，不設定provider user id。
- Provider failure不得影響App原始error flow或造成recursive crash。
- Android mapping與iOS dSYM可在verification-only、未簽署Store pipeline前先建立；Store distribution evidence defer。
- Connectivity state、retry queue與network breadcrumbs defer至Connectivity and Offline State Foundation。

### Rejected alternatives

- 只建立provider-neutral abstraction、不導入reference adapter：缺少production evidence。
- 同時導入Crashlytics與Sentry：增加native、privacy、CI與maintenance scope，沒有必要證據。
- 將reporter放入`packages/core`：會讓App lifecycle、environment與provider ownership污染reusable package boundary。
- 將所有typed Failure上報：會製造noise並違反ADR-020 operational failure policy。

## Gate status before fixes

```txt
Open P0: 0
Open P1: 3
Open P2: 1
Formal disposition: CHANGES REQUIRED
```

完成上述文件authority與navigation修正後，必須重新執行：

- `dart run melos run docs_check`。
- `git diff --check`。
- roadmap／candidate／App README semantic re-review。

在Open P0／P1歸零前，不得把本review改為accepted，也不得開始production source implementation。
