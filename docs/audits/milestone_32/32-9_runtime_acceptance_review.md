---
document_type: runtime-evidence
status: active
authoritative_for:
  - milestone-32-task-9-runtime-acceptance-review
last_reviewed_baseline: 1.13.0
---

# Milestone 32 — Task 9 Runtime Acceptance Review

## Current conclusion

```txt
Windows manual-local quality: Passed
Windows manual-local Android: Passed after runtime portability repair
Controlled quality failure evidence: Passed
GitHub storage no-growth: Passed for all Windows local runs
Self-hosted offline / no-fallback: Passed
Mac manual-local quality / Android / iOS / Observability: Blocked — bridge-mac account connection unavailable
Mac self-hosted source-change success: Blocked — runner offline and CI_ARTIFACT_ROOT unset
Task 9 whole-Task review: Open
Task 10 cleanup manifest: Forbidden until Task 9 completes
```

本文件只保存Task 9 runtime evidence。它不核准GitHub artifact／cache刪除，也不建立、apply或purge任何local cleanup manifest。

## Pre-run GitHub storage inventory

2026-07-30於Windows checkout以GitHub API只讀取得：

```txt
Artifacts
  count: 110
  bytes: 7,835,943,504
  latest_created_at: 2026-07-24T14:52:05Z
  latest_updated_at: 2026-07-24T14:52:05Z

Caches
  count: 12
  bytes: 8,558,394,658
  latest_created_at: 2026-07-23T17:25:23.379841000Z
  latest_last_accessed_at: 2026-07-23T17:25:45.915783000Z
```

Task 9 Windows local runs與offline queued run後fresh re-query完全相同；count、bytes與latest timestamps均未增加。

## Windows manual-local quality acceptance

### Initial acceptance

```txt
run_key: local-20260730t104049z-1264-81dbe6f2
commit_sha: b4de1af46ed88a3761e496bdc81f0c0b4730944e
run_result: success
job_key: quality-windows
job_result: success
execution_mode: manual-local
host_os: windows
evidence_status: complete
retention_class: verification-success
checksums: all OK
```

### Final fresh acceptance after runtime repairs

```txt
run_key: local-20260730t110123z-1522-10474905
commit_sha: d74082e25270ed1683289c1c41200618ff0dead9
run_result: success
job_count: 1
job_key: quality-windows
job_result: success
validation_exit: 0
execution_mode: manual-local
host_os: windows
evidence_status: complete
retention_class: verification-success
cleanup_status: retained
```

Fresh coverage：

```txt
Dependency resolution: passed
Documentation checks: passed
CI contract tests: 186 passed
Five-package analyze: passed
Generated consistency: passed
Flutter tests: passed
Managed aggregation: passed
Retention dry evaluation: passed
```

Checksum verification：

```txt
artifacts/quality/quality-result.txt: OK
manifest.json: OK
summary.md: OK
```

## Windows Android acceptance

### Runtime finding — Windows apkanalyzer resolution

首次Android run：

```txt
run_key: local-20260730t104348z-1433-3c6a77db
commit_sha: b4de1af46ed88a3761e496bdc81f0c0b4730944e
result: failure
evidence_status: complete
retention_class: verification-failure
```

Development APK已成功建置，但validation找不到`apkanalyzer`。只讀調查確認Android SDK與以下檔案完整存在：

```txt
C:\Users\crazy\AppData\Local\Android\Sdk\cmdline-tools\latest\bin\apkanalyzer.bat
```

Root cause是shell script只尋找Unix無副檔名executable，沒有支援Windows `.bat`，不是SDK遭刪除或build failure。

依TDD先新增RED contract，再實作`resolve_apkanalyzer`，支援：

```txt
command -v apkanalyzer
ANDROID_SDK_ROOT
ANDROID_HOME
Windows LOCALAPPDATA/Android/Sdk
macOS $HOME/Library/Android/sdk
apkanalyzer與apkanalyzer.bat
```

修正commit：

```txt
b34feee2142cbf1b9c4a5161e83c93e3435336dd
fix(ci): 支援Windows apkanalyzer驗證
```

### Fresh Android pass

```txt
run_key: local-20260730t105032z-675-5d811d80
commit_sha: b34feee2142cbf1b9c4a5161e83c93e3435336dd
run_result: success
job_key: android-android
job_result: success
execution_mode: manual-local
host_os: windows
target_platform: android
evidence_status: complete
retention_class: verification-success
cleanup_status: retained
```

Artifacts：

