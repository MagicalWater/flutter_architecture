---
document_type: implementation-plan
status: accepted
authoritative_for:
  - milestone-30-test-suite-audit-rationalization-governance-plan
last_reviewed_baseline: 1.11.0
---

# Milestone 30 — Test Suite Audit, Rationalization & Governance Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 建立可重現的repository測試盤點與coverage ownership，分離production／historical implementation，依replacement evidence受控精簡測試，並建立長期test governance與execution tiers。

**Architecture:** 先建立inventory與baseline，再處理Persistence historical boundary，接著分別rationalize Auth與Catalog；只有在重複已被證明後才抽取shared fixture。最後審查CI／Platform contracts、優化execution matrix、執行controlled cleanup、建立governance並完成全量holistic regression。

**Tech Stack:** Flutter／Dart test、Python unittest、Melos、Drift、sqflite historical harness、GitHub Actions YAML、repository documentation governance。

---

## Global execution rules

每個Task都必須依序完成：

```txt
implementation
→ focused review
→ findings
→ fix
→ focused re-review
→ whole-task holistic review
→ documentation authority check
→ validation
→ Open P0 = 0
→ Open P1 without disposition = 0
→ independent commit
→ next Task
```

禁止：

- 以case／LOC下降作為唯一成果。
- 無replacement evidence刪除測試。
- 將historical sqflite migration／rollback harness視為一般legacy garbage。
- 建立跨domain generic test framework。
- 因單檔過長而機械拆檔。
- 未量測就把deterministic tests移到manual／nightly。

## Task 30-1 — Implementation Plan

**Files:**

- Create: `docs/superpowers/plans/2026-07-24-milestone-30-test-suite-audit-rationalization-governance.md`
- Create: `docs/audits/milestone_30/30-1_implementation_plan_review.md`
- Modify: `docs/roadmap/active.md`
- Modify: `docs/superpowers/README.md`

- [ ] 對照Spec逐項確認Task coverage、順序、validation與commit boundary。
- [ ] 完成placeholder、scope、type／path一致性自我審查。
- [ ] 執行`dart run melos run docs_check`與`git diff --check`。
- [ ] 記錄focused／whole-task review與P0／P1 disposition。
- [ ] Commit：`docs(test): 完成Milestone 30實作計畫`。

## Task 30-2 — Test Inventory, Ownership and Baseline

**Files:**

- Create: `tools/testing/test_inventory.py`
- Create: `tools/testing/test_test_inventory.py`
- Create: `docs/audits/milestone_30/30-2_test_inventory.md`
- Create: `docs/audits/milestone_30/30-2_review.md`
- Modify: `melos.yaml` only if a stable inventory command is required.

**Required inventory fields:**

```txt
path, suite, type, loc, static_cases, primary_category,
coverage_owner, implementation_classification, execution_tier,
disposition, replacement_or_notes
```

- [ ] Write Python unit tests for path discovery, Dart／Python case counting, LOC counting and deterministic sorting.
- [ ] Run the focused test and verify it fails before implementation.
- [ ] Implement repository-relative inventory generation without third-party dependencies.
- [ ] Generate a complete baseline covering exactly all tracked test files.
- [ ] Manually classify primary owner、production／historical status與initial disposition by test group; do not auto-infer destructive decisions from file names.
- [ ] Record baseline runtime commands and results.
- [ ] Validate with `python3 -m unittest tools.testing.test_test_inventory`, inventory generation, `docs_check` and focused Flutter smoke.
- [ ] Commit：`test(governance): 建立測試盤點與ownership基線`。

## Task 30-3 — Historical and Persistence Boundary Audit

**Files:**

- Modify／move only after evidence:
  - `apps/flutter_architecture/test/support/historical_sqflite_*.dart`
  - `apps/flutter_architecture/test/app/database/*migration*test.dart`
  - `apps/flutter_architecture/test/features/auth/data/stores/sqflite_auth_user_store_test.dart`
  - `apps/flutter_architecture/test/features/auth/data/auth_single_active_user_persistence_test.dart`
  - `apps/flutter_architecture/test/features/catalog/data/catalog_*test.dart`
- Create: `docs/audits/milestone_30/30-3_persistence_boundary_audit.md`
- Create: `docs/audits/milestone_30/30-3_review.md`

