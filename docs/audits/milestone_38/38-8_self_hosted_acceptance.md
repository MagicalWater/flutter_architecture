---
document_type: phase-review
status: draft
authoritative_for:
  - milestone-38-task-38-8-self-hosted-acceptance
last_reviewed_baseline: 1.18.0
---

# Task 38-8 — Isolated Product Bootstrap Acceptance: self-hosted

## Current Disposition

Task 38-8：**BLOCKED_EXTERNAL**。

Machine contract與source-template live read-back均已取得，但accepted Plan要求的**product-scoped trusted Mac runner runtime**尚未完成，因此不得宣稱ACCEPTED，也不得以mock取代live route。

## Completed Evidence

- `tools/ci/test_ci_execution_mode_contract.py`、`test_public_repository_security_contract.py`與`test_repository_infrastructure.py` targeted set：23 tests PASS。
- Fresh source-template live snapshot：
  - `CI_EXECUTION_MODE = self-hosted`；
  - runner `water-mac-flutter-architecture`存在；
  - labels包含`self-hosted / macOS / ARM64 / flutter-architecture / trusted-main`；
  - runner current status為`offline`；
  - Actions default workflow permission為`read`；
  - `can_approve_pull_request_reviews=false`；
  - branch force-push與deletion均disabled；
  - observability Environment required secret **names**存在，snapshot不讀secret values。
- Workflow contract已證明：
  - PR不得選trusted self-hosted runner；
  - runner offline時沒有GitHub-hosted fallback；
  - selected profile仍需完整trusted label set；
  - self-hosted managed artifact root必須是checkout外explicit absolute root。

上述template runner只作transport／current contract evidence，**不是product-scoped acceptance runner**。

## Blocking External Dependency

2026-08-15 Task執行時：

- primary `bridge-mac` fresh `open_workspace`回傳connector account HTTP 400：`We couldn't connect your account. Please try again.`；
- 依bridge failover規則改試`bridge-mac-backup`，回傳相同connector account HTTP 400；
- 因此無法在Mac建立獨立product runner root、取得product repository registration token、fresh註冊／read-back runner、執行trusted main route或驗證external artifact root。

這是工具連線層external blocker，不是repository test failure，也不是允許把existing template runner重綁到product repository的理由。

## Resume Gate

Mac bridge恢復後，Task 38-8必須從current Milestone 38 HEAD fresh admission並完成：

1. 建立或使用disposable product repository，tracked profile=`self-hosted`、product-specific artifact key。
2. 使用獨立runner install root與product-specific labels；不得刪除、重綁或重用template runner registration。
3. Fresh live snapshot確認product repository runner存在、online、labels exact。
4. `CI_ARTIFACT_ROOT`設為checkout／runner `_work`外的explicit absolute product root並驗證fail-closed boundary。
5. Trusted main representative job實際由product runner執行並發布managed local evidence。
6. PR route不得進入trusted runner；runner offline probe不得fallback GitHub-hosted。
7. Live state、tracked manifest與selected profile一致後，才可finalize disposable lifecycle並將本文件改為ACCEPTED。

## Review Findings

- P0：0。
- Undisposed P1：0。
- Blocking：1 個external runtime dependency（Mac bridge connector unavailable）。

