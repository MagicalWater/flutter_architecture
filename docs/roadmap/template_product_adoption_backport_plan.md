---
document_type: implementation-plan
status: accepted
authoritative_for:
  - template-product-adoption-backport-implementation-plan
last_reviewed_baseline: 1.26.1
---

# Template → Product Adoption Backport — Implementation Plan

## 1. Plan intent

本 Plan 實作已 accepted 的 `template_product_adoption_backport_design.md`，目標不是逐一關閉 TA-001～TA-009，而是將其收斂成四個 corrective domains，修正 Template → Product adoption 的 stable authority、tooling 與 verification contract。

Implementation 必須遵守：

- 不修改 `D:\Developer\wl-ai-badminton-app`；產品 repository 只作 evidence source。
- 不新增第三份 repository-wide adoption manifest。
- 不新增 persistent `bootstrapping` lifecycle state。
- 不將 native product identity 放入 `repository_identity.json`。
- 不建立 per-TA ADR、per-TA verifier 或 per-TA permanent tests。
- 不做全文字 `flutter_architecture` replace。
- 不 push，除非使用者另行明確核准。

## 2. Implementation sequence

### Stage 1 — Atomic repository lifecycle correction

Scope：TA-002 + TA-005 的 repository lifecycle 部分。

#### Files expected

- `docs/adr/adr-030-template-to-product-repository-identity-bootstrap-contract.md`
- `.agents/skills/adopting-template-repository/SKILL.md`
- `docs/guides/template_repository_adoption.md`
- `tools/docs/verify_repository_identity.py`
- focused verifier tests（若 lowest-sufficient test authoring decision 判定 Required）

#### Implementation decisions

1. 保留 canonical persistent states 僅 `template | product`。
2. Prospective product validation 不再要求先覆寫 canonical template `VERSION`。
3. `verify_repository_identity.py` 必須支援 prospective candidate identity + candidate product VERSION 一起驗證，而 canonical template state仍維持 `VERSION == template_origin.baseline`。
4. Final transition 採原子寫入語意：

```txt
candidate identity + candidate product VERSION validation
→ required tracked/live acceptance PASS
→ write product VERSION + product repository_identity
→ immediate canonical re-verify
```

5. 明確定義 repository 已 product 化但 Native Product Identity 仍 Pending 為合法狀態；repository identity verifier 不推斷 native readiness。

#### Validation

- canonical template identity PASS。
- prospective product candidate + product VERSION PASS。
- candidate product VERSION 不得污染 canonical template `VERSION`。
- malformed / unknown / invariant mismatch 仍 fail closed。

### Stage 2 — Technical identity and residual ownership correction

Scope：TA-001 + TA-003。

#### Files expected

- `docs/adr/adr-030-template-to-product-repository-identity-bootstrap-contract.md`
- `.agents/skills/adopting-template-repository/SKILL.md`
- `docs/guides/template_repository_adoption.md`
- tooling files that currently assume `apps/flutter_architecture` as permanent product locator, only where a concrete migration-safe correction is required

#### Implementation decisions

1. Adoption procedure 在 mutation 前先做 identity ownership classification：

```txt
product-facing
technical/operational
native-placeholder
compatibility-preserved
template-provenance
historical/fixture
```

2. App directory / Dart package / workspace name 必須被明確分類為 product technical identity，而不是漏出 bootstrap scope。
3. Compatibility-owned values，例如 DB filename / channel / Web storage，不因產品 branding 自動改名。
4. Provenance / historical / fixture identity 不因 adoption cleanup 被替換。
5. 不以 generic rename framework 解決；優先讓 repository-owned tooling從 current workspace/app metadata 或明確 bootstrap migration map 取得 locator。
6. 若 app directory rename 會影響 validation planner / classifier / CI script path，必須在同一 Stage 一次性收斂，不留下 mixed locator state。

#### Validation

- fresh productized technical naming scenario 下，repository tooling不再因舊 app path而失效。
- compatibility/provenance identity preservation scenario PASS。
- no blanket replacement behavior。

### Stage 3 — Native identity machine authority and projection correction

Scope：TA-004 + TA-006 + TA-008 + TA-009，以及 TA-005 的 native lifecycle clarity。

#### Files expected

- `apps/flutter_architecture/config/environments.json`
- `docs/adr/adr-025-native-environment-mapping-product-identity-contract.md`
- `.agents/skills/adopting-template-product-identity/SKILL.md`
- `docs/guides/native_environment_adoption.md`
- `tools/ci/verify_environment_contract.py`
- `tools/ci/build_android_environment.sh`
- `tools/ci/build_ios_environment.sh`
- `tools/ci/verify_android_firebase_config.py`
- `tools/ci/verify_ios_firebase_config.py`
- `.github/workflows/observability-acceptance.yml` where product identity is currently hard-coded
- focused verifier tests only where behavior cannot be adequately proven by direct verifier/runtime evidence

#### Schema correction

1. 將 `templateBaseIdentifier` 改為 lifecycle-neutral field name，例如 `baseIdentifier`；具體 final name在 implementation 前以 current schema consumers inventory確認，避免建立 migration ambiguity。
2. Schema version是否需要 bump，依 backward compatibility與current verifier input contract決定；若 tracked manifest schema semantics改變，必須明確 migration / fail-closed behavior。
3. Manifest仍是 concrete identifier/display-name唯一 machine owner。

#### Projection correction

