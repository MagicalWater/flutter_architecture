---
document_type: implementation-plan
status: accepted
authoritative_for:
  - milestone-32-ci-artifact-local-storage-cutover-implementation-plan
last_reviewed_baseline: 1.13.0
---

# Milestone 32 — CI產物本機化與GitHub儲存空間切換 Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 建立Windows／Mac共用的本機managed artifact store，讓`manual-local`與`self-hosted`保留可追溯verification evidence，同時停止日常GitHub Actions artifact／cache storage增長，並在replacement evidence通過後安全清理既有GitHub storage。

**Architecture:** GitHub Actions繼續擁有event、runner routing、checks、logs與summary；repository-owned Python／Bash工具負責artifact root解析、job staging、manifest、checksums、retention、cleanup與GitHub storage deletion manifest。Android／iOS既有build scripts仍擁有platform artifact內容，透過統一job wrapper寫入repository checkout外的managed store，不在workflow YAML建立平行schema。

**Tech Stack:** GitHub Actions YAML、Python 3.9+ standard library、Bash、Python `unittest`、Flutter 3.41.6、Dart 3.11.4、Melos 8、GitHub CLI、macOS self-hosted Actions Runner。

## Global Constraints

- Design authority：`docs/superpowers/specs/2026-07-30-milestone-32-ci-artifact-local-storage-cutover-design.md`，status必須維持`accepted`。
- Implementation開始前，本Plan必須完成完整雙層Task review並取得使用者明確核准。
- `CI_EXECUTION_MODE`長期預設維持`self-hosted`；不得自動fallback至付費`github-hosted`。
- Self-hosted禁止`actions/upload-artifact`與`actions/cache`；GitHub只保存logs與job summary。
- GitHub-hosted的`artifact_transport=repository-default`必須等同`none`；`failure-only`與`full`只允許manual dispatch明確選擇。
- Self-hosted缺少`CI_ARTIFACT_ROOT`時fail closed；不得回退到repository、worktree、runner `_work`、`RUNNER_TEMP`、filesystem root或home root本身。
- Windows manual-local預設root為`%LOCALAPPDATA%/flutter_architecture/ci-artifacts`；POSIX manual-local預設root為`${XDG_STATE_HOME:-$HOME/.local/state}/flutter_architecture/ci-artifacts`。
- Store預設上限為30 GiB，最低剩餘空間為15 GiB；pin最長90天且必須包含owner、reason與`expires_at`。
- Python production tooling必須相容Python 3.9；不得使用`str | None`或其他只有Python 3.10+可用的語法。
- Provider config、service account、token、credential、完整process environment與任意home內容不得進入manifest、summary、diagnostics或artifact store。
- GitHub artifact／cache刪除是不可逆操作，必須在exact ID deletion manifest完成雙層review後再次取得使用者明確核准。
- Production signing、Store publishing、GitHub Release、R2／S3／NAS與Branch Protection settings不屬本Milestone。
- 每個implementation Task都必須完成focused review、finding修正、fresh re-review、whole-Task review、authority check、必要validation與獨立commit。

---

## File Map

### Create

- `tools/ci/artifact_contract.py`：root／key validation、manifest allowlist與跨平台path safety。
- `tools/ci/artifact_store.py`：job begin／finalize、atomic publish、checksums、run aggregation與GitHub summary CLI。
- `tools/ci/artifact_cleanup.py`：retention evaluation、pin、dry-run manifest、trash apply、restore與purge CLI。
- `tools/ci/github_storage_cleanup.py`：GitHub artifact／cache inventory、exact deletion manifest與受控delete CLI。
- `tools/ci/test_artifact_contract.py`。
- `tools/ci/test_artifact_store.py`。
- `tools/ci/test_artifact_cleanup.py`。
- `tools/ci/test_github_storage_cleanup.py`。
- `tools/ci/test_artifact_workflow_contract.py`。
- `docs/audits/milestone_32/32-2_artifact_contract_review.md`至`32-12_post_release_validation.md`。

### Modify

