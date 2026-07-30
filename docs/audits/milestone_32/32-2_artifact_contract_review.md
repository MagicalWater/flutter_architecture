---
document_type: phase-review
status: completed
authoritative_for:
  - milestone-32-task-1-artifact-authority-review
  - milestone-32-task-2-artifact-contract-review
last_reviewed_baseline: 1.13.0
---

# Milestone 32 — Tasks 1–2 Artifact Authority and Contract Review

## Task Scope

本Task只建立durable architecture authority：

```txt
docs/adr/adr-023-repository-ci-quality-gates-android-verification-artifact.md
docs/roadmap/active.md
```

不建立production tooling、不修改workflow、不建立`CI_ARTIFACT_ROOT`、不修改`CI_EXECUTION_MODE`，也不刪除GitHub artifacts或caches。

## Focused Review

逐項核對accepted Design與Plan後，Task 1將下列contract寫入ADR-023：

- GitHub Actions只擁有control plane、checks、logs與summary。
- `manual-local`／`self-hosted`由external managed local store擁有artifact。
- Self-hosted禁止`actions/upload-artifact`與`actions/cache`。
- `github-hosted`的repository default remote transport為`none`，例外只能由manual dispatch明確選擇。
- Root不得位於repository、worktree、runner `_work`、temp、filesystem root或home root。
- Job-level atomic manifest與run-level aggregation不可互相覆蓋。
- Manifest採allowlist，不保存完整environment、credential或provider config。
- Retention同時使用age、count、capacity與minimum-free-space，pin必須有期限。
- Local cleanup採dry-run、manifest integrity、trash與restore boundary。
- GitHub cleanup使用exact IDs，且需要獨立review與使用者approval。

## Findings and Fixes

| Finding | Severity | Fix |
|---|---|---|
| ADR原本把cache描述為一般可用加速層，與新self-hosted／repository-default禁用政策衝突 | P1 | 改為self-hosted與repository-default github-hosted不使用Actions cache，未來例外需獨立review |
| ADR原本描述iOS失敗時直接上傳diagnostics，可能被解讀為所有mode預設remote upload | P1 | 改為local store／logs預設，僅manual explicit github-hosted bounded diagnostics可例外上傳 |
| 只記「本機artifact」不足以治理multi-job與cleanup safety | P1 | 補入job atomic publish、run aggregation、allowlist manifest、age／count／capacity與trash contract |
| GitHub cleanup若只寫在Plan會缺少durable不可逆邊界 | P1 | ADR明確要求exact object IDs、replacement evidence、雙層review與獨立使用者核准 |
| Current inventory數字與個人Mac路徑不屬durable architecture | P2 | ADR不保存artifact count、runner ID、absolute operator path或deletion object ID |

修正後沒有open P0或未處置P1。

## Fresh Focused Re-review

- 三種execution mode仍維持互斥，沒有新增第四種mode。
- GitHub control plane與local artifact ownership責任互斥且可追溯。
- Root、manifest、retention與cleanup contract足以支撐Tasks 2–4。
- Workflow仍只擁有routing與transport，不承擔平行schema。
- GitHub-hosted保留人工例外能力，但push／PR不會隱式增加storage。
- Secret、provider config與完整environment仍被排除。
- Production signing、Store publishing、remote object storage與Branch Protection settings沒有進入scope。

## Whole-Task Review

以完整authority chain重新檢查：

```txt
accepted Design
→ accepted Plan
→ ADR-023 durable contract
→ Task 2 root／schema implementation
→ Task 3 writer／aggregation
→ Task 4 retention／cleanup
```

結果：ADR只保存長期contract，不保存可變runtime inventory；Roadmap只保存目前Task與next gate；本Audit只保存findings與review evidence，沒有形成平行architecture authority。

```txt
Open P0: 0
Open P1 without disposition: 0
```

## Validation

```txt
python tools/docs/check_docs.py .
dart run melos run docs_check
git diff --check
```

Task 1只有文件authority變更，不執行Flutter tests或platform builds。

## Gate

```txt
Task 1 focused review: Passed
Task 1 whole-Task review: Passed
Next Task: Task 2 artifact contract／root resolution／schema validation
Workflow mutation: forbidden until Task 6
GitHub cleanup: forbidden
```

---

## Task 2 Scope

Task 2以TDD建立：

```txt
tools/ci/artifact_contract.py
tools/ci/test_artifact_contract.py
tools/ci/test_shell_portability_contract.py
```

