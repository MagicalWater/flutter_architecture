---
document_type: phase-review
status: completed
authoritative_for:
  - milestone-37-task-37-3-bootstrap-routing-skill
last_reviewed_baseline: 1.17.0
---

# Milestone 37 Task 37-3 — Central Admission Routing and Bootstrap Skill Review

## Scope

本 Task 讓 fresh Agent admission先讀 `repository_identity.json`，新增薄型 `adopting-template-repository` Skill與pressure scenarios，並把human Skill registry對齊首次 Template → Product bootstrap route。

## RED evidence

新增 `tools/docs/test_template_repository_bootstrap_routing.py` 後首次執行：

```text
6 tests
2 failures
2 errors
```

失敗點精準落在預期缺口：

- 新 bootstrap Skill不存在；
- pressure scenarios不存在；
- central governance未讀 `repository_identity.json`／未路由新 Skill；
- human registry未登錄新 Skill。

既有 `adopting-template-product-identity` 不擁有 `repository_kind`／template provenance 的 negative owner當時已 PASS。

## Focused review

- Central authority：PASS。`governing-template-development`仍是唯一 classification／approval入口。
- Fresh admission：PASS。`AGENTS.md` fixed minimum set新增 `repository_identity.json`。
- Lifecycle fail-closed：PASS。missing／malformed／unknown state不得由remote、folder、README或bundle identifier猜測。
- Bootstrap trigger：PASS。只允許 `template` state + accepted首次產品採用 Requirement Decision。
- Product-state guard：PASS。`product` repo再次要求首次 bootstrap會回中央治理重新分類，不重跑生命周期轉換。
- Native identity delegation：PASS。Android／iOS product identity仍委派 `adopting-template-product-identity`；新 Skill不保存native mapping。
- Scope containment：PASS。API-only、visual-only、單一平台 repair、discussion-only均為negative scenarios。
- Atomic boundary：PASS。blocking validation完成前canonical state保持 `template`。
- Open P0：0。
- Open P1 without disposition：0。

## Fresh validation

Planner candidate：

```text
change_classes=[governance,test_only]
validation_level=focused
fail_safe=false
android_build=false
ios_build=false
python_test_scopes=[tools/docs, tools/docs/test_template_repository_bootstrap_routing.py]
docs_check=true
```

Fresh execution：

```text
tools/docs: 73 PASS
bootstrap routing focused: 7 PASS
docs_check: PASS
git diff --check: PASS
```

## Machine discovery evidence

以 candidate commit `686a05dbbe965cd423aac18f7b7d7e8e4f1fced5` 建立 disposable clean managed worktree並 fresh `open_workspace`。

Fresh inventory 明確列出：

```text
adopting-template-repository
→ .agents/skills/adopting-template-repository/SKILL.md
```

同一 fresh admission載入的 `AGENTS.md` minimum set亦包含：

```text
repository_identity.json
```

因此 discovery evidence不是由本 conversation cache或單純檔案存在推定。

## Whole-Task decision

**ACCEPTED.** Task 37-3符合 accepted Design／Plan：repository lifecycle與native identity沒有形成parallel authority，fresh Agent可從machine state開始 routing。新 Skill目前以 `Pilot` 登錄，後續 Task 37-7 fresh no-handoff behavioral acceptance與Milestone final review再決定final status。
