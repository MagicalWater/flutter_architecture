---
document_type: phase-review
status: completed
authoritative_for:
  - repository-local-skills-zh-tw-task-5-language-governance-review
last_reviewed_baseline: 1.13.0
---

# Repository-local Skills 中文化治理恢復 Task 5 — Language Governance and Mechanical Enforcement Review

## Task scope

審查繁體中文語言規則、Skill registry、原中文化review與docs checker ownership，並以TDD建立最小mechanical enforcement，避免未來新增英文-only repository-local Skill文件。

## Focused findings

### F-T5-01 — 語言規則只有policy與one-off scan

- Severity：P1。
- Finding：`AGENTS.md`與Skill adoption reference要求繁體中文，但原docs checker只把`SKILL.md`排除於managed metadata檢查，完全不驗證Skill description或reference正文語言。
- Risk：未來新增英文-only Skill仍可通過`docs_check`，重複本次回歸。
- RED：新增兩個tests，分別建立英文-only frontmatter description與英文-onlyreference body；兩者都預期`agent-skill-language`，但實際issues為空，2 tests failed。
- Fix：加入最小`_check_agent_skill_language`：
  - 掃描`.agents/skills/**/*.md`；
  - `SKILL.md` description必須含CJK；
  - 排除frontmatter與fenced code後的正文必須含CJK；
  - 不禁止技術英文，也不嘗試以程式判斷繁簡品質。
- GREEN：3個focused tests passed；全部docs tests由17增為19並全通過。

### F-T5-02 — 原Level 1 review可能仍被誤當current closure authority

- Severity：P1。
- Finding：`repository_local_skills_traditional_chinese_review.md`標記completed，內文直接宣稱Level 1 accepted，沒有supersession route。
- Fix：保留歷史內容，新增historical review notice、Level 3 supersession與Design／Plan／Task／final review routing。
- Fresh re-review：歷史時間線保留，current classification與closure authority轉移至本recovery。

### F-T5-03 — 四個trigger wording變更缺少逐Skill current revalidation route

- Severity：P1。
- Finding：Registry記錄adoption status，但原中文化只提供單一總結review，沒有逐Skill evidence路由。
- Fix：在human governance overview加入2026-07-30 language revalidation section，路由Task 1～5 evidence，並記錄product identity pressure status修正與checker evidence。
- Fresh re-review：四個Skills各有獨立review ownership；registry status本身未被翻譯改變。

### F-T5-04 — Checker能力可能被過度宣稱為「繁體中文判定」

- Severity：P2。
- Finding：CJK presence無法可靠區分繁體與簡體，也不能判斷翻譯品質。
- Fix：issue message明確說明checker只要求Chinese prose，repository policy才要求Traditional Chinese；繁體用字與語意仍由human／agent focused review負責。
- Fresh re-review：mechanical與judgment ownership邊界清楚。

## TDD evidence

### RED

```txt
test_reports_agent_skill_description_without_chinese   FAILED
test_reports_agent_skill_reference_without_chinese     FAILED
reason                                                  agent-skill-language absent
```

### GREEN

```txt
focused agent Skill language tests                     3 passed
full documentation checker tests                       19 passed
docs_check                                              passed
```

## Whole-Task authority review

- `AGENTS.md`仍擁有不可違反的繁體中文policy。
- `skill-adoption-governance.md`擁有Skill文件語言與revalidation process。
- `tools/docs/check_docs.py`只擁有可機械執行的最低CJK presence gate。
- Task 1～4 audits擁有語意review evidence。
- `docs/governance/development_workflow.md`只提供human-readable registry與routing，不複製完整Skill contract。
- 原Level 1 review保留historical evidence，不再擁有current closure authority。

## Modified files

```txt
tools/docs/check_docs.py
tools/docs/test_check_docs.py
docs/governance/development_workflow.md
docs/audits/repository_local_skills_traditional_chinese_review.md
docs/audits/repository_local_skills_zh_tw_task_5_language_governance_review.md
```

## Severity gate

- Open P0：0。
- Open P1 without disposition：0。
- Open P2 without disposition：0。

## Task disposition

```txt
Task 5：Passed after TDD fix and fresh re-review
Mechanical language regression gate：Active
Next：Task 6 — Holistic Final Review and Closure
```
