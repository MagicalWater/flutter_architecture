---
name: karpathy-guidelines
description: 當 implementation、refactor 或 production code review 可能出現不必要 abstraction、無關修改、scope creep 或無法驗證的工作時使用。
---

# Karpathy Guidelines

改編自 `multica-ai/andrej-karpathy-skills` 的 `skills/karpathy-guidelines/SKILL.md`，固定於 commit `2c606141936f1eeef17fa3043a72095b4765b9c2`。

**必要治理：**Current Requirement Decision、已接受的 Design／Plan／ADR、repository policy 與 routed Superpowers workflow 的權威高於這些 heuristics。

## Coding 前先思考

- 編輯前先讀取受影響的 authority、source、callers 與 tests。
- 能從 repository evidence 釐清 ambiguity 時直接處理；只有 approved scope 或 architecture 確實需要使用者決策時才停止。
- 明確寫出會影響 behavior 或 validation 的 assumptions。

## 簡單優先

- 實作滿足 accepted scope 的最小方案。
- 新增 abstraction 前，先重用目前 code、platform features 與 installed dependencies。
- 沒有 confirmed need 時，不新增 interfaces、factories、registries、generic frameworks 或 future scaffolding。

## 精準修改

- Diff 保持在 Task boundary 內。
- 不得把有界修正與 renaming、formatting、comment cleanup 或 adjacent refactors 混在一起。
- Evidence 證明存在 shared root cause 時，修正共同根因；不得以「順便」為理由修改無關路徑。

## 以目標驅動執行

- 定義 observable result，以及能證明它的 command 或 evidence。
- 必要 review、tests 與 repository validation fresh pass 前，變更不算完成。
- 記錄刻意保留的 non-goals 與 rejected scope expansion。

## 限制

此 Skill 不得分類工作；不得修改 approval、stop、Task、branch、commit、release 或 closure gate；不得縮減 accepted scope；不得移除必要 security、migration、rollback、accessibility、error handling 或 validation evidence；純討論、approval decision、roadmap disposition、只有文件的 Level 0 工作或 release metadata 不得觸發，除非同時正在審查 production code。

壓力測試協議：[references/pressure-scenarios.md](references/pressure-scenarios.md)。
