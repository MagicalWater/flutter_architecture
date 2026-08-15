---
document_type: phase-review
status: active
authoritative_for:
  - milestone-38-task-38-9-github-hosted-acceptance
last_reviewed_baseline: 1.18.0
---

# Task 38-9 — Isolated Product Bootstrap Acceptance: github-hosted + GitHub Settings

## Scope

建立真正的private disposable GitHub product repository，驗證tracked `github-hosted` profile、live `CI_EXECUTION_MODE` create/read-back、Actions least-privilege、private-repository feature compatibility、representative PR/main GitHub-hosted routing與final fresh remote-clone admission。

Disposable repository：`MagicalWater/m38-github-hosted-acceptance-20260815`。

## Atomic Lifecycle

1. 從Milestone 38 implementation authority建立獨立repository；live selected-profile acceptance前canonical lifecycle保持`template`。
2. Tracked infrastructure先切為：
   - `ci_execution_mode = github-hosted`；
   - `artifact_store.product_key = m38_github_hosted_fixture`；
   - `self_hosted_runner.disposition = not-applicable`；
   - `github.branch_protection = explicit-deferred`；
   - `github.fork_pr_policy = not-applicable`；
   - observability remote acceptance=`deferred`。
3. Fresh live snapshot最初讀回`CI_EXECUTION_MODE = null`；manager執行create後fresh read-back=`github-hosted`。
4. Live Actions default workflow permissions=`read`，`can_approve_pull_request_reviews=false`。
5. Selected profile PR/main acceptance完成後才finalize：
   - `repository_kind = product`；
   - product name=`Milestone 38 GitHub Hosted Fixture`；
   - VERSION=`0.1.0`；
   - template provenance仍為`MagicalWater/flutter_architecture@1.18.0`。
6. Product docs authority同步：README使用`Product Repository Version：0.1.0`，CHANGELOG建立`0.1.0` entry。

## Private Repository Live-admission Correctives

Real GitHub API acceptance抓出兩個原工具未覆蓋情境，均已回正式Milestone branch做direct regression後再同步fixture：

### Private fork-PR approval endpoint

GitHub private repository不支援fork-PR contributor approval setting。最初snapshot收到`422 Validation Failed`；final contract改為已知`visibility=private`時不呼叫該不適用endpoint，而不是吞掉一般422。

### Branch Protection plan availability

目前帳號方案對private repository Branch Protection API回`403 Upgrade to GitHub Pro or make this repository public...`。Final contract只在`private + exact plan-unavailable diagnostic`下回：

```json
{"present": false, "unavailable": "plan"}
```

一般permission 403 direct owner仍fail closed。

Final `tools/ci` holistic after these corrections：268 tests PASS。

## GitHub-hosted PR Evidence

Disposable PR #1：`acceptance-pr-probe` → `main`，docs-only change。

Observed checks：

- CI / Classify Changes：PASS。
- CI / Quality：PASS。
- CI / Generated Consistency：PASS／planned no-op semantics。
- CI / Tests：PASS／planned no-op semantics。
- iOS / Classify Changes：PASS。
- iOS / Simulator Build：PASS／docs-only no-op contract。
- Observability / PR-safe Contract：PASS。
- Android/iOS provider-symbol jobs與Production Release：按planner／trusted-secret boundary skip。
- 沒有job進入self-hosted runner；沒有production signing/provider secret consumption。

## GitHub-hosted Main Evidence

PR merge head：`7fc184e6a1a4a60af39eda2b7e5f5e7dd3b785f6`。

- CI run `31854223857`：SUCCESS；Quality實際走GitHub-hosted planned validation。
- iOS run `31854223846`：SUCCESS；docs-only Simulator no-op contract正確，Production Release skip。
- Android run `31854223853`：SUCCESS；Android Summary驗證planner skip result。

第一次product lifecycle commit `46f560aa76f1dfe52926d1b61a45dbe8f9d39de7`觸發release planner時，CI / Quality正確因README／CHANGELOG仍保留template version marker而FAIL；failure不是hosted runner問題。Fixture補齊product docs authority後，本機`docs_check`、identity verifier、infrastructure verifier與diff check全PASS。

Final remote product authority：`51a8e0746a662a1a9b7a7d701d0d330549368f45`。

- CI run `31854503380`：SUCCESS；Quality PASS，Generated／Tests依docs-only plan成功no-op。
- Android run `31854503361`：SUCCESS；build jobs按docs-only plan skip，Summary PASS。
- iOS run `31854503339`：SUCCESS；Simulator no-op contract PASS，Production Release skip。
- Observability Acceptance按非manual trusted path安全skip。

## Fresh Remote-clone Admission

從GitHub重新clone `main`到新的local path，不沿用前一checkout：

- clone HEAD=`51a8e0746a662a1a9b7a7d701d0d330549368f45`；
- working tree clean；
- documentation check PASS；
- repository identity verifier PASS；
- repository infrastructure verifier PASS；
- fresh live snapshot：
  - visibility=`private`；
  - default branch=`main`；
  - `CI_EXECUTION_MODE=github-hosted`；
  - Actions default token=`read`；
  - `can_approve_pull_request_reviews=false`；
  - branch protection=`present:false / unavailable:plan`，與tracked `explicit-deferred`相容；
  - runners=[]；
  - secret values未被讀取或保存。

## Review Findings

- P0：0。
- Undisposed P1：0。
- Corrected during acceptance：private fork-approval unsupported endpoint；private branch-protection plan limitation；fixture product docs authority incomplete。
- Production signing／Store distribution仍未進scope。

## Disposition

Task 38-9：**ACCEPTED**。

`github-hosted` profile已在real isolated GitHub product repository證明tracked/live state一致、least-privilege read token、PR/main routing正確、secret/signing boundary安全、private-repository capability limitation可被明確disposition，且final product可由fresh remote clone自行admit。
