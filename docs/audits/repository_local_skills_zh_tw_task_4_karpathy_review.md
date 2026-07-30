---
document_type: phase-review
status: completed
authoritative_for:
  - repository-local-skills-zh-tw-task-4-karpathy-review
last_reviewed_baseline: 1.13.0
---

# Repository-local Skills 中文化治理恢復 Task 4 — Karpathy Guidelines Skill Review

## Task scope

審查 `karpathy-guidelines` Skill與pressure scenarios的繁體中文化結果，確認external source pin、subordinate companion定位、anti-overengineering heuristics、non-trigger exclusions與restricted Pilot evidence boundary未被改變。

## Review oracle

- 中文化前版本：`7418a60`。
- Pinned source review：`docs/audits/milestone_31/31-followup-karpathy-guidelines-source-review.md`。
- Primary workflow final review：`docs/audits/milestone_31/31-followup-karpathy-primary-workflow-final-review.md`。
- Current registry：`Pilot／Approved with restrictions`。

## Focused findings

### F-T4-01 — 未發現語意漂移

- Severity：None。
- Review：逐段對照frontmatter description、source pin、coding heuristics、restrictions與pressure controls。
- Result：trigger、source identity、subordinate authority與restricted evidence wording均與中文化前版本等價，不需要source修正。

## Semantic equivalence review

### Source and routing

- Upstream仍為`multica-ai/andrej-karpathy-skills`。
- Pinned commit仍為`2c606141936f1eeef17fa3043a72095b4765b9c2`。
- Current Requirement Decision、accepted Design／Plan／ADR、repository policy與routed Superpowers workflow仍高於此Skill。
- 使用者不把它當成workflow入口；只在classification與必要approvals後由中央治理載入。

### Heuristics

- Coding前讀取authority、source、callers與tests。
- 優先採用滿足accepted scope的最小方案。
- 不建立沒有confirmed need的interfaces、factories、registries、generic frameworks或future scaffolding。
- Diff維持Task boundary，不混入renaming、formatting與adjacent refactors。
- Required review、tests與repository validation fresh pass前不得宣稱完成。

### Restrictions

- 不得分類工作或修改approval、stop、Task、branch、commit、release、closure gate。
- 不得縮減accepted scope。
- 不得移除security、migration、rollback、accessibility、error handling或validation evidence。
- 純需求討論、Design／Plan approval、Level 0 documentation fix、roadmap與release closure仍是non-trigger。

### Pressure scenarios

- Single Widget formatting不建立framework。
- Bounded Bloc race fix拒絕無關修改。
- Offline recovery保留retry UI、accessibility、typed failures與tests。
- Repository evidence可解決的ambiguity不造成不必要停止。
- Level 5 migration保留rollback、compatibility fixtures與failure injection。
- Fresh ChatGPT behavioral subagent evidence仍為`Pending`，因此status保持restricted Pilot，未因中文化誤升級。

## Whole-Task authority review

- `governing-template-development`仍是唯一workflow owner。
- Karpathy只提供heuristics，不擁有approval或closure。
- External source pin與license／provenance evidence未被翻譯覆蓋。
- Current registry的`Pilot／Approved with restrictions`與Skill pressure文件一致。

## Fresh validation

```txt
Skill files                                     2
Required semantic anchors                      14 passed
Pinned source commit                           unchanged
UTF-8 replacement characters                   0
Traditional Chinese description                verified
Restricted Pilot boundary                      preserved
Documentation checker tests                    17 passed
docs_check                                     passed
git diff --check                               passed
```

## Severity gate

- Open P0：0。
- Open P1 without disposition：0。
- Open P2 without disposition：0。

## Task disposition

```txt
Task 4：Passed without source changes
Karpathy Guidelines status：Pilot／Approved with restrictions
Next：Task 5 — Language Governance and Mechanical Enforcement
```
