# Milestone 21-2 Enable / Disable Policy與Persistence Review

狀態：Reviewed / Closed。

## Implementation

- `LocalUnlockPreference`使用version 1、`enabled / disabled` closed contract。
- Read taxonomy為`absent / present / corrupted`；operational failure不被當成absence。
- App-owned SharedPreferences adapter只保存固定key與boolean policy，不保存userId、biometric type、credential或enrollment identity。
- Writes與clear採serialized queue，完整操作依提交順序收斂至latest snapshot。
- Enable只允許authenticated Session，順序固定為capability → biometric-only verification → preference write。
- Enable與Auth login / logout / account switch共用`AuthStateMutationCoordinator` generation；stale prompt completion不得寫enabled。
- Prompt成功但preference write失敗回`storageFailure`，維持disabled。
- Disable只修改preference，不清credential或runtime Session。
- Logout cleanup加入local unlock preference，仍完整嘗試secure、legacy、user與preference cleanup。
- Restore解析為unauthenticated時best-effort清除stale local unlock preference。

## Implementation Review Finding

| ID | Severity | Finding | Disposition |
|---|---|---|---|
| M21-2-R01 | P1 | Enable write failure若直接向外拋storage exception，Presentation無法以穩定policy result區分prompt rejection與persistence failure。 | Closed：新增`LocalUnlockPolicyResult.storageFailure`；unknown exception仍保留原始error / stack。 |

## Verification

- build_runner：成功。
- Workspace analyze：5 packages全部通過。
- 完整Flutter tests：610項全部通過。
- App bundle：成功；既有zh untranslated提示不影響build結果。
- `git diff --check`：通過。

## Boundary Confirmation

- Startup gate尚未啟用，`AuthNavigationCoordinator`仍維持21-2前行為。
- Android Native未修改。
- Route Guard、OTP challenge authority、Refresh authority與Secure credential source of truth未改變。
- VERSION維持1.4.0。

下一步：Milestone 21-3 Gated Restore與Session Authority。
