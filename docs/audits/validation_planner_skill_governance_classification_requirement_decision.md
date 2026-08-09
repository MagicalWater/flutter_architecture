---
document_type: planning-review
status: accepted
authoritative_for:
  - validation-planner-skill-governance-classification-corrective-scope
last_reviewed_baseline: 1.16.0
---

# Validation Planner — Repository-local Skill Governance Classification Requirement Decision

## Requirement Decision

- Request（需求）：確認並修正Validation Planner對repository-local `.agents/skills/**`、Skill lock與third-party Skill provenance路徑的分類，使Skill治理變更執行正確的Minimum Sufficient Validation，而不是被當成普通文件或未知路徑。
- Problem（問題）：Milestone 35 accepted Design已把`governance Skill／references`列為`governance` class，但current classifier只把`.agents/skills/governing-template-development/**`列為`governance`。其他repository-authored與third-party-managed Skills目前多數落入`docs_content`，只執行`check_docs.py`；`skills-lock.json`與`third_party/skills/**`則落入`unknown`並full fail-safe。這同時造成under-validation與不必要over-validation。
- Current behavior（目前行為）：中央治理Skill為`governance → docs_check + tools/docs tests`；`starting-feature-work`、`adopting-template-product-identity`、`implementing-pencil-flutter-design`、`karpathy-guidelines`及Taste Skills為`docs_content → docs_check only`；`skills-lock.json`與`third_party/skills/taste-skill/LICENSE`為`unknown → full fail-safe`。
- Expected behavior（預期行為）：所有repository-managed Skill governance surface都應deterministically分類為既有`governance` class，執行docs check與`tools/docs` governance contracts；locked third-party bytes仍由`skills-lock.json` exact hash／license contract fail closed。真正未受管理或無法分類的路徑仍維持`unknown → full fail-safe`。
- Value（價值）：補齊Milestone 35 canonical change-class contract，使Skill trigger、permissions、workflow ordering、representation policy、lock／provenance等治理變更不會少跑既有machine contracts，同時避免Skill lock／vendored license的小型治理變更無理由執行完整Flutter與雙平台矩陣。
- Classification（分類）：Level 4 — Architecture／repository-wide governance corrective。
- Decision（決策）：Accept。
- Scope（範圍）：`change_classifier.py`的Skill governance path boundary；classifier／planner contract tests；Skill lock／docs contract routing；mixed Skill＋docs classification；unknown negative controls；current validation governance authority必要同步。
- Non-goals（非目標）：不新增新的change class；不降低真正unknown／invalid range／planner failure的full fail-safe；不刪測試；不修改Flutter production source；不讓planner取代Skill adoption review或fresh behavioral pressure evidence；不重新開啟Milestone 35；不建立新的Milestone編號。
- Behavioral requirements required（是否需要行為需求）：YES。
- Design Spec required（是否需要 Design Spec）：YES。
- Implementation Plan required（是否需要 Implementation Plan）：YES。
- ADR required（是否需要 ADR）：NO。ADR-023與Milestone 35 accepted Design已定義`governance Skill／references`屬`governance` class，本工作只修正implementation與tests使其符合既有stable authority。
- Task governance mode（Task 治理模式）：Full two-layer governance。
- Worktree／branch：Design／Plan階段不建立implementation worktree；Plan accepted後implementation必須使用managed worktree／branch。
- Regression level（Regression 等級）：Design／Plan使用focused governance validation；implementation因會修改validation engine，依planner self-change contract執行full validation-engine verification，並保留unknown negative controls。
- Release required（是否需要發布）：Conditional。屬既有能力corrective，最終由Implementation Final Review依Versioning Policy判定；不得僅因Level 4自動升版。
- Post-release validation（發布後驗證）：只有實際發布新Template Baseline時required；若不發布則以merged-main fresh validation closure取代。
- Required Superpowers skills（必要 Superpowers Skills）：Design使用`brainstorming`；Design accepted後使用`writing-plans`；Plan accepted後依中央治理使用worktree／TDD／debugging／review／verification流程；production script implementation與review搭配`karpathy-guidelines`。
- Required artifacts（必要 artifacts）：本Requirement Decision；Corrective Design；Design review evidence；Implementation Plan；Plan review evidence；implementation Task review；classifier／planner regression evidence；holistic final review；必要current authority sync；若發布則release／post-release evidence。

## Admission evidence

Fresh baseline：

```text
main == origin/main == 6ef1b7d6370097920c4281933558684639f970ac
VERSION = 1.16.0
working tree = clean
```

Fresh path probes：

```text
.agents/skills/governing-template-development/SKILL.md
  → governance / focused / docs_check + tools/docs

.agents/skills/implementing-pencil-flutter-design/SKILL.md
  → docs_content / focused / docs_check only

.agents/skills/starting-feature-work/SKILL.md
  → docs_content / focused / docs_check only

.agents/skills/adopting-template-product-identity/SKILL.md
  → docs_content / focused / docs_check only

.agents/skills/karpathy-guidelines/SKILL.md
  → docs_content / focused / docs_check only

.agents/skills/brandkit/SKILL.md
  → docs_content / focused / docs_check only

skills-lock.json
  → unknown / full / fail_safe=true

third_party/skills/taste-skill/LICENSE
  → unknown / full / fail_safe=true
```

Current `validation_runner.py`證明`governance`額外執行`python -m unittest discover -s tools/docs -p test_*.py`；`docs_content`只執行`tools/docs/check_docs.py`。Repository另已有Pencil representation／single-renderer與Skill lock專屬`tools/docs` tests，因此差異具有實際validation coverage意義。

## Disposition

**ACCEPT — Level 4 standalone governance corrective，不建立新Milestone。**

下一合法artifact為proposed Corrective Design；Plan與implementation不得提前開始。
