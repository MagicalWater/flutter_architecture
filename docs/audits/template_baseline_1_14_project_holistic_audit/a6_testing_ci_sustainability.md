---
document_type: phase-review
status: accepted
authoritative_for:
  - template-baseline-1-14-audit-testing-ci-sustainability-evidence
last_reviewed_baseline: 1.14.0
---

# A6 — Testing and CI Sustainability Audit

## Scope and Decision Rule

本Task對照Testing Governance、CI Operations、Milestone 30／32 evidence、current tests、classifier、四份workflows與managed artifact source，審查coverage ownership、historical boundary、重複／脆弱candidate、execution cost與artifact可維護性。

檔案數、LOC與static cases只作導航；沒有replacement evidence時不得以「測試太多」建立刪除建議。

## Fresh Test Inventory

Current inventory成功輸出至ignored repository temp後取得：

```txt
Tracked test files: 144
Test LOC: 25,732
Static cases: 887
Current: 132
Current with historical fixture: 5
Historical: 6
Historical mixed: 1
Tier 1: 138
Tier 4: 6
```

Primary category：

```txt
Business invariant: 89
CI: 22
Architecture boundary: 10
Implementation contract: 10
Historical-only: 6
Platform: 3
Migration compatibility: 3
Visual: 1
```

Milestone 30 baseline：

```txt
Tracked test files: 136
Test LOC: 22,943
Static cases: 769
```

增量為8個test files、2,789 LOC與118 static cases。八個新增檔案全部屬Milestone 32 artifact／normalizer／GitHub cleanup治理：

```txt
tools/ci/test_artifact_cleanup.py
tools/ci/test_artifact_contract.py
tools/ci/test_artifact_store.py
tools/ci/test_artifact_workflow_contract.py
tools/ci/test_codegen_normalizer_contract.py
tools/ci/test_drift_schema_normalizer.py
tools/ci/test_github_storage_cleanup.py
tools/ci/test_secret_leakage.py
```

沒有tracked test被移除；增量與1.14.0新增CI artifact責任一致，不是無owner擴張。

## Inventory CLI Finding

Accepted Plan要求將fresh inventory輸出到系統temp：

```bat
python tools/testing/inventory.py --root . --output "%TEMP%\flutter_architecture_audit_1_14\test-inventory.csv"
```

Current CLI會先成功寫出CSV，再在summary輸出執行：

```python
output.relative_to(root)
```

當absolute output位於repository root外時，Python拋出`ValueError`並以exit 1結束。這使documented／planned non-tracked temp-output route不可用，形成`F-A6-01`。

Audit-only recovery使用repository內已gitignored的：

```txt
.dart_tool/audit_1_14/test-inventory.csv
```

CLI在此路徑成功回報`files=144 loc=25732 cases=887`；盤點完成後已刪除ignored temp，working tree clean。沒有修改tool或tracked baseline。

## Ownership and Large-file Review

Largest current tests仍集中於明確domain owner：

- Catalog Bloc：query generation、SWR、append、refresh、reconnect與cancellation。
- Auth migration coordinator：secure authority、legacy migration、read-back、rollback與cleanup diagnostics。
- Catalog Repository／LocalDataSource：cache policy、chain revision、cursor、corruption與Drift transaction。
- Auth refresh／persistence：single-flight、safe replay、generation與compensation。
- Artifact store／cleanup：manifest、secret scan、retention、capacity、pin、trash／restore／purge。

這些檔案雖長，但scenario與failure domain不同；A4 fresh tests亦證明其primary owner仍可定位。沒有找到兩個檔案對同一business invariant提供相同failure signal的confirmed duplicate，因此不建立delete／merge finding。

## Current and Historical Boundary

| Area | Current owner | Historical owner | Conclusion |
|---|---|---|---|
| Auth persistence | Secure credential adapter＋Drift AuthUser | SharedPreferences migration與sqflite AuthUser oracle | Current runtime不依賴historical implementation。 |
| Catalog persistence | Drift DAO／LocalDataSource | Historical schema fixtures與sqflite rollback oracle | Historical evidence保留migration／rollback purpose。 |
| Database | AppDatabase v6 current schema | v1～v6 fixtures | Tier 4隔離正確。 |
| CI artifact | Managed local store／workflow contracts | Milestone 32 cleanup evidence | Current source與tests擁有runtime contract。 |
| Documentation | Current docs checker／metadata policy | Historical audits | Historical docs不作current behavior fixture。 |

`sqflite_auth_user_store_test.dart`仍標為`historical-mixed`且Tier 1，因它同時驗證App adapter error semantics；這不是production sqflite ownership。若未來要進一步隔離，需先拆分current adapter contract與historical oracle，不能直接刪除。

