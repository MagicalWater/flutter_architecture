# Milestone 21-3 Gated Restore與Session Authority Review

## 結論

Milestone 21-3已完成並通過implementation review。Cold-start restore不再由navigation coordinator無條件觸發，而是由App-owned `StartupLocalUnlockCoordinator`先讀取local unlock preference，再決定直接restore或先完成local user-presence verification。

## 完成項目

- Disabled / absent preference：不開啟prompt，直接dispatch既有Repository restore。
- Enabled preference：先清除runtime Session authority，再檢查capability與執行prompt；只有verified結果可dispatch restore。
- Cancel、not verified、not enrolled、no hardware、temporary / permanent lockout與temporarily unavailable均fail closed，不自動fallback restore。
- Corrupted preference fail closed；operational error保留原始error與caught stack。
- Preference read、capability、prompt與restore dispatch共用完整startup lifecycle lease。
- Login、Logout、OTP、account switch或external clear建立較新Auth lifecycle intent後，舊startup completion不得restore。
- Concurrent start / retry共用單一in-flight prompt。
- Auth navigation coordinator只負責AuthState → route reconciliation，不再擁有restore side effect。
- App先完成startup gate，再啟動navigation reconciliation，避免初始authenticated UI先於gate曝光。

## Implementation review findings

| ID | Severity | Finding | Disposition |
| --- | --- | --- | --- |
| M21-3-R01 | P1 | Generation lease若在preference read完成後才取得，Login / Logout發生於read期間時，舊startup仍可能dispatch restore並取代較新意圖。 | Closed：lease提前至整個startup gate開始，並加入delayed preference read regression。 |

## Planning finding closure

- `M21-PR01` P0：Closed。Enabled cold start現在具備真實pre-restore gate；prompt成功前不讀取credential、不執行restore、不建立Session。

## 驗證

- Targeted startup / navigation / app integration tests通過。
- Workspace analyze：5 packages通過。
- Workspace Flutter tests：617項通過。
- App bundle build通過。
- Android Native、OTP authority、Refresh authority與VERSION未修改。

## 下一步

Milestone 21-4將新增可觀察unlock presentation state、locked route / UI、retry / server-login出口與resume grace-period lifecycle concurrency。
