---
document_type: runtime-evidence
status: completed
authoritative_for:
  - milestone-32-task-8-operations-and-runtime-readiness-evidence
last_reviewed_baseline: 1.13.0
---

# Milestone 32 Task 8 — Operations and Runtime Readiness Review

## Scope

本文件保存Task 8的operator operations guide、完整static regression、Windows portability finding、managed quality suite與後續Task 9 runtime acceptance入口。

Task 8不建立正式Mac operator artifact root、不修改`CI_EXECUTION_MODE`，也不刪除任何GitHub artifact或cache。

## Operator guide review

`docs/guides/ci_cd_operations.md`已同步Tasks 1–7的current contract：

- `manual-local`／`self-hosted`以checkout外managed local artifact store保存成功、失敗、platform與Observability raw evidence。
- `github-hosted`只保留manual explicit `none`／`failure-only`／`full`transport。
- 文件提供Windows、POSIX與Mac self-hosted的`CI_ARTIFACT_ROOT`設定。
- 文件提供run／job manifest查詢、checksum、pin／unpin、cleanup evaluate／apply／restore／purge與runner offline fallback。
- Operator不得使用`rm -rf`、`Remove-Item -Recurse`、`shutil.rmtree`或parent traversal直接清理store；只能使用exact root與`tools/ci/artifact_cleanup.py`manifest流程。

## Operator safety incident and disposition

Task 8 checksum smoke完成後，曾使用repository contract外的ad hoc Python cleanup，並錯誤地把artifact root的父目錄向上取兩層後傳入recursive delete。目標因此從預期的test artifact root擴大為Windows使用者的`AppData\\Local`。操作在AMD仍占用的cache檔案處因`PermissionError`停止。

立即處置：

1. 停止Task 8所有mutation與cleanup。
2. 只讀盤點repository、toolchain、AMD、AdsPower與受影響路徑。
3. 告知使用者exact root cause與已知／未知影響。
4. 使用者保存資料並重新啟動Windows；重開後未發現應用或資料異常。
5. 重開後再次只讀確認repository HEAD、AMD Radeon state與AdsPower profile仍存在且持續重建。
6. 不再清除剩餘test artifact root；Task 8後續禁止任何workspace外直接filesystem cleanup。

Root cause不是`artifact_cleanup.py`的path validation、manifest apply或trash restore contract；事故來自繞過正式CLI的ad hoc cleanup。Corrective action是把「所有store cleanup只能使用正式CLI」提升為operator guide硬性規則，並保留本紀錄作為Task 8 review evidence。

## Windows shell portability finding

### Finding

首次完整static regression中，183個CI contracts通過，但：

```txt
bash -n tools/ci/build_android_environment.sh
```

因CRLF在第26行失敗。只讀調查確認Windows worktree使用`core.autocrlf=true`，repository沒有`.gitattributes`，多數tracked `*.sh`因此checkout為`w/crlf`。

### RED／GREEN

先新增`ShellPortabilityContractTest.test_repository_forces_lf_for_shell_scripts`。在`.gitattributes`不存在時fresh RED；新增：

```gitattributes
*.sh text eol=lf
```

並將目前tracked shell scripts重新落成LF後，focused test與全部named `bash -n` checks通過。所有tracked shell scripts的`git ls-files --eol`結果均為：

```txt
i/lf w/lf attr/text eol=lf
```

## Static regression evidence

2026-07-30（Asia/Taipei）fresh執行：

```bash
python -m unittest discover -s tools/ci -p "test_*.py" -v
bash -n tools/ci/run_local_ci.sh
bash -n tools/ci/build_android_environment.sh
bash -n tools/ci/build_ios_environment.sh
bash -n tools/ci/cleanup_ci_secrets.sh
actionlint -shellcheck=
python tools/docs/check_docs.py .
dart run melos run docs_check
git diff --check
```

結果：

```txt
CI contract tests: 184 passed
Tracked shell LF contract: passed
Named shell syntax checks: passed
actionlint 1.7.12: passed
Documentation checks: passed
git diff --check: passed
```

重開機後發現原本位於使用者local tool path的`actionlint.exe`已不存在；依前一Task使用的exact version `1.7.12`從官方release重新安裝後，workflow lint通過。這是host tool restoration，不是降低validation。

## Managed quality suite

在clean Task 8 commit `fe21742fb905b1f6e5f2416f4c17b812cf85be48`上，以Windows Git Bash與exact existing validation root執行：

```bash
bash tools/ci/run_local_ci.sh quality
```

第一次由`C:\\Windows\\System32\\bash.exe`解析到WSL bash，因Windows Git worktree的`.git`指向`D:/Developer/.../.git/worktrees/...`而在job begin前失敗；沒有finalized job。改用`C:\\Program Files\\Git\\bin\\bash.exe`後fresh重跑成功。Operator guide已加入Windows Git Bash硬性入口。

成功run：

```txt
run_key: local-20260730t103328z-400-fab390e2
commit_sha: fe21742fb905b1f6e5f2416f4c17b812cf85be48
execution_mode: manual-local
host: windows
run_result: success
job_count: 1
job_key: quality-windows
job_result: success
evidence_status: complete
retention_class: verification-success
cleanup_status: retained
```

Fresh quality coverage：

```txt
Dependency resolution: passed
Documentation checks: passed
CI contract tests: 184 passed
Five-package analyze: passed
Generated consistency: passed
Flutter tests (api_client, design_system, core, auth, app): passed
git diff --check: passed
Managed run aggregation: passed
Retention dry evaluation: passed
```

Checksum verification從job directory執行：

```txt
artifacts/quality/quality-result.txt: OK
manifest.json: OK
summary.md: OK
```

Quality run未執行cleanup apply、restore或purge，現有validation root亦未手動刪除。

## Current gate

```txt
Task 8 focused review: Passed
Task 8 whole-Task review: Passed
Official Mac operator root: Not created
CI_EXECUTION_MODE: Unchanged
GitHub artifact/cache deletion: Forbidden
Next gate: Task 9 Windows／Mac／self-hosted runtime acceptance
```