實作只包含root解析／驗證、key sanitization、manifest allowlist與retention constants；不包含writer、run aggregation、cleanup apply、workflow wiring或正式artifact root建立。

## Task 2 TDD Evidence

第一輪RED：

```txt
python -m unittest tools.ci.test_artifact_contract -v
→ ModuleNotFoundError: tools.ci.artifact_contract
```

建立最小implementation後，focused suite首次GREEN為25項。Fresh focused review再新增兩組安全RED：

```txt
schema_version=True不得被當成1
C:/absolute與C:drive-relative不得被當成安全relative artifact path
```

兩項均先確認失敗，再修正為strict integer schema與cross-platform drive prefix rejection；最終focused suite為25項PASS。

## Task 2 Focused Findings and Fixes

| Finding | Severity | Fix |
|---|---|---|
| POSIX `PurePosixPath`會把`C:/...`與`C:relative`視為非absolute，跨平台store可能接受Windows drive path | P1 | 明確拒絕`^[A-Za-z]:`，並以RED／GREEN覆蓋absolute與drive-relative兩種形式 |
| Python中`True == 1`，只比較schema value會誤接受boolean | P1 | `schema_version`要求`int`且排除`bool`，再比對`SCHEMA_VERSION` |
| Artifact root若含symlink component，canonical path可能跳離operator預期位置 | P1 | 在resolve前逐component拒絕symlink，並保留repository／runner work／temp canonical descendant檢查 |
| Manifest若只檢查top-level allowlist，secret-bearing nested field仍可能進入cleanup或artifact metadata | P1 | 對全部mapping／sequence遞迴掃描`SECRET_FIELD_PATTERNS`，再執行各層allowlist |
| Python 3.10 union annotation會破壞既有Python 3.9 runner | P1 | Production介面使用`typing.Optional`／`typing.Mapping`，portability contract禁止`| None` |
| 額外full CI discovery在目前Windows host有3項baseline harness失敗 | P2 | Root cause確認為`python3`指向Windows Store stub（9009）及`bash`指向WSL而未轉換Windows absolute path；相關tests／scripts相對Task 1 commit無diff，不在Task 2越界修改，Task 8／9於支援host執行完整suite |

修正後沒有open P0或未處置P1。

## Task 2 Fresh Re-review

- `resolve_artifact_root`在self-hosted缺值時fail closed。
- Windows與POSIX manual-local defaults符合accepted Design。
- `validate_artifact_root`拒絕relative、repository／worktree descendant、runner work、runner temp、filesystem root、home root、`..`與symlink component。
- `sanitize_key`只輸出小寫ASCII安全key，空值與traversal拒絕。
- `validate_job_manifest`要求schema 1、40字元commit SHA、sanitized run／job key、合法execution mode、safe relative artifact path、64字元SHA-256及已核准retention class。
- Manifest nested unknown／secret-bearing field被拒絕；完整environment與provider config沒有入口。
- `RETENTION_CLASSES`精確保存7／14／3／30天、3／10／2／3 count及bounded 90天pin。
- 沒有新增writer、cleanup、workflow或artifact directory side effect。

## Task 2 Whole-Task Review

完整資料流檢查：

```txt
operator／workflow input
→ resolve_artifact_root
→ validate_artifact_root
→ sanitize run／job keys
→ validate allowlist manifest
→ Task 3 atomic writer
```

Task 2只提供pure contract functions與constants，沒有隱式I/O、目錄建立、GitHub API或environment dump。介面名稱與accepted Plan完全一致，足以供Task 3直接消費。

```txt
Open P0: 0
Open P1 without disposition: 0
```

## Task 2 Validation

```txt
python -m unittest tools.ci.test_artifact_contract tools.ci.test_shell_portability_contract -v
→ 25 tests PASS

python -m compileall -q tools/ci/artifact_contract.py tools/ci/test_artifact_contract.py
→ PASS

Task 2 interface and retention scan
→ PASS

CI contract regression excluding 3 proven baseline Windows host harness tests
→ 108 tests PASS
```

Task 2 completion gate仍需documentation check與`git diff --check` fresh通過後才可提交。

## Task 2 Gate

```txt
Task 2 focused review: Passed
Task 2 whole-Task review: Passed
Next Task: Task 3 atomic writer／checksums／run aggregation
Workflow mutation: forbidden until Task 6
GitHub cleanup: forbidden
```
