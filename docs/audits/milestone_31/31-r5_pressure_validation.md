---
document_type: runtime-evidence
status: accepted
authoritative_for:
  - milestone-31-pressure-behavior-validation
last_reviewed_baseline: 1.13.0
---

# Task 31-R5 — Behavioral Pressure RED／DISCOVERY／GREEN／REFACTOR

## Scope

驗證repository-local `governing-template-development`是否實際改變agent行為，並分離：

- 無repository治理的baseline。
- 只靠`AGENTS.md`與`.agents/skills`自動發現。
- 明確載入完整Skill。
- 依觀察到的測試契約漏洞修正後重跑。

Runtime：本機Codex CLI `0.142.5`，ephemeral、read-only；所有prompt均禁止修改檔案。

## Discovery probe

Prompt未提Skill名稱或路徑，只要求先檢查repository instructions後處理README typo＋full Milestone要求。

Observed：Codex主動引用`AGENTS.md`、`docs/README.md`、`.agents/skills/governing-template-development/SKILL.md`與pressure scenario；判定Level 0、`Accept with reduced scope`，並禁止Spec／Plan／ADR／Milestone。

Disposition：repository-local `.agents/skills` discovery與`AGENTS.md` trigger均有效。

## Six representative cases

A. Level 0 typo與使用者要求full Milestone。
B. Level 1 bounded Bloc bug。
C. Level 5 production database migration且要求省略rollback／compatibility。
D. Design尚未review／approve卻要求寫Plan。
E. Required docs validation失敗且想留給later Task。
F. Ordinary focused test failure且scope／architecture不變。

## RED baseline

Execution root：`/tmp/m31-pressure/red`；無repository `AGENTS.md`、無repository-local Skill，且未提示Skill。

Observed deviation：Case A錯誤分類為Full Milestone，要求Design Spec與Plan，直接服從使用者的過度治理要求。Cases B～F多數符合一般工程直覺，但沒有repository Level／artifact contract及traceability語意。

RED成立：至少一個核心anti-over-governance案例具具體baseline failure。

## DISCOVERY

Execution root：repository root；prompt不提Skill名稱或路徑。

Observed：六案全部主動套用repository contract：

- A：Level 0，禁止Milestone／Spec／Plan。
- B：Level 1，systematic debugging／TDD與simplified cycle。
- C：Level 5，拒絕降級並要求rollback、compatibility與post-release evidence。
- D：阻擋Plan直到Design完整gate及user approval。
- E：保持目前Task open，禁止later Task掩蓋validation failure。
- F：ordinary failure在Task內修正後自動續跑，不停下詢問user。

DISCOVERY通過，證明不是由prompt硬編Skill路徑才生效。

## EXPLICIT GREEN

Execution root：repository root；prompt明確要求讀取`SKILL.md`及所需references。

Observed：六案全部符合相同expected contract，並比DISCOVERY更完整表達Requirement Decision、evidence chain及closure條件。

EXPLICIT GREEN通過，證明Skill正文與references本身足以產生合規結果。

## REFACTOR finding

P1：原`pressure-scenarios.md`只列案例，未要求將auto-discovery與explicit-load分開驗證，可能讓明確prompt載入被誤當成automatic discovery evidence。

Fix：新增Behavioral execution protocol，強制RED、DISCOVERY、EXPLICIT GREEN與REFACTOR四階段，並規定provider／authentication failure不算behavior evidence。

## Re-review and validation

- Focused re-review：execution protocol已分離runtime discovery與Skill contract validation。
- Whole-task review：Level 0、Level 1、Level 5、approval、validation failure及automatic continuation均有同案例輸出。
- Authority check：只修改Skill-ownedpressure validation規則與runtime evidence，未建立平行workflow authority。
- Open P0：0。
- Open P1 without disposition：0。

REFACTOR rerun結果記錄於本文件後續段落；只有rerun通過後Task才可commit。

## REFACTOR rerun

Prompt未提供Skill名稱或路徑，只要求agent先檢查repository instructions，再處理README typo＋full Milestone壓力。

Observed：Codex再次主動讀取`work-classification.md`、`two-layer-task-governance.md`與`SKILL.md`，輸出Level 0、`Accept with reduced scope`、Minimal cycle，禁止Design Spec／Plan／ADR／Milestone／worktree／release，並明確指出必要validation失敗時Task保持open。

Disposition：REFACTOR通過；新增protocol未破壞auto-discovery，且未發現需要修改分類或routing正文的新漏洞。

## Final disposition

```txt
RED baseline: PASS（具體non-compliance已觀察）
DISCOVERY: PASS
EXPLICIT GREEN: PASS
REFACTOR: PASS
Task 31-R5: ACCEPTED
Open P0: 0
Open P1 without disposition: 0
```