- [ ] Enumerate every sqflite import／historical adapter reference and classify it as migration oracle, rollback oracle, fixture integrity, historical implementation contract, accidental production fixture, or unrelated text reference.
- [ ] Keep v1～v6 fixture／migration／rollback coverage unchanged before rewriting general feature tests.
- [ ] Define replacement owners for current AuthUser and Catalog persistence integration.
- [ ] Make historical tooling paths／names explicit where needed; preserve executable evidence.
- [ ] Resolve `tools/milestone_19_5/test_auth_fixture_server.py` as current CI, documented manual tooling, or archive; define a working command.
- [ ] Validate historical migration、rollback、fixture integrity、no-sqflite production authority and focused production Drift tests.
- [ ] Commit：`test(database): 明確化production與historical測試邊界`。

## Task 30-4 — Auth Test Rationalization

**Files:**

- Modify／split only by responsibility:
  - `packages/auth/test/auth_credential_migration_coordinator_test.dart`
  - `packages/auth/test/auth_repository_persistence_test.dart`
  - `packages/auth/test/auth_session_refresher_test.dart`
  - `packages/auth/test/auth_session_refresher_secure_lifecycle_test.dart`
  - `packages/api_client/test/auth_refresh_interceptor_test.dart`
  - Auth adapter／local unlock tests under `apps/flutter_architecture/test/`
- Create focused helpers under existing package `test/support/` only when at least two files share a stable fixture.
- Create: `docs/audits/milestone_30/30-4_auth_rationalization.md`
- Create: `docs/audits/milestone_30/30-4_review.md`

- [ ] Build an Auth invariant matrix covering credential authority, migration, login／logout generation, refresh, replay, cleanup, redaction and local unlock.
- [ ] Identify duplicate call-order／identity／corruption cases and nominate one primary owner for each.
- [ ] Rewrite current persistence integration to use Drift or narrow fake contracts as defined by Task 30-3.
- [ ] Split large files only when authority resolution、migration transaction、cleanup diagnostics、concurrency or replay eligibility have distinct fixtures／failure domains.
- [ ] Preserve unknown error identity／stack and sensitive-data redaction coverage.
- [ ] Run all Auth package、API client Auth and App Auth tests after each focused edit.
- [ ] Commit：`test(auth): 收斂Auth測試ownership與重複coverage`。

## Task 30-5 — Catalog Test Rationalization

**Files:**

- Modify／split only by responsibility:
  - `apps/flutter_architecture/test/features/catalog/data/catalog_local_data_source_test.dart`
  - `apps/flutter_architecture/test/features/catalog/data/catalog_repository_cache_test.dart`
  - `apps/flutter_architecture/test/features/catalog/data/catalog_data_layer_test.dart`
  - `apps/flutter_architecture/test/features/catalog/data/catalog_logout_persistence_test.dart`
  - `apps/flutter_architecture/test/features/catalog/presentation/bloc/catalog_bloc_test.dart`
  - `apps/flutter_architecture/test/features/catalog/presentation/pages/catalog_view_test.dart`
- Create: `docs/audits/milestone_30/30-5_catalog_rationalization.md`
- Create: `docs/audits/milestone_30/30-5_review.md`

- [ ] Build a Catalog invariant matrix for page transaction, chain revision, cursor protocol, cache policy, emission order, cancellation, reconnect and rendering.
- [ ] Move current persistence integration to Drift; retain historical sqflite only in Task 30-3 oracle paths.
- [ ] Remove only cross-layer cases with identical owner and failure signal; keep layer-specific responsibilities.
- [ ] Split large files by initial／append／refresh／reconnect or persistence／policy responsibilities only when readability and fixture isolation improve.
- [ ] Preserve concurrency, stale completion, corruption cleanup and logout-public-cache invariants.
- [ ] Run all Catalog tests plus database migration focused tests.
- [ ] Commit：`test(catalog): 收斂Catalog跨層coverage與Drift路徑`。

## Task 30-6 — Shared Fixtures and Focused Contract Extraction

**Files:**

- Create／modify narrowly scoped files under:
  - `packages/auth/test/support/`
  - `packages/api_client/test/support/`
  - `apps/flutter_architecture/test/support/`
  - `tools/ci/test_support/` only if Python module boundaries remain simple.
- Create: `docs/audits/milestone_30/30-6_shared_fixture_review.md`

- [ ] Extract only helpers proven duplicated by Tasks 30-4／30-5.
- [ ] Prefer typed builders、recording stores、fake clocks、in-memory Drift setup and workflow loaders.
- [ ] Keep scenario names and assertions in test files.
- [ ] Reject any abstraction that hides domain terminology or asserts multiple layers.
- [ ] Validate all consumers and compare inventory／LOC without treating reduction as the acceptance gate.
- [ ] Commit：`test(governance): 抽取有界共享測試fixture`。

## Task 30-7 — Platform, CI, Documentation and Generated Contract Audit

**Files:**

