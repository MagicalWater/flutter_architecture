---
document_type: phase-review
status: completed
authoritative_for:
  - milestone-32-task-6-workflow-transport-review
last_reviewed_baseline: 1.13.0
---

# Milestone 32 — Task 6 Workflow Transport Review

## Task Scope

本Task將四份GitHub Actions workflows切換為local-first artifact transport：

```txt
.github/workflows/ci.yml
.github/workflows/android.yml
.github/workflows/ios.yml
.github/workflows/observability-acceptance.yml
```

同時建立：

```txt
tools/ci/artifact_transport.py
tools/ci/test_artifact_workflow_contract.py
```

並擴充`run_local_ci.sh`與`artifact_store.py`，使self-hosted jobs只負責atomic job finalize，整個run則由所有managed jobs完成後的summary job統一aggregate、執行cleanup dry evaluation並寫入GitHub Step Summary。

本Task沒有修改repository variable `CI_EXECUTION_MODE`、沒有建立正式operator artifact root、沒有執行任何GitHub artifact／cache刪除，也沒有觸發正式remote workflow run。

## TDD Evidence

### RED

- Self-hosted workflows仍包含`actions/upload-artifact`可達路徑。
- GitHub-hosted workflows仍使用`actions/cache`。
- `repository-default`尚未明確等價於`none`。
- `failure-only`缺少25 MiB總量、檔案類型與敏感檔案preflight。
- `full`缺少一天retention與storage warning。
- Self-hosted若缺少`CI_ARTIFACT_ROOT`會回退manual-local預設路徑。
- 多個GitHub jobs共用同一run key時，各job finalize後立即aggregate，會被其他active job lock阻擋。
- GitHub summary缺少manifest SHA-256與retention class。
- Managed CI內層`python -m unittest`換行缺少shell續行符。
- Observability managed command沒有穩定保存job artifact root，且部分環境變數沒有投影到子process。
- `full`transport仍可能接受provider config、service account、keystore、Apple private key與provisioning material。
- `full`transport在所有指定路徑皆不存在時仍回傳成功。

所有RED均先由Python contract test、actionlint、fresh shell inspection或bounded runtime smoke重現，再進入修正。

### GREEN

Workflow transport matrix固定為：

```txt
self-hosted + any supported event
  => local managed store only
  => no actions/cache
  => no actions/upload-artifact

github-hosted + pull_request／push
  => artifact_transport=none

workflow_dispatch + repository-default／none
  => no remote artifact

workflow_dispatch + failure-only
  => bounded text／JSON／Markdown／selected golden PNG
  => <= 25 MiB per preflight set
  => 7-day retention

workflow_dispatch + full
  => explicit manual request only
  => GitHub storage warning
  => 1-day retention
  => provider config／credential／signing material仍永遠禁止
```

Self-hosted jobs現在明確設定：

```txt
CI_MANAGED_EXECUTION_MODE=self-hosted
CI_ARTIFACT_ROOT=${{ vars.CI_ARTIFACT_ROOT }}
CI_RUN_KEY=gh-<run-id>-<run-attempt>
```

若root缺失，resolver以self-hosted contract fail closed，不會回退到manual-local path。

Job與run lifecycle分離為：

```txt
managed job
→ begin
→ primary command
→ finalize job
→ job GitHub summary

all managed jobs complete
→ dedicated summary job
→ aggregate run
→ cleanup dry evaluation
→ run GitHub summary
```

## Focused Findings and Fixes

