---
document_type: phase-review
status: accepted
authoritative_for:
  - public-repository-secret-ignore-hardening-review
last_reviewed_baseline: 1.17.0
---

# Task 1 — Secret-ignore Policy Hardening Review

## Result

PASS。Root `.gitignore` 已加入 local environment、Android signing、Apple signing/private material、Firebase/provider config 與 service-account 防誤提交規則，並保留 `.env.example` / `.env.*.example` 可追蹤。

## Evidence

- Baseline `.gitignore` 缺少 `google-services.json`、keystore 與 `.env.*` public-readiness guards，作為 RED evidence。
- `tools.ci.test_public_repository_security_contract` 直接以 `git check-ignore` 驗證敏感路徑被忽略、example env 不被忽略。
- Native Firebase environment 既有 local `.gitignore` 保持不變，root policy 為額外防呆層。

## Findings

- P0：0。
- 未處置 P1：0。