- `docs/adr/adr-023-repository-ci-quality-gates-android-verification-artifact.md`。
- `.github/workflows/ci.yml`、`android.yml`、`ios.yml`、`observability-acceptance.yml`。
- `tools/ci/run_local_ci.sh`、`build_android_environment.sh`、`build_ios_environment.sh`。
- `tools/ci/write_observability_acceptance_evidence.py`及既有CI contract tests。
- `docs/guides/ci_cd_operations.md`、Roadmap／Project Context／indexes。
- `CHANGELOG.md`、`VERSION`（只在release Task）。

---

### Task 1: Durable CI Artifact Authority and Active Task Gate

**Files:**
- Modify: `docs/adr/adr-023-repository-ci-quality-gates-android-verification-artifact.md`
- Modify: `docs/roadmap/active.md`
- Create: `docs/audits/milestone_32/32-2_artifact_contract_review.md`

**Interfaces:**
- Consumes: accepted Milestone 32 Design、現有ADR-023三種execution mode contract。
- Produces: durable artifact ownership／transport／retention／cleanup contract，供Tasks 2–11實作。

- [ ] **Step 1: 將active roadmap切換至Task 1**

記錄Design與Plan均accepted、GitHub cleanup仍forbidden，且本Task只建立authority。

- [ ] **Step 2: 更新ADR-023 durable contract**

加入以下不可變規則：

```txt
GitHub Actions = control plane
manual-local/self-hosted = managed local artifact owner
self-hosted remote cache/artifact transport = prohibited
github-hosted repository-default artifact transport = none
artifact root must be external and validated
job-level atomic manifest + run-level aggregation
age + count + capacity retention
GitHub cleanup requires exact IDs and separate approval
```

不得把當前artifact count、runner ID、個人absolute path或cleanup object ID寫入ADR。

- [ ] **Step 3: 執行文件驗證**

```bash
python tools/docs/check_docs.py .
dart run melos run docs_check
git diff --check
```

Expected: 全部PASS。

- [ ] **Step 4: 完成Task 1雙層review並提交**

```bash
git add docs/adr/adr-023-repository-ci-quality-gates-android-verification-artifact.md docs/roadmap/active.md docs/audits/milestone_32/32-2_artifact_contract_review.md
git commit -m "docs(ci): 建立本機產物架構權威"
```

---

### Task 2: Artifact Contract, Root Resolution, and Schema Validation

**Files:**
- Create: `tools/ci/artifact_contract.py`
- Create: `tools/ci/test_artifact_contract.py`
- Modify: `tools/ci/test_shell_portability_contract.py`
- Update: `docs/audits/milestone_32/32-2_artifact_contract_review.md`

**Interfaces:**
- Consumes: Task 1 external-root與manifest allowlist contract。
- Produces:
  - `resolve_artifact_root(explicit_root, execution_mode, platform_name, environment) -> pathlib.Path`
  - `validate_artifact_root(root, repo_root, runner_work=None, runner_temp=None, home=None) -> pathlib.Path`
  - `sanitize_key(value: str) -> str`
  - `validate_job_manifest(payload: Mapping[str, object]) -> None`
  - `SCHEMA_VERSION = 1`、`RETENTION_CLASSES`、`SECRET_FIELD_PATTERNS`。

- [ ] **Step 1: 寫root resolution RED tests**

```python
def test_self_hosted_requires_explicit_root(self) -> None:
    with self.assertRaisesRegex(ValueError, "CI_ARTIFACT_ROOT"):
        resolve_artifact_root(None, "self-hosted", "Darwin", {})

def test_windows_manual_default_uses_local_app_data(self) -> None:
    root = resolve_artifact_root(
        None,
        "manual-local",
        "Windows",
        {"LOCALAPPDATA": r"C:\\Users\\tester\\AppData\\Local"},
    )
    self.assertEqual(
        root,
        Path(r"C:\Users\tester\AppData\Local\flutter_architecture\ci-artifacts"),
    )
```

- [ ] **Step 2: 寫path safety與schema RED tests**

覆蓋repository內、worktree、runner `_work`、runner temp、filesystem root、home root、symlink escape與`..` traversal。Manifest加入`environment_variables`、`token`或`service_account_json`時必須raise `ValueError`。

- [ ] **Step 3: 執行RED**

```bash
python -m unittest tools.ci.test_artifact_contract -v
```

Expected: FAIL，指出`tools.ci.artifact_contract`不存在。

- [ ] **Step 4: 建立最小contract implementation**

