---
document_type: phase-review
status: active
authoritative_for:
  - milestone-38-task-38-1-infrastructure-contract-red
last_reviewed_baseline: 1.18.0
---

# Task 38-1 — Repository Infrastructure Contract RED

## Scope

本Task只建立Milestone 38 repository infrastructure fail-closed regression owner，不新增manifest、verifier、bootstrap Skill mutation或GitHub live mutation。

## Test Authoring Disposition

**Required**。

Primary owner：`tools/docs/test_repository_infrastructure.py`。

直接鎖定：

- missing／malformed／unknown schema fail closed；
- unknown CI mode／artifact strategy／capability disposition；
- explicit safe `product_key`；
- secret-shaped field/value rejection；
- self-hosted profile要求runner disposition；
- product state不得保留required infrastructure unresolved state；
- canonical template defaults；
- manifest不得持有operator absolute path、runner token或GitHub numeric live object ID。

## RED Expectation

Task 38-1結束時`tools.docs.test_repository_infrastructure`必須因`tools.docs.verify_repository_infrastructure`尚不存在而失敗。這個failure是本Task的預期RED evidence，不得在38-1提前建立production verifier把它轉GREEN。

## Review Gate

- Focused review：確認tests直接對應accepted Design failure modes，沒有為每個JSON getter建立無價值test。
- Whole-Task review：scope只包含RED owner與本evidence；沒有live GitHub side effect。
- Secret review：fixture只使用明顯synthetic token-shaped strings，不含真實credential。
- Open P0：0。
- Undisposed P1：0。

## Validation

Fresh evidence：

```txt
python -m unittest tools.docs.test_repository_infrastructure
python -m unittest tools.docs.test_repository_identity tools.docs.test_template_repository_bootstrap_atomic_lifecycle tools.docs.test_template_repository_bootstrap_routing
git diff --check
```

結果：

- Infrastructure focused suite：**RED as expected**，9 tests / 16 failures；全部由`tools.docs.verify_repository_infrastructure`尚不存在觸發，證明direct owner已建立且尚未被提前實作。
- Existing repository identity／bootstrap baseline：**15 PASS**。
- `git diff --check`：PASS。

## Final Disposition

Task 38-1：**ACCEPTED RED**。下一Task 38-2負責建立canonical manifest／verifier並把同一direct owner轉GREEN。

