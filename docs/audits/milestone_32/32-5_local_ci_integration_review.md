---
document_type: phase-review
status: completed
authoritative_for:
  - milestone-32-task-5-local-ci-integration-review
last_reviewed_baseline: 1.13.0
---

# Milestone 32 — Task 5 Local CI Integration Review

## Task Scope

本Task將`manual-local` quality與Android／iOS build entrypoints接入Tasks 2–4建立的managed artifact contract：

```txt
tools/ci/run_local_ci.sh
tools/ci/build_android_environment.sh
tools/ci/build_ios_environment.sh
```

同時修復Windows local route中已由fresh runtime evidence確認的Python、Git Bash與Drift schema newline portability blockers。本Task不修改任何GitHub workflow、不修改`CI_EXECUTION_MODE`、不建立正式operator artifact root，也不刪除GitHub artifacts或caches。

## TDD Evidence

### RED

- `run_local_ci.sh`缺少managed begin／finalize／aggregate／cleanup lifecycle。
- Local與platform scripts仍把artifact寫入repository的`artifacts/`。
- Platform scripts未要求external `ARTIFACT_DIR`。
- Windows的`python3`解析到Microsoft Store stub，classifier CLI test回傳9009。
- Windows預設`bash`解析到WSL launcher，Windows absolute path被錯誤傳給Linux shell。
- Direct執行`python tools/ci/artifact_store.py`時缺少repository root import path。
- CLI只接受JSON檔案，shell需建立額外temp file才能傳入allowlist metadata。
- Generated consistency在Windows會受Drift schema JSON字串內CRLF與stat-only status影響。
- Job manifest未投影target `platform`／`environment`／`build_mode`。
- Evidence preparation失敗可能在primary command失敗後提前return，覆蓋原始exit code。

每項RED都先由對應Python contract test或fresh command output重現，再進入implementation。

### GREEN

- `run_local_ci.sh`建立唯一`local-<UTC>-<pid>-<nonce>` run key。
- 每個suite以`run_managed_job`完成begin、primary command、finalize、run aggregation與cleanup dry evaluation。
- `CI_ARTIFACT_ROOT`、`CI_RUN_KEY`、`CI_JOB_KEY`與`CI_RETENTION_CLASS`只投影必要值。
- Primary exit code高於evidence preparation、finalize、aggregate與cleanup failure。
- Android／iOS build scripts要求明確external `ARTIFACT_DIR`，cleanup只作用於該job staging。
- Platform metadata保留`run_key`與`job_key`；job manifest分離host OS與target platform。
- Windows使用目前有效Python interpreter與Git Bash；POSIX仍可使用`python3`／`python`解析。
- Direct CLI支援repository import bootstrap與inline allowlist JSON。
- Drift schema exporter以resolved Python執行JSON semantic newline normalization。
- Generated consistency以content diff與untracked files作判斷，不以line-ending stat noise冒充內容變更。

## Focused Findings and Fixes

| Finding | Severity | Fix |
|---|---|---|
| Dirty implementation worktree無法執行既有generated consistency | P1 | 不放寬clean-tree contract；建立一次性detached clean validation snapshot執行完整quality |
| Manifest只在artifact entry保存platform，操作者查job manifest頂層得到`null` | P1 | 將target `platform`、`environment`、`build_mode`升級為required job metadata與top-level projection |
| Evidence JSON準備失敗可能遮蔽primary command failure | P1 | 分離`evidence_prepare_exit_code`，最終return順序固定primary → evidence prepare → finalize → aggregate → cleanup |
| Root validation只知道repository，未拒絕home root與runner paths | P1 | Manual-local root resolution傳入`Path.home()`、`RUNNER_WORKSPACE`與`RUNNER_TEMP` |
| Android／iOS suite metadata若直接使用host OS會把Windows Android誤標為Windows artifact | P1 | Metadata分離host與target；Android=`android`、iOS=`ios`、Observability=`multiple`、quality=host |
| Windows `python3`為Store stub | P1 | Tests與scripts使用working-interpreter resolver；subprocess tests使用`sys.executable` |
| Windows預設Bash為WSL launcher，無法接受Windows path | P1 | Windows shell contract明確尋找Git Bash並轉換路徑 |
| Drift schema strings內CRLF使clean generated verification產生false diff | P1 | 新增JSON semantic normalizer與deterministic tests，不以文字replace破壞JSON |
| Cleanup fixtures仍使用舊job manifest shape | P1 | 同步top-level target projection fixture後fresh執行全部CI contracts |

修正後Open P0 = 0，Open P1 without disposition = 0。

## Fresh Focused Re-review

- Local scripts不再出現`$repo_root/artifacts`正式輸出路徑。
- Platform scripts缺少`ARTIFACT_DIR`時fail closed。
- Build script cleanup不會刪除整個store、run或其他job目錄。
- Windows不宣稱可執行iOS；`all`在Windows明確skip iOS，explicit `ios`回傳unsupported exit。
- Manifest不序列化完整environment；root、run與job identities均由allowlist建立。
- Job staging、manifest、summary、checksums與run aggregation使用相同external root。
- Task 5沒有提前修改workflow transport policy或Observability controlled-event policy；兩者仍屬Tasks 6–7。

## Clean Managed Quality Acceptance

為保留`verify_generated.sh`的clean-tree安全契約，本Task建立一次性detached validation snapshot：

```txt
snapshot SHA: fff5b60808326fe1485e98a1a3416c8a6efa0026
run key: local-20260730t082412z-902-f68d284e
job key: quality-windows
execution mode: manual-local
artifact transport: local-only
```

該snapshot與artifact root只用於Task 5 bounded validation，不是正式release或長期runtime evidence。Fresh結果：

```txt
Python CI contracts: 151 passed
flutter analyze: all 5 packages passed
generated consistency: passed
Drift schema governance: passed
Flutter tests: api_client 55 / design_system 43 / core 4 / auth 154 / app 463 passed
managed job result: success
evidence status: complete
run aggregation: success / 1 job
checksum entries: 3 / failures 0
target platform: windows
environment: repository
build mode: verification
```

Validation完成後，temporary worktree、patch、log與smoke artifact roots全部移除，不保留為operator store。

## Whole-Task Review

完整資料流重新核對：

```txt
manual-local invocation
→ external root resolution and safety validation
→ unique run／job identity
→ atomic staging and active lock
→ exact suite command
→ bounded artifact output
→ primary result preservation
→ job manifest／summary／checksums
→ atomic publish
→ run aggregation
→ cleanup dry evaluation
```

結果：Task 5完成local producer route，但尚未切換GitHub workflow transport。Current GitHub artifact／cache behavior仍保持不變，必須由Task 6的workflow RED／GREEN與review處理。

```txt
Open P0: 0
Open P1 without disposition: 0
```

## Validation

```txt
python -m unittest discover -s tools/ci -p "test_*.py" -v
Git Bash -n tools/ci/run_local_ci.sh
Git Bash -n tools/ci/build_android_environment.sh
Git Bash -n tools/ci/build_ios_environment.sh
python -m py_compile artifact／cleanup／normalizer tooling
clean detached managed quality run
python tools/docs/check_docs.py .
dart run melos run docs_check
git diff --check
```

## Gate

```txt
Task 5 focused review: Passed
Task 5 whole-Task review: Passed
Next Task: Task 6 workflow transport policy and GitHub summary
Workflow mutation: now allowed only within Task 6
GitHub cleanup: forbidden
```