使用`typing.Optional`／`typing.Mapping`；`sanitize_key`只允許ASCII小寫字母、數字、`.`、`_`、`-`，其餘轉為`-`，空結果raise `ValueError`。

- [ ] **Step 5: 執行GREEN與portability tests**

```bash
python -m unittest tools.ci.test_artifact_contract tools.ci.test_shell_portability_contract -v
```

Expected: PASS。

- [ ] **Step 6: 完成Task 2雙層review並提交**

```bash
git add tools/ci/artifact_contract.py tools/ci/test_artifact_contract.py tools/ci/test_shell_portability_contract.py docs/audits/milestone_32/32-2_artifact_contract_review.md
git commit -m "feat(ci): 建立本機產物契約"
```

---

### Task 3: Atomic Artifact Writer, Checksums, and Run Aggregation

**Files:**
- Create: `tools/ci/artifact_store.py`
- Create: `tools/ci/test_artifact_store.py`
- Create: `docs/audits/milestone_32/32-3_artifact_store_review.md`

**Interfaces:**
- Consumes: Task 2 root／key／schema validation。
- Produces:
  - `begin_job(root, repo_root, commit_sha, run_key, job_key, metadata) -> JobContext`
  - `finalize_job(context, result, validation_entries, cleanup_disposition) -> pathlib.Path`
  - `aggregate_run(root, commit_sha, run_key) -> pathlib.Path`
  - CLI `begin-job`、`finalize-job`、`aggregate-run`、`write-summary`。

- [ ] **Step 1: 寫begin／finalize RED tests**

`begin_job`必須建立locked staging tree；finalize前published dir不存在，finalize後staging消失且`manifest.json`、`summary.md`、`checksums.sha256`存在，每個SHA-256可重新計算一致。

- [ ] **Step 2: 寫multi-job aggregation RED test**

同一run依序finalize `quality-macos`與`ios-macos`，`run-manifest.json`必須同時列出兩個job manifest及各自SHA-256，不得只保留最後一個job。

- [ ] **Step 3: 寫primary-result precedence RED test**

模擬primary command=`failure`且summary writer失敗；final manifest必須保留`result=failure`與`evidence_status=degraded`。

- [ ] **Step 4: 執行RED並實作**

```bash
python -m unittest tools.ci.test_artifact_store -v
```

Expected RED後，實作同filesystem atomic rename、sorted JSON、relative checksums與禁止覆寫published job。

- [ ] **Step 5: 執行GREEN**

```bash
python -m unittest tools.ci.test_artifact_contract tools.ci.test_artifact_store -v
```

- [ ] **Step 6: 完成Task 3雙層review並提交**

```bash
git add tools/ci/artifact_store.py tools/ci/test_artifact_store.py docs/audits/milestone_32/32-3_artifact_store_review.md
git commit -m "feat(ci): 建立原子化本機產物寫入器"
```

---

### Task 4: Retention, Pins, Capacity, Trash, and Cleanup Recovery

**Files:**
- Create: `tools/ci/artifact_cleanup.py`
- Create: `tools/ci/test_artifact_cleanup.py`
- Create: `docs/audits/milestone_32/32-4_retention_cleanup_review.md`

**Interfaces:**
- Consumes: Tasks 2–3 manifests、published runs與locks。
- Produces:
  - `evaluate_cleanup(root, now, max_bytes, min_free_bytes) -> CleanupPlan`
  - `write_cleanup_manifest(root, plan) -> str`
  - `apply_cleanup(root, manifest_id) -> pathlib.Path`
  - `restore_cleanup(root, cleanup_id) -> None`
  - `purge_trash(root, cleanup_id, now) -> None`
  - CLI `evaluate`、`apply`、`restore`、`purge`、`pin`、`unpin`。

- [ ] **Step 1: 寫age／count RED tests**

精確覆蓋success 7天／3次、failure 14天／10次、Observability 3天／2次、release 30天／3 SHA。

- [ ] **Step 2: 寫capacity／minimum-free RED tests**

模擬31 GiB store與14 GiB free；排序必須先success、再超count failure、再Observability、最後release。仍不足時回報blocking bytes，不刪pin或未過期保留項目。

- [ ] **Step 3: 寫path／lock／manifest drift與trash RED tests**