```txt
development debug APK
  package_id: com.example.flutterarchitecture.development
  bytes: 196,965,596

production release APK
  package_id: com.example.flutterarchitecture
  bytes: 58,552,774
  Flutter symbols: 3 files
  mapping.txt: present / 18,996,835 bytes
```

Job內全部checksum entries為`OK`；provider config、service account、private key、keystore、mobileprovision與其他denied filenames均不存在。

## Controlled failure evidence

### Platform failure

前述Windows `apkanalyzer`缺口提供真實platform failure evidence：primary failure保留、job finalize成功、evidence complete、retention切換為`verification-failure`。修復後另建fresh success run，沒有覆寫failure authority。

### Quality failure injection

以`managed-command`執行受控quality fixture：建立單一54-byte文字diagnostic後固定退出`17`。

```txt
run_key: task9-quality-failure-20260730-01
run_result: failure
job_result: failure
primary_exit_code: 17
evidence_status: complete
retention_class: verification-failure
diagnostic_bytes: 54
checksums: all OK
secret scan: passed
```

Diagnostic只包含closed fixture fields：

```txt
failure_kind=controlled-quality
secret_content=none
```

Fresh quality恢復run在後續codegen runtime repair完成後成功，見`local-20260730t110123z-1522-10474905`。

## Runtime finding — generated normalizer traversed volatile build output

在Android build後執行fresh quality時，run：

```txt
local-20260730t105717z-1818-e725317a
```

於generated consistency失敗。`tools/codegen/normalize_generated.dart`使用recursive `listSync`先進入Android `build/`，再於file filter排除；Gradle transient directory在列舉期間消失，造成`PathNotFoundException`。

依TDD新增RED contract，將normalizer改為受控directory walk，在recursion前prune：

```txt
.git
.dart_tool
build
```

若目錄在列舉時已消失則安全跳過；其他`FileSystemException`仍rethrow。實際於仍保有Android build output的app目錄重現驗證：

```txt
Normalized 0 generated file(s).
```

修正commit：

```txt
d74082e25270ed1683289c1c41200618ff0dead9
fix(codegen): 排除動態建置目錄
```

完整186個CI contracts、format、actionlint、docs checks與最終fresh quality均通過。

## Self-hosted offline and no-fallback acceptance

GitHub repository runner inventory：

```txt
name: water-mac-flutter-architecture
os: macOS
status: offline
busy: false
labels:
  self-hosted
  macOS
  ARM64
  flutter-architecture
  trusted-main
```

受控dispatch：

```txt
workflow: CI
run_id: 30537229489
event: workflow_dispatch
ref: milestone-32-ci-artifact-storage-cutover
head_sha: d74082e25270ed1683289c1c41200618ff0dead9
execution_mode: self-hosted
```

觀察結果：

```txt
run status: queued
only job: Classify Changes
job status: queued
steps: none
GitHub-hosted fallback: none
GitHub artifact growth: none
```

取得證據後已取消run；最終status為`completed / cancelled`。Manual-local仍以相同managed job／run schema產生Windows evidence，因此runner offline不阻止operator本機驗證。

## Mac and self-hosted success blocker

`bridge-mac`對：

```txt
/Users/water/Developer/projects/flutter_architecture
```

連續三次在workspace開啟前回傳connector account error：

```txt
We couldn't connect your account. Please try again.
```

同時GitHub runner為`offline`，repository variable狀態為：

```txt
CI_EXECUTION_MODE=self-hosted
CI_ARTIFACT_ROOT=<not configured>
```

依accepted Design，self-hosted缺少explicit root必須fail closed，不得回退到repository、runner `_work`或temp。未取得Mac filesystem access前，不應猜測或建立正式operator root，也不能聲稱iOS、dSYM、Mac Android／quality、Observability或self-hosted local manifest已通過。

## Remaining gate

Task 9保持open。恢復Mac connector／runner後必須依序完成：

```txt
1. 只讀確認Mac checkout、toolchain、disk與既有runner service
2. 建立並驗證正式external CI_ARTIFACT_ROOT
3. Mac manual-local quality、Android、iOS、Observability（emit_controlled_event=false）
4. 核對App、dSYM、symbols、mapping、redacted evidence與secret absence
5. Source-changing self-hosted success run
6. 核對GitHub summary、local manifests與storage no-growth
7. Task 9 whole-Task review與final commit
```

Task 9完成前：

```txt
不得進入Task 10
不得產生GitHub deletion manifest
不得刪除GitHub artifacts或caches
不得直接filesystem-clean managed store
```
