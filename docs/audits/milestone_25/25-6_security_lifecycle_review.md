# Milestone 25-6 — Security Plugin and Lifecycle Review

Status: Accepted

## Scope

本Task驗證iOS Simulator上的Secure Storage、local_auth capability與本機解鎖生命週期契約。實作未改變production adapter或coordinator，只新增device-level regression harness。

## Runtime environment

- Device: iPhone 17 Pro Simulator
- Runtime: iOS 26.5
- Bundle identifier: `com.example.flutterarchitecture`
- Flutter entry: repository integration test runner

## Keychain evidence

`integration_test/security_lifecycle_smoke_test.dart`使用production DI取得`AuthCredentialStore`，執行：

```text
clear
→ write complete token pair
→ read present
→ reset composition root
→ configure production DI again
→ read same access token / refresh token / user id
→ LogoutUseCase.execute
→ read absent
```

結果：passed。

此證據確認`flutter_secure_storage_darwin`在Simulator上的write／read／delete可用，且資料不依賴原adapter instance。測試值只存在於測試Runner的Simulator Keychain，未寫入文件或log。

## Cold-start fail-closed gate

使用實際`LocalUnlockPreferenceStore`、`AuthCredentialStore`、`SessionManager`與`AuthStateMutationCoordinator`，搭配可控user-presence verifier：

```text
preference = enabled
session initially authenticated
start coordinator
→ state = prompting
→ runtime session cleared
→ restore callback credential reads = 0
user presence verified
→ restore callback credential reads = 1
```

結果：enabled cold start在user presence成功前不讀取credential，也不保留runtime authenticated session。

## Lifecycle evidence

Device-level harness驗證：

- prompt-owned lifecycle bounce不建立第二個prompt；
- grace period內resume不觸發重新解鎖；
-超過5分鐘後resume先清除session，再重新執行unlock；
-重新驗證前session維持fail closed。

結果：passed。

既有focused tests另外覆蓋cancel、corrupted preference、superseded lifecycle operation與server-login escape failure。

## local_auth disposition

production `LocalAuthUserPresenceVerifier.checkCapability()`已在iOS Simulator實際執行並回傳typed `available`或`unavailable` disposition，沒有`MissingPluginException`或未映射platform error。

本機Xcode 26.5的`simctl`不提供`biometric` subcommand，因此無法以repository-owned CLI自動切換enrollment或送出match／nonmatch事件。基於「where simulator supports them」邊界，本Task不偽造success／nonmatch／cancel的native prompt evidence；這些mapping維持由`local_auth_user_presence_verifier_test.dart`的focused adapter tests驗證。實體Face ID／Touch ID acceptance仍保留Task 25-9 disposition。

## Review findings and corrections

1. 初版integration test重複呼叫`bootstrap()`，與global uncaught-error hook的single-install contract衝突。
   - Root cause: test isolation方式錯誤，不是App bootstrap缺陷。
   - Correction: device smoke改用`initializeDatabaseFactory()`與`configureDependencies()`重建composition root，不重裝global hooks。

2. 初版Keychain assertion直接比較`StoredAuthTokens` instance。
   - Root cause:該型別未定義value equality。
   - Correction:逐欄位驗證access token、refresh token與user id。

3. Xcode 26.5無`simctl biometric`。
   - Disposition: runtime capability與plugin registration可驗證；native prompt match／nonmatch／cancel不可宣稱已自動驗證。

## Verification

```text
flutter test integration_test/security_lifecycle_smoke_test.dart -d <simulator>
→ 4 tests passed
```

Open P0/P1 without disposition: 0

## Decision

Task 25-6 accepted。iOS Keychain persistence／Logout deletion、cold-start user-presence gate、prompt deduplication、grace-period resume與fail-closed行為均具Simulator evidence。Native biometric prompt outcome automation受目前Simulator CLI能力限制，已明確降級為capability runtime evidence + adapter mapping tests + Task 25-9 physical-device disposition。
