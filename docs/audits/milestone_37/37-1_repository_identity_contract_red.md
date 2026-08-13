---
document_type: phase-review
status: completed
authoritative_for:
  - milestone-37-task-37-1-repository-identity-contract-red
last_reviewed_baseline: 1.17.0
---

# Milestone 37 Task 37-1 — Repository Identity Contract RED

## Scope

本 Task 只建立 repository identity lifecycle／fail-closed contract 的 RED owner，不先新增 manifest 或 verifier implementation。

## Test Authoring Decision

Disposition：**Required**。

理由：repository lifecycle 將成為 fresh Agent admission 的 blocking authority；missing／malformed／unknown state、template/product invariant 與版本 authority 若沒有 direct regression owner，會造成 repository 被錯誤分類。

Primary owner：`tools/docs/test_repository_identity.py`。

明確不新增 README wording snapshot、每個 JSON getter test、或重複 Android／iOS environment contract tests。

## Locked RED Scenarios

- missing `repository_identity.json` fail closed；
- malformed JSON fail closed；
- unknown schema／repository kind fail closed；
- template state要求`product_name == null`與 canonical template origin；
- template origin baseline 必須與 `VERSION` 一致；
- product state要求非空 product name、合法 template-origin SemVer、合法 current Product `VERSION`；
- manifest 不得新增 `product_version` 平行 authority；
- lifecycle 不從 README prose、folder 或 remote 猜測；
- valid template／product identity可各自形成乾淨 contract。

## Expected RED

Task 37-2 前 `tools.docs.verify_repository_identity` 尚不存在，因此 focused test 應以 module／implementation missing 失敗。這是預期 RED，不得以 stub 或跳過測試冒充 GREEN。

## Fresh RED Evidence

`python -m unittest tools.docs.test_repository_identity`：**RED / expected**。

唯一 discovery failure：

```txt
ModuleNotFoundError: No module named 'tools.docs.verify_repository_identity'
```

沒有 unrelated baseline failure 混入。

## Validation Planner

以 staged Task tree 建立不移動 branch HEAD 的 candidate commit後執行 planner：

```txt
change_classes: docs_content, test_only
validation_level: focused
docs_check: true
python_test_scopes:
  - tools/docs/test_repository_identity.py
full_regression: false
```

`docs_check`：PASS。`git diff --check`：PASS。Planner-selected Python scope維持上述 expected RED；本 Task 的目的即建立 Task 37-2 必須轉 GREEN 的 regression owner。

## Focused Review

- Contract coverage：PASS。
- Scope containment：PASS。
- Test density：PASS；沒有 README snapshot、getter tests或重複 native identity tests。
- Open P0：0。
- Open P1 without disposition：0。

## Whole-Task Review

- Requirement alignment：PASS。
- Accepted Design alignment：PASS。
- Test Authoring Decision：Required owner已建立。
- Final disposition：**Task 37-1 accepted as RED contract baseline**。

## Acceptance Gate

以上 gate 已完成；可進入 Task 37-2。
