---
document_type: phase-review
status: accepted
authoritative_for:
  - milestone-24-clean-run-and-workflow-validation-review
last_reviewed_baseline: 1.5.1
---

# Milestone 24-5 — Clean-run and Workflow Validation Review

## Scope

本 review 將 Task 24-1～24-4 的工具鏈、quality gates、generated consistency、Android verification artifact 與操作契約視為同一條 CI chain，驗證 repository 不依賴既有 workspace build state 或 cache 才能完成關鍵命令。

本 Task 不修改 GitHub repository settings、不加入 production signing、不發布 Store artifact，也不宣稱本機執行可取代 GitHub-hosted runner logs。

## Clean-run Procedure

開始前確認 working tree 為乾淨狀態，接著移除 repository 內所有 `.dart_tool` 與既有 `artifacts/`，再從 tracked root `pubspec.lock` 執行：

```bash
dart pub get
dart run melos run docs_check
dart run melos run analyze
dart run melos exec --fail-fast -- flutter test -r compact
```

結果：

- Fresh dependency resolution：Passed。
- Documentation check：Passed。
- Workspace analyze：5 packages passed，無 issue。
- All Flutter tests：5 packages passed；app suite 370 tests passed。

此結果證明關鍵 quality commands 不需要 repository-local `.dart_tool` 或 build output cache 才能成功。Pub cache仍可由本機或GitHub Actions使用，但cache miss不是correctness failure。

## Generated Consistency Finding

第一次fresh generation正確失敗，發現4個tracked generated files與目前locked toolchain輸出不一致：

```txt
apps/flutter_architecture/lib/features/auth/presentation/bloc/auth_bloc.freezed.dart
apps/flutter_architecture/lib/features/catalog/presentation/bloc/catalog_bloc.freezed.dart
apps/flutter_architecture/lib/features/profile/presentation/bloc/profile_bloc.freezed.dart
packages/api_client/lib/src/models/login_response_dto.freezed.dart
```

差異為Freezed在Windows產生的行尾空白，以及`login_response_dto.freezed.dart`開頭BOM移除；沒有domain、runtime或public API語意變更。BOM移除屬於實質byte-level drift，必須更新tracked output；Windows-only行尾空白則不得污染canonical source。

處置：

- 接受目前Flutter 3.41.6與tracked lockfile產生的BOM移除。
- `verify_generated.sh`先以`git diff --ignore-space-at-eol`拒絕任何實質generated drift。
- 只有在不存在實質diff時，才restore Windows Freezed造成的tracked whitespace-only changes。
- untracked output與其他working-tree變更仍維持hard failure。

此修正不會忽略API、token、annotation或其他實質generated變更；只處理已驗證的跨平台行尾空白差異。修正後必須從乾淨commit再次執行script。

## Workflow Static Validation

驗證項目：

- `.github/workflows/ci.yml`與`.github/workflows/android.yml`可由YAML parser讀取。
- `on` events、stable job names、runner、permissions與concurrency符合ADR-023及phase reviews。
- 所有local／remote `uses:`皆pin 40位commit SHA。
- 無`pull_request_target`、secret引用或write permission。
- Android workflow的generated prerequisite位於build之前。
- `upload-artifact`使用`if-no-files-found: error`、14-day retention與SHA traceability。

結果：Passed。

## Android Artifact Validation

Repository script從乾淨commit執行：

```bash
bash tools/ci/build_android_release.sh
```

驗證內容：

- build command固定為`flutter build apk --release -t lib/main.dart`。
- APK命名為`flutter-architecture-<short-sha>-release.apk`。
- metadata的full SHA、short SHA、entrypoint與artifact filename一致。
- metadata保留`debug signing for verification only`與`not production-ready`警告。
- artifact output不被Git追蹤。

修正commit：

```txt
f71aa782c7a9df53caf1cce55992e95a05ed328a
```

從該乾淨commit重跑結果：

- `tools/ci/verify_generated.sh`：Passed；沒有實質tracked diff或untracked output。
- Android release build：Passed。
- APK：`flutter-architecture-f71aa78-release.apk`。
- APK size：約57.1 MB。
- Metadata：`artifact-metadata.txt`，full SHA、short SHA、entrypoint、build command與artifact filename一致。
- Signing／distribution警告：保留verification-only debug signing與not production-ready分類。

## Environment Boundary

Windows本機必須使用Git for Windows Bash搭配Windows Flutter SDK。WSL Bash搭配Windows Flutter shell wrapper會受CRLF與路徑邊界影響，不能作為Ubuntu workflow等價證據。

正式workflow仍以`ubuntu-24.04`、Flutter 3.41.6與Temurin Java 17為authority；GitHub-hosted execution logs需在push後取得，不能由本機review虛構。

## Findings

| ID | Severity | Finding | Resolution |
|---|---:|---|---|
| M24-5-R01 | P1 | 4個tracked Freezed outputs與fresh locked generation不一致 | 更新generated outputs並從乾淨commit重跑consistency |
| M24-5-R04 | P1 | Windows Freezed會產生trailing-space-only diff，與repository whitespace policy衝突 | generated verifier只在無實質diff時restore whitespace-only changes |
| M24-5-R02 | P2 | WSL Bash不能安全搭配Windows Flutter SDK執行repository scripts | 本機使用Git for Windows Bash；正式CI使用Ubuntu runner |
| M24-5-R03 | P2 | GitHub-hosted workflow與artifact upload尚無remote run evidence | push後觀察；不得在本Task宣稱remote success |

## Review Result

Task 24-5在完成修正後的acceptance條件：

- Fresh resolution、docs、analyze與all tests通過。
- Generated consistency從乾淨commit通過。
- Android APK與metadata從同一乾淨commit產生並符合traceability contract。
- Workflow static contract與Action SHA pinning通過。
- Open P0／P1為0。

最終結果：Accepted。Open P0／P1為0；M24-5-R02與M24-5-R03保留為已知環境／remote evidence邊界，不阻擋進入whole-milestone final review。