Symlink escape、active lock、in-progress、generation或manifest SHA drift必須拒絕apply。Apply只move至trash；24小時內可restore，未滿24小時不得purge。

- [ ] **Step 4: 執行RED並實作**

```bash
python -m unittest tools.ci.test_artifact_cleanup -v
```

時間使用UTC aware datetime，manifest只保存relative paths。

- [ ] **Step 5: 執行GREEN並提交**

```bash
python -m unittest tools.ci.test_artifact_contract tools.ci.test_artifact_store tools.ci.test_artifact_cleanup -v
git add tools/ci/artifact_cleanup.py tools/ci/test_artifact_cleanup.py docs/audits/milestone_32/32-4_retention_cleanup_review.md
git commit -m "feat(ci): 建立產物保留與安全清理"
```

---

### Task 5: Manual-local and Platform Build Integration

**Files:**
- Modify: `tools/ci/run_local_ci.sh`
- Modify: `tools/ci/build_android_environment.sh`
- Modify: `tools/ci/build_ios_environment.sh`
- Modify: `tools/ci/test_local_build_commands.py`
- Create: `docs/audits/milestone_32/32-5_local_ci_integration_review.md`

**Interfaces:**
- Consumes: Tasks 2–4 CLI。
- Produces: 每個suite以managed job執行；環境變數`CI_ARTIFACT_ROOT`、`CI_RUN_KEY`、`CI_JOB_KEY`、`CI_RETENTION_CLASS`。

- [ ] **Step 1: 擴充local command RED tests**

Static test要求`begin-job`、trap `finalize-job`、`aggregate-run`與cleanup evaluate，並拒絕正式artifact寫回`$repo_root/artifacts`。

- [ ] **Step 2: 執行RED**

```bash
python -m unittest tools.ci.test_local_build_commands -v
```

- [ ] **Step 3: 改造`run_local_ci.sh`**

建立`run_managed_job <suite> <platform> <command...>`，begin後執行exact argv，trap中finalize／aggregate，並保留primary command exit code。

- [ ] **Step 4: 調整Android／iOS build cleanup boundary**

Build scripts只清理傳入job staging `ARTIFACT_DIR`，新增`run_key`／`job_key`projection，不複製完整run manifest。

- [ ] **Step 5: 執行focused tests與bounded smoke**

```bash
python -m unittest tools.ci.test_local_build_commands tools.ci.test_artifact_store -v
bash -n tools/ci/run_local_ci.sh
bash -n tools/ci/build_android_environment.sh
bash -n tools/ci/build_ios_environment.sh
CI_ARTIFACT_ROOT="$PWD/.tmp-artifact-smoke" bash tools/ci/run_local_ci.sh quality
python tools/ci/artifact_cleanup.py evaluate --root "$PWD/.tmp-artifact-smoke" --dry-run
```

完成後刪除`.tmp-artifact-smoke`；它不得作正式runtime evidence。

- [ ] **Step 6: 完成Task 5雙層review並提交**

```bash
git add tools/ci/run_local_ci.sh tools/ci/build_android_environment.sh tools/ci/build_ios_environment.sh tools/ci/test_local_build_commands.py docs/audits/milestone_32/32-5_local_ci_integration_review.md
git commit -m "feat(ci): 將本機驗證接入managed產物"
```

---

### Task 6: Workflow Transport Policy and GitHub Summary

**Files:**
- Modify: `.github/workflows/ci.yml`
- Modify: `.github/workflows/android.yml`
- Modify: `.github/workflows/ios.yml`
- Modify: `.github/workflows/observability-acceptance.yml`
- Create: `tools/ci/test_artifact_workflow_contract.py`
- Modify: `tools/ci/test_ci_execution_mode_contract.py`
- Modify: `tools/ci/test_environment_workflow_matrix_contract.py`
- Modify: `tools/ci/test_ios_workflow_contract.py`
- Create: `docs/audits/milestone_32/32-6_workflow_transport_review.md`

**Interfaces:**
- Consumes: Task 5 managed job wrapper與existing execution mode expressions。
- Produces: `artifact_transport` choice；self-hosted取得external `CI_ARTIFACT_ROOT`；summary呼叫writer CLI。

- [ ] **Step 1: 寫workflow transport RED matrix**

