---
document_type: final-review
status: accepted
authoritative_for:
  - public-repository-readiness-sha-pinning-compatibility-corrective
last_reviewed_baseline: 1.18.0
---

# Task 9 — SHA Pinning Compatibility Corrective Review

## Trigger

Repository切換Public並完成Task 8 live-settings hardening後，`main@31faa854e93351e371952fcf13403eba931e3502`的GitHub Actions push run出現5個failing checks。

Fresh failed-log review確認這些不是Flutter source、test或generated regression，而是同一個GitHub Actions policy incompatibility：

- Repository-level `sha_pinning_required = true`會遞迴檢查composite/third-party Action內部使用的Actions。
- Repository直接使用的`subosito/flutter-action`已固定完整commit SHA。
- 但該Action內部使用`actions/cache@v4`。
- 此nested reference不受本repository YAML控制，因此GitHub在job setup階段以policy violation拒絕執行。

受影響checks：CI / Quality、CI / Generated Consistency、CI / Tests、CI / Artifact Summary（連帶失敗）、iOS / Simulator Build。

## Corrective disposition

保留Public repository allowlist hardening：

- `allowed_actions = selected`。
- GitHub-owned Actions：allowed。
- Explicit third-party allowance：`subosito/flutter-action@*`。
- Verified creator blanket allowance：disabled。
- Default `GITHUB_TOKEN`仍為read-only。

只取消GitHub repository-level recursive SHA enforcement：

- `sha_pinning_required = false`。

原因是該setting會把repository無法控制的nested Action reference納入強制範圍，與current trusted Flutter setup dependency不相容。

為避免因此降低repository-owned workflow governance，新增direct machine owner：

`tools/ci/test_public_repository_security_contract.py::test_repository_owned_workflow_actions_are_pinned_to_full_sha`

此test要求`.github/workflows/*.yml`中所有非local `uses:` reference都必須是40-character lowercase commit SHA。

## Security disposition

Corrective不重新允許任意third-party Actions：selected-actions allowlist仍在。Public fork PR仍受到external contributor workflow approval、selected-actions policy、repository-owned full-SHA regression、read-only default `GITHUB_TOKEN`與PR → GitHub-hosted runner trust boundary保護。

## Findings

- Root cause：GitHub repository-level recursive SHA enforcement與`subosito/flutter-action` nested `actions/cache@v4`不相容。
- Flutter/runtime regression：0。
- Credential / secret exposure：0。
- Public PR → trusted self-hosted exposure：0。
- Corrective security downgrade：No；selected allowlist與repository-owned full-SHA contract保留。

## Fresh GitHub Actions GREEN verification

Corrective commit：

`6e9987d4e1798c5d5c1c0dd681b17a318cd1abb4`

推送至Public `main`後，fresh GitHub Actions確認原先5個failing checks均恢復：

- CI / Classify Changes：PASS。
- CI / Generated Consistency：PASS（planner判定本次不需generated execution，job安全skip對應steps後成功完成）。
- CI / Tests：PASS（planner判定本次不需Flutter tests，job安全skip對應steps後成功完成）。
- CI / Quality：PASS。
- CI / Artifact Summary：PASS。
- iOS workflow：PASS。
- Android workflow：PASS。
- Observability Acceptance：依既有condition預期SKIPPED，非failure。

因此Task 8造成的repository-level recursive SHA enforcement regression已完成live corrective closure。

Task 9：**CORRECTIVE ACCEPTED / CLOSED**。
