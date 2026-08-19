---
document_type: implementation-plan
status: accepted
authoritative_for:
  - generated-platform-owner-alignment-implementation-plan
last_reviewed_baseline: 1.25.2
---

# Generated / Platform Validation Owner Alignment — Implementation Plan

## Goal

消除Android Production中的duplicate generated consistency，讓Android／iOS platform workflow責任對稱，同時維持planner／orchestrator作為制式validation入口。

## Implementation

1. 從`.github/workflows/android.yml`移除GitHub-hosted Production的`Verify generated files`step。
2. 從self-hosted Android Production command移除`verify_generated.sh`，保留`dart pub get + build_android_production.sh`。
3. 在既有`tools/ci/test_validation_planner.py`workflow contract test加入「Android workflow不得內嵌`verify_generated.sh`」的單一critical invariant，不新增test file。
4. 同步ADR-023與CI/CD guide，明確generated owner、platform owner與orchestrator組合責任。
5. 執行critical owner tests、docs checker、YAML parse、`git diff --check`與planner changed-risk probe；做一次whole-scope review。

## Test Retention Decision

保留既有critical owner中的單一negative assertion，因它直接保護本次stable ownership boundary；不新增path permutations或platform test matrix。

## Release disposition

本Task本身不自動發布新baseline。完成local holistic review後，由explicit release decision決定是否建立fresh exact candidate與remote platform evidence。
