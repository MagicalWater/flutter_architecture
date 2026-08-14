---
document_type: phase-review
status: accepted
authoritative_for:
  - milestone-38-task-38-2-infrastructure-manifest-verifier
last_reviewed_baseline: 1.18.0
---

# Task 38-2 — Infrastructure Manifest / Verifier / Artifact Product Identity Review

## Scope

本Task把38-1 RED owner轉GREEN，建立canonical `repository_infrastructure.json`、machine verifier與docs-check integration，並將manual-local managed artifact default從硬編`flutter_architecture`改為tracked `product_key`投影。

## Implemented Contract

- `repository_infrastructure.json`保存non-secret desired/disposition state。
- `tools/docs/verify_repository_infrastructure.py`對schema、CI mode、artifact strategy、capability dispositions、secret-like payload與self-hosted required runner state fail closed。
- `tools/docs/check_docs.py`將infrastructure verifier納入既有docs governance入口。
- `tools/ci/artifact_contract.py`的implicit manual-local root改由explicit `product_key`形成。
- `tools/ci/run_local_ci.sh`先由canonical infrastructure verifier讀取tracked `product_key`，不從folder或Git remote推導。

## Findings / Fixes

### F1 — Unsafe product key error used generic artifact-key wording

- Severity：P2。
- Finding：第一輪focused suite中unsafe `product_key`已正確拒絕，但錯誤訊息只回報`artifact key contains traversal`，不利於辨識contract owner。
- Fix：`resolve_artifact_root`包裝sanitization error為`invalid product_key: ...`。
- Re-review：focused suite同case PASS。

### F2 — Task 38-1 audit metadata used unsupported document type

- Severity：P2。
- Finding：`docs_check`指出`task-review`不是canonical document type。
- Fix：改為既有`phase-review`，不擴張docs schema。
- Re-review：待本Task fresh docs check確認。

## Test Authoring Disposition

**Required**。

Direct owners：

- `tools/docs/test_repository_infrastructure.py`
- `tools/ci/test_artifact_contract.py`
- existing `tools/ci/test_local_build_commands.py`

沒有新增重複的layer-by-layer測試。

## Review Gate

- Focused source review：schema與field ownership維持narrow；沒有把GitHub live state或secret value寫入manifest。
- Whole-Task review：artifact projection只改implicit manual-local default；explicit root與self-hosted fail-closed不變。
- Architecture authority：repository identity與repository infrastructure分離；ADR-031留待Task 38-3正式建立。
- Open P0：0。
- Undisposed P1：0。

## Validation

Planner admission對exact candidate `238712fa122f0182a8dbdc2b8370a57e9eda3eab`判定新root infrastructure manifest為`unknown`，依fail-safe policy升級為**full matrix**；未人工縮減。

Fresh evidence：

```txt
python -m unittest tools.docs.test_repository_infrastructure tools.ci.test_artifact_contract tools.ci.test_local_build_commands
dart run melos run docs_check
python -m unittest tools.docs.test_repository_identity tools.docs.test_template_repository_bootstrap_atomic_lifecycle tools.docs.test_template_repository_bootstrap_routing
git diff --check
```

結果：

- Focused infrastructure / artifact / local-build contract：49 PASS。
- Existing repository identity / bootstrap baseline：15 PASS。
- Full tools Python discovery：11 PASS。
- `docs_check`：PASS。
- Full workspace analyze：PASS。
- Full Flutter regression：所有5個workspace package PASS；App 493 cases PASS。
- Generated consistency：exact clean candidate worktree `238712f...` PASS；build_runner、Drift schema v1～v6/current、worker compile與semantic generated diff均無漂移。
- Android production release：exact candidate PASS；package id=`com.example.flutterarchitecture`；Flutter symbols=3；mapping present。
- iOS GitHub-hosted run `31824855900`：exact head `238712f...`；Production Release Build PASS、Simulator Build PASS、artifact transport=`none`。
- `git diff --check`：PASS。

Mac primary／backup bridge在本Task驗證時分別回502與account-connect 400，因此沒有把local Mac availability當作source defect；依accepted profile-neutral platform contract改用repository既有GitHub-hosted iOS route取得exact candidate evidence。

## Final Disposition

- Open P0：0。
- Undisposed P1：0。
- Task 38-2：**ACCEPTED**。

