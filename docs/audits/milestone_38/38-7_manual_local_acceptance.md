---
document_type: phase-review
status: active
authoritative_for:
  - milestone-38-task-38-7-manual-local-acceptance
last_reviewed_baseline: 1.18.0
---

# Task 38-7 — Isolated Product Bootstrap Acceptance: manual-local

## Scope

以從Milestone 38 accepted implementation tree建立的disposable managed worktree模擬GitHub `Use this template`後的新產品repository，驗證`manual-local` CI profile、產品artifact identity、atomic lifecycle與fresh no-handoff machine admission。

本Task不修改template repository的live `CI_EXECUTION_MODE`，也不建立／刪除GitHub repository。Live variable mutation/read-back語意使用Task 38-5已建立的repository-scoped manager與controlled disposable transport owner驗證，避免為manual-local acceptance改動正式template repository live state。

## Isolated Fixture

- Source implementation commit：`44d25f4a1a9ca7a5d2764e6243e7e01a7a026ce5`。
- Disposable infrastructure fixture commit：`8545876d19c4f3569e824398cc7c3b91326a5cf9`。
- Final disposable product fixture commit：`d3601e7ebe7a27373274af2ababa4ddbfd023df1`。
- Product name：`Milestone 38 Manual Local Fixture`。
- Product VERSION：`0.1.0`。
- Template provenance：`MagicalWater/flutter_architecture` / baseline `1.18.0`。
- CI profile：`manual-local`。
- Artifact product key：`m38_manual_local_fixture`。

## Atomic Bootstrap Evidence

1. Canonical `repository_kind`在infrastructure/profile mutation與representative local quality acceptance期間保持`template`。
2. `repository_infrastructure.json`先產品化為：
   - `ci_execution_mode = manual-local`；
   - `artifact_store.product_key = m38_manual_local_fixture`；
   - `self_hosted_runner.disposition = not-applicable`；
   - `github.branch_protection = explicit-deferred`；
   - `github.fork_pr_policy = not-applicable`；
   - `observability_remote_acceptance.disposition = deferred`。
3. Infrastructure verifier在template lifecycle期間PASS。
4. Corrected classifier direct Python plan與Git for Windows Bash `run_local_ci.sh plan-range`都將manifest-only change判為`focused / governance`，不再誤判`unknown / full`。
5. Selected-profile controlled live disposition owner：
   - missing variable → create `CI_EXECUTION_MODE=manual-local` → fresh read-back `manual-local` PASS；
   - read-back mismatch direct owner PASS，證明mismatch fail closed；
   - 未對正式template GitHub repository做manual-local mutation。
6. 上述profile acceptance完成後才將canonical lifecycle切為`product`並將VERSION切為`0.1.0`。
7. Final product identity與infrastructure verifiers均PASS。
8. 再從final fixture commit建立新的clean managed worktree，不提供前一個worktree狀態；fresh machine admission可直接讀出product identity、template provenance、VERSION、CI profile與artifact product key，兩個verifier再次PASS。

## Representative manual-local Quality Route

以Git for Windows Bash執行repository-owned：

```txt
tools/ci/run_local_ci.sh quality
```

未設定`CI_ARTIFACT_ROOT`，刻意驗證implicit manual-local product-key projection。

結果：

- Run key：`local-20260815t002347z-612-85fa4c4b`。
- Job key：`quality-windows`。
- Commit SHA：`8545876d19c4f3569e824398cc7c3b91326a5cf9`。
- Artifact root：`C:/Users/crazy/AppData/Local/m38_manual_local_fixture/ci-artifacts`。
- Documentation check：PASS。
- `tools/ci`：265 tests PASS。
- Workspace analyze：5 packages PASS。
- Generated consistency：PASS。
- Workspace Flutter tests：5 packages PASS；app suite 493 cases PASS。
- Managed run aggregation：PASS，jobs=1。

Published managed evidence：

```txt
runs/8545876d19c4f3569e824398cc7c3b91326a5cf9/
  local-20260815t002347z-612-85fa4c4b/
    run-manifest.json
    run-summary.md
    jobs/quality-windows/
      manifest.json
      summary.md
      checksums.sha256
      artifacts/quality/quality-result.txt
```

Fresh checksum verification：3 entries，0 mismatch。Job manifest與run manifest皆為`result=success`，commit SHA皆精確綁`8545876d19c4f3569e824398cc7c3b91326a5cf9`，job execution mode為`manual-local`。

## Review Findings

- P0：0。
- Undisposed P1：0。
- 第一輪使用plain `bash`時Windows環境解析到WSL，造成Windows Git worktree `.git` pointer被錯誤解析並產生假性的`unknown/full`結果；改用repository支援的Git for Windows Bash後，結果與direct Python planner一致。此為operator shell selection問題，不是classifier regression。
- Representative quality route的build_runner在disposable Windows working tree造成generated files換行噪音；這些檔案未納入任何fixture commit。Final clean-worktree admission從committed authority重新建立，狀態clean。
- `manual-local`不等同「GitHub CI PASS」；本Task只接受repository-owned local managed route與受控live-variable read-back contract。

## Disposition

Task 38-7：**ACCEPTED**。

`manual-local`產品bootstrap已證明：tracked infrastructure可產品化、validation routing不會誤升級、implicit artifact root使用產品key、managed evidence可校驗、selected-profile acceptance先於product lifecycle finalization，且final product可由fresh clean checkout自行admit。
