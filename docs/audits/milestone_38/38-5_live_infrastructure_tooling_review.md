---
document_type: phase-review
status: active
authoritative_for:
  - milestone-38-task-38-5-live-infrastructure-admission-tooling
last_reviewed_baseline: 1.18.0
---

# Task 38-5 — GitHub Live Infrastructure Admission / Read-back Tooling Review

## Scope

建立repository-owned GitHub live infrastructure admission工具，讓bootstrap可對指定`owner/repo`取得sanitized snapshot，並只對已核准的`CI_EXECUTION_MODE`提供可逆mutation＋fresh read-back。

## Test Authoring Disposition

**Required**：新增direct Python owner覆蓋snapshot parsing/sanitization、optional 404、CI mode create/update、invalid mode authorization boundary與read-back mismatch fail closed。

## RED

`python -m unittest tools.ci.test_repository_infrastructure`在implementation前因`tools.ci.repository_infrastructure`不存在而預期失敗。

## Implementation / Security Review

- Read-only snapshot覆蓋repository visibility/default branch、`CI_EXECUTION_MODE`、Actions policy/default token permissions、fork PR contributor approval、default-branch protection、repository-scoped self-hosted runners，以及指定Environment required secret names。
- Snapshot主動丟棄GitHub numeric object IDs、API URLs、runner label IDs、secret timestamps與任何非必要payload。
- Environment secrets只使用GitHub list-secrets response的`name`；工具不存在讀取／輸出secret value的code path。
- Optional 404（variable／branch protection／environment）轉為absent state，不冒充configured。
- Mutation目前只允許`manual-local | self-hosted | github-hosted`三種`CI_EXECUTION_MODE`；unknown/legacy值在任何request前拒絕。
- Existing variable使用PATCH；missing variable使用POST；兩者都在mutation後fresh GET並精確比對expected，mismatch拋出`ReadBackMismatchError`。
- 工具沒有runner delete、Environment delete、secret write/delete、credential rotation、signing material或Branch Protection mutation入口。
- Open P0：0。
- Undisposed P1：0。

## Official API Contract Verification

Implementation endpoint shape已對照GitHub官方REST文件：repository Actions permissions/default workflow permissions、fork PR contributor approval、repository variables、repository-scoped runners、deployment environments與environment secret-name listing。

## Controlled Live Read-only Smoke

對`MagicalWater/flutter_architecture`執行read-only snapshot：PASS。

Fresh safe fields顯示：

- visibility：`public`；default branch：`main`；
- `CI_EXECUTION_MODE = self-hosted`；
- default workflow permission：`read`；`can_approve_pull_request_reviews = false`；
- Actions policy為selected；
- Branch Protection存在，force push／deletion disabled；
- repository-scoped runner labels包含`self-hosted, macOS, ARM64, flutter-architecture, trusted-main`，snapshot當下status為`offline`；
- `staging-observability` Environment存在，當前workflow需要的7個secret names均存在；未輸出secret value。

此smoke只驗證tool transport／sanitization，不構成Task 38-8 self-hosted isolated product acceptance。

## Validation

- `python -m unittest tools.ci.test_repository_infrastructure`：PASS，6 tests。
- Task candidate planner：`validation_level = focused`；required Python scopes為`tools`、`tools/docs`、`tools/ci/repository_infrastructure.py`與`tools/ci/test_repository_infrastructure.py`，另要求`docs_check`與`git diff --check`；不要求Flutter analyze/tests/generated或Android/iOS build。
- `python -m unittest discover -s tools -p "test_*.py"`：PASS，11 tests。
- `python -m unittest discover -s tools/docs -p "test_*.py"`：PASS，85 tests。
- `dart run melos run docs_check`：PASS。
- `git diff --check`：PASS。
- 額外非planner-required的`tools/ci` holistic probe執行261 tests，發現1個existing stale owner：`test_ci_execution_mode_contract.test_self_hosted_policy_is_main_or_manual_only`仍要求舊的literal `vars.CI_EXECUTION_MODE == 'github-hosted'`，而current public-repository-compatible workflow已改用`contains([self-hosted, github-hosted], vars.CI_EXECUTION_MODE)`。此finding屬Task 38-6 CI profile runtime contract scope，未修改Task 38-5 live tooling behavior。
