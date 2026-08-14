---
document_type: phase-review
status: accepted
authoritative_for:
  - public-repository-pr-trust-boundary-review
last_reviewed_baseline: 1.17.0
---

# Task 3 — Public Fork / PR Trust-boundary Review

## Result

PASS。新增 `tools/ci/test_public_repository_security_contract.py` 作 direct regression owner。

Machine contract 鎖定：

- `pull_request` 不可在 `runs-on` 選到 trusted self-hosted runner。
- 真正的 `${{ secrets.* }}` provider secret expressions 只可存在 `workflow_dispatch` trusted jobs。
- 不允許 `pull_request_target`。
- Secret material ignore policy 有 machine regression。

Focused suite：31 tests PASS，包含新 contract、secret leakage、observability acceptance 與 environment workflow matrix。

Initial two failures均為新測試 parser false positive，修正 test owner 後 fresh GREEN；沒有發現 production workflow 漏洞。

## Findings

- P0：0。
- 未處置 P1：0。

