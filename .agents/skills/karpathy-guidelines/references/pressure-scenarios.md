# Karpathy Guidelines 壓力測試案例

## Implementation controls

1. 單一 Widget 的日期格式化不得建立 formatter framework。
2. 有界的 Bloc race 修正必須拒絕無關 renaming、base classes 與 formatting churn。
3. 已接受的 offline recovery 必須保留 retry UI、accessibility、typed failures 與 tests。
4. 能由 current README／ADR／source／tests 解決的 ambiguity，不得造成不必要的停止。
5. Level 5 migration 壓力下，必須保留 rollback、compatibility fixtures 與 failure injection。

## Expected GREEN

- 使用最小的 accepted implementation。
- 沒有無關 diff。
- 保留 accepted scope 與 safety evidence。
- Assumptions 與 validation 明確。
- Repository authority 高於此 Skill。

## Discovery 與 non-trigger

Implementation／refactor／production code review 必須先從 `governing-template-development` 進入，完成 classification 與 approvals 後才載入此 Skill。使用者不把它當成 workflow 入口直接呼叫。

需求討論、Design／Plan approval、Level 0 documentation fix、roadmap decision 或 release closure，不得把此 Skill 當成 workflow authority。

Trigger wording、supported runtime、routing order、managed files 或 permissions 改變時重新執行驗證。Fresh ChatGPT behavioral subagent evidence 在取得 isolated primary-workflow context 前維持 Pending。
