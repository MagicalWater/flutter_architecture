---
document_type: implementation-plan
status: accepted
authoritative_for:
  - milestone-40-repository-landing-documentation-authority-implementation-plan
last_reviewed_baseline: 1.20.0
---

# Milestone 40 — GitHub Repository Landing Page & Documentation Authority Restructure Implementation Plan

## 1. Plan status

```txt
Requirement: accepted
Design: accepted / user approved 2026-08-17
Plan: accepted / user approved 2026-08-17
Implementation: allowed by Task sequence
```

本Plan只執行已核准Design，不重新決定README資訊架構，也不擴張到Flutter production behavior、App／Package architecture或新文件系統。

## 2. Execution principles

- root `README.md`仍是human／product entry，不成為current snapshot、roadmap、ADR、AI policy或procedure authority。
- 詳細current facts優先由既有owner承擔；README只保存摘要＋stable route。
- 兩張正式架構圖直接inline preview，來源仍是`docs/assets/architecture/`。
- 大型刪減先建立section-level preservation／migration matrix，再改README。
- Template → Product bootstrap必須持續可轉換；checker baseline contract不可被靜默破壞。
- 不新增平行「README詳細版」。
- 不修改Flutter production source、tests或generated files。
- 每個Task依validation planner產生Minimum Sufficient Validation；Milestone holistic再執行必要的fresh broader validation。

## 3. Task 40-1 — README preservation / migration matrix

### Goal

在任何README重寫前，建立逐section preservation evidence，證明目前README內容不是直接丟失。

### Files

- Create: `docs/audits/milestone_40/40-1_readme_preservation_matrix.md`
- Create: `docs/audits/milestone_40/40-1_readme_preservation_review.md`
- Modify: `docs/audits/README.md`

### Required matrix columns

```txt
source heading
current responsibility
disposition
destination / canonical owner
landing-page summary required?
bootstrap-sensitive?
checker-sensitive?
semantic preservation assertion
```

### Mandatory coverage

至少逐一覆蓋：

- 專案狀態。
- Template adoption。
- 專案定位。
- 架構視覺。
- 技術選型各小節。
- 專案結構。
- Demo Flow。
- Runtime Flow。
- Quick Start。
- Flutter Web。
- 文件導覽。
- 開發原則。
- 開新對話。

### Gate

- 每一個現有section都有disposition。
- `remove`只能在已有canonical owner或明確判定historical／no-longer-required時成立。
- Template bootstrap會重寫的README facts必須標示。
- checker讀取的baseline phrase必須標示。
- Focused review → fixes → fresh re-review → whole-Task review。
- Open P0=0；Open P1 without disposition=0。

## 4. Task 40-2 — Root README product landing implementation

### Goal

依accepted Design與40-1 matrix，把root README重構成GitHub landing page。

### Files

- Modify: `README.md`
- Create: `docs/audits/milestone_40/40-2_root_readme_review.md`

### Required section order

```txt
Hero / Positioning
Current Baseline / platform summary
Why this template
Architecture Overview
Dependency Contract
What is included
Start a Product
Quick Start
Repository Structure
Platform Support
Documentation
Limitations / Non-goals
```

implementation時可調整section名稱，但不得改變已核准責任與閱讀順序意圖。

### Architecture visual contract

直接使用：

```md
![...](docs/assets/architecture/productized-topology.png)
![...](docs/assets/architecture/c4-dependency-contract.png)
```

不得複製圖片、產生新authority或把圖片移到root只為README顯示。

### Content constraints

- 保留machine-readable `Template Baseline Version：1.20.0`；預設不改checker。
- 不列Milestone 1～39完整journal。
- 不複製Network／Auth／Storage／Localization／CI完整contract。
- 不保存完整AI reading rules。
- 不保存完整Web procedure。
- Capability只保存人類可掃讀摘要並連到current owner。
- `Use this template` newcomer CTA必須保持可見。

### Gate

- GitHub Markdown relative links有效。
- inline image paths有效。
- baseline checker仍PASS。
- preservation matrix逐項對照沒有資訊無owner消失。
- focused review、fresh re-review與whole-Task review完成。

## 5. Task 40-3 — Documentation ownership and reading-route alignment

### Goal

修正因root README責任收斂而需要同步的current policy／routing，避免舊規則把README再次膨脹。

### Files

- Modify as required: `docs/README.md`
- Modify: `docs/conversation_rules.md`
- Modify as required: `docs/governance/documentation_policy.md`
- Modify as required: `AGENTS.md`
- Modify as required: `docs/project_context.md`
- Create: `docs/audits/milestone_40/40-3_documentation_authority_review.md`

### Exact responsibility

- `docs/README.md`：Human entry定義收斂為product landing summary，而不是「所有重要內容都放README」。
- `docs/conversation_rules.md`：Rule 5改成README只同步landing-critical facts；詳細procedure／current contract回canonical owner。
- `documentation_policy.md`：只有existing policy wording不足時才改；不複製reading route。
- `AGENTS.md`：只有root README被現行AI route誤當authority時才改；固定最小讀取集仍不必加入root README。
- `project_context.md`：release route的`Root README current capability`措辭如需收斂，改為landing summary consistency。

