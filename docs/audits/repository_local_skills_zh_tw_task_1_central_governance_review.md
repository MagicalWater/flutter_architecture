---
document_type: phase-review
status: completed
authoritative_for:
  - repository-local-skills-zh-tw-task-1-central-governance-review
last_reviewed_baseline: 1.13.0
---

# Repository-local Skills 中文化治理恢復 Task 1 — 中央治理 Skill Review

## Task scope

逐檔審查 `governing-template-development` 與五份 references 的繁體中文化結果，確認中央 classification、artifact routing、Design／Plan gate、雙層 Task、stop／continue、Skill adoption 與 pressure protocol 沒有語意漂移。

## Review oracle

- 中文化前 commit：`7418a60`。
- 中文化 commit：`c8a77a5`。
- Current repository policy：`AGENTS.md`。
- Accepted recovery Design／Plan：`7b8279c`、`9a6cf92`。

## Focused findings

### F-T1-01 — 原中文化 review 的 Level 1 classification 不成立

- Severity：P1。
- Finding：原 review 同時修改中央治理 Skill、Level 0～5、artifact routing、acceptance gate與全部 adopted Skills trigger wording，卻分類為 Level 1。
- Fix：由本 Level 3 governance recovery Design／Plan正式 supersede；舊 review只保存歷史執行事實，不再作為 current classification authority。
- Fresh re-review：current recovery明確要求Design、Plan、full Task governance、逐Skill review與holistic final review。

### F-T1-02 — 終端 diff 顯示疑似 replacement characters

- Severity：P2。
- Finding：`git diff`輸出曾顯示`��後`與`branch��commit`，可能被誤判為檔案編碼損壞。
- Investigation：使用 repository file reader與 UTF-8 code-point scan直接讀取檔案。
- Result：實際內容分別為「最後」與`branch、commit`；12份Skill文件的 U+FFFD replacement character為零。屬終端輸出編碼問題，不需要 source修正。
- Fresh re-review：直接 UTF-8讀檔與anchor scan通過。

## Semantic equivalence review

### Central Skill

- `Requirement Decision`仍先於Design、Plan、implementation與review。
- Repository policy與current artifacts仍高於Skill。
- Design與Plan只有在full Task gate＋使用者明確核准後，才能`proposed → accepted`。
- Parent Plan仍為`proposed`時不得開始implementation。
- 一般finding／test failure直接修正；只有user-owned decision、external blocker、推翻approved artifact的P0／P1或完整Milestone closure才停止。
- `karpathy-guidelines`與`adopting-template-product-identity`的subordinate route維持不變。

### Work classification

- Level 0～5全部保留。
- Highest-risk-first與ambiguous-work-upgrade規則保留。
- Repository-wide governance仍是Level 4訊號；cross-cutting shared contract仍為Level 3。
- Anti-over-governance規則未被中文化削弱。

### Artifact routing

- Design／Plan／ADR／worktree／regression／release matrix保留。
- Superpowers順序與acceptance state transitions保留。
- `karpathy-guidelines`仍非workflow入口。

### Two-layer Task governance

- Minimal、Simplified、Standard、Full、Full-critical模式保留。
- 每個formal Task仍要求focused review、finding、fix、fresh re-review、whole-Task review、authority check、validation、severity gate與independent commit。
- 後續Task不得retroactively證明早期失敗Task已通過。

### Skill adoption and pressure protocol

- Approved／Approved with restrictions／Pilot／Deprecated／Rejected狀態保留。
- Placement、registry、revalidation、rollback規則保留。
- RED／DISCOVERY／EXPLICIT GREEN／REFACTOR四階段與10個governance controls保留。

## Whole-Task authority review

- `AGENTS.md`仍是強制入口與語言政策authority。
- Central Skill仍是唯一classification／routing owner。
- Human governance overview未取代executable Skill matrix。
- 本Task未修改Skill行為、source、tests、CI、release metadata或roadmap。

## Fresh validation

```txt
Central governance files                         6
Required semantic anchors                       26 passed
UTF-8 replacement characters                    0
Skill name                                      unchanged
Traditional Chinese description                 verified
Documentation checker tests                     17 passed
docs_check                                      passed
git diff --check                                passed
```

## Severity gate

- Open P0：0。
- Open P1 without disposition：0。
- Open P2 without disposition：0。

## Task disposition

```txt
Task 1：Passed
Central governance behavior：Semantically preserved
Next：Task 2 — Product Identity Skill Review
```