```txt
self-hosted + any event => no upload-artifact, no actions/cache
github-hosted + pull_request/push => none
workflow_dispatch + repository-default => none
workflow_dispatch + failure-only => bounded diagnostics only
workflow_dispatch + full => one-day artifact and warning
manual-local => no execution job
```

- [ ] **Step 2: 寫allowlist與25 MiB preflight RED tests**

`failure-only`只接受文字log、selected golden PNG與manifest summary；拒絕APK、`.app`、dSYM、symbols、mapping與provider config。

- [ ] **Step 3: 執行RED並修改四份workflow**

```bash
python -m unittest tools.ci.test_artifact_workflow_contract tools.ci.test_ci_execution_mode_contract tools.ci.test_environment_workflow_matrix_contract tools.ci.test_ios_workflow_contract -v
```

移除全部`actions/cache`；upload steps只允許manual explicit github-hosted transport。

- [ ] **Step 4: 加入GitHub summary**

Self-hosted summary必須含`local-only`、commit、run/job key、primary/evidence result、manifest SHA、count／bytes與「not downloadable from GitHub」。

- [ ] **Step 5: 執行workflow tests／lint並提交**

```bash
python -m unittest discover -s tools/ci -p "test_*workflow*.py" -v
actionlint -shellcheck=
git add .github/workflows tools/ci/test_artifact_workflow_contract.py tools/ci/test_ci_execution_mode_contract.py tools/ci/test_environment_workflow_matrix_contract.py tools/ci/test_ios_workflow_contract.py docs/audits/milestone_32/32-6_workflow_transport_review.md
git commit -m "feat(ci): 切換workflow產物傳輸政策"
```

---

### Task 7: Observability and Bounded Failure Evidence

**Files:**
- Modify: `.github/workflows/ci.yml`
- Modify: `.github/workflows/ios.yml`
- Modify: `.github/workflows/observability-acceptance.yml`
- Modify: `tools/ci/write_observability_acceptance_evidence.py`
- Modify: `tools/ci/test_observability_acceptance_workflow.py`
- Modify: `tools/ci/test_android_observability_contract.py`
- Modify: `tools/ci/test_ios_observability_contract.py`
- Create: `docs/audits/milestone_32/32-7_observability_failure_evidence_review.md`

**Interfaces:**
- Consumes: Task 6 transport matrix、Task 3 diagnostics allowlist。
- Produces: `emit_controlled_event` default `false`、redacted Observability evidence、bounded golden／iOS diagnostics與secret leakage gate。

- [ ] **Step 1: 寫`emit_controlled_event` RED tests**

只有`remote_acceptance=true && emit_controlled_event=true`才能傳入acceptance event flag；event=false時symbol upload與artifact build仍可執行。

- [ ] **Step 2: 寫secret leakage與bounded diagnostics RED tests**

Firebase private key header、provider config、plist client ID與`gho_` token pattern必須阻擋publish且不回顯完整secret。Golden只接受master／test／diff與summary；iOS只接受toolchain／build log。

- [ ] **Step 3: 實作並驗證**

```bash
python -m unittest tools.ci.test_observability_acceptance_workflow tools.ci.test_android_observability_contract tools.ci.test_ios_observability_contract tools.ci.test_artifact_store tools.ci.test_ci_secret_cleanup_contract -v
actionlint -shellcheck=
bash -n tools/ci/cleanup_ci_secrets.sh
```

- [ ] **Step 4: 完成Task 7雙層review並提交**

```bash
git add .github/workflows/ci.yml .github/workflows/ios.yml .github/workflows/observability-acceptance.yml tools/ci/write_observability_acceptance_evidence.py tools/ci/test_observability_acceptance_workflow.py tools/ci/test_android_observability_contract.py tools/ci/test_ios_observability_contract.py docs/audits/milestone_32/32-7_observability_failure_evidence_review.md
git commit -m "feat(ci): 收斂可觀測性與失敗證據"
```

---

### Task 8: Operations, Full Static Regression, and Runtime Readiness

**Files:**
- Modify: `docs/guides/ci_cd_operations.md`
- Modify: `docs/project_context.md`
- Modify: `docs/roadmap/active.md`
- Modify: `docs/audits/README.md`
- Modify: `docs/superpowers/README.md`
- Modify: `docs/milestones/README.md`
- Create: `docs/audits/milestone_32/32-8_runtime_acceptance.md`

