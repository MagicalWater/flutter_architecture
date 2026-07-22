---
document_type: phase-review
status: accepted
authoritative_for:
  - milestone-24-android-artifact-workflow-review
last_reviewed_baseline: 1.5.1
---

# Milestone 24-3 — Android Verification Artifact Workflow Review

## Scope

本 review 驗證 `.github/workflows/android.yml` 是否在 `main` push與manual dispatch建立可追溯的Android release APK verification artifact，並維持production signing、Store publishing與deployment為明確非目標。

## Delivered Contract

- Events：push to `main`、`workflow_dispatch`。
- Runner：`ubuntu-24.04`。
- Toolchain：Flutter 3.41.6、Temurin Java 17。
- Permissions：`contents: read`。
- Concurrency：以ref與commit SHA隔離，`cancel-in-progress: false`。
- Prerequisite：`dart pub get`後執行generated consistency。
- Build：`flutter build apk --release -t lib/main.dart`，由repository script執行。
- Artifact：APK與`artifact-metadata.txt`一併上傳，retention 14天。
- Signing：既有debug signing，只作verification，不是production-ready artifact。

## Review Findings

| Finding | Severity | Disposition |
|---|---:|---|
| M24-3-01 main commit build不可因後續push取消 | P1 | concurrency group包含SHA且不取消in-progress |
| M24-3-02 artifact必須與commit可追溯 | P1 | logical artifact name使用full SHA，檔名與metadata使用short/full SHA |
| M24-3-03 Gradle cache不可成為正確性前提 | P2 | setup-java只cache dependencies，仍完整執行Gradle build |
| M24-3-04 production signing界線需明確 | P1 | metadata標示debug signing與not production-ready |
| M24-3-05 upload step需在缺檔時失敗 | P2 | `if-no-files-found: error` |

Open P0／P1：0。

## Security Review

- 無repository secrets。
- 無write permission。
- 無`pull_request_target`。
- 所有Actions pin完整commit SHA。
- Checkout不持久化credential。
- Artifact path位於runner temp，不污染repository working tree。

## Validation

- Workflow YAML parse：Passed。
- Event、job、concurrency、permissions與SHA pinning static contract：Passed。
- Repository script shell syntax：Passed。
- Local release APK build：Passed，產生57.1 MB `flutter-architecture-eb8521b-release.apk`。
- Metadata inspection：Passed，包含full／short SHA、`lib/main.dart`、release mode、build command、verification-only debug signing與non-production classification。
- `docs_check`與`git diff --check`：Passed。

本機Windows驗證必須使用Git for Windows Bash；WSL Bash與Windows Flutter SDK混用會因SDK shell wrapper line ending失敗。正式GitHub Actions runner為原生Ubuntu，不存在此cross-environment問題。Local evidence使用Java 20，只證明script與artifact contract；workflow仍由setup-java固定Temurin 17，完整clean-run evidence留到Task 24-5。

## Decision

Task 24-3通過；後續進入Branch Protection與CI operations文件化。