| Finding | Severity | Fix |
|---|---|---|
| Self-hosted root resolver固定使用`manual-local` | P1 | 加入`CI_MANAGED_EXECUTION_MODE`，self-hosted缺root立即fail closed |
| 每個job立即aggregate會與其他active jobs衝突 | P1 | Job wrapper只finalize；CI／Android／iOS／Observability summary jobs統一aggregate |
| Manual-local移除per-job aggregate後可能失去既有行為 | P1 | Single suite與`all`在local entrypoint結束時仍aggregate，且primary failure優先於aggregate failure |
| CI managed unittest換行會把module名稱當shell command | P1 | 所有module arguments加入明確shell續行符 |
| Observability子command未保留穩定artifact root | P1 | 使用`managed_artifact_dir`，所有platform output與evidence均由該root派生 |
| Observability環境變數只成為shell variable，未傳給build process | P1 | 使用同一command的inline environment projection與續行符 |
| GitHub job summary缺manifest hash與retention | P1 | `write-summary`以published manifest計算SHA-256並顯示retention class |
| `full`可攜出provider config或signing material | P1 | 兩種remote transport共用always-denied policy，拒絕provider config、service account、keystore、`.p8`、`.p12`、`.pem`、`.key`與`.mobileprovision` |
| `full`全部路徑缺失仍通過preflight | P1 | Full transport要求至少一個實際regular file |
| Summary job直接array形式的custom runner labels被actionlint視為未知 | P2 | 與既有workflow一致改用`fromJSON` self-hosted label set |

修正後：

```txt
Open P0: 0
Open P1 without disposition: 0
```

## Bounded Runtime Evidence

使用repository外的temporary artifact root驗證同一GitHub-style run key可安全產生兩個jobs：

```txt
run key: gh-900-1
job keys: smoke-one / smoke-two
job finalize: passed
run aggregation: passed
job count: 2
run result: success
```

另以`CI_MANAGED_EXECUTION_MODE=self-hosted`且不提供`CI_ARTIFACT_ROOT`執行bounded command：

```txt
result: failed before primary command
error: CI_ARTIFACT_ROOT is required for self-hosted execution
```

Temporary root與smoke evidence驗證後已移除；這不是正式operator root或release runtime evidence。

## Fresh Focused Re-review

- 四份workflow均暴露相同`artifact_transport`choice。
- `repository-default`不會產生remote artifact。
- 非manual event無法進入remote upload step。
- 所有remote upload step均要求`workflow_dispatch`、GitHub-hosted runner與明確transport。
- 所有upload前均執行repository-owned preflight。
- Self-hosted jobs不使用Actions cache，也不進入任何upload-artifact step。
- Full artifact固定一天retention並顯示storage warning。
- Failure-only只接受bounded diagnostics與指定golden PNG，拒絕APK、AAB、IPA、`.app`、dSYM、symbols、mapping與敏感設定。
- GitHub summary包含execution mode、commit、run／job key、primary result、evidence result、retention、manifest SHA-256、count、bytes與local-only聲明。
- Summary aggregation在all managed jobs完成後執行，不再與active locks競爭。
- Manual-local既有single suite與`all`路線仍會完成run aggregation。

## Whole-Task Review

完整資料流重新核對：

```txt
event／execution mode resolution
→ runner selection
→ transport resolution
→ self-hosted external root fail-closed validation
→ managed job begin／primary／finalize
→ local-only job summary
→ all-needs summary job
→ run aggregation
→ cleanup dry evaluation
→ local-only run summary

or explicit github-hosted manual exception
→ repository-owned preflight
→ allowlist／always-denied／size checks
→ one-day full or seven-day failure-only upload
```

Task 6完成workflow transport policy切換，但尚未完成Task 7的Observability controlled-event default、failure evidence更深層secret scan與正式runtime acceptance。

## Validation

```txt
python -m unittest discover -s tools/ci -p "test_*.py"
Result: 168 passed

python -m py_compile artifact／transport／cleanup tooling
Result: passed

Git Bash -n tools/ci/run_local_ci.sh
Git Bash -n platform build scripts
Result: passed

PyYAML parse all workflow files
Result: passed

actionlint v1.7.12 -shellcheck=
Result: passed

two-job managed run smoke
self-hosted missing-root smoke
Result: passed

python tools/docs/check_docs.py .
dart run melos run docs_check
git diff --check
Result: passed
```

## Gate

```txt
Task 6 focused review: Passed
Task 6 whole-Task review: Passed
Workflow transport cutover implementation: Completed locally
CI_EXECUTION_MODE mutation: Not performed
Official operator artifact root: Not created
GitHub artifacts／caches deletion: Forbidden
Next Task: Task 7 Observability and bounded failure evidence
```
