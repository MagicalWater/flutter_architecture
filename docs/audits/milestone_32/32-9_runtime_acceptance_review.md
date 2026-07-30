---
document_type: runtime-evidence
status: completed
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
Mac manual-local quality / Android / iOS / Observability: Passed
Mac self-hosted CI / Android / iOS: Passed
GitHub storage no-growth: Passed across Windows、Mac manual-local與self-hosted runs
Self-hosted offline / no-fallback: Passed
Task 9 whole-Task review: Passed
Task 10 cleanup manifest: Unblocked；仍不得刪除GitHub artifacts或caches
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

Task 9 Windows local runs與offline queued run後fresh re-query完全相同；count、bytes與latest timestamps均未增加。Mac acceptance開始前再次凍結inventory，artifact數值仍完全相同；cache已由GitHub自然淘汰為10筆，但latest timestamps沒有前進。

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

## Mac operator root and toolchain acceptance

Mac connector恢復後，在不修改`main`的隔離worktree接續：

```txt
worktree: /Users/water/.devspace/worktrees/flutter_architecture-57b58169
branch: milestone-32-ci-artifact-storage-cutover
runner: water-mac-flutter-architecture
runner labels: self-hosted / macOS / ARM64 / flutter-architecture / trusted-main
```

Fresh preflight確認Python、Flutter、Dart、Xcode、CocoaPods、GitHub CLI與磁碟空間可用。正式operator root依Plan指定建立：

```txt
/Users/water/Developer/ci-artifacts/flutter_architecture
mode: 0700
symlink: false
repository descendant: false
runner _work descendant: false
validated by artifact_contract.validate_artifact_root: passed
repository variable CI_ARTIFACT_ROOT: configured
```

全程只執行retention dry-run；沒有apply、restore、purge或任何手動filesystem cleanup。

## Mac runtime findings and repairs

### Test fixture path portability

首次Mac quality揭露兩項test portability問題：macOS的`/var → /private/var`system alias使`tempfile`fixture被strict symlink contract拒絕；Windows default path test則使用host `Path`語意比較Windows path。

Production symlink拒絕規則沒有放寬。修正只限測試：temporary root先`resolve()`，Windows path改用`PureWindowsPath`比較。54個focused tests與完整186個CI contracts fresh通過。

```txt
6d52a6d9a7099793e7c537b9a54c754c47ca03b5
test(ci): 修正Mac路徑可攜性
```

### iOS volatile build output entered permanent evidence

首次iOS雙建置本身成功，但manifest錯誤納入整個Xcode `DerivedData`：

```txt
files: 23,689
bytes: approximately 3.06 GB
```

這違反bounded evidence目標，也會放大checksum、secret scan與retention成本。依TDD修正後：

```txt
build workspace: $ARTIFACT_DIR/.build
DerivedData: $ARTIFACT_DIR/.build/DerivedData
cleanup target: exact $ARTIFACT_DIR/.build only
symlink target: rejected
cleanup timing: before managed job finalize
```

同一修正也讓Android與iOS metadata持久記錄：

```txt
observability_remote_collection
observability_acceptance_event
```

Manual-local Observability event預設改為`false`，只有明確環境變數才能opt in。

```txt
08caafecc0d6c1ec3ff1f6f1c322b0768d74a86e
fix(ci): 收斂Mac產物與事件邊界
```

Fresh regression：187個CI contracts、shell syntax、documentation checks、workflow semantic lint與diff check均通過。

## Mac manual-local acceptance

### Quality

```txt
run_key: local-20260730t133038z-11529-d5870ef5
commit_sha: 6d52a6d9a7099793e7c537b9a54c754c47ca03b5
run_result: success
job_key: quality-macos
execution_mode: manual-local
host_os: macos
evidence_status: complete
checksums: all OK
cleanup dry-run: passed / no candidates
```

Coverage包含186個CI contracts、五個package analyze、generated consistency與全部Flutter tests。後續final commit另由self-hosted CI完整重驗。

### Android

```txt
run_key: local-20260730t133421z-14796-28f9050a
run_result: success
development package: com.example.flutterarchitecture.development
production package: com.example.flutterarchitecture
Flutter symbols: 3
mapping.txt: present
checksums: all OK
secret scan: passed
```

