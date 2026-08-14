---
document_type: phase-review
status: completed
authoritative_for:
  - milestone-37-task-37-5-current-authority-integration
last_reviewed_baseline: 1.17.0
---

# Milestone 37 Task 37-5 — Template Repository Current-Authority Integration Review

## Scope

本 Task只把 template 本體的 current authority 對齊 Milestone 37 已接受的 lifecycle contract；不把 template 本身轉成 product，也不建立產品需求、MVP、Feature或產品 roadmap。

同步範圍：

```text
README.md
docs/project_context.md
docs/roadmap.md
docs/roadmap/active.md
docs/README.md
```

## Test Authoring Decision

Disposition：**no-new-test justified**。

本 Task是 current prose／navigation projection，沒有新的獨立 machine failure owner。Repository lifecycle、routing與native delegation已由 Task 37-1～37-3 的 direct tests擁有；本 Task仍執行 identity verifier、docs checker、stale-state search與planner-selected validation。

## Focused review findings

### M37-37-5-F01 — duplicated stale maintenance state

`docs/project_context.md` 前段已宣告 Milestone 37 active，但後段 `Current Work and Maintenance State`仍殘留：

```text
Current active milestone: None
Current phase: Maintenance / Requirement Decision entry
```

這會讓 fresh Agent取得互相衝突的 current authority。

Disposition：**FIXED**。後段已同步為 Milestone 37 execution state，且 minimum reading route同步加入 `repository_identity.json`。

## Authority review

- Root `repository_identity.json` fresh讀取仍為 `repository_kind = template`、`product_name = null`。
- Root `VERSION`仍為 Template Baseline 1.17.0 authority；本 Task沒有改 version。
- Root README明確把 GitHub `Use this template`列為正式 newcomer path，但仍把 current repository描述為 Flutter Enterprise Architecture Template。
- `docs/project_context.md`仍描述 template 本體；只新增 lifecycle authority與adoption route。
- Roadmap只描述 Milestone 37 execution，不建立 product roadmap。
- `docs/README.md`只增加 machine admission與Guide navigation，不複製bootstrap contract。
- Native identity仍路由 `native_environment_adoption.md`。

Open P0：0。

Open P1 without disposition：0。

## Validation

Candidate：`2122cee09be7560cfc46793c300f5f84a11b9b70`

Planner：

```text
change_classes=[docs_content]
validation_level=focused
fail_safe=false
docs_check=true
android_build=false
ios_build=false
full_regression=false
```

Fresh evidence：

```text
repository identity verifier: PASS
docs_check: PASS
git diff --check: PASS
stale Active Milestone=None / Maintenance entry search: none
```

## Whole-Task decision

**ACCEPTED.** Template本體 current authority、machine lifecycle state與newcomer documentation一致，可進入 Task 37-6 isolated Template → Product Bootstrap Acceptance Fixture。
