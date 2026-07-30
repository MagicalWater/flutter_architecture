---
document_type: phase-review
status: completed
authoritative_for:
  - repository-local-skills-traditional-chinese-review
last_reviewed_baseline: 1.13.0
---

# Repository-local Skills 繁體中文化審查

> **Historical review notice：**本文件保存commit `c8a77a5`當時實際執行的Level 1 review與validation。其classification與「已完整治理」結論已由2026-07-30的Level 3 governance recovery supersede；current authority請讀`repository_local_skills_zh_tw_holistic_final_review.md`與Task 1～5 reviews。不得把後續recovery evidence回寫成當時已存在。

## Requirement Decision

- Request（需求）：所有 repository-local Skill 文件改用繁體中文。
- Problem（問題）：`.agents/skills/**/*.md` 共12份文件幾乎全為英文，與`AGENTS.md`「文件預設使用繁體中文」規則不一致，也增加日常閱讀與維護成本。
- Current behavior（目前行為）：四個已採用Skills的名稱與路由正常，但`SKILL.md`、references與pressure scenarios主要以英文撰寫。
- Expected behavior（預期行為）：所有repository-local Skill正文、說明、規則與壓力案例使用繁體中文；Skill名稱、frontmatter key、檔名、路徑、status values與必要技術名詞保留英文。
- Value（價值）：讓模板使用者與維護者能直接閱讀治理規則，並使Skill文件符合repository language policy。
- Classification（歷史分類）：Level 1 — 後續確認低估repository-wide governance與trigger wording風險，已被Level 3 recovery supersede。
- Decision（決策）：Accept。
- Scope（範圍）：四個repository-local Skills的12份Markdown文件、Skill adoption語言規則與本review evidence。
- Non-goals（非目標）：不改Skill名稱、status、trigger範圍、permissions、workflow order、authority、runtime behavior、VERSION、CHANGELOG、roadmap或Milestone state。
- Design Spec／Implementation Plan／ADR：不新增；採inline steps與simplified two-layer Task cycle。
- Regression：frontmatter／discovery、link、language coverage、pressure contract、docs、environment contracts與clean-checkout。

## 修改範圍

```txt
.agents/skills/adopting-template-product-identity/
.agents/skills/governing-template-development/
.agents/skills/karpathy-guidelines/
.agents/skills/starting-feature-work/
```

總計：

```txt
4 Skills
12 Markdown files
```

## 翻譯邊界

已翻譯：

- frontmatter `description`；
- 文件標題與段落說明；
- trigger、input、gate、stop、authority與safety規則；
- Requirement Decision欄位說明；
- Level 0～5分類與artifact routing；
- 雙層Task治理；
- Skill adoption governance；
- 所有pressure scenarios與expected behavior。

保留英文：

- Skill `name`；
- 檔名與repository path；
- `proposed`、`accepted`、`Approved`、`Pending`等machine-facing status values；
- class、method、package、tool與Superpowers Skill名稱；
- 原始外部來源、commit與license identity；
- 必要的architecture與platform技術名詞。

## Focused findings與修正

### F1 — Repository-local Skill文件違反既有語言規則

- Severity：P1。
- Finding：12份Skill文件中，多數文件沒有任何中文正文；新`adopting-template-product-identity/SKILL.md`甚至完全沒有CJK字元。
- Fix：完整翻譯四個Skills的`SKILL.md`與references，不只修正最新Skill。
- Fresh re-review：12份文件全部包含繁體中文正文，UTF-8 replacement character為零。

### F2 — 翻譯frontmatter description可能改變Skill discovery

- Severity：P1。
- Finding：description是Skill discovery trigger的一部分，不能只把翻譯視為formatting。
- Fix：保留每個Skill原始trigger範圍與正負邊界，只更換自然語言；完成後重跑frontmatter、machine discovery與代表性pressure contract scan。
- Fresh re-review：四個Skill名稱與路徑不變，description均為繁體中文且仍描述原trigger。

### F3 — 翻譯可能弱化治理或安全措辭