Android SDK `apkanalyzer`wrapper在macOS JBR環境會輸出一行非致命Java版本判斷warning；development與production驗證命令皆exit `0`並回傳正確application ID。

### iOS fresh bounded acceptance

```txt
run_key: local-20260730t134900z-28192-bf4f527d
commit_sha: 08caafecc0d6c1ec3ff1f6f1c322b0768d74a86e
run_result: success
artifact files: 266
artifact bytes: 232,618,842
DerivedData entries: 0
.build entries: 0
checksums: all OK
secret scan: passed
```

Artifacts與identity：

```txt
Development Simulator .app: com.example.flutterarchitecture.development
Production unsigned device .app: com.example.flutterarchitecture
Development dSYM: present
Production dSYM: present
provider config / signing material: absent
observability event: false
```

### Observability secret-safe acceptance

```txt
run_key: local-20260730t135207z-34393-ddfe43be
commit_sha: 08caafecc0d6c1ec3ff1f6f1c322b0768d74a86e
run_result: success
retention_class: observability-raw
artifact files: 282
artifact bytes: 407,714,127
DerivedData entries: 0
.build entries: 0
checksums: all OK
secret scan: passed
```

Closed metadata matrix：

```txt
Android production: remote_collection=false / acceptance_event=false
Android staging:    remote_collection=true  / acceptance_event=false
iOS production:     remote_collection=false / acceptance_event=false
iOS staging:        remote_collection=true  / acceptance_event=false
```

Provider config與Firebase app IDs未提供，因此symbol／dSYM upload安全略過，沒有發送controlled event。

## Self-hosted source-change success acceptance

在runner online且`CI_ARTIFACT_ROOT`設定完成後，對commit `08caafe`受控dispatch：

```txt
CI run:      30549370714 / success
Android run: 30549373444 / success
iOS run:     30549376547 / success
```

全部jobs都由`water-mac-flutter-architecture`執行，沒有fallback至GitHub-hosted：

```txt
CI:      quality + tests + generated consistency + artifact summary
Android: development debug + production release + Android summary
iOS:     development Simulator + production release + iOS summary
```

Local run aggregation：

```txt
gh-30549370714-1: success / 3 managed jobs / 0 artifact bytes
gh-30549373444-1: success / 2 managed jobs / 257,599,547 artifact bytes
gh-30549376547-1: success / 2 managed jobs / 245,977,066 artifact bytes
```

每個job均符合：

```txt
execution_mode=self-hosted
host_os=macos
runner_name=water-mac-flutter-architecture
evidence_status=complete
checksums=all OK
summary=Local-only evidence; not downloadable from GitHub.
DerivedData / .build entries=0
```

## Final GitHub storage no-growth evidence

三個self-hosted run各自GitHub artifact count與bytes均為`0`。Final aggregate inventory：

```txt
Artifacts
  count: 110
  bytes: 7,835,943,504
  latest_created_at: 2026-07-24T14:52:05Z
  latest_updated_at: 2026-07-24T14:52:05Z

Caches
  count: 10
  bytes: 8,415,432,007
  latest_created_at: 2026-07-23T17:25:23.379841000Z
  latest_last_accessed_at: 2026-07-23T17:25:45.915783000Z
```

Artifact count、bytes與latest timestamps完全未增加。Cache由pre-run 12筆自然下降為10筆，latest timestamps沒有前進；沒有任何Task 9 run建立GitHub cache。

## Whole-Task review

Task 9全部acceptance gates已完成：

```txt
Windows manual-local success / controlled failure / fresh recovery: passed
Mac manual-local quality / Android / iOS / Observability: passed
Self-hosted offline no-fallback: passed
Self-hosted CI / Android / iOS success: passed
Local manifest / checksum / retention / secret-safe evidence: passed
GitHub artifact and cache no-growth: passed
```

Task 10 exact GitHub cleanup manifest現在可以開始，但邊界維持：

```txt
只允許inventory與exact-ID deletion manifest
不得只依名稱或prefix刪除
不得在manifest review與使用者再次明確核准前送出DELETE
不得直接filesystem-clean managed local store
```