1. Android/iOS build scripts的 expected package/bundle identifier從 manifest resolve，不再硬寫 `com.example.flutterarchitecture`。
2. Firebase config verifier從同一 manifest resolve expected identifier。
3. Observability workflow不硬寫 product-specific `.app` / `.dSYM` 名稱；從 build metadata / discovered artifact / manifest-derived product name取得。
4. ADR-025與Guide不再把 current product mapping concrete values作為第二 authority；template defaults可保留為明確「template example/default」，但 product current truth只由 manifest擁有。

#### Verifier coverage correction

Android至少覆蓋：

- `namespace`
- production `applicationId`
- flavor identifiers
- Kotlin `package` declaration
- `MainActivity.kt` source path與 package一致性
- display name / entrypoint / sentinel mapping

iOS至少覆蓋：

- per-environment `PRODUCT_BUNDLE_IDENTIFIER`
- `APP_DISPLAY_NAME`
- `PRODUCT_NAME`
- Runner target projection
- RunnerTests bundle identifier與product base identity一致性
- scheme / configuration / entrypoint / sentinel mapping

Verifier應驗證 machine-owned semantics，不新增脆弱的 unrelated source-shape assertions。

#### Native Pending contract

Guide/Skill/ADR明確區分：

```txt
Repository Productized
Native Identity Pending
Native Identity Adopted
```

這些是 procedure/evidence disposition，不新增 root repository lifecycle state。

#### Validation

- template default manifest contract PASS。
- rehearsal identifier temporary projection scenario PASS。
- Android development artifact package identity inspection PASS（Windows可執行）。
- iOS：Windows只允許 static projection evidence；macOS available時才執行 real Xcode build acceptance。
- rollback後 template operational residual rehearsal identity = 0。

### Stage 4 — Python runtime portability correction

Scope：TA-007。

#### Files expected

- `tools/ci/run_local_ci.sh`
- `tools/ci/build_android_environment.sh`
- `tools/ci/build_ios_environment.sh`
- optional small shared shell helper only if duplication cannot be eliminated cleanly without it

#### Implementation decisions

1. 一個 repository-owned Python 3 resolver semantics。
2. Respect valid `PYTHON_BIN` override。
3. Probe `python3` / `python` for actual executability，不只 `command -v`。
4. Android/iOS direct build入口與local CI入口一致。
5. 不 tracked machine-specific absolute interpreter path。

#### Validation

- explicit valid override PASS。
- invalid `python3` shim + working `python` fallback PASS。
- no working interpreter → deterministic failure。

### Stage 5 — Fresh adoption acceptance

此 Stage 只在 Stage 1～4 implementation + review完成後執行。

不得修改既有羽球產品 repository；使用 disposable copy / temporary productized checkout / reversible rehearsal方式取得 evidence。

至少驗證：

#### Scenario A — Product repository with Native Identity Pending

```txt
Template baseline
→ product technical naming
→ product docs/version/infrastructure candidate
→ native identity remains template placeholder / explicitly Pending
→ prospective validation
→ final repository product transition
→ fresh no-handoff admission
```

Expected：合法完成 repository productization，不誤稱 native production readiness。

#### Scenario B — Rehearsal Native Identity adoption

```txt
Template/product candidate
→ rehearsal base identifier
→ manifest-first native projection
→ environment verifier
→ Android development artifact build
→ package identity inspection
→ rollback or discard rehearsal checkout
```

Expected：無需手動 grep 才能補齊 operational identity projection。

## 3. Test authoring / retention decision

Permanent test只保留 machine-contract高價值 case：

- repository prospective identity/version validation invariant；
- environment verifier新增的 stable semantic coverage；
- Python resolver behavior（若適合穩定自動化）。

不得為每個 TA 建立獨立 permanent test。

Temporary rehearsal helper / fixtures在 GREEN後必須 Retention Decision；能由 current verifier / real artifact acceptance取代者預設刪除。

## 4. Review gates

每個 Stage完成後只做 focused review；Stage 1～4全部完成後做一次 whole-scope holistic review。

Holistic review至少檢查：

- ADR-030 / ADR-025 ownership是否單一且一致。
- Skill只保留 routing/orchestration，不複製Guide完整procedure。
- Guide與machine verifier沒有 concrete truth drift。
- repository identity與native identity沒有重新耦合。
- tooling沒有新增 generic framework或額外 manifest。
- compatibility/provenance identity沒有被錯誤產品化。
- Open P0 = 0。
- Open P1 without disposition = 0。

## 5. Documentation retention

本 Plan與Design在完成 backport closure後進行 retention decision：

- stable rules吸收到 ADR / Guide / Skill / machine tooling後，不把Design/Plan留作current authority。
- 若最終只剩implementation sequencing value，Delete，交由Git history保存。
- 只有存在獨立重大architecture transition追溯價值時才Archive。

不新增per-Stage永久review文件；material findings可在final review或既有audit mechanism中集中保存。

## 6. Commit / release boundaries

Implementation 可依 coherent corrective domain commit，而不是 per finding commit。建議 commit boundaries：

1. repository lifecycle atomic correction
2. product technical identity ownership correction
3. native identity authority/projection correction
4. runtime portability correction
5. final docs / acceptance closure

在使用者沒有明確核准前：

- 不 push。
- 不發布新 VERSION。
- 不宣稱 backport complete。

## 7. Stop conditions

Implementation中只有以下情況停止並回報使用者：

- 需要改變 accepted Design 的 stable ownership model。
- 發現必須新增第三份 machine authority才能完成。
- 發現 compatibility identity需要 irreversible migration。
- native schema correction造成產品 backward compatibility decision。
- external/manual platform blocker使必要 acceptance無法完成。

一般 test failure、source defect、stale docs或局部 implementation issue直接修正並重驗，不要求額外核准。

