---
document_type: phase-review
status: completed
authoritative_for:
  - milestone-37-task-37-6-isolated-bootstrap-acceptance
last_reviewed_baseline: 1.17.0
---

# Milestone 37 Task 37-6 — Isolated Template → Product Bootstrap Acceptance

## Scope

本 Task 以 disposable managed worktree 模擬 GitHub `Use this template` 後的新 repository，使用 accepted Plan 指定的假資料完成一次真正的 Template → Product bootstrap。所有產品 mutation只存在 fixture；template implementation branch本身仍維持 `repository_kind = template`。

Fixture：

```text
Product name: Pickup Basketball Acceptance
Base identifier: com.magicalwater.pickupbasketballacceptance
Development display name: Pickup Basketball Acceptance Dev
Staging display name: Pickup Basketball Acceptance Staging
Production display name: Pickup Basketball Acceptance
Initial product version: 0.1.0
Template origin: MagicalWater/flutter_architecture @ 1.17.0
```

Disposable fixture root：`C:\Users\crazy\.devspace\worktrees\flutter_architecture-bd5b251b`。
Fixture base：`8b3dbd6c128e63993af8d7a0c02157f305b956fc`。

## Test Authoring Decision

Disposition：**Required**。

Direct owners：

- `tools/docs/test_template_repository_bootstrap_atomic_lifecycle.py`：鎖定 template valid → product projections造成 canonical fail-closed → prospective candidate PASS → final canonical product PASS 的 atomic ordering。
- `tools/docs/test_check_docs.py`：鎖定 product README version marker與 prospective product docs validation。
- `tools/docs/test_repository_identity.py`：既有 template/product schema與lifecycle invariant owner。

移除一個錯誤的 routing test：`test_template_manifest_remains_template_during_skill_adoption`。它把「執行 tests 的 repository永遠必須是 template」寫死，會讓真正 product repository bootstrap完成後永遠失敗；template/product lifecycle invariant已有更直接的 identity contract owner，因此此刪除不是 coverage gap。

## Atomic acceptance sequence

Fixture 初始 canonical state：

```text
repository_kind = template
VERSION = 1.17.0
template_origin.baseline = 1.17.0
```

產品 `VERSION`、README／project_context／roadmap／CHANGELOG與 Android／iOS environment projections完成後，canonical manifest刻意仍保持 `template`。此時 canonical verifier回：

```text
[template-origin-baseline-mismatch]
template origin baseline 1.17.0 must equal VERSION 0.1.0
```

這是預期 fail-closed intermediate evidence，不建立第三個 persistent lifecycle state。

之後建立 temporary candidate product manifest，但不覆蓋 canonical path。Fresh prospective validation：

```text
python tools/docs/verify_repository_identity.py . --manifest candidate-product.json
→ PASS

python tools/docs/check_docs.py . --manifest candidate-product.json
→ PASS

python tools/ci/verify_environment_contract.py
→ PASS
```

只有上述 blocking prospective evidence通過後，才把同一 candidate內容寫入 canonical `repository_identity.json`，並立即刪除 temporary candidate。

## Portability findings and disposition

### M37-37-6-F01 — routing test hard-coded template state

Severity：P1。

Product fixture完成 lifecycle transition後，`tools.docs.test_template_repository_bootstrap_routing`失敗，因為 test直接 assert current canonical manifest必須是 `template`。

Disposition：**FIXED**。刪除這個非 routing responsibility assertion；template/product invariants由 repository identity direct tests與本 Task atomic lifecycle test擁有。

### M37-37-6-F02 — docs checker only understood template-era version projection

Severity：P1。

Product fixture `VERSION = 0.1.0` 且 README已轉產品語意後，`docs_check`原本只能解析 `Template Baseline Version`，因此回 `baseline-mismatch`；同時 docs checker沒有 prospective identity manifest入口，無法在 canonical仍為template時驗證candidate product docs。

Disposition：**FIXED**。

- README version projection接受 accepted Design 定義的 `Template Baseline Version` 或 `Product Repository Version`；
- `check_repository()`與 CLI加入 optional prospective identity manifest；
- candidate manifest只影響validation input，不建立 persistent第三狀態；
- focused tests鎖定 final product與prospective docs behavior。

### M37-37-6-F03 — temporary overly-broad product marker alias

Severity：P2。

Corrective過程曾暫時接受 `Product Version` alias；accepted Design的正式語意是 `Product Repository Version`。

Disposition：**FIXED before acceptance**。移除 alias，避免擴張 current authority vocabulary。

Open P0：0。

Open P1 without disposition：0。

## Final isolated product evidence

Canonical transition後：

```text
repository_kind = product
product_name = Pickup Basketball Acceptance
template_origin.repository = MagicalWater/flutter_architecture
template_origin.baseline = 1.17.0
VERSION = 0.1.0
```

Fresh final evidence：

```text
repository identity verifier: PASS
documentation checker: PASS
environment mapping contract: PASS
focused product/bootstrap/native tests: 96 PASS
git diff --check: PASS
```

Native manifest使用：

```text
production = com.magicalwater.pickupbasketballacceptance
development = com.magicalwater.pickupbasketballacceptance.development
staging = com.magicalwater.pickupbasketballacceptance.staging
```

Fixture current docs不再把 current repository描述成 template本體；template provenance與product VERSION分離。

## Whole-Task review

Requirement alignment：PASS。

Atomic lifecycle ordering：PASS。

Native identity delegation／manifest-first contract：PASS。

Product docs／VERSION projection：PASS。

Template provenance preservation：PASS。

No product MVP／Feature／roadmap scope creep：PASS。

**Task 37-6 ACCEPTED.** 下一步是 Task 37-7 fresh no-handoff Agent behavioral acceptance。
