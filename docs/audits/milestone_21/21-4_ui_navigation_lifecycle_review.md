# Milestone 21-4 Unlock UI、Navigation與Lifecycle Concurrency Review

## 結論

Milestone 21-4已完成並通過implementation review。Local unlock現在具備正式locked route、可觀察presentation state、retry／改用帳號登入安全出口，以及App-owned 5分鐘resume grace-period lifecycle gate。

## 完成項目

- 新增`LocalUnlockRoute`與`LocalUnlockPage`。
- Presentation state涵蓋checking、locked、prompting、rejected、unavailable、corruption、operational failure、superseded與server-login escape。
- Locked surface不顯示credential、biometric type或raw plugin detail。
- UI提供retry與改用帳號登入；prompting期間兩個action均停用，避免duplicate prompt與escape race。
- 新增English、zh、zh_TW文案、Semantics、2.0 text scale與320px narrow viewport regression。
- `AuthNavigationDestination`新增locked；App仍是唯一navigation owner，Page不直接操作Router或Shell tabs。
- App lifecycle coordinator使用可注入monotonic clock，default grace period固定5分鐘。
- Grace period內resume不prompt且保留Session；逾時resume先清Session，再要求unlock與restore。
- Prompt-owned inactive / hidden / resumed抖動不建立第二prompt。
- Resume re-lock透過Session generation與Auth lifecycle generation使舊refresh / restore completion失效。

## Implementation review findings

| ID | Severity | Finding | Disposition |
| --- | --- | --- | --- |
| M21-4-R01 | P1 | 改用帳號登入時若preference write失敗直接向Widget callback拋出，可能形成uncaught async error且無法安全導航。 | Closed：escape write failure收斂為observable operational failure，保留error與caught stack，只有write成功才進server-login destination。 |

## 驗證

- Targeted startup、lifecycle、navigation與widget tests通過。
- Workspace analyze：5 packages通過。
- Workspace Flutter tests：624項通過。
- App bundle build通過。
- `git diff --check`通過。
- Android Native、OTP authority、Refresh authority與VERSION未修改。

## 下一步

Milestone 21-5將完成Android Native configuration、release artifact、runtime smoke、security leakage audit與Milestone 21最終封存。