**Interfaces:**
- Consumes: Tasks 1–7 implementation與tests。
- Produces: operator configuration、pin／cleanup／restore／rollback guide與runtime acceptance checklist。

- [ ] **Step 1: 文件化operator configuration與復原**

Mac以`/Users/water/Developer/ci-artifacts/flutter_architecture`作operator example，不作source default；Windows提供PowerShell `$env:CI_ARTIFACT_ROOT`與default說明。包含query、checksum、pin、dry-run、apply、restore、purge、runner offline與workflow revert。

- [ ] **Step 2: 執行完整static regression**

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

- [ ] **Step 3: 執行repository quality suite**

```bash
bash tools/ci/run_local_ci.sh quality
```

Expected: dependency resolution、docs、contracts、analyze、generated consistency、Flutter tests與managed manifest全部PASS。

- [ ] **Step 4: 完成Task 8雙層review並提交**

```bash
git add docs/guides/ci_cd_operations.md docs/project_context.md docs/roadmap/active.md docs/audits/README.md docs/superpowers/README.md docs/milestones/README.md docs/audits/milestone_32/32-8_runtime_acceptance.md
git commit -m "docs(ci): 建立本機產物操作與驗收入口"
```

---

### Task 9: Windows, Mac, and Self-hosted Runtime Acceptance

**Files:**
- Update: `docs/audits/milestone_32/32-8_runtime_acceptance.md`

**Interfaces:**
- Consumes: complete local writer、cleanup與workflow implementation。
- Produces: Windows／Mac manual-local、Mac self-hosted、failure injection、offline no-fallback與GitHub storage no-growth evidence。

- [ ] **Step 1: Freeze pre-run GitHub storage inventory**

只讀記錄artifacts／caches count、bytes與latest timestamp。

- [ ] **Step 2: Windows manual-local acceptance**

```bash
bash tools/ci/run_local_ci.sh quality
bash tools/ci/run_local_ci.sh android
```

核對兩種APK、metadata、manifest、checksums、host、mode、retention與cleanup dry-run。

- [ ] **Step 3: Mac manual-local acceptance**

執行quality、Android、iOS與Observability secret-safe build，`emit_controlled_event=false`；核對App、dSYM、symbols、mapping與redacted evidence，確認provider config／service account不在store。

- [ ] **Step 4: Mac self-hosted source-change acceptance**

以受控source／workflow contract commit觸發CI、Android、iOS；確認checks成功、runner正確、local manifests存在、summary標示local-only。

- [ ] **Step 5: Re-query GitHub storage**

Expected：count、bytes與latest timestamp均不增加；若增加，Task保持open並追查exact workflow／job後fresh rerun。

- [ ] **Step 6: Failure injection與offline acceptance**

Quality與platform各失敗一次，確認primary exit code、bounded diagnostics與secret scan；恢復fixture後fresh pass。Runner停止時self-hosted job queued且無fallback，manual-local仍可產生相同schema。

- [ ] **Step 7: 完成Task 9 runtime review並提交**

```bash
git add docs/audits/milestone_32/32-8_runtime_acceptance.md
git commit -m "test(ci): 驗收本機產物執行路線"
```

---

### Task 10: GitHub Storage Inventory and Exact Deletion Manifest

**Files:**
- Create: `tools/ci/github_storage_cleanup.py`
- Create: `tools/ci/test_github_storage_cleanup.py`
- Create: `docs/audits/milestone_32/32-9_github_cleanup_manifest_review.md`
- Modify: `docs/roadmap/active.md`

**Interfaces:**
- Consumes: Task 9 replacement local evidence與fresh GitHub inventory。
- Produces:
  - `collect_inventory(api_client) -> Inventory`
  - `classify_inventory(inventory) -> Sequence[DeletionCandidate]`
  - `write_deletion_manifest(candidates, output_dir) -> str`
  - `delete_from_manifest(api_client, manifest_path, approval_token) -> DeletionResult`
  - CLI `inventory`、`manifest`、`delete`。

- [ ] **Step 1: 建立offline API fixtures與RED tests**

Fixture包含artifact/cache exact IDs、name/key、bytes、timestamps、workflow/ref。Test禁止只依prefix產生DELETE。

- [ ] **Step 2: 寫manifest integrity與delete gate RED tests**