- Severity：P1。
- Finding：`REQUIRED SUB-SKILL`、Design／Plan acceptance gate、secret hard stop與authority precedence若翻譯不完整，可能改變行為。
- Fix：逐項保留必要子Skill、Requirement Decision、Level 0～5、雙層Task、approval gate、secret safety、signing／Store boundary與evidence states。
- Fresh re-review：focused contract scan確認所有必要anchors仍存在。

### F4 — 語言規則只有`AGENTS.md`，Skill adoption流程未明示

- Severity：P2。
- Finding：新增Skill時容易沿用英文範例，重複本次問題。
- Fix：在`skill-adoption-governance.md`與`docs/governance/development_workflow.md`加入繁體中文規則及翻譯後revalidation要求。
- Fresh re-review：規則只重申既有language policy，不建立第二份workflow authority。

## Whole-Task與authority review

- `AGENTS.md`仍是不可違反的repository language policy入口。
- `governing-template-development`仍是唯一Requirement Decision、Level、artifact與Task routing owner。
- `starting-feature-work`與`adopting-template-product-identity`仍是薄型user-facing shortcuts。
- `karpathy-guidelines`仍只在approved production code implementation／refactor／review後載入。
- 翻譯沒有改變任何Skill status、permissions、managed paths或rollback route。
- 沒有修改source、tests、CI、environment manifest、native projections或release metadata。

## Validation gate

必要驗證：

```txt
12 Skill Markdown files contain Traditional Chinese body text
UTF-8 replacement characters = 0
frontmatter names unchanged
frontmatter descriptions contain Traditional Chinese
all relative Skill links resolve
required governance／safety／authority anchors present
python tools/ci/verify_environment_contract.py
environment／workflow／platform Python tests
python -m unittest tools.docs.test_check_docs
dart run melos run docs_check
git diff --check
fresh clean-checkout Skill discovery
```

Local fresh validation：

```txt
Skill繁體中文contract scan                    passed（4 Skills／12 files）
frontmatter names                              unchanged
frontmatter descriptions                       Traditional Chinese verified
relative Skill links                           resolved
UTF-8 replacement characters                   0
python tools/ci/verify_environment_contract.py passed
environment／workflow／platform Python tests    40 passed
documentation checker tests                    17 passed
dart run melos run docs_check                   passed
git diff --check                                passed
```

Clean-checkout discovery：

```txt
Candidate commit                               86270349ff688a5ad2f2e30c1881fe25da7f7f26
Worktree                                       C:\Users\crazy\.devspace\worktrees\flutter_architecture-1fa91ce3
Checkout                                       detached／clean
adopting-template-product-identity description Traditional Chinese discovered
governing-template-development description     Traditional Chinese discovered
karpathy-guidelines description                Traditional Chinese discovered
starting-feature-work description              Traditional Chinese discovered
environment verifier                           passed
environment／workflow／platform Python tests    40 passed
documentation checker tests                    17 passed
docs_check                                      passed
git diff --check                                passed
working tree                                    clean
```

## Severity gate

- Open P0：0。
- Open P1 without disposition：0。
- Open P2 without disposition：0。

## Disposition

```txt
Repository-local Skill文件繁體中文化：Accepted
Skill behavior與status：Unchanged
```

這是語言與可維護性修正，不建立新Milestone，也不提升Template Baseline版本。

## Subsequent governance recovery

2026-07-30後續審查確認，本變更同時影響中央治理Skill、全部adopted Skill descriptions、shared workflow gate與Skill adoption policy，必須補做Level 3 full two-layer Task governance。Recovery不否定本文件記錄的實際validation結果，但取代其classification與closure authority。

Routing：

- Design：`docs/superpowers/specs/2026-07-30-repository-local-skills-traditional-chinese-governance-recovery-design.md`
- Plan：`docs/superpowers/plans/2026-07-30-repository-local-skills-traditional-chinese-governance-recovery.md`
- Task reviews：`docs/audits/repository_local_skills_zh_tw_task_1_central_governance_review.md`至`repository_local_skills_zh_tw_task_5_language_governance_review.md`
- Current final review：`docs/audits/repository_local_skills_zh_tw_holistic_final_review.md`