### Gate

- Single Authority沒有新overlap。
- AI最小讀取集不膨脹。
- Human newcomer route與AI route明確分離。
- focused review／fresh re-review／holistic review PASS。

## 6. Task 40-4 — Template → Product README transition compatibility

### Goal

證明新的landing README仍可被既有bootstrap流程安全轉成產品repository入口。

### Files

- Modify as required: `docs/guides/template_repository_adoption.md`
- Modify as required: `.agents/skills/adopting-template-repository/**`
- Modify as required: related repository bootstrap tests／tools only if actual incompatibility is confirmed
- Create: `docs/audits/milestone_40/40-4_template_product_readme_compatibility_review.md`

### Required checks

- Template README含Template Baseline machine phrase。
- Product bootstrap後仍可產生`Product Repository Version：x.y.z`或current checker接受的等價phrase。
- template positioning會被產品定位取代，不留下「current repository = template」矛盾。
- architecture visuals若仍適合產品repo，可作template provenance／architecture summary；若不適合，bootstrap contract要有明確disposition。
- newcomer route不得要求產品repo重新閱讀模板milestone history。

### Change minimization

如果read-only／prospective validation證明現有bootstrap已相容，記錄`no implementation change required`；不得為了Task存在而修改Skill或Guide。

## 7. Task 40-5 — Documentation checker / validation contract

### Goal

確認landing restructure具可重現machine safety net。

### Files

- Modify only if required: `tools/docs/check_docs.py`
- Modify only if required: `tools/docs/test_check_docs.py`
- Create: `docs/audits/milestone_40/40-5_documentation_validation_review.md`

### Default decision

預設**不改checker**：保留現有baseline phrase，使既有VERSION／README／CHANGELOG一致性檢查繼續成立。

只有Task 40-2或40-4證明新README格式無法合理保留現有phrase時：

1. 先新增／修改fixture形成expected RED。
2. 最小修改checker。
3. template與product兩種README fixture都轉GREEN。
4. 不讓checker解析自然語言capability或section順序。

## 8. Task 40-6 — Cross-document holistic review and current authority sync

### Goal

完成所有implementation tasks後做repository-wide documentation consistency review。

### Files

- Create: `docs/audits/milestone_40/40-6_holistic_final_review.md`
- Modify: `docs/audits/README.md`
- Modify: `docs/superpowers/README.md`
- Modify: `docs/milestones/README.md`
- Modify: `docs/roadmap.md`
- Modify: `docs/roadmap/active.md`
- Modify: `docs/project_context.md`
- Modify release files only if release disposition requires

### Holistic assertions

- README第一屏／前段是產品定位與架構視覺，而不是Milestone journal。
- 所有原README內容都可由preservation matrix追蹤。
- README沒有建立第二份project context、Guide、ADR或Agent policy。
- architecture images可直接在GitHub render。
- Template bootstrap仍保持machine／semantic compatibility。
- docs checker、relative links、metadata與language policy PASS。
- current indexes與active milestone無矛盾。
- Open P0=0；Open P1 without disposition=0。

## 9. Validation strategy

每個Task先執行：

```bash
python tools/ci/validation_planner.py --event push --base <task-base> --head <task-head> --stdout-json
```

依planner執行selected validations。

固定documentation safety checks至少包括：

```bash
git diff --check
dart run melos run docs_check
```

若checker implementation被修改，再執行：

```bash
python -m unittest tools.docs.test_check_docs
```

Milestone 40 holistic時重新依planner產生整體plan；若classification要求full則執行full，否則不得因Level 4名義無條件跑所有Flutter tests。

## 10. Commit boundaries

建議每個formal Task獨立commit：

```txt
docs(governance): 建立 README preservation matrix
docs(readme): 重構 repository product landing page
docs(governance): 收斂 README 文件責任邊界
docs(template): 驗證產品化 README transition
test(docs): 強化 README validation contract   # only if checker changes
docs(milestone): 完成 Milestone 40 holistic review
```

若Task 40-4或40-5判定`no implementation change required`，只提交review evidence，不製造空泛production change。

## 11. Release disposition

Plan不預先強制升版。

Holistic Final Review依實際變更決定：

- documentation／presentation-only且沒有stable contract change：可維持`1.20.0`，不做release。
- 若documentation authority stable contract、bootstrap machine behavior或checker public governance contract實質改變：依current release policy決定是否提升Template Baseline。

無論是否release，都必須完成branch integration後的fresh current-authority validation；只有真的發版才使用release／post-release semantics。

## 12. Stop conditions

只有以下情況停止要求使用者決策：

1. implementation證明必須推翻accepted README section architecture。
2. 必須改變ADR-011 stable Single Authority contract。
3. Template → Product bootstrap需要與accepted Design不同的產品README策略。
4. Plan holistic review發現undisposed P0／P1。
5. Plan完成review後等待使用者核准。

一般link error、docs checker failure、stale routing或wording finding直接修正並fresh re-verify。
