---
document_type: phase-review
status: accepted
authoritative_for:
  - milestone-23-task-23-6-batch-e-review
last_reviewed_baseline: 1.5.1
---

# Milestone 23-6 — Batch E Presentation Foundations Review

## Scope

本 Task擷取 ADR-018、019、020，更新 migration-aware index與 manifest。Aggregate `docs/architecture_decisions.md`正文保持不變，正式 authority尚未 cutover。

## Section Disposition

### ADR-018

| Aggregate material | Disposition | Canonical result |
|---|---|---|
| Implementation status／page rollout／golden result | route evidence | 不進 ADR body |
| Design System package ownership | retain | Pure UI foundation；App仍是 Composition Root |
| Theme Identity／Mode | retain | stable identity與 system/light/dark分離 |
| First-version exact theme count | normalize | multi-theme capability retained；release inventory routed README |
| Theme ID／registry | retain | stable value、validation與 fallback |
| Token hierarchy／Material priority | retain | raw palette internal；semantic API public |
| Feature boundary／surfaces | retain | business state先映射成 presentation properties |
| Preference persistence | retain/normalize | App ownership、runtime-first、serialized snapshot與 diagnostic policy |
| Accessibility | retain | text scaling、Semantics、touch target與 narrow viewport |
| Migration sequence／test matrix／non-goals journal | route plan/evidence | 不進 ADR body |

### ADR-019

- App localization ownership、generated resources、supported locale resolution與 selector wiring完整保留。
- Design System與 lower layers不得依賴 App localization完整保留。
- Locale preference runtime-first／serialized writes／bootstrap fallback完整保留。
- `Failure.message` diagnostic-only與 feature-local localized mapping完整保留。
- ARB naming、placeholder與 UTC→local presentation formatting保留。
- Milestone completion、production text audit與 regression journal不進 ADR body。

### ADR-020

- Expected operational failure、unexpected error、cancellation、protocol violation與 lifecycle result五類語意完整保留。
- Typed `AppException`／`Failure`／`Result`與 unknown error stack preservation完整保留。
- DataSource／Repository／UseCase／Bloc／Presentation mapping ownership完整保留。
- Auth lifecycle、cache／preference degraded mode、retry policy owner、reporting adapter與 sensitive-data contract完整保留。
- Milestone 17 audit chronology、implementation phase敘述、382 tests、bundle結果與 Firebase／Crashlytics階段紀錄不進 ADR body；provider-neutral App-owned adapter contract保留。

## Cross-ADR Terminology Review

- ADR-018使用 `Theme Identity`／`Theme Mode`、`Design System`、`blocking`／`non-blocking surface`，與 package README一致。
- ADR-019使用 `Failure identity + operation context → localized copy`，不將 `Failure.message`稱為 UI message。
- ADR-020使用 `expected Failure`、`unexpected error`、`protocol violation`、`Session lifecycle result`，與 ADR-015／016／017一致。
- `App`／`Composition Root`、`Repository`、`DataSource`、`Presentation`大小寫與既有 canonical ADR一致。
- 三份 ADR均未建立 Global Handler、Generic Mapper、Generic Preference或 Generic UI framework。

## Relation Review

- ADR-018與 ADR-003、012、016、017、019、020 relation語意一致。
- ADR-019與 ADR-009、012、018、020 relation語意一致。
- ADR-020與 ADR-013、015–019 relation語意一致；ADR-022尚待 Batch F extraction，僅列 related，不建立 graph edge。
- 本批沒有 supersession relation。

## Link and Compatibility Review

- Related Evidence使用 current package／feature README與既有 plan路徑。
- Current repository routing仍可指向 aggregate，符合 Batch G前 compatibility contract。
- Historical plans、audits與 published CHANGELOG不重寫。
- Aggregate Decision 018–020正文未刪除、未縮減、未轉 stub。

## Validation

```txt
python -m unittest tools.docs.test_check_docs
→ 11 tests passed

dart run melos run docs_check
→ Documentation check passed

git diff --check
→ Passed

git diff --quiet -- docs/architecture_decisions.md
→ Passed；aggregate未修改

ADR index
→ 21 extracted / 1 aggregate

Canonical journal scan
→ 無實作狀態、測試要求、382 test count、bundle result、Milestone 17 phase journal、Crashlytics dependency decision或 Reviewed / Closed journal
```

## Rollback

若 Batch E需要 rollback，revert本 batch commit即可移除三個 canonical ADR、index／manifest更新與本 review；aggregate authority仍完整存在。

## Review Decision

Batch E semantic、terminology、relation、link與 checker gate通過。Open P0／P1：0。
