---
document_type: final-review
status: accepted
authoritative_for:
  - public-repository-readiness-post-public-visibility-closure
last_reviewed_baseline: 1.18.0
---

# Task 8 — Post-Public Visibility Closure Review

## User authorization and visibility transition

使用者明確授權：

`將 MagicalWater/flutter_architecture 改為 Public`

依該授權執行 GitHub repository visibility transition 後 fresh read-back：

- Repository：`MagicalWater/flutter_architecture`。
- Visibility：`PUBLIC`。
- Default branch：`main`。
- GitHub Template：`isTemplate = true`。
- Template Baseline：`1.18.0`。
- `repository_identity.json` lifecycle authority仍維持`repository_kind = template`。

Visibility transition沒有改變template lifecycle authority、default branch或published 1.18.0 baseline。

## Post-Public fork PR approval hardening

Private期間不可使用的fork PR contributor approval API在Public後可用。

Fresh admission值：

`approval_policy = first_time_contributors`

為避免已曾貢獻過的external contributor直接觸發workflow，依Public repository security baseline收緊為：

`approval_policy = all_external_contributors`

Update後使用GitHub API fresh read-back確認已生效。

## Post-Public Actions allowlist hardening

Visibility切換前已啟用：

- `sha_pinning_required = true`。
- Default `GITHUB_TOKEN` permissions = `read`。
- `can_approve_pull_request_reviews = false`。

Public後進一步把Actions policy從：

`allowed_actions = all`

收緊為：

`allowed_actions = selected`

Selected policy：

- GitHub-owned Actions：allowed。
- Verified Marketplace creators blanket allowance：disabled。
- Explicit third-party pattern：`subosito/flutter-action@*`。
- Full-length commit SHA enforcement：仍為`true`。

Current repository workflows使用的外部Actions只有GitHub-owned `actions/*`與`subosito/flutter-action`，且所有`uses:`目前都固定完整commit SHA，因此此設定不破壞current workflow dependency contract。

## Main branch minimum protection

Public後branch protection API可用；fresh admission顯示`main`原先沒有branch protection。

為保留既有trusted direct push / local self-hosted CI操作模式，不導入PR-only或required status checks，但啟用最低保護：

- force push：disabled。
- branch deletion：disabled。
- admin enforcement：disabled。
- required pull request reviews：未啟用。
- required status checks：未啟用。
- lock branch：disabled。

此設定阻止破壞性history rewrite / branch deletion，同時不改變目前正常trusted direct push到`main`的操作模式。

## Self-hosted runner boundary

Post-Public fresh read-back仍只有1台repository-level self-hosted runner：

- `water-mac-flutter-architecture`。
- macOS / ARM64。
- Labels包含`flutter-architecture`與`trusted-main`。

Repository security regression與current workflow contract已確認：

- Public `pull_request`一律進GitHub-hosted runner。
- Pull request path不會選到`trusted-main` self-hosted runner。
- Main push仍可依`CI_EXECUTION_MODE=self-hosted`使用trusted local runner。
- Explicit trusted `workflow_dispatch`仍可選self-hosted execution。
- Repository沒有`pull_request_target`。

## Environment disposition

`staging-observability` Environment post-Public fresh read-back：

- Environment存在。
- Firebase provider secret names仍只存放於Environment scope。
- `protection_rules = []`。
- `can_admins_bypass = true`。

Secret-consuming jobs仍只允許explicit `workflow_dispatch` + `remote_acceptance == true` path；PR-safe job不讀provider secrets，Public fork PR無法進入secret-consuming job。

Required reviewer沒有在本次強制加入，原因是這會改變trusted manual acceptance操作模型，且不是Public exposure blocker。若未來需要更嚴格的remote observability approval，可在有獨立reviewer ownership後另開治理Task。

## Post-Public verification

Fresh GitHub read-back已確認：

- visibility=`PUBLIC`。
- `isTemplate=true`。
- default branch=`main`。
- fork PR approval=`all_external_contributors`。
- Actions=`selected`。
- SHA pin enforcement=`true`。
- default `GITHUB_TOKEN`=`read`。
- main force push=`false`。
- main deletion=`false`。

Repository-side final verification：

- Public repository security / CI contract suite：64 PASS。
- `docs_check`：PASS。
- repository identity check：PASS。
- `git diff --check`：PASS。

Cross-platform full matrix已於exact Public PR corrective commit `c7ce70c316a9a8a4682b75d01d7d2af3bfd410cb`完成且PASS；Task 8只修改GitHub live settings與governance evidence，不重新改變production/runtime source。

## Findings

- Open P0：0。
- Undisposed P1：0。
- Real secret exposure：0。
- Public PR → trusted self-hosted exposure：0。
- Public PR privileged secret exposure：0。
- Visibility blocker：0。
- Remaining mandatory post-Public blocker：0。

Task 8：**ACCEPTED / CLOSED**。

