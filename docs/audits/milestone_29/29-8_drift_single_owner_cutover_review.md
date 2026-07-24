---
document_type: phase-review
status: accepted
authoritative_for:
  - milestone-29-task-29-8-review-evidence
last_reviewed_baseline: 1.10.0
---

# Task 29-8 — Drift Single-owner Cutover Review

## Scope

將production Composition Root一次切換為單一`AppDatabase`，移除sqflite production authority、legacy assets與runtime dependencies，保留test-only historical compatibility harness。

## Implemented

- Composition Root pre-resolve單一`AppDatabase` singleton。
- AuthUser改用`AuthUserDao`／`DriftAuthUserStore`。
- Catalog改用`DriftCatalogCacheDao`。
- Bootstrap移除sqflite factory initializer。
- Android／iOS透過native bridge解析既有database directory與精確`flutter_architecture.db`。
- 刪除production `AppDatabaseSchema`、sqflite Auth store、Catalog adapter與initializer files。
- sqflite schema／stores／adapter移至`test/support/`，只供historical fixtures與rollback tests。
- 移除`sqflite_common_ffi_web`與`sqflite_sw.js`；sqflite native dependencies降為test-only。
- 新增no-sqflite production authority CI guard。
- 更新ADR-010並同步current authority文件。

## Focused Review Findings

1. Injectable初版未辨識外部注入的`AppDatabase`。Disposition：加入ignore list並由Composition Root明確註冊。
2. Integration smoke仍引用已刪除initializer。Disposition：移除舊initializer call。
3. Drift generated `AuthUser`與domain entity名稱衝突。Disposition：測試import隱藏generated row type。
4. DI unit tests誤走production path_provider。Disposition：明確注入in-memory `AppDatabase`。
5. Historical tests仍import production sqflite classes。Disposition：建立test-only historical harness並更新imports。

## Focused Re-review

- Production `lib/`無sqflite import、factory、schema或adapter authority。
- Generated DI graph只有一個外部註冊的`AppDatabase` singleton。
- Auth與Catalog共用同一database instance。
- Historical sqflite code只存在於tests／dev dependencies。
- Web舊worker已移除，Drift worker／Wasm保留。

## Whole-task Review

- Single-owner cutover符合approved Option D，沒有長期雙軌production baseline。
- Native同檔path、v1～v6migration、Auth／Catalog invariants與rollback evidence仍保留。
- Test-only compatibility harness不具production authority。
- Web explicit reset disposition未被改寫為automatic preservation。

## Authority Check

- ADR-010為current canonical database authority。
- ADR index、App README與Auth README已同步。
- CI guard禁止sqflite重新進入production `lib/`。

## Exit Criteria

- Open P0：0。
- Open P1 without disposition：0。
- Task 29-8：accepted。

