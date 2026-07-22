---
document_type: phase-review
status: completed
authoritative_for:
  - milestone-26-task-26-1-environment-contract-review
last_reviewed_baseline: 1.7.0
---

# Milestone 26-1 — Environment Mapping Contract Review

## Scope

本Task建立repository-owned environment mapping manifest、path-specific static verifier、focused tests與canonical ADR-025。未修改Android Gradle、Android Manifest、Xcode project、xcconfig、shared scheme或CI workflow。

## Implemented Contract

Authority檔案：

```txt
apps/flutter_architecture/config/environments.json
```

Contract固定三個ordered environment：

| Environment | Android flavor | iOS scheme | Dart entrypoint | Identifier |
|---|---|---|---|---|
| development | `development` | `Development` | `lib/main_development.dart` | `com.example.flutterarchitecture.development` |
| staging | `staging` | `Staging` | `lib/main_staging.dart` | `com.example.flutterarchitecture.staging` |
| production | `production` | `Production` | `lib/main_production.dart` | `com.example.flutterarchitecture` |

Manifest只保存mapping所需值，不包含signing、secret、Apple Team、certificate、provisioning或API endpoint。

## TDD Evidence

第一輪RED：

```txt
ModuleNotFoundError: No module named 'tools.ci.verify_environment_contract'
```

加入最小manifest與verifier後，6個focused tests通過。

Self-review發現development／staging精確suffix只由manifest sample表達，verifier尚未阻止`.dev`等漂移。新增focused regression test後先得到預期FAIL，再補上approved suffix enforcement；最終7個tests全部通過。

## Verification Coverage

`verify_environment_contract.py`驗證：

- root與environment object只允許明確schema fields。
- schema version與Android flavor dimension。
- exactly three且固定順序的environment names。
- flavor、scheme、entrypoint與兩平台identifier唯一。
- entrypoint命名與environment一致。
- development／staging使用精確suffix，production不得有suffix。
- identifier符合reverse-domain格式。
- 三個Dart entrypoint實際存在並bootstrap正確`AppEnvironment`。
- `lib/main.dart`維持development compatibility入口。
- `AppEnvironment`包含三個正式member。
- 所有error包含可定位的contract path。

## Findings and Disposition

| Finding | Severity | Disposition |
|---|---:|---|
| M26-1-R01 Manifest若允許額外field，可能逐步混入signing或另一套runtime config authority | P1 | Verifier採exact-field schema；tests另掃描signing／secret相關field |
| M26-1-R02 Development／staging identifier只驗證unique不足以保證approved suffix | P1 | 新增精確`.development`／`.staging`suffix驗證與regression test |
| M26-1-R03 Static manifest可能與Dart entrypoint或enum漂移 | P1 | Verifier讀取實際source並檢查entrypoint bootstrap與enum members |
| M26-1-R04 Manifest重複兩平台完整identifier，產品採用時需同步修改 | P2 | 保留明確projection值以利review；verifier強制其由同一base identifier與suffix推導 |
| M26-1-R05 本Task尚未驗證Gradle／Xcode projection | P2 | 依scope分別由Task 26-2與26-3擴充同一verifier |
| M26-1-R06 ADR coverage checker仍以ADR-024為硬編碼上限，canonical ADR-025使docs check失敗 | P1 | 先新增要求ADR-025的failing regression，再將coverage authority擴充至ADR-025 |

Open P0／P1：0。

## Validation

```txt
python3 -m unittest tools.ci.test_environment_contract
7 tests passed

python3 tools/ci/verify_environment_contract.py
Environment mapping contract verified.

python3 -m unittest tools.docs.test_check_docs.DocumentationCheckerTest.test_requires_adr_025_after_cutover
1 test passed

dart run melos run docs_check
Documentation check passed.

git diff --check
Passed.
```

## Architecture Decision Disposition

Verifier evidence已成立，ADR-025由planning draft轉為Accepted canonical record：

```txt
docs/adr/adr-025-native-environment-mapping-product-identity-contract.md
```

## Rollback Boundary

本Task只新增manifest、Python verifier／tests、ADR與review文件。若contract設計需要撤回，可整體revert本Task，不影響現有Android或iOS build；後續platform projection尚未開始。

## Final Disposition

Task 26-1完成implement、self-review、findings、fix、re-review與focused validation。Open P0／P1為0，可進入repository final validation與commit gate。