## CI Classifier Evidence

Fresh command以initial main baseline `b3c71b6`對Audit HEAD分類：

```txt
docs_only=true
full_ci=false
android_build=false
ios_build=false
release_full=false
reason=documentation only
```

本Audit只新增docs evidence，因此結果符合change-aware contract。完整CI Python suite共202 tests fresh通過，涵蓋：

- Documentation-only stable no-op。
- Dart source full CI。
- Android／iOS native routing。
- Database／historical fail-safe。
- Workflow／classifier source變更。
- Unknown path、invalid range與execution failure fail-safe。
- Manual-local、self-hosted、github-hosted mode validation。

## Workflow Sustainability Review

四份workflow：

```txt
.github/workflows/ci.yml
.github/workflows/android.yml
.github/workflows/ios.yml
.github/workflows/observability-acceptance.yml
```

Current contract review：

- `self-hosted`只允許trusted `main` push與manual dispatch進入repository-scoped Mac labels。
- PR／fork／Dependabot不得進trusted runner；沒有`pull_request_target`。
- Unknown execution mode fail closed，不自動fallback至GitHub-hosted。
- Documentation-only保留stable check／summary語意，不產生平台artifact。
- Workflow共用repository-owned scripts，沒有第二套build implementation。
- Workflow沒有`actions/cache`。
- `actions/upload-artifact`只存在人工`workflow_dispatch + github-hosted + explicit failure-only／full transport`條件。
- Full transport固定1天retention並顯示storage warning；failure-only受25 MiB與allowlist限制。
- Self-hosted path使用`CI_ARTIFACT_ROOT`與`managed-command`，summary明示local-only。

Current GitHub inventory在A5仍為0 objects／0 bytes，證明保留upload action沒有造成implicit storage growth。

## Managed Artifact Store Sustainability

Source與202個CI tests共同覆蓋：

- External root與path traversal／symlink rejection。
- Job／run manifest、SHA-256與atomic publish。
- Allowlist metadata與secret leakage scanner。
- Retention class、age、count、30 GiB default capacity與15 GiB minimum-free-space。
- Limited pin owner／reason／90-day expiry。
- Cleanup dry-run、generation hash與exact manifest apply。
- Atomic move至trash、24-hour restore window與purge gate。
- Active lock／in-progress protection。
- GitHub exact-ID cleanup inventory／manifest／delete分離與再授權要求。

沒有發現parallel retention authority或workflow內自行複製cleanup policy。

## Operator Burden and Accepted Risks

### Single trusted Mac runner

Runner offline時job queued且不fallback，會影響即時性，但可避免非預期GitHub-hosted費用與secret boundary擴張。Manual-local與人工切換mode是明確recovery route。此為ADR-023已接受trade-off，不建立defect finding。

### Local artifact availability

Managed store只在owner host可取用，不是遠端下載服務。Current single-owner workflow下可接受；當出現多協作者、host replacement或disaster recovery需求時，才重新評估R2／S3／NAS。現階段不建立generic remote store。

### Test execution cost

138個Tier 1 files代表source變更會執行廣泛deterministic regression；change-aware classifier已避免docs-only成本。A9會量測full repository validation，若runtime超出可操作範圍才形成future optimization evidence。本Task沒有以test count推導成本缺陷。

## Findings and Non-findings

### Confirmed

- `F-A6-01`：Inventory CLI不支援repository外absolute output，與Plan／可重用CLI預期不一致。

### Not confirmed

- 沒有confirmed duplicate test owner。
- 沒有test依賴historical production implementation。
- 沒有classifier defect。
- 沒有self-hosted remote artifact leakage。
- 沒有GitHub cache dependency。
- 沒有current GitHub storage growth。

## Fresh Validation

```txt
Inventory CLI inside ignored repository temp: passed
Inventory unit tests: 4 passed
Repository CI contracts: 202 passed
Classifier current Audit diff: documentation only
GitHub storage: 0 objects / 0 bytes
Working tree after temp cleanup: clean
```

## Whole-Task Review

- Inventory差異有owner解釋，未作機械刪除建議。
- Large tests以scenario responsibility審查，不只看LOC。
- Historical boundary逐area確認。
- Upload actions以condition與contract tests判讀，未因字串存在誤判。
- Self-hosted與artifact operational burden皆有explicit disposition。
- `F-A6-01`具exact reproduction、source line、risk與bounded remediation route。
- 沒有修改tests、CI、workflow或artifact source。

## Task Disposition

```txt
Current test files reviewed: 144
Current static cases: 887
CI contract tests: 202 passed
Confirmed findings added: F-A6-01
Open P0: 0
Open P1 without disposition: 0
Task A6: ACCEPTED
```
