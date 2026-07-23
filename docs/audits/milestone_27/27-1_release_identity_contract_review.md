---
document_type: phase-review
status: accepted
authoritative_for:
  - milestone-27-task-1-release-identity-contract-review
last_reviewed_baseline: 1.8.0
---

# Milestone 27 Task 27-1 — Release Identity and Provider-neutral Contracts Review

## Scope

本Review涵蓋Task 27-1新增的App-owned provider-neutral contracts、native package metadata reader、build-time commit metadata、collection policy、provider lifecycle seam、dependency resolution與focused tests。

本Task沒有加入Firebase Core、Crashlytics、Sentry或任何production provider SDK，也沒有改動既有error routing、Flutter／Platform hooks或DI composition。

## Execution evidence

Task依TDD執行：

```txt
新增focused tests
→ 確認因production contract不存在而RED
→ 建立最小implementation
→ focused tests GREEN
→ focused review
→ findings fix
→ re-review
→ whole-task validation
```

## Delivered contracts

- `ReleaseIdentity`：保存environment、native package version／build number、platform、native configuration與optional commit SHA。
- `ReleaseMetadataReader`：App-owned seam；`PackageInfoReleaseMetadataReader`以安裝產物native package metadata作runtime authority。
- `ReleaseBuildMetadata`：`APP_COMMIT_SHA` build-time define；未提供或空白時保持absent，不偽造local SHA。
- `ObservabilityCollectionPolicy`：development／staging／production預設remote collection全部關閉，只有明確construction可啟用。
- `ObservabilityProviderLifecycle`：provider initializer失敗轉為typed unavailable result，不阻止App composition。

## Findings and fixes

| Finding | Severity | Fix |
|---|---|---|
| M27-1-R01 初版Factory直接接受任意`commitSha`字串，未鎖定受控build-time seam | P1 | 新增`ReleaseBuildMetadata.fromEnvironment()`，Factory只接受typed build metadata |
| M27-1-R02 Provider initialization result使用預設`toString()`，未明確保證不展開provider error | P1 | 新增safe `toString()`，只輸出available／hasError／hasStackTrace |
| M27-1-R03 `package_info_plus` 9.x造成Windows transitive dependency downgrade | P1 | 提升至可由目前workspace解析的10.2.1，保留既有`flutter_secure_storage_windows`與`win32`版本 |
| M27-1-R04 初版test誤用non-const constructor作const expression | P2 | 修正test construction並重新確認RED／GREEN |

## Re-review

- Version／build number只有native package metadata一個runtime authority。
- Commit SHA只由`APP_COMMIT_SHA`受控build-time define提供；local缺省維持null。
- 所有environment的default policy均不允許remote collection。
- Provider unavailable result保留原error／stack供App-owned fallback判斷，但safe diagnostic不展開error內容。
- Production contract位於App scope；reusable packages與Feature均未新增dependency或direct call。
- Repository source、tests、pubspec與lockfile均沒有Firebase／Crashlytics／Sentry dependency或import。
- Task 27-1沒有提前實作Task 27-2 routing、Task 27-3 provider adapter或native symbol pipeline。

## Final disposition

```txt
Disposition: ACCEPTED AFTER FIX
Open P0: 0
Open P1: 0
Open P2: 0
Next action: Task 27-2 — Reporting Routing Hardening
```

