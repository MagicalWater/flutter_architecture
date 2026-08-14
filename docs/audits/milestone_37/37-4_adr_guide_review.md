---
document_type: phase-review
status: completed
authoritative_for:
  - milestone-37-task-37-4-adr-guide-review
last_reviewed_baseline: 1.17.0
---

# Milestone 37 Task 37-4 — ADR-030 and Human Adoption Procedure Review

## Scope

本 Task 建立 stable repository lifecycle decision `ADR-030`、窄版 `Template Repository Adoption Guide`，並在 Quick Start 提供最小 newcomer prompt。Native identity 的 exact procedure仍由既有 `native_environment_adoption.md` 擁有。

## Test Authoring Decision

Disposition：**Should-not-add** prose snapshot tests。

理由：本 Task沒有新增 runtime behavior；ADR／Guide wording不應逐句 snapshot。Direct machine behavior已由 Task 37-1～37-3 的 repository identity／routing tests擁有。本 Task使用 ADR index、docs checker、link／stale-route search與authority review驗證。

## Focused review findings

### M37-37-4-F01 — stale native identity Quick Start route

初版把 Quick Start 原「正式把模板採用成產品」拆成：

1. GitHub Template Repository → product repository bootstrap；
2. bounded cross-platform native product identity adoption。

但 `native_environment_adoption.md`仍引用舊場景名稱，可能讓 newcomer 跳過 repository bootstrap route。

Disposition：**FIXED**。Native guide現在明確：首次 repository birth先進 `template_repository_adoption.md`；只做 native identity 時指向新的 Quick Start native scenario。

## Authority review

- `repository_identity.json`：仍是 lifecycle／template provenance唯一 machine authority。
- `VERSION`：仍是 current repository version唯一 authority。
- ADR-030：只保存 stable lifecycle decision，不保存 mutable product identity values。
- Template Repository Adoption Guide：只保存 human procedure，不建立 machine state engine。
- `adopting-template-repository`：只 orchestration首次 bootstrap。
- `adopting-template-product-identity`＋`environments.json`＋ADR-014／025：仍擁有 Android／iOS native identity mapping。
- Quick Start：只提供入口與 copyable prompt，不複製完整 procedure。
- MVP／Feature／產品 roadmap：未納入本 Task。

Open P0：0。

Open P1 without disposition：0。

## Fresh validation

Planner candidate：`14d032d1e5af81fc5a20bb4ac70d81b79b360132`

```text
change_classes=[docs_content,governance]
validation_level=focused
fail_safe=false
python_test_scopes=[tools/docs]
docs_check=true
android_build=false
ios_build=false
```

Fresh evidence：

```text
ADR/docs checker focused suite: PASS
docs_check: PASS
git diff --check: PASS
stale "ADR-001至ADR-029" route: none
stale "正式把模板採用成產品" route: none
```

## Whole-Task decision

**ACCEPTED.** ADR、Guide、Quick Start與native identity Guide的ownership一致，可進入 Task 37-5 Template Repository Current-Authority Integration。
