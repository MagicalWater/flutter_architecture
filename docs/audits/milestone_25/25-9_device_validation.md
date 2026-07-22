# Milestone 25-9 — Physical Device Validation Disposition

## 結論

Task 25-9採正式deferred disposition。

2026-07-22在本機macOS驗證環境中，Flutter與Xcode均未偵測到任何有線或無線iPhone。環境只有一台booted iOS Simulator、macOS host與Web browser，因此無法建立可信的physical-device、real biometric或device Keychain evidence。

本Task不修改production source、native runner或signing設定，也不把Simulator結果冒充實體裝置結果。

## 驗證環境檢查

執行：

```bash
flutter devices
xcrun xctrace list devices
security find-identity -v -p codesigning
```

觀察結果：

- `flutter devices`沒有列出physical iOS device。
- `xcrun xctrace list devices`只有本機Mac與iOS Simulators，沒有實體iPhone。
- 本機Keychain存在可用的Apple Development identity，但其Team ID、email、certificate fingerprint與其他個人signing資料不寫入repository evidence。
- Repository Xcode project沒有`DEVELOPMENT_TEAM`或`PROVISIONING_PROFILE_SPECIFIER`值。

因沒有實體裝置，未嘗試修改tracked Xcode signing state，也未建立archive、IPA或distribution artifact。

## 已有證據與device claim邊界

目前可成立的iOS證據：

| 範圍 | 狀態 | Evidence |
|---|---|---|
| iOS runner與native identity | 已驗證 | Tasks 25-1、25-2 |
| Face ID purpose text、Keychain entitlement與plugin registration | Static verified | Task 25-3 |
| Clean unsigned Simulator build | 已驗證 | Task 25-4 |
| Simulator app bootstrap、navigation、SQLite與preferences | 已驗證 | Task 25-5 |
| Simulator Keychain adapter、local-auth capability與lifecycle coordinator | 已驗證 | Task 25-6 |
| macOS golden authority | 已驗證 | Task 25-7 |
| GitHub-hosted iOS build gate contract | Local/static verified；remote run待push | Task 25-8 |

以下聲明仍未驗證，Milestone 25不得宣稱已完成：

- 實體iPhone上的Face ID或Touch ID成功驗證。
- 實體裝置上的biometric nonmatch、user cancel、system cancel與lockout UX。
- 實體裝置Keychain在process termination、device restart或App upgrade後的持久性。
- 實體裝置background／inactive／resumed生命週期與biometric prompt互動。
- 實體裝置Logout後Keychain item刪除。
- Development signing、provisioning、archive、IPA與App Store distribution readiness。

## 後續實體裝置驗證程序

取得可用iPhone後，必須使用non-repository signing state執行：

1. 以Xcode local user setting或temporary untracked configuration選擇Development Team，不提交project diff。
2. 安裝development build至已信任的實體iPhone。
3. 使用真實Face ID／Touch ID驗證success、nonmatch、cancel與unavailable disposition。
4. 啟用local unlock，完成登入後terminate並relaunch，確認user presence成功前不restore credential。
5. 驗證Keychain write → terminate → restart → read，以及Logout → credential absent。
6. 驗證prompt造成的`inactive → resumed`不建立duplicate prompt。
7. 驗證grace-period resume與超時後fail-closed重新解鎖。
8. 完成後執行`git diff`與全repo signing-data scan，確認Team ID、certificate、profile與device identifier沒有進入tracked files。

## Review findings

| ID | Finding | Severity | Disposition |
|---|---|---:|---|
| M25-9-R01 | 沒有physical iOS device可供驗證 | P1 | 正式defer；精確列出未驗證claim，不以Simulator代替 |
| M25-9-R02 | 本機存在個人Apple Development identity | P1 | 僅確認identity可用；不記錄或提交Team ID、email、fingerprint與profile資料 |
| M25-9-R03 | 既有Task 25-1歷史review明文保留實際Team ID | P1 | 已redact並重跑repository signing-data scan |
| M25-9-R04 | Physical-device evidence可能被誤解為release readiness | P1 | 明確排除archive、IPA、App Store與distribution claim |

Open P0／P1 without disposition：0。

## Verification

```bash
flutter devices
xcrun xctrace list devices
git diff --check
dart run melos run docs_check
git grep -n -E 'DEVELOPMENT_TEAM = [A-Z0-9]+|Apple Development: .+\(.+\)|PROVISIONING_PROFILE_SPECIFIER = .+'
```

Repository可保留generic build-setting key與禁止規則，但不得保留實際Team ID、identity owner、certificate fingerprint或provisioning profile value。

## Review decision

Task 25-9通過formal disposition review：目前iOS support可宣稱Simulator build與runtime evidence成立；physical-device、real biometric、device Keychain persistence及distribution evidence維持deferred。
