---
document_type: final-review
status: accepted
authoritative_for:
  - public-repository-readiness-live-ci-settings-hardening
last_reviewed_baseline: 1.18.0
---

# Task 7 — Public CI & Live GitHub Settings Hardening Review

## Live GitHub admission

在Template Baseline 1.18.0 Public-readiness branch完成同步與fresh validation後，使用已登入`MagicalWater`帳號的GitHub CLI直接讀取repository live settings。

Admission時repository狀態：

- Repository：`MagicalWater/flutter_architecture`。
- Visibility：`PRIVATE`。
- GitHub Template：`isTemplate = true`。
- Default branch：`main`。
- Repository-level secrets：0。
- Repository variable `CI_EXECUTION_MODE = self-hosted`。
- Repository variable `CI_ARTIFACT_ROOT`仍指向operator local artifact root；只作trusted local CI設定，不是credential。

## Live Actions / runner findings

GitHub Actions live settings原始狀態：

- Actions enabled：Yes。
- `allowed_actions = all`。
- `sha_pinning_required = false`。
- Default `GITHUB_TOKEN` permissions：`read`。
- `can_approve_pull_request_reviews = false`。

Repository-level self-hosted runner：1台：

- `water-mac-flutter-architecture`。
- OS：macOS。
- Labels包含`self-hosted`、`macOS`、`ARM64`、`flutter-architecture`、`trusted-main`。

Current workflows沒有`pull_request_target`，所有`uses:` third-party actions目前已固定到完整commit SHA。

## Public PR CI behavioral finding

Live repository variable為`CI_EXECUTION_MODE=self-hosted`，但pre-corrective`ci.yml`的`classify-changes`只有在：

```text
pull_request && CI_EXECUTION_MODE == github-hosted
```

時才啟動。

因此原contract雖能阻止Public fork PR進入trusted self-hosted runner，但在current live variable下也會讓Public PR完全沒有CI。這不是credential exposure，卻是Public repository adoption behavior defect。

Expected public contract：

- Pull request：always GitHub-hosted。
- Push to main：仍依repository default `CI_EXECUTION_MODE=self-hosted`使用trusted local runner。
- Trusted `workflow_dispatch`：保留explicit execution mode選擇。

## RED / corrective / GREEN

先於`tools/ci/test_public_repository_security_contract.py`新增direct regression owner：

- `test_pull_request_ci_is_not_disabled_by_repository_execution_mode`

RED evidence確認pre-corrective workflow確實把PR activation綁到repository execution mode。

Corrective只修改`.github/workflows/ci.yml`的PR activation expression：

```text
pull_request → always admitted
```

既有`runs-on` expression未改變；其self-hosted selector只接受`push`或`workflow_dispatch`，因此PR仍必然落到`ubuntu-24.04`。Main push與trusted manual local CI behavior未改變。

Corrective commit：

`c7ce70c316a9a8a4682b75d01d7d2af3bfd410cb`

`fix(ci): 確保公開 PR 使用 GitHub-hosted CI`

## Planner-selected fresh full validation

對`4d7563f71423b58b79ab63bb64ca0c0829abf0d7` → `c7ce70c316a9a8a4682b75d01d7d2af3bfd410cb`執行validation planner，change classes為`test_only + validation_engine`，planner明確要求full matrix；未人工縮減。

Fresh evidence：

- Public security / change classifier / secret leakage focused suite：42 PASS。
- Python tools discovery：11 PASS。
- `docs_check`：PASS。
- Full workspace analyze：PASS。
- Full Flutter regression：所有packages PASS；App 493 cases PASS。
- Fresh build_runner：PASS，0 generated outputs。
- Drift v1～v6/current schema、normalization、worker compile與Drift governance tests：PASS；semantic generated diff=0。
- Android production release exact corrective commit：PASS；package id=`com.example.flutterarchitecture`；arm/arm64/x64 symbols present。
- macOS fresh managed worktree exact corrective commit：`c7ce70c...`。
- iOS `Production / Release-production / iphoneos / CODE_SIGNING_ALLOWED=NO`：`BUILD SUCCEEDED`。
- iOS bundle id=`com.example.flutterarchitecture`。
- Unsigned verification app與dSYM set：PASS。

## Live GitHub Actions settings hardening

Current workflow actions均已使用完整commit SHA，故啟用GitHub repository-level SHA pinning enforcement不會改變目前workflow execution semantics。

已將live setting更新為：

- Actions enabled：Yes。
- `allowed_actions = all`（本Task不引入selected-actions maintenance policy）。
- `sha_pinning_required = true`。
- Default `GITHUB_TOKEN` permissions仍為`read`。
- `can_approve_pull_request_reviews`仍為`false`。

Update後以GitHub API fresh read-back確認設定已生效。

## Environment / visibility-related deferred settings

`staging-observability` Environment目前持有Firebase provider secret names，沒有repository-level secret values，也沒有Environment protection rules。

Secret-consuming workflow仍受以下machine contract限制：

- 只允許explicit `workflow_dispatch` remote acceptance path。
- PR-safe job不讀provider secrets。
- External PR不會進secret job或trusted self-hosted runner。

以下live settings無法或不應在repository仍為Private時提前完成：

- Fork PR contributor approval：Private repository API目前拒絕此設定；改Public後再設定strict outside-collaborator approval。
- Main ruleset / branch protection：目前GitHub plan對Private repo API回傳403；改Public後再建立／驗證。
- Environment required reviewer：會改變trusted manual acceptance操作流程，保留為final live-settings decision，不作為目前repository-content security blocker。
- Repository visibility：仍維持Private，必須取得使用者明確最終授權才可切換。

## Findings

- Open P0：0。
- Undisposed P1：0。
- Public PR → trusted self-hosted exposure：0。
- Public PR CI disabled defect：Corrected。
- Privileged secret PR exposure：0。
- Remaining repository-content security blocker：0。
- Remaining user-owned gate：Public visibility + post-Public GitHub settings closure。

Task 7：**ACCEPTED**。