Manifest必須含repository、generated_at、pre-delete totals、exact IDs、classification、reason、replacement evidence route與SHA-256。無approval token、token不符、未reviewed或inventory drift時不得送出DELETE。

- [ ] **Step 3: 實作CLI並執行unit tests**

Unit tests只用fake API client；production delete前fresh GET並比較IDs與bytes。

- [ ] **Step 4: 產生real dry-run manifest**

輸出至managed store的`cleanup-manifests/github/<manifest-id>`，repository audit只記manifest ID、SHA、totals與非敏感摘要。

- [ ] **Step 5: 完成manifest雙層review並提交**

```bash
git add tools/ci/github_storage_cleanup.py tools/ci/test_github_storage_cleanup.py docs/audits/milestone_32/32-9_github_cleanup_manifest_review.md docs/roadmap/active.md
git commit -m "feat(ci): 建立GitHub儲存清理清單"
```

- [ ] **Step 6: 強制停止並取得獨立cleanup核准**

報告manifest ID、artifact／cache數量、總bytes、不可逆範圍與replacement evidence；此時不得執行DELETE。

---

### Task 11: Approved GitHub Cleanup, Release, and Post-release Closure

**Files:**
- Create: `docs/audits/milestone_32/32-10_github_cleanup_execution.md`
- Create: `docs/audits/milestone_32/32-11_final_review.md`
- Create: `docs/audits/milestone_32/32-12_post_release_validation.md`
- Modify: `docs/guides/ci_cd_operations.md`、current authority indexes、`CHANGELOG.md`、`VERSION`。

**Interfaces:**
- Consumes: Task 10 reviewed manifest與獨立cleanup approval。
- Produces: exact deletion evidence、storage下降驗證、Template Baseline release、clean-checkout／self-hosted post-release evidence與formal closure。

- [ ] **Step 1: 核對approval、manifest hash與fresh inventory**

若manifest或inventory drift，回到Task 10重新產生／review，不沿用舊approval。

- [ ] **Step 2: 依manifest執行exact deletion**

先artifacts後caches；每次記錄object ID、HTTP status與timestamp。任一未知失敗立即停止後續刪除。

- [ ] **Step 3: Fresh re-query storage**

記錄post-delete count／bytes，逐一確認manifest objects不存在；不得只以CLI exit 0宣稱下降。

- [ ] **Step 4: 執行full regression與platform builds**

```bash
python -m unittest discover -s tools/ci -p "test_*.py" -v
actionlint -shellcheck=
python tools/docs/check_docs.py .
dart run melos run docs_check
dart run melos run analyze
dart run melos exec -- flutter test
git diff --check
```

Windows Android與Mac Android／iOS代表build都須fresh通過；self-hosted run後再確認GitHub storage不增加。

- [ ] **Step 5: Holistic final review與release identity**

跨Tasks 1–10檢查ownership、schema、secret、multi-job、retention、rollback、irreversible cleanup與authority。若final review確認minor capability，`VERSION`由`1.13.0`提升為`1.14.0`；不同版本需新的release decision，不得靜默變更。

- [ ] **Step 6: Commit、push、clean-checkout與post-release closure**

Release SHA必須由self-hosted CI、Android與iOS成功驗證，Observability ordinary push保持skipped，GitHub storage不得重新增加。完成post-release evidence後才可把active milestone設為`None`。

---

## Plan Completion Gate

本Plan已完成下列條件，並於2026-07-30 14:04（Asia/Taipei）取得使用者明確核准，正式由`proposed`轉為`accepted`：

```txt
focused Plan review
findings and fixes
fresh focused re-review
whole-Plan holistic review
Spec coverage and interface consistency check
placeholder／ambiguity scan
documentation validation
independent commit
user explicit Plan approval
```

Plan核准後允許依Tasks 1–10順序開始implementation；但仍保留以下停止條件：

```txt
每個Task必須完成focused review、修正、fresh re-review與獨立commit
不得建立正式CI_ARTIFACT_ROOT
不得修改CI_EXECUTION_MODE
不得刪除GitHub artifacts／caches
```

即使Plan核准，Task 10 cleanup manifest完成後仍必須再次取得獨立cleanup approval，才能進入Task 11的GitHub DELETE操作。
