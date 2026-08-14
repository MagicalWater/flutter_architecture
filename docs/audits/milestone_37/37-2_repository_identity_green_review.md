---
document_type: phase-review
status: completed
authoritative_for:
  - milestone-37-task-37-2-review
last_reviewed_baseline: 1.17.0
---

# Milestone 37 — Task 37-2 Repository Identity GREEN Review

## Scope

Task 37-2 建立 `repository_identity.json` 作為 repository lifecycle 與 template provenance 的唯一 machine authority，新增 `tools/docs/verify_repository_identity.py`，並接入既有 `docs_check` pipeline。

Focused review 另發現 validation planner 對新的 root canonical manifest 初始會分類為 `unknown`，造成單純 repository identity 變更 fail-safe 升級到 Android／iOS full matrix。此 finding 在本 Task 內修正：`repository_identity.json` 現由 existing change classifier 明確分類為 `governance`；native identity 仍由既有 environment/native paths 決定 platform gates。

## Review disposition

- Repository identity authority：PASS。沒有新增平行 lifecycle authority。
- Verifier scope：PASS。只處理 schema、template/product invariants、SemVer、projection marker 與 fail-closed；沒有接管 Android／iOS identity 驗證。
- Template invariant：PASS。`repository_kind=template`、`product_name=null`，template origin baseline 與 root `VERSION` 對齊。
- Product-version ownership：PASS。manifest 不保存 product version；current repository version仍只由 `VERSION` 擁有。
- Validation planner integration：PASS。canonical manifest不再落入 `unknown`；classifier本身變更正確要求一次 full matrix。
- Open P0：0。
- Open P1 without disposition：0。

## Fresh validation evidence

Candidate SHA：

```text
5dd4ad891c0ad5925fbbb1a41aa5f3d22851fe32
```

Windows focused／workspace evidence：

```text
Python governance/tooling tests: 65 PASS
repository identity verifier: PASS
docs_check: PASS
environment mapping contract: PASS
full workspace analyze: PASS (5 packages)
full Flutter regression: PASS
app workspace tests: 493 PASS
clean-candidate generated consistency: PASS
Android development debug verification: PASS
Android production release verification: PASS
```

macOS 使用相同 candidate SHA 執行 repository-owned：

```text
bash tools/ci/run_local_ci.sh ios
```

Managed evidence：

```text
run_key=local-20260814t004710z-6306-d47e04cf
job_key=ios-ios
result=success
evidence_status=complete
development iOS verification artifact=PASS
production iOS verification artifact=PASS
artifact_count=278
```

Task 37-2 因 validation-engine classifier change 而要求的 full cross-platform matrix 已完整閉合。

## Final decision

**ACCEPTED.** Task 37-2 可獨立 commit；下一步依 accepted Plan 進入 Task 37-3 Central Admission Routing and Bootstrap Skill。
