---
document_type: runtime-evidence
status: completed
authoritative_for:
  - karpathy-guidelines-primary-workflow-pressure-validation
last_reviewed_baseline: 1.13.0
---

# Karpathy Guidelines Primary Workflow Pressure Validation

## Environment

- Primary workflow：ChatGPT網頁＋`bridge-mac`。
- Clean managed worktree：`/Users/water/.devspace/worktrees/flutter_architecture-b117af0b`。
- Tested branch SHA：`7075685b441f8dd4fc5ea15a6a49577efb578e40`。
- Codex Ponytail Plugin：不列入repository capability，也不作為本validation依賴。

## Discovery GREEN

在clean worktree重新執行`bridge-mac.open_workspace`後，advertised Skills明確包含：

```txt
governing-template-development
karpathy-guidelines
starting-feature-work
```

這證明primary ChatGPT＋bridge-mac runtime可從repository-local path發現新Skill，不依賴Codex Plugin cache或hooks。

## Authority review

Focused review確認：

- `karpathy-guidelines`只有implementation／refactor／production code review heuristics。
- Level、Requirement Decision、Design／Plan approval、Task、branch、commit、validation、release與closure仍由`governing-template-development`擁有。
- Skill不複製Level matrix、Task cycle或release rules。
- Accepted scope、安全、migration、rollback、accessibility、error handling與validation不可被simplicity覆蓋。

## Trigger review

Positive triggers：

- production code implementation；
- refactor；
- production code review。

Non-trigger controls：

- pure requirement discussion；
- Design／Plan approval；
- documentation-only Level 0 work；
- roadmap disposition；
- release metadata／closure，除非同時review production code。

## Behavioral evidence boundary

平台目前沒有可由本對話建立的fresh、無記憶ChatGPT＋`bridge-mac`子對話，因此沒有冒充fresh behavioral GREEN。五個scenario與expected outcomes已保存在Skill reference；未來平台提供isolated primary-workflow context時必須補做behavioral discovery GREEN。

Disposition：這項限制不阻塞restricted Pilot，但禁止升級為fully Approved。

## Validation

```txt
Skill word count：275
Documentation checker：17 passed
docs_check：passed
git diff --check：passed
Open P0：0
Open P1 without disposition：0
```