- Modify as evidence requires:
  - `tools/ci/test_*.py`
  - `tools/docs/test_check_docs.py`
  - `.github/workflows/*.yml`
  - platform contract Dart tests
- Create: `tools/ci/test_support/workflow_contract.py` only if repeated loading／section extraction is proven.
- Create: `docs/audits/milestone_30/30-7_platform_ci_contract_audit.md`
- Create: `docs/audits/milestone_30/30-7_review.md`

- [ ] Map every workflow／classifier／execution mode assertion to a primary owner.
- [ ] Consolidate repeated raw file loading and focused section extraction without building a YAML DSL.
- [ ] Keep stable required job names、fail-safe classifier behavior、runner routing、generated consistency and platform identity gates.
- [ ] Remove duplicate assertions only when the same failure remains caught by the primary owner.
- [ ] Run all CI Python tests、docs checker、platform Dart contracts and generated verification.
- [ ] Commit：`test(ci): 收斂平台與workflow contract ownership`。

## Task 30-8 — Execution Matrix and Cost Optimization

**Files:**

- Modify only if evidence supports:
  - `tools/ci/change_classifier.py`
  - `.github/workflows/ci.yml`
  - `.github/workflows/android.yml`
  - `.github/workflows/ios.yml`
  - `tools/ci/run_local_ci.sh`
- Create: `docs/audits/milestone_30/30-8_execution_matrix.md`
- Create: `docs/audits/milestone_30/30-8_review.md`

- [ ] Measure per-suite runtime at least twice after rationalization.
- [ ] Assign each suite to Tier 1～5 and identify current CI routing.
- [ ] Keep deterministic Dart／Python tests in related CI unless measured evidence demonstrates material cost.
- [ ] Ensure database-critical and test-governance changes fail-safe to full／historical gates.
- [ ] Add or update classifier tests before changing routing.
- [ ] Validate docs-only、source、database、native、classifier、unknown path and invalid range scenarios.
- [ ] Commit：`ci(test): 優化測試執行矩陣與fail-safe路由`。

## Task 30-9 — Controlled Cleanup and Deletion Manifest

**Files:**

- Create: `docs/audits/milestone_30/30-9_deletion_manifest.md`
- Create: `docs/audits/milestone_30/30-9_review.md`
- Modify／delete only files already dispositioned in Tasks 30-2～30-8.

- [ ] For every Delete／Merge record old coverage, reason, replacement owner, replacement test and validation.
- [ ] Execute cleanup in small groups with focused regression after each group.
- [ ] Regenerate inventory and compare owner／tier／historical references.
- [ ] Confirm no migration fixture、security invariant、concurrency or platform gate disappeared without replacement.
- [ ] Commit：`test(governance): 執行受控測試清理與替代驗證`。

## Task 30-10 — Governance and Adoption Documentation

**Files:**

- Create: `docs/guides/testing_governance.md`
- Modify: `docs/README.md`
- Modify: `AGENTS.md` only with a short navigation／mandatory command summary.
- Modify relevant package／feature README only where local test routes need clarification.
- Create: `docs/audits/milestone_30/30-10_governance_review.md`

- [ ] Document taxonomy、primary owner、production／historical boundary、disposition contract、large-file rule and execution tiers.
- [ ] Document how to add, move, merge, delete and archive tests.
- [ ] Document inventory and deletion-manifest commands.
- [ ] Keep one authoritative guide; other files only route or summarize.
- [ ] Run docs check and link／authority review.
- [ ] Commit：`docs(test): 建立測試治理與採用指南`。

## Task 30-11 — Holistic Regression and Final Review

**Files:**

- Create: `docs/audits/milestone_30/30-11_final_review.md`
- Modify: `docs/roadmap.md`
- Modify: `docs/roadmap/active.md`
- Modify: `docs/project_context.md`
- Modify: `docs/milestones/README.md`
- Modify: `docs/superpowers/README.md`
- Modify: `CHANGELOG.md`
- Modify: `VERSION` according to final release policy.

- [ ] Compare before／after inventory、owner matrix、historical references、runtime and deletion manifest.
- [ ] Run dependency resolution、inventory tests、all Python contracts、docs check、analyze、full Flutter regression and generated consistency.
- [ ] Run focused historical migration／rollback and no-sqflite authority gates.
- [ ] Run representative bundle／platform validation according to change-aware classification.
- [ ] Perform cross-Task architecture、authority and coverage-hole review.
- [ ] Resolve all findings and repeat affected validation.
- [ ] Confirm Open P0 = 0 and Open P1 without disposition = 0.
- [ ] Commit final review and release with Conventional Commit in Traditional Chinese.
- [ ] Do not push until the user explicitly requests it.

