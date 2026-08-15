---
document_type: phase-review
status: accepted
authoritative_for:
  - milestone-38-task-38-10-fresh-no-handoff-product-admission
last_reviewed_baseline: 1.18.0
---

# Task 38-10 — Fresh No-Handoff Product Admission & Negative Corpus

## Disposition

Task 38-10：**ACCEPTED**。

本Task驗證產品repository完成首次bootstrap後，fresh context可只依repository current authority重新判斷lifecycle、selected CI profile、artifact strategy與live dependency disposition，不需要本conversation handoff；同時missing／invalid infrastructure state必須fail closed。

## Fresh Admission Evidence

### manual-local

- 由Task 38-7 final product commit建立fresh clean managed worktree。
- fresh context直接讀出：
  - `repository_kind = product`；
  - Product Repository Version `0.1.0`；
  - `template_origin = MagicalWater/flutter_architecture@1.18.0`；
  - `CI_EXECUTION_MODE = manual-local`；
  - managed-local artifact strategy與product-scoped `product_key`。
- repository identity與infrastructure verifier均PASS；不依賴前一個acceptance worktree狀態。

### self-hosted

- Current Task 38-8 live evidence仍為`BLOCKED_EXTERNAL`：source-template runner可fresh read-back，但product-scoped trusted Mac runner runtime尚未完成。
- fresh admission不得把template runner當成product runner，也不得把runner offline／Mac connector不可用解讀為bootstrap完成。
- machine authority要求`self-hosted` product具有configured runner disposition；runner缺失／未完成時fail closed。
- 因此fresh context能正確指出required live dependency，而不是重跑或假裝完成首次Template adoption。

### github-hosted

- Task 38-9建立private disposable GitHub product repository並完成final product transition。
- 另從remote重新clone至fresh checkout；`main == origin/main == 51a8e0746a662a1a9b7a7d701d0d330549368f45`。
- fresh context直接驗證：
  - product identity與`0.1.0`；
  - `CI_EXECUTION_MODE = github-hosted`；
  - Actions token default為read-only；
  - private repository fork-approval capability不適用；
  - Branch Protection因GitHub plan unavailable而明確標示`unavailable=plan`；
  - repository runners為空集合。
- docs、repository identity與repository infrastructure verifier全部PASS。

## Negative Corpus

Automated admission／routing owners：

```text
python -m unittest \
  tools.docs.test_repository_infrastructure \
  tools.docs.test_template_repository_bootstrap_atomic_lifecycle \
  tools.docs.test_template_repository_bootstrap_routing \
  tools.ci.test_repository_infrastructure \
  tools.ci.test_ci_execution_mode_contract \
  tools.ci.test_public_repository_security_contract
```

Result：**43 tests PASS**。

Coverage包含：

- missing `repository_infrastructure.json` fail closed；
- unknown CI mode fail closed；
- self-hosted without configured runner disposition fail closed；
- live `CI_EXECUTION_MODE` create/update後read-back mismatch fail closed；
- secret-shaped field/value不得持久化進tracked manifest；
- private-repository unavailable capability不得被誤報為configured；
- product lifecycle finalization前必須完成selected-profile infrastructure disposition；
- fresh routing先讀repository identity與infrastructure authority；
- 已是`repository_kind=product`時，再要求「首次Template adoption」不得直接重跑bootstrap，而必須回中央`governing-template-development`重新分類。

## Review

- automated machine owners先行，fresh clone/worktree evidence只作no-handoff behavioral proof，不取代tests。
- 沒有secret value被讀取、複製或寫入evidence。
- self-hosted external blocker被保留為Task 38-8 disposition，不污染manual-local／github-hosted acceptance，也不被本Task重新解釋為成功。

結論：Task 38-10 acceptance criteria滿足，**ACCEPTED**。
